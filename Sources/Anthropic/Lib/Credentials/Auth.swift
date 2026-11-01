import Foundation

/// Port of `anthropic/lib/credentials/_auth.py`.

/// The credentials subsystem's log (the Python `anthropic` logger's credential records).
///
/// Records go to a process-wide handler (by default, warnings are written to standard error).
/// Replace it with `setHandler(_:)`.
public enum CredentialsLog {
    public enum Level: Int, Sendable, Comparable {
        case debug = 10, info = 20, warning = 30, error = 40
        public static func < (a: Level, b: Level) -> Bool { a.rawValue < b.rawValue }
    }

    public typealias Handler = @Sendable (Level, String) -> Void

    nonisolated(unsafe) private static var handler: Handler = { level, message in
        if level >= .warning { FileHandle.standardError.write(Data("anthropic: \(message)\n".utf8)) }
    }
    private static let lock = NSLock()

    /// Replaces the process-wide handler.
    public static func setHandler(_ h: @escaping Handler) { lock.withLock { handler = h } }

    /// Overrides the handler for the current task tree (used by tests to capture records).
    @TaskLocal static var taskHandler: Handler?

    /// Overrides the one-shot warning registry for the current task tree (tests reset it this way).
    @TaskLocal static var taskWarnOnceRegistry: WarnOnceRegistry?

    static func log(_ level: Level, _ message: String) {
        if let h = taskHandler {
            h(level, message)
            return
        }
        let h = lock.withLock { handler }
        h(level, message)
    }

    static func debug(_ message: String) { log(.debug, message) }
    static func warning(_ message: String) { log(.warning, message) }

    /// Emits a warning at most once per `key` per process (`_warn_once`).
    static func warnOnce(_ key: String, _ message: String) {
        let registry = taskWarnOnceRegistry ?? WarnOnceRegistry.shared
        guard registry.insert(key) else { return }
        warning(message)
    }
}

/// The keys `CredentialsLog.warnOnce` has already warned for.
final class WarnOnceRegistry: @unchecked Sendable {
    static let shared = WarnOnceRegistry()
    private let lock = NSLock()
    private var seen: Set<String> = []

    init() {}

    /// Records `key`; false if it was already recorded.
    func insert(_ key: String) -> Bool { lock.withLock { seen.insert(key).inserted } }
}

/// Warns that an `ANTHROPIC_API_KEY` / `ANTHROPIC_AUTH_TOKEN` from the environment shadows the
/// SDK's profile / federation auto-discovery.
func warnEnvStaticShadowsAutoDiscovery(_ envVar: String) {
    CredentialsLog.warnOnce(
        "env-shadow:\(envVar)",
        "\(envVar) is set and takes precedence over the SDK's profile / federation auto-discovery; unset \(envVar) to use the auto-discovered credential."
    )
}

/// Warns that `ANTHROPIC_AUTH_TOKEN` is ignored because `ANTHROPIC_API_KEY` is set as well.
func warnEnvAPIKeyShadowsEnvAuthToken() {
    CredentialsLog.warnOnce(
        "env-shadow:ANTHROPIC_API_KEY:ANTHROPIC_AUTH_TOKEN",
        "Anthropic: ANTHROPIC_API_KEY and ANTHROPIC_AUTH_TOKEN are both set. Using ANTHROPIC_API_KEY."
    )
}

/// Adds `Authorization: Bearer <token>` plus the OAuth beta header to a request, with proactive
/// refresh handled by `TokenCache` (`AccessTokenAuth`).
///
/// If the outgoing request already carries an `Authorization` or `X-Api-Key` header, this is a no-op.
public struct AccessTokenAuth: Sendable {
    public let tokenCache: TokenCache

    public init(_ tokenCache: TokenCache) { self.tokenCache = tokenCache }

    static func hasStaticCredential(_ request: HTTPRequest) -> Bool {
        !(request.headers["X-Api-Key"] ?? "").isEmpty || !(request.headers["Authorization"] ?? "").isEmpty
    }

    static func apply(_ request: inout HTTPRequest, token: String) {
        request.headers["Authorization"] = "Bearer \(token)"
        let existing = request.headers["anthropic-beta"] ?? ""
        // Whole flag names, so `oauth-2025-04-20` never matches a future `oauth-2025-04-20b`.
        var flags = existing.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        if !flags.contains(OAUTH_API_BETA_HEADER) {
            flags.append(OAUTH_API_BETA_HEADER)
            request.headers["anthropic-beta"] = flags.joined(separator: ",")
        }
    }

    /// Authenticates `request` in place.
    public func apply(to request: inout HTTPRequest) async throws {
        if Self.hasStaticCredential(request) { return }
        let token = try await tokenCache.getToken()
        Self.apply(&request, token: token)
    }
}
