// Port of `anthropic/lib/environments/_worker.py` (`EnvironmentWorker`, `EnvironmentWorkerTools`) and the
// hand-written `AsyncWork.worker(...)` of `resources/beta/environments/work.py`: the self-hosted environment
// worker, the composition of the control-plane poller, the per-session `AgentToolContext` (skills download), the
// session's memory-store sync (`SessionMemoryStores`) and the per-session tool runner.

import Foundation

let workerLog = ToolLogger(name: "anthropic.lib.environments._worker")

let HEARTBEAT_DEFAULT: Double = 30
/// Assumed lease TTL before the server's first heartbeat response tells the real value.
let HEARTBEAT_TTL_DEFAULT: Double = 90
let NO_HEARTBEAT_SENTINEL = "NO_HEARTBEAT"

/// The tools a worker exposes to each claimed session (`EnvironmentWorkerTools`): a fixed list, or a factory
/// called once per session with that session's `AgentToolContext`. Use the factory to bind
/// `betaAgentToolset20260401` (or any tool that needs the workdir or the session) to the right session.
public enum EnvironmentWorkerTools: Sendable {
    case list([any BetaRunnableTool])
    case factory(@Sendable (AgentToolContext) throws -> [any BetaRunnableTool])
}

/// Why heartbeating of a work item ended (`_LeaseEndReason`).
enum LeaseEndReason: String, Sendable {
    /// The session run ended first; the lease was held throughout.
    case runnerDone = "runner_done"
    /// State `stopping` / `stopped`, or `lease_extended` false.
    case controlPlaneStop = "control_plane_stop"
    /// A heartbeat met 412: the item was re-queued or another worker holds it.
    case leaseLost = "lease_lost"
    /// A heartbeat met another 4xx that retrying will not fix.
    case heartbeatRejected = "heartbeat_rejected"
    /// No heartbeat succeeded for a full lease TTL.
    case assumedLost = "assumed_lost"
}

/// This worker's view of one work-item lease: whether it has ended, and why (`_Lease`). The first recorded reason
/// wins, so a run cancelled because the lease was lost still reads as lost afterwards.
final class EnvironmentLease: @unchecked Sendable {
    private let lock = NSLock()
    private var reason: LeaseEndReason?
    private var isEnded = false
    private var waiters: [UUID: CheckedContinuation<Void, Never>] = [:]

    var endReason: LeaseEndReason? { lock.withLock { reason } }
    var ended: Bool { lock.withLock { isEnded } }

    func finish(_ reason: LeaseEndReason) {
        let waiting: [CheckedContinuation<Void, Never>] = lock.withLock {
            if self.reason == nil { self.reason = reason }
            isEnded = true
            let w = Array(waiters.values)
            waiters = [:]
            return w
        }
        for w in waiting { w.resume() }
    }

    /// True once the item belongs to the queue or another worker, so this one must not stop it.
    var lost: Bool { [.leaseLost, .assumedLost].contains(endReason) }

    /// False once a heartbeat failed for good, so the worker stops before it has finished with the item.
    var kept: Bool { !lost && endReason != .heartbeatRejected }

    /// Wait until the lease ends, or `timeout` seconds pass, or the task is cancelled.
    func waitEnded(timeout: Double) async {
        let id = UUID()
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await withTaskCancellationHandler {
                    await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
                        let resumeNow: Bool = self.lock.withLock {
                            if self.isEnded || Task.isCancelled { return true }
                            self.waiters[id] = c
                            return false
                        }
                        if resumeNow { c.resume() }
                    }
                } onCancel: {
                    let c = self.lock.withLock { self.waiters.removeValue(forKey: id) }
                    c?.resume()
                }
            }
            group.addTask { try? await Task.sleep(nanoseconds: UInt64(max(0, timeout) * 1_000_000_000)) }
            await group.next()
            group.cancelAll()
        }
    }
}

/// The heartbeat loop's clock and intervals, replaceable in tests.
struct HeartbeatTimings: Sendable {
    var defaultInterval: Double = HEARTBEAT_DEFAULT
    var ttlDefault: Double = HEARTBEAT_TTL_DEFAULT
    var now: @Sendable () -> Double = { ProcessInfo.processInfo.systemUptime }
}

/// The server's view of the lease carried by a 412 heartbeat response, or empty if absent.
func serverLeaseState(_ error: APIStatusError) -> [String: JSONValue] {
    error.body?["error"]?["details"]?["current_state"]?.objectValue ?? [:]
}

/// Python's `str()` of a JSON value read from a response.
private func pyValue(_ value: JSONValue?) -> String {
    switch value {
    case nil, .null?: return "None"
    case .string(let s)?: return s
    case .bool(let b)?: return b ? "True" : "False"
    case let v?: return v.description
    }
}

/// Keep the work-item lease alive while a session is served (`_heartbeat_loop`).
///
/// Returns once `lease` has ended, and ends it itself when the control plane reports the work is `stopping` /
/// `stopped` or no longer extends the lease, when a heartbeat is rejected (a 412 means the lease belongs to someone
/// else), or when transient failures have run long enough that the lease must be assumed lost. `onLeaseTTL` is
/// called with the server-reported TTL after every successful beat.
func heartbeatLoop(_ work: any EnvironmentWorkAPI, workID: String, environmentID: String, lease: EnvironmentLease,
                   extraHeaders: Headers? = nil, timings: HeartbeatTimings = HeartbeatTimings(),
                   onLeaseTTL: (@Sendable (Double) -> Void)? = nil) async
{
    var interval = timings.defaultInterval
    var ttl = timings.ttlDefault
    var last = NO_HEARTBEAT_SENTINEL
    var lastSuccess = timings.now()
    while !lease.ended && !Task.isCancelled {
        do {
            // Bound each heartbeat: a network blackhole must not leave the loop waiting for the client's default
            // timeout while the lease TTL expires.
            let expected = last
            let response = try await withHeartbeatTimeout(interval) {
                try await work.heartbeat(workID, environmentID: environmentID, expectedLastHeartbeat: expected, extraHeaders: extraHeaders)
            }
            last = response.lastHeartbeat
            lastSuccess = timings.now()
            if response.ttlSeconds > 0 {
                ttl = Double(response.ttlSeconds)
                interval = max(1, min(ttl / 2, timings.defaultInterval))
                onLeaseTTL?(ttl)
            }
            if response.state == .stopping || response.state == .stopped || !response.leaseExtended {
                workerLog.info("heartbeat signals shutdown state=\(response.state.rawValue) lease_extended=\(response.leaseExtended ? "True" : "False")")
                lease.finish(.controlPlaneStop)
                return
            }
        } catch let error where HelperRetry.isTransient(error) || error is ToolTimedOut {
            if let e = error as? APIStatusError, e.statusCode == 412 {
                let server = serverLeaseState(e)
                workerLog.error(
                    "lease lost: heartbeat precondition failed work_id=\(workID) server_state=\(pyValue(server["state"])) "
                        + "server_ttl_seconds=\(pyValue(server["ttl_seconds"])) server_last_heartbeat=\(pyValue(server["last_heartbeat"]))")
                lease.finish(.leaseLost)
                return
            }
            if HelperRetry.isFatalStatusError(error) {
                workerLog.error("permanent heartbeat failure error=\(helperErrorString(error))")
                lease.finish(.heartbeatRejected)
                return
            }
            // A transient failure: retrying forever risks two workers serving the item once the lease expires.
            if timings.now() - lastSuccess > ttl {
                workerLog.error("lease assumed lost: no successful heartbeat in \(String(format: "%.0f", ttl))s error=\(helperErrorString(error))")
                lease.finish(.assumedLost)
                return
            }
            workerLog.warning("transient heartbeat failure error=\(error is ToolTimedOut ? "" : helperErrorString(error))")
        } catch {
            // Cancellation, or a real bug: stop beating.
            return
        }
        await lease.waitEnded(timeout: interval)
    }
}

/// Runs `body`, throwing `ToolTimedOut` once `seconds` pass (`anyio.fail_after`). Unlike `withToolTimeout`, the body is
/// a child task, so cancelling the heartbeat loop cancels a heartbeat in flight.
func withHeartbeatTimeout<T: Sendable>(_ seconds: Double, _ body: @escaping @Sendable () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T?.self) { group in
        group.addTask { try await body() }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(max(0, seconds) * 1_000_000_000))
            return nil
        }
        defer { group.cancelAll() }
        guard let first = try await group.next(), let value = first else { throw ToolTimedOut() }
        return value
    }
}

/// Extract the per-item sessions token from a work item's `secret` payload (`_sessions_token_from_secret`): a
/// URL-safe base64 JSON payload, possibly without padding. `nil` when the payload is missing, doesn't decode, or
/// carries no token. Never log the payload or anything extracted from it.
func sessionsTokenFromSecret(_ secret: String?) -> String? {
    guard let secret, !secret.isEmpty else { return nil }
    var base64 = secret.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
    base64 += String(repeating: "=", count: (4 - base64.count % 4) % 4)
    guard let data = Data(base64Encoded: base64), let parsed = try? JSONValue.parse(data),
          case .string(let token)? = parsed.objectValue?["sessions_token"], !token.isEmpty
    else { return nil }
    return token
}

/// The parts of a claimed work item the per-item flow reads.
struct EnvironmentWorkItem: Sendable {
    var id: String
    var environmentID: String
    var secret: String?
    var type: String
    var sessionID: String

    init(id: String, environmentID: String, secret: String?, type: String, sessionID: String) {
        self.id = id
        self.environmentID = environmentID
        self.secret = secret
        self.type = type
        self.sessionID = sessionID
    }

    init(_ work: BetaSelfHostedWork) {
        self.init(id: work.id, environmentID: work.environmentID, secret: work.secret, type: work.data.type, sessionID: work.data.id)
    }
}

/// What the worker hands the session tool runner for one session (`_run_session_tools`' arguments).
struct EnvironmentSessionRun: Sendable {
    var client: Anthropic
    var sessionID: String
    var tools: [any BetaRunnableTool]
    var maxIdle: TimeInterval?
    /// The runner's Bearer credential.
    var environmentKey: String
    var extraHeaders: Headers?
    var sendRetryWindow: @Sendable () -> TimeInterval?
}

/// The worker's collaborators, replaceable in tests.
struct EnvironmentWorkerHooks: Sendable {
    var scopedClient: @Sendable (Anthropic, String, StainlessHelper) throws -> Anthropic = { client, token, helper in
        try ScopedClient.copyWithBearerAuth(client, authToken: token, helper: helper)
    }
    var workAPI: @Sendable (Anthropic) -> any EnvironmentWorkAPI = { ResourceEnvironmentWork(resource: $0.beta.environments.work) }
    /// The items `run()` serves; the poller's by default.
    var workItems: (@Sendable (EnvironmentWorkPoller) -> AsyncThrowingStream<BetaSelfHostedWork, Error>)?
    var retrieveSession: @Sendable (Anthropic, String) async throws -> BetaManagedAgentsSession = { client, id in
        try await client.beta.sessions.retrieve(id)
    }
    var runSessionTools: @Sendable (EnvironmentSessionRun) throws -> AsyncThrowingStream<DispatchedToolCall, Error> = { run in
        let scoped = try sessionScopedClient(run.client, environmentKey: run.environmentKey)
        return SessionToolRunner(
            events: ResourceSessionEvents(resource: scoped.beta.sessions.events), sessionID: run.sessionID, tools: run.tools,
            maxIdle: run.maxIdle, extraHeaders: run.extraHeaders, timings: SessionRunnerTimings(),
            sendRetryWindow: run.sendRetryWindow, spanClient: scoped, conversationEvents: sessionConversationEvents(scoped, bearer: true)
        ).run()
    }
    var heartbeat = HeartbeatTimings()
    /// Runs the lease heartbeat loop of an item (`_heartbeat_loop`); a test can wrap it.
    var heartbeatLoop: (@Sendable (_ beat: @Sendable () async -> Void) async -> Void)?
    var environment: @Sendable () -> [String: String] = { ProcessInfo.processInfo.environment }
    /// `AgentToolContext.__aenter__` / `__aexit__`.
    var enterContext: @Sendable (AgentToolContext) async throws -> Void = { try await $0.setupSkills() }
    var exitContext: @Sendable (AgentToolContext) async throws -> Void = { await $0.exit() }
    /// The memory stores of an item: (the item's token-scoped client, workdir, sync interval, delete mode).
    var memoryStores: @Sendable (Anthropic, String, TimeInterval, MemoryDeleteMode) throws -> any EnvironmentMemoryStores = {
        client, workdir, interval, deletions in
        try SessionMemoryStores(client, workdir: workdir, syncInterval: interval, syncDeletions: deletions)
    }
    /// The bound of each memory teardown pass, as the warnings report it (`MEMORY_FLUSH_TIMEOUT`).
    var memoryFlushTimeout: TimeInterval = MEMORY_FLUSH_TIMEOUT
    /// Waits out the bound of one memory teardown pass; by default sleeps `memoryFlushTimeout`. It must return
    /// when cancelled (the pass finished first).
    var memoryTeardownBound: (@Sendable (MemoryTeardownPass) async -> Void)?
}

/// The two bounded memory passes of an item's teardown.
enum MemoryTeardownPass: Sendable {
    /// The clean end's last full sync (`finish`).
    case finish
    /// The push-only flush (`flush_writes`).
    case flush
}

/// What the worker drives of `SessionMemoryStores`; a test can wrap one.
protocol EnvironmentMemoryStores: Sendable {
    func download(_ session: BetaManagedAgentsSession) async throws
    var roots: [String] { get async }
    var readOnlyRoots: [String] { get async }
    func syncIfDue() async
    func finish() async throws
    func flushWrites() async
    func dispose() async
}

extension SessionMemoryStores: EnvironmentMemoryStores {}

/// True when the session has at least one memory store attached (`_has_memory_store`).
func sessionHasMemoryStore(_ session: BetaManagedAgentsSession) -> Bool {
    session.resources.contains { if case .memoryStore = $0 { return true } else { return false } }
}

/// Python's `%g` of a bound in seconds.
private func pyG(_ value: Double) -> String { String(format: "%g", value) }

private final class EnvLeaseTTLBox: @unchecked Sendable {
    private let lock = NSLock()
    private var ttl: Double?
    var value: Double? {
        get { lock.withLock { ttl } }
        set { lock.withLock { ttl = newValue } }
    }
}

/// Run a self-hosted environment worker (`EnvironmentWorker`).
///
/// For each claimed `session` work item the worker builds the per-session `AgentToolContext` and downloads the
/// session agent's skills and the session's memory stores, then runs a `SessionToolRunner` for the session *while*
/// heartbeating the work-item lease; on exit it syncs the memory stores back, force-stops the work item (unless the
/// lease was lost, in which case the item is left to whoever holds it now) and goes on to the next one.
///
/// The `environmentKey` is the worker's standing credential: polling always uses it, and per-session calls fall back
/// to it when a work item's `secret` yields no sessions token. Every request rides a Bearer-only scoped sub-client,
/// never the parent client's API key.
///
/// ```swift
/// // Long-running daemon: poll for work, serve each session, loop. Cancel the task to stop it.
/// try await client.beta.environments.work.worker(environmentID: id, environmentKey: key, workdir: "/workspace").run()
///
/// // Already-claimed item (e.g. inside `ant worker poll --on-work ...`):
/// try await client.beta.environments.work.worker(workdir: "/workspace").handleItem()
/// ```
public final class EnvironmentWorker: Sendable {
    public let client: Anthropic
    public let environmentID: String?
    public let environmentKey: String?
    public let tools: EnvironmentWorkerTools?
    public let workdir: String
    public let maxFileBytes: Int??
    public let maxIdle: TimeInterval?
    public let memorySyncInterval: TimeInterval?
    public let memorySyncDeletions: MemoryDeleteMode
    public let workerID: String?
    public let extraHeaders: Headers?
    let hooks: EnvironmentWorkerHooks

    /// - Parameters:
    ///   - environmentID: The self-hosted environment to poll. Required by `run()`; not used by `handleItem()`.
    ///   - environmentKey: The environment key: the Bearer credential of the control-plane and session calls, except
    ///     where a claimed item's own `secret` takes precedence. Required by `run()`.
    ///   - tools: The tools of each claimed session: a list, or a factory called with each session's
    ///     `AgentToolContext`. Defaults to `betaAgentToolset20260401(context)` (the standard `agent_toolset_20260401`
    ///     set bound to the session's context).
    ///   - workdir: Base directory of each session's `AgentToolContext`. Defaults to the current directory when the
    ///     worker is built.
    ///   - unrestrictedPaths: Deprecated and no longer accepted: passing it at all throws (see `AgentToolContext`).
    ///   - maxFileBytes: The `maxFileBytes` of each session's `AgentToolContext`.
    ///   - maxIdle: Seconds the session tool runner keeps running after the session goes idle with any
    ///     `stop_reason` but `requires_action`. `nil` disables it.
    ///   - memorySyncInterval: How often (seconds) the session's attached memory stores are synced back while it
    ///     runs — checked after each dispatched tool call, plus one final sync when the session ends cleanly. At
    ///     least `MIN_MEMORY_SYNC_INTERVAL` (a lower value throws `ValueError`). A session that ends on an error or
    ///     cancel gets a push-only flush instead, bounded by `MEMORY_FLUSH_TIMEOUT` like the final sync. `nil`
    ///     disables memory download and sync entirely. Memory stores are only touched for work items whose `secret`
    ///     carries a `sessions_token`; while sync is enabled, an item without one fails when its session has memory
    ///     stores attached, because those stores cannot be mounted without the token.
    ///   - memorySyncDeletions: Whether a file deleted locally in a memory store's folder may delete its server
    ///     memory. `.logOnly` runs the same checks and only logs; `.disabled` never deletes.
    ///   - workerID: Sent on each poll. Defaults to a unique, hostname-prefixed id.
    ///   - extraHeaders: Headers passed through on every request the worker makes (poll / ack / stop / heartbeat and
    ///     the session tool runner's requests). Use them for passthrough such as trace ids, not for auth.
    public convenience init(client: Anthropic, environmentID: String? = nil, environmentKey: String? = nil,
                            tools: EnvironmentWorkerTools? = nil, workdir: String? = nil, unrestrictedPaths: Bool? = nil,
                            maxFileBytes: Int?? = nil, maxIdle: TimeInterval? = DEFAULT_MAX_IDLE,
                            memorySyncInterval: TimeInterval? = DEFAULT_MEMORY_SYNC_INTERVAL,
                            memorySyncDeletions: MemoryDeleteMode = .enabled, workerID: String? = nil,
                            extraHeaders: Headers? = nil) throws
    {
        try self.init(client: client, environmentID: environmentID, environmentKey: environmentKey, tools: tools, workdir: workdir,
                      unrestrictedPaths: unrestrictedPaths, maxFileBytes: maxFileBytes, maxIdle: maxIdle,
                      memorySyncInterval: memorySyncInterval, memorySyncDeletions: memorySyncDeletions, workerID: workerID,
                      extraHeaders: extraHeaders, hooks: EnvironmentWorkerHooks())
    }

    init(client: Anthropic, environmentID: String?, environmentKey: String?, tools: EnvironmentWorkerTools?, workdir: String?,
         unrestrictedPaths: Bool? = nil, maxFileBytes: Int?? = nil, maxIdle: TimeInterval?,
         memorySyncInterval: TimeInterval? = DEFAULT_MEMORY_SYNC_INTERVAL, memorySyncDeletions: MemoryDeleteMode = .enabled,
         workerID: String?, extraHeaders: Headers?, hooks: EnvironmentWorkerHooks) throws
    {
        if unrestrictedPaths != nil { throw ArgumentTypeError(UNRESTRICTED_PATHS_DEPRECATION) }
        if let memorySyncInterval { try checkSyncInterval(memorySyncInterval) }
        self.client = client
        self.environmentID = environmentID
        self.environmentKey = environmentKey
        self.tools = tools
        // The cwd is taken now, so a `chdir` before a session is served does not move where tools resolve paths.
        self.workdir = workdir ?? FileManager.default.currentDirectoryPath
        self.maxFileBytes = maxFileBytes
        self.maxIdle = maxIdle
        self.memorySyncInterval = memorySyncInterval
        self.memorySyncDeletions = memorySyncDeletions
        self.workerID = workerID
        self.extraHeaders = extraHeaders
        self.hooks = hooks
    }

    func toolsFor(_ context: AgentToolContext) throws -> [any BetaRunnableTool] {
        switch tools {
        case .list(let tools)?: return tools
        case .factory(let factory)?: return try factory(context)
        case nil: return betaAgentToolset20260401(context)
        }
    }

    /// Poll the environment and serve each claimed session until cancelled. One item that fails is logged and
    /// skipped; cancellation ends the loop.
    ///
    /// Each work item has the poller's OpenTelemetry span, `anthropic.environment.work`, when the client has spans. It
    /// is the current span while the item is handled, so the spans of the worker's requests and tools for the item are
    /// its children. `handleItem()` has no such span.
    public func run() async throws {
        guard let environmentID, let environmentKey else {
            throw ValueError("EnvironmentWorker.run: environment_id and environment_key are required to poll for work")
        }
        // Poll / ack / stop go through a Bearer-only sub-client tagged with the poller's helper telemetry; each
        // item builds its own `environments-worker` sub-client for the heartbeat and force-stop.
        let pollClient = try hooks.scopedClient(client, environmentKey, .environmentsWorkPoller)
        // The poller starts the span of each item; the worker handles the item with it current, and ends it first.
        let workSpan = WorkSpan()
        let poller = EnvironmentWorkPoller(work: hooks.workAPI(pollClient), environmentID: environmentID, workerID: workerID,
                                           blockMs: POLL_BLOCK_MS, reclaimOlderThanMs: nil, drain: false, autoStop: false,
                                           extraHeaders: extraHeaders, hooks: EnvironmentPollerHooks(), workSpan: workSpan)
        let items = hooks.workItems?(poller) ?? AsyncThrowingStream { try await poller.next() }
        for try await item in items {
            let lease = EnvironmentLease()
            do {
                try await asCurrentSpan(workSpan.span) {
                    try await serve(EnvironmentWorkItem(item), environmentKey: environmentKey, lease: lease)
                }
                workSpan.end(finished: lease.kept)
            } catch {
                if error is CancellationError || Task.isCancelled {
                    workSpan.end(error: CancellationError())
                    throw error
                }
                // An error after the lease is gone is a side effect of losing it, not a failed item.
                workSpan.end(error: lease.kept ? error : nil, finished: lease.kept)
                // One bad item fails that item, not the worker: the teardown already stopped or released it.
                workerLog.error("work item failed work_id=\(item.id) error=\(helperErrorString(error))")
            }
        }
    }

    /// Serve a single, already-claimed work item without the poll loop (`handle_item`).
    ///
    /// `workID` / `environmentID` / `sessionID` fall back to `ANTHROPIC_WORK_ID` / `ANTHROPIC_ENVIRONMENT_ID` /
    /// `ANTHROPIC_SESSION_ID`; `environmentKey` to this worker's own key, then `ANTHROPIC_ENVIRONMENT_KEY`; and
    /// `workSecret` (the item's per-item `secret`) to `ANTHROPIC_WORK_SECRET`. The sessions token of the secret is
    /// preferred as the item's credential; the environment key is required only when there is no secret.
    public func handleItem(workID: String? = nil, environmentID: String? = nil, sessionID: String? = nil,
                           environmentKey: String? = nil, workSecret: String? = nil) async throws
    {
        let env = hooks.environment()
        func require(_ value: String?, _ name: String, _ variable: String) throws -> String {
            if let value, !value.isEmpty { return value }
            if let value = env[variable], !value.isEmpty { return value }
            throw ValueError("handle_item: \(name) is required — pass it or set \(variable)")
        }
        let workID = try require(workID, "work_id", "ANTHROPIC_WORK_ID")
        let environmentID = try require(environmentID, "environment_id", "ANTHROPIC_ENVIRONMENT_ID")
        let sessionID = try require(sessionID, "session_id", "ANTHROPIC_SESSION_ID")
        let secret = [workSecret, env["ANTHROPIC_WORK_SECRET"]].compactMap { $0 }.first { !$0.isEmpty }
        let key = [environmentKey, self.environmentKey, env["ANTHROPIC_ENVIRONMENT_KEY"]].compactMap { $0 }.first { !$0.isEmpty }
        if key == nil && secret == nil {
            throw ValueError("handle_item: environment_key is required — pass it or set ANTHROPIC_ENVIRONMENT_KEY")
        }
        try await serve(EnvironmentWorkItem(id: workID, environmentID: environmentID, secret: secret, type: "session", sessionID: sessionID),
                        environmentKey: key, lease: EnvironmentLease())
    }

    /// The per-item body shared by `run()` and `handleItem()` (`_handle_item`).
    func serve(_ item: EnvironmentWorkItem, environmentKey: String?, lease: EnvironmentLease) async throws {
        // The per-item credential: the sessions token inside the item's secret when the server issued one,
        // otherwise the environment key. Never log it.
        let sessionsToken = sessionsTokenFromSecret(item.secret)
        guard let credential = sessionsToken ?? environmentKey else {
            throw ValueError(
                "the work item's secret payload yielded no sessions token and no environment key is available; provide a secret "
                    + "whose payload carries a sessions_token, or an environment key (pass one or set ANTHROPIC_ENVIRONMENT_KEY) "
                    + "work_id=\(item.id)")
        }
        if let secret = item.secret, !secret.isEmpty, sessionsToken == nil {
            workerLog.warning(
                "work item carried a secret payload but no sessions token could be extracted; falling back to the environment key work_id=\(item.id)")
        }
        let workerClient = try hooks.scopedClient(client, credential, .environmentsWorker)
        let work = hooks.workAPI(workerClient)
        // The memory endpoints accept the per-item sessions token but reject the environment key, so download and
        // sync only run when the item carried a usable secret (and the interval is set). `workerClient` is scoped to
        // that token then, so the memory calls ride it too.
        var stores: (any EnvironmentMemoryStores)?
        if sessionsToken != nil, let interval = memorySyncInterval {
            stores = try hooks.memoryStores(workerClient, workdir, interval, memorySyncDeletions)
        } else {
            workerLog.debug("memory stores disabled for this item work_id=\(item.id)")
        }
        do {
            try await serveSession(item, credential: credential, workerClient: workerClient, work: work, stores: stores, lease: lease)
        } catch {
            await stopOnExit(item, work: work, lease: lease)
            throw error
        }
        await stopOnExit(item, work: work, lease: lease)
    }

    /// Stop only an item this worker still holds: after a lost lease it belongs to the queue or another worker.
    private func stopOnExit(_ item: EnvironmentWorkItem, work: any EnvironmentWorkAPI, lease: EnvironmentLease) async {
        if lease.lost {
            workerLog.info("lease lost; released work_id=\(item.id) session_id=\(item.sessionID) without stopping it")
            return
        }
        // Not a child of the caller, so the stop survives a cancelled run (upstream shields it).
        let extraHeaders = self.extraHeaders
        await Task {
            do {
                try await work.stop(item.id, environmentID: item.environmentID, force: true, extraHeaders: extraHeaders)
            } catch {
                if !isStatus(error, 409) {
                    workerLog.error("force-stop on exit failed work_id=\(item.id) error=\(helperErrorString(error))")
                }
            }
        }.value
    }

    private func serveSession(_ item: EnvironmentWorkItem, credential: String, workerClient: Anthropic,
                              work: any EnvironmentWorkAPI, stores: (any EnvironmentMemoryStores)?, lease: EnvironmentLease) async throws
    {
        // The queue also sends "healthcheck" items, which the generated type does not model.
        if item.type != "session" {
            workerLog.debug("skipping non-session work item work_id=\(item.id) type=\(item.type)")
            return
        }
        let leaseTTL = EnvLeaseTTLBox()
        let timings = hooks.heartbeat
        let extraHeaders = self.extraHeaders
        let wrapHeartbeat = hooks.heartbeatLoop
        // The heartbeat starts before the skills and memory stores are downloaded, which can take longer than the
        // lease TTL, and runs until the memory teardown is done: the lease stays this worker's the whole time.
        let result: Result<Void, Error>? = await withTaskGroup(of: (Bool, Result<Void, Error>?).self) { group in
            group.addTask {
                let beat: @Sendable () async -> Void = {
                    await heartbeatLoop(work, workID: item.id, environmentID: item.environmentID, lease: lease,
                                        extraHeaders: extraHeaders, timings: timings, onLeaseTTL: { leaseTTL.value = $0 })
                }
                if let wrapHeartbeat { await wrapHeartbeat(beat) } else { await beat() }
                return (true, nil)
            }
            group.addTask {
                do {
                    try await self.runSession(item, credential: credential, workerClient: workerClient, stores: stores,
                                              sendRetryWindow: { leaseTTL.value })
                    lease.finish(.runnerDone)
                    return (false, .success(()))
                } catch {
                    return (false, .failure(error))
                }
            }
            var mainResult: Result<Void, Error>?
            while let (isHeartbeat, r) = await group.next() {
                if !isHeartbeat { mainResult = r }
                // Either side ending ends the other: a lease that ended stops the session run, and a finished run
                // stops the heartbeat.
                group.cancelAll()
            }
            return mainResult
        }
        if case .failure(let error)? = result {
            // The run was cancelled because the lease ended: that is how such a run ends, not an error.
            if error is CancellationError && lease.ended && !Task.isCancelled { return }
            throw error
        }
        if Task.isCancelled { throw CancellationError() }
    }

    private func runSession(_ item: EnvironmentWorkItem, credential: String, workerClient: Anthropic,
                            stores: (any EnvironmentMemoryStores)?, sendRetryWindow: @escaping @Sendable () -> TimeInterval?) async throws
    {
        // One session fetch, shared by the skills download and the memory-store download: two fetches could disagree
        // about the attached resources.
        let session = try await hooks.retrieveSession(workerClient, item.sessionID)
        // Only now can a session that simply has no memory be told from one whose memory cannot be mounted. Turning
        // the interval off is a deliberate opt-out and stays quiet.
        if stores == nil && memorySyncInterval != nil && sessionHasMemoryStore(session) {
            throw SessionMemoryError(
                "this session has memory stores attached, but the work item carried no sessions token; the memory endpoints "
                    + "reject the environment key, so the session's memories cannot be mounted. The work item was failed rather "
                    + "than run without them, matching how hosted sandboxes behave (work_id=\(item.id), session_id=\(item.sessionID))")
        }
        let context = try AgentToolContext(workdir: workdir, client: workerClient, session: session, maxFileBytes: maxFileBytes)
        var cleanEnd = false
        let outcome: Result<Void, Error>
        do {
            // A cancel while entering (a lost lease) still interrupts a skill download in progress.
            try await hooks.enterContext(context)
            if let stores {
                try await stores.download(session)
                // A store mounted outside the workdir must stay reachable by the file tools; read-only stores still
                // refuse writes through `readOnlyRoots`.
                context.allowedRoots = await stores.roots
                context.readOnlyRoots = await stores.readOnlyRoots
            }
            let tools = try toolsFor(context)
            let calls = try hooks.runSessionTools(EnvironmentSessionRun(
                client: client, sessionID: item.sessionID, tools: tools, maxIdle: maxIdle, environmentKey: credential,
                extraHeaders: extraHeaders, sendRetryWindow: sendRetryWindow))
            for try await _ in calls {
                await stores?.syncIfDue()
            }
            // A cancelled run ends its stream quietly; it is not a clean end.
            try Task.checkCancellation()
            // The last full sync runs in the teardown, after the bash processes are killed: its waived delete window
            // must not race a writer.
            cleanEnd = true
            outcome = .success(())
        } catch {
            outcome = .failure(error)
        }
        // The teardown is not a child of the run, so a cancel (a lost lease) cannot abort the bash kill, the skills
        // removal or the memory sync (upstream shields it). The heartbeat keeps the lease until it is done.
        let finalSync = cleanEnd
        // As in a Python `finally`, an error of the teardown replaces the run's.
        try await Task { try await self.teardown(item, context: context, stores: stores, cleanEnd: finalSync) }.value
        try outcome.get()
    }

    /// The session's teardown: the context first (so nothing is still writing when the syncs read), then the final
    /// memory sync of a clean end, the push-only flush, and the removal of the store folders.
    private func teardown(_ item: EnvironmentWorkItem, context: AgentToolContext, stores: (any EnvironmentMemoryStores)?,
                          cleanEnd: Bool) async throws
    {
        var exitError: Error?
        do {
            try await hooks.exitContext(context)
        } catch {
            exitError = error
        }
        if let stores {
            let bound = hooks.memoryFlushTimeout
            if cleanEnd, try await memoryTeardownPass(.finish, { try await stores.finish() }) {
                workerLog.warning(
                    "final memory sync cut off after \(pyG(bound))s; the flush that follows still uploads changed files "
                        + "work_id=\(item.id) session_id=\(item.sessionID)")
            }
            // Push whatever is still on disk before dispose removes it, even after `finish()`, which may have failed
            // or been cut off; a clean flush is free.
            if try await memoryTeardownPass(.flush, { await stores.flushWrites() }) {
                workerLog.warning(
                    "memory flush cut off after \(pyG(bound))s; changed files it had not uploaded yet are not saved "
                        + "work_id=\(item.id) session_id=\(item.sessionID)")
            }
            await stores.dispose()
        }
        if let exitError { throw exitError }
    }

    /// Runs one memory teardown pass under its bound (`anyio.move_on_after`): once the bound passes, the pass is
    /// cancelled and waited for. Returns whether it was cut off.
    private func memoryTeardownPass(_ pass: MemoryTeardownPass, _ body: @escaping @Sendable () async throws -> Void) async throws -> Bool {
        let bound = hooks.memoryTeardownBound
        let seconds = hooks.memoryFlushTimeout
        return try await withThrowingTaskGroup(of: Bool.self) { group in
            group.addTask {
                try await body()
                return false
            }
            group.addTask {
                if let bound {
                    await bound(pass)
                } else {
                    try? await Task.sleep(nanoseconds: UInt64(max(0, seconds) * 1_000_000_000))
                }
                return true
            }
            let cutOff = try await group.next() ?? false
            group.cancelAll()
            // A pass cut off part-way ends on the cancel; whatever it throws then is part of being cut off.
            while (try? await group.next()) != nil {}
            return cutOff
        }
    }
}

extension BetaEnvironmentsWorkResource {
    /// Build an `EnvironmentWorker` bound to this resource's client (`work.worker(...)`): it polls the environment,
    /// and for each claimed session sets up the workdir, the session agent's skills and the session's memory stores,
    /// runs `tools` (by default `betaAgentToolset20260401`) against the session's tool calls while heartbeating the
    /// work-item lease, syncs the memory stores back, force-stops the work on exit, and loops. See `EnvironmentWorker`.
    public func worker(environmentID: String? = nil, environmentKey: String? = nil, tools: EnvironmentWorkerTools? = nil,
                       workdir: String? = nil, unrestrictedPaths: Bool? = nil, maxFileBytes: Int?? = nil,
                       maxIdle: TimeInterval? = DEFAULT_MAX_IDLE, memorySyncInterval: TimeInterval? = DEFAULT_MEMORY_SYNC_INTERVAL,
                       memorySyncDeletions: MemoryDeleteMode = .enabled, workerID: String? = nil,
                       extraHeaders: Headers? = nil) throws -> EnvironmentWorker
    {
        guard let client = client as? Anthropic else {
            throw ArgumentTypeError("The environment worker needs an Anthropic client")
        }
        return try EnvironmentWorker(client: client, environmentID: environmentID, environmentKey: environmentKey, tools: tools,
                                     workdir: workdir, unrestrictedPaths: unrestrictedPaths, maxFileBytes: maxFileBytes,
                                     maxIdle: maxIdle, memorySyncInterval: memorySyncInterval,
                                     memorySyncDeletions: memorySyncDeletions, workerID: workerID, extraHeaders: extraHeaders)
    }
}
