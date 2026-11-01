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
    let environment: [String: String]
    let explicitBaseURL: Bool

    /// Creates a client.
    ///
    /// Credentials resolve in this order: an explicit `apiKey` / `authToken` argument, then the
    /// `ANTHROPIC_API_KEY` and `ANTHROPIC_AUTH_TOKEN` environment variables.
    ///
    /// - Parameters:
    ///   - environment: The environment variables to read (defaults to the process environment).
    public init(apiKey: String? = nil, authToken: String? = nil, webhookKey: String? = nil, baseURL: String? = nil,
                timeout: Timeout? = nil, maxRetries: Int = DEFAULT_MAX_RETRIES, defaultHeaders: Headers? = nil,
                defaultQuery: Query? = nil, transport: HTTPTransport? = nil, middleware: [Middleware]? = nil,
                environment: [String: String] = ProcessInfo.processInfo.environment) throws
    {
        let passed = [apiKey, authToken].compactMap { $0 }
        if passed.count > 1 {
            throw ValueError("Pass at most one of `api_key=`, or `auth_token=`. Received `api_key=`, `auth_token=`.")
        }
        var apiKey = apiKey
        var authToken = authToken
        if passed.isEmpty {
            let envKey = environment["ANTHROPIC_API_KEY"].flatMap { $0.isEmpty ? nil : $0 }
            let envToken = environment["ANTHROPIC_AUTH_TOKEN"].flatMap { $0.isEmpty ? nil : $0 }
            if let envKey { apiKey = envKey } else { authToken = envToken }
        }
        self.apiKey = apiKey
        self.authToken = authToken
        self.webhookKey = webhookKey ?? environment["ANTHROPIC_WEBHOOK_SIGNING_KEY"]
        self.environment = environment

        var base = baseURL
        if base == nil { base = environment["ANTHROPIC_BASE_URL"] }
        self.explicitBaseURL = base != nil
        let resolvedBase = base ?? "https://api.anthropic.com"
        guard let url = URL(string: resolvedBase) else { throw ValueError("Invalid base URL: \(resolvedBase)") }

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

    /// Copies a client, replacing the options given (`copy` / `with_options`).
    open func copy(apiKey: String? = nil, authToken: String? = nil, webhookKey: String? = nil, baseURL: String? = nil,
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

        var key = apiKey
        var token = authToken
        if key == nil && token == nil {
            key = self.apiKey
            token = key == nil ? self.authToken : nil
        }
        var env = environment
        env.removeValue(forKey: "ANTHROPIC_CUSTOM_HEADERS")
        let client = try Anthropic(
            apiKey: key, authToken: token, webhookKey: webhookKey ?? self.webhookKey,
            baseURL: baseURL ?? self.baseURL.absoluteString, timeout: timeout ?? (timeoutOverridden ? self.timeout : nil),
            maxRetries: maxRetries ?? self.maxRetries, defaultHeaders: headers, defaultQuery: params,
            transport: transport ?? self.transport, middleware: middleware ?? self.middleware, environment: env)
        client.timeoutOverridden = self.timeoutOverridden || timeout != nil
        client.sleeper = self.sleeper
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
        ], customHeaders)
    }

    open override func validateHeaders(_ headers: HTTPHeaders, omitted: Set<String>) throws {
        if headers["Authorization"] != nil || headers["X-Api-Key"] != nil { return }
        if omitted.contains("authorization") || omitted.contains("x-api-key") { return }
        throw ArgumentTypeError(
            "\"Could not resolve authentication method. Expected one of api_key, auth_token, or credentials to be set. Or for the `Authorization` header to be explicitly omitted\""
        )
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
