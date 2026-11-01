import Foundation

/// Port of `anthropic/lib/credentials/_chain.py`.

/// Reads `ANTHROPIC_IDENTITY_TOKEN` on every call, so a rotated value is picked up at the next
/// token exchange.
struct EnvIdentityToken: IdentityTokenProvider {
    let environment: CredentialEnvironment

    func callAsFunction() async throws -> String {
        guard let value = environment[ENV_IDENTITY_TOKEN] else {
            throw CredentialsError(
                "\(ENV_IDENTITY_TOKEN) is not set; the workload-identity chain selected this provider at construction time but the env var is no longer present.")
        }
        return value
    }
}

/// The env-var federation path (step 4); `nil` unless the required trio is fully set.
func buildFederationResult(baseURL: String, environment env: CredentialEnvironment, transport: HTTPTransport?) throws -> CredentialResult? {
    guard let ruleID = env.nonEmpty(ENV_FEDERATION_RULE_ID), let orgID = env.nonEmpty(ENV_ORGANIZATION_ID) else { return nil }
    let hasLiteralToken = env.nonEmpty(ENV_IDENTITY_TOKEN) != nil
    let tokenPath = resolveIdentityTokenPath(nil, env)
    if !hasLiteralToken && tokenPath == nil { return nil }

    let identityProvider: any IdentityTokenProvider = tokenPath.map { IdentityTokenFile(url: $0) } ?? EnvIdentityToken(environment: env)
    let provider = WorkloadIdentityCredentials(
        identityTokenProvider: identityProvider, federationRuleID: ruleID, organizationID: orgID,
        serviceAccountID: env[ENV_SERVICE_ACCOUNT_ID],
        // An empty CI variable must not put `"workspace_id": ""` on the wire.
        workspaceID: env.nonEmpty(ENV_WORKSPACE_ID),
        scope: env[ENV_SCOPE], transport: transport)
    try provider.bindBaseURL(baseURL)
    return CredentialResult(provider: provider)
}

/// Resolves a `CredentialResult` from the environment, first match wins (`default_credentials`).
///
/// 1. `ANTHROPIC_API_KEY` → `nil`, so the client sends the key itself.
/// 2. `ANTHROPIC_AUTH_TOKEN` → `StaticToken` (Bearer).
/// 3. `ANTHROPIC_PROFILE` → the profile it names; failures propagate.
/// 4. `ANTHROPIC_FEDERATION_RULE_ID` + `ANTHROPIC_ORGANIZATION_ID` +
///    `ANTHROPIC_IDENTITY_TOKEN[_FILE]` → a direct jwt-bearer exchange via
///    `WorkloadIdentityCredentials`. It sits between the explicit and the active profile, so a
///    machine with WIF env vars uses WIF even if a leftover profile exists on disk.
/// 5. The active profile on disk (the one `active_config` points at, else `default`). Failures
///    propagate when `ANTHROPIC_CONFIG_DIR` is set or the `active_config` pointer exists, and are
///    otherwise swallowed.
///
/// Returns `nil` when nothing matches.
///
/// - Parameters:
///   - transport: The HTTP transport the providers use for token requests (the client passes its
///     own); providers create one when omitted.
public func defaultCredentials(baseURL: String = "https://api.anthropic.com", environment: CredentialEnvironment = .process,
                               transport: HTTPTransport? = nil) throws -> CredentialResult?
{
    let env = environment
    if env.nonEmpty(ENV_API_KEY) != nil { return nil }

    if let authToken = env.nonEmpty(ENV_AUTH_TOKEN) { return CredentialResult(provider: StaticToken(authToken)) }

    if env.nonEmpty(ENV_PROFILE) != nil {
        let file = try CredentialsFile(transport: transport, environment: env)
        try file.bindBaseURL(baseURL)
        let headers = try file.extraHeaders()
        return CredentialResult(provider: file, extraHeaders: headers, baseURL: try file.resolvedBaseURL)
    }

    if let federation = try buildFederationResult(baseURL: baseURL, environment: env, transport: transport) { return federation }

    let userConfigured = env.nonEmpty(ENV_CONFIG_DIR) != nil || hasExplicitActiveConfig(env)
    if userConfigured || hasActiveProfileConfig(env) {
        let file = try CredentialsFile(transport: transport, environment: env)
        try file.bindBaseURL(baseURL)
        let headers: [String: String]
        do {
            headers = try file.extraHeaders()
        } catch let err as AnthropicError {
            if userConfigured { throw err }
            return nil
        }
        return CredentialResult(provider: file, extraHeaders: headers, baseURL: try file.resolvedBaseURL)
    }
    return nil
}
