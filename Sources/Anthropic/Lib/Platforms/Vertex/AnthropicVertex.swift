import Foundation

/// Claude on Google Cloud Vertex AI (`anthropic.lib.vertex.AsyncAnthropicVertex`).
///
/// Messages requests are rewritten to the Vertex publisher-model routes
/// (`.../publishers/anthropic/models/{model}:rawPredict` / `:streamRawPredict`), the API version
/// travels in the body, and requests carry a Google OAuth2 access token: `accessToken`, else
/// `credentials`, else Application Default Credentials.
open class AnthropicVertex: BaseClient, @unchecked Sendable {
    public let region: String
    public let accessToken: String?
    let state: GoogleCredentialsState
    let environment: [String: String]
    let credentialsLoader: GoogleCredentialsLoader
    private let projectLock = NSLock()
    private var _projectID: String?

    /// - Parameters:
    ///   - region: The Vertex region (or `CLOUD_ML_REGION`); `global`, `us` and `eu` use the
    ///     global / multi-region endpoints.
    ///   - projectID: The GCP project (or `ANTHROPIC_VERTEX_PROJECT_ID`, else the ADC project).
    ///   - credentials: Google credentials to mint tokens with.
    ///   - credentialsLoader: Replaces Application Default Credentials discovery.
    public init(region: String? = nil, projectID: String? = nil, accessToken: String? = nil, credentials: GoogleCredentials? = nil,
                baseURL: String? = nil, timeout: Timeout? = nil, maxRetries: Int = DEFAULT_MAX_RETRIES,
                defaultHeaders: Headers? = nil, defaultQuery: Query? = nil, transport: HTTPTransport? = nil,
                middleware: [Middleware]? = nil, credentialsLoader: GoogleCredentialsLoader? = nil,
                environment: [String: String] = ProcessInfo.processInfo.environment) throws
    {
        guard let region = region ?? environment["CLOUD_ML_REGION"] else {
            throw ValueError(
                "No region was given. The client should be instantiated with the `region` argument or the `CLOUD_ML_REGION` environment variable should be set."
            )
        }
        var base = baseURL ?? environment["ANTHROPIC_VERTEX_BASE_URL"]
        if base == nil {
            switch region {
            case "global": base = "https://aiplatform.googleapis.com/v1"
            case "us": base = "https://aiplatform.us.rep.googleapis.com/v1"
            case "eu": base = "https://aiplatform.eu.rep.googleapis.com/v1"
            default: base = "https://\(region)-aiplatform.googleapis.com/v1"
            }
        }
        guard let url = URL(string: base!) else { throw ValueError("Invalid base URL: \(base!)") }
        self.region = region
        self.accessToken = accessToken
        self.environment = environment
        let loader = credentialsLoader ?? { try await GoogleAuth.loadDefaultCredentials(environment: environment) }
        self.credentialsLoader = loader
        self.state = GoogleCredentialsState(credentials, loader: loader)
        let envProject = environment["ANTHROPIC_VERTEX_PROJECT_ID"].flatMap { $0.isEmpty ? nil : $0 }
        self._projectID = projectID ?? envProject
        super.init(version: ANTHROPIC_SDK_VERSION, baseURL: url, maxRetries: maxRetries, timeout: timeout,
                   customHeaders: defaultHeaders, customQuery: defaultQuery, transport: transport, middleware: middleware)
    }

    /// The GCP project; back-filled from Application Default Credentials when not configured.
    public var projectID: String? { projectLock.withLock { _projectID } }

    /// The Google credentials in use (explicit or lazily-loaded ADC), if any.
    public var credentials: GoogleCredentials? { state.credentials }

    public var messages: MessagesResource { MessagesResource(client: self) }
    public var beta: VertexBetaResource { VertexBetaResource(client: self) }

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
        case 504: return DeadlineExceededError(message, response: response, body: body)
        case 500...: return InternalServerError(message, response: response, body: body)
        default: return APIStatusError(message, response: response, body: body)
        }
    }

    open override func prepareOptions(_ options: FinalRequestOptions) async throws -> FinalRequestOptions {
        try AnthropicVertex.prepareVertexOptions(options, projectID: projectID, region: region)
    }

    /// `_prepare_options` of `lib/vertex/_client.py`.
    public static func prepareVertexOptions(_ input: FinalRequestOptions, projectID: String?, region: String) throws -> FinalRequestOptions {
        var options = keepClientHeaderParams(input)
        if case .object(var body)? = options.jsonData {
            if body["anthropic_version"] == nil { body["anthropic_version"] = .string(ANTHROPIC_API_VERSION) }
            options.jsonData = .object(body)
        }
        let missingProject =
            "No project_id was given and it could not be resolved from credentials. The client should be instantiated with the `project_id` argument or the `ANTHROPIC_VERTEX_PROJECT_ID` environment variable should be set."
        if (options.url == "/v1/messages" || options.url == "/v1/messages?beta=true") && options.method == "post" {
            guard let projectID else { throw AnthropicError(missingProject) }
            guard case .object(var body)? = options.jsonData else {
                throw AnthropicError("Expected json data to be a dictionary for post /v1/messages")
            }
            let model = body.removeValue(forKey: "model").map(pythonStr) ?? "None"
            let specifier = body["stream"] == .bool(true) ? "streamRawPredict" : "rawPredict"
            options.jsonData = .object(body)
            options.url = "/projects/\(projectID)/locations/\(region)/publishers/anthropic/models/\(model):\(specifier)"
        }
        if (options.url == "/v1/messages/count_tokens" || options.url == "/v1/messages/count_tokens?beta=true") && options.method == "post" {
            guard let projectID else { throw AnthropicError(missingProject) }
            options.url = "/projects/\(projectID)/locations/\(region)/publishers/anthropic/models/count-tokens:rawPredict"
        }
        if options.url.hasPrefix("/v1/messages/batches") {
            throw AnthropicError("The Batch API is not supported in the Vertex client yet")
        }
        return options
    }

    open override func prepareRequest(_ request: inout HTTPRequest) async throws {
        if let auth = request.headers["Authorization"], !auth.isEmpty { return }
        request.headers["Authorization"] = "Bearer \(try await ensureAccessToken())"
    }

    /// `_ensure_access_token`.
    func ensureAccessToken() async throws -> String {
        if let accessToken { return accessToken }
        let hadCredentials = state.credentials != nil
        let token = try await state.token()
        if !hadCredentials && projectID == nil {
            guard let project = state.adcProject else { throw ValueError("Could not resolve project_id") }
            projectLock.withLock { _projectID = project }
        }
        return token
    }

    /// Copies the client, replacing the options given (`copy` / `with_options`).
    public func copy(region: String? = nil, projectID: String? = nil, accessToken: String? = nil, credentials: GoogleCredentials? = nil,
                     baseURL: String? = nil, timeout: Timeout? = nil, maxRetries: Int? = nil, defaultHeaders: Headers? = nil,
                     setDefaultHeaders: Headers? = nil, defaultQuery: Query? = nil, setDefaultQuery: Query? = nil,
                     transport: HTTPTransport? = nil, middleware: [Middleware]? = nil) throws -> AnthropicVertex
    {
        let (headers, params) = try copiedLayers(defaultHeaders: defaultHeaders, setDefaultHeaders: setDefaultHeaders,
                                                 defaultQuery: defaultQuery, setDefaultQuery: setDefaultQuery)
        let client = try AnthropicVertex(
            region: region ?? self.region, projectID: projectID ?? self.projectID, accessToken: accessToken ?? self.accessToken,
            credentials: credentials ?? self.credentials, baseURL: baseURL ?? self.baseURL.absoluteString,
            timeout: timeout ?? (timeoutOverridden ? self.timeout : nil), maxRetries: maxRetries ?? self.maxRetries,
            defaultHeaders: headers, defaultQuery: params, transport: transport ?? self.transport,
            middleware: middleware ?? self.middleware, credentialsLoader: credentialsLoader, environment: environment)
        client.timeoutOverridden = timeoutOverridden || timeout != nil
        client.sleeper = sleeper
        return client
    }

    /// Alias for `copy`, for inline use.
    public func withOptions(region: String? = nil, projectID: String? = nil, timeout: Timeout? = nil, maxRetries: Int? = nil,
                            defaultHeaders: Headers? = nil, defaultQuery: Query? = nil) throws -> AnthropicVertex
    {
        try copy(region: region, projectID: projectID, timeout: timeout, maxRetries: maxRetries, defaultHeaders: defaultHeaders,
                 defaultQuery: defaultQuery)
    }

    /// A copy of this client with `middleware` appended after its own.
    public func withMiddleware(_ middleware: Middleware...) throws -> AnthropicVertex {
        try copy(middleware: self.middleware + middleware)
    }
}

/// `client.beta` on Vertex: only `messages` (`create` and `count_tokens`).
public struct VertexBetaResource: Sendable {
    public let client: BaseClient
    public init(client: BaseClient) { self.client = client }
    public var messages: BetaMessagesResource { BetaMessagesResource(client: client) }
}
