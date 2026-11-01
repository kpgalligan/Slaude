import Foundation

/// The Claude Platform on AWS client (`anthropic.lib.aws.AsyncAnthropicAWS`).
///
/// It is the first-party client pointed at `https://aws-external-anthropic.{region}.api.aws`, with
/// every request scoped to a workspace (`anthropic-workspace-id`) and authenticated either with an
/// API key (`Authorization: Bearer`) or with AWS SigV4 (service `aws-external-anthropic`).
///
/// Auth precedence: an `apiKey` argument, explicit `awsAccessKey`/`awsSecretKey`, an `awsProfile`
/// argument, the `ANTHROPIC_AWS_API_KEY` environment variable, then the default AWS credential
/// chain (see `AWSDefaultCredentialsChain`).
open class AnthropicAWS: Anthropic, @unchecked Sendable {
    open override var otelPlatform: String? { "aws" }

    public let awsAccessKey: String?
    public let awsSecretKey: String?
    public let awsRegion: String?
    public let awsProfile: String?
    public let awsSessionToken: String?
    public let workspaceID: String?
    public let useSigV4: Bool
    public let skipAuth: Bool
    let credentialsProvider: AWSCredentialsProvider?
    let resolver: AWSCredentialsResolver
    let awsEnvironment: [String: String]
    /// The SigV4 service name.
    open var signingServiceName: String { "aws-external-anthropic" }

    public init(apiKey: String? = nil, awsAccessKey: String? = nil, awsSecretKey: String? = nil, awsRegion: String? = nil,
                awsProfile: String? = nil, awsSessionToken: String? = nil, workspaceID: String? = nil, skipAuth: Bool = false,
                baseURL: String? = nil, timeout: Timeout? = nil, maxRetries: Int = DEFAULT_MAX_RETRIES,
                defaultHeaders: Headers? = nil, defaultQuery: Query? = nil, transport: HTTPTransport? = nil,
                middleware: [Middleware]? = nil, authToken: String? = nil, webhookKey: String? = nil,
                credentialsProvider: AWSCredentialsProvider? = nil,
                openTelemetry: OpenTelemetryOptions? = nil,
                environment: [String: String] = ProcessInfo.processInfo.environment) throws
    {
        try AWSConfig.validateCredentials(awsAccessKey: awsAccessKey, awsSecretKey: awsSecretKey)

        let useSigV4: Bool
        let resolvedAPIKey: String?
        if skipAuth {
            useSigV4 = false
            resolvedAPIKey = nil
        } else {
            useSigV4 = AWSConfig.resolveAuthMode(apiKey: apiKey, awsAccessKey: awsAccessKey, awsSecretKey: awsSecretKey,
                                                 awsProfile: awsProfile, environment: environment)
            resolvedAPIKey = AWSConfig.resolveAPIKey(apiKey: apiKey, useSigV4: useSigV4, environment: environment)
        }
        let region = AWSConfig.resolveRegion(awsRegion, environment: environment)
        if useSigV4 && region == nil {
            throw AnthropicError(
                "No AWS region was provided. Set the `aws_region` argument or the `AWS_REGION`/`AWS_DEFAULT_REGION` environment variable."
            )
        }
        let workspace: String?
        if skipAuth {
            workspace = workspaceID
        } else {
            guard let w = AWSConfig.resolveWorkspaceID(workspaceID, environment: environment) else {
                throw AnthropicError(
                    "No workspace ID found. Set the `workspace_id` argument or the `ANTHROPIC_AWS_WORKSPACE_ID` environment variable."
                )
            }
            workspace = w
        }
        guard let resolvedBaseURL = AWSConfig.resolveBaseURL(baseURL, region: region, environment: environment) else {
            throw AnthropicError(
                "No AWS region was provided and no base_url was given. Set the `aws_region` argument, the `AWS_REGION`/`AWS_DEFAULT_REGION` environment variable, or provide a `base_url` directly."
            )
        }

        self.awsAccessKey = awsAccessKey
        self.awsSecretKey = awsSecretKey
        self.awsRegion = region
        self.awsProfile = awsProfile
        self.awsSessionToken = awsSessionToken
        self.workspaceID = workspace
        self.useSigV4 = useSigV4
        self.skipAuth = skipAuth
        self.credentialsProvider = credentialsProvider
        self.awsEnvironment = environment
        self.resolver = AWSCredentialsResolver(accessKey: awsAccessKey, secretKey: awsSecretKey, sessionToken: awsSessionToken,
                                               profile: awsProfile, provider: credentialsProvider, environment: environment,
                                               transport: nil)
        try super.init(apiKey: resolvedAPIKey ?? "", webhookKey: webhookKey, baseURL: resolvedBaseURL, timeout: timeout,
                       maxRetries: maxRetries, defaultHeaders: defaultHeaders, defaultQuery: defaultQuery, transport: transport,
                       middleware: middleware, openTelemetry: openTelemetry, environment: environment)
        // Only explicit credentials apply: undo the base client's ambient ANTHROPIC_API_KEY /
        // ANTHROPIC_AUTH_TOKEN fallback. `authToken` is set here, not passed up, because the base
        // client rejects it next to an API key.
        self.apiKey = resolvedAPIKey
        self.authToken = authToken
    }

    open override var defaultHeaders: Headers {
        var headers = super.defaultHeaders
        if let workspaceID { headers = mergeHeaderLayers(headers, ["anthropic-workspace-id": .value(workspaceID)]) }
        return headers
    }

    /// `{**_bearer_auth, **_api_key_auth}` with the API-key half off under SigV4 / `skipAuth`.
    open override var authHeaders: Headers {
        var h: Headers = [:]
        if let authToken { h["Authorization"] = .value("Bearer \(authToken)") }
        if !useSigV4 && !skipAuth, let apiKey { h["Authorization"] = .value("Bearer \(apiKey)") }
        return h
    }

    open override func validateHeaders(_ headers: HTTPHeaders, omitted: Set<String>) throws {
        if useSigV4 || skipAuth { return }
        try super.validateHeaders(headers, omitted: omitted)
    }

    open override func prepareOptions(_ options: FinalRequestOptions) async throws -> FinalRequestOptions {
        try rejectActionURLRequest(options, client: "AWS")
        return try await super.prepareOptions(options)
    }

    open override func prepareRequest(_ request: inout HTTPRequest) async throws {
        try await super.prepareRequest(&request)
        guard useSigV4 else { return }
        let credentials = try await resolver.resolve()
        for (name, value) in awsAuthHeaders(method: request.method, url: request.url, headers: request.headers, body: request.body,
                                            credentials: credentials, region: awsRegion ?? "", serviceName: signingServiceName)
        {
            request.headers[name] = value
        }
    }

    open override func copy(apiKey: String? = nil, authToken: String? = nil, credentials: (any AccessTokenProvider)?? = nil,
                            config: [String: JSONValue]? = nil, profile: String? = nil, webhookKey: String? = nil, baseURL: String? = nil,
                            timeout: Timeout? = nil, maxRetries: Int? = nil, defaultHeaders: Headers? = nil,
                            setDefaultHeaders: Headers? = nil, defaultQuery: Query? = nil, setDefaultQuery: Query? = nil,
                            transport: HTTPTransport? = nil, middleware: [Middleware]? = nil,
                            openTelemetry: OpenTelemetryOptions? = nil) throws -> Anthropic
    {
        // The AWS client authenticates with SigV4 (or an API key), not a token provider:
        // `credentials: .some(nil)` (Python's `credentials=None`) is accepted as a no-op, and a
        // real provider is rejected rather than silently ignored.
        if case .some(.some) = credentials {
            throw ArgumentTypeError("AnthropicAWS does not support a `credentials` provider (it authenticates with AWS SigV4).")
        }
        if config != nil || profile != nil {
            throw ArgumentTypeError("AnthropicAWS.copy() does not accept `config` or `profile`")
        }
        let c: AnthropicAWS = try copy(apiKey: apiKey, authToken: authToken, webhookKey: webhookKey, baseURL: baseURL,
                                       timeout: timeout, maxRetries: maxRetries, defaultHeaders: defaultHeaders,
                                       setDefaultHeaders: setDefaultHeaders, defaultQuery: defaultQuery,
                                       setDefaultQuery: setDefaultQuery, transport: transport, middleware: middleware,
                                       awsAccessKey: nil, openTelemetry: openTelemetry)
        return c
    }

    /// Copies the client, replacing the options given (`copy` / `with_options`).
    ///
    /// A region-derived host follows a new `awsRegion` (SigV4 signs for it); a custom base URL is kept.
    public func copy(apiKey: String? = nil, authToken: String? = nil, webhookKey: String? = nil, baseURL: String? = nil,
                     timeout: Timeout? = nil, maxRetries: Int? = nil, defaultHeaders: Headers? = nil,
                     setDefaultHeaders: Headers? = nil, defaultQuery: Query? = nil, setDefaultQuery: Query? = nil,
                     transport: HTTPTransport? = nil, middleware: [Middleware]? = nil, awsAccessKey: String? = nil,
                     awsSecretKey: String? = nil, awsRegion: String? = nil, awsProfile: String? = nil,
                     awsSessionToken: String? = nil, workspaceID: String? = nil, skipAuth: Bool? = nil,
                     credentialsProvider: AWSCredentialsProvider? = nil, openTelemetry: OpenTelemetryOptions? = nil) throws -> AnthropicAWS
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

        var newBaseURL = baseURL
        if newBaseURL == nil, let awsRegion {
            if let derived = AWSConfig.resolveBaseURL(nil, region: self.awsRegion, environment: awsEnvironment),
               let derivedURL = URL(string: derived), BaseClient.enforceTrailingSlash(derivedURL) == self.baseURL
            {
                newBaseURL = AWSConfig.resolveBaseURL(nil, region: awsRegion, environment: awsEnvironment)
            }
        }

        // The base `copy()`: a new credential replaces this client's; otherwise inherit the one it sends.
        var key = apiKey ?? self.apiKey
        var token = authToken
        if key == nil && token == nil {
            key = self.apiKey
            token = key == nil ? self.authToken : nil
        }
        var env = awsEnvironment
        env.removeValue(forKey: "ANTHROPIC_CUSTOM_HEADERS")
        let client = try AnthropicAWS(
            apiKey: key, awsAccessKey: awsAccessKey ?? self.awsAccessKey, awsSecretKey: awsSecretKey ?? self.awsSecretKey,
            awsRegion: awsRegion ?? self.awsRegion, awsProfile: awsProfile ?? self.awsProfile,
            awsSessionToken: awsSessionToken ?? self.awsSessionToken, workspaceID: workspaceID ?? self.workspaceID,
            skipAuth: skipAuth ?? self.skipAuth, baseURL: newBaseURL ?? self.baseURL.absoluteString,
            timeout: timeout ?? (timeoutOverridden ? self.timeout : nil), maxRetries: maxRetries ?? self.maxRetries,
            defaultHeaders: headers, defaultQuery: params, transport: transport ?? self.transport,
            middleware: middleware ?? self.middleware, authToken: token, webhookKey: webhookKey ?? self.webhookKey,
            credentialsProvider: credentialsProvider ?? self.credentialsProvider, openTelemetry: openTelemetry ?? self.openTelemetry,
            environment: env)
        client.timeoutOverridden = self.timeoutOverridden || timeout != nil
        client.sleeper = self.sleeper
        return client
    }

    /// Alias for `copy`, for inline use: `client.withOptions(awsRegion: "us-west-2").messages.create(...)`.
    public func withOptions(timeout: Timeout? = nil, maxRetries: Int? = nil, defaultHeaders: Headers? = nil,
                            defaultQuery: Query? = nil, baseURL: String? = nil, awsAccessKey: String? = nil,
                            awsSecretKey: String? = nil, awsRegion: String? = nil, awsProfile: String? = nil,
                            awsSessionToken: String? = nil, workspaceID: String? = nil, skipAuth: Bool? = nil,
                            openTelemetry: OpenTelemetryOptions? = nil) throws -> AnthropicAWS
    {
        try copy(baseURL: baseURL, timeout: timeout, maxRetries: maxRetries, defaultHeaders: defaultHeaders, defaultQuery: defaultQuery,
                 awsAccessKey: awsAccessKey, awsSecretKey: awsSecretKey, awsRegion: awsRegion, awsProfile: awsProfile,
                 awsSessionToken: awsSessionToken, workspaceID: workspaceID, skipAuth: skipAuth, openTelemetry: openTelemetry)
    }
}

/// `reject_action_url_request`: user-profile action URLs are not available on the AWS client.
func rejectActionURLRequest(_ options: FinalRequestOptions, client: String) throws {
    let path = options.url.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? options.url
    if path.hasPrefix("/v1/user_profiles/") && path.hasSuffix("/action_urls") {
        throw AnthropicError("User profile action URLs are not supported in the \(client) client.")
    }
}
