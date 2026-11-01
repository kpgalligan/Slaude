// Port of tests/lib/tools/memory_sync/test_lost_response.py: an upload whose response never arrives.
//
// The server can save a create or update and the response still be lost — a timeout, a dropped connection. The sync
// then cannot tell whether the bytes landed. If they did, the server's copy is the sync's own upload, not another
// writer's edit, and a newer local edit must go out over it.

import Foundation
import Testing
@testable import Anthropic

private func created(_ path: String, _ content: String) -> MemorySyncCall { memorySyncCreated(path, content) }
private func updated(_ path: String, _ content: String, was: String) -> MemorySyncCall { memorySyncUpdated(path, content, was: was) }
private func deleted(_ path: String, was: String) -> MemorySyncCall { memorySyncDeleted(path, was: was) }

/// `uploads_fail`: every create and update raises a connection error — after the server has saved the write (the
/// response was lost) or before it arrived at all — while `body` runs.
private func uploadsFail(_ memories: MemorySyncFakeMemories, afterSaving: Bool, _ body: () async throws -> Void) async rethrows {
    let failing: @Sendable (String, MemorySyncFakeMemories.Real) async throws -> SessionMemoryItem = { _, real in
        if afterSaving { _ = try await real() }
        throw APIConnectionError(request: nil)
    }
    memories.wrapCreate = failing
    memories.wrapUpdate = failing
    defer {
        memories.wrapCreate = nil
        memories.wrapUpdate = nil
    }
    try await body()
}

@Suite struct MemorySyncLostResponseTests {
    @Test func anEditMadeAfterALostUploadResponseStillReachesTheServer() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v0"])
        let server = fake.server

        try local.write("note.md", "v1")
        try local.write("new.md", "v1")
        await uploadsFail(fake.memories, afterSaving: true) { await memorySyncRun(stores) }
        // The server holds both writes; the sync never heard back.
        #expect(server.texts == ["note.md": "v1", "new.md": "v1"])

        try local.write("note.md", "v2")
        try local.write("new.md", "v2")
        await memorySyncRun(stores)

        // The server's v1 was this sync's own upload, so v2 goes out over it.
        #expect(server.texts == ["note.md": "v2", "new.md": "v2"])
        #expect(local.read("note.md") == "v2")
        #expect(local.read("new.md") == "v2")
        #expect(server.received == [
            created("new.md", "v1"), updated("note.md", "v1", was: "v0"), updated("new.md", "v2", was: "v1"),
            updated("note.md", "v2", was: "v1"),
        ])

        // Settled: nothing more to send.
        await memorySyncRun(stores)
        #expect(server.received.count == 4)
    }

    @Test func aRetryWhoseResponseIsLostIsRememberedToo() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v0"])

        try local.write("note.md", "v1")
        await uploadsFail(fake.memories, afterSaving: false) { await memorySyncRun(stores) }
        // The retry sends the same bytes; this time they land and the response is lost.
        await uploadsFail(fake.memories, afterSaving: true) { await memorySyncRun(stores) }
        #expect(fake.server.texts["note.md"] == "v1")

        try local.write("note.md", "v2")
        await memorySyncRun(stores)

        #expect(fake.server.texts["note.md"] == "v2")
        #expect(local.read("note.md") == "v2")
    }

    /// The client's own retry re-sends the update with the old precondition; the first attempt already moved the
    /// server, so the retry gets a 409.
    @Test func aClientRetryRefusedBecauseTheFirstAttemptLandedIsRemembered() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v0"])

        try local.write("note.md", "v1")
        fake.memories.wrapUpdate = { _, real in
            _ = try await real()
            return try await real()
        }
        await memorySyncRun(stores)
        fake.memories.wrapUpdate = nil
        #expect(fake.server.texts["note.md"] == "v1")
        #expect(fake.server.received == Array(repeating: updated("note.md", "v1", was: "v0"), count: 2))

        try local.write("note.md", "v2")
        await memorySyncRun(stores)

        #expect(fake.server.texts["note.md"] == "v2")
        #expect(local.read("note.md") == "v2")
    }

    @Test func aDeletionMadeAfterALostUploadResponseStillReachesTheServer() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v0", "keep.md": "v0"])

        try local.write("note.md", "v1")
        try local.write("new.md", "v1")
        await uploadsFail(fake.memories, afterSaving: true) { await memorySyncRun(stores) }
        try local.unlink("note.md")
        try local.unlink("new.md")

        try await stores.finish()

        // The server's copies are this sync's own uploads, so the deletions go out, guarded by the content sent.
        #expect(fake.server.texts == ["keep.md": "v0"])
        #expect(Array(fake.server.received.suffix(2)) == [deleted("new.md", was: "v1"), deleted("note.md", was: "v1")])
    }

    @Test func aFolderWipedAfterALostCreateResponseIsRebuiltNotReadAsDeletions() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v0"])

        try local.write("new.md", "v1")
        await uploadsFail(fake.memories, afterSaving: true) { await memorySyncRun(stores) }
        // Both files vanish at once; the marker stays.
        try local.unlink("note.md")
        try local.unlink("new.md")

        // The final sync waives the delete window, so a misread wipe would delete at once.
        try await stores.finish()

        // Two known files gone together is a wipe: re-downloaded, nothing deleted.
        #expect(fake.server.texts == ["note.md": "v0", "new.md": "v1"])
        #expect(local.read("note.md") == "v0")
        #expect(local.read("new.md") == "v1")
        #expect(fake.server.received == [created("new.md", "v1")])
    }

    @Test func theShutdownFlushPushesARevertMadeAfterALostUploadResponse() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v0"])

        try local.write("note.md", "v1")
        await uploadsFail(fake.memories, afterSaving: true) { await memorySyncRun(stores) }
        // Back to the last content the sync knows it saved — but the server moved on.
        try local.write("note.md", "v0")

        await stores.flushWrites()

        #expect(fake.server.texts["note.md"] == "v0")
        #expect(fake.server.received.last == updated("note.md", "v0", was: "v1"))
    }

    @Test func theShutdownFlushSendsNothingForARevertWhoseUploadNeverLanded() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v0", "keep.md": "v0"])

        try local.write("note.md", "v1")
        await uploadsFail(fake.memories, afterSaving: false) { await memorySyncRun(stores) }
        try local.write("note.md", "v0")
        // Another writer deletes the memory; the file holds no edit to save.
        fake.server.delete("note.md")

        await stores.flushWrites()

        #expect(fake.server.texts == ["keep.md": "v0"])
        #expect(fake.server.received.isEmpty)
    }

    @Test func theShutdownFlushPushesAnEditMadeAfterALostUploadResponse() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v0"])

        try local.write("note.md", "v1")
        await uploadsFail(fake.memories, afterSaving: true) { await memorySyncRun(stores) }
        try local.write("note.md", "v2")

        await stores.flushWrites()

        #expect(fake.server.texts["note.md"] == "v2")
        #expect(fake.server.received.last == updated("note.md", "v2", was: "v1"))
    }

    @Test func anotherWritersEditAfterALostUploadResponseStillWins() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v0"])

        try local.write("note.md", "v1")
        await uploadsFail(fake.memories, afterSaving: true) { await memorySyncRun(stores) }
        fake.server.write("note.md", "theirs")
        try local.write("note.md", "v2")

        let (_, capture) = await ToolDiagnostics.capture { await memorySyncRun(stores) }

        // The server's copy is not what this sync sent, so the usual conflict rule holds.
        #expect(fake.server.texts["note.md"] == "theirs")
        #expect(local.read("note.md") == "theirs")
        #expect(memorySyncLogText(capture).contains("changed both locally and remotely"))
    }

    /// A remembered send must not outlive the next completed sync: kept longer, it would mistake another writer's
    /// identical bytes for this sync's upload and overwrite them.
    @Test func aSendIsForgottenOnceALaterSyncHasSeenTheServer() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v0"])
        let server = fake.server

        try local.write("note.md", "v1")
        await uploadsFail(fake.memories, afterSaving: false) { await memorySyncRun(stores) }
        #expect(server.texts["note.md"] == "v0")

        // The agent reverts, so the next sync has nothing to send — its listing shows the v1 upload never landed.
        try local.write("note.md", "v0")
        await memorySyncRun(stores)

        // Another writer now saves the very bytes that failed upload carried.
        server.write("note.md", "v1")
        try local.write("note.md", "v2")
        let (_, capture) = await ToolDiagnostics.capture { await memorySyncRun(stores) }

        #expect(server.texts["note.md"] == "v1")
        #expect(local.read("note.md") == "v1")
        #expect(memorySyncLogText(capture).contains("changed both locally and remotely"))
        #expect(server.received.isEmpty)
    }
}
