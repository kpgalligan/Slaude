// Port of tests/lib/tools/memory_sync/test_two_pass.py: the sync's two passes, a content-free listing, then
// targeted fetches.

import Foundation
import Testing
@testable import Anthropic

@Suite struct MemorySyncTwoPassTests {
    @Test func aSyncThatPullsNothingFetchesNoContent() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1", "b.md": "v1", "c.md": "v1"])
        // The download took full listing pages: no single-memory fetches at all.
        #expect(fake.server.contentFetches.isEmpty)

        try local.write("a.md", "v2 from agent")  // a push needs no remote content
        await memorySyncRun(stores)

        #expect(fake.server.contentFetches.isEmpty)
        #expect(fake.server.texts["a.md"] == "v2 from agent")
    }

    @Test func onlyTheChangedMemoryIsFetched() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1", "b.md": "v1"])
        fake.server.clearFetches()

        fake.server.write("a.md", "v2 from server")
        await memorySyncRun(stores)

        #expect(fake.server.contentFetches == ["a.md"])
        #expect(local.read("a.md") == "v2 from server")
        #expect(local.read("b.md") == "v1")
    }

    @Test func aFileAlreadyHoldingTheRemoteContentIsAdoptedWithoutAFetch() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1"])
        fake.server.clearFetches()

        // Both sides landed on the same bytes independently.
        try local.write("a.md", "v2 on both")
        fake.server.write("a.md", "v2 on both")
        await memorySyncRun(stores)

        #expect(fake.server.contentFetches.isEmpty)
        #expect(fake.server.received.isEmpty)

        // The baseline advanced to the adopted sha: the next edit pushes guarded by it.
        try local.write("a.md", "v3 from agent")
        await memorySyncRun(stores)
        #expect(fake.server.received == [memorySyncUpdated("a.md", "v3 from agent", was: "v2 on both")])
    }

    /// The first memory's fetch completes only after the second's starts — only parallel fetches satisfy that.
    @Test func contentFetchesFanOutWithinAStore() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1", "b.md": "v1"])
        fake.server.write("a.md", "v2 from server")
        fake.server.write("b.md", "v2 from server")

        let secondStarted = ToolsBox(false)
        fake.memories.wrapRetrieve = { path, real in
            if path == "a.md" {
                let start = Date()
                while !secondStarted.value {
                    if Date().timeIntervalSince(start) > 10 { throw MemorySyncRuntimeError("the second fetch never started") }
                    try await Task.sleep(nanoseconds: 1_000_000)
                }
            } else {
                secondStarted.value = true
            }
            return try await real()
        }
        await memorySyncRun(stores)

        #expect(local.read("a.md") == "v2 from server")
        #expect(local.read("b.md") == "v2 from server")
    }

    @Test func aFailedFetchKeepsTheOldStateAndTheNextSyncRetries() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1"])
        fake.server.write("a.md", "v2 from server")

        fake.server.fetchHook = { _ in throw memorySyncStatusError(500) }
        await memorySyncRun(stores)
        #expect(local.read("a.md") == "v1")

        fake.server.fetchHook = nil
        await memorySyncRun(stores)
        #expect(local.read("a.md") == "v2 from server")
        // The stale baseline drove no uploads or deletes along the way.
        #expect(fake.server.received.isEmpty)
    }

    @Test func aMemoryDeletedBetweenListingAndFetchWaitsForTheNextSync() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1", "keep.md": "v1"])
        let server = fake.server
        server.write("a.md", "v2 from server")

        server.fetchHook = { path in server.delete(path) }
        await memorySyncRun(stores)
        // The fetch 404ed: disk and baseline keep the old version for now.
        #expect(local.read("a.md") == "v1")

        server.fetchHook = nil
        await memorySyncRun(stores)
        // The next sync saw the server-side delete and took the local copy with it.
        #expect(!local.exists("a.md"))
        #expect(server.received.isEmpty)
    }
}
