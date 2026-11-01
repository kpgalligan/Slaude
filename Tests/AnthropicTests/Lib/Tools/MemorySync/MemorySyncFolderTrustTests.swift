// Port of tests/lib/tools/memory_sync/test_folder_trust.py: folder-trust gating. A missing, emptied, or swapped store
// folder is never trusted as a basis for deletions or uploads. A sync pass that finds the folder destroyed
// re-downloads it and pushes nothing; a sync that finds files without a matching marker leaves the folder as found.

import Foundation
import Testing
@testable import Anthropic

private let STORE_ID = "memstore_notes"
private func updated(_ path: String, _ content: String, was: String) -> MemorySyncCall { memorySyncUpdated(path, content, was: was) }
private func deleted(_ path: String, was: String) -> MemorySyncCall { memorySyncDeleted(path, was: was) }
private func markerStamp(_ local: MemorySyncFolder) -> String? { local.read(MARKER_PATH) }
private func count(_ text: String, _ needle: String) -> Int { text.components(separatedBy: needle).count - 1 }

@Suite struct MemorySyncFolderTrustTests {
    /// rm -rf of the whole folder between syncs: the next sync must not read the emptiness as "the agent deleted
    /// everything" and wipe the server.
    @Test func aDeletedFolderIssuesNoDeletesAndIsRebuilt() async throws {
        let clock = MemorySyncClock()
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1", "b.md": "v1"], clock: clock)
        let server = fake.server
        try local.removeTree()

        let (_, capture) = await ToolDiagnostics.capture { await memorySyncRun(stores) }

        #expect(server.received.isEmpty)
        #expect(server.texts == ["a.md": "v1", "b.md": "v1"])
        #expect(local.read("a.md") == "v1")
        #expect(local.read("b.md") == "v1")
        #expect(markerStamp(local) == "version 1\n\(STORE_ID)")
        #expect(memorySyncLogText(capture).contains("the folder or its marker is gone; re-downloading"))

        // The rebuilt folder syncs normally: an edit and a deletion both propagate.
        try local.write("a.md", "v2")
        try local.unlink("b.md")
        await memorySyncRun(stores)
        clock.now = DELETE_CORROBORATION_SECONDS + 1
        await memorySyncRun(stores)
        #expect(server.received == [updated("a.md", "v2", was: "v1"), deleted("b.md", was: "v1")])
        #expect(server.texts == ["a.md": "v2"])
    }

    @Test func anEmptiedFolderIssuesNoDeletesAndIsRepopulated() async throws {
        let clock = MemorySyncClock()
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1", "b.md": "v1"], clock: clock)
        for child in try FileManager.default.contentsOfDirectory(atPath: local.path) { try local.unlink(child) }

        let (_, capture) = await ToolDiagnostics.capture { await memorySyncRun(stores) }

        #expect(fake.server.received.isEmpty)
        #expect(fake.server.texts == ["a.md": "v1", "b.md": "v1"])
        #expect(local.read("a.md") == "v1")
        #expect(markerStamp(local) == "version 1\n\(STORE_ID)")
        #expect(memorySyncLogText(capture).contains("the folder or its marker is gone; re-downloading"))

        try local.unlink("a.md")
        await memorySyncRun(stores)
        clock.now = DELETE_CORROBORATION_SECONDS + 1
        await memorySyncRun(stores)
        #expect(fake.server.received == [deleted("a.md", was: "v1")])
    }

    /// `rm <mount>/*`: shell globs skip dotfiles, so the marker survives the wipe — an intact marker alone must not
    /// clear a folder whose every memory file vanished at once.
    @Test func anEmptiedFolderWithTheMarkerLeftBehindIssuesNoDeletes() async throws {
        let clock = MemorySyncClock()
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1", "b.md": "v1"], clock: clock)
        for child in try FileManager.default.contentsOfDirectory(atPath: local.path) where child != MARKER_PATH { try local.unlink(child) }

        let (_, capture) = await ToolDiagnostics.capture { await memorySyncRun(stores) }

        #expect(fake.server.received.isEmpty)
        #expect(fake.server.texts == ["a.md": "v1", "b.md": "v1"])
        #expect(local.read("a.md") == "v1")
        #expect(memorySyncLogText(capture).contains("every memory file is gone at once; re-downloading"))

        // With files present again, an ordinary single deletion still propagates.
        try local.unlink("a.md")
        await memorySyncRun(stores)
        clock.now = DELETE_CORROBORATION_SECONDS + 1
        await memorySyncRun(stores)
        #expect(fake.server.received == [deleted("a.md", was: "v1")])
    }

    /// A folder carrying another store's marker is foreign: no deletes, no uploads, no restamp — on this pass or any
    /// later one.
    @Test func aSwappedFolderNeitherDeletesNorUploadsEver() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1"])
        try local.removeTree()
        try local.write(MARKER_PATH, "memstore_other")
        try local.write("foreign.md", "someone else's notes")

        let (_, capture) = await ToolDiagnostics.capture {
            await memorySyncRun(stores)
            await memorySyncRun(stores)
        }

        #expect(fake.server.received.isEmpty)
        #expect(fake.server.texts == ["a.md": "v1"])
        #expect(local.read(MARKER_PATH) == "memstore_other")
        #expect(local.read("foreign.md") == "someone else's notes")
        #expect(!local.exists("a.md"))
        #expect(memorySyncLogText(capture).contains("the marker file does not match this store; leaving the memory store folder as found"))
    }

    /// Only the marker was deleted (a dotfile cleanup): the remaining files may hold un-pushed edits, so the pass must
    /// neither upload them, nor delete by them, nor destroy them by re-downloading over the folder.
    @Test func filesWithoutAMarkerAreNeitherPushedNorPulledOver() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1", "b.md": "v1"])
        try local.unlink(MARKER_PATH)
        try local.write("a.md", "un-pushed edit")
        try local.unlink("b.md")

        let (_, capture) = await ToolDiagnostics.capture { await memorySyncRun(stores) }

        #expect(fake.server.received.isEmpty)
        #expect(fake.server.texts == ["a.md": "v1", "b.md": "v1"])
        #expect(local.read("a.md") == "un-pushed edit")
        #expect(!local.exists(MARKER_PATH))
        #expect(memorySyncLogText(capture).contains("the marker file is gone; leaving the memory store folder as found"))
    }

    @Test func aSingleLocalDeletionWithTheMarkerIntactStillPropagates() async throws {
        let clock = MemorySyncClock()
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1", "b.md": "v1"], clock: clock)
        try local.unlink("a.md")

        await memorySyncRun(stores)
        clock.now = DELETE_CORROBORATION_SECONDS + 1
        await memorySyncRun(stores)

        #expect(fake.server.received == [deleted("a.md", was: "v1")])
        #expect(fake.server.texts == ["b.md": "v1"])
        #expect(markerStamp(local) == "version 1\n\(STORE_ID)")
    }

    @Test func theMarkerNeverSyncsInEitherDirection() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1"])

        // The marker sits in the folder yet is never uploaded or remote-deleted.
        await memorySyncRun(stores)
        #expect(fake.server.received.isEmpty)

        // A marker path the server lists is refused: skipped with a warning, never written over the real marker.
        fake.server.write(MARKER_PATH, "not a store id")
        let (_, capture) = await ToolDiagnostics.capture { await memorySyncRun(stores) }
        #expect(fake.server.received.isEmpty)
        #expect(markerStamp(local) == "version 1\n\(STORE_ID)")
        #expect(memorySyncLogText(capture).contains("reserved marker path"))
    }

    @Test func disposeToleratesAnAlreadyDeletedFolder() async throws {
        let (local, _, stores, _) = try await memorySyncDownloaded(["a.md": "v1"])
        try local.removeTree()

        await stores.dispose()

        #expect(!local.exists())
    }

    /// Sync left the folder as found after a failed marker check; teardown must not then delete the files.
    @Test func disposeKeepsAFolderThatFailsTheMarkerCheck() async throws {
        let (local, _, stores, _) = try await memorySyncDownloaded(["a.md": "v1"])
        try local.unlink(MARKER_PATH)
        try local.write("a.md", "un-pushed edit")

        let (_, capture) = await ToolDiagnostics.capture { await stores.dispose() }

        #expect(local.read("a.md") == "un-pushed edit")
        #expect(memorySyncLogText(capture).contains("leaving the memory store folder on disk"))
    }

    /// A store whose folder something replaced with a regular file must log and be skipped, not raise out of the
    /// teardown.
    @Test func disposeNeverRaisesWhenAStoreRootIsReplacedByAFile() async throws {
        let (local, _, stores, _) = try await memorySyncDownloaded(["a.md": "v1"])
        try local.removeTree()
        try Data("a file where the folder was".utf8).write(to: URL(fileURLWithPath: local.path))

        await stores.dispose()

        #expect(FileManager.default.contents(atPath: local.path).map { String(decoding: $0, as: UTF8.self) } == "a file where the folder was")
    }

    /// A marker in the old format (the bare store id) must fail the check, and the folder is left as found.
    @Test func aMarkerFromAnOlderFormatNoLongerClearsTheFolder() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1", "b.md": "v1"])
        try local.write(MARKER_PATH, STORE_ID)
        try local.write("a.md", "edit under the old marker")
        try local.unlink("b.md")

        let (_, capture) = await ToolDiagnostics.capture { await memorySyncRun(stores) }

        #expect(fake.server.received.isEmpty)
        #expect(fake.server.texts == ["a.md": "v1", "b.md": "v1"])
        #expect(local.read("a.md") == "edit under the old marker")
        #expect(memorySyncLogText(capture).contains("the marker file does not match this store"))
    }

    /// rm -rf lands between a sync's scan and its content write: the write must not bring the folder back without its
    /// marker, or every later sync reads the folder as foreign.
    @Test(arguments: ["z.md", "sub/z.md"])
    func aFolderWipedWhileAPullIsInFlightIsRebuiltNotDistrusted(rel: String) async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["x.md": "v1", "y.md": "v1", rel: "v1"])
        let server = fake.server
        server.write(rel, "v2")
        server.fetchHook = { _ in try? local.removeTree() }

        let (_, capture) = try await ToolDiagnostics.capture {
            await memorySyncRun(stores)

            #expect(!local.exists())
            #expect(server.received.isEmpty)

            server.fetchHook = nil
            await memorySyncRun(stores)

            #expect(markerStamp(local) == "version 1\n\(STORE_ID)")
            #expect(local.read("x.md") == "v1")
            #expect(local.read(rel) == "v2")

            try await stores.finish()
            await stores.flushWrites()
            await stores.dispose()
        }
        let text = memorySyncLogText(capture)
        #expect(text.contains("re-downloading the memory store folder"))
        #expect(!text.contains("leaving the memory store folder as found"))
        #expect(!local.exists())
        #expect(server.received.isEmpty)
        #expect(server.texts == ["x.md": "v1", "y.md": "v1", rel: "v2"])
    }

    /// An rm -rf that lands while a locally deleted, remotely changed memory is being restored must leave no folder
    /// behind, the sync after it must rebuild the whole store, and the earlier absence must never become a delete.
    @Test func aFolderWipedWhileALocallyDeletedMemoryIsBeingRestoredIsRebuilt() async throws {
        let clock = MemorySyncClock()
        let (local, fake, stores, _) = try await memorySyncDownloaded(["x.md": "v1", "y.md": "v1", "z.md": "v1"], clock: clock)
        let server = fake.server
        try local.unlink("z.md")
        server.write("z.md", "v2")
        server.fetchHook = { _ in try? local.removeTree() }

        let (_, capture) = await ToolDiagnostics.capture {
            await memorySyncRun(stores)
            #expect(!local.exists())

            server.fetchHook = nil
            await memorySyncRun(stores)
            #expect(markerStamp(local) == "version 1\n\(STORE_ID)")
            #expect(local.read("x.md") == "v1")
            #expect(local.read("y.md") == "v1")
            #expect(local.read("z.md") == "v2")

            clock.now = DELETE_CORROBORATION_SECONDS + 1
            await memorySyncRun(stores)
        }
        #expect(server.received.isEmpty)
        #expect(server.texts == ["x.md": "v1", "y.md": "v1", "z.md": "v2"])
        #expect(!memorySyncLogText(capture).contains("leaving the memory store folder as found"))
    }

    /// A re-download writes the marker first and the memories after it; a second rm -rf between those writes must
    /// not leave memories on disk without a marker — the next sync re-downloads once more instead.
    @Test func aFolderWipedAgainMidRecoveryIsRebuiltByTheNextSync() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1", "b.md": "v1", "c.md": "v1"])
        try local.removeTree()

        let (_, capture) = await ToolDiagnostics.capture {
            await memorySyncInterruptListing(stores, afterItems: 1) { try? local.removeTree() }
            await memorySyncRun(stores)
            await memorySyncStopInterrupting(stores)

            #expect(!local.exists())
            #expect(fake.server.received.isEmpty)

            await memorySyncRun(stores)
        }

        #expect(markerStamp(local) == "version 1\n\(STORE_ID)")
        for name in ["a.md", "b.md", "c.md"] { #expect(local.read(name) == "v1") }
        let text = memorySyncLogText(capture)
        #expect(count(text, "re-downloading the memory store folder") == 2)
        #expect(!text.contains("leaving the memory store folder as found"))
        #expect(fake.server.received.isEmpty)

        await stores.dispose()
        #expect(!local.exists())
    }
}
