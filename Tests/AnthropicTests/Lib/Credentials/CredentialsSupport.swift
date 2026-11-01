import Foundation
import Testing
@testable import Anthropic

/// Helpers for the port of `tests/lib/test_credentials.py`.

let CREDS_BASE_URL = "https://api.anthropic.com"
let CREDS_TOKEN_URL = "\(CREDS_BASE_URL)\(TOKEN_ENDPOINT)"
/// A second deployment, for tests that build clients against two hosts at once.
let OTHER_BASE_URL = "https://api.other.example"
let OTHER_TOKEN_URL = "\(OTHER_BASE_URL)\(TOKEN_ENDPOINT)"
let BOTH_STATIC_ENV_VARS_WARNING = "Anthropic: ANTHROPIC_API_KEY and ANTHROPIC_AUTH_TOKEN are both set. Using ANTHROPIC_API_KEY."

/// A temporary directory removed when the value is deallocated (`tmp_path`).
final class TempDir: @unchecked Sendable {
    let url: URL
    var path: String { url.path }

    init() throws {
        // Resolve symlinks (macOS's /var → /private/var) so paths compare equal to resolved ones.
        let base = URL(fileURLWithPath: resolvePath(FileManager.default.temporaryDirectory.path), isDirectory: true)
        url = base.appendingPathComponent("slaude-credentials-\(UUID().uuidString.lowercased())", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    deinit { try? FileManager.default.removeItem(at: url) }

    func child(_ components: String...) -> URL {
        components.reduce(url) { $0.appendingPathComponent($1) }
    }

    /// The default config directory when `HOME` is `home` (the `no_default_creds_file` fixture
    /// points the config directory at an empty location this way).
    var home: URL { child("home") }
    var defaultConfigDir: URL { home.appendingPathComponent(".config").appendingPathComponent("anthropic") }
}

func writeText(_ url: URL, _ text: String, mode: Int? = nil) throws {
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try Data(text.utf8).write(to: url)
    if let mode { try chmod(url, mode) }
}

func writeJSON(_ url: URL, _ value: JSONValue, mode: Int? = nil) throws {
    try writeText(url, String(decoding: try JSONValue.serialize(value), as: UTF8.self), mode: mode)
}

func readJSON(_ url: URL) throws -> JSONValue { try JSONValue.parse(try Data(contentsOf: url)) }

func chmod(_ url: URL, _ mode: Int) throws {
    try FileManager.default.setAttributes([.posixPermissions: mode], ofItemAtPath: url.path)
}

func fileExistsAt(_ url: URL) -> Bool { FileManager.default.fileExists(atPath: url.path) }

/// Converts a flat legacy config (`{"type": "workload_identity", ...}`) into the nested shape
/// (`_migrate_legacy_config`).
func migrateLegacyConfig(_ flat: [String: JSONValue]) -> [String: JSONValue] {
    let topLevel: Set<String> = ["base_url", "organization_id", "workspace_id"]
    var result: [String: JSONValue] = [:]
    var auth: [String: JSONValue] = [:]
    for (k, v) in flat where k != "type" {
        if topLevel.contains(k) { result[k] = v } else { auth[k] = v }
    }
    let type = flat["type"]?.stringValue ?? ""
    let renamed = ["external": "user_oauth", "workload_identity": "oidc_federation", "authorized_user": "user_oauth"][type] ?? type
    auth["type"] = .string(renamed)
    result["authentication"] = .object(auth)
    return result
}

/// Lays out `configs/<profile>.json` (0644) and optionally `credentials/<profile>.json` (0600)
/// (`_write_profile`). Prepends `"type": "oauth_token"` to the credentials unless given.
func writeProfile(_ configDir: URL, _ profile: String, _ config: [String: JSONValue], _ credentials: [String: JSONValue]? = nil) throws {
    var config = config
    if config["type"] != nil && config["authentication"] == nil { config = migrateLegacyConfig(config) }
    try writeJSON(configDir.appendingPathComponent("configs").appendingPathComponent("\(profile).json"), .object(config), mode: 0o644)
    if var credentials {
        if credentials["type"] == nil { credentials["type"] = "oauth_token" }
        try writeJSON(configDir.appendingPathComponent("credentials").appendingPathComponent("\(profile).json"), .object(credentials), mode: 0o600)
    }
}

/// An environment that tests can change while providers hold it (`monkeypatch.setenv`).
final class MutableEnvironment: @unchecked Sendable {
    private let lock = NSLock()
    private var values: [String: String]

    init(_ values: [String: String] = [:]) { self.values = values }

    subscript(name: String) -> String? {
        get { lock.withLock { values[name] } }
        set { lock.withLock { values[name] = newValue } }
    }

    var dictionary: [String: String] { lock.withLock { values } }
    var environment: CredentialEnvironment { CredentialEnvironment { [self] in self[$0] } }
}

/// The isolated environment most tests run in (`clean_env` + `no_default_creds_file`): no
/// `ANTHROPIC_*` variables and a `HOME` whose default config directory is empty.
func cleanEnv(_ tmp: TempDir, _ extra: [String: String] = [:]) -> [String: String] {
    var env = ["HOME": tmp.home.path]
    for (k, v) in extra { env[k] = v }
    return env
}

/// `cleanEnv` with `ANTHROPIC_CONFIG_DIR` pointing at the temp dir (the `TestCredentialsFile` setup).
func configDirEnv(_ tmp: TempDir, _ extra: [String: String] = [:]) -> [String: String] {
    cleanEnv(tmp, ["ANTHROPIC_CONFIG_DIR": tmp.path].merging(extra) { $1 })
}

/// A mock HTTP router recording every request (`respx.MockRouter`).
final class MockRouter: HTTPTransport, @unchecked Sendable {
    typealias Responder = @Sendable (HTTPRequest) async throws -> HTTPResponse

    final class Route: @unchecked Sendable {
        let method: String
        let url: String
        let responder: Responder
        private let lock = NSLock()
        private var _calls: [HTTPRequest] = []

        init(method: String, url: String, responder: @escaping Responder) {
            self.method = method
            self.url = url
            self.responder = responder
        }

        func record(_ r: HTTPRequest) { lock.withLock { _calls.append(r) } }
        var calls: [HTTPRequest] { lock.withLock { _calls } }
        var callCount: Int { calls.count }
        var called: Bool { callCount > 0 }
    }

    private let lock = NSLock()
    private var routes: [Route] = []
    private var _calls: [HTTPRequest] = []
    private var _closed = false

    var calls: [HTTPRequest] { lock.withLock { _calls } }
    var isClosed: Bool { lock.withLock { _closed } }

    @discardableResult
    func route(_ method: String, _ url: String, _ responder: @escaping Responder) -> Route {
        let r = Route(method: method, url: trimTrailingSlashes(url), responder: responder)
        lock.withLock { routes.append(r) }
        return r
    }

    @discardableResult
    func post(_ url: String, _ responder: @escaping Responder) -> Route { route("POST", url, responder) }

    @discardableResult
    func post(_ url: String, status: Int = 200, json: JSONValue, headers: HTTPHeaders = HTTPHeaders()) -> Route {
        post(url) { HTTPResponse.json(json, status: status, headers: headers, for: $0) }
    }

    /// Answers successive calls with successive responses (`side_effect=[...]`); the last repeats.
    @discardableResult
    func post(_ url: String, sequence: [(Int, JSONValue)]) -> Route {
        let counter = Counter()
        return post(url) { req in
            let i = min(counter.next(), sequence.count - 1)
            return HTTPResponse.json(sequence[i].1, status: sequence[i].0, for: req)
        }
    }

    /// A route for every host: `url` is a suffix such as `"/v1/messages"` (`url__regex=...`).
    @discardableResult
    func postAnyHost(_ path: String, json: JSONValue) -> Route {
        post("*\(path)") { HTTPResponse.json(json, for: $0) }
    }

    func send(_ request: HTTPRequest, stream: Bool) async throws -> HTTPResponse {
        let key = trimTrailingSlashes(request.url.absoluteString.components(separatedBy: "?")[0])
        let match: Route? = lock.withLock {
            _calls.append(request)
            return routes.last(where: { $0.method == request.method && $0.url == key })
                ?? routes.last(where: { $0.method == request.method && $0.url.hasPrefix("*") && key.hasSuffix($0.url.dropFirst()) })
        }
        guard let match else {
            Issue.record("unmocked request \(request.method) \(request.url)")
            throw URLError(.unsupportedURL)
        }
        match.record(request)
        return try await match.responder(request)
    }

    func close() async { lock.withLock { _closed = true } }

    /// The requests sent to `baseURL` (`_requests_to`).
    func requests(to baseURL: String) -> [HTTPRequest] {
        calls.filter { $0.url.absoluteString.hasPrefix("\(baseURL)/") }
    }

    /// The `Authorization` bearer tokens sent to the messages endpoint (`_bearer_tokens`).
    func bearerTokens() -> [String] {
        calls.filter { $0.url.path.hasSuffix("/v1/messages") }.compactMap { $0.headers["Authorization"] }
            .map { $0.hasPrefix("Bearer ") ? String($0.dropFirst(7)) : $0 }
    }
}

/// A thread-safe counter.
final class Counter: @unchecked Sendable {
    private let lock = NSLock()
    private var value = 0
    func next() -> Int { lock.withLock { defer { value += 1 }; return value } }
    var count: Int { lock.withLock { value } }
}

/// A thread-safe box for values tests collect from concurrent code.
final class Box<T>: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: T
    init(_ value: T) { _value = value }
    var value: T {
        get { lock.withLock { _value } }
        set { lock.withLock { _value = newValue } }
    }
    func mutate(_ f: (inout T) -> Void) { lock.withLock { f(&_value) } }
}

let messageResponseJSON: JSONValue = [
    "id": "msg_01", "type": "message", "role": "assistant", "model": "claude-opus-4-5",
    "content": [["type": "text", "text": "hi"]], "stop_reason": "end_turn", "stop_sequence": nil,
    "usage": ["input_tokens": 1, "output_tokens": 1],
]

extension MockRouter {
    /// `_mock_token_endpoint`.
    func mockTokenEndpoint() {
        post(CREDS_TOKEN_URL, json: ["access_token": "sk-ant-oat01-test", "token_type": "Bearer", "expires_in": 600])
    }

    /// `_mock_messages_endpoint`.
    @discardableResult
    func mockMessages(_ baseURL: String = CREDS_BASE_URL) -> Route { post("\(baseURL)/v1/messages", json: messageResponseJSON) }

    /// `_mock_token_exchange`.
    @discardableResult
    func mockTokenExchange(_ baseURL: String, _ token: String) -> Route {
        post("\(baseURL)\(TOKEN_ENDPOINT)", json: ["access_token": .string(token), "token_type": "Bearer", "expires_in": 600])
    }

    /// `_mock_deployment`: the deployment's token endpoint mints `token`; its messages endpoint
    /// accepts anything.
    func mockDeployment(_ baseURL: String, _ token: String) {
        mockTokenExchange(baseURL, token)
        mockMessages(baseURL)
    }

    /// `_assert_exchanged_and_called_own_deployment`.
    func expectExchangedAndCalledOwnDeployment(_ baseURL: String, _ token: String, sourceLocation: SourceLocation = #_sourceLocation) {
        let reqs = requests(to: baseURL)
        #expect(reqs.map { $0.url.absoluteString } == ["\(baseURL)\(TOKEN_ENDPOINT)", "\(baseURL)/v1/messages"], sourceLocation: sourceLocation)
        if reqs.count == 2 {
            #expect(reqs[0].jsonBody?["assertion"] == "ext-jwt", sourceLocation: sourceLocation)
            #expect(reqs[1].headers["Authorization"] == "Bearer \(token)", sourceLocation: sourceLocation)
        }
    }
}

/// `_workload_credentials`.
func workloadCredentials(_ transport: HTTPTransport? = nil) -> WorkloadIdentityCredentials {
    WorkloadIdentityCredentials(identityTokenProvider: { "ext-jwt" }, federationRuleID: "fdrl_01abc", organizationID: "org-uuid",
                                transport: transport)
}

/// `_send_message`. Sends the request raw so it doesn't depend on the generated param types.
@discardableResult
func sendMessage(_ client: Anthropic) async throws -> JSONValue {
    try await client.post("/v1/messages", body: [
        "max_tokens": 1, "model": "claude-opus-4-5", "messages": [["role": "user", "content": "hi"]],
    ], as: JSONValue.self)
}

/// Records what the credentials subsystem logs (`caplog`).
final class LogRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var _records: [(CredentialsLog.Level, String)] = []

    func append(_ level: CredentialsLog.Level, _ message: String) { lock.withLock { _records.append((level, message)) } }
    var records: [(CredentialsLog.Level, String)] { lock.withLock { _records } }
    var warnings: [String] { records.filter { $0.0 == .warning }.map(\.1) }
    var text: String { records.map(\.1).joined(separator: "\n") }
}

/// Runs `body` capturing the credentials log, with a fresh one-shot warning registry (the
/// `_reset_shadow_one_shot` fixture).
func withCapturedLogs<T>(_ body: (LogRecorder) async throws -> T) async rethrows -> T {
    let recorder = LogRecorder()
    return try await CredentialsLog.$taskHandler.withValue({ recorder.append($0, $1) }) {
        try await CredentialsLog.$taskWarnOnceRegistry.withValue(WarnOnceRegistry()) {
            try await body(recorder)
        }
    }
}

/// `pytest.raises(E, match=...)`: expects `body` to throw an `E` whose description contains
/// `contains`, and returns it.
@discardableResult
func expectThrows<E: Error>(_ errorType: E.Type, _ contains: String? = nil, sourceLocation: SourceLocation = #_sourceLocation,
                            _ body: () async throws -> Void) async -> E?
{
    do {
        try await body()
        Issue.record("expected \(E.self) to be thrown", sourceLocation: sourceLocation)
        return nil
    } catch let e as E {
        if let contains {
            let text = String(describing: e)
            #expect(text.contains(contains), "\"\(text)\" does not contain \"\(contains)\"", sourceLocation: sourceLocation)
        }
        return e
    } catch {
        Issue.record("expected \(E.self), got \(type(of: error)): \(error)", sourceLocation: sourceLocation)
        return nil
    }
}

/// A clock tests advance by hand (`FakeClock`).
final class FakeClock: @unchecked Sendable {
    private let lock = NSLock()
    private var _now: Double
    init(_ now: Double = 1000) { _now = now }
    var now: Double {
        get { lock.withLock { _now } }
        set { lock.withLock { _now = newValue } }
    }
    var source: @Sendable () -> Double { { [self] in self.now } }
}

/// Hands out tokens in order and counts calls (`CountingProvider`).
final class CountingProvider: AccessTokenProvider, @unchecked Sendable {
    private let lock = NSLock()
    private let tokens: [AccessToken]
    private var _calls = 0
    private var _forces: [Bool] = []

    init(_ tokens: [AccessToken]) { self.tokens = tokens }

    var calls: Int { lock.withLock { _calls } }
    var forces: [Bool] { lock.withLock { _forces } }

    func callAsFunction(forceRefresh: Bool) async throws -> AccessToken {
        lock.withLock {
            defer { _calls += 1 }
            _forces.append(forceRefresh)
            return tokens[min(_calls, tokens.count - 1)]
        }
    }
}

/// Whether the process runs as root (which bypasses POSIX mode bits).
var runningAsRoot: Bool { getuid() == 0 }
