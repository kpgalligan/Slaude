// Port of tests/lib/tools/memory_sync/test_keep_only_copy.py: never destroy the only copy of a local edit. A memory
// deleted remotely while its file holds an un-pushed edit keeps the file — a writable store re-creates the memory
// from it, a read-only store keeps it on disk unsynced. Only an unedited file follows the remote delete off the disk.

import Foundation
import Testing
@testable import Anthropic

private func created(_ path: String, _ content: String) -> MemorySyncCall { memorySyncCreated(path, content) }
private func updated(_ path: String, _ content: String, was: String) -> MemorySyncCall { memorySyncUpdated(path, content, was: was) }

private struct KeepOnlyCopyIOError: Error, CustomStringConvertible {
    var description: String { "[Errno 5] I/O error" }
}

@Suite struct MemorySyncKeepOnlyCopyTests {
    @Test func anEditedFileSurvivesARemoteDeleteAndIsReCreated() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["edited.md": "v1", "plain.md": "v1"])
        let server = fake.server
        try local.write("edited.md", "v2 from agent")
        server.delete("edited.md")
        server.delete("plain.md")

        let (_, capture) = await ToolDiagnostics.capture { await memorySyncRun(stores) }

        // The edit's only copy survives and the memory is re-created from it; the unedited file follows the remote
        // delete off the disk.
        #expect(local.read("edited.md") == "v2 from agent")
        #expect(server.texts == ["edited.md": "v2 from agent"])
        #expect(server.received == [created("edited.md", "v2 from agent")])
        #expect(!local.exists("plain.md"))
        #expect(memorySyncLogText(capture, atLeast: .info).contains("re-creating it from the file"))

        // Settled: nothing more goes out.
        await memorySyncRun(stores)
        #expect(server.received == [created("edited.md", "v2 from agent")])

        // The upload's sha became the baseline: the next edit is a guarded update.
        try local.write("edited.md", "v3")
        await memorySyncRun(stores)
        #expect(server.received.last == updated("edited.md", "v3", was: "v2 from agent"))
    }

    @Test func aReadOnlyStoreKeepsTheEditedFileWithoutPushing() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["edited.md": "v1", "plain.md": "v1"], access: .readOnly)
        let server = fake.server
        try local.write("edited.md", "v2 from agent")
        server.delete("edited.md")
        server.delete("plain.md")

        let (_, capture) = await ToolDiagnostics.capture {
            await memorySyncRun(stores)
            #expect(local.read("edited.md") == "v2 from agent")
            #expect(!local.exists("plain.md"))
            #expect(server.received.isEmpty)
            // Later passes see a local-only file in a read-only store: a quiet no-op.
            await memorySyncRun(stores)
            await memorySyncRun(stores)
        }

        #expect(server.received.isEmpty)
        #expect(local.read("edited.md") == "v2 from agent")
        #expect(memorySyncLogText(capture, atLeast: .warning).components(separatedBy: "cannot push").count - 1 == 1)
    }

    /// The server already refused this content, so the remote delete neither removes the file nor triggers a
    /// re-create the server would refuse again.
    @Test func aRefusedEditSurvivesARemoteDeleteWithoutARetry() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["big.md": "v1"])
        let server = fake.server
        server.maxContentBytes = 64

        try local.write("big.md", String(repeating: "x", count: 100))
        await memorySyncRun(stores)
        #expect(server.received.count == 1)  // the one refused update

        server.delete("big.md")
        await memorySyncRun(stores)
        await memorySyncRun(stores)

        #expect(local.read("big.md") == String(repeating: "x", count: 100))
        #expect(server.received.count == 1)
        #expect(!server.has("big.md"))
    }

    /// An update that meets a 404 re-creates the memory in the same pass.
    @Test func aMemoryDeletedBetweenTheListingAndTheUpdateIsReCreated() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v1"])
        let server = fake.server
        try local.write("note.md", "v2 from agent")

        server.uploadHook = { path in
            server.delete(path)
            server.uploadHook = nil
        }
        await memorySyncRun(stores)

        #expect(server.texts == ["note.md": "v2 from agent"])
        #expect(server.received == [updated("note.md", "v2 from agent", was: "v1"), created("note.md", "v2 from agent")])

        // The create's sha is the new baseline.
        try local.write("note.md", "v3")
        await memorySyncRun(stores)
        #expect(server.received.last == updated("note.md", "v3", was: "v2 from agent"))
    }

    /// The directory scan saw the file unedited; an edit is written while the server listing is in flight. The
    /// removal must re-read the file instead of destroying the edit based on the stale scan.
    @Test func anEditWrittenMidSyncStillSurvivesARemoteDelete() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["z.md": "v1", "keep.md": "v1"])
        fake.server.delete("z.md")

        await memorySyncInterruptListing(stores) { try? local.write("z.md", "late edit") }
        await memorySyncRun(stores)
        await memorySyncStopInterrupting(stores)

        #expect(local.read("z.md") == "late edit")
        #expect(fake.server.texts["z.md"] == "late edit")
    }

    /// Read-only stores always take the server version, but overwriting a local edit must leave a trace.
    @Test func aReadOnlyPullOverALocalEditIsWarned() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["pull.md": "v1"], access: .readOnly)
        try local.write("pull.md", "local edit")
        fake.server.write("pull.md", "v2 from server")

        let (_, capture) = await ToolDiagnostics.capture { await memorySyncRun(stores) }

        #expect(local.read("pull.md") == "v2 from server")
        #expect(fake.server.received.isEmpty)
        #expect(memorySyncLogText(capture).contains("changed both locally and remotely"))
    }

    /// The re-read before removal can fail (a transient I/O error). That must mean "retry next sync", not "file
    /// gone": dropping the entry would make the next sync upload the file as new.
    @Test func aFailedReReadDoesNotResurrectAServerDeletedMemory() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["z.md": "v1", "keep.md": "v1"])
        fake.server.delete("z.md")

        await stores.setHooks(SessionMemoryHooks(beforeHashFile: { rel in if rel == "z.md" { throw KeepOnlyCopyIOError() } }))
        await memorySyncRun(stores)
        await stores.setHooks(SessionMemoryHooks())

        // The error held everything: file still on disk, nothing pushed.
        #expect(local.read("z.md") == "v1")
        #expect(fake.server.received.isEmpty)

        // With the error gone, the next sync completes the server delete.
        await memorySyncRun(stores)
        #expect(!local.exists("z.md"))
        #expect(!fake.server.has("z.md"))
        #expect(fake.server.received.isEmpty)
    }
}
