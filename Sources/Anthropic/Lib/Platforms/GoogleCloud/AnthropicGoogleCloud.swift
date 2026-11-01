import Foundation

/// A callable returning a GCP access token, invoked per request.
public typealias GoogleTokenProvider = @Sendable () async throws -> String

/// Claude Models on Google Cloud (Anthropic managed) (`anthropic.lib.google_cloud.AsyncAnthropicGoogleCloud`):
/// the first-party Anthropic API served through Google's gateway.
///
/// The whole first-party surface is proxied verbatim (no URL or body rewriting), so this subclasses
/// `Anthropic`. Requests go to
/// `https://claude.googleapis.com/v1/projects/{project}/locations/{location}/workspaces/{workspace_id}/invoke`
/// (organization-level routes — `/v1/organizations/...` and `/v1/user_profiles...` — to
/// `.../claudeOrganization/invoke`), authenticated with a GCP bearer token.
///
/// Auth precedence (unless `skipAuth`): `tokenProvider`, then `credentials`, then Application
/// Default Credentials. A caller-supplied `Authorization` header always wins.
open class AnthropicGoogleCloud: Anthropic, @unchecked Sendable {
    static let locationURLTemplate = "https://claude.googleapis.com/v1/projects/{project}/locations/{location}"
    public static let defaultURLTemplate = locationURLTemplate + "/workspaces/{workspace_id}/invoke"
    public static let organizationURLTemplate = locationURLTemplate + "/claudeOrganization/invoke"
    static let userProfilesPath = "/v1/user_profiles"
    static let organizationPathPrefixes = ["/v1/organizations/", userProfilesPath + "/"]
    public static let defaultLocation = "global"
    static let missingProjectMessage =
        "No `project` was provided and one could not be resolved from Google credentials. Pass the `project` argument, set the `ANTHROPIC_GOOGLE_CLOUD_PROJECT` environment variable, or provide `base_url` directly."
    static let missingWorkspaceMessage =
        "No workspace ID found. Set the `workspace_id` argument or the `ANTHROPIC_GOOGLE_CLOUD_WORKSPACE_ID` environment variable."

    public let workspaceID: String?
    public let location: String
    public let skipAuth: Bool
    let tokenProvider: GoogleTokenProvider?
    var credsState: GoogleCredentialsState
    let credentialsLoader: GoogleCredentialsLoader
    let gcEnvironment: [String: String]

    private let gcLock = NSLock()
    private var _project: String?
    private var _gcBaseURL: URL?
    private var baseURLDeferred: Bool
    private(set) var baseURLOverridden: Bool

    /// - Parameters:
    ///   - project: The GCP consumer project (or `ANTHROPIC_GOOGLE_CLOUD_PROJECT`, else
    ///     `GOOGLE_CLOUD_PROJECT`). Only needed when the base URL is derived; if omitted it is taken
    ///     from `credentials` when they know theirs, or back-filled from ADC on the first request.
    ///   - location: The GCP location (or `ANTHROPIC_GOOGLE_CLOUD_LOCATION`, default `global`).
    ///   - workspaceID: The Anthropic workspace (or `ANTHROPIC_GOOGLE_CLOUD_WORKSPACE_ID`). Required
    ///     for every route outside `/v1/organizations` and `/v1/user_profiles` on a derived URL.
    ///   - skipAuth: For pre-authenticated proxies: no token is attached. Mutually exclusive with
    ///     `tokenProvider` and `credentials`.
    ///   - baseURL: Overrides the derived gateway URL for every route (or `ANTHROPIC_GOOGLE_CLOUD_BASE_URL`).
    ///   - credentialsLoader: Replaces Application Default Credentials discovery.
    public init(project: String? = nil, location: String? = nil, workspaceID: String? = nil, tokenProvider: GoogleTokenProvider? = nil,
                credentials: GoogleCredentials? = nil, skipAuth: Bool = false, baseURL: String? = nil, timeout: Timeout? = nil,
                maxRetries: Int = DEFAULT_MAX_RETRIES, defaultHeaders: Headers? = nil, defaultQuery: Query? = nil,
                transport: HTTPTransport? = nil, middleware: [Middleware]? = nil, credentialsLoader: GoogleCredentialsLoader? = nil,
                environment: [String: String] = ProcessInfo.processInfo.environment) throws
    {
        if skipAuth && (tokenProvider != nil || credentials != nil) {
            throw ValueError(
                "`skip_auth` is mutually exclusive with `token_provider` and `credentials`; `skip_auth` disables authentication entirely."
            )
        }
        func env(_ name: String) -> String? { environment[name] }
        let location = location ?? env("ANTHROPIC_GOOGLE_CLOUD_LOCATION") ?? AnthropicGoogleCloud.defaultLocation
        var project = project ?? env("ANTHROPIC_GOOGLE_CLOUD_PROJECT") ?? env("GOOGLE_CLOUD_PROJECT")
        if project == nil, let credentials { project = credentials.projectID.flatMap { $0.isEmpty ? nil : $0 } }
        let explicitBase = baseURL ?? env("ANTHROPIC_GOOGLE_CLOUD_BASE_URL")
        let workspaceID = workspaceID ?? env("ANTHROPIC_GOOGLE_CLOUD_WORKSPACE_ID")

        // `_resolve_base_url`
        var resolved: String? = nil
        if let explicitBase {
            resolved = explicitBase
        } else if let project {
            if let workspaceID { resolved = AnthropicGoogleCloud.derive(AnthropicGoogleCloud.defaultURLTemplate, project, location, workspaceID) }
        } else if skipAuth {
            // Without auth there are no Google credentials to back-fill the project from.
            throw ValueError(
                "No `project` was provided. Pass `project`, set the `ANTHROPIC_GOOGLE_CLOUD_PROJECT` environment variable, or provide `base_url` directly."
            )
        }
        var resolvedURL: URL? = nil
        if let resolved {
            guard let u = URL(string: resolved) else { throw ValueError("Invalid base URL: \(resolved)") }
            resolvedURL = BaseClient.enforceTrailingSlash(u)
        }

        self.workspaceID = workspaceID
        self.location = location
        self.skipAuth = skipAuth
        self.tokenProvider = tokenProvider
        let loader = credentialsLoader ?? { try await GoogleAuth.loadDefaultCredentials(environment: environment) }
        self.credentialsLoader = loader
        self.credsState = GoogleCredentialsState(credentials, loader: loader)
        self.gcEnvironment = environment
        self._project = project
        self._gcBaseURL = resolvedURL
        self.baseURLDeferred = explicitBase == nil && project == nil
        self.baseURLOverridden = explicitBase != nil
        // The parent never falls through to `ANTHROPIC_BASE_URL` / api.anthropic.com: the base URL is
        // this client's, and an empty API key stops the parent reading ANTHROPIC_API_KEY.
        try super.init(apiKey: "", baseURL: resolvedURL?.absoluteString ?? "https://claude.googleapis.com/", timeout: timeout,
                       maxRetries: maxRetries, defaultHeaders: defaultHeaders, defaultQuery: defaultQuery, transport: transport,
                       middleware: middleware, environment: environment)
        // Never inherit first-party static credentials: they would leak to the gateway host.
        self.apiKey = nil
        self.authToken = nil
    }

    static func derive(_ template: String, _ project: String, _ location: String, _ workspaceID: String? = nil) -> String {
        var s = template.replacingOccurrences(of: "{project}", with: project).replacingOccurrences(of: "{location}", with: location)
        if let workspaceID { s = s.replacingOccurrences(of: "{workspace_id}", with: workspaceID) }
        return s
    }

    /// The GCP project (explicit, from the environment or credentials, or back-filled from ADC).
    public var project: String? { gcLock.withLock { _project } }

    /// The `google.auth`-style credentials in use (explicit or lazily-loaded ADC), if any.
    public var googleCredentials: GoogleCredentials? { credsState.credentials }

    /// The gateway base URL. Assigning one wins over (and cancels) a pending project back-fill and
    /// turns off per-route base selection.
    open override var baseURL: URL {
        get { gcLock.withLock { _gcBaseURL } ?? URL(string: "/")! }
        set {
            gcLock.withLock {
                baseURLDeferred = false
                baseURLOverridden = true
                _gcBaseURL = BaseClient.enforceTrailingSlash(newValue)
            }
        }
    }

    open override var authHeaders: Headers { [:] }

    open override func validateHeaders(_ headers: HTTPHeaders, omitted: Set<String>) throws {}

    /// Path of a relative request URL, or `nil` for an absolute one.
    static func relativePath(_ url: String) -> String? {
        if let u = URL(string: url), u.scheme != nil { return nil }
        return String(url.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false).first ?? "")
    }

    static func isOrganizationPath(_ path: String) -> Bool {
        path == userProfilesPath || organizationPathPrefixes.contains(where: { path.hasPrefix($0) })
    }

    open override func prepareURL(_ url: String) -> URL {
        let (overridden, project) = gcLock.withLock { (baseURLOverridden, _project) }
        if !overridden, let path = AnthropicGoogleCloud.relativePath(url), AnthropicGoogleCloud.isOrganizationPath(path), let project {
            let base = BaseClient.enforceTrailingSlash(URL(string: AnthropicGoogleCloud.derive(AnthropicGoogleCloud.organizationURLTemplate, project, location))!)
            var rest = url
            while rest.hasPrefix("/") { rest.removeFirst() }
            return URL(string: base.absoluteString + rest) ?? base
        }
        return super.prepareURL(url)
    }

    /// The token to attach: the provider's, else the credentials' / ADC's (`_get_token`).
    func getToken() async throws -> String {
        if let tokenProvider { return try await tokenProvider() }
        return try await credsState.token()
    }

    open override func prepareOptions(_ options: FinalRequestOptions) async throws -> FinalRequestOptions {
        if !skipAuth && gcLock.withLock({ baseURLDeferred }) {
            if project == nil && tokenProvider == nil {
                // An ADC load also resolves the credentials' project; done here, independent of token
                // attachment, so the back-fill happens even when the request carries its own header.
                _ = try await credsState.token()
                let adc = credsState.adcProject
                gcLock.withLock { if _project == nil { _project = adc } }
            }
            try resolveDeferredBaseURL()
        }
        // `_prepare_url`'s checks (`prepareURL` itself cannot throw).
        let (overridden, project) = gcLock.withLock { (baseURLOverridden, _project) }
        if !overridden, let path = AnthropicGoogleCloud.relativePath(options.url) {
            if AnthropicGoogleCloud.isOrganizationPath(path) {
                if project == nil { throw AnthropicError(AnthropicGoogleCloud.missingProjectMessage) }
            } else if workspaceID == nil {
                throw AnthropicError(AnthropicGoogleCloud.missingWorkspaceMessage)
            }
        }
        return try await super.prepareOptions(options)
    }

    /// Derives the real base URL once the project is known (`_resolve_deferred_base_url`).
    func resolveDeferredBaseURL() throws {
        try gcLock.withLock {
            guard baseURLDeferred else { return }
            guard let project = _project else { throw AnthropicError(AnthropicGoogleCloud.missingProjectMessage) }
            if let workspaceID {
                _gcBaseURL = BaseClient.enforceTrailingSlash(
                    URL(string: AnthropicGoogleCloud.derive(AnthropicGoogleCloud.defaultURLTemplate, project, location, workspaceID))!)
            }
            baseURLDeferred = false
        }
    }

    open override func prepareRequest(_ request: inout HTTPRequest) async throws {
        try await super.prepareRequest(&request)
        if skipAuth { return }
        // A caller-supplied Authorization header (per request, default headers or
        // ANTHROPIC_CUSTOM_HEADERS) wins; never send two.
        if request.headers["Authorization"] != nil { return }
        request.headers["Authorization"] = "Bearer \(try await getToken())"
    }

    /// The first-party credential arguments are rejected: this client authenticates with GCP tokens.
    open override func copy(apiKey: String? = nil, authToken: String? = nil, webhookKey: String? = nil, baseURL: String? = nil,
                            timeout: Timeout? = nil, maxRetries: Int? = nil, defaultHeaders: Headers? = nil,
                            setDefaultHeaders: Headers? = nil, defaultQuery: Query? = nil, setDefaultQuery: Query? = nil,
                            transport: HTTPTransport? = nil, middleware: [Middleware]? = nil) throws -> Anthropic
    {
        if apiKey != nil || authToken != nil {
            throw ArgumentTypeError("AnthropicGoogleCloud.copy() does not accept `api_key` or `auth_token`; it authenticates with GCP credentials.")
        }
        let c: AnthropicGoogleCloud = try copy(baseURL: baseURL, timeout: timeout, maxRetries: maxRetries, defaultHeaders: defaultHeaders,
                                               setDefaultHeaders: setDefaultHeaders, defaultQuery: defaultQuery,
                                               setDefaultQuery: setDefaultQuery, transport: transport, middleware: middleware,
                                               project: nil)
        return c
    }

    /// Copies the client, replacing the options given (`copy` / `with_options`).
    ///
    /// Passing either of `tokenProvider` / `credentials` replaces the inherited credential
    /// configuration wholesale. `workspaceID: .some(nil)` clears the workspace ID; `project` /
    /// `location` re-derive a template-derived base URL.
    public func copy(baseURL: String? = nil, timeout: Timeout? = nil, maxRetries: Int? = nil, defaultHeaders: Headers? = nil,
                     setDefaultHeaders: Headers? = nil, defaultQuery: Query? = nil, setDefaultQuery: Query? = nil,
                     transport: HTTPTransport? = nil, middleware: [Middleware]? = nil, project: String? = nil,
                     location: String? = nil, workspaceID: String?? = nil, tokenProvider: GoogleTokenProvider?? = nil,
                     credentials: GoogleCredentials?? = nil, skipAuth: Bool? = nil) throws -> AnthropicGoogleCloud
    {
        let (headers, params) = try copiedLayers(defaultHeaders: defaultHeaders, setDefaultHeaders: setDefaultHeaders,
                                                 defaultQuery: defaultQuery, setDefaultQuery: setDefaultQuery)
        let resolvedSkipAuth = skipAuth ?? self.skipAuth
        let credentialOverridden = tokenProvider != nil || credentials != nil
        var newTokenProvider: GoogleTokenProvider? = nil
        var newCredentials: GoogleCredentials? = nil
        if credentialOverridden {
            newTokenProvider = tokenProvider ?? nil
            newCredentials = credentials ?? nil
        } else if !resolvedSkipAuth {
            newTokenProvider = self.tokenProvider
            newCredentials = credsState.credentials
        }
        let newBaseURL: String? = baseURL ?? (baseURLOverridden ? self.baseURL.absoluteString : nil)
        var env = gcEnvironment
        env.removeValue(forKey: "ANTHROPIC_CUSTOM_HEADERS")
        // A base URL left unset re-derives from the (new) project / location, not from the environment.
        env.removeValue(forKey: "ANTHROPIC_GOOGLE_CLOUD_BASE_URL")
        let client = try AnthropicGoogleCloud(
            project: project ?? self.project, location: location ?? self.location,
            workspaceID: workspaceID ?? self.workspaceID, tokenProvider: newTokenProvider, credentials: newCredentials,
            skipAuth: resolvedSkipAuth, baseURL: newBaseURL, timeout: timeout ?? (timeoutOverridden ? self.timeout : nil),
            maxRetries: maxRetries ?? self.maxRetries, defaultHeaders: headers, defaultQuery: params,
            transport: transport ?? self.transport, middleware: middleware ?? self.middleware,
            credentialsLoader: credentialsLoader, environment: env)
        client.timeoutOverridden = timeoutOverridden || timeout != nil
        client.sleeper = sleeper
        if !credentialOverridden && !resolvedSkipAuth {
            // Clones share lazily-loaded ADC credentials so a per-call clone doesn't mint its own token.
            client.credsState = credsState
        }
        return client
    }

    /// Alias for `copy`, for inline use.
    public func withOptions(timeout: Timeout? = nil, maxRetries: Int? = nil, defaultHeaders: Headers? = nil, defaultQuery: Query? = nil,
                            project: String? = nil, location: String? = nil) throws -> AnthropicGoogleCloud
    {
        try copy(timeout: timeout, maxRetries: maxRetries, defaultHeaders: defaultHeaders, defaultQuery: defaultQuery, project: project,
                 location: location)
    }
}
