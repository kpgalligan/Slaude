import Foundation

/// The version of this SDK. It tracks the version of the Python SDK it is transformed from.
public let ANTHROPIC_SDK_VERSION = "2.3.0"

/// The Claude API client (`anthropic.AsyncAnthropic`).
///
/// ```swift
/// let client = try Anthropic()   // reads ANTHROPIC_API_KEY
/// let message = try await client.messages.create(
///     maxTokens: 1024,
///     messages: [MessageParam(content: "Hello, Claude", role: .user)],
///     model: "claude-opus-4-5"
/// )
/// ```
open class Anthropic: BaseClient, @unchecked Sendable {
    public internal(set) var apiKey: String?
    public internal(set) var authToken: String?
    public let webhookKey: String?
    /// The access-token provider requests authenticate with, when the client uses one: passed as
    /// `credentials:`, built from `config:` / `profile:`, or found by `defaultCredentials`.
    public internal(set) var credentials: (any AccessTokenProvider)?
    let environment: [String: String]
    let explicitBaseURL: Bool
    /// Caches the provider's token; shared with copies on the same provider and deployment.
    var tokenCache: TokenCache?
    var customAuth: AccessTokenAuth?
    /// Headers that came with the config or profile (e.g. `anthropic-workspace-id`).
    var credentialHeaders: [String: String] = [:]
    /// The base URL when the caller did not choose one (`nil` when they did).
    var unchosenBaseURL: URL?

    /// Whether this is the base `Anthropic` class rather than a subclass with its own auth
    /// (`_is_base_client`): only the base class runs the credential chain.
    var isBaseClient: Bool { type(of: self) == Anthropic.self }

    /// Creates a client.
    ///
    /// Credentials resolve in this order (first match wins):
    ///
    /// 1. An explicit argument — `apiKey:`, `authToken:`, `credentials:`, `config:`, or `profile:`.
    ///    When one of these is passed, environment variables are not consulted for credentials.
    /// 2. The `ANTHROPIC_API_KEY`, then `ANTHROPIC_AUTH_TOKEN` environment variables.
    /// 3. `ANTHROPIC_PROFILE` — loads the named profile from `<config_dir>/configs/<profile>.json`.
    /// 4. Workload identity federation variables — `ANTHROPIC_IDENTITY_TOKEN[_FILE]` +
    ///    `ANTHROPIC_FEDERATION_RULE_ID` + `ANTHROPIC_ORGANIZATION_ID`.
    /// 5. The active profile on disk — the profile named by `<config_dir>/active_config`, or `default`.
    ///
    /// `ANTHROPIC_CONFIG_DIR` sets `<config_dir>`; it does not select a profile. The credential
    /// arguments are mutually exclusive: passing more than one throws `ValueError`.
    ///
    /// If `ANTHROPIC_API_KEY` / `ANTHROPIC_AUTH_TOKEN` is set alongside a profile or federation
    /// configuration, the static credential wins and a one-shot warning is logged
    /// (`CredentialsLog`); likewise when both are set (the API key wins).
    ///
    /// - Parameters:
    ///   - credentials: A provider minting the Bearer token each request is sent with.
    ///   - config: An in-memory profile config (see `InMemoryConfig`).
    ///   - profile: The name of a profile under the config directory (see `CredentialsFile`).
    ///   - transport: The HTTP transport; providers the client builds (from `config:`, `profile:`
    ///     or the environment) exchange tokens through it too.
    ///   - environment: The environment variables to read (defaults to the process environment).
    public init(apiKey: String? = nil, authToken: String? = nil, credentials: (any AccessTokenProvider)? = nil,
                config: [String: JSONValue]? = nil, profile: String? = nil, webhookKey: String? = nil, baseURL: String? = nil,
                timeout: Timeout? = nil, maxRetries: Int = DEFAULT_MAX_RETRIES, defaultHeaders: Headers? = nil,
                defaultQuery: Query? = nil, transport: HTTPTransport? = nil, middleware: [Middleware]? = nil,
                environment: [String: String] = ProcessInfo.processInfo.environment) throws
    {
        let isBase = Self.self == Anthropic.self
        let env = CredentialEnvironment(environment)
        var apiKey = apiKey
        var authToken = authToken
        // Explicit arguments are total: if any credential argument was passed, the credential
        // environment variables are not read.
        if try !Self.hasExplicitCredential(apiKey: apiKey, authToken: authToken, credentials: credentials, config: config, profile: profile) {
            (apiKey, authToken) = Self.staticCredentialFromEnv(env, warn: isBase)
        }
        self.apiKey = apiKey
        self.authToken = authToken
        self.webhookKey = webhookKey ?? environment["ANTHROPIC_WEBHOOK_SIGNING_KEY"]
        self.environment = environment

        // base URL precedence: argument > ANTHROPIC_BASE_URL > profile config > default.
        var base = baseURL
        if base == nil { base = environment["ANTHROPIC_BASE_URL"] }
        let isExplicitBaseURL = base != nil
        self.explicitBaseURL = isExplicitBaseURL
        var resolvedBase = base ?? "https://api.anthropic.com"

        let transport = transport ?? URLSessionTransport()
        var credentials = credentials
        var credentialHeaders: [String: String] = [:]
        var credentialBaseURL: String? = nil
        if let config {
            let inMemory = try InMemoryConfig(config, transport: transport, environment: env)
            credentials = inMemory
            credentialHeaders = try inMemory.extraHeaders()
            credentialBaseURL = try inMemory.resolvedBaseURL
        } else if let profile {
            let file = try CredentialsFile(profile: profile, transport: transport, environment: env)
            credentials = file
            credentialHeaders = try file.extraHeaders()
            credentialBaseURL = try file.resolvedBaseURL
        }
        if credentials == nil && apiKey == nil && authToken == nil && isBase {
            if let result = try defaultCredentials(baseURL: resolvedBase, environment: env, transport: transport) {
                credentials = result.provider
                credentialHeaders = result.extraHeaders
                credentialBaseURL = result.baseURL
            }
        }
        self.credentialHeaders = credentialHeaders
        if !isExplicitBaseURL, let credentialBaseURL, !credentialBaseURL.isEmpty { resolvedBase = credentialBaseURL }
        guard let url = URL(string: resolvedBase) else { throw ValueError("Invalid base URL: \(resolvedBase)") }
        self.unchosenBaseURL = isExplicitBaseURL ? nil : BaseClient.enforceTrailingSlash(url)

        // A provider bound to a deployment exchanges tokens through the client's own base URL.
        if let bound = credentials as? any BaseURLBoundProvider { credentials = try bound.forBaseURL(resolvedBase) }
        self.credentials = credentials
        let cache = credentials.map { TokenCache($0) }
        self.tokenCache = cache
        self.customAuth = cache.map { AccessTokenAuth($0) }

        var headers = defaultHeaders
        if let custom = environment["ANTHROPIC_CUSTOM_HEADERS"] {
            var parsed: Headers = [:]
            for line in custom.split(separator: "\n", omittingEmptySubsequences: false) {
                if let colon = line.firstIndex(of: ":") {
                    parsed[line[..<colon].trimmingCharacters(in: .whitespaces)] = .value(line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces))
                }
            }
            headers = mergeHeaderLayers(parsed, defaultHeaders)
        }

        super.init(version: ANTHROPIC_SDK_VERSION, baseURL: url, maxRetries: maxRetries, timeout: timeout,
                   customHeaders: headers, customQuery: defaultQuery, transport: transport, middleware: middleware)
    }

    /// Whether one of the credential arguments was passed; throws `ValueError` for more than one
    /// (`has_explicit_credential`).
    static func hasExplicitCredential(apiKey: String?, authToken: String?, credentials: (any AccessTokenProvider)?,
                                      config: [String: JSONValue]?, profile: String?) throws -> Bool
    {
        let arguments: [(String, Bool)] = [
            ("api_key", apiKey != nil), ("auth_token", authToken != nil), ("credentials", credentials != nil),
            ("config", config != nil), ("profile", profile != nil),
        ]
        let names = arguments.map { "`\($0.0)=`" }
        let passed = arguments.filter(\.1).map { "`\($0.0)=`" }
        if passed.count > 1 {
            throw ValueError(
                "Pass at most one of \(names.dropLast().joined(separator: ", ")), or \(names.last!). Received \(passed.joined(separator: ", ")).")
        }
        return !passed.isEmpty
    }

    /// The `(apiKey, authToken)` the environment supplies; at most one is set
    /// (`static_credential_from_env`). With `warn`, logs what that credential shadows: the auth
    /// token, or the profile / federation configuration auto-discovery would have used.
    static func staticCredentialFromEnv(_ env: CredentialEnvironment, warn: Bool) -> (String?, String?) {
        let apiKey = env.nonEmpty("ANTHROPIC_API_KEY")
        let authToken = env.nonEmpty("ANTHROPIC_AUTH_TOKEN")
        if warn && apiKey != nil && authToken != nil { warnEnvAPIKeyShadowsEnvAuthToken() }
        if warn && (apiKey != nil || authToken != nil) && hasAutoDiscoverableCredentials(env) {
            warnEnvStaticShadowsAutoDiscovery(apiKey != nil ? "ANTHROPIC_API_KEY" : "ANTHROPIC_AUTH_TOKEN")
        }
        return apiKey != nil ? (apiKey, nil) : (nil, authToken)
    }

    /// Whether a `copy()` stays on this client's deployment (`_keeps_base_url`).
    static func keepsBaseURL(_ current: URL, _ requested: String?) -> Bool {
        guard let requested else { return true }
        return trimTrailingSlashes(requested) == trimTrailingSlashes(current.absoluteString)
    }

    /// Copies a client, replacing the options given (`copy` / `with_options`).
    ///
    /// A credential passed here (`apiKey:`, `authToken:`, `credentials:`, `config:`, or `profile:`)
    /// replaces this client's credential, whichever kind that is; passing more than one throws
    /// `ValueError`. A base URL and headers that came with this client's config or profile go with
    /// that credential. The token cache is shared with the copy only while the provider and base
    /// URL are unchanged. `credentials: .some(nil)` drops this client's provider.
    open func copy(apiKey: String? = nil, authToken: String? = nil, credentials: (any AccessTokenProvider)?? = nil,
                   config: [String: JSONValue]? = nil, profile: String? = nil, webhookKey: String? = nil, baseURL: String? = nil,
                   timeout: Timeout? = nil, maxRetries: Int? = nil, defaultHeaders: Headers? = nil,
                   setDefaultHeaders: Headers? = nil, defaultQuery: Query? = nil, setDefaultQuery: Query? = nil,
                   transport: HTTPTransport? = nil, middleware: [Middleware]? = nil) throws -> Anthropic
    {
        if defaultHeaders != nil && setDefaultHeaders != nil {
            throw ValueError("The `default_headers` and `set_default_headers` arguments are mutually exclusive")
        }
        if defaultQuery != nil && setDefaultQuery != nil {
            throw ValueError("The `default_query` and `set_default_query` arguments are mutually exclusive")
        }
        var headers = customHeaders
        if let defaultHeaders { headers = mergeHeaders(headers, defaultHeaders) } else if let setDefaultHeaders { headers = setDefaultHeaders }
        var params = customQuery
        if let defaultQuery { params.merge(defaultQuery) { $1 } } else if let setDefaultQuery { params = setDefaultQuery }

        let credentialsGiven = credentials != nil
        var resolvedCredentials: (any AccessTokenProvider)? = credentials ?? nil
        var key = apiKey
        var token = authToken
        var keepsCredential = false
        if (key ?? "").isEmpty && (token ?? "").isEmpty && resolvedCredentials == nil && config == nil && profile == nil {
            keepsCredential = !credentialsGiven
            // Inherit only the credential this client sends.
            key = self.apiKey
            token = key == nil ? self.authToken : nil
            if !credentialsGiven && key == nil && token == nil && isBaseClient { resolvedCredentials = self.credentials }
        }
        let inheritsProvider = !credentialsGiven && resolvedCredentials != nil
        let sharesTokenCache = inheritsProvider && Self.keepsBaseURL(self.baseURL, baseURL)

        // A host the caller chose stays; otherwise a new credential brings its own, or the default.
        var inheritedBaseURL: String? = nil
        if keepsCredential || self.baseURL != unchosenBaseURL { inheritedBaseURL = self.baseURL.absoluteString }

        var env = environment
        env.removeValue(forKey: "ANTHROPIC_CUSTOM_HEADERS")
        let client = try Anthropic(
            apiKey: key, authToken: token, credentials: resolvedCredentials, config: config, profile: profile,
            webhookKey: webhookKey ?? self.webhookKey, baseURL: baseURL ?? inheritedBaseURL,
            timeout: timeout ?? (timeoutOverridden ? self.timeout : nil),
            maxRetries: maxRetries ?? self.maxRetries, defaultHeaders: headers, defaultQuery: params,
            transport: transport ?? self.transport, middleware: middleware ?? self.middleware, environment: env)
        if sharesTokenCache {
            client.tokenCache = tokenCache
            client.customAuth = tokenCache.map { AccessTokenAuth($0) }
        }
        client.timeoutOverridden = self.timeoutOverridden || timeout != nil
        client.sleeper = self.sleeper
        if keepsCredential {
            client.credentialHeaders = credentialHeaders
            client.unchosenBaseURL = unchosenBaseURL
        }
        return client
    }

    /// Alias for `copy`, for inline use: `client.withOptions(timeout: 10).messages.create(...)`.
    public func withOptions(timeout: Timeout? = nil, maxRetries: Int? = nil, defaultHeaders: Headers? = nil,
                            defaultQuery: Query? = nil, middleware: [Middleware]? = nil) throws -> Anthropic
    {
        try copy(timeout: timeout, maxRetries: maxRetries, defaultHeaders: defaultHeaders, defaultQuery: defaultQuery,
                 middleware: middleware)
    }

    /// A copy of this client with `middleware` appended after its own.
    public func withMiddleware(_ middleware: Middleware...) throws -> Anthropic {
        try copy(middleware: self.middleware + middleware)
    }

    open override var querystring: Querystring { Querystring(arrayFormat: .brackets) }

    open override var authHeaders: Headers {
        var h: Headers = [:]
        if let authToken { h["Authorization"] = .value("Bearer \(authToken)") }
        if let apiKey { h["Authorization"] = .value("Bearer \(apiKey)") }
        return h
    }

    open override var userAgent: String { "Anthropic/Swift \(version)" }

    open override var defaultHeaders: Headers {
        mergeHeaderLayers(super.defaultHeaders, [
            "X-Stainless-Async": "async:swift-concurrency",
            "anthropic-version": .value(ANTHROPIC_API_VERSION),
        ], credentialHeaders.mapValues { HeaderValue.value($0) }, customHeaders)
    }

    open override func validateHeaders(_ headers: HTTPHeaders, omitted: Set<String>) throws {
        // With a token cache, `authenticate(_:)` adds the Bearer token after validation.
        if tokenCache != nil && (headers["X-Api-Key"] ?? "").isEmpty && (headers["Authorization"] ?? "").isEmpty { return }
        if headers["Authorization"] != nil || headers["X-Api-Key"] != nil { return }
        if omitted.contains("authorization") || omitted.contains("x-api-key") { return }
        throw ArgumentTypeError(
            "\"Could not resolve authentication method. Expected one of api_key, auth_token, or credentials to be set. Or for the `Authorization` header to be explicitly omitted\""
        )
    }

    /// Adds the credentials provider's Bearer token (`custom_auth`).
    open override func authenticate(_ request: inout HTTPRequest) async throws {
        try await super.authenticate(&request)
        try await customAuth?.apply(to: &request)
    }

    /// On a 401 with a token cache, invalidates it and retries once, so the request is re-sent with
    /// a freshly minted token. The single-shot guard relies on `x-stainless-retry-count` being `"0"`
    /// on the first attempt; if a caller omits that header the guard fails safe (no retry).
    open override func shouldRetry(_ response: HTTPResponse) -> Bool {
        if response.statusCode == 401, let tokenCache {
            tokenCache.invalidate()
            if response.request.headers["x-stainless-retry-count"] == "0" { return true }
        }
        return super.shouldRetry(response)
    }

    /// Closes the transport, then the credentials provider.
    open override func close() async {
        await super.close()
        await credentials?.close()
    }

    open override func prepareOptions(_ options: FinalRequestOptions) async throws -> FinalRequestOptions {
        var options = try await super.prepareOptions(options)
        // Per-request header params arrive as `.omit` when unset, which would strip a value the client
        // itself sends; drop those so the client-level header survives (`_keep_client_header_params`).
        if let headers = options.headers {
            let clientLevel: Set<String> = ["anthropic-workspace-id", "anthropic-user-profile-id"]
            options.headers = headers.filter { !(clientLevel.contains($0.key.lowercased()) && $0.value == .omit) }
        }
        return options
    }
}
