import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// AWS credentials used to sign a request with SigV4 (botocore's `Credentials`).
public struct AWSCredentials: Sendable, Hashable {
    public var accessKeyID: String
    public var secretAccessKey: String
    public var sessionToken: String?
    /// When temporary credentials expire; `nil` for long-lived keys.
    public var expiration: Date?

    public init(accessKeyID: String, secretAccessKey: String, sessionToken: String? = nil, expiration: Date? = nil) {
        self.accessKeyID = accessKeyID
        self.secretAccessKey = secretAccessKey
        self.sessionToken = sessionToken
        self.expiration = expiration
    }
}

/// Supplies AWS credentials, e.g. from a vault or an STS role you assume yourself.
///
/// Pass one as `credentialsProvider:` to the AWS clients to bypass the default chain.
public protocol AWSCredentialsProvider: Sendable {
    /// Returns credentials, or `nil` when this provider has none.
    func credentials() async throws -> AWSCredentials?
}

/// A provider built from a closure.
public struct AWSCredentialsProviderFunction: AWSCredentialsProvider {
    let body: @Sendable () async throws -> AWSCredentials?
    public init(_ body: @escaping @Sendable () async throws -> AWSCredentials?) { self.body = body }
    public func credentials() async throws -> AWSCredentials? { try await body() }
}

/// Fixed credentials.
public struct AWSStaticCredentialsProvider: AWSCredentialsProvider {
    public let value: AWSCredentials
    public init(_ value: AWSCredentials) { self.value = value }
    public func credentials() async throws -> AWSCredentials? { value }
}

/// The AWS shared `config` and `credentials` files (INI), as botocore reads them.
public struct AWSSharedConfig: Sendable {
    /// Profile name → key → value, from the config file (`[profile name]` / `[default]` sections).
    public var configProfiles: [String: [String: String]]
    /// Profile name → key → value, from the credentials file (`[name]` sections).
    public var credentialProfiles: [String: [String: String]]

    public init(configProfiles: [String: [String: String]] = [:], credentialProfiles: [String: [String: String]] = [:]) {
        self.configProfiles = configProfiles
        self.credentialProfiles = credentialProfiles
    }

    /// Loads `AWS_CONFIG_FILE` (default `~/.aws/config`) and `AWS_SHARED_CREDENTIALS_FILE`
    /// (default `~/.aws/credentials`). Missing files are treated as empty.
    public static func load(environment: [String: String]) -> AWSSharedConfig {
        let home = environment["HOME"] ?? NSHomeDirectory()
        func expand(_ path: String) -> String {
            if path == "~" { return home }
            if path.hasPrefix("~/") { return home + String(path.dropFirst()) }
            return path
        }
        let configPath = expand(environment["AWS_CONFIG_FILE"] ?? "~/.aws/config")
        let credentialsPath = expand(environment["AWS_SHARED_CREDENTIALS_FILE"] ?? "~/.aws/credentials")
        var config = AWSSharedConfig()
        if let text = try? String(contentsOfFile: configPath, encoding: .utf8) {
            for (section, values) in parseINI(text) {
                // The config file names profiles `[profile name]`, except `[default]`.
                if section == "default" {
                    config.configProfiles["default", default: [:]].merge(values) { $1 }
                } else if section.hasPrefix("profile ") {
                    let name = section.dropFirst("profile ".count).trimmingCharacters(in: .whitespaces)
                    config.configProfiles[name, default: [:]].merge(values) { $1 }
                }
            }
        }
        if let text = try? String(contentsOfFile: credentialsPath, encoding: .utf8) {
            for (section, values) in parseINI(text) {
                config.credentialProfiles[section, default: [:]].merge(values) { $1 }
            }
        }
        return config
    }

    /// Parses an INI file the way botocore's `raw_config_parse` does: `key = value` lines,
    /// `#`/`;` comment lines, and indented continuation lines (nested sections) ignored.
    static func parseINI(_ text: String) -> [(String, [String: String])] {
        var sections: [(String, [String: String])] = []
        var current: Int? = nil
        for rawLine in text.split(omittingEmptySubsequences: false, whereSeparator: { $0 == "\n" || $0 == "\r\n" }) {
            let line = String(rawLine).replacingOccurrences(of: "\r", with: "")
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") || trimmed.hasPrefix(";") { continue }
            if trimmed.hasPrefix("[") && trimmed.hasSuffix("]") {
                let name = String(trimmed.dropFirst().dropLast()).trimmingCharacters(in: .whitespaces)
                sections.append((name, [:]))
                current = sections.count - 1
                continue
            }
            // Indented lines continue a nested value (e.g. `s3 =\n  max_concurrent_requests = 10`).
            if let first = line.first, first == " " || first == "\t" { continue }
            guard let i = current, let eq = trimmed.firstIndex(where: { $0 == "=" || $0 == ":" }) else { continue }
            let key = trimmed[..<eq].trimmingCharacters(in: .whitespaces).lowercased()
            let value = trimmed[trimmed.index(after: eq)...].trimmingCharacters(in: .whitespaces)
            sections[i].1[key] = value
        }
        return sections
    }

    /// The configured region of a profile (`region` in the config file).
    public func region(profile: String) -> String? {
        configProfiles[profile]?["region"].flatMap { $0.isEmpty ? nil : $0 }
    }
}

/// The default AWS credential chain, ported from botocore's resolver.
///
/// In order:
/// 1. the `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN` environment
///    variables (skipped when a profile is passed explicitly),
/// 2. static keys of the profile in the shared credentials file (`~/.aws/credentials`),
/// 3. `credential_process` of the profile in the config file (macOS / Linux),
/// 4. static keys of the profile in the config file (`~/.aws/config`),
/// 5. the ECS/EKS container credentials endpoint (`AWS_CONTAINER_CREDENTIALS_RELATIVE_URI` /
///    `AWS_CONTAINER_CREDENTIALS_FULL_URI`),
/// 6. the EC2 instance metadata service (IMDSv2), unless `AWS_EC2_METADATA_DISABLED=true`.
///
/// Not supported (pass your own `AWSCredentialsProvider` instead): IAM Identity Center (SSO)
/// profiles, `role_arn` / `source_profile` assume-role profiles, and web-identity federation.
public final class AWSDefaultCredentialsChain: AWSCredentialsProvider, @unchecked Sendable {
    public let profile: String?
    public let environment: [String: String]
    let transport: HTTPTransport
    let metadataTimeout: TimeInterval
    private let lock = NSLock()
    private var cached: AWSCredentials?

    /// - Parameters:
    ///   - profile: An explicitly chosen profile; `nil` uses `AWS_PROFILE` or `default`.
    ///   - transport: Used for the container and instance-metadata endpoints.
    public init(profile: String? = nil, environment: [String: String] = ProcessInfo.processInfo.environment,
                transport: HTTPTransport? = nil, metadataTimeout: TimeInterval = 1)
    {
        self.profile = profile
        self.environment = environment
        self.transport = transport ?? URLSessionTransport()
        self.metadataTimeout = metadataTimeout
    }

    public func credentials() async throws -> AWSCredentials? {
        if let c = lock.withLock({ cached }) {
            // Refresh temporary credentials five minutes before they expire.
            if let exp = c.expiration, exp.timeIntervalSinceNow < 300 {} else { return c }
        }
        let resolved = try await resolve()
        lock.withLock { cached = resolved }
        return resolved
    }

    var profileName: String { profile ?? env("AWS_PROFILE") ?? env("AWS_DEFAULT_PROFILE") ?? "default" }

    func env(_ name: String) -> String? { environment[name].flatMap { $0.isEmpty ? nil : $0 } }

    func resolve() async throws -> AWSCredentials? {
        if profile == nil, let c = fromEnvironment() { return c }
        let shared = AWSSharedConfig.load(environment: environment)
        let name = profileName
        if let section = shared.credentialProfiles[name], let c = AWSDefaultCredentialsChain.staticKeys(section) { return c }
        if let process = shared.configProfiles[name]?["credential_process"], !process.isEmpty {
            return try await runCredentialProcess(process)
        }
        if let section = shared.configProfiles[name], let c = AWSDefaultCredentialsChain.staticKeys(section) { return c }
        if profile != nil, shared.credentialProfiles[name] == nil, shared.configProfiles[name] == nil {
            throw AnthropicError("The config profile (\(name)) could not be found")
        }
        if let c = try await fromContainer() { return c }
        if let c = try? await fromInstanceMetadata() { return c }
        return nil
    }

    func fromEnvironment() -> AWSCredentials? {
        guard let key = env("AWS_ACCESS_KEY_ID"), let secret = env("AWS_SECRET_ACCESS_KEY") else { return nil }
        return AWSCredentials(accessKeyID: key, secretAccessKey: secret,
                              sessionToken: env("AWS_SESSION_TOKEN") ?? env("AWS_SECURITY_TOKEN"))
    }

    static func staticKeys(_ section: [String: String]) -> AWSCredentials? {
        guard let key = section["aws_access_key_id"], !key.isEmpty, let secret = section["aws_secret_access_key"], !secret.isEmpty else {
            return nil
        }
        let token = section["aws_session_token"] ?? section["aws_security_token"]
        return AWSCredentials(accessKeyID: key, secretAccessKey: secret, sessionToken: (token?.isEmpty ?? true) ? nil : token)
    }

    /// Parses the JSON of a credentials endpoint or `credential_process` (`AccessKeyId`, ...).
    static func parseCredentialsJSON(_ data: Data, tokenKey: String) throws -> AWSCredentials {
        guard case .object(let o) = try JSONValue.parse(data),
              let key = o["AccessKeyId"]?.stringValue, let secret = o["SecretAccessKey"]?.stringValue
        else { throw AnthropicError("Invalid AWS credentials response") }
        var expiration: Date? = nil
        if let exp = o["Expiration"]?.stringValue {
            let f = ISO8601DateFormatter()
            expiration = f.date(from: exp)
            if expiration == nil {
                f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                expiration = f.date(from: exp)
            }
        }
        return AWSCredentials(accessKeyID: key, secretAccessKey: secret, sessionToken: o[tokenKey]?.stringValue, expiration: expiration)
    }

    func runCredentialProcess(_ command: String) async throws -> AWSCredentials {
        #if os(macOS) || os(Linux)
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/sh")
            process.arguments = ["-c", command]
            process.environment = environment
            let out = Pipe()
            process.standardOutput = out
            process.standardError = FileHandle.nullDevice
            try process.run()
            let data = out.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else {
                throw AnthropicError("Error when retrieving credentials from custom-process: exit status \(process.terminationStatus)")
            }
            return try AWSDefaultCredentialsChain.parseCredentialsJSON(data, tokenKey: "SessionToken")
        #else
            throw AnthropicError("credential_process is not supported on this platform")
        #endif
    }

    func fromContainer() async throws -> AWSCredentials? {
        var url: URL? = nil
        if let relative = env("AWS_CONTAINER_CREDENTIALS_RELATIVE_URI") {
            url = URL(string: "http://169.254.170.2" + relative)
        } else if let full = env("AWS_CONTAINER_CREDENTIALS_FULL_URI") {
            url = URL(string: full)
        }
        guard let url else { return nil }
        var headers = HTTPHeaders()
        if let tokenFile = env("AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE") {
            headers["Authorization"] = try String(contentsOfFile: tokenFile, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let token = env("AWS_CONTAINER_AUTHORIZATION_TOKEN") {
            headers["Authorization"] = token
        }
        headers["Accept"] = "application/json"
        let response = try await transport.send(HTTPRequest(method: "GET", url: url, headers: headers, timeout: Timeout(metadataTimeout * 2)), stream: false)
        let data = try await response.read()
        guard response.isSuccess else { throw AnthropicError("Error retrieving container credentials: HTTP \(response.statusCode)") }
        return try AWSDefaultCredentialsChain.parseCredentialsJSON(data, tokenKey: "Token")
    }

    func fromInstanceMetadata() async throws -> AWSCredentials? {
        if env("AWS_EC2_METADATA_DISABLED")?.lowercased() == "true" { return nil }
        let endpoint = (env("AWS_EC2_METADATA_SERVICE_ENDPOINT") ?? "http://169.254.169.254/").trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let timeout = Timeout(metadataTimeout)
        guard let tokenURL = URL(string: endpoint + "/latest/api/token"),
              let rolesURL = URL(string: endpoint + "/latest/meta-data/iam/security-credentials/")
        else { return nil }
        let tokenResponse = try await transport.send(
            HTTPRequest(method: "PUT", url: tokenURL, headers: ["x-aws-ec2-metadata-token-ttl-seconds": "21600"], timeout: timeout), stream: false)
        let token = try await tokenResponse.text()
        guard tokenResponse.isSuccess else { return nil }
        let auth: HTTPHeaders = ["x-aws-ec2-metadata-token": token]
        let rolesResponse = try await transport.send(HTTPRequest(method: "GET", url: rolesURL, headers: auth, timeout: timeout), stream: false)
        let roles = try await rolesResponse.text()
        guard rolesResponse.isSuccess, let role = roles.split(separator: "\n").first.map(String.init), !role.isEmpty,
              let credsURL = URL(string: rolesURL.absoluteString + role)
        else { return nil }
        let credsResponse = try await transport.send(HTTPRequest(method: "GET", url: credsURL, headers: auth, timeout: timeout), stream: false)
        let data = try await credsResponse.read()
        guard credsResponse.isSuccess else { return nil }
        return try AWSDefaultCredentialsChain.parseCredentialsJSON(data, tokenKey: "Token")
    }
}

/// Resolves the credentials an AWS client signs with: explicit keys win, then a custom provider,
/// then the default chain (`_get_session` + `session.get_credentials()` in the Python SDK).
final class AWSCredentialsResolver: @unchecked Sendable {
    let explicit: AWSCredentials?
    let provider: AWSCredentialsProvider

    init(accessKey: String?, secretKey: String?, sessionToken: String?, profile: String?,
         provider: AWSCredentialsProvider?, environment: [String: String], transport: HTTPTransport?)
    {
        if let accessKey, let secretKey {
            explicit = AWSCredentials(accessKeyID: accessKey, secretAccessKey: secretKey, sessionToken: sessionToken)
        } else {
            explicit = nil
        }
        self.provider = provider ?? AWSDefaultCredentialsChain(profile: profile, environment: environment, transport: transport)
    }

    func resolve() async throws -> AWSCredentials {
        if let explicit { return explicit }
        guard let c = try await provider.credentials() else {
            throw AnthropicError("Could not resolve AWS credentials from session")
        }
        return c
    }
}
