import Foundation

/// Port of `anthropic/lib/credentials/_types.py`.

/// An Anthropic API access token with optional expiry (`AccessToken`).
///
/// `expiresAt` is unix seconds; `nil` means no expiry information (the token is treated as
/// never-expiring by `TokenCache`). Exactly `0` means the provider does its own caching, so the
/// client asks it again before every request, concurrently if requests are concurrent. Any other
/// past value is an expired token and is refreshed one call at a time.
///
/// `description`, `debugDescription` and the reflection mirror mask the token (at most its last
/// four characters), so logging or dumping an `AccessToken` never exposes the raw value.
public struct AccessToken: Sendable, Hashable, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    public let token: String
    public let expiresAt: Int?

    public init(token: String, expiresAt: Int? = nil) {
        self.token = token
        self.expiresAt = expiresAt
    }

    var maskedToken: String {
        token.unicodeScalars.count >= 12 ? "..." + String(String.UnicodeScalarView(token.unicodeScalars.suffix(4))) : "**********"
    }

    public var description: String {
        "AccessToken(token='\(maskedToken)', expires_at=\(expiresAt.map(String.init) ?? "None"))"
    }

    public var debugDescription: String { description }

    public var customMirror: Mirror {
        Mirror(self, children: ["token": maskedToken, "expiresAt": expiresAt as Any], displayStyle: .struct)
    }
}

/// Mints or returns an access token (`AccessTokenProvider` / `AsyncAccessTokenProvider`).
///
/// Re-invoking the provider IS the refresh mechanism — providers have no separate `refresh()`
/// method. Providers may be stateful (hold config / paths) but the *cache* lives in `TokenCache`.
///
/// `forceRefresh` is set by `TokenCache.invalidate()` after a 401: providers with on-disk caches
/// (`user_oauth`, `oidc_federation` profiles) bypass their freshness short-circuit and always fetch
/// fresh when it is true. Providers without a cache ignore it.
///
/// A provider that holds resources (an HTTP transport it created) releases them in `close()`;
/// `Anthropic.close()` calls it.
public protocol AccessTokenProvider: Sendable {
    func callAsFunction(forceRefresh: Bool) async throws -> AccessToken
    /// Releases any resources the provider owns. The default does nothing.
    func close() async
}

extension AccessTokenProvider {
    public func close() async {}

    /// Calls the provider without forcing a refresh.
    public func callAsFunction() async throws -> AccessToken { try await self(forceRefresh: false) }
}

/// A provider whose token exchange targets a specific deployment (`BaseURLBoundProvider`).
///
/// The client calls `forBaseURL` with its own base URL at construction. Providers that don't
/// implement this resolve their own exchange endpoint and are used as-is.
public protocol BaseURLBoundProvider: AccessTokenProvider {
    /// Returns the provider a client with `baseURL` should exchange through: either `self`, bound
    /// to `baseURL`, or — if another client already bound `self` to a different deployment — a
    /// separate provider bound to `baseURL`, so that client's binding is left alone.
    func forBaseURL(_ baseURL: String) throws -> any AccessTokenProvider
}

/// An access-token provider built from a closure.
public struct AccessTokenProviderFunction: AccessTokenProvider {
    let body: @Sendable (Bool) async throws -> AccessToken
    let onClose: (@Sendable () async -> Void)?

    /// - Parameters:
    ///   - body: Called with `forceRefresh` to mint a token.
    ///   - onClose: Called by `close()`.
    public init(onClose: (@Sendable () async -> Void)? = nil, _ body: @escaping @Sendable (_ forceRefresh: Bool) async throws -> AccessToken) {
        self.body = body
        self.onClose = onClose
    }

    public func callAsFunction(forceRefresh: Bool) async throws -> AccessToken { try await body(forceRefresh) }
    public func close() async { await onClose?() }
}

/// Returns the raw external JWT string (`IdentityTokenProvider`), used as the
/// `identityTokenProvider` of `WorkloadIdentityCredentials`.
public protocol IdentityTokenProvider: Sendable {
    func callAsFunction() async throws -> String
}

/// An identity-token provider built from a closure.
public struct IdentityTokenProviderFunction: IdentityTokenProvider {
    let body: @Sendable () async throws -> String
    public init(_ body: @escaping @Sendable () async throws -> String) { self.body = body }
    public func callAsFunction() async throws -> String { try await body() }
}

/// Bundles an `AccessTokenProvider` with config-level metadata (`CredentialResult`).
///
/// Returned by `defaultCredentials`. `extraHeaders` are set on every API request (e.g.
/// `anthropic-workspace-id`). `baseURL` is the API host the resolved profile is configured for; the
/// client adopts it only when the caller did not choose one (`baseURL:` or `ANTHROPIC_BASE_URL`).
public struct CredentialResult: Sendable {
    public let provider: any AccessTokenProvider
    public let extraHeaders: [String: String]
    public let baseURL: String?

    public init(provider: any AccessTokenProvider, extraHeaders: [String: String] = [:], baseURL: String? = nil) {
        self.provider = provider
        self.extraHeaders = extraHeaders
        self.baseURL = baseURL
    }
}

/// Where the credentials subsystem reads environment variables from.
///
/// The Python SDK reads `os.environ` directly; here every reader takes an environment so callers
/// (and tests) control it. `.process` reads the live process environment on every lookup, so a
/// rotated variable is picked up; a dictionary is a fixed snapshot.
public struct CredentialEnvironment: Sendable, ExpressibleByDictionaryLiteral {
    let lookup: @Sendable (String) -> String?

    public init(_ lookup: @escaping @Sendable (String) -> String?) { self.lookup = lookup }

    public init(_ values: [String: String]) { self.lookup = { values[$0] } }

    public init(dictionaryLiteral elements: (String, String)...) {
        var d: [String: String] = [:]
        for (k, v) in elements { d[k] = v }
        self.init(d)
    }

    /// The live process environment.
    public static var process: CredentialEnvironment {
        CredentialEnvironment { ProcessInfo.processInfo.environment[$0] }
    }

    public subscript(name: String) -> String? { lookup(name) }

    /// The value of `name` unless it is unset or empty (Python's `os.environ.get(name) or None`).
    func nonEmpty(_ name: String) -> String? {
        guard let v = lookup(name), !v.isEmpty else { return nil }
        return v
    }
}
