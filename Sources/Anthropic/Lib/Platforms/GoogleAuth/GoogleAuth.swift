import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// The OAuth scope the Google-hosted clients request.
public let GOOGLE_CLOUD_PLATFORM_SCOPE = "https://www.googleapis.com/auth/cloud-platform"

/// Google OAuth2 credentials, the Swift counterpart of a `google.auth.credentials.Credentials`
/// object: a current access token that `refresh()` renews.
///
/// The SDK ships `GoogleServiceAccountCredentials` (RS256 JWT bearer grant),
/// `GoogleAuthorizedUserCredentials` (refresh-token grant, as written by
/// `gcloud auth application-default login`), `GoogleComputeEngineCredentials` (metadata server) and
/// `GoogleAccessTokenCredentials` (a fixed token). Conform your own type to plug in anything else.
public protocol GoogleCredentials: AnyObject, Sendable {
    /// The current access token, if one has been minted.
    var token: String? { get }
    /// Whether the token has expired (or is about to).
    var expired: Bool { get }
    /// The project these credentials belong to, when they know it (`project_id` /
    /// `quota_project_id` on the Python objects).
    var projectID: String? { get }
    /// Mints a new access token.
    func refresh() async throws
}

/// Thrown when Application Default Credentials cannot be found or loaded
/// (`google.auth.exceptions.DefaultCredentialsError`).
open class GoogleDefaultCredentialsError: AnthropicError, @unchecked Sendable {}

/// Base for credentials that mint tokens over HTTP: holds the token and its expiry.
open class GoogleOAuthCredentials: GoogleCredentials, @unchecked Sendable {
    private let lock = NSLock()
    private var _token: String?
    private var _expiry: Date?
    public let transport: HTTPTransport
    public let projectID: String?
    /// google-auth treats tokens as expired this long before their real expiry.
    public static let refreshThreshold: TimeInterval = 3 * 60 + 45

    public init(transport: HTTPTransport? = nil, projectID: String? = nil) {
        self.transport = transport ?? URLSessionTransport()
        self.projectID = projectID
    }

    public var token: String? { lock.withLock { _token } }
    public var expiry: Date? { lock.withLock { _expiry } }

    public var expired: Bool {
        guard let e = expiry else { return false }
        return Date() >= e.addingTimeInterval(-GoogleOAuthCredentials.refreshThreshold)
    }

    public func refresh() async throws {
        let (token, expiry) = try await fetchToken()
        lock.withLock {
            _token = token
            _expiry = expiry
        }
    }

    /// Returns a fresh access token and its expiry. Subclasses override this.
    open func fetchToken() async throws -> (String, Date?) {
        throw AnthropicError("\(type(of: self)) does not implement fetchToken()")
    }

    /// POSTs a form to a token endpoint and parses `access_token` / `expires_in`.
    func postTokenRequest(_ url: URL, form: [(String, String)]) async throws -> (String, Date?) {
        let body = form.map { "\(pythonQuote($0.0, safe: ""))=\(pythonQuote($0.1, safe: ""))" }.joined(separator: "&")
        let request = HTTPRequest(method: "POST", url: url,
                                  headers: ["Content-Type": "application/x-www-form-urlencoded", "Accept": "application/json"],
                                  body: Data(body.utf8), timeout: Timeout(120))
        let response = try await transport.send(request, stream: false)
        let data = try await response.read()
        let json = try? JSONValue.parse(data)
        guard response.isSuccess, let token = json?["access_token"]?.stringValue else {
            let detail = json?["error_description"]?.stringValue ?? json?["error"]?.stringValue ?? String(decoding: data, as: UTF8.self)
            throw AnthropicError("Google token request to \(url.absoluteString) failed (HTTP \(response.statusCode)): \(detail)")
        }
        return (token, Self.expiry(json?["expires_in"]))
    }

    static func expiry(_ expiresIn: JSONValue?) -> Date? {
        switch expiresIn {
        case .int(let i)?: return Date().addingTimeInterval(TimeInterval(i))
        case .double(let d)?: return Date().addingTimeInterval(d)
        case .string(let s)?: return Double(s).map { Date().addingTimeInterval($0) }
        default: return nil
        }
    }
}

/// A fixed access token (it is never refreshed).
public final class GoogleAccessTokenCredentials: GoogleCredentials, @unchecked Sendable {
    public let token: String?
    public let projectID: String?
    public var expired: Bool { false }
    public init(token: String, projectID: String? = nil) {
        self.token = token
        self.projectID = projectID
    }
    public func refresh() async throws {}
}

/// Service-account credentials: signs an RS256 JWT with the account's private key and exchanges
/// it at the token endpoint (`google.oauth2.service_account.Credentials`).
public final class GoogleServiceAccountCredentials: GoogleOAuthCredentials, @unchecked Sendable {
    public let clientEmail: String
    public let privateKeyID: String?
    public let tokenURI: URL
    public let scopes: [String]
    let privateKey: RSAPrivateKey

    public init(clientEmail: String, privateKeyPEM: String, privateKeyID: String? = nil,
                tokenURI: URL = URL(string: "https://oauth2.googleapis.com/token")!, projectID: String? = nil,
                scopes: [String] = [GOOGLE_CLOUD_PLATFORM_SCOPE], transport: HTTPTransport? = nil) throws
    {
        self.clientEmail = clientEmail
        self.privateKey = try RSAPrivateKey(pem: privateKeyPEM)
        self.privateKeyID = privateKeyID
        self.tokenURI = tokenURI
        self.scopes = scopes
        super.init(transport: transport, projectID: projectID)
    }

    /// Loads a service-account key file's JSON (`"type": "service_account"`).
    public convenience init(json: JSONValue, scopes: [String] = [GOOGLE_CLOUD_PLATFORM_SCOPE], transport: HTTPTransport? = nil) throws {
        guard let email = json["client_email"]?.stringValue, let key = json["private_key"]?.stringValue else {
            throw GoogleDefaultCredentialsError("Service account info was not in the expected format, missing fields client_email, private_key.")
        }
        let uri = json["token_uri"]?.stringValue.flatMap(URL.init(string:)) ?? URL(string: "https://oauth2.googleapis.com/token")!
        try self.init(clientEmail: email, privateKeyPEM: key, privateKeyID: json["private_key_id"]?.stringValue, tokenURI: uri,
                      projectID: json["project_id"]?.stringValue, scopes: scopes, transport: transport)
    }

    /// The signed JWT assertion for `now`.
    public func assertion(now: Date = Date()) throws -> String {
        var header: [String: JSONValue] = ["alg": "RS256", "typ": "JWT"]
        if let privateKeyID { header["kid"] = .string(privateKeyID) }
        let iat = Int(now.timeIntervalSince1970)
        let claims: JSONValue = [
            "iss": .string(clientEmail), "scope": .string(scopes.joined(separator: " ")), "aud": .string(tokenURI.absoluteString),
            "iat": .int(iat), "exp": .int(iat + 3600),
        ]
        let signingInput = try JSONValue.serialize(.object(header), sortedKeys: true).base64URLEncodedString() + "."
            + JSONValue.serialize(claims, sortedKeys: true).base64URLEncodedString()
        let signature = try privateKey.signature(for: Array(signingInput.utf8))
        return signingInput + "." + Data(signature).base64URLEncodedString()
    }

    public override func fetchToken() async throws -> (String, Date?) {
        try await postTokenRequest(tokenURI, form: [
            ("grant_type", "urn:ietf:params:oauth:grant-type:jwt-bearer"), ("assertion", try assertion()),
        ])
    }
}

/// User credentials from `gcloud auth application-default login` (`"type": "authorized_user"`):
/// a refresh-token grant (`google.oauth2.credentials.Credentials`).
public final class GoogleAuthorizedUserCredentials: GoogleOAuthCredentials, @unchecked Sendable {
    public let clientID: String
    let clientSecret: String
    let refreshToken: String
    public let tokenURI: URL

    public init(clientID: String, clientSecret: String, refreshToken: String,
                tokenURI: URL = URL(string: "https://oauth2.googleapis.com/token")!, quotaProjectID: String? = nil,
                transport: HTTPTransport? = nil)
    {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.refreshToken = refreshToken
        self.tokenURI = tokenURI
        super.init(transport: transport, projectID: quotaProjectID)
    }

    public convenience init(json: JSONValue, transport: HTTPTransport? = nil) throws {
        guard let id = json["client_id"]?.stringValue, let secret = json["client_secret"]?.stringValue,
              let refresh = json["refresh_token"]?.stringValue
        else {
            throw GoogleDefaultCredentialsError(
                "Authorized user info was not in the expected format, missing fields client_id, client_secret, refresh_token.")
        }
        let uri = json["token_uri"]?.stringValue.flatMap(URL.init(string:)) ?? URL(string: "https://oauth2.googleapis.com/token")!
        self.init(clientID: id, clientSecret: secret, refreshToken: refresh, tokenURI: uri,
                  quotaProjectID: json["quota_project_id"]?.stringValue, transport: transport)
    }

    public override func fetchToken() async throws -> (String, Date?) {
        try await postTokenRequest(tokenURI, form: [
            ("grant_type", "refresh_token"), ("client_id", clientID), ("client_secret", clientSecret), ("refresh_token", refreshToken),
        ])
    }
}

/// The attached service account of a GCE VM / GKE pod / Cloud Run service, via the metadata server
/// (`google.auth.compute_engine.Credentials`).
public final class GoogleComputeEngineCredentials: GoogleOAuthCredentials, @unchecked Sendable {
    public let metadataHost: String
    public let scopes: [String]

    public init(metadataHost: String = "metadata.google.internal", projectID: String? = nil,
                scopes: [String] = [GOOGLE_CLOUD_PLATFORM_SCOPE], transport: HTTPTransport? = nil)
    {
        self.metadataHost = metadataHost
        self.scopes = scopes
        super.init(transport: transport, projectID: projectID)
    }

    public override func fetchToken() async throws -> (String, Date?) {
        let scope = pythonQuote(scopes.joined(separator: ","), safe: "")
        guard let url = URL(string: "http://\(metadataHost)/computeMetadata/v1/instance/service-accounts/default/token?scopes=\(scope)") else {
            throw AnthropicError("Invalid metadata host \(metadataHost)")
        }
        let response = try await transport.send(HTTPRequest(method: "GET", url: url, headers: ["Metadata-Flavor": "Google"], timeout: Timeout(10)),
                                                stream: false)
        let data = try await response.read()
        guard response.isSuccess, let json = try? JSONValue.parse(data), let token = json["access_token"]?.stringValue else {
            throw AnthropicError("Failed to retrieve an access token from the GCE metadata server (HTTP \(response.statusCode))")
        }
        return (token, Self.expiry(json["expires_in"]))
    }
}

/// Application Default Credentials (port of `google.auth.default` as `lib/_extras/_google_auth.py` uses it).
public enum GoogleAuth {
    /// Finds credentials the way `google.auth.default(scopes=[cloud-platform])` does and mints an
    /// initial access token. Returns the credentials and the project they resolve to (`nil` for
    /// plain user credentials).
    ///
    /// Order: the `GOOGLE_APPLICATION_CREDENTIALS` file, the gcloud ADC file
    /// (`$CLOUDSDK_CONFIG/application_default_credentials.json`, default
    /// `~/.config/gcloud/application_default_credentials.json`), then the GCE metadata server.
    /// `GOOGLE_CLOUD_PROJECT` / `GCLOUD_PROJECT` override the project.
    ///
    /// Supported credential files: `service_account` and `authorized_user`. Not supported:
    /// `external_account` (workload identity federation), `impersonated_service_account`, and the
    /// gcloud-configured project of user credentials (it would need the `gcloud` CLI).
    public static func loadDefaultCredentials(scopes: [String] = [GOOGLE_CLOUD_PLATFORM_SCOPE],
                                              environment: [String: String] = ProcessInfo.processInfo.environment,
                                              transport: HTTPTransport? = nil) async throws -> (GoogleCredentials, String?)
    {
        let transport = transport ?? URLSessionTransport()
        let explicitProject = env(environment, "GOOGLE_CLOUD_PROJECT") ?? env(environment, "GCLOUD_PROJECT")
        var found: (GoogleCredentials, String?)? = nil
        if let path = env(environment, "GOOGLE_APPLICATION_CREDENTIALS") {
            guard let data = FileManager.default.contents(atPath: path) else {
                throw GoogleDefaultCredentialsError("File \(path) was not found.")
            }
            found = try credentials(fromFile: data, path: path, scopes: scopes, transport: transport)
        } else if let data = FileManager.default.contents(atPath: gcloudADCPath(environment)) {
            found = try credentials(fromFile: data, path: gcloudADCPath(environment), scopes: scopes, transport: transport)
        } else if let gce = try? await computeEngine(environment: environment, scopes: scopes, transport: transport) {
            found = gce
        }
        guard let (credentials, project) = found else {
            throw GoogleDefaultCredentialsError(
                "Your default credentials were not found. To set up Application Default Credentials, see https://cloud.google.com/docs/authentication/external/set-up-adc for more information."
            )
        }
        try await credentials.refresh()
        return (credentials, explicitProject ?? project)
    }

    static func env(_ environment: [String: String], _ name: String) -> String? {
        environment[name].flatMap { $0.isEmpty ? nil : $0 }
    }

    static func gcloudADCPath(_ environment: [String: String]) -> String {
        if let dir = env(environment, "CLOUDSDK_CONFIG") { return dir + "/application_default_credentials.json" }
        let home = env(environment, "HOME") ?? NSHomeDirectory()
        return home + "/.config/gcloud/application_default_credentials.json"
    }

    /// Parses a credentials JSON file.
    public static func credentials(fromFile data: Data, path: String = "<data>", scopes: [String] = [GOOGLE_CLOUD_PLATFORM_SCOPE],
                                   transport: HTTPTransport? = nil) throws -> (GoogleCredentials, String?)
    {
        guard let json = try? JSONValue.parse(data), case .object = json else {
            throw GoogleDefaultCredentialsError("File \(path) is not a valid json file.")
        }
        switch json["type"]?.stringValue {
        case "service_account":
            let c = try GoogleServiceAccountCredentials(json: json, scopes: scopes, transport: transport)
            return (c, c.projectID)
        case "authorized_user":
            return (try GoogleAuthorizedUserCredentials(json: json, transport: transport), nil)
        case let type:
            throw GoogleDefaultCredentialsError(
                "The file \(path) does not have a supported credentials type (\(type ?? "None")). Supported: service_account, authorized_user."
            )
        }
    }

    /// The metadata-server credentials, when the metadata server answers.
    static func computeEngine(environment: [String: String], scopes: [String], transport: HTTPTransport) async throws
        -> (GoogleCredentials, String?)?
    {
        let host = env(environment, "GCE_METADATA_HOST") ?? env(environment, "GCE_METADATA_ROOT") ?? "metadata.google.internal"
        guard let url = URL(string: "http://\(host)/computeMetadata/v1/project/project-id") else { return nil }
        let response = try await transport.send(HTTPRequest(method: "GET", url: url, headers: ["Metadata-Flavor": "Google"], timeout: Timeout(3)),
                                                stream: false)
        let project = try await response.text()
        guard response.isSuccess, response.headers["Metadata-Flavor"] == "Google" else { return nil }
        return (GoogleComputeEngineCredentials(metadataHost: host, projectID: project, scopes: scopes, transport: transport),
                project.isEmpty ? nil : project)
    }
}

/// Loads Application Default Credentials; injectable so tests and custom setups can replace ADC.
public typealias GoogleCredentialsLoader = @Sendable () async throws -> (GoogleCredentials, String?)

/// Holds the Google credentials object, serializes its loading / refreshing, and remembers the
/// project ADC resolved (`_GoogleCredentialsState`). Shared between a client and its copies so a
/// lazily-loaded ADC credential is minted once.
public final class GoogleCredentialsState: @unchecked Sendable {
    private let lock = NSLock()
    private var _credentials: GoogleCredentials?
    private var _adcProject: String?
    private var inflight: Task<String, Error>?
    let loader: GoogleCredentialsLoader

    public init(_ credentials: GoogleCredentials?, loader: @escaping GoogleCredentialsLoader) {
        self._credentials = credentials
        self.loader = loader
    }

    public var credentials: GoogleCredentials? { lock.withLock { _credentials } }
    public var adcProject: String? { lock.withLock { _adcProject } }

    /// A valid access token, loading ADC / refreshing as needed. Concurrent callers share one load.
    public func token() async throws -> String {
        let task: Task<String, Error> = lock.withLock {
            if let t = inflight { return t }
            let t = Task { try await self.resolveToken() }
            inflight = t
            return t
        }
        defer { lock.withLock { if inflight == task { inflight = nil } } }
        return try await task.value
    }

    private func resolveToken() async throws -> String {
        var credentials = self.credentials
        if credentials == nil {
            let (loaded, project) = try await loader()
            lock.withLock {
                _credentials = loaded
                _adcProject = project
            }
            credentials = loaded
        } else if let c = credentials, c.expired || c.token == nil {
            try await c.refresh()
        }
        guard let token = credentials?.token, !token.isEmpty else {
            throw AnthropicError("Could not resolve a GCP access token from the configured Google credentials")
        }
        return token
    }
}
