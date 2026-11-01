import Foundation

/// A function that returns a Microsoft Entra ID (Azure AD) token, invoked on every request.
public typealias AzureADTokenProvider = @Sendable () async throws -> String

/// `api_key` and `azure_ad_token_provider` were both passed.
open class MutuallyExclusiveAuthError: AnthropicError, @unchecked Sendable {
    public init() {
        super.init("The `api_key` and `azure_ad_token_provider` arguments are mutually exclusive; Only one can be passed at a time")
    }
}

/// Claude in Microsoft Foundry (`anthropic.lib.foundry.AsyncAnthropicFoundry`).
///
/// The first-party API at `https://{resource}.services.ai.azure.com/anthropic/`, authenticated with
/// a Foundry API key (sent as `x-api-key` and `api-key`) or an Azure AD bearer token. The Models
/// API and Message Batches are not available on Foundry (the Python client hides them; here they
/// are present but the service rejects them).
open class AnthropicFoundry: Anthropic, @unchecked Sendable {
    let azureADTokenProvider: AzureADTokenProvider?
    let foundryEnvironment: [String: String]

    /// - Parameters:
    ///   - resource: Your Foundry resource name (or `ANTHROPIC_FOUNDRY_RESOURCE`), e.g. `example-resource`
    ///     for `https://example-resource.services.ai.azure.com/anthropic/`. Mutually exclusive with `baseURL`.
    ///   - apiKey: The Foundry API key (or `ANTHROPIC_FOUNDRY_API_KEY`).
    ///   - azureADTokenProvider: Returns an Azure AD token; invoked on every request.
    ///   - baseURL: The endpoint (or `ANTHROPIC_FOUNDRY_BASE_URL`).
    public init(resource: String? = nil, apiKey: String? = nil, azureADTokenProvider: AzureADTokenProvider? = nil,
                webhookKey: String? = nil, baseURL: String? = nil, timeout: Timeout? = nil, maxRetries: Int = DEFAULT_MAX_RETRIES,
                defaultHeaders: Headers? = nil, defaultQuery: Query? = nil, transport: HTTPTransport? = nil,
                middleware: [Middleware]? = nil, environment: [String: String] = ProcessInfo.processInfo.environment) throws
    {
        let apiKey = apiKey ?? environment["ANTHROPIC_FOUNDRY_API_KEY"]
        let resource = resource ?? environment["ANTHROPIC_FOUNDRY_RESOURCE"]
        var base = baseURL ?? environment["ANTHROPIC_FOUNDRY_BASE_URL"]
        if apiKey == nil && azureADTokenProvider == nil {
            throw AnthropicError(
                "Missing credentials. Please pass one of `api_key`, `azure_ad_token_provider`, or the `ANTHROPIC_FOUNDRY_API_KEY` environment variable."
            )
        }
        if base == nil {
            guard let resource else {
                throw ValueError(
                    "Must provide one of the `base_url` or `resource` arguments, or the `ANTHROPIC_FOUNDRY_RESOURCE` environment variable")
            }
            base = "https://\(resource).services.ai.azure.com/anthropic/"
        } else if resource != nil {
            throw ValueError("base_url and resource are mutually exclusive")
        }
        self.azureADTokenProvider = azureADTokenProvider
        self.foundryEnvironment = environment
        try super.init(apiKey: apiKey, webhookKey: webhookKey, baseURL: base, timeout: timeout, maxRetries: maxRetries,
                       defaultHeaders: defaultHeaders, defaultQuery: defaultQuery, transport: transport, middleware: middleware,
                       environment: environment)
    }

    /// The Azure AD token, when a provider is configured (`_get_azure_ad_token`).
    public func azureADToken() async throws -> String? {
        guard let provider = azureADTokenProvider else { return nil }
        let token = try await provider()
        if token.isEmpty {
            throw ValueError("Expected `azure_ad_token_provider` argument to return a string but it returned \(token)")
        }
        return token
    }

    open override func prepareOptions(_ options: FinalRequestOptions) async throws -> FinalRequestOptions {
        let auth: Headers
        if let token = try await azureADToken() {
            auth = ["Authorization": .value("Bearer \(token)")]
        } else if let apiKey {
            // With an Azure AD provider configured the branch above wins, so an environment
            // ANTHROPIC_API_KEY is never sent here. `api-key` is sent for backwards compatibility.
            auth = ["x-api-key": .value(apiKey), "api-key": .value(apiKey)]
        } else {
            throw ValueError("Unable to handle auth")
        }
        var options = try await super.prepareOptions(options)
        options.headers = mergeHeaders(auth, options.headers ?? [:])
        return options
    }

    /// Auth is attached per request in `prepareOptions`; nothing derives from `apiKey` here.
    open override var authHeaders: Headers { [:] }

    open override func validateHeaders(_ headers: HTTPHeaders, omitted: Set<String>) throws {}

    open override func copy(apiKey: String? = nil, authToken: String? = nil, credentials: (any AccessTokenProvider)?? = nil,
                            config: [String: JSONValue]? = nil, profile: String? = nil, webhookKey: String? = nil, baseURL: String? = nil,
                            timeout: Timeout? = nil, maxRetries: Int? = nil, defaultHeaders: Headers? = nil,
                            setDefaultHeaders: Headers? = nil, defaultQuery: Query? = nil, setDefaultQuery: Query? = nil,
                            transport: HTTPTransport? = nil, middleware: [Middleware]? = nil) throws -> Anthropic
    {
        if credentials != nil || config != nil || profile != nil {
            throw ArgumentTypeError("AnthropicFoundry.copy() does not accept `credentials`, `config` or `profile`")
        }
        let c: AnthropicFoundry = try copy(apiKey: apiKey, webhookKey: webhookKey, baseURL: baseURL, timeout: timeout,
                                           maxRetries: maxRetries, defaultHeaders: defaultHeaders, setDefaultHeaders: setDefaultHeaders,
                                           defaultQuery: defaultQuery, setDefaultQuery: setDefaultQuery, transport: transport,
                                           middleware: middleware, azureADTokenProvider: nil)
        return c
    }

    /// Copies the client, replacing the options given (`copy` / `with_options`).
    public func copy(apiKey: String? = nil, webhookKey: String? = nil, baseURL: String? = nil, timeout: Timeout? = nil,
                     maxRetries: Int? = nil, defaultHeaders: Headers? = nil, setDefaultHeaders: Headers? = nil,
                     defaultQuery: Query? = nil, setDefaultQuery: Query? = nil, transport: HTTPTransport? = nil,
                     middleware: [Middleware]? = nil, azureADTokenProvider: AzureADTokenProvider?) throws -> AnthropicFoundry
    {
        let (headers, params) = try copiedLayers(defaultHeaders: defaultHeaders, setDefaultHeaders: setDefaultHeaders,
                                                 defaultQuery: defaultQuery, setDefaultQuery: setDefaultQuery)
        var env = foundryEnvironment
        env.removeValue(forKey: "ANTHROPIC_CUSTOM_HEADERS")
        env.removeValue(forKey: "ANTHROPIC_FOUNDRY_RESOURCE")
        let client = try AnthropicFoundry(
            apiKey: apiKey ?? self.apiKey, azureADTokenProvider: azureADTokenProvider ?? self.azureADTokenProvider,
            webhookKey: webhookKey ?? self.webhookKey, baseURL: baseURL ?? self.baseURL.absoluteString,
            timeout: timeout ?? (timeoutOverridden ? self.timeout : nil), maxRetries: maxRetries ?? self.maxRetries,
            defaultHeaders: headers, defaultQuery: params, transport: transport ?? self.transport,
            middleware: middleware ?? self.middleware, environment: env)
        client.timeoutOverridden = timeoutOverridden || timeout != nil
        client.sleeper = sleeper
        return client
    }
}
