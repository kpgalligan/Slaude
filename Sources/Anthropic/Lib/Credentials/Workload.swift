import Foundation

/// Port of `anthropic/lib/credentials/_workload.py`.

let JWT_BEARER_BETA_HEADER = "\(OAUTH_API_BETA_HEADER),\(FEDERATION_BETA_HEADER)"

/// Hard limits on the size of the assertion JWT we send and the token-endpoint response we accept.
let MAX_ASSERTION_BYTES = 16 * 1024
let MAX_TOKEN_RESPONSE_BYTES = 1 << 20

/// The OIDC token exchange (`POST /v1/oauth/token`) failed (`WorkloadIdentityError`).
open class WorkloadIdentityError: AnthropicError, @unchecked Sendable {
    public let statusCode: Int?
    /// The redacted response body (see `redactBody`).
    public let body: JSONValue?
    public let requestID: String?

    public init(_ message: String, statusCode: Int? = nil, body: JSONValue? = nil, requestID: String? = nil) {
        self.statusCode = statusCode
        self.body = body
        self.requestID = requestID
        super.init(message)
    }

    open override var description: String {
        if let requestID, !requestID.isEmpty { return "\(message) [request_id=\(requestID)]" }
        return message
    }
}

func tokenEndpointRequestID(_ resp: HTTPResponse) -> String? {
    if let v = resp.headers["Request-Id"], !v.isEmpty { return v }
    return resp.headers["request-id"]
}

/// Throws a redacted `WorkloadIdentityError` for a failed token-endpoint response
/// (`_raise_token_endpoint_error`).
func tokenEndpointError(_ resp: HTTPResponse, body: Data, messagePrefix: String, hint: String? = nil) -> WorkloadIdentityError {
    let redacted: JSONValue?
    if let parsed = try? parseJSONFragment(body) {
        redacted = redactBody(parsed)
    } else {
        redacted = redactBody(.string(String(decoding: body, as: UTF8.self)))
    }
    var message = "\(messagePrefix) (HTTP \(resp.statusCode)): \(pythonStr(redacted))"
    if let hint, !hint.isEmpty { message += " \(hint)" }
    return WorkloadIdentityError(message, statusCode: resp.statusCode, body: redacted, requestID: tokenEndpointRequestID(resp))
}

/// POSTs a JSON body to the token endpoint and returns the response with its body read.
func postToTokenEndpoint(_ transport: HTTPTransport, url: String, body: Data, beta: String) async throws -> (HTTPResponse, Data) {
    guard let u = URL(string: url) else { throw CredentialsError("Invalid token endpoint URL \(pythonStringRepr(url))") }
    var headers = HTTPHeaders()
    headers["anthropic-beta"] = beta
    headers["Content-Type"] = "application/json"
    headers["User-Agent"] = credentialsUserAgent()
    let request = HTTPRequest(method: "POST", url: u, headers: headers, body: body, timeout: Timeout(TOKEN_EXCHANGE_TIMEOUT))
    let resp = try await transport.send(request, stream: false)
    return (resp, try await resp.read())
}

/// The token-exchange transport a provider owns or borrows (the Python `httpx2.Client`).
final class TokenTransport: @unchecked Sendable {
    private let lock = NSLock()
    private var borrowed: HTTPTransport?
    private var owned: HTTPTransport?

    init(_ borrowed: HTTPTransport?) { self.borrowed = borrowed }

    /// The transport to use, lazily creating (and owning) a `URLSessionTransport` if none was given.
    func get() -> HTTPTransport {
        lock.withLock {
            if let borrowed { return borrowed }
            if let owned { return owned }
            let t = URLSessionTransport()
            owned = t
            return t
        }
    }

    /// Closes the transport if this object created it.
    func close() async {
        let t: HTTPTransport? = lock.withLock {
            defer { owned = nil }
            return owned
        }
        await t?.close()
    }
}

/// Exchanges an external OIDC JWT for an Anthropic access token via the RFC 7523 `jwt-bearer`
/// grant (`WorkloadIdentityCredentials`).
///
/// Calling it performs a *fresh* token exchange. Wrap it in a `TokenCache` (done automatically
/// when passed as `credentials:` to `Anthropic`) to avoid exchanging on every request.
public final class WorkloadIdentityCredentials: BaseURLBoundProvider, @unchecked Sendable {
    let identityTokenProvider: any IdentityTokenProvider
    let federationRuleID: String
    let organizationID: String
    let serviceAccountID: String?
    let workspaceID: String?
    /// Informational only: the server derives the effective scope from the federation rule.
    public let scope: String?
    let transport: TokenTransport
    /// Whether `close()` closes `transport` (false for a copy made by `forBaseURL`).
    private var ownsTransport: Bool
    private let lock = NSLock()
    private var boundBaseURL: String?

    /// - Parameters:
    ///   - identityTokenProvider: Returns the external JWT; called on every exchange, since the
    ///     underlying file (e.g. a Kubernetes projected token) may have rotated.
    ///   - organizationID: The organization's raw UUID string.
    ///   - workspaceID: Optional `wrkspc_*` tagged ID, or `"default"` for the organization's
    ///     default workspace. The minted token is workspace-scoped.
    ///   - transport: The HTTP transport for the exchange; a `URLSessionTransport` is created (and
    ///     closed by `close()`) when omitted.
    public init(identityTokenProvider: any IdentityTokenProvider, federationRuleID: String, organizationID: String,
                serviceAccountID: String? = nil, workspaceID: String? = nil, scope: String? = nil,
                transport: HTTPTransport? = nil)
    {
        self.identityTokenProvider = identityTokenProvider
        self.federationRuleID = federationRuleID
        self.organizationID = organizationID
        self.serviceAccountID = serviceAccountID
        self.workspaceID = workspaceID
        self.scope = scope
        self.transport = TokenTransport(transport)
        self.ownsTransport = transport == nil
    }

    public convenience init(identityTokenProvider: @escaping @Sendable () async throws -> String, federationRuleID: String,
                            organizationID: String, serviceAccountID: String? = nil, workspaceID: String? = nil,
                            scope: String? = nil, transport: HTTPTransport? = nil)
    {
        self.init(identityTokenProvider: IdentityTokenProviderFunction(identityTokenProvider), federationRuleID: federationRuleID,
                  organizationID: organizationID, serviceAccountID: serviceAccountID, workspaceID: workspaceID, scope: scope,
                  transport: transport)
    }

    private init(copying other: WorkloadIdentityCredentials) {
        identityTokenProvider = other.identityTokenProvider
        federationRuleID = other.federationRuleID
        organizationID = other.organizationID
        serviceAccountID = other.serviceAccountID
        workspaceID = other.workspaceID
        scope = other.scope
        transport = TokenTransport(other.transport.get())
        ownsTransport = false
        boundBaseURL = other.lock.withLock { other.boundBaseURL }
    }

    var baseURL: String { lock.withLock { boundBaseURL } ?? DEFAULT_CREDENTIALS_BASE_URL }

    /// Sets the API base URL the token exchange POSTs to. For standalone use; clients bind through
    /// `forBaseURL`, which never rebinds an instance another client is already exchanging through.
    public func bindBaseURL(_ baseURL: String) throws {
        let bound = trimTrailingSlashes(baseURL)
        try requireHTTPS(bound, field: "base_url")
        lock.withLock { boundBaseURL = bound }
    }

    /// Binds in place, unless another client already bound this instance to a different host; then
    /// returns a copy bound to `baseURL` that shares the identity token and borrows (never closes)
    /// this instance's transport.
    public func forBaseURL(_ baseURL: String) throws -> any AccessTokenProvider {
        let bound = trimTrailingSlashes(baseURL)
        var provider = self
        let current = lock.withLock { boundBaseURL }
        if let current, current != bound { provider = WorkloadIdentityCredentials(copying: self) }
        try provider.bindBaseURL(bound)
        return provider
    }

    /// Closes the transport if this instance created it.
    public func close() async {
        if lock.withLock({ ownsTransport }) { await transport.close() }
    }

    public func callAsFunction(forceRefresh: Bool) async throws -> AccessToken {
        // forceRefresh is a no-op: this provider has no cache to bypass.
        let jwt = try await identityTokenProvider()
        let assertionBytes = jwt.utf8.count
        if assertionBytes > MAX_ASSERTION_BYTES {
            throw WorkloadIdentityError(
                "Identity token assertion is \(assertionBytes) bytes, which exceeds the \(MAX_ASSERTION_BYTES)-byte limit. This is almost certainly not a JWT — check that the identity-token path points at the projected token, not a key or cert."
            )
        }

        var body = SecretPayload([
            "grant_type": .string(GRANT_TYPE_JWT_BEARER),
            "assertion": .string(jwt),
            "federation_rule_id": .string(federationRuleID),
            "organization_id": .string(organizationID),
        ])
        if let serviceAccountID { body["service_account_id"] = .string(serviceAccountID) }
        if let workspaceID { body["workspace_id"] = .string(workspaceID) }

        let url = "\(baseURL)\(TOKEN_ENDPOINT)"
        let resp: HTTPResponse
        let content: Data
        do {
            (resp, content) = try await postToTokenEndpoint(transport.get(), url: url, body: try body.serialized(), beta: JWT_BEARER_BETA_HEADER)
        } catch let e as CancellationError {
            throw e
        } catch {
            throw WorkloadIdentityError("Failed to reach token endpoint \(url): \(error)")
        }

        let requestID = tokenEndpointRequestID(resp)
        if content.count > MAX_TOKEN_RESPONSE_BYTES {
            throw WorkloadIdentityError(
                "Token endpoint response body exceeds \(MAX_TOKEN_RESPONSE_BYTES) bytes (got \(content.count)); refusing to parse.",
                statusCode: resp.statusCode, requestID: requestID)
        }

        if resp.statusCode >= 400 {
            // A 401 is almost always a federation-rule mismatch.
            var hint: String? = nil
            if resp.statusCode == 401 {
                var h = "Ensure your federation rule matches your identity token. "
                if workspaceID == nil {
                    h += "If your federation rule is scoped to multiple workspaces, set the ANTHROPIC_WORKSPACE_ID environment variable, the 'workspace_id' config key, or the workspace_id= argument. "
                }
                h += "View your authentication events in the Workload identity page of Claude Console for more details."
                hint = h
            }
            throw tokenEndpointError(resp, body: content, messagePrefix: "Token exchange failed", hint: hint)
        }

        let data: SecretPayload
        do {
            data = try SecretPayload.parse(content)
        } catch let err as NonObjectPayloadError {
            throw WorkloadIdentityError(
                "Token endpoint returned a JSON \(err.typeName) (status \(resp.statusCode)); expected an object.",
                statusCode: resp.statusCode, requestID: requestID)
        } catch {
            let redacted = redactBody(.string(String(decoding: content, as: UTF8.self)))
            throw WorkloadIdentityError(
                "Token endpoint returned non-JSON response (status \(resp.statusCode)): \(pythonStr(redacted))",
                statusCode: resp.statusCode, body: redacted, requestID: requestID)
        }

        if let tokenType = data["token_type"], !tokenType.isNull, pythonStringValue(tokenType).lowercased() != "bearer" {
            throw WorkloadIdentityError(
                "Token endpoint returned unsupported token_type \(pythonRepr(tokenType)) (expected 'Bearer').",
                statusCode: resp.statusCode, body: redactBody(.object(data.values)), requestID: requestID)
        }

        guard case .string(let token)? = data["access_token"], let expiresIn = pythonInt(data["expires_in"]),
              case (let expiresAt, false) = Int(Date().timeIntervalSince1970).addingReportingOverflow(expiresIn)
        else {
            throw WorkloadIdentityError(
                "Token endpoint response missing required fields (access_token / expires_in).",
                statusCode: resp.statusCode, body: redactBody(.object(data.values)), requestID: requestID)
        }
        return AccessToken(token: token, expiresAt: expiresAt)
    }
}

/// Performs a single RFC 7523 `jwt-bearer` exchange and returns the resulting `AccessToken`
/// (`exchange_federation_assertion`): no caching, no provider plumbing.
public func exchangeFederationAssertion(assertion: String, federationRuleID: String, organizationID: String,
                                        serviceAccountID: String? = nil, workspaceID: String? = nil,
                                        baseURL: String? = nil, transport: HTTPTransport? = nil) async throws -> AccessToken
{
    let creds = WorkloadIdentityCredentials(
        identityTokenProvider: IdentityTokenProviderFunction { assertion }, federationRuleID: federationRuleID,
        organizationID: organizationID, serviceAccountID: serviceAccountID, workspaceID: workspaceID, transport: transport)
    if let baseURL { try creds.bindBaseURL(baseURL) }
    do {
        let token = try await creds()
        await creds.close()
        return token
    } catch {
        await creds.close()
        throw error
    }
}

func trimTrailingSlashes(_ s: String) -> String {
    var s = s
    while s.hasSuffix("/") { s.removeLast() }
    return s
}
