// Port of tests/lib/tools/memory_sync/test_e2e_memory.py: memory-store sync driven end to end through the real
// `EnvironmentWorker`.
//
// Real: the worker, `SessionMemoryStores`, `FileStore`, and the filesystem. Faked: the network (the in-memory
// `MemorySyncServer`, and `EnvWorkerAPI` answering heartbeat and stop over a mock transport), the session tool-call
// stream, and the clock. So the chain worker → gate on the sessions token → download → `syncIfDue` per tool call →
// `finish` → `dispose` runs for real against a fake server; assertions read the server and the disk.
//
// Upstream patches `SessionMemoryStores.finish` / `flush_writes` / `dispose`, `AgentToolContext.__aexit__`,
// `_heartbeat_loop` and `MEMORY_FLUSH_TIMEOUT`; here the worker's internal hooks wrap the same steps. Where upstream
// shortens `MEMORY_FLUSH_TIMEOUT` and bounds the elapsed time, the teardown bound ends as soon as the pass under test
// is stuck, and a bound that did not work would hold the test until its (generous) time limit.

import Foundation
import Testing
@testable import Anthropic

/// What the session's tool-call stream does (`fake_session`'s arguments).
struct MemoryE2EScript: Sendable {
    var toolCalls: Int
    var onCall: (@Sendable (Int) throws -> Void)?
    var thenRaise: (any Error)?
}

/// `SessionMemoryStores` with some of its steps replaced (upstream's `monkeypatch.setattr(SessionMemoryStores, ...)`).
struct MemoryE2EStores: EnvironmentMemoryStores {
    let inner: SessionMemoryStores
    var finishStep: (@Sendable (SessionMemoryStores) async throws -> Void)?
    var flushStep: (@Sendable (SessionMemoryStores) async -> Void)?
    var disposeStep: (@Sendable (SessionMemoryStores) async -> Void)?

    func download(_ session: BetaManagedAgentsSession) async throws { try await inner.download(session) }
    var roots: [String] { get async { await inner.roots } }
    var readOnlyRoots: [String] { get async { await inner.readOnlyRoots } }
    func syncIfDue() async { await inner.syncIfDue() }
    func finish() async throws {
        if let finishStep { try await finishStep(inner) } else { try await inner.finish() }
    }
    func flushWrites() async {
        if let flushStep { await flushStep(inner) } else { await inner.flushWrites() }
    }
    func dispose() async {
        if let disposeStep { await disposeStep(inner) } else { await inner.dispose() }
    }
}

/// An `OSError` for a fake to raise.
struct MemoryE2EOSError: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
}

/// One claimed work item and a worker pointed at fakes (`fake_session`).
struct MemoryE2ESession {
    let worker: EnvironmentWorker
    let fake: MemorySyncFake
    let api: EnvWorkerAPI
    let retrieves: ToolsBox<[String]>
    let tmp: String
    var server: MemorySyncServer { fake.server }
    /// Where the `notes` store lands.
    var local: MemorySyncFolder { MemorySyncFolder(tmp + "/memory/notes") }

    /// Runs the worker to completion, capturing its log records.
    func run() async throws -> ToolDiagnostics.Capture {
        let worker = self.worker
        let (_, capture) = try await ToolDiagnostics.capture { try await envWithTimeout { try await worker.run() } }
        return capture
    }
}

/// The stub session `retrieve` answers: no skills, and the given resources.
func memoryE2ESessionModel(_ id: String, resources: [BetaManagedAgentsMemoryStoreResource]) throws -> BetaManagedAgentsSession {
    var session: BetaManagedAgentsSession = try envSessionJSON.decode()
    session.id = id
    session.resources = resources.map { .memoryStore($0) }
    return session
}

func memoryE2EToolCall(_ i: Int) -> DispatchedToolCall {
    DispatchedToolCall(event: ["type": "agent.tool_use", "id": .string("tu_\(i)"), "name": "noop", "input": [:]], result: nil,
                       toolUseID: "tu_\(i)", name: "noop", isError: false, posted: true, confirmation: nil)
}

/// An `EnvironmentWorker` pointed at fakes, one work item queued (`fake_session`). The item's `secret` carries `token`
/// as its sessions token; the tool-call stream is pull-driven, so each `onCall` runs right before the worker's
/// `syncIfDue` for that call.
func memoryE2ESession(_ tmp: String, token: String?, script: MemoryE2EScript, interval: TimeInterval? = 300,
                      clock: MemorySyncClock? = nil, noStores: Bool = false, syncDeletions: MemoryDeleteMode = .enabled,
                      tools: EnvironmentWorkerTools = .list([]), stores wrap: (@Sendable (SessionMemoryStores) -> MemoryE2EStores)? = nil,
                      configure: (inout EnvironmentWorkerHooks) -> Void = { _ in }) throws -> MemoryE2ESession
{
    let fake = MemorySyncFake(["note.md": "v1"], noStores: noStores)
    let api = EnvWorkerAPI()
    api.heartbeatState = "running"
    let retrieves = ToolsBox<[String]>([])
    // Encode the token the way the poll response carries it: base64url JSON.
    let secret = token.map { envEncodeSecret(["sessions_token": .string($0)]) }
    let item = envWork("w1", sessionID: "s1", secret: secret, environmentID: "e1")

    var hooks = EnvironmentWorkerHooks()
    hooks.environment = { [:] }
    hooks.workItems = { _ in
        let queue = ToolsBox([item])
        return AsyncThrowingStream { queue.value.isEmpty ? nil : queue.value.removeFirst() }
    }
    let resources = fake.resources
    hooks.retrieveSession = { _, id in
        retrieves.mutate { $0.append(id) }
        return try memoryE2ESessionModel(id, resources: resources)
    }
    let memories: any SessionMemoriesAPI = fake.memories
    var monotonic: @Sendable () -> TimeInterval = { ProcessInfo.processInfo.systemUptime }
    if let clock { monotonic = clock.function }
    let clockFunction = monotonic
    hooks.memoryStores = { (_: Anthropic, workdir: String, interval: TimeInterval, deletions: MemoryDeleteMode) throws
        -> any EnvironmentMemoryStores in
        let stores = try SessionMemoryStores(memories: memories, workdir: workdir, syncInterval: interval, syncDeletions: deletions,
                                             monotonic: clockFunction)
        if let wrap { return wrap(stores) }
        return MemoryE2EStores(inner: stores)
    }
    hooks.runSessionTools = { _ in
        let next = ToolsBox(0)
        let produce: @Sendable () async throws -> DispatchedToolCall? = {
            let i = next.value
            if i < script.toolCalls {
                next.value = i + 1
                try script.onCall?(i)
                return memoryE2EToolCall(i)
            }
            if let error = script.thenRaise { throw error }
            return nil
        }
        return AsyncThrowingStream<DispatchedToolCall, Error>(unfolding: produce)
    }
    configure(&hooks)
    let worker = try EnvironmentWorker(client: api.client(), environmentID: "e1", environmentKey: "ek", tools: tools, workdir: tmp,
                                       maxIdle: DEFAULT_MAX_IDLE, memorySyncInterval: interval, memorySyncDeletions: syncDeletions, workerID: nil,
                                       extraHeaders: nil, hooks: hooks)
    return MemoryE2ESession(worker: worker, fake: fake, api: api, retrieves: retrieves, tmp: tmp)
}

/// Waits (cancellably) until `condition` holds; a teardown bound that ends once the pass under test is stuck.
func memoryE2EWait(_ condition: @Sendable () -> Bool) async {
    while !condition() && !Task.isCancelled { try? await Task.sleep(nanoseconds: 5_000_000) }
}

/// A step that never finishes on its own; it ends only when cancelled.
func memoryE2EHang() async { try? await Task.sleep(nanoseconds: 600_000_000_000) }

func memoryE2EText(_ capture: ToolDiagnostics.Capture, loggers: [String], atLeast level: ToolDiagnostics.Level) -> String {
    capture.records.filter { loggers.contains($0.logger) && $0.level >= level }.map(\.message).joined(separator: "\n")
}

let memoryE2EWorkerLogger = "anthropic.lib.environments._worker"
let memoryE2EStoresLogger = "anthropic.lib.tools.agent_toolset"

@Suite struct MemoryE2ETests {
    @Test func workerSyncsOnCadenceFinishesAndDisposes() async throws {
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let clock = MemorySyncClock()
        let local = MemorySyncFolder(tmp + "/memory/notes")
        // The agent edits its note, then a long gap passes before the worker's `syncIfDue` poll, so every poll is due.
        let s = try memoryE2ESession(tmp, token: "tok", script: MemoryE2EScript(toolCalls: 3, onCall: { i in
            try local.write("note.md", "edit \(i)")
            clock.now += 400
        }), clock: clock)

        _ = try await s.run()

        // One session fetch, shared by the skills and memory downloads.
        #expect(s.retrieves.value == ["s1"])
        // The download landed the file before any edit; three cadence syncs pushed edits 0/1/2; the final sync had
        // nothing new.
        #expect(s.server.received == [
            memorySyncUpdated("note.md", "edit 0", was: "v1"),
            memorySyncUpdated("note.md", "edit 1", was: "edit 0"),
            memorySyncUpdated("note.md", "edit 2", was: "edit 1"),
        ])
        // Dispose removed the store dir the download created.
        #expect(!local.exists())
    }

    @Test func workerFailsTheItemWhenTheSessionsTokenIsMissing() async throws {
        // The session has memory stores attached but the item carried no sessions token, so its memories cannot be
        // mounted: the item fails before a single tool call is served. The worker keeps polling.
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let calls = ToolsBox<[Int]>([])
        let s = try memoryE2ESession(tmp, token: nil, script: MemoryE2EScript(toolCalls: 2, onCall: { i in calls.mutate { $0.append(i) } }))

        // run() completes: the item failed, the poll loop did not.
        let capture = try await s.run()

        let text = memoryE2EText(capture, loggers: [memoryE2EWorkerLogger], atLeast: .error)
        #expect(text.contains("work item failed"))
        #expect(text.contains("carried no sessions token"))
        // The session never served a tool call, and memory was never touched.
        #expect(calls.value.isEmpty)
        #expect(s.server.received.isEmpty)
        #expect(!s.local.exists())
    }

    @Test func workerSkipsMemoryWhenTheIntervalIsNil() async throws {
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let s = try memoryE2ESession(tmp, token: "tok", script: MemoryE2EScript(toolCalls: 2), interval: nil)

        let capture = try await s.run()

        // Even with a sessions token, a `nil` interval turns memory off entirely.
        #expect(s.server.received.isEmpty)
        #expect(!s.local.exists())
        // Turning memory off is a deliberate choice, so it says nothing loud.
        #expect(memorySyncLogText(capture, atLeast: .warning) == "")
    }

    @Test func workerRejectsASubFloorInterval() throws {
        let client = try EnvWorkerAPI().client()
        for interval in [4.9, 0, Double.nan] {
            do {
                _ = try EnvironmentWorker(client: client, memorySyncInterval: interval)
                Issue.record("expected a ValueError for \(interval)")
            } catch let error as ValueError {
                #expect(error.message.contains("at least"))
            }
        }
    }

    @Test func workerFailsTheItemWhenAMemoryStoreCannotBeDownloaded() async throws {
        // A folder already at the store's path is debris from a run that died. The download refuses it and the item
        // fails, rather than serving a session whose memory folder holds someone else's files. The worker keeps
        // polling: a killed worker's leftovers must not crashloop it.
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let debris = MemorySyncFolder(tmp + "/memory/notes")
        try debris.write("left-behind.md", "from a dead run")
        let s = try memoryE2ESession(tmp, token: "tok", script: MemoryE2EScript(toolCalls: 2))

        let capture = try await s.run()

        let text = memoryE2EText(capture, loggers: [memoryE2EWorkerLogger], atLeast: .error)
        #expect(text.contains("work item failed"))
        #expect(text.contains("already exists"))
        // Nothing was pushed, and the debris is exactly as it was found.
        #expect(s.server.received.isEmpty)
        #expect(debris.read("left-behind.md") == "from a dead run")
        #expect(!debris.exists("note.md"))
    }

    @Test func workerFlushesWritesWhenTheStreamRaises() async throws {
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let clock = MemorySyncClock()
        let local = MemorySyncFolder(tmp + "/memory/notes")
        let s = try memoryE2ESession(tmp, token: "tok", script: MemoryE2EScript(toolCalls: 2, onCall: { i in
            try local.write("note.md", "edit \(i)")
            // Only the first edit gets a cadence sync; the second is still on disk when the stream breaks.
            if i == 0 { clock.now += 400 }
        }, thenRaise: MemorySyncRuntimeError("stream broke")), clock: clock)

        // The item fails; the poll loop does not, and the log names the real cause.
        let capture = try await s.run()
        let text = memoryE2EText(capture, loggers: [memoryE2EWorkerLogger], atLeast: .error)
        #expect(text.contains("work item failed"))
        #expect(text.contains("stream broke"))

        // The raise skipped the final sync, but the teardown flush pushed the pending edit before dispose removed
        // the folder.
        #expect(s.server.received == [
            memorySyncUpdated("note.md", "edit 0", was: "v1"),
            memorySyncUpdated("note.md", "edit 1", was: "edit 0"),
        ])
        // Dispose still ran (shielded teardown).
        #expect(!local.exists())
    }

    @Test func workerCleanEndSyncsOnceAndTheFlushAddsNothing() async throws {
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let clock = MemorySyncClock()
        let local = MemorySyncFolder(tmp + "/memory/notes")
        let s = try memoryE2ESession(tmp, token: "tok", script: MemoryE2EScript(toolCalls: 2, onCall: { i in
            try local.write("note.md", "edit \(i)")
            if i == 0 { clock.now += 400 }
        }), clock: clock)

        let capture = try await s.run()

        // The cadence sync pushed edit 0 and the clean-end final sync pushed edit 1, exactly once each. The teardown
        // flush runs after them but finds nothing dirty.
        #expect(s.server.received == [
            memorySyncUpdated("note.md", "edit 0", was: "v1"),
            memorySyncUpdated("note.md", "edit 1", was: "edit 0"),
        ])
        // Neither teardown pass hit its time bound, so nothing says "cut off".
        #expect(!memoryE2EText(capture, loggers: [memoryE2EWorkerLogger, memoryE2EStoresLogger], atLeast: .warning).contains("cut off"))
        #expect(!local.exists())
    }

    @Test func workerFlushesAfterACleanFinalSyncThatFailed() async throws {
        // The syncs swallow their own failures, so a clean end whose final sync broke would silently lose the last
        // edits: the teardown flush is their second chance.
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let local = MemorySyncFolder(tmp + "/memory/notes")
        let s = try memoryE2ESession(tmp, token: "tok", script: MemoryE2EScript(toolCalls: 1, onCall: { _ in
            try local.write("note.md", "last edit")
        }), stores: { inner in
            // A store-level failure inside the last sync: logged, nothing pushed.
            MemoryE2EStores(inner: inner, finishStep: { _ in })
        })

        _ = try await s.run()

        #expect(s.server.texts["note.md"] == "last edit")
        #expect(!local.exists())
    }

    @Test func workerFlushIsBoundedAndTeardownStillRuns() async throws {
        // A flush that hangs is cut off at its bound and says so; dispose still runs.
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let local = MemorySyncFolder(tmp + "/memory/notes")
        let flushStarted = ToolsBox(false)
        let s = try memoryE2ESession(tmp, token: "tok", script: MemoryE2EScript(toolCalls: 1, onCall: { i in
            try local.write("note.md", "edit \(i)")
        }, thenRaise: MemorySyncRuntimeError("stream broke")), stores: { inner in
            MemoryE2EStores(inner: inner, flushStep: { _ in
                flushStarted.value = true
                await memoryE2EHang()
            })
        }, configure: { hooks in
            hooks.memoryTeardownBound = { _ in await memoryE2EWait { flushStarted.value } }
        })

        // Without the bound the hung flush would hold the teardown until the test's time limit.
        let capture = try await s.run()

        #expect(flushStarted.value)
        #expect(memoryE2EText(capture, loggers: [memoryE2EWorkerLogger], atLeast: .warning).contains("memory flush cut off after"))
        #expect(!local.exists())
    }

    @Test func workerFinalSyncIsBoundedAndTheFlushStillRuns() async throws {
        // A final sync that hangs is cut off at its bound and says so; the flush after it still uploads the last edit.
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let local = MemorySyncFolder(tmp + "/memory/notes")
        let finishStarted = ToolsBox(false)
        let s = try memoryE2ESession(tmp, token: "tok", script: MemoryE2EScript(toolCalls: 1, onCall: { _ in
            try local.write("note.md", "last edit")
        }), stores: { inner in
            MemoryE2EStores(inner: inner, finishStep: { _ in
                finishStarted.value = true
                await memoryE2EHang()
            })
        }, configure: { hooks in
            hooks.memoryTeardownBound = { pass in
                switch pass {
                case .finish: await memoryE2EWait { finishStarted.value }
                // The real flush that follows must finish inside its bound, even on a loaded machine.
                case .flush: try? await Task.sleep(nanoseconds: 60_000_000_000)
                }
            }
        })

        let capture = try await s.run()

        let text = memoryE2EText(capture, loggers: [memoryE2EWorkerLogger], atLeast: .warning)
        #expect(text.contains("final memory sync cut off after"))
        // The flush finished in time, so only the final sync reports a cut-off.
        #expect(!text.contains("memory flush cut off after"))
        #expect(s.server.texts["note.md"] == "last edit")
        #expect(!local.exists())
    }

    @Test func workerLogsWhatACutOffFlushLeftBehind() async throws {
        // One upload never completes: the flush is cut off, the store logs that one of its two changed files did not
        // make it, and the other one did.
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let local = MemorySyncFolder(tmp + "/memory/notes")
        let stuckParked = ToolsBox(false)
        let serverRef = ToolsBox<MemorySyncServer?>(nil)
        let s = try memoryE2ESession(tmp, token: "tok", script: MemoryE2EScript(toolCalls: 1, onCall: { _ in
            try local.write("kept.md", "saved")
            try local.write("stuck.md", "only copy")
        }, thenRaise: MemorySyncRuntimeError("stream broke")), configure: { hooks in
            // The bound ends once `kept.md` has landed and `stuck.md` is parked.
            hooks.memoryTeardownBound = { _ in await memoryE2EWait { stuckParked.value && serverRef.value?.has("kept.md") == true } }
        })
        serverRef.value = s.server
        s.server.uploadHook = { path in
            if path == "stuck.md" {
                stuckParked.value = true
                await memoryE2EHang()
                try Task.checkCancellation()
            }
        }

        let capture = try await s.run()
        let server = s.server

        #expect(server.texts["kept.md"] == "saved")
        #expect(!server.has("stuck.md"))
        let text = memoryE2EText(capture, loggers: [memoryE2EWorkerLogger, memoryE2EStoresLogger], atLeast: .warning)
        #expect(text.contains("1 of 2 changed files had not finished uploading memory_store_id=memstore_notes"))
        #expect(text.contains("memory flush cut off after"))
        #expect(!local.exists())
    }

    @Test func workerStaysQuietWhenNoMemoryStoreIsAttached() async throws {
        // Most sessions have no memory at all. A missing sessions token only matters when there is memory the session
        // cannot reach.
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let s = try memoryE2ESession(tmp, token: nil, script: MemoryE2EScript(toolCalls: 2), noStores: true)

        let capture = try await s.run()

        #expect(s.server.received.isEmpty)
        #expect(!s.local.exists())
        #expect(memorySyncLogText(capture, atLeast: .warning) == "")
    }

    @Test func workerCanTurnSyncDeletionsOff() async throws {
        // `.disabled` reaches the stores: a local deletion never propagates however many syncs run, while uploads
        // still do.
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let clock = MemorySyncClock()
        let local = MemorySyncFolder(tmp + "/memory/notes")
        let s = try memoryE2ESession(tmp, token: "tok", script: MemoryE2EScript(toolCalls: 3, onCall: { i in
            if i == 0 {
                try local.unlink("note.md")
                try local.write("new.md", "survives")
            }
            // Every gap dwarfs both the sync interval and the corroboration window.
            clock.now += 400
        }), clock: clock, syncDeletions: .disabled)

        _ = try await s.run()

        #expect(s.server.texts["note.md"] == "v1")
        #expect(s.server.received == [memorySyncCreated("new.md", "survives")])
    }

    @Test func workerFlushesAndDisposesEvenWhenEnvTeardownRaises() async throws {
        // A context teardown that throws must not skip the flush or leave the folder behind for the next work item.
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let local = MemorySyncFolder(tmp + "/memory/notes")
        let s = try memoryE2ESession(tmp, token: "tok", script: MemoryE2EScript(toolCalls: 1, onCall: { _ in
            try local.write("note.md", "edit before burp")
        }, thenRaise: MemorySyncRuntimeError("stream died")), configure: { hooks in
            let real = hooks.exitContext
            hooks.exitContext = { context in
                try await real(context)
                throw MemoryE2EOSError(message: "teardown burp")
            }
        })

        _ = try await s.run()

        #expect(s.server.texts["note.md"] == "edit before burp")
        #expect(!local.exists())
    }

    @Test func theLastSyncRunsAfterTheBashSubprocessesAreKilled() async throws {
        // `finish()` skips the delete waiting window, so it must only run once nothing can still be rewriting files:
        // after the context teardown kills the session's processes.
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let local = MemorySyncFolder(tmp + "/memory/notes")
        let order = ToolsBox<[String]>([])
        let s = try memoryE2ESession(tmp, token: "tok", script: MemoryE2EScript(toolCalls: 1, onCall: { _ in
            try local.write("note.md", "last edit")
        }), stores: { inner in
            MemoryE2EStores(inner: inner, finishStep: { stores in
                order.mutate { $0.append("finish") }
                try await stores.finish()
            })
        }, configure: { hooks in
            let real = hooks.exitContext
            hooks.exitContext = { context in
                order.mutate { $0.append("env_teardown") }
                try await real(context)
            }
        })

        _ = try await s.run()

        #expect(order.value == ["env_teardown", "finish"])
        #expect(s.server.texts["note.md"] == "last edit")
        #expect(!local.exists())
    }

    @Test func theLeaseIsHeartbeatedUntilTheMemoryTeardownIsDone() async throws {
        // The lease must not lapse while the final sync, flush and dispose still hold the folder.
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let order = ToolsBox<[String]>([])
        let s = try memoryE2ESession(tmp, token: "tok", script: MemoryE2EScript(toolCalls: 1), stores: { inner in
            MemoryE2EStores(inner: inner, disposeStep: { stores in
                await stores.dispose()
                order.mutate { $0.append("folder removed") }
            })
        }, configure: { hooks in
            hooks.heartbeatLoop = { beat in
                await beat()
                order.mutate { $0.append("heartbeat stopped") }
            }
        })

        _ = try await s.run()

        #expect(order.value == ["folder removed", "heartbeat stopped"])
    }

    @Test func workerGrantsFileToolsAccessToStoreFolders() async throws {
        // The context handed to the tools factory carries the downloaded store folders as allowed roots, so the file
        // tools can reach a memory mounted outside the working directory.
        let tmp = try memorySyncTempDir()
        defer { try? FileManager.default.removeItem(atPath: tmp) }
        let contexts = ToolsBox<[AgentToolContext]>([])
        let s = try memoryE2ESession(tmp, token: "tok", script: MemoryE2EScript(toolCalls: 1), tools: .factory { context in
            contexts.mutate { $0.append(context) }
            return []
        })

        _ = try await s.run()

        let captured = contexts.value
        #expect(captured.count == 1)
        let context = try #require(captured.first)
        #expect(context.allowedRoots == [s.local.path])
        #expect(context.readOnlyRoots.isEmpty)
    }
}
