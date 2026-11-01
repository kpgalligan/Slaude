import Foundation

/// Claude on Amazon Bedrock (`anthropic.lib.bedrock.AsyncAnthropicBedrock`).
///
/// Messages requests are rewritten to Bedrock's `InvokeModel` routes
/// (`/model/{model}/invoke` and `/model/{model}/invoke-with-response-stream`), the API version and
/// betas travel in the body, and requests are signed with SigV4 (service `bedrock`) unless an API
/// key (`AWS_BEARER_TOKEN_BEDROCK`) is used. Streaming responses use the AWS event-stream encoding.
open class AnthropicBedrock: BaseClient, @unchecked Sendable {
    public let apiKey: String?
    public let awsSecretKey: String?
    public let awsAccessKey: String?
    public let awsRegion: String
    public let awsProfile: String?
    public let awsSessionToken: String?
    let credentialsProvider: AWSCredentialsProvider?
    let resolver: AWSCredentialsResolver
    let environment: [String: String]

    /// - Parameters:
    ///   - credentialsProvider: Overrides the default AWS credential chain.
    ///   - environment: The environment variables to read (defaults to the process environment).
    public init(awsSecretKey: String? = nil, awsAccessKey: String? = nil, awsRegion: String? = nil, awsProfile: String? = nil,
                awsSessionToken: String? = nil, apiKey: String? = nil, baseURL: String? = nil, timeout: Timeout? = nil,
                maxRetries: Int = DEFAULT_MAX_RETRIES, defaultHeaders: Headers? = nil, defaultQuery: Query? = nil,
                transport: HTTPTransport? = nil, middleware: [Middleware]? = nil,
                credentialsProvider: AWSCredentialsProvider? = nil,
                environment: [String: String] = ProcessInfo.processInfo.environment) throws
    {
        let apiKey = apiKey ?? environment["AWS_BEARER_TOKEN_BEDROCK"]
        let hasAWSCredentials = awsAccessKey != nil || awsSecretKey != nil || awsSessionToken != nil || awsProfile != nil
        if apiKey != nil && hasAWSCredentials {
            throw ValueError(
                "Cannot specify both `api_key` and AWS credentials (`aws_access_key`, `aws_secret_key`, `aws_session_token`, `aws_profile`)"
            )
        }
        self.apiKey = apiKey
        self.awsSecretKey = awsSecretKey
        self.awsAccessKey = awsAccessKey
        self.awsRegion = try awsRegion ?? AnthropicBedrock.inferRegion(awsProfile: awsProfile, environment: environment)
        self.awsProfile = awsProfile
        self.awsSessionToken = awsSessionToken
        self.credentialsProvider = credentialsProvider
        self.environment = environment
        self.resolver = AWSCredentialsResolver(accessKey: awsAccessKey, secretKey: awsSecretKey, sessionToken: awsSessionToken,
                                               profile: awsProfile, provider: credentialsProvider, environment: environment,
                                               transport: nil)
        let base = baseURL ?? environment["ANTHROPIC_BEDROCK_BASE_URL"] ?? "https://bedrock-runtime.\(self.awsRegion).amazonaws.com"
        guard let url = URL(string: base) else { throw ValueError("Invalid base URL: \(base)") }
        super.init(version: ANTHROPIC_SDK_VERSION, baseURL: url, maxRetries: maxRetries, timeout: timeout,
                   customHeaders: defaultHeaders, customQuery: defaultQuery, transport: transport, middleware: middleware)
    }

    /// The region from `AWS_REGION` / `AWS_DEFAULT_REGION`, else from the profile in the AWS config file.
    static func inferRegion(awsProfile: String?, environment: [String: String]) throws -> String {
        if let r = AWSConfig.resolveRegion(nil, environment: environment) { return r }
        let profile = awsProfile ?? environment["AWS_PROFILE"].flatMap { $0.isEmpty ? nil : $0 } ?? "default"
        if let r = AWSSharedConfig.load(environment: environment).region(profile: profile) { return r }
        throw ValueError(
            "No AWS region was provided. Set the `aws_region` argument, the `AWS_REGION` / `AWS_DEFAULT_REGION` environment variable, or configure a region for your AWS profile."
        )
    }

    public var messages: MessagesResource { MessagesResource(client: self) }
    public var beta: BedrockBetaResource { BedrockBetaResource(client: self) }

    open override func makeSSEEvents(_ bytes: ByteStream) -> AsyncThrowingStream<ServerSentEvent, Error> {
        AWSEventStreamDecoder.events(from: bytes)
    }

    open override func makeStatusError(_ message: String, body: JSONValue?, response: HTTPResponse) -> APIStatusError {
        switch response.statusCode {
        case 400: return BadRequestError(message, response: response, body: body)
        case 401: return AuthenticationError(message, response: response, body: body)
        case 403: return PermissionDeniedError(message, response: response, body: body)
        case 404: return NotFoundError(message, response: response, body: body)
        case 409: return ConflictError(message, response: response, body: body)
        case 422: return UnprocessableEntityError(message, response: response, body: body)
        case 429: return RateLimitError(message, response: response, body: body)
        case 503: return ServiceUnavailableError(message, response: response, body: body)
        case 500...: return InternalServerError(message, response: response, body: body)
        default: return APIStatusError(message, response: response, body: body)
        }
    }

    open override func prepareOptions(_ options: FinalRequestOptions) async throws -> FinalRequestOptions {
        try AnthropicBedrock.prepareBedrockOptions(options)
    }

    /// `_prepare_options` of `lib/bedrock/_client.py`.
    public static func prepareBedrockOptions(_ input: FinalRequestOptions) throws -> FinalRequestOptions {
        var options = keepClientHeaderParams(input)
        if case .object(var body)? = options.jsonData {
            if body["anthropic_version"] == nil { body["anthropic_version"] = .string(ANTHROPIC_API_VERSION) }
            if let headers = options.headers, let betas = buildHeaderLayers([headers]).0["anthropic-beta"], !betas.isEmpty,
               body["anthropic_beta"] == nil
            {
                body["anthropic_beta"] = .array(betas.split(separator: ",", omittingEmptySubsequences: false).map { .string(String($0)) })
            }
            options.jsonData = .object(body)
        }
        if (options.url == "/v1/messages" || options.url == "/v1/messages?beta=true") && options.method == "post" {
            guard case .object(var body)? = options.jsonData else {
                throw AnthropicError("Expected dictionary json_data for post /v1/messages endpoint")
            }
            let model = body.removeValue(forKey: "model").map(pythonStr) ?? "None"
            let quoted = pythonQuote(model, safe: ":")
            let stream = body.removeValue(forKey: "stream")
            options.jsonData = .object(body)
            options.url = stream == .bool(true) ? "/model/\(quoted)/invoke-with-response-stream" : "/model/\(quoted)/invoke"
        }
        if options.url.hasPrefix("/v1/messages/batches") {
            throw AnthropicError("The Batch API is not supported in Bedrock yet")
        }
        if options.url == "/v1/messages/count_tokens" {
            throw AnthropicError("Token counting is not supported in Bedrock yet")
        }
        return options
    }

    open override func prepareRequest(_ request: inout HTTPRequest) async throws {
        if let apiKey {
            request.headers["Authorization"] = "Bearer \(apiKey)"
            return
        }
        let credentials: AWSCredentials
        do {
            credentials = try await resolver.resolve()
        } catch let e as AnthropicError where e.message == "Could not resolve AWS credentials from session" {
            throw AnthropicError("could not resolve credentials from session")
        }
        for (name, value) in awsAuthHeaders(method: request.method, url: request.url, headers: request.headers, body: request.body,
                                            credentials: credentials, region: awsRegion, serviceName: "bedrock")
        {
            request.headers[name] = value
        }
    }

    /// Copies the client, replacing the options given (`copy` / `with_options`).
    public func copy(awsSecretKey: String? = nil, awsAccessKey: String? = nil, awsRegion: String? = nil,
                     awsSessionToken: String? = nil, apiKey: String? = nil, baseURL: String? = nil, timeout: Timeout? = nil,
                     maxRetries: Int? = nil, defaultHeaders: Headers? = nil, setDefaultHeaders: Headers? = nil,
                     defaultQuery: Query? = nil, setDefaultQuery: Query? = nil, transport: HTTPTransport? = nil,
                     middleware: [Middleware]? = nil) throws -> AnthropicBedrock
    {
        let (headers, params) = try copiedLayers(defaultHeaders: defaultHeaders, setDefaultHeaders: setDefaultHeaders,
                                                 defaultQuery: defaultQuery, setDefaultQuery: setDefaultQuery)
        let client = try AnthropicBedrock(
            awsSecretKey: awsSecretKey ?? self.awsSecretKey, awsAccessKey: awsAccessKey ?? self.awsAccessKey,
            awsRegion: awsRegion ?? self.awsRegion, awsProfile: (apiKey ?? self.apiKey) == nil ? self.awsProfile : nil,
            awsSessionToken: awsSessionToken ?? self.awsSessionToken, apiKey: apiKey ?? self.apiKey,
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
                            defaultQuery: Query? = nil) throws -> AnthropicBedrock
    {
        try copy(timeout: timeout, maxRetries: maxRetries, defaultHeaders: defaultHeaders, defaultQuery: defaultQuery)
    }

    /// A copy of this client with `middleware` appended after its own.
    public func withMiddleware(_ middleware: Middleware...) throws -> AnthropicBedrock {
        try copy(middleware: self.middleware + middleware)
    }
}

/// `client.beta` on Bedrock: only `messages` (`lib/bedrock/_beta.py`).
public struct BedrockBetaResource: Sendable {
    public let client: BaseClient
    public init(client: BaseClient) { self.client = client }
    public var messages: BetaMessagesResource { BetaMessagesResource(client: client) }
    public var withRawResponse: WithRawResponse { WithRawResponse(client: client) }
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(client: client) }

    public struct WithRawResponse: Sendable {
        let client: BaseClient
        public var messages: BetaMessagesResource.WithRawResponse { BetaMessagesResource(client: client).withRawResponse }
    }

    public struct WithStreamingResponse: Sendable {
        let client: BaseClient
        public var messages: BetaMessagesResource.WithStreamingResponse { BetaMessagesResource(client: client).withStreamingResponse }
    }
}

extension BaseClient {
    /// The header / query layers of a copy (the shared part of every platform client's `copy`).
    func copiedLayers(defaultHeaders: Headers?, setDefaultHeaders: Headers?, defaultQuery: Query?, setDefaultQuery: Query?) throws
        -> (Headers, Query)
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
        return (headers, params)
    }
}


