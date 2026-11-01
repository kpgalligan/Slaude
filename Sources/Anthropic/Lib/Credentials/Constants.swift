import Foundation

/// Port of `anthropic/lib/credentials/_constants.py`.

public let GRANT_TYPE_JWT_BEARER = "urn:ietf:params:oauth:grant-type:jwt-bearer"
public let GRANT_TYPE_REFRESH_TOKEN = "refresh_token"
public let TOKEN_ENDPOINT = "/v1/oauth/token"

/// Seconds to wait on the `/v1/oauth/token` POST before giving up.
let TOKEN_EXCHANGE_TIMEOUT: TimeInterval = 30.0

/// Beta header required on any authenticated API request that uses a Bearer token obtained via
/// OAuth/federation, and on `refresh_token` grants against `/v1/oauth/token`.
public let OAUTH_API_BETA_HEADER = "oauth-2025-04-20"

/// Beta header for `/v1/oauth/token` jwt-bearer grants. Only sent on jwt-bearer exchanges.
public let FEDERATION_BETA_HEADER = "oidc-federation-2026-04-01"

/// Proactive refresh thresholds (seconds before expiry). Tuned for ≤10min token TTL.
public let ADVISORY_REFRESH_SECONDS = 120
public let MANDATORY_REFRESH_SECONDS = 30

let DEFAULT_PROFILE = "default"
let DEFAULT_CREDENTIALS_BASE_URL = "https://api.anthropic.com"

let ENV_API_KEY = "ANTHROPIC_API_KEY"
let ENV_AUTH_TOKEN = "ANTHROPIC_AUTH_TOKEN"
let ENV_CONFIG_DIR = "ANTHROPIC_CONFIG_DIR"
let ENV_PROFILE = "ANTHROPIC_PROFILE"
let ENV_IDENTITY_TOKEN = "ANTHROPIC_IDENTITY_TOKEN"
let ENV_IDENTITY_TOKEN_FILE = "ANTHROPIC_IDENTITY_TOKEN_FILE"
let ENV_FEDERATION_RULE_ID = "ANTHROPIC_FEDERATION_RULE_ID"
let ENV_ORGANIZATION_ID = "ANTHROPIC_ORGANIZATION_ID"
let ENV_SERVICE_ACCOUNT_ID = "ANTHROPIC_SERVICE_ACCOUNT_ID"
let ENV_WORKSPACE_ID = "ANTHROPIC_WORKSPACE_ID"
let ENV_SCOPE = "ANTHROPIC_SCOPE"
let ENV_BASE_URL = "ANTHROPIC_BASE_URL"

/// `User-Agent` value sent on token-endpoint POSTs.
func credentialsUserAgent() -> String { "anthropic-swift/\(ANTHROPIC_SDK_VERSION)" }

/// The home directory: `HOME` from the environment, else the user's home.
func homeDirectory(_ env: CredentialEnvironment) -> URL {
    if let home = env.nonEmpty("HOME") { return URL(fileURLWithPath: home, isDirectory: true) }
    return URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
}

/// `pathlib.Path(p).expanduser()`.
func expandUser(_ path: String, _ env: CredentialEnvironment) -> URL {
    if path == "~" { return homeDirectory(env) }
    if path.hasPrefix("~/") { return homeDirectory(env).appendingPathComponent(String(path.dropFirst(2))) }
    return URL(fileURLWithPath: path)
}

/// Resolves the config directory: `ANTHROPIC_CONFIG_DIR` → platform default.
///
/// Platform defaults: `~/.config/anthropic/` on Linux and macOS (XDG-style on both), and
/// `%APPDATA%\Anthropic\` on Windows.
func credentialsConfigDir(_ env: CredentialEnvironment) -> URL {
    if let dir = env.nonEmpty(ENV_CONFIG_DIR) { return URL(fileURLWithPath: dir, isDirectory: true) }
    #if os(Windows)
        let base = env.nonEmpty("APPDATA").map { URL(fileURLWithPath: $0, isDirectory: true) }
            ?? homeDirectory(env).appendingPathComponent("AppData").appendingPathComponent("Roaming")
        return base.appendingPathComponent("Anthropic", isDirectory: true)
    #else
        return homeDirectory(env).appendingPathComponent(".config").appendingPathComponent("anthropic", isDirectory: true)
    #endif
}

/// The stripped contents of `<config_dir>/active_config`, or `nil` if missing or empty.
func readActiveConfigPointer(_ env: CredentialEnvironment) -> String? {
    let url = credentialsConfigDir(env).appendingPathComponent("active_config")
    guard let data = try? readFileBytes(url.path), let text = String(data: data, encoding: .utf8) else { return nil }
    let name = text.trimmingCharacters(in: .whitespacesAndNewlines)
    return name.isEmpty ? nil : name
}

/// Resolves the active profile name: `ANTHROPIC_PROFILE` → `active_config` pointer → `"default"`.
func activeProfile(_ env: CredentialEnvironment) throws -> String {
    if let name = env.nonEmpty(ENV_PROFILE) {
        try validateProfileName(name, source: ENV_PROFILE)
        return name
    }
    guard let name = readActiveConfigPointer(env) else { return DEFAULT_PROFILE }
    try validateProfileName(name, source: "active_config pointer file")
    return name
}

/// Rejects non-`https://` token-endpoint URLs. Localhost is allowed for testing.
func requireHTTPS(_ url: String, field: String) throws {
    var lowered = url.lowercased()
    while lowered.hasSuffix("/") { lowered.removeLast() }
    if lowered.hasPrefix("https://") { return }
    if lowered.hasPrefix("http://localhost") || lowered.hasPrefix("http://127.0.0.1") || lowered.hasPrefix("http://[::1]") { return }
    throw CredentialsError(
        "\(field) must use https (got \(pythonStringRepr(url))); the token-exchange endpoint carries secret material and cannot be used over cleartext HTTP."
    )
}

/// Rejects profile names that could escape the config directory.
func validateProfileName(_ profile: String, source: String = "profile name") throws {
    if profile.isEmpty { throw CredentialsError("\(source) must not be empty.") }
    let r = pythonStringRepr(profile)
    if profile != profile.trimmingCharacters(in: .whitespacesAndNewlines) {
        throw CredentialsError("\(source) \(r) has leading or trailing whitespace.")
    }
    if profile.hasPrefix(".") { throw CredentialsError("\(source) \(r) must not start with a dot.") }
    for sep in ["/", "\\"] where profile.contains(sep) {
        throw CredentialsError(
            "\(source) \(r) must not contain path separators — profiles are filenames under the config directory. Pick a name without \(pythonStringRepr(sep))."
        )
    }
    if profile.contains("\u{0}") { throw CredentialsError("\(source) \(r) must not contain null bytes.") }
}

/// Asserts `candidate` resolves to a descendant of `base` and returns it unresolved.
func resolveUnder(_ base: URL, _ candidate: URL) throws -> URL {
    let baseResolved = resolvePath(base.path)
    let candidateResolved = resolvePath(candidate.path)
    let prefix = baseResolved.hasSuffix("/") ? baseResolved : baseResolved + "/"
    if candidateResolved != baseResolved && !candidateResolved.hasPrefix(prefix) {
        throw CredentialsError("Resolved path \(candidateResolved) escapes config directory \(baseResolved).")
    }
    return candidate
}

/// `<config_dir>/configs/<profile>.json` (non-secret).
func configFilePath(_ profile: String, _ env: CredentialEnvironment) throws -> URL {
    try validateProfileName(profile)
    let base = credentialsConfigDir(env)
    return try resolveUnder(base, base.appendingPathComponent("configs").appendingPathComponent("\(profile).json"))
}

/// `<config_dir>/credentials/<profile>.json` (secret, 0600).
func credentialsFilePath(_ profile: String, _ env: CredentialEnvironment) throws -> URL {
    try validateProfileName(profile)
    let base = credentialsConfigDir(env)
    return try resolveUnder(base, base.appendingPathComponent("credentials").appendingPathComponent("\(profile).json"))
}

/// Whether the *active* profile's config file exists.
func hasActiveProfileConfig(_ env: CredentialEnvironment) -> Bool {
    guard let path = try? configFilePath(try activeProfile(env), env) else { return false }
    return isRegularFile(path.path)
}

/// Whether the user wrote a non-empty `active_config` pointer file.
func hasExplicitActiveConfig(_ env: CredentialEnvironment) -> Bool { readActiveConfigPointer(env) != nil }

/// Explicit path → `ANTHROPIC_IDENTITY_TOKEN_FILE` → `nil`.
func resolveIdentityTokenPath(_ path: String?, _ env: CredentialEnvironment) -> URL? {
    if let path { return URL(fileURLWithPath: path) }
    if let p = env.nonEmpty(ENV_IDENTITY_TOKEN_FILE) { return URL(fileURLWithPath: p) }
    return nil
}

/// True if the environment / filesystem holds signals that would drive the profile or env
/// federation paths of `defaultCredentials` (used for the shadowing warnings).
func hasAutoDiscoverableCredentials(_ env: CredentialEnvironment) -> Bool {
    if env.nonEmpty(ENV_PROFILE) != nil || env.nonEmpty(ENV_CONFIG_DIR) != nil { return true }
    if hasExplicitActiveConfig(env) { return true }
    if env.nonEmpty(ENV_FEDERATION_RULE_ID) != nil && env.nonEmpty(ENV_ORGANIZATION_ID) != nil {
        if env.nonEmpty(ENV_IDENTITY_TOKEN_FILE) != nil || env.nonEmpty(ENV_IDENTITY_TOKEN) != nil { return true }
    }
    return false
}
