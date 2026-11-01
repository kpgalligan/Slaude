import Foundation

/// Claude on Amazon Bedrock's Anthropic-compatible "Mantle" endpoint
/// (`anthropic.lib.bedrock.AsyncAnthropicBedrockMantle`).
///
/// It speaks the first-party Messages API at `https://bedrock-mantle.{region}.api.aws/anthropic`,
/// authenticated with an API key (`AWS_BEARER_TOKEN_BEDROCK`, then `ANTHROPIC_AWS_API_KEY`) or
/// SigV4 (service `bedrock-mantle`). Only `messages` and `beta.messages` are available.
open class AnthropicBedrockMantle: BaseClient, @unchecked Sendable {
    public static let defaultServiceName = "bedrock-mantle"
    static let apiKeyEnvVars = ["AWS_BEARER_TOKEN_BEDROCK", "ANTHROPIC_AWS_API_KEY"]
    static let userProfileIDHeader = "anthropic-user-profile-id"
    static let userProfileIDBodyPaths: Set<String> = [
        "/v1/messages", "/v1/messages?beta=true", "/v1/messages/count_tokens", "/v1/messages/count_tokens?beta=true",
    ]

    public let apiKey: String?
    public let awsRegion: String?
    public let awsAccessKey: String?
    public let awsSecretKey: String?
    public let awsSessionToken: String?
    public let awsProfile: String?
    public let skipAuth: Bool
    public let useSigV4: Bool
    let credentialsProvider: AWSCredentialsProvider?
    let resolver: AWSCredentialsResolver
    let environment: [String: String]

    public init(awsAccessKey: String? = nil, awsSecretKey: String? = nil, awsSessionToken: String? = nil, awsRegion: String? = nil,
                awsProfile: String? = nil, apiKey: String? = nil, skipAuth: Bool = false, baseURL: String? = nil,
                timeout: Timeout? = nil, maxRetries: Int = DEFAULT_MAX_RETRIES, defaultHeaders: Headers? = nil,
                defaultQuery: Query? = nil, transport: HTTPTransport? = nil, middleware: [Middleware]? = nil,
                credentialsProvider: AWSCredentialsProvider? = nil,
                environment: [String: String] = ProcessInfo.processInfo.environment) throws
    {
        // `_resolve_mantle_config`
        let useSigV4: Bool
        let resolvedAPIKey: String?
        if skipAuth {
            useSigV4 = false
            resolvedAPIKey = nil
        } else {
            try AWSConfig.validateCredentials(awsAccessKey: awsAccessKey, awsSecretKey: awsSecretKey)
            useSigV4 = AWSConfig.resolveAuthMode(apiKey: apiKey, awsAccessKey: awsAccessKey, awsSecretKey: awsSecretKey,
                                                 awsProfile: awsProfile, apiKeyEnvVars: AnthropicBedrockMantle.apiKeyEnvVars,
                                                 environment: environment)
            resolvedAPIKey = AWSConfig.resolveAPIKey(apiKey: apiKey, useSigV4: useSigV4, apiKeyEnvVars: AnthropicBedrockMantle.apiKeyEnvVars,
                                                     environment: environment)
        }
        let region = AWSConfig.resolveRegion(awsRegion, environment: environment)
        var base = baseURL ?? environment["ANTHROPIC_BEDROCK_MANTLE_BASE_URL"]
        if base == nil {
            guard let region else {
                throw AnthropicError(
                    "No AWS region or base URL found. Set `aws_region` in the constructor, the `AWS_REGION` / `AWS_DEFAULT_REGION` environment variable, or provide a `base_url` / `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` environment variable."
                )
            }
            base = "https://bedrock-mantle.\(region).api.aws/anthropic"
        }
        guard let url = URL(string: base!) else { throw ValueError("Invalid base URL: \(base!)") }

        self.apiKey = resolvedAPIKey
        self.awsRegion = region
        self.awsAccessKey = awsAccessKey
        self.awsSecretKey = awsSecretKey
        self.awsSessionToken = awsSessionToken
        self.awsProfile = awsProfile
        self.skipAuth = skipAuth
        self.useSigV4 = useSigV4
        self.credentialsProvider = credentialsProvider
        self.environment = environment
        self.resolver = AWSCredentialsResolver(accessKey: awsAccessKey, secretKey: awsSecretKey, sessionToken: awsSessionToken,
                                               profile: awsProfile, provider: credentialsProvider, environment: environment,
                                               transport: nil)
        super.init(version: ANTHROPIC_SDK_VERSION, baseURL: url, maxRetries: maxRetries, timeout: timeout,
                   customHeaders: defaultHeaders ?? [:], customQuery: defaultQuery, transport: transport, middleware: middleware)
    }

    public var messages: MessagesResource { MessagesResource(client: self) }
    public var beta: MantleBetaResource { MantleBetaResource(client: self) }

    open override var querystring: Querystring { Querystring(arrayFormat: .comma) }

    open override var authHeaders: Headers {
        if skipAuth || useSigV4 { return [:] }
        guard let apiKey else { return [:] }
        return ["Authorization": .value("Bearer \(apiKey)")]
    }

    open override var defaultHeaders: Headers {
        mergeHeaderLayers(super.defaultHeaders, [
            "X-Stainless-Async": "async:swift-concurrency",
            "anthropic-version": .value(ANTHROPIC_API_VERSION),
        ], customHeaders)
    }

    open override func validateHeaders(_ headers: HTTPHeaders, omitted: Set<String>) throws {}

    open override func makeStatusError(_ message: String, body: JSONValue?, response: HTTPResponse) -> APIStatusError {
        switch response.statusCode {
        case 400: return BadRequestError(message, response: response, body: body)
        case 401: return AuthenticationError(message, response: response, body: body)
        case 403: return PermissionDeniedError(message, response: response, body: body)
        case 404: return NotFoundError(message, response: response, body: body)
        case 409: return ConflictError(message, response: response, body: body)
        case 413: return RequestTooLargeError(message, response: response, body: body)
        case 422: return UnprocessableEntityError(message, response: response, body: body)
        case 429: return RateLimitError(message, response: response, body: body)
        case 529: return OverloadedError(message, response: response, body: body)
        case 500...: return InternalServerError(message, response: response, body: body)
        default: return APIStatusError(message, response: response, body: body)
        }
    }

    open override func prepareOptions(_ options: FinalRequestOptions) async throws -> FinalRequestOptions {
        moveUserProfileIDToBody(keepClientHeaderParams(options))
    }

    /// Mantle reads the user profile ID from the body of the Messages / count-tokens requests, and
    /// from the header on other routes (`_move_user_profile_id_to_body`).
    func moveUserProfileIDToBody(_ input: FinalRequestOptions) -> FinalRequestOptions {
        var options = input
        guard AnthropicBedrockMantle.userProfileIDBodyPaths.contains(options.url), case .object(let body)? = options.jsonData else {
            return options
        }
        let headers = options.headers ?? [:]
        guard let userProfileID = buildHeaderLayers([customHeaders, headers]).0[AnthropicBedrockMantle.userProfileIDHeader] else {
            return options
        }
        options.headers = mergeHeaders(headers, [AnthropicBedrockMantle.userProfileIDHeader: .omit])
        var newBody: [String: JSONValue] = ["user_profile_id": .string(userProfileID)]
        for (k, v) in body { newBody[k] = v }
        options.jsonData = .object(newBody)
        return options
    }

    open override func prepareRequest(_ request: inout HTTPRequest) async throws {
        if skipAuth || !useSigV4 { return }
        let credentials = try await resolver.resolve()
        for (name, value) in awsAuthHeaders(method: request.method, url: request.url, headers: request.headers, body: request.body,
                                            credentials: credentials, region: awsRegion ?? "",
                                            serviceName: AnthropicBedrockMantle.defaultServiceName)
        {
            request.headers[name] = value
        }
    }

    /// Copies the client, replacing the options given (`copy` / `with_options`).
    public func copy(apiKey: String? = nil, awsAccessKey: String? = nil, awsSecretKey: String? = nil, awsSessionToken: String? = nil,
                     awsRegion: String? = nil, awsProfile: String? = nil, skipAuth: Bool? = nil, baseURL: String? = nil,
                     timeout: Timeout? = nil, maxRetries: Int? = nil, defaultHeaders: Headers? = nil,
                     setDefaultHeaders: Headers? = nil, defaultQuery: Query? = nil, setDefaultQuery: Query? = nil,
                     transport: HTTPTransport? = nil, middleware: [Middleware]? = nil) throws -> AnthropicBedrockMantle
    {
        let (headers, params) = try copiedLayers(defaultHeaders: defaultHeaders, setDefaultHeaders: setDefaultHeaders,
                                                 defaultQuery: defaultQuery, setDefaultQuery: setDefaultQuery)
        let client = try AnthropicBedrockMantle(
            awsAccessKey: awsAccessKey ?? self.awsAccessKey, awsSecretKey: awsSecretKey ?? self.awsSecretKey,
            awsSessionToken: awsSessionToken ?? self.awsSessionToken, awsRegion: awsRegion ?? self.awsRegion,
            awsProfile: awsProfile ?? self.awsProfile, apiKey: apiKey ?? self.apiKey, skipAuth: skipAuth ?? self.skipAuth,
            baseURL: baseURL ?? self.baseURL.absoluteString, timeout: timeout ?? (timeoutOverridden ? self.timeout : nil),
            maxRetries: maxRetries ?? self.maxRetries, defaultHeaders: headers, defaultQuery: params,
            transport: transport ?? self.transport, middleware: middleware ?? self.middleware,
            credentialsProvider: credentialsProvider, environment: environment)
        client.timeoutOverridden = timeoutOverridden || timeout != nil
        client.sleeper = sleeper
        return client
    }

    /// Alias for `copy`, for inline use.
    public func withOptions(timeout: Timeout? = nil, maxRetries: Int? = nil, defaultHeaders: Headers? = nil,
                            defaultQuery: Query? = nil) throws -> AnthropicBedrockMantle
    {
        try copy(timeout: timeout, maxRetries: maxRetries, defaultHeaders: defaultHeaders, defaultQuery: defaultQuery)
    }

    /// A copy of this client with `middleware` appended after its own.
    public func withMiddleware(_ middleware: Middleware...) throws -> AnthropicBedrockMantle {
        try copy(middleware: self.middleware + middleware)
    }
}

/// `client.beta` on Mantle: only `messages`.
public struct MantleBetaResource: Sendable {
    public let client: BaseClient
    public init(client: BaseClient) { self.client = client }
    public var messages: BetaMessagesResource { BetaMessagesResource(client: client) }
}
