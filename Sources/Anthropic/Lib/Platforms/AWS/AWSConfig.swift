import Foundation

/// Configuration resolution shared by the AWS-hosted clients (port of `lib/aws/_credentials.py`).
///
/// Every function takes the environment explicitly (the Python versions read `os.environ`).
public enum AWSConfig {
    /// Raises if only one of `awsAccessKey` / `awsSecretKey` is provided.
    public static func validateCredentials(awsAccessKey: String?, awsSecretKey: String?) throws {
        if (awsAccessKey != nil) != (awsSecretKey != nil) {
            let provided = awsAccessKey != nil ? "aws_access_key" : "aws_secret_key"
            let missing = awsAccessKey != nil ? "aws_secret_key" : "aws_access_key"
            throw ValueError(
                "`\(provided)` was provided without `\(missing)`. Both must be provided together, or neither (to use the default credential chain)."
            )
        }
    }

    /// The first set value among `names` (an empty string counts as set, like `os.environ.get`).
    static func readEnv(_ environment: [String: String], _ names: [String]) -> String? {
        for name in names {
            if let v = environment[name] { return v }
        }
        return nil
    }

    /// Whether to use SigV4 (`true`) or an API key (`false`).
    ///
    /// Precedence: an `apiKey` argument, then explicit AWS keys, then a profile argument, then the
    /// API-key environment variables (in order), then the default AWS credential chain.
    public static func resolveAuthMode(apiKey: String?, awsAccessKey: String?, awsSecretKey: String?, awsProfile: String?,
                                       apiKeyEnvVars: [String] = ["ANTHROPIC_AWS_API_KEY"],
                                       environment: [String: String] = ProcessInfo.processInfo.environment) -> Bool
    {
        if apiKey != nil { return false }
        if awsAccessKey != nil || awsSecretKey != nil { return true }
        if awsProfile != nil { return true }
        if readEnv(environment, apiKeyEnvVars) != nil { return false }
        return true
    }

    /// The API key, or `nil` when signing with SigV4.
    public static func resolveAPIKey(apiKey: String?, useSigV4: Bool, apiKeyEnvVars: [String] = ["ANTHROPIC_AWS_API_KEY"],
                                     environment: [String: String] = ProcessInfo.processInfo.environment) -> String?
    {
        if let apiKey { return apiKey }
        if !useSigV4 { return readEnv(environment, apiKeyEnvVars) }
        return nil
    }

    /// The region from the argument, `AWS_REGION` or `AWS_DEFAULT_REGION`; never defaulted.
    public static func resolveRegion(_ awsRegion: String?, environment: [String: String] = ProcessInfo.processInfo.environment) -> String? {
        if let awsRegion { return awsRegion }
        if let r = environment["AWS_REGION"], !r.isEmpty { return r }
        if let r = environment["AWS_DEFAULT_REGION"], !r.isEmpty { return r }
        return nil
    }

    public static func resolveWorkspaceID(_ workspaceID: String?, workspaceIDEnvVars: [String] = ["ANTHROPIC_AWS_WORKSPACE_ID"],
                                          environment: [String: String] = ProcessInfo.processInfo.environment) -> String?
    {
        if let workspaceID { return workspaceID }
        return readEnv(environment, workspaceIDEnvVars)
    }

    /// The base URL from the argument, the env var(s), or the region-derived template.
    public static func resolveBaseURL(_ baseURL: String?, region: String?, baseURLEnvVars: [String] = ["ANTHROPIC_AWS_BASE_URL"],
                                      urlTemplate: String = "https://aws-external-anthropic.{region}.api.aws",
                                      environment: [String: String] = ProcessInfo.processInfo.environment) -> String?
    {
        if let baseURL { return baseURL }
        if let env = readEnv(environment, baseURLEnvVars) { return env }
        if let region { return urlTemplate.replacingOccurrences(of: "{region}", with: region) }
        return nil
    }
}

/// `_keep_client_header_params`: per-request header params that are `.omit` would strip a value the
/// client itself sends (e.g. a client-level workspace ID); drop them so the client-level header survives.
func keepClientHeaderParams(_ options: FinalRequestOptions) -> FinalRequestOptions {
    guard let headers = options.headers else { return options }
    let clientLevel: Set<String> = ["anthropic-workspace-id", "anthropic-user-profile-id"]
    var o = options
    o.headers = headers.filter { !(clientLevel.contains($0.key.lowercased()) && $0.value == .omit) }
    return o
}
