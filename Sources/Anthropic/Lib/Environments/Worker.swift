// Port of `anthropic/lib/environments/_worker.py` (`EnvironmentWorker`, `EnvironmentWorkerTools`) and the
// hand-written `AsyncWork.worker(...)` of `resources/beta/environments/work.py`: the self-hosted environment
// worker, the composition of the control-plane poller and the per-session tool runner.
//
// Not ported here (see docs/porting/threads-environments-sessions.md): the memory-store sync of `_memories.py`
// (`memory_sync_interval`, `memory_sync_deletions`), and the default `beta_agent_toolset_20260401` tools with the
// bash session of `AgentToolContext` (`agent_toolset.py`). `EnvironmentWorkerContext` carries the part of
// `AgentToolContext` the worker drives: the workdir, the session and its downloaded skills.

import Foundation

let workerLog = ToolLogger(name: "anthropic.lib.environments._worker")

let HEARTBEAT_DEFAULT: Double = 30
/// Assumed lease TTL before the server's first heartbeat response tells the real value.
let HEARTBEAT_TTL_DEFAULT: Double = 90
let NO_HEARTBEAT_SENTINEL = "NO_HEARTBEAT"

/// The per-session context the worker builds for each claimed session (the part of upstream's `AgentToolContext`
/// that the worker drives): the workdir, the worker's client for the item, the session, and the session agent's
/// skills, downloaded into `{workdir}/skills/<name>/` before any tool runs and removed when the session ends.
public final class EnvironmentWorkerContext: @unchecked Sendable {
    public let workdir: String
    /// The Bearer-only client of the work item.
    public let client: Anthropic
    public let session: BetaManagedAgentsSession
    public var sessionID: String { session.id }
    /// The skill directories downloaded for the session.
    public private(set) var skillDirectories: [String] = []
    let downloadSkills: Bool

    init(workdir: String, client: Anthropic, session: BetaManagedAgentsSession, downloadSkills: Bool = true) {
        self.workdir = workdir
        self.client = client
        self.session = session
        self.downloadSkills = downloadSkills
    }

    /// `__aenter__`: download the session agent's skills.
    func enter() async throws {
        if downloadSkills && !session.agent.skills.isEmpty {
            skillDirectories = try await downloadSessionSkills(client, workdir: workdir, session: session)
        }
    }

    /// `__aexit__`: remove the downloaded skills.
    func exit() {
        for directory in skillDirectories { try? FileManager.default.removeItem(atPath: directory) }
        skillDirectories = []
    }
}

/// The tools a worker exposes to each claimed session (`EnvironmentWorkerTools`): a fixed list, or a factory
/// called once per session with that session's context.
public enum EnvironmentWorkerTools: Sendable {
    case list([any BetaRunnableTool])
    case factory(@Sendable (EnvironmentWorkerContext) throws -> [any BetaRunnableTool])
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
            sendRetryWindow: run.sendRetryWindow
        ).run()
    }
    var heartbeat = HeartbeatTimings()
    var environment: @Sendable () -> [String: String] = { ProcessInfo.processInfo.environment }
    var downloadSkills = true
}

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
/// For each claimed `session` work item the worker builds the per-session `EnvironmentWorkerContext` and downloads
/// the session agent's skills, then runs a `SessionToolRunner` for the session *while* heartbeating the work-item
/// lease; on exit it force-stops the work item (unless the lease was lost, in which case the item is left to whoever
/// holds it now) and goes on to the next one.
///
/// The `environmentKey` is the worker's standing credential: polling always uses it, and per-session calls fall back
/// to it when a work item's `secret` yields no sessions token. Every request rides a Bearer-only scoped sub-client,
/// never the parent client's API key.
///
/// ```swift
/// // Long-running daemon: poll for work, serve each session, loop. Cancel the task to stop it.
/// try await client.beta.environments.work.worker(environmentID: id, environmentKey: key, tools: .list(myTools)).run()
///
/// // Already-claimed item (e.g. inside `ant worker poll --on-work ...`):
/// try await client.beta.environments.work.worker(tools: .list(myTools)).handleItem()
/// ```
public final class EnvironmentWorker: Sendable {
    public let client: Anthropic
    public let environmentID: String?
    public let environmentKey: String?
    public let tools: EnvironmentWorkerTools?
    public let workdir: String
    public let maxIdle: TimeInterval?
    public let workerID: String?
    public let extraHeaders: Headers?
    let hooks: EnvironmentWorkerHooks

    /// - Parameters:
    ///   - environmentID: The self-hosted environment to poll. Required by `run()`; not used by `handleItem()`.
    ///   - environmentKey: The environment key: the Bearer credential of the control-plane and session calls, except
    ///     where a claimed item's own `secret` takes precedence. Required by `run()`.
    ///   - tools: The tools of each claimed session: a list, or a factory called with each session's context.
    ///     Upstream defaults to the `agent_toolset_20260401` tools, which are not part of this port; without tools
    ///     the session's tool calls are answered as unknown tools.
    ///   - workdir: Base directory of each session's context. Defaults to the current directory when the worker is
    ///     built.
    ///   - maxIdle: Seconds the session tool runner keeps running after the session goes idle with any
    ///     `stop_reason` but `requires_action`. `nil` disables it.
    ///   - workerID: Sent on each poll. Defaults to a unique, hostname-prefixed id.
    ///   - extraHeaders: Headers passed through on every request the worker makes (poll / ack / stop / heartbeat and
    ///     the session tool runner's requests). Use them for passthrough such as trace ids, not for auth.
    public convenience init(client: Anthropic, environmentID: String? = nil, environmentKey: String? = nil,
                            tools: EnvironmentWorkerTools? = nil, workdir: String? = nil, maxIdle: TimeInterval? = DEFAULT_MAX_IDLE,
                            workerID: String? = nil, extraHeaders: Headers? = nil)
    {
        self.init(client: client, environmentID: environmentID, environmentKey: environmentKey, tools: tools, workdir: workdir,
                  maxIdle: maxIdle, workerID: workerID, extraHeaders: extraHeaders, hooks: EnvironmentWorkerHooks())
    }

    init(client: Anthropic, environmentID: String?, environmentKey: String?, tools: EnvironmentWorkerTools?, workdir: String?,
         maxIdle: TimeInterval?, workerID: String?, extraHeaders: Headers?, hooks: EnvironmentWorkerHooks)
    {
        self.client = client
        self.environmentID = environmentID
        self.environmentKey = environmentKey
        self.tools = tools
        // The cwd is taken now, so a `chdir` before a session is served does not move where tools resolve paths.
        self.workdir = workdir ?? FileManager.default.currentDirectoryPath
        self.maxIdle = maxIdle
        self.workerID = workerID
        self.extraHeaders = extraHeaders
        self.hooks = hooks
    }

    func toolsFor(_ context: EnvironmentWorkerContext) throws -> [any BetaRunnableTool] {
        switch tools {
        case .list(let tools)?: return tools
        case .factory(let factory)?: return try factory(context)
        case nil: return []
        }
    }

    /// Poll the environment and serve each claimed session until cancelled. One item that fails is logged and
    /// skipped; cancellation ends the loop.
    public func run() async throws {
        guard let environmentID, let environmentKey else {
            throw ValueError("EnvironmentWorker.run: environment_id and environment_key are required to poll for work")
        }
        // Poll / ack / stop go through a Bearer-only sub-client tagged with the poller's helper telemetry; each
        // item builds its own `environments-worker` sub-client for the heartbeat and force-stop.
        let pollClient = try hooks.scopedClient(client, environmentKey, .environmentsWorkPoller)
        let poller = EnvironmentWorkPoller(work: hooks.workAPI(pollClient), environmentID: environmentID, workerID: workerID,
                                           autoStop: false, extraHeaders: extraHeaders)
        let items = hooks.workItems?(poller) ?? AsyncThrowingStream { try await poller.next() }
        for try await item in items {
            let lease = EnvironmentLease()
            do {
                try await serve(EnvironmentWorkItem(item), environmentKey: environmentKey, lease: lease)
            } catch {
                if error is CancellationError || Task.isCancelled { throw error }
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
        do {
            try await serveSession(item, credential: credential, workerClient: workerClient, work: work, lease: lease)
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
                              work: any EnvironmentWorkAPI, lease: EnvironmentLease) async throws
    {
        // The queue also sends "healthcheck" items, which the generated type does not model.
        if item.type != "session" {
            workerLog.debug("skipping non-session work item work_id=\(item.id) type=\(item.type)")
            return
        }
        let leaseTTL = EnvLeaseTTLBox()
        let timings = hooks.heartbeat
        let extraHeaders = self.extraHeaders
        // The heartbeat starts before the skills are downloaded, which can take longer than the lease TTL: the lease
        // stays this worker's the whole time.
        let result: Result<Void, Error>? = await withTaskGroup(of: (Bool, Result<Void, Error>?).self) { group in
            group.addTask {
                await heartbeatLoop(work, workID: item.id, environmentID: item.environmentID, lease: lease, extraHeaders: extraHeaders,
                                    timings: timings, onLeaseTTL: { leaseTTL.value = $0 })
                return (true, nil)
            }
            group.addTask {
                do {
                    try await self.runSession(item, credential: credential, workerClient: workerClient,
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
                            sendRetryWindow: @escaping @Sendable () -> TimeInterval?) async throws
    {
        // One session fetch, shared by everything that reads the session's resources.
        let session = try await hooks.retrieveSession(workerClient, item.sessionID)
        let context = EnvironmentWorkerContext(workdir: workdir, client: workerClient, session: session, downloadSkills: hooks.downloadSkills)
        defer { context.exit() }
        try await context.enter()
        let tools = try toolsFor(context)
        let calls = try hooks.runSessionTools(EnvironmentSessionRun(
            client: client, sessionID: item.sessionID, tools: tools, maxIdle: maxIdle, environmentKey: credential,
            extraHeaders: extraHeaders, sendRetryWindow: sendRetryWindow))
        for try await _ in calls {}
        try Task.checkCancellation()
    }
}

extension BetaEnvironmentsWorkResource {
    /// Build an `EnvironmentWorker` bound to this resource's client (`work.worker(...)`): it polls the environment,
    /// and for each claimed session sets up the workdir and the session agent's skills, runs `tools` against the
    /// session's tool calls while heartbeating the work-item lease, force-stops the work on exit, and loops.
    public func worker(environmentID: String? = nil, environmentKey: String? = nil, tools: EnvironmentWorkerTools? = nil,
                       workdir: String? = nil, maxIdle: TimeInterval? = DEFAULT_MAX_IDLE, workerID: String? = nil,
                       extraHeaders: Headers? = nil) throws -> EnvironmentWorker
    {
        guard let client = client as? Anthropic else {
            throw ArgumentTypeError("The environment worker needs an Anthropic client")
        }
        return EnvironmentWorker(client: client, environmentID: environmentID, environmentKey: environmentKey, tools: tools,
                                 workdir: workdir, maxIdle: maxIdle, workerID: workerID, extraHeaders: extraHeaders)
    }
}
