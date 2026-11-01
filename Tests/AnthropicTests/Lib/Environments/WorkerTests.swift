// Port of tests/lib/environments/test_worker.py.
//
// Upstream stubs `aiter_work`, the session tool runner and the scoped-client factory. Here the worker runs with
// its real scoped clients over a mock transport (`EnvWorkerAPI` answers the heartbeat, stop and session requests
// and records them, so the credential and helper tag of each request are checked on the wire), and the hooks
// replace only the poll loop (`workItems`) and the session tool runner (`runSessionTools`).

import Foundation
import Testing
@testable import Anthropic

/// A one-shot async event (`asyncio.Event`).
final class EnvEvent: @unchecked Sendable {
    private let lock = NSLock()
    private var isSet = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func set() {
        let w: [CheckedContinuation<Void, Never>] = lock.withLock {
            isSet = true
            defer { waiters = [] }
            return waiters
        }
        for c in w { c.resume() }
    }

    var value: Bool { lock.withLock { isSet } }

    func wait() async {
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            let now: Bool = lock.withLock {
                if isSet { return true }
                waiters.append(c)
                return false
            }
            if now { c.resume() }
        }
    }
}

let envSessionJSON: JSONValue = try! JSONValue.parse(Data(#"""
{"id": "s_1", "agent": {"id": "string", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "model": {"id": "claude-haiku-5-5"}, "name": "string", "skills": [], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}, "created_at": "2024-01-01T00:00:00Z", "environment_id": "string", "metadata": {"key": "string"}, "outcome_evaluations": [{"description": "string", "iteration": 0, "outcome_id": "string", "result": "string", "type": "outcome_evaluation"}], "resources": [], "stats": {"active_seconds": 0, "duration_seconds": 0}, "status": "rescheduling", "title": "string", "type": "session", "updated_at": "2024-01-01T00:00:00Z", "usage": {"active_seconds": 0, "cache_creation": {}, "cache_read_input_tokens": 0, "input_tokens": 0, "list_cost": {"amount": "string", "currency": "USD"}, "output_tokens": 0, "server_tool_use": {}}, "vault_ids": ["string"], "deployment_id": "string"}
"""#.utf8))

/// The control-plane and session endpoints the worker calls, over a mock transport.
final class EnvWorkerAPI: @unchecked Sendable {
    private let lock = NSLock()
    private var _requests: [HTTPRequest] = []
    var heartbeatState = "active"
    var heartbeatStatus = 200
    var heartbeatBody: JSONValue?
    /// When set, every heartbeat waits for it before answering.
    var heartbeatGate: EnvEvent?
    var stopStatus = 200
    var sessionSkills: JSONValue = []
    /// Called when a skill version is fetched (before answering it with a 404).
    var onSkillFetch: (@Sendable () async -> Void)?

    var requests: [HTTPRequest] { lock.withLock { _requests } }

    func calls(_ suffix: String) -> [HTTPRequest] { requests.filter { $0.url.path.hasSuffix(suffix) } }
    var heartbeats: [HTTPRequest] { calls("/heartbeat") }
    var stops: [HTTPRequest] { calls("/stop") }
    var sessionRetrieves: [String] { requests.filter { $0.url.path.hasPrefix("/v1/sessions/") }.map { $0.url.lastPathComponent } }

    func client() throws -> Anthropic {
        try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, maxRetries: 0, transport: MockTransport { [self] request in
            try await self.respond(request)
        }, environment: [:])
    }

    private func respond(_ request: HTTPRequest) async throws -> HTTPResponse {
        lock.withLock { _requests.append(request) }
        let path = request.url.path
        if path.hasSuffix("/heartbeat") {
            if let gate = heartbeatGate { await gate.wait() }
            if heartbeatStatus != 200 {
                return .json(heartbeatBody ?? ["type": "error", "error": ["type": "api_error", "message": "boom"]], status: heartbeatStatus,
                             for: request)
            }
            return .json(["type": "work_heartbeat", "last_heartbeat": "hb-1", "ttl_seconds": 60, "state": .string(heartbeatState),
                          "lease_extended": true], for: request)
        }
        if path.hasSuffix("/stop") {
            if stopStatus != 200 {
                return .json(["type": "error", "error": ["type": "api_error", "message": "force-stop exploded"]], status: stopStatus,
                             for: request)
            }
            return .json(envWorkJSON(request.url.deletingLastPathComponent().lastPathComponent), for: request)
        }
        if path.hasPrefix("/v1/sessions/") {
            var session = envSessionJSON.objectValue!
            session["id"] = .string(request.url.lastPathComponent)
            var agent = session["agent"]!.objectValue!
            agent["skills"] = sessionSkills
            session["agent"] = .object(agent)
            return .json(.object(session), for: request)
        }
        if path.hasPrefix("/v1/skills/") {
            await onSkillFetch?()
            return .json(["type": "error", "error": ["type": "not_found_error", "message": "no such skill"]], status: 404, for: request)
        }
        return .json(["type": "error", "error": ["type": "not_found_error", "message": .string("unexpected \(path)")]], status: 404, for: request)
    }
}

func envWorkJSON(_ id: String) -> JSONValue {
    ["id": .string(id), "type": "work", "created_at": "2026-01-01T00:00:00Z", "environment_id": "e_1", "metadata": [:], "state": "stopped",
     "data": ["id": "s_1", "type": "session"]]
}

/// What the faked session tool runner was given (`record["run"]`).
final class EnvRunRecord: @unchecked Sendable {
    private let lock = NSLock()
    private var _run: EnvironmentSessionRun?
    private var _window: TimeInterval??
    var run: EnvironmentSessionRun? {
        get { lock.withLock { _run } }
        set { lock.withLock { _run = newValue } }
    }
    /// The send retry window read at the end of the run (`record["send_retry_window"]`).
    var sendRetryWindow: TimeInterval?? {
        get { lock.withLock { _window } }
        set { lock.withLock { _window = newValue } }
    }
}

/// The hooks of a worker test: the given work items instead of the poll loop, and a session tool runner that
/// records its arguments and runs `serve` (by default it ends on its own after a moment).
func envHooks(_ record: EnvRunRecord, items: [BetaSelfHostedWork] = [], polls: ToolsBox<[String]>? = nil,
              poller: ToolsBox<EnvironmentWorkPoller?>? = nil, serve: (@Sendable () async -> Void)? = nil,
              environment: [String: String] = [:]) -> EnvironmentWorkerHooks
{
    var hooks = EnvironmentWorkerHooks()
    hooks.environment = { environment }
    hooks.workItems = { p in
        poller?.value = p
        let queue = ToolsBox(items)
        return AsyncThrowingStream {
            polls?.mutate { $0.append("poll") }
            return queue.value.isEmpty ? nil : queue.value.removeFirst()
        }
    }
    hooks.runSessionTools = { run in
        record.run = run
        return AsyncThrowingStream { continuation in
            let task = Task {
                if let serve {
                    await serve()
                } else {
                    // Upstream sleeps 50ms and relies on asyncio having run the first heartbeat by then; with a
                    // multithreaded executor wait (bounded) for the heartbeat to report the lease TTL instead.
                    try? await Task.sleep(nanoseconds: 50_000_000)
                    let deadline = Date().addingTimeInterval(5)
                    while run.sendRetryWindow() == nil && Date() < deadline {
                        try? await Task.sleep(nanoseconds: 10_000_000)
                    }
                }
                record.sendRetryWindow = .some(run.sendRetryWindow())
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
    return hooks
}

/// A session that never completes on its own, with the heartbeat held back until the runner is serving it: the
/// heartbeat's outcome decides how the run ends (`_install_session_ended_by_heartbeat`).
func envServeUntilTheHeartbeatEndsIt(_ api: EnvWorkerAPI) -> @Sendable () async -> Void {
    let serving = EnvEvent()
    api.heartbeatGate = serving
    return {
        serving.set()
        try? await Task.sleep(nanoseconds: 30_000_000_000)
    }
}

func envWorker(_ api: EnvWorkerAPI, hooks: EnvironmentWorkerHooks, environmentID: String? = "e_1", environmentKey: String? = "env_key",
               tools: EnvironmentWorkerTools? = nil, maxIdle: TimeInterval? = DEFAULT_MAX_IDLE,
               extraHeaders: Headers? = nil) throws -> EnvironmentWorker
{
    try EnvironmentWorker(client: api.client(), environmentID: environmentID, environmentKey: environmentKey, tools: tools, workdir: ".",
                      maxIdle: maxIdle, workerID: nil, extraHeaders: extraHeaders, hooks: hooks)
}

/// A work-item `secret` the way the control plane builds one: URL-safe base64 of a JSON payload, without padding.
func envEncodeSecret(_ payload: JSONValue) -> String {
    let data = try! JSONValue.serialize(payload)
    return data.base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
}

func envBearer(_ request: HTTPRequest) -> String? { request.headers["authorization"] }

func envLogText(_ capture: ToolDiagnostics.Capture) -> String {
    capture.records.map(\.message).joined(separator: "\n")
}

/// Runs `body` with a time limit (`asyncio.wait_for(..., timeout=5)`). The limit only stops a hung test, so it is
/// generous: a full parallel `swift test` keeps the cooperative pool busy for many seconds, and upstream's 5s bound
/// assumes a test runs alone on its event loop.
func envWithTimeout<T: Sendable>(_ seconds: Double = 60, _ body: @escaping @Sendable () async throws -> T) async throws -> T {
    try await withToolTimeout(seconds, body)
}

private let envLeaseLostBody: JSONValue = [
    "type": "error",
    "error": [
        "type": "invalid_request_error", "message": "Heartbeat precondition failed: expected hb-1, actual was NULL",
        "details": [
            "error_code": "heartbeat_precondition_failed", "error_visibility": "user_facing",
            "current_state": ["state": "queued", "last_heartbeat": nil, "lease_updated_at": nil, "lease_extended": false, "ttl_seconds": 120],
        ],
    ],
]

@Suite struct EnvWorkerTests {
    @Test func servesSession() async throws {
        let api = EnvWorkerAPI()
        let record = EnvRunRecord()
        let worker = try envWorker(api, hooks: envHooks(record, items: [envWork("w_1", environmentID: "e_1")]), maxIdle: 12)
        try await envWithTimeout { try await worker.run() }

        #expect(api.sessionRetrieves == ["s_1"])
        let run = try #require(record.run)
        #expect(run.sessionID == "s_1")
        #expect(run.maxIdle == 12)
        #expect(run.environmentKey == "env_key")
        // Without `tools`, the default toolset (the six `agent_toolset_20260401` tools) was bound.
        #expect(run.tools.map(\.name) == ["bash", "read", "write", "edit", "glob", "grep"])
        // The lease was heartbeated, and the lease TTL it reported (60s) became the send retry window.
        #expect(api.heartbeats.count >= 1)
        #expect(record.sendRetryWindow == .some(60))
        #expect(api.stops.count == 1)
        #expect(api.stops[0].url.path == "/v1/environments/e_1/work/w_1/stop")
        #expect(api.stops[0].jsonBody?["force"] == true)
        // The heartbeat, stop and session fetch ride the `environments-worker` client with the environment key.
        for request in api.requests {
            #expect(envBearer(request) == "Bearer env_key")
            #expect(request.headers["x-api-key"] == nil)
            #expect(request.headers["x-stainless-helper"] == "environments-worker")
        }
    }

    @Test func pollsWithAnEnvironmentWorkPollerClient() async throws {
        let api = EnvWorkerAPI()
        let poller = ToolsBox<EnvironmentWorkPoller?>(nil)
        let worker = try envWorker(api, hooks: envHooks(EnvRunRecord(), poller: poller), extraHeaders: ["x-trace-id": "abc123"])
        try await envWithTimeout { try await worker.run() }
        let p = try #require(poller.value)
        #expect(p.environmentID == "e_1")
        #expect(!p.autoStop)
        #expect(!p.drain)
        #expect(p.extraHeaders == ["x-trace-id": "abc123"])
        let work = try #require(p.work as? ResourceEnvironmentWork)
        let client = try #require(work.resource.client as? Anthropic)
        #expect(client.authToken == "env_key")
        #expect(client.apiKey == nil)
        #expect(client.customHeaders[STAINLESS_HELPER_HEADER] == "environments-work-poller")
    }

    @Test func skipsNonSessionItem() async throws {
        let api = EnvWorkerAPI()
        let record = EnvRunRecord()
        let worker = try envWorker(api, hooks: envHooks(record, items: [envWork("w_1", type: "healthcheck", environmentID: "e_1")]))
        try await envWithTimeout { try await worker.run() }
        #expect(api.sessionRetrieves.isEmpty)
        #expect(record.run == nil)
        #expect(api.stops.count == 1)
    }

    @Test func acceptsToolsFactory() async throws {
        let api = EnvWorkerAPI()
        let record = EnvRunRecord()
        let seen = ToolsBox<[String]>([])
        let tool = recordingTool("custom", ToolsBox([]))
        let worker = try envWorker(api, hooks: envHooks(record, items: [envWork("w_1", environmentID: "e_1")]),
                                   tools: .factory { context in
                                       seen.mutate { $0.append(context.session?.id ?? "") }
                                       return [tool]
                                   })
        try await envWithTimeout { try await worker.run() }
        #expect(record.run?.tools.map(\.name) == ["custom"])
        #expect(seen.value == ["s_1"])
    }

    @Test func prefersWorkItemSecret() async throws {
        let secret = envEncodeSecret(["sessions_token": "sessions-token-item-1", "session_ingress_token": "ingress-token-1"])
        let api = EnvWorkerAPI()
        let record = EnvRunRecord()
        let poller = ToolsBox<EnvironmentWorkPoller?>(nil)
        let worker = try envWorker(api, hooks: envHooks(record, items: [envWork("w_1", secret: secret, environmentID: "e_1")], poller: poller))
        let (_, capture) = try await ToolDiagnostics.capture { try await envWithTimeout { try await worker.run() } }

        // Polling keeps the environment key; the per-item client switches to the sessions token.
        let pollClient = try #require((poller.value?.work as? ResourceEnvironmentWork)?.resource.client as? Anthropic)
        #expect(pollClient.authToken == "env_key")
        for request in api.requests { #expect(envBearer(request) == "Bearer sessions-token-item-1") }
        #expect(record.run?.environmentKey == "sessions-token-item-1")
        #expect(api.heartbeats.count >= 1)
        #expect(api.stops[0].jsonBody?["force"] == true)
        let text = envLogText(capture)
        #expect(!text.contains(secret))
        #expect(!text.contains("sessions-token-item-1"))
    }

    @Test func fallsBackWhenSecretUndecodable() async throws {
        let api = EnvWorkerAPI()
        let record = EnvRunRecord()
        let worker = try envWorker(api, hooks: envHooks(record, items: [envWork("w_1", secret: "not-a-valid-payload", environmentID: "e_1")]))
        let (_, capture) = try await ToolDiagnostics.capture { try await envWithTimeout { try await worker.run() } }
        for request in api.requests { #expect(envBearer(request) == "Bearer env_key") }
        #expect(record.run?.environmentKey == "env_key")
        let text = envLogText(capture)
        #expect(text.contains("no sessions token could be extracted"))
        #expect(!text.contains("not-a-valid-payload"))
    }

    @Test func sessionsTokenFromSecretDecodesThePayload() {
        let payload: JSONValue = ["sessions_token": "sessions-token-abc", "auth": [["type": "anthropic_oauth", "token": "oauth"]]]
        let unpadded = envEncodeSecret(payload)
        let padded = (try! JSONValue.serialize(payload)).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")

        #expect(sessionsTokenFromSecret(unpadded) == "sessions-token-abc")
        #expect(sessionsTokenFromSecret(padded) == "sessions-token-abc")
        #expect(sessionsTokenFromSecret(nil) == nil)
        #expect(sessionsTokenFromSecret("") == nil)
        #expect(sessionsTokenFromSecret("!!! not base64 !!!") == nil)
        #expect(sessionsTokenFromSecret(Data("plain text".utf8).base64EncodedString()) == nil)
        #expect(sessionsTokenFromSecret(envEncodeSecret(["session_ingress_token": "ingress-token-1"])) == nil)
        #expect(sessionsTokenFromSecret(envEncodeSecret(["sessions_token": ""])) == nil)
    }

    @Test func secretNotLoggedOnErrorPaths() async throws {
        let secret = envEncodeSecret(["sessions_token": "sessions-token-err"])
        let api = EnvWorkerAPI()
        api.heartbeatState = "stopping"
        api.stopStatus = 500
        let worker = try envWorker(api, hooks: envHooks(EnvRunRecord(), items: [envWork("w_1", secret: secret, environmentID: "e_1")]))
        let (_, capture) = try await ToolDiagnostics.capture { try await envWithTimeout { try await worker.run() } }
        #expect(api.stops.map { $0.url.path } == ["/v1/environments/e_1/work/w_1/stop"])
        let text = envLogText(capture)
        #expect(text.contains("force-stop on exit failed"))
        #expect(!text.contains(secret))
        #expect(!text.contains("sessions-token-err"))
    }

    @Test func heartbeat412ReleasesItemWithoutStoppingIt() async throws {
        let api = EnvWorkerAPI()
        api.heartbeatStatus = 412
        api.heartbeatBody = envLeaseLostBody
        let record = EnvRunRecord()
        let polls = ToolsBox<[String]>([])
        let hooks = envHooks(record, items: [envWork("w_1", environmentID: "e_1")], polls: polls, serve: envServeUntilTheHeartbeatEndsIt(api))
        let worker = try envWorker(api, hooks: hooks, tools: .list([]))
        let (_, capture) = try await ToolDiagnostics.capture { try await envWithTimeout { try await worker.run() } }

        #expect(record.run?.sessionID == "s_1")
        #expect(api.heartbeats.count == 1)
        #expect(api.stops.isEmpty)
        #expect(polls.value == ["poll", "poll"], "run() must go back to the poller after releasing the item")
        let text = envLogText(capture)
        #expect(text.contains(
            "lease lost: heartbeat precondition failed work_id=w_1 server_state=queued server_ttl_seconds=120 server_last_heartbeat=None"))
        #expect(text.contains("lease lost; released work_id=w_1 session_id=s_1 without stopping it"))
        #expect(!text.contains("work item failed"))
    }

    @Test func controlPlaneStopStillForceStops() async throws {
        let api = EnvWorkerAPI()
        api.heartbeatState = "stopped"
        let record = EnvRunRecord()
        let hooks = envHooks(record, items: [envWork("w_1", environmentID: "e_1")], serve: envServeUntilTheHeartbeatEndsIt(api))
        let worker = try envWorker(api, hooks: hooks, tools: .list([]))
        let (_, capture) = try await ToolDiagnostics.capture { try await envWithTimeout { try await worker.run() } }

        #expect(record.run?.sessionID == "s_1")
        let text = envLogText(capture)
        #expect(text.contains("heartbeat signals shutdown state=stopped"))
        #expect(api.stops.count == 1)
        #expect(api.stops[0].url.path == "/v1/environments/e_1/work/w_1/stop")
        #expect(api.stops[0].jsonBody?["force"] == true)
        #expect(!text.contains("without stopping it"))
    }

    @Test func leaseAssumedLostReleasesItemWithoutStoppingIt() async throws {
        let api = EnvWorkerAPI()
        api.heartbeatStatus = 503
        let record = EnvRunRecord()
        var hooks = envHooks(record, items: [envWork("w_1", environmentID: "e_1")], serve: envServeUntilTheHeartbeatEndsIt(api))
        // Each clock read lands 100s after the previous one, so the first transient failure is already past the 90s
        // default TTL.
        let ticks = ToolsBox(-100.0)
        hooks.heartbeat.now = {
            ticks.mutate { $0 += 100 }
            return ticks.value
        }
        let worker = try envWorker(api, hooks: hooks, tools: .list([]))
        let (_, capture) = try await ToolDiagnostics.capture { try await envWithTimeout { try await worker.run() } }

        #expect(record.run?.sessionID == "s_1")
        let text = envLogText(capture)
        #expect(text.contains("lease assumed lost: no successful heartbeat in 90s"))
        #expect(api.stops.isEmpty)
        #expect(text.contains("lease lost; released work_id=w_1 session_id=s_1 without stopping it"))
    }

    @Test func leaseLostClassification() {
        for (reason, lost) in [(LeaseEndReason.leaseLost, true), (.assumedLost, true), (.controlPlaneStop, false),
                               (.heartbeatRejected, false), (.runnerDone, false)]
        {
            let lease = EnvironmentLease()
            #expect(!lease.ended)
            #expect(!lease.lost)
            lease.finish(reason)
            lease.finish(.runnerDone)
            #expect(lease.ended)
            #expect(lease.endReason == reason)
            #expect(lease.lost == lost, "\(reason)")
        }
    }

    @Test func runRequiresEnvironmentIDAndEnvironmentKey() async throws {
        let worker = try envWorker(EnvWorkerAPI(), hooks: envHooks(EnvRunRecord()), environmentID: nil, environmentKey: nil)
        await #expect(throws: ValueError("EnvironmentWorker.run: environment_id and environment_key are required to poll for work")) {
            try await worker.run()
        }
    }

    @Test func handleItemServicesASingleClaimedItem() async throws {
        let api = EnvWorkerAPI()
        let record = EnvRunRecord()
        let polls = ToolsBox<[String]>([])
        // A leftover per-item secret on the host must not override the explicit key: none is set here.
        let worker = try envWorker(api, hooks: envHooks(record, polls: polls), environmentID: nil, environmentKey: nil, maxIdle: 7)
        try await envWithTimeout {
            try await worker.handleItem(workID: "w_1", environmentID: "e_1", sessionID: "s_1", environmentKey: "env_key")
        }
        #expect(api.sessionRetrieves == ["s_1"])
        #expect(record.run?.sessionID == "s_1")
        #expect(record.run?.maxIdle == 7)
        #expect(record.run?.environmentKey == "env_key")
        #expect(api.heartbeats.count >= 1)
        #expect(api.heartbeats[0].url.path == "/v1/environments/e_1/work/w_1/heartbeat")
        #expect(api.heartbeats[0].headers["x-trace-id"] == nil)
        #expect(api.stops.map { $0.url.path } == ["/v1/environments/e_1/work/w_1/stop"])
        #expect(api.stops[0].jsonBody?["force"] == true)
        // `handleItem` doesn't poll: only the `environments-worker` client is used.
        #expect(polls.value.isEmpty)
        for request in api.requests {
            #expect(envBearer(request) == "Bearer env_key")
            #expect(request.headers["x-stainless-helper"] == "environments-worker")
        }
    }

    @Test func handleItemFallsBackToEnvVars() async throws {
        let api = EnvWorkerAPI()
        let record = EnvRunRecord()
        let env = ["ANTHROPIC_WORK_ID": "w_env", "ANTHROPIC_ENVIRONMENT_ID": "e_env", "ANTHROPIC_SESSION_ID": "s_env",
                   "ANTHROPIC_ENVIRONMENT_KEY": "key_env"]
        let worker = try envWorker(api, hooks: envHooks(record, environment: env), environmentID: nil, environmentKey: nil)
        try await envWithTimeout { try await worker.handleItem() }
        #expect(api.sessionRetrieves == ["s_env"])
        #expect(record.run?.sessionID == "s_env")
        #expect(record.run?.environmentKey == "key_env")
        #expect(api.heartbeats[0].url.path == "/v1/environments/e_env/work/w_env/heartbeat")
        #expect(api.stops[0].url.path == "/v1/environments/e_env/work/w_env/stop")
        for request in api.requests { #expect(envBearer(request) == "Bearer key_env") }
    }

    @Test func handleItemUsesConstructorEnvironmentKey() async throws {
        let api = EnvWorkerAPI()
        let record = EnvRunRecord()
        let worker = try envWorker(api, hooks: envHooks(record), environmentID: nil, environmentKey: "ctor_key")
        try await envWithTimeout { try await worker.handleItem(workID: "w_1", environmentID: "e_1", sessionID: "s_1") }
        #expect(record.run?.environmentKey == "ctor_key")
        for request in api.requests { #expect(envBearer(request) == "Bearer ctor_key") }
    }

    @Test func handleItemUsesWorkSecretArgument() async throws {
        let secret = envEncodeSecret(["sessions_token": "sessions-token-arg"])
        let api = EnvWorkerAPI()
        let record = EnvRunRecord()
        let worker = try envWorker(api, hooks: envHooks(record), environmentID: nil, environmentKey: nil)
        try await envWithTimeout {
            try await worker.handleItem(workID: "w_1", environmentID: "e_1", sessionID: "s_1", environmentKey: "env_key", workSecret: secret)
        }
        for request in api.requests { #expect(envBearer(request) == "Bearer sessions-token-arg") }
        #expect(record.run?.environmentKey == "sessions-token-arg")
    }

    @Test func handleItemFallsBackToWorkSecretEnvVar() async throws {
        let secret = envEncodeSecret(["sessions_token": "sessions-token-env"])
        let api = EnvWorkerAPI()
        let record = EnvRunRecord()
        let env = ["ANTHROPIC_WORK_ID": "w_env", "ANTHROPIC_ENVIRONMENT_ID": "e_env", "ANTHROPIC_SESSION_ID": "s_env",
                   "ANTHROPIC_ENVIRONMENT_KEY": "key_env", "ANTHROPIC_WORK_SECRET": secret]
        let worker = try envWorker(api, hooks: envHooks(record, environment: env), environmentID: nil, environmentKey: nil)
        try await envWithTimeout { try await worker.handleItem() }
        for request in api.requests { #expect(envBearer(request) == "Bearer sessions-token-env") }
        #expect(record.run?.environmentKey == "sessions-token-env")
        #expect(api.stops[0].url.path == "/v1/environments/e_env/work/w_env/stop")
    }

    @Test func handleItemMissingRequiredRaises() async throws {
        let worker = try envWorker(EnvWorkerAPI(), hooks: envHooks(EnvRunRecord()), environmentID: nil, environmentKey: nil)
        await #expect(throws: ValueError("handle_item: work_id is required — pass it or set ANTHROPIC_WORK_ID")) {
            try await worker.handleItem()
        }
        await #expect(throws: ValueError("handle_item: environment_key is required — pass it or set ANTHROPIC_ENVIRONMENT_KEY")) {
            try await worker.handleItem(workID: "w_1", environmentID: "e_1", sessionID: "s_1")
        }
    }

    @Test func handleItemRunsKeylessOnATokenBearingSecret() async throws {
        let secret = envEncodeSecret(["sessions_token": "sessions-token-keyless"])
        let api = EnvWorkerAPI()
        let record = EnvRunRecord()
        let worker = try envWorker(api, hooks: envHooks(record), environmentID: nil, environmentKey: nil)
        try await envWithTimeout { try await worker.handleItem(workID: "w_1", environmentID: "e_1", sessionID: "s_1", workSecret: secret) }
        for request in api.requests { #expect(envBearer(request) == "Bearer sessions-token-keyless") }
        #expect(record.run?.environmentKey == "sessions-token-keyless")
        #expect(api.sessionRetrieves == ["s_1"])
        #expect(api.stops[0].url.path == "/v1/environments/e_1/work/w_1/stop")
    }

    @Test func handleItemKeylessWithATokenlessSecretRaises() async throws {
        let api = EnvWorkerAPI()
        let worker = try envWorker(api, hooks: envHooks(EnvRunRecord()), environmentID: nil, environmentKey: nil)
        do {
            try await worker.handleItem(workID: "w_1", environmentID: "e_1", sessionID: "s_1", workSecret: "not-a-valid-payload")
            Issue.record("expected a ValueError")
        } catch let error as ValueError {
            #expect(error.message.contains("sessions_token, or an environment key"))
        }
        #expect(api.requests.isEmpty)
    }

    @Test func threadsExtraHeadersIntoPollHeartbeatStopAndRunner() async throws {
        let extras: Headers = ["x-trace-id": "abc123"]
        let api = EnvWorkerAPI()
        let record = EnvRunRecord()
        let poller = ToolsBox<EnvironmentWorkPoller?>(nil)
        let worker = try envWorker(api, hooks: envHooks(record, items: [envWork("w_1", environmentID: "e_1")], poller: poller),
                                   extraHeaders: extras)
        try await envWithTimeout { try await worker.run() }
        #expect(poller.value?.extraHeaders == extras)
        #expect(api.heartbeats[0].headers["x-trace-id"] == "abc123")
        #expect(api.stops[0].headers["x-trace-id"] == "abc123")
        #expect(record.run?.extraHeaders == extras)
        #expect(record.run?.environmentKey == "env_key")
    }

    @Test func workResourceWorkerBuildsEnvironmentWorker() throws {
        let client = try Anthropic(apiKey: "x", environment: [:])
        let worker = try client.beta.environments.work.worker(
            environmentID: "e_1", environmentKey: "env_key", workdir: "/workspace", maxIdle: 12, memorySyncInterval: 45,
            memorySyncDeletions: .logOnly, workerID: "w-test", extraHeaders: ["x-trace-id": "abc123"])
        #expect(worker.client === client)
        #expect(worker.environmentID == "e_1")
        #expect(worker.environmentKey == "env_key")
        #expect(worker.workdir == "/workspace")
        #expect(worker.maxIdle == 12)
        #expect(worker.memorySyncInterval == 45)
        #expect(worker.memorySyncDeletions == .logOnly)
        #expect(worker.workerID == "w-test")
        #expect(worker.extraHeaders == ["x-trace-id": "abc123"])
    }

    @Test(arguments: [true, false]) func unrestrictedPathsIsRejectedAtConstruction(_ value: Bool) throws {
        let client = try Anthropic(apiKey: "x", environment: [:])
        #expect(throws: ArgumentTypeError(UNRESTRICTED_PATHS_DEPRECATION)) {
            try EnvironmentWorker(client: client, unrestrictedPaths: value)
        }
        #expect(throws: ArgumentTypeError(UNRESTRICTED_PATHS_DEPRECATION)) {
            try client.beta.environments.work.worker(unrestrictedPaths: value)
        }
        #expect(UNRESTRICTED_PATHS_DEPRECATION.hasPrefix("unrestricted_paths is no longer supported"))
    }

    @Test func workResourceWorkerDefaults() throws {
        let worker = try Anthropic(apiKey: "x", environment: [:]).beta.environments.work.worker()
        #expect(worker.environmentID == nil)
        #expect(worker.environmentKey == nil)
        #expect(worker.tools == nil)
        #expect(worker.workdir == FileManager.default.currentDirectoryPath)
        #expect(worker.maxIdle == 60)
        #expect(worker.memorySyncInterval == 15)
        #expect(worker.memorySyncDeletions == .enabled)
    }

    @Test func heartbeatStartsBeforeSkillDownload() async throws {
        let api = EnvWorkerAPI()
        let order = ToolsBox<[String]>([])
        let heartbeatFired = EnvEvent()
        api.sessionSkills = [["type": "anthropic", "skill_id": "xlsx", "version": "latest"]]
        api.onSkillFetch = {
            order.mutate { $0.append("setup_start") }
            // If the heartbeat hadn't started yet this would wait out the test's time limit.
            await heartbeatFired.wait()
            order.mutate { $0.append("setup_end") }
        }
        let gate = EnvEvent()
        gate.set()
        api.heartbeatGate = gate
        let record = EnvRunRecord()
        var hooks = envHooks(record, items: [envWork("w_1", environmentID: "e_1")], serve: {})
        let workdir = FileManager.default.temporaryDirectory.appendingPathComponent("env-worker-\(UUID().uuidString)").path
        try FileManager.default.createDirectory(atPath: workdir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(atPath: workdir) }
        let wrapped = hooks.workAPI
        hooks.workAPI = { client in EnvHeartbeatSpy(inner: wrapped(client), order: order, fired: heartbeatFired) }
        let worker = try EnvironmentWorker(client: api.client(), environmentID: "e_1", environmentKey: "env_key", tools: nil, workdir: workdir,
                                       maxIdle: DEFAULT_MAX_IDLE, workerID: nil, extraHeaders: nil, hooks: hooks)
        try await envWithTimeout { try await worker.run() }

        let seen = order.value
        #expect(seen.contains("heartbeat"))
        #expect(seen.contains("setup_end"))
        if let h = seen.firstIndex(of: "heartbeat"), let e = seen.firstIndex(of: "setup_end") { #expect(h < e) }
        #expect(api.stops.count == 1)
    }
}

/// Records each heartbeat before it goes out.
struct EnvHeartbeatSpy: EnvironmentWorkAPI {
    let inner: any EnvironmentWorkAPI
    let order: ToolsBox<[String]>
    let fired: EnvEvent

    func poll(_ environmentID: String, blockMs: Int?, reclaimOlderThanMs: Int?, workerID: String, extraHeaders: Headers?) async throws
        -> BetaSelfHostedWork?
    {
        try await inner.poll(environmentID, blockMs: blockMs, reclaimOlderThanMs: reclaimOlderThanMs, workerID: workerID, extraHeaders: extraHeaders)
    }
    func ack(_ workID: String, environmentID: String, extraHeaders: Headers?) async throws {
        try await inner.ack(workID, environmentID: environmentID, extraHeaders: extraHeaders)
    }
    func stop(_ workID: String, environmentID: String, force: Bool?, extraHeaders: Headers?) async throws {
        try await inner.stop(workID, environmentID: environmentID, force: force, extraHeaders: extraHeaders)
    }
    func heartbeat(_ workID: String, environmentID: String, expectedLastHeartbeat: String, extraHeaders: Headers?) async throws
        -> BetaSelfHostedWorkHeartbeatResponse
    {
        order.mutate { $0.append("heartbeat") }
        fired.set()
        return try await inner.heartbeat(workID, environmentID: environmentID, expectedLastHeartbeat: expectedLastHeartbeat,
                                         extraHeaders: extraHeaders)
    }
}

// MARK: - The heartbeat loop
//
// `heartbeatLoop` is driven directly with a scripted work fake and a fake clock, so the lease-staleness ceiling is
// crossed without real waiting. The first scripted beat reports `ttl_seconds=0` so the loop keeps the tiny default
// interval instead of the 1s floor it applies to a server-provided TTL.

private let envFastInterval = 0.01
private let envFakeTTL = 5.0

enum EnvBeat: Sendable {
    case ok
    case error(any Error)
    case hang
}

/// `heartbeat` pops `(clock advance, outcome)` per call (`_ScriptedHeartbeatWork`).
final class EnvScriptedHeartbeatWork: EnvironmentWorkAPI, @unchecked Sendable {
    private let lock = NSLock()
    private let clock: EnvFakeClock
    private var script: [(Double, EnvBeat)]
    private var _calls = 0
    var calls: Int { lock.withLock { _calls } }

    init(clock: EnvFakeClock, script: [(Double, EnvBeat)]) {
        self.clock = clock
        self.script = script
    }

    func poll(_ environmentID: String, blockMs: Int?, reclaimOlderThanMs: Int?, workerID: String, extraHeaders: Headers?) async throws
        -> BetaSelfHostedWork? { nil }
    func ack(_ workID: String, environmentID: String, extraHeaders: Headers?) async throws {}
    func stop(_ workID: String, environmentID: String, force: Bool?, extraHeaders: Headers?) async throws {}

    func heartbeat(_ workID: String, environmentID: String, expectedLastHeartbeat: String, extraHeaders: Headers?) async throws
        -> BetaSelfHostedWorkHeartbeatResponse
    {
        let (advance, outcome) = lock.withLock { () -> (Double, EnvBeat) in
            _calls += 1
            return script.removeFirst()
        }
        clock.advance(advance)
        switch outcome {
        case .ok: return BetaSelfHostedWorkHeartbeatResponse(lastHeartbeat: "hb", leaseExtended: true, state: .active, ttlSeconds: 0)
        case .error(let e): throw e
        case .hang:
            try await Task.sleep(nanoseconds: 60_000_000_000)
            throw CancellationError()
        }
    }
}

private func envRunHeartbeatLoop(_ script: [(Double, EnvBeat)]) async throws -> (EnvScriptedHeartbeatWork, EnvironmentLease, [String]) {
    let clock = EnvFakeClock()
    let work = EnvScriptedHeartbeatWork(clock: clock, script: script)
    let lease = EnvironmentLease()
    let timings = HeartbeatTimings(defaultInterval: envFastInterval, ttlDefault: envFakeTTL, now: { clock.now })
    let (_, capture) = try await ToolDiagnostics.capture {
        try await envWithTimeout {
            await heartbeatLoop(work, workID: "w_1", environmentID: "e_1", lease: lease, timings: timings)
        }
    }
    let messages = capture.records.filter { $0.logger == "anthropic.lib.environments._worker" && $0.level >= .warning }.map(\.message)
    return (work, lease, messages)
}

@Suite struct EnvHeartbeatLoopTests {
    @Test func conflictIsRetriedUntilTheLeaseIsStale() async throws {
        let (work, lease, messages) = try await envRunHeartbeatLoop([
            (0, .ok), (envFakeTTL - 2, .error(envAPIStatusError(409))), (envFakeTTL, .error(envAPIStatusError(409))),
        ])
        #expect(work.calls == 3)
        #expect(lease.ended)
        #expect(lease.lost)
        #expect(messages.contains { $0.hasPrefix("transient heartbeat failure") })
        #expect(messages.contains { $0.hasPrefix("lease assumed lost") })
        #expect(!messages.contains { $0.hasPrefix("permanent heartbeat failure") })
    }

    @Test func aHeartbeatThatNeverReturnsIsCutOffEachInterval() async throws {
        let (work, lease, messages) = try await envRunHeartbeatLoop([(0, .ok), (envFakeTTL - 2, .hang), (envFakeTTL, .hang)])
        #expect(work.calls == 3)
        #expect(lease.ended)
        #expect(lease.lost)
        #expect(messages.contains { $0.hasPrefix("lease assumed lost") })
    }

    @Test func permanent4xxStopsImmediately() async throws {
        let (work, lease, messages) = try await envRunHeartbeatLoop([(0, .error(envAPIStatusError(401)))])
        #expect(work.calls == 1)
        #expect(lease.ended)
        #expect(!lease.lost)
        #expect(messages.contains { $0.hasPrefix("permanent heartbeat failure") })
    }
}
