// Port of tests/lib/tools/memory_sync/test_delete_discipline.py.
//
// Server-delete discipline: a locally deleted file is deleted on the server only after a second sync confirms it, at
// a bounded rate per sync, and only when server deletes are enabled at all.

import Foundation
import Testing
@testable import Anthropic

private let ELAPSED = DELETE_CORROBORATION_SECONDS + 1
private func deleted(_ path: String, was: String) -> MemorySyncCall { memorySyncDeleted(path, was: was) }
private func updated(_ path: String, _ content: String, was: String) -> MemorySyncCall { memorySyncUpdated(path, content, was: was) }

/// `listing_interrupted_by`: runs `interrupt` once per listing while a sync's server listing is consumed — right after
/// `afterItems` listed memories were handled, or once the listing is exhausted when `nil`.
func memorySyncInterruptListing(_ stores: SessionMemoryStores, afterItems: Int? = nil,
                                _ interrupt: @escaping @Sendable () -> Void) async
{
    var hooks = await stores.hooks
    hooks.listing = { count in if count == afterItems { interrupt() } }
    await stores.setHooks(hooks)
}

func memorySyncStopInterrupting(_ stores: SessionMemoryStores) async {
    var hooks = await stores.hooks
    hooks.listing = nil
    await stores.setHooks(hooks)
}

@Suite struct MemorySyncDeleteDisciplineTests {
    @Test func aLocalDeletionIsConfirmedBeforeItReachesTheServer() async throws {
        let clock = MemorySyncClock()
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1", "keep.md": "v1"], clock: clock)
        let server = fake.server
        try local.unlink("a.md")

        // The first pass only records the absence.
        await memorySyncRun(stores)
        #expect(server.received.isEmpty)
        #expect(server.texts == ["a.md": "v1", "keep.md": "v1"])

        // Still inside the window: nothing goes out.
        clock.now = DELETE_CORROBORATION_SECONDS - 1
        await memorySyncRun(stores)
        #expect(server.received.isEmpty)

        // Window elapsed and the file is still gone: the guarded delete is sent.
        clock.now = ELAPSED
        await memorySyncRun(stores)
        #expect(server.received == [deleted("a.md", was: "v1")])
        #expect(server.texts == ["keep.md": "v1"])
    }

    @Test func aFileThatReappearsIsNotDeletedAndLeavesPending() async throws {
        let clock = MemorySyncClock()
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1"], clock: clock)
        let server = fake.server
        try local.unlink("a.md")
        await memorySyncRun(stores)

        try local.write("a.md", "v1")
        clock.now = ELAPSED
        await memorySyncRun(stores)
        #expect(server.received.isEmpty)
        #expect(server.texts == ["a.md": "v1"])

        // The reappearance cleared the pending entry: deleting again starts a fresh window.
        try local.unlink("a.md")
        await memorySyncRun(stores)
        #expect(server.received.isEmpty)
        clock.now = 2 * ELAPSED
        await memorySyncRun(stores)
        #expect(server.received == [deleted("a.md", was: "v1")])
    }

    @Test func disabledModeNeverDeletesButStillSyncs() async throws {
        let clock = MemorySyncClock()
        let (local, fake, stores, _) = try await memorySyncDownloaded(
            ["gone.md": "v1", "push.md": "v1", "pull.md": "v1"], clock: clock, syncDeletions: .disabled)
        let server = fake.server
        try local.unlink("gone.md")
        try local.write("push.md", "v2 from agent")
        server.write("pull.md", "v2 from server")

        let (_, capture) = await ToolDiagnostics.capture {
            await memorySyncRun(stores)
            clock.now = ELAPSED
            await memorySyncRun(stores)
            clock.now = 2 * ELAPSED
            await memorySyncRun(stores)
        }

        // Uploads and pulls still flow; the deletion never does.
        #expect(server.received == [updated("push.md", "v2 from agent", was: "v1")])
        #expect(server.texts == ["gone.md": "v1", "push.md": "v2 from agent", "pull.md": "v2 from server"])
        #expect(local.read("pull.md") == "v2 from server")
        #expect(memorySyncLogText(capture).contains("server deletes are disabled"))
    }

    @Test func thePerPassCapSpreadsDeletesOverPasses() async throws {
        let clock = MemorySyncClock()
        var files: [String: String] = [:]
        for i in 0..<14 { files[String(format: "f%02d.md", i)] = "v1" }
        let (local, fake, stores, _) = try await memorySyncDownloaded(files, clock: clock)
        let server = fake.server
        let doomed = Array(files.keys.sorted().prefix(12))
        for name in doomed { try local.unlink(name) }

        await memorySyncRun(stores)
        #expect(server.received.isEmpty)

        // cap = max(8, min(50, 14 / 4)) = 8: the first confirming sync stops there.
        clock.now = ELAPSED
        let (_, capture) = await ToolDiagnostics.capture { await memorySyncRun(stores) }
        #expect(server.received == doomed.prefix(8).map { deleted($0, was: "v1") })
        #expect(memorySyncLogText(capture).contains("delete cap reached: sent 8 deletes, held 4 for later syncs"))

        // The held-back deletions confirm on the next pass.
        await memorySyncRun(stores)
        #expect(server.received == doomed.map { deleted($0, was: "v1") })
        #expect(server.texts == Dictionary(uniqueKeysWithValues: files.keys.sorted().dropFirst(12).map { ($0, "v1") }))
    }

    /// A deletion made in a session shorter than the waiting window still goes through: the final sync skips the
    /// wait, and the re-check just before the delete stands in for the second observation.
    @Test func theFinalSyncWaivesTheWindowButStillReChecks() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1", "keep.md": "v1"])
        try local.unlink("a.md")

        try await stores.finish()

        #expect(fake.server.received == [deleted("a.md", was: "v1")])
        #expect(fake.server.texts == ["keep.md": "v1"])
    }

    /// The directory scan saw an intact folder, then the folder vanished while the server listing was in flight: the
    /// re-check just before the delete must notice the marker is gone and hold every delete.
    @Test func aFolderDestroyedMidSyncSendsNoDeletes() async throws {
        let clock = MemorySyncClock()
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1", "keep.md": "v1"], clock: clock)
        try local.unlink("a.md")
        await memorySyncRun(stores)
        clock.now = ELAPSED

        await memorySyncInterruptListing(stores) { try? local.removeTree() }
        await memorySyncRun(stores)
        await memorySyncStopInterrupting(stores)

        #expect(fake.server.received.isEmpty)
        #expect(fake.server.texts == ["a.md": "v1", "keep.md": "v1"])
    }

    /// Files under a directory the scan cannot enter are not treated as deleted.
    @Test func anUnreadableSubdirectoryFailsThePassInsteadOfReadingAsDeletions() async throws {
        if geteuid() == 0 { return }  // permission checks do not bind root
        let clock = MemorySyncClock()
        let (local, fake, stores, _) = try await memorySyncDownloaded(["sub/a.md": "v1", "sub/b.md": "v1", "top.md": "v1"], clock: clock)
        try local.write("top.md", "v2")
        chmod(local.file("sub"), 0o000)
        let (_, capture) = await ToolDiagnostics.capture {
            await memorySyncRun(stores)
            clock.now = ELAPSED
            await memorySyncRun(stores)
        }
        chmod(local.file("sub"), 0o700)

        #expect(fake.server.received.isEmpty)
        #expect(memorySyncLogText(capture).components(separatedBy: "memory sync failed").count - 1 == 2)

        // Readable again: the edit goes out and nothing is deleted.
        clock.now = 2 * ELAPSED
        await memorySyncRun(stores)
        #expect(fake.server.received == [updated("top.md", "v2", was: "v1")])
        #expect(fake.server.texts == ["sub/a.md": "v1", "sub/b.md": "v1", "top.md": "v2"])
    }

    /// The re-download rebuilt the disk, so an absence observed before it says nothing about the rebuilt folder.
    @Test func aRecoveryReDownloadClearsPendingDeletes() async throws {
        let clock = MemorySyncClock()
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1"], clock: clock)
        try local.unlink("a.md")
        await memorySyncRun(stores)

        clock.now = ELAPSED
        try local.removeTree()
        await memorySyncRun(stores)
        #expect(local.read("a.md") == "v1")

        // A fresh deletion starts a fresh window — the pre-recovery observation must not corroborate it.
        try local.unlink("a.md")
        await memorySyncRun(stores)
        #expect(fake.server.received.isEmpty)
        clock.now = 2 * ELAPSED
        await memorySyncRun(stores)
        #expect(fake.server.received == [deleted("a.md", was: "v1")])
    }

    /// The dry-run setting: the full pipeline runs — window, re-checks, cap — but the confirmed delete is logged
    /// instead of sent, on every sync while the file stays missing.
    @Test func logOnlyModeLogsTheDeleteButNeverSendsIt() async throws {
        let clock = MemorySyncClock()
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1", "keep.md": "v1"], clock: clock, syncDeletions: .logOnly)
        try local.unlink("a.md")

        let (_, first) = await ToolDiagnostics.capture { await memorySyncRun(stores) }
        #expect(!memorySyncLogText(first).contains("log-only"))  // still inside the waiting window

        clock.now = ELAPSED
        let (_, capture) = await ToolDiagnostics.capture {
            await memorySyncRun(stores)
            await memorySyncRun(stores)
        }

        #expect(fake.server.received.isEmpty)
        #expect(fake.server.texts == ["a.md": "v1", "keep.md": "v1"])
        #expect(memorySyncLogText(capture).components(separatedBy: "log-only: sync would delete this memory on the server path=a.md").count - 1 == 2)
    }

    @Test func finishRunsOnceAndASecondCallRaises() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1"])
        try local.write("a.md", "v2")

        try await stores.finish()
        #expect(fake.server.texts == ["a.md": "v2"])

        do {
            try await stores.finish()
            Issue.record("expected an error")
        } catch let error as AnthropicError {
            #expect(error.message.contains("finish"))
        }
    }
}
