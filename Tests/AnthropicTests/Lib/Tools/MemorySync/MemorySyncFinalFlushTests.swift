// Port of tests/lib/tools/memory_sync/test_final_flush.py: `flushWrites` — the push-only shutdown pass.
//
// A session that ends on an error or cancel gets no full reconcile, but the writes already on disk are the only copy
// of the agent's edits. `flushWrites` pushes those and does nothing else: no remote deletes, no local removals, no
// pulls.

import Foundation
import Testing
@testable import Anthropic

private func created(_ path: String, _ content: String) -> MemorySyncCall { memorySyncCreated(path, content) }
private func updated(_ path: String, _ content: String, was: String) -> MemorySyncCall { memorySyncUpdated(path, content, was: was) }

private func sortedCalls(_ calls: [MemorySyncCall]) -> [String] { calls.map(\.description).sorted() }

@Suite struct MemorySyncFinalFlushTests {
    @Test func flushPushesNewAndChangedFilesAndNothingElse() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded([
            "a-pull.md": "v1", "b-push.md": "v1", "d-local-gone.md": "v1", "e-remote-gone.md": "v1",
            "f-remote-gone-edited.md": "v1", "g-both.md": "v1",
        ])
        let server = fake.server

        try local.write("b-push.md", "v2 from agent")
        try local.write("c-new.md", "new from agent")
        try local.unlink("d-local-gone.md")
        try local.write("f-remote-gone-edited.md", "v2 from agent")
        try local.write("g-both.md", "v2 from agent")
        server.write("a-pull.md", "v2 from server")
        server.delete("e-remote-gone.md")
        server.delete("f-remote-gone-edited.md")
        server.write("g-both.md", "v2 from server")

        let (_, capture) = await ToolDiagnostics.capture { await stores.flushWrites() }

        // Only additions went out: the update, the new file, and the re-created edited file whose remote copy was
        // deleted.
        let sent = [
            updated("b-push.md", "v2 from agent", was: "v1"), created("c-new.md", "new from agent"),
            created("f-remote-gone-edited.md", "v2 from agent"),
        ]
        #expect(sortedCalls(server.received) == sortedCalls(sent))
        // A locally missing file was not deleted remotely.
        #expect(server.texts["d-local-gone.md"] == "v1")
        // A remotely deleted, locally unedited memory was not re-uploaded — and its file was not removed either.
        #expect(!server.has("e-remote-gone.md"))
        #expect(local.read("e-remote-gone.md") == "v1")
        // Remote changes were not pulled.
        #expect(local.read("a-pull.md") == "v1")
        // The conflict was left to the server, and logged.
        #expect(server.texts["g-both.md"] == "v2 from server")
        #expect(local.read("g-both.md") == "v2 from agent")
        #expect(memorySyncLogText(capture).contains("changed both locally and remotely"))

        // Settled: a second flush pushes nothing more.
        await stores.flushWrites()
        #expect(sortedCalls(server.received) == sortedCalls(sent))
    }

    /// Two uploads are in flight together, and never more than the bound — a serial flush would time out waiting for
    /// the second to start.
    @Test func flushUploadsSeveralFilesAtOnceUpToTheBound() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded([:])
        await stores.setUploadConcurrency(2)
        for i in 0..<5 { try local.write("f\(i).md", "file \(i)") }

        let state = ToolsBox((inFlight: 0, peak: 0, released: false))
        fake.server.uploadHook = { _ in
            var holdFirstPair = false
            state.mutate {
                $0.inFlight += 1
                $0.peak = max($0.peak, $0.inFlight)
                holdFirstPair = $0.inFlight == 2 && !$0.released
            }
            defer { state.mutate { $0.inFlight -= 1 } }
            if holdFirstPair {
                // Hold both a little longer so a flush that ignored the bound would start a third upload meanwhile.
                try await Task.sleep(nanoseconds: 100_000_000)
                state.mutate { $0.released = true }
            }
            let start = Date()
            while !state.value.released {
                if Date().timeIntervalSince(start) > 5 { throw MemorySyncRuntimeError("timed out waiting for the second upload") }
                try await Task.sleep(nanoseconds: 1_000_000)
            }
        }
        await stores.flushWrites()

        #expect(state.value.peak == 2)
        #expect(fake.server.texts == Dictionary(uniqueKeysWithValues: (0..<5).map { ("f\($0).md", "file \($0)") }))
    }

    @Test func aFlushCutOffPartWayLogsHowManyFilesItHadNotUploaded() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded([:])
        let server = fake.server
        for name in ["a.md", "b.md", "c.md", "y.md", "z.md"] { try local.write(name, "content of \(name)") }

        let fastArrived = ToolsBox(0)
        let flushTask = ToolsBox<Task<Void, Never>?>(nil)
        func cutOffLines(_ capture: ToolDiagnostics.Capture) -> [String] {
            capture.records.map(\.message).filter { $0.contains("cut off") }
        }
        server.uploadHook = { path in
            if path == "y.md" || path == "z.md" {
                try await Task.sleep(nanoseconds: 5_000_000_000)
            } else {
                var count = 0
                fastArrived.mutate { $0 += 1; count = $0 }
                if count == 3 { flushTask.value?.cancel() }
            }
        }
        let (_, capture) = await ToolDiagnostics.capture {
            let task = Task { await stores.flushWrites() }
            flushTask.value = task
            await task.value
        }

        #expect(cutOffLines(capture) == [
            "memory flush cut off part-way; 2 of 5 changed files had not finished uploading memory_store_id=memstore_notes",
        ])
        #expect(server.texts.keys.sorted() == ["a.md", "b.md", "c.md"])

        // The three that made it are not sent again; the two that did not are. A flush that finishes in time adds no
        // cut-off line.
        server.uploadHook = nil
        let (_, again) = await ToolDiagnostics.capture { await stores.flushWrites() }
        #expect(server.texts.keys.sorted() == ["a.md", "b.md", "c.md", "y.md", "z.md"])
        #expect(server.received.map(\.path).sorted() == ["a.md", "b.md", "c.md", "y.md", "z.md"])
        #expect(cutOffLines(again).isEmpty)
    }

    /// A final sync cut off after uploading a file leaves the baseline stale; the flush sees the server already has
    /// those bytes and records that instead of reporting a conflict.
    @Test func flushAdoptsAFileTheServerAlreadyHolds() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["n.md": "v1"])
        try local.write("n.md", "v2")
        fake.server.write("n.md", "v2")

        let (_, capture) = await ToolDiagnostics.capture { await stores.flushWrites() }

        #expect(fake.server.received.isEmpty)
        #expect(!memorySyncLogText(capture).contains("changed both locally and remotely"))

        try local.write("n.md", "v3")
        await stores.flushWrites()
        #expect(fake.server.received == [updated("n.md", "v3", was: "v2")])
    }

    @Test func flushNeverPushesAReadOnlyStore() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["edit.md": "v1"], access: .readOnly)

        try local.write("edit.md", "v2 from agent")
        try local.write("new.md", "new from agent")

        await stores.flushWrites()

        #expect(fake.server.received.isEmpty)
        #expect(fake.server.texts == ["edit.md": "v1"])
    }

    @Test func flushSkipsFilesTheServerAlreadyRefused() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v1"])
        fake.server.maxContentBytes = 64

        try local.write("big.md", String(repeating: "x", count: 100))
        await memorySyncRun(stores)
        #expect(fake.server.received.filter { $0.kind == "create" }.count == 1)

        await stores.flushWrites()

        // The refused file was not retried; nothing else needed pushing.
        #expect(fake.server.received.filter { $0.kind == "create" }.count == 1)
        #expect(!fake.server.has("big.md"))
    }

    @Test func flushPushesNothingWhenTheMarkerCheckFails() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1"])

        try local.unlink(MARKER_PATH)
        try local.write("foreign.md", "someone else's notes")

        let (_, capture) = await ToolDiagnostics.capture { await stores.flushWrites() }

        #expect(fake.server.received.isEmpty)
        #expect(!fake.server.has("foreign.md"))
        // Unlike sync's recovery, the flush does not re-download the folder.
        #expect(!local.exists(MARKER_PATH))
        #expect(memorySyncLogText(capture).contains("not uploading anything from the memory store folder"))
    }

    @Test func flushNeverRaises() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["a.md": "v1"])
        try local.write("a.md", "v2 from agent")

        fake.memories.wrapList = { _ in throw MemorySyncRuntimeError("listing exploded") }
        let (_, capture) = await ToolDiagnostics.capture { await stores.flushWrites() }

        #expect(fake.server.received.isEmpty)
        #expect(memorySyncLogText(capture).contains("memory flush failed"))
    }
}
