import Foundation

/// Port of `anthropic/lib/credentials/_providers.py`.

/// Discriminator for the credentials file's `type` field.
let CREDENTIALS_FILE_TYPE = "oauth_token"
let CONFIG_FILE_VERSION = "1.0"
let CREDENTIALS_FILE_VERSION = "1.0"
/// Discriminator values for the config file's `authentication.type` field.
let AUTH_TYPE_OIDC_FEDERATION = "oidc_federation"
let AUTH_TYPE_USER_OAUTH = "user_oauth"

/// Parses a credentials-file `expires_at` field into Unix seconds.
func coerceExpiresAt(_ value: JSONValue?, source: URL?) throws -> Int? {
    guard let value, !value.isNull else { return nil }
    if let i = pythonInt(value) { return i }
    let whereText = source.map { "credentials file at \($0.path)" } ?? "credentials"
    throw CredentialsError(
        "\(whereText) has invalid 'expires_at' \(pythonRepr(value)); expected an integer Unix timestamp in seconds. The SDK does not parse ISO8601 — convert with int(datetime.timestamp()) before writing the file."
    )
}

/// Fills empty profile fields from the corresponding `ANTHROPIC_*` environment variables. The
/// profile file is authoritative — this only fills fields the file left unset.
func fillMissingFromEnv(_ config: inout [String: JSONValue], _ auth: inout [String: JSONValue], _ env: CredentialEnvironment) {
    func fill(_ target: inout [String: JSONValue], _ key: String, _ envVar: String) {
        if !isTruthy(target[key]), let v = env.nonEmpty(envVar) { target[key] = .string(v) }
    }
    fill(&config, "base_url", ENV_BASE_URL)
    fill(&config, "organization_id", ENV_ORGANIZATION_ID)
    fill(&config, "workspace_id", ENV_WORKSPACE_ID)

    let authType = auth["type"]?.stringValue
    if authType == AUTH_TYPE_OIDC_FEDERATION {
        fill(&auth, "federation_rule_id", ENV_FEDERATION_RULE_ID)
        fill(&auth, "service_account_id", ENV_SERVICE_ACCOUNT_ID)
        fill(&auth, "scope", ENV_SCOPE)
        if !isTruthy(auth["identity_token"]), let v = env.nonEmpty(ENV_IDENTITY_TOKEN_FILE) {
            auth["identity_token"] = ["source": "file", "path": .string(v)]
        }
    } else if authType == AUTH_TYPE_USER_OAUTH {
        fill(&auth, "scope", ENV_SCOPE)
    }
}

/// Always returns a fixed token with no expiry (`StaticToken`).
public struct StaticToken: AccessTokenProvider {
    let token: String
    public init(_ token: String) { self.token = token }
    public func callAsFunction(forceRefresh: Bool) async throws -> AccessToken { AccessToken(token: token, expiresAt: nil) }
}

/// Reads `ANTHROPIC_AUTH_TOKEN` (or another variable) at call time (`EnvToken`).
public struct EnvToken: AccessTokenProvider {
    let envVar: String
    let environment: CredentialEnvironment

    public init(_ envVar: String = "ANTHROPIC_AUTH_TOKEN", environment: CredentialEnvironment = .process) {
        self.envVar = envVar
        self.environment = environment
    }

    public func callAsFunction(forceRefresh: Bool) async throws -> AccessToken {
        guard let value = environment[envVar] else {
            throw CredentialsError(
                "Environment variable \(envVar) is not set. Set it or pass an explicit `credentials=` provider to the client.")
        }
        return AccessToken(token: value, expiresAt: nil)
    }
}

/// Reads a JWT from a file on every call (`IdentityTokenFile`).
///
/// Kubernetes projected service-account tokens (and similar) are rotated in place, so the file is
/// re-read on every invocation rather than cached.
public struct IdentityTokenFile: IdentityTokenProvider {
    public let path: URL

    /// - Parameter path: The token file; defaults to `ANTHROPIC_IDENTITY_TOKEN_FILE`.
    public init(_ path: String? = nil, environment: CredentialEnvironment = .process) throws {
        guard let resolved = resolveIdentityTokenPath(path, environment) else {
            throw CredentialsError(
                "No identity token file path given. Pass `path=` or set the \(ENV_IDENTITY_TOKEN_FILE) environment variable.")
        }
        self.path = resolved
    }

    public init(url: URL) { self.path = url }

    public func callAsFunction() async throws -> String {
        let p = path.path
        let bytes: Data
        do {
            bytes = try readFileBytes(p)
        } catch let err as FileSystemError {
            if err.isNotFound { throw IdentityTokenFileError("Identity token file not found at \(p).", path: path) }
            if err.isPermissionDenied {
                throw IdentityTokenFileError(
                    "Identity token file at \(p) is not readable by this process: \(err). Check the file mode and the effective uid of the process.",
                    path: path)
            }
            if err.isDirectory {
                throw IdentityTokenFileError(
                    "Identity token path \(p) is a directory, not a file. Point at the projected token file itself.", path: path)
            }
            throw IdentityTokenFileError("Identity token file at \(p) could not be read: \(err)", path: path)
        }
        guard let text = String(validatingUTF8Data: bytes) else {
            throw IdentityTokenFileError("Identity token file at \(p) could not be read: 'utf-8' codec can't decode the file contents", path: path)
        }
        let content = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if content.isEmpty {
            throw IdentityTokenFileError(
                "Identity token file at \(p) is empty. If this is a Kubernetes projected service-account token, check the volume mount and the serviceAccountToken projection audience.",
                path: path)
        }
        return content
    }
}

extension String {
    init?(validatingUTF8Data data: Data) {
        guard let s = String(data: data, encoding: .utf8) else { return nil }
        self = s
    }
}

/// A credentials file vanished between the existence check and the read.
final class CredentialsFileNotFoundError: CredentialsError, @unchecked Sendable {}

/// An access-token provider backed by a named profile (`CredentialsFile`).
///
/// A profile is a pair of files under the config directory (`~/.config/anthropic/` by default;
/// override with `ANTHROPIC_CONFIG_DIR`):
///
/// * `configs/<profile>.json` — non-secret. Holds the nested `"authentication"` object
///   (discriminated by its `"type"` field), plus top-level `organization_id`, `workspace_id`, and
///   `base_url`. The `authentication` object may contain a `credentials_path` field overriding the
///   credentials file location.
/// * `credentials/<profile>.json` — secret (0600). Holds `access_token`, `expires_at`, and (for
///   `user_oauth` with a `client_id`) `refresh_token`.
///
/// `"oidc_federation"` profiles exchange an identity token through a `WorkloadIdentityCredentials`
/// delegate (caching the minted token in the credentials file). `"user_oauth"` profiles with a
/// `client_id` run `refresh_token` grants on expiry and write the new tokens back atomically;
/// without a `client_id` the credentials file is treated as externally rotated and re-read on every
/// call.
public class CredentialsFile: BaseURLBoundProvider, @unchecked Sendable {
    public let profile: String
    public let configPath: URL
    let environment: CredentialEnvironment
    let lock = NSLock()
    var boundBaseURL: String?
    var transport: TokenTransport
    var ownsTransport: Bool
    var config: [String: JSONValue]?
    var credentialsPath: URL?
    var resolvedExchangeBaseURL: String = DEFAULT_CREDENTIALS_BASE_URL
    var workloadDelegate: WorkloadIdentityCredentials?

    /// - Parameters:
    ///   - profile: Profile name; `nil` resolves `ANTHROPIC_PROFILE` → `<config_dir>/active_config` →
    ///     `"default"`.
    ///   - transport: The HTTP transport for token requests; one is created (and closed by
    ///     `close()`) when omitted.
    ///   - environment: Where `ANTHROPIC_*` variables are read from.
    public init(profile: String? = nil, transport: HTTPTransport? = nil, environment: CredentialEnvironment = .process) throws {
        self.environment = environment
        self.profile = try profile ?? activeProfile(environment)
        self.configPath = try configFilePath(self.profile, environment)
        self.transport = TokenTransport(transport)
        self.ownsTransport = transport == nil
    }

    init(profile: String, configPath: URL, config: [String: JSONValue]?, transport: HTTPTransport?, environment: CredentialEnvironment) {
        self.profile = profile
        self.configPath = configPath
        self.config = config
        self.transport = TokenTransport(transport)
        self.ownsTransport = transport == nil
        self.environment = environment
    }

    /// A copy that borrows this instance's transport and has no delegate or credentials path yet.
    func makeCopy() -> CredentialsFile {
        let c = CredentialsFile(profile: profile, configPath: configPath, config: lock.withLock { config },
                                transport: transport.get(), environment: environment)
        copyState(to: c)
        return c
    }

    func copyState(to c: CredentialsFile) {
        lock.withLock {
            c.boundBaseURL = boundBaseURL
            c.resolvedExchangeBaseURL = resolvedExchangeBaseURL
        }
    }

    /// The `base_url` declared in the profile config, if any (loads the config on first access).
    ///
    /// `nil` when the config has no top-level `base_url`: callers fall back to their own default, so
    /// a profile that doesn't pin a host never overrides an explicit client setting.
    public var resolvedBaseURL: String? {
        get throws {
            let config = try loadConfig()
            guard let raw = config["base_url"], isTruthy(raw) else { return nil }
            return trimTrailingSlashes(pythonStringValue(raw))
        }
    }

    /// Adopts the owning client's base URL as the token-exchange fallback (between the config
    /// file's own `base_url` and the default). Rebinding affects every client holding this
    /// instance; clients bind through `forBaseURL`.
    public func bindBaseURL(_ baseURL: String) throws {
        let bound = trimTrailingSlashes(baseURL)
        try requireHTTPS(bound, field: "\(configPath.path): base_url")
        let loaded: [String: JSONValue]? = lock.withLock {
            boundBaseURL = bound
            return config
        }
        if let loaded {
            let resolved = resolveBaseURL(loaded)
            lock.withLock { resolvedExchangeBaseURL = resolved }
            try requireHTTPS(resolved, field: "\(configPath.path): base_url")
        }
    }

    /// Binds in place, unless another client already bound this instance to a different host.
    /// Then: a profile that pins its own `base_url` returns `self` (the bind is moot); an
    /// `oidc_federation` profile returns a copy bound to `baseURL` (sharing the identity token and
    /// transport, but not the on-disk token cache); a `user_oauth` profile returns `self`, since its
    /// refresh token belongs to the deployment that issued it.
    public func forBaseURL(_ baseURL: String) throws -> any AccessTokenProvider {
        let bound = trimTrailingSlashes(baseURL)
        let current = lock.withLock { boundBaseURL }
        if current == nil || current == bound {
            try bindBaseURL(bound)
            return self
        }
        let config = try loadConfig()
        let authType = try authBlock()["type"]?.stringValue
        if isTruthy(config["base_url"]) || authType != AUTH_TYPE_OIDC_FEDERATION {
            return self
        }
        let provider = makeCopy()
        provider.lock.withLock {
            provider.workloadDelegate = nil
            provider.credentialsPath = nil
        }
        try provider.bindBaseURL(bound)
        return provider
    }

    /// `base_url` precedence: top-level config field → bound (the owning client's) → default.
    func resolveBaseURL(_ config: [String: JSONValue]) -> String {
        if let raw = config["base_url"], isTruthy(raw) { return trimTrailingSlashes(pythonStringValue(raw)) }
        if let b = lock.withLock({ boundBaseURL }) { return b }
        return DEFAULT_CREDENTIALS_BASE_URL
    }

    /// Headers derived from the config (e.g. `anthropic-workspace-id`), for the client's defaults.
    /// For federation profiles the workspace goes in the exchange body instead.
    public func extraHeaders() throws -> [String: String] {
        let config = try loadConfig()
        var headers: [String: String] = [:]
        if try authBlock()["type"]?.stringValue != AUTH_TYPE_OIDC_FEDERATION {
            if let ws = config["workspace_id"], isTruthy(ws) { headers["anthropic-workspace-id"] = pythonStringValue(ws) }
        }
        return headers
    }

    /// Reads and caches the config file, resolving `base_url` and `credentials_path`. On POSIX,
    /// refuses a file that group or others can write.
    func loadConfig() throws -> [String: JSONValue] {
        if let c = lock.withLock({ config }) { return c }
        let path = configPath.path
        let raw: Data
        do {
            raw = try readFileBytes(path) { st in
                guard credentialsCheckPosixModes else { return }
                let mode = permissionBits(st)
                if mode & 0o022 != 0 {
                    throw CredentialsError(
                        "Config file at \(path) is writable by group or others (mode \(octalMode(mode))); run `chmod go-w \(path)` before retrying.")
                }
            }
        } catch let err as FileSystemError where err.isNotFound {
            throw CredentialsError(
                "Config file not found at \(path) (profile \(pythonStringRepr(profile))). Set \(ENV_PROFILE) to select a different profile, or set \(ENV_CONFIG_DIR) to relocate the config directory.")
        } catch let err as FileSystemError {
            throw CredentialsError("Config file at \(path) could not be read: \(err)")
        }
        guard String(data: raw, encoding: .utf8) != nil else {
            throw CredentialsError("Config file at \(path) could not be read: 'utf-8' codec can't decode the file contents")
        }
        let parsed: JSONValue
        do {
            parsed = try parseJSONFragment(raw)
        } catch {
            throw CredentialsError("Config file at \(path) is not valid JSON: \(error)")
        }
        guard case .object(var config) = parsed else {
            throw CredentialsError("Config file at \(path) must contain a JSON object, not \(pythonTypeName(parsed)).")
        }
        guard case .object(var auth)? = config["authentication"] else {
            throw CredentialsError(
                "Config file at \(path) is missing the 'authentication' object. Expected shape: {\"authentication\": {\"type\": \"\(AUTH_TYPE_OIDC_FEDERATION)\"|\"\(AUTH_TYPE_USER_OAUTH)\", ...}, ...}")
        }

        // Env-vars fill only what the file left empty; runs before derived state is resolved.
        fillMissingFromEnv(&config, &auth, environment)
        config["authentication"] = .object(auth)

        let base = resolveBaseURL(config)
        try requireHTTPS(base, field: "\(path): base_url")

        let credsPath: URL
        if let override = auth["credentials_path"], isTruthy(override) {
            credsPath = expandUser(pythonStringValue(override), environment)
        } else {
            credsPath = try credentialsFilePath(profile, environment)
        }
        lock.withLock {
            self.resolvedExchangeBaseURL = base
            self.credentialsPath = credsPath
            self.config = config
        }
        return config
    }

    /// Reads the credentials file. Re-reads on every call — daemons rotate it. On POSIX, refuses
    /// symlinks and any file readable or writable by group or others.
    func readCredentials() throws -> SecretPayload {
        guard let url = lock.withLock({ credentialsPath }) else { throw CredentialsError("credentials path is not set") }
        let path = url.path
        if credentialsCheckPosixModes {
            let st: stat
            do {
                st = try fileStatus(path, followSymlinks: false)
            } catch let err as FileSystemError where err.isNotFound {
                throw CredentialsFileNotFoundError("Credentials file not found at \(path) (profile \(pythonStringRepr(profile))).")
            } catch {
                throw CredentialsError("Credentials file at \(path) could not be accessed: \(error)")
            }
            if isSymlink(st) {
                throw CredentialsError(
                    "Credentials file at \(path) is a symlink; refusing to follow (move the real file into place to keep secret material on the expected filesystem).")
            }
            let mode = permissionBits(st)
            if mode & 0o077 != 0 {
                throw CredentialsError(
                    "Credentials file at \(path) is accessible by group or others (mode \(octalMode(mode))); run `chmod 600 \(path)` before retrying.")
            }
        }
        let creds: SecretPayload
        do {
            creds = try SecretPayload.parse(try readFileBytes(path))
        } catch let err as FileSystemError where err.isNotFound {
            throw CredentialsFileNotFoundError("Credentials file not found at \(path) (profile \(pythonStringRepr(profile))).")
        } catch let err as FileSystemError {
            throw CredentialsError("Credentials file at \(path) could not be read: \(err)")
        } catch let err as NonObjectPayloadError {
            throw CredentialsError("Credentials file at \(path) must contain a JSON object, not \(err.typeName).")
        } catch {
            // The decoder's message carries only position info.
            throw CredentialsError("Credentials file at \(path) is not valid JSON: \(error)")
        }

        // Validate the discriminator if present; lenient if absent.
        if let actual = creds["type"], !actual.isNull, actual != .string(CREDENTIALS_FILE_TYPE) {
            let authType = (try? authBlock())?["type"] ?? .null
            throw CredentialsError(
                "credentials file has type \(pythonRepr(actual)); expected \(pythonStringRepr(CREDENTIALS_FILE_TYPE)) for authentication.type \(pythonRepr(authType))")
        }
        return creds
    }

    /// Closes the transport if this instance created it, and the workload delegate.
    public func close() async {
        if lock.withLock({ ownsTransport }) { await transport.close() }
        let delegate = lock.withLock { workloadDelegate }
        await delegate?.close()
    }

    /// Drops the cached config so the next call re-reads it from disk (e.g. after a daemon rotates
    /// the profile in place).
    public func reload() {
        lock.withLock {
            config = nil
            workloadDelegate = nil
        }
    }

    /// Atomic write to the credentials file (never the config file).
    func atomicWriteCredentials(_ data: SecretPayload) throws {
        guard let url = lock.withLock({ credentialsPath }) else { return }
        try atomicWriteSecretFile(url, try data.serialized(pretty: true))
    }

    /// The cached `authentication` object from the config.
    func authBlock() throws -> [String: JSONValue] {
        let config = try loadConfig()
        return config["authentication"]?.objectValue ?? [:]
    }

    public func callAsFunction(forceRefresh: Bool) async throws -> AccessToken {
        let auth = try authBlock()
        let authType = auth["type"]
        if authType?.stringValue == AUTH_TYPE_OIDC_FEDERATION { return try await callOIDCFederation(auth, forceRefresh: forceRefresh) }
        if authType?.stringValue == AUTH_TYPE_USER_OAUTH { return try await callUserOAuth(auth, forceRefresh: forceRefresh) }
        throw CredentialsError(
            "Unknown authentication.type \(pythonRepr(authType ?? .null)) at \(configPath.path). Expected \(pythonStringRepr(AUTH_TYPE_OIDC_FEDERATION)) or \(pythonStringRepr(AUTH_TYPE_USER_OAUTH)).")
    }

    /// Interactive-login profile. With a `client_id` we run the `refresh_token` grant on expiry;
    /// without one the credentials file is externally rotated and just read fresh.
    func callUserOAuth(_ auth: [String: JSONValue], forceRefresh: Bool) async throws -> AccessToken {
        var creds = try readCredentials()
        let credsPath = lock.withLock { credentialsPath }
        guard let accessToken = creds["access_token"], isTruthy(accessToken) else {
            throw CredentialsError("Credentials file at \(credsPath?.path ?? "None") is missing 'access_token'.")
        }
        guard let clientID = auth["client_id"], isTruthy(clientID) else {
            let expiresAt = try coerceExpiresAt(creds["expires_at"], source: credsPath)
            return AccessToken(token: pythonStringValue(accessToken), expiresAt: expiresAt)
        }
        guard let refreshToken = creds["refresh_token"], isTruthy(refreshToken) else {
            throw WorkloadIdentityError(
                "credentials file for profile \(pythonStringRepr(profile)) (authentication.type \(pythonStringRepr(AUTH_TYPE_USER_OAUTH)) with client_id) must include 'refresh_token': \(credsPath?.path ?? "None")")
        }

        // Strict expiry only — TokenCache owns the advisory/mandatory policy. forceRefresh (after a
        // 401) bypasses the freshness short-circuit so a revoked token isn't re-served.
        let expiresAt = try coerceExpiresAt(creds["expires_at"], source: credsPath)
        if !forceRefresh, let expiresAt, Date().timeIntervalSince1970 < Double(expiresAt) {
            return AccessToken(token: pythonStringValue(accessToken), expiresAt: expiresAt)
        }

        let body = SecretPayload(["grant_type": .string(GRANT_TYPE_REFRESH_TOKEN), "refresh_token": refreshToken, "client_id": clientID])
        let base = lock.withLock { resolvedExchangeBaseURL }
        let resp: HTTPResponse
        let content: Data
        do {
            // Not the federation beta: that is only for jwt-bearer exchanges.
            (resp, content) = try await postToTokenEndpoint(transport.get(), url: "\(base)\(TOKEN_ENDPOINT)", body: try body.serialized(),
                                                            beta: OAUTH_API_BETA_HEADER)
        } catch let e as CancellationError {
            throw e
        } catch {
            throw WorkloadIdentityError("user_oauth refresh failed to reach token endpoint: \(error)")
        }
        if resp.statusCode != 200 { throw tokenEndpointError(resp, body: content, messagePrefix: "user_oauth refresh failed") }

        let payload: SecretPayload
        do {
            payload = try SecretPayload.parse(content)
        } catch let err as NonObjectPayloadError {
            throw WorkloadIdentityError(
                "user_oauth refresh returned a JSON \(err.typeName) (status \(resp.statusCode)); expected an object.",
                statusCode: resp.statusCode, requestID: tokenEndpointRequestID(resp))
        } catch {
            throw WorkloadIdentityError("user_oauth refresh returned a non-JSON response (status \(resp.statusCode)).",
                                        statusCode: resp.statusCode, requestID: tokenEndpointRequestID(resp))
        }
        guard let newAccess = payload["access_token"], isTruthy(newAccess) else {
            throw WorkloadIdentityError("user_oauth refresh response missing 'access_token'")
        }
        let rawExpiresIn = payload["expires_in"] ?? .int(3600)
        guard let expiresIn = pythonInt(rawExpiresIn),
              case (let newExpiresAt, false) = Int(Date().timeIntervalSince1970).addingReportingOverflow(expiresIn)
        else {
            throw WorkloadIdentityError(
                "user_oauth refresh response has invalid 'expires_in' \(pythonRepr(rawExpiresIn)); expected an integer number of seconds.")
        }
        let newRefresh = isTruthy(payload["refresh_token"]) ? payload["refresh_token"]! : refreshToken

        creds["version"] = .string(CREDENTIALS_FILE_VERSION)
        creds["type"] = .string(CREDENTIALS_FILE_TYPE)
        creds["access_token"] = newAccess
        creds["expires_at"] = .int(newExpiresAt)
        creds["refresh_token"] = newRefresh
        // A failed persist propagates: the refresh token may have rotated server-side.
        do {
            try atomicWriteCredentials(creds)
        } catch let err as FileSystemError {
            throw CredentialsError("Credentials file at \(credsPath?.path ?? "None") could not be written: \(err)")
        }
        return AccessToken(token: pythonStringValue(newAccess), expiresAt: newExpiresAt)
    }

    /// `readCredentials` that returns `nil` when the file is absent (the federation disk cache:
    /// a missing file just means "exchange now").
    func readCredentialsIfExists() throws -> SecretPayload? {
        guard let url = lock.withLock({ credentialsPath }), fileExists(url.path) else {
            return nil
        }
        do {
            return try readCredentials()
        } catch is CredentialsFileNotFoundError {
            return nil
        }
    }

    func callOIDCFederation(_ auth: [String: JSONValue], forceRefresh: Bool) async throws -> AccessToken {
        let delegate: WorkloadIdentityCredentials
        if let d = lock.withLock({ workloadDelegate }) {
            delegate = d
        } else {
            delegate = try buildWorkloadDelegate(auth)
            lock.withLock { workloadDelegate = delegate }
        }

        // Disk cache: an unexpired token from a prior exchange is returned instead of re-exchanging.
        // `InMemoryConfig` without a `credentials_path` opts out of it.
        if lock.withLock({ credentialsPath }) == nil { return try await delegate() }

        let cached = try readCredentialsIfExists()
        if !forceRefresh, let cached, let accessToken = cached["access_token"], isTruthy(accessToken),
           let expiresAt = cached["expires_at"], !expiresAt.isNull,
           let expiresAtFloat = pythonFloat(expiresAt),
           Date().timeIntervalSince1970 < expiresAtFloat - Double(MANDATORY_REFRESH_SECONDS),
           let expiresAtInt = pythonInt(expiresAt)
        {
            return AccessToken(token: pythonStringValue(accessToken), expiresAt: expiresAtInt)
        }

        let token = try await delegate()
        var updated = cached ?? SecretPayload()
        updated["version"] = .string(CREDENTIALS_FILE_VERSION)
        updated["type"] = .string(CREDENTIALS_FILE_TYPE)
        updated["access_token"] = .string(token.token)
        updated["expires_at"] = token.expiresAt.map { .int($0) } ?? .null
        do {
            try atomicWriteCredentials(updated)
        } catch {
            CredentialsLog.debug("federation token disk-cache write-back failed (best-effort): \(error)")
        }
        return token
    }

    func buildWorkloadDelegate(_ auth: [String: JSONValue]) throws -> WorkloadIdentityCredentials {
        let config = try loadConfig()
        guard let ruleID = auth["federation_rule_id"], isTruthy(ruleID), let orgID = config["organization_id"], isTruthy(orgID) else {
            throw WorkloadIdentityError(
                "config file with authentication.type \(pythonStringRepr(AUTH_TYPE_OIDC_FEDERATION)) must include 'authentication.federation_rule_id' and top-level 'organization_id': \(configPath.path)")
        }

        // identity_token is a discriminated object so future variants slot in; v1 implements
        // source "file" only. Absent → ANTHROPIC_IDENTITY_TOKEN_FILE.
        var identityTokenPath: String? = nil
        if let cfg = auth["identity_token"], !cfg.isNull {
            let source = cfg["source"] ?? .null
            if source != .string("file") {
                throw CredentialsError("identity_token source \(pythonRepr(source)) is not supported; only 'file' is implemented")
            }
            guard let p = cfg["path"], isTruthy(p) else {
                // The source explicitly says "file", which has no meaning without a path.
                throw CredentialsError(
                    "identity_token source 'file' requires a non-empty path; profile \(pythonStringRepr(profile)) at \(configPath.path) has identity_token=\(pythonRepr(cfg)).")
            }
            identityTokenPath = pythonStringValue(p)
        }
        let provider = try IdentityTokenFile(identityTokenPath, environment: environment)
        return try makeDelegate(provider, ruleID: ruleID, orgID: orgID, auth: auth, config: config)
    }

    /// The delegate borrows our transport, so `close()` here stays the single closer.
    func makeDelegate(_ provider: any IdentityTokenProvider, ruleID: JSONValue, orgID: JSONValue, auth: [String: JSONValue],
                      config: [String: JSONValue]) throws -> WorkloadIdentityCredentials
    {
        let delegate = WorkloadIdentityCredentials(
            identityTokenProvider: provider, federationRuleID: pythonStringValue(ruleID), organizationID: pythonStringValue(orgID),
            serviceAccountID: auth["service_account_id"].flatMap { $0.isNull ? nil : pythonStringValue($0) },
            workspaceID: config["workspace_id"].flatMap { $0.isNull ? nil : pythonStringValue($0) },
            scope: auth["scope"].flatMap { $0.isNull ? nil : pythonStringValue($0) },
            transport: transport.get())
        try delegate.bindBaseURL(lock.withLock { resolvedExchangeBaseURL })
        return delegate
    }
}

/// An access-token provider driven by an in-memory config (same shape as
/// `configs/<profile>.json`) rather than files on disk (`InMemoryConfig`).
///
/// * `"oidc_federation"`: `authentication.credentials_path` is optional. If set, exchanged tokens
///   are cached in that file; if omitted, every call performs a fresh exchange.
/// * `"user_oauth"`: `authentication.credentials_path` is required — it is where the
///   access/refresh tokens live.
public final class InMemoryConfig: CredentialsFile, @unchecked Sendable {
    static let inMemoryPath = URL(fileURLWithPath: "<in-memory config>")
    let identityTokenProviderOverride: (any IdentityTokenProvider)?

    /// - Parameters:
    ///   - config: The profile config.
    ///   - identityTokenProvider: Supplies the identity token instead of `identity_token` /
    ///     `ANTHROPIC_IDENTITY_TOKEN_FILE`.
    ///   - transport: The HTTP transport for token requests.
    public init(_ config: [String: JSONValue], identityTokenProvider: (any IdentityTokenProvider)? = nil,
                transport: HTTPTransport? = nil, environment: CredentialEnvironment = .process) throws
    {
        guard case .object(let auth)? = config["authentication"] else {
            throw CredentialsError(
                "config dict is missing the 'authentication' object. Expected shape: {\"authentication\": {\"type\": \"\(AUTH_TYPE_OIDC_FEDERATION)\"|\"\(AUTH_TYPE_USER_OAUTH)\", ...}, ...}")
        }
        let authType = auth["type"] ?? .null
        if authType != .string(AUTH_TYPE_OIDC_FEDERATION) && authType != .string(AUTH_TYPE_USER_OAUTH) {
            throw CredentialsError(
                "Unknown authentication.type \(pythonRepr(authType)). Expected \(pythonStringRepr(AUTH_TYPE_OIDC_FEDERATION)) or \(pythonStringRepr(AUTH_TYPE_USER_OAUTH)).")
        }
        let credsPath = auth["credentials_path"]
        if authType == .string(AUTH_TYPE_USER_OAUTH) && !isTruthy(credsPath) {
            throw CredentialsError(
                "authentication.type \(pythonStringRepr(AUTH_TYPE_USER_OAUTH)) requires 'authentication.credentials_path' (where the access/refresh tokens live). For profile-based resolution, use CredentialsFile instead.")
        }
        self.identityTokenProviderOverride = identityTokenProvider
        super.init(profile: "<in-memory>", configPath: Self.inMemoryPath, config: config, transport: transport, environment: environment)
        if let credsPath, isTruthy(credsPath) { self.credentialsPath = expandUser(pythonStringValue(credsPath), environment) }
        self.resolvedExchangeBaseURL = resolveBaseURL(config)
        try requireHTTPS(resolvedExchangeBaseURL, field: "config: base_url")
    }

    public convenience init(_ config: [String: JSONValue], identityTokenProvider: @escaping @Sendable () async throws -> String,
                            transport: HTTPTransport? = nil, environment: CredentialEnvironment = .process) throws
    {
        try self.init(config, identityTokenProvider: IdentityTokenProviderFunction(identityTokenProvider), transport: transport,
                      environment: environment)
    }

    private init(copying other: InMemoryConfig) {
        identityTokenProviderOverride = other.identityTokenProviderOverride
        super.init(profile: other.profile, configPath: other.configPath, config: other.lock.withLock { other.config },
                   transport: other.transport.get(), environment: other.environment)
    }

    override func makeCopy() -> CredentialsFile {
        let c = InMemoryConfig(copying: self)
        copyState(to: c)
        return c
    }

    override func loadConfig() throws -> [String: JSONValue] { lock.withLock { config } ?? [:] }

    /// The config is fixed at construction; only the workload delegate is dropped, so a re-exchange
    /// picks up rotated identity-token state.
    public override func reload() { lock.withLock { workloadDelegate = nil } }

    override func buildWorkloadDelegate(_ auth: [String: JSONValue]) throws -> WorkloadIdentityCredentials {
        guard let override = identityTokenProviderOverride else { return try super.buildWorkloadDelegate(auth) }
        let config = try loadConfig()
        guard let ruleID = auth["federation_rule_id"], isTruthy(ruleID), let orgID = config["organization_id"], isTruthy(orgID) else {
            throw WorkloadIdentityError(
                "config dict with authentication.type \(pythonStringRepr(AUTH_TYPE_OIDC_FEDERATION)) must include 'authentication.federation_rule_id' and top-level 'organization_id'")
        }
        return try makeDelegate(override, ruleID: ruleID, orgID: orgID, auth: auth, config: config)
    }
}
