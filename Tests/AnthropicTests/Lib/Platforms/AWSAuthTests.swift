import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/test_aws_auth.py (the `monkeypatch.setenv` cases pass an explicit environment).

@Suite struct AWSValidateCredentialsTests {
    @Test func bothProvidedPasses() throws { try AWSConfig.validateCredentials(awsAccessKey: "AKID", awsSecretKey: "secret") }
    @Test func neitherProvidedPasses() throws { try AWSConfig.validateCredentials(awsAccessKey: nil, awsSecretKey: nil) }
    @Test func accessKeyOnlyRaises() async {
        await expectThrows(ValueError.self, matching: "aws_access_key.*without.*aws_secret_key") {
            try AWSConfig.validateCredentials(awsAccessKey: "AKID", awsSecretKey: nil)
        }
    }
    @Test func secretKeyOnlyRaises() async {
        await expectThrows(ValueError.self, matching: "aws_secret_key.*without.*aws_access_key") {
            try AWSConfig.validateCredentials(awsAccessKey: nil, awsSecretKey: "secret")
        }
    }
}

@Suite struct AWSResolveAuthModeTests {
    func mode(apiKey: String? = nil, access: String? = nil, secret: String? = nil, profile: String? = nil,
              vars: [String] = ["ANTHROPIC_AWS_API_KEY"], env: [String: String] = [:]) -> Bool
    {
        AWSConfig.resolveAuthMode(apiKey: apiKey, awsAccessKey: access, awsSecretKey: secret, awsProfile: profile,
                                  apiKeyEnvVars: vars, environment: env)
    }

    @Test func apiKeyArgReturnsFalse() { #expect(mode(apiKey: "key") == false) }
    @Test func explicitCredsReturnsTrue() { #expect(mode(access: "AKID", secret: "secret") == true) }
    @Test func accessKeyAloneReturnsTrue() { #expect(mode(access: "AKID") == true) }
    @Test func profileReturnsTrue() { #expect(mode(profile: "my-profile") == true) }
    @Test func envApiKeyReturnsFalse() { #expect(mode(env: ["ANTHROPIC_AWS_API_KEY": "env-key"]) == false) }
    @Test func noArgsNoEnvDefaultsToSigV4() { #expect(mode() == true) }
    @Test func explicitCredsSuppressEnvApiKey() {
        #expect(mode(access: "AKID", secret: "secret", env: ["ANTHROPIC_AWS_API_KEY": "env-key"]) == true)
    }
    @Test func profileSuppressesEnvApiKey() { #expect(mode(profile: "my-profile", env: ["ANTHROPIC_AWS_API_KEY": "env-key"]) == true) }
    @Test func apiKeyArgBeatsExplicitCreds() { #expect(mode(apiKey: "key", access: "AKID", secret: "secret") == false) }
    @Test func customEnvVar() {
        #expect(mode(vars: ["AWS_BEARER_TOKEN_BEDROCK"], env: ["AWS_BEARER_TOKEN_BEDROCK": "mantle-key"]) == false)
    }
    @Test func customEnvVarNotSetDefaultsToSigV4() { #expect(mode(vars: ["AWS_BEARER_TOKEN_BEDROCK"]) == true) }
    @Test func envVarFallbackChainFirstWins() {
        #expect(mode(vars: ["AWS_BEARER_TOKEN_BEDROCK", "ANTHROPIC_AWS_API_KEY"],
                     env: ["AWS_BEARER_TOKEN_BEDROCK": "mantle-key", "ANTHROPIC_AWS_API_KEY": "aws-key"]) == false)
    }
    @Test func envVarFallbackChainFallsThrough() {
        #expect(mode(vars: ["AWS_BEARER_TOKEN_BEDROCK", "ANTHROPIC_AWS_API_KEY"], env: ["ANTHROPIC_AWS_API_KEY": "aws-key"]) == false)
    }
    @Test func envVarFallbackChainNoneSet() { #expect(mode(vars: ["AWS_BEARER_TOKEN_BEDROCK", "ANTHROPIC_AWS_API_KEY"]) == true) }
}

@Suite struct AWSResolveAPIKeyTests {
    @Test func returnsArgWhenProvided() { #expect(AWSConfig.resolveAPIKey(apiKey: "arg-key", useSigV4: false, environment: [:]) == "arg-key") }
    @Test func returnsNoneForSigV4() { #expect(AWSConfig.resolveAPIKey(apiKey: nil, useSigV4: true, environment: [:]) == nil) }
    @Test func returnsEnvWhenNotSigV4() {
        #expect(AWSConfig.resolveAPIKey(apiKey: nil, useSigV4: false, environment: ["ANTHROPIC_AWS_API_KEY": "env-key"]) == "env-key")
    }
    @Test func returnsNoneWhenNotSigV4AndNoEnv() { #expect(AWSConfig.resolveAPIKey(apiKey: nil, useSigV4: false, environment: [:]) == nil) }
    @Test func argTakesPrecedenceOverEnv() {
        #expect(AWSConfig.resolveAPIKey(apiKey: "arg-key", useSigV4: false, environment: ["ANTHROPIC_AWS_API_KEY": "env-key"]) == "arg-key")
    }
    @Test func sigv4IgnoresEnv() {
        #expect(AWSConfig.resolveAPIKey(apiKey: nil, useSigV4: true, environment: ["ANTHROPIC_AWS_API_KEY": "env-key"]) == nil)
    }
    @Test func customEnvVar() {
        #expect(AWSConfig.resolveAPIKey(apiKey: nil, useSigV4: false, apiKeyEnvVars: ["AWS_BEARER_TOKEN_BEDROCK"],
                                        environment: ["AWS_BEARER_TOKEN_BEDROCK": "mantle-key"]) == "mantle-key")
    }
    @Test func envVarFallbackChainFirstWins() {
        #expect(AWSConfig.resolveAPIKey(apiKey: nil, useSigV4: false, apiKeyEnvVars: ["AWS_BEARER_TOKEN_BEDROCK", "ANTHROPIC_AWS_API_KEY"],
                                        environment: ["AWS_BEARER_TOKEN_BEDROCK": "mantle-key", "ANTHROPIC_AWS_API_KEY": "aws-key"]) == "mantle-key")
    }
    @Test func envVarFallbackChainFallsThrough() {
        #expect(AWSConfig.resolveAPIKey(apiKey: nil, useSigV4: false, apiKeyEnvVars: ["AWS_BEARER_TOKEN_BEDROCK", "ANTHROPIC_AWS_API_KEY"],
                                        environment: ["ANTHROPIC_AWS_API_KEY": "aws-key"]) == "aws-key")
    }
}

@Suite struct AWSResolveRegionTests {
    @Test func returnsArgWhenProvided() { #expect(AWSConfig.resolveRegion("us-west-2", environment: [:]) == "us-west-2") }
    @Test func returnsAwsRegionEnv() { #expect(AWSConfig.resolveRegion(nil, environment: ["AWS_REGION": "eu-west-1"]) == "eu-west-1") }
    @Test func returnsAwsDefaultRegionEnv() {
        #expect(AWSConfig.resolveRegion(nil, environment: ["AWS_DEFAULT_REGION": "ap-southeast-1"]) == "ap-southeast-1")
    }
    @Test func awsRegionTakesPrecedenceOverDefault() {
        #expect(AWSConfig.resolveRegion(nil, environment: ["AWS_REGION": "us-east-1", "AWS_DEFAULT_REGION": "us-west-2"]) == "us-east-1")
    }
    @Test func argTakesPrecedenceOverEnv() {
        #expect(AWSConfig.resolveRegion("eu-central-1", environment: ["AWS_REGION": "us-east-1"]) == "eu-central-1")
    }
    @Test func returnsNoneWhenNoSource() { #expect(AWSConfig.resolveRegion(nil, environment: [:]) == nil) }
}

@Suite struct AWSResolveWorkspaceIDTests {
    @Test func returnsArgWhenProvided() { #expect(AWSConfig.resolveWorkspaceID("ws-123", environment: [:]) == "ws-123") }
    @Test func returnsEnvWhenNoArg() {
        #expect(AWSConfig.resolveWorkspaceID(nil, environment: ["ANTHROPIC_AWS_WORKSPACE_ID": "env-ws"]) == "env-ws")
    }
    @Test func returnsNoneWhenNoSource() { #expect(AWSConfig.resolveWorkspaceID(nil, environment: [:]) == nil) }
    @Test func argTakesPrecedenceOverEnv() {
        #expect(AWSConfig.resolveWorkspaceID("arg-ws", environment: ["ANTHROPIC_AWS_WORKSPACE_ID": "env-ws"]) == "arg-ws")
    }
    @Test func customEnvVar() {
        #expect(AWSConfig.resolveWorkspaceID(nil, workspaceIDEnvVars: ["ANTHROPIC_BEDROCK_MANTLE_WORKSPACE_ID"],
                                             environment: ["ANTHROPIC_BEDROCK_MANTLE_WORKSPACE_ID": "mantle-ws"]) == "mantle-ws")
    }
    @Test func envVarFallbackChainFirstWins() {
        #expect(AWSConfig.resolveWorkspaceID(nil, workspaceIDEnvVars: ["ANTHROPIC_BEDROCK_MANTLE_WORKSPACE_ID", "ANTHROPIC_AWS_WORKSPACE_ID"],
                                             environment: ["ANTHROPIC_BEDROCK_MANTLE_WORKSPACE_ID": "mantle-ws", "ANTHROPIC_AWS_WORKSPACE_ID": "aws-ws"])
            == "mantle-ws")
    }
    @Test func envVarFallbackChainFallsThrough() {
        #expect(AWSConfig.resolveWorkspaceID(nil, workspaceIDEnvVars: ["ANTHROPIC_BEDROCK_MANTLE_WORKSPACE_ID", "ANTHROPIC_AWS_WORKSPACE_ID"],
                                             environment: ["ANTHROPIC_AWS_WORKSPACE_ID": "aws-ws"]) == "aws-ws")
    }
    @Test func envVarFallbackChainNoneSet() {
        #expect(AWSConfig.resolveWorkspaceID(nil, workspaceIDEnvVars: ["ANTHROPIC_BEDROCK_MANTLE_WORKSPACE_ID", "ANTHROPIC_AWS_WORKSPACE_ID"],
                                             environment: [:]) == nil)
    }
}

@Suite struct AWSResolveBaseURLTests {
    @Test func returnsArgWhenProvided() {
        #expect(AWSConfig.resolveBaseURL("https://custom.example.com", region: "us-east-1", environment: [:]) == "https://custom.example.com")
    }
    @Test func returnsEnvWhenNoArg() {
        #expect(AWSConfig.resolveBaseURL(nil, region: "us-east-1", environment: ["ANTHROPIC_AWS_BASE_URL": "https://env-gateway.example.com"])
            == "https://env-gateway.example.com")
    }
    @Test func derivesFromRegion() {
        #expect(AWSConfig.resolveBaseURL(nil, region: "us-west-2", environment: [:]) == "https://aws-external-anthropic.us-west-2.api.aws")
    }
    @Test func returnsNoneWhenNoSource() { #expect(AWSConfig.resolveBaseURL(nil, region: nil, environment: [:]) == nil) }
    @Test func argTakesPrecedenceOverEnv() {
        #expect(AWSConfig.resolveBaseURL("https://arg.example.com", region: "us-east-1",
                                         environment: ["ANTHROPIC_AWS_BASE_URL": "https://env-gateway.example.com"]) == "https://arg.example.com")
    }
    @Test func envTakesPrecedenceOverRegion() {
        #expect(AWSConfig.resolveBaseURL(nil, region: "us-east-1", environment: ["ANTHROPIC_AWS_BASE_URL": "https://env-gateway.example.com"])
            == "https://env-gateway.example.com")
    }
    @Test func customURLTemplate() {
        #expect(AWSConfig.resolveBaseURL(nil, region: "us-east-1", urlTemplate: "https://bedrock-mantle.{region}.api.aws/anthropic", environment: [:])
            == "https://bedrock-mantle.us-east-1.api.aws/anthropic")
    }
    @Test func customEnvVar() {
        #expect(AWSConfig.resolveBaseURL(nil, region: "us-east-1", baseURLEnvVars: ["ANTHROPIC_BEDROCK_MANTLE_BASE_URL"],
                                         environment: ["ANTHROPIC_BEDROCK_MANTLE_BASE_URL": "https://mantle.example.com"]) == "https://mantle.example.com")
    }
    @Test func envVarFallbackChain() {
        #expect(AWSConfig.resolveBaseURL(nil, region: "us-east-1", baseURLEnvVars: ["ANTHROPIC_BEDROCK_MANTLE_BASE_URL", "ANTHROPIC_AWS_BASE_URL"],
                                         environment: ["ANTHROPIC_AWS_BASE_URL": "https://aws-fallback.example.com"]) == "https://aws-fallback.example.com")
    }
}

@Suite struct AWSGetAuthHeadersTests {
    let creds = AWSCredentials(accessKeyID: "AKIAIOSFODNN7EXAMPLE", secretAccessKey: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")

    func headers(method: String = "POST", url: String = "https://gateway.us-east-1.api.aws/v1/messages",
                 headers: HTTPHeaders = ["content-type": "application/json"], data: String? = #"{"hello": "world"}"#,
                 credentials: AWSCredentials? = nil, service: String = "aws-external-anthropic",
                 date: Date = Date()) -> [String: String]
    {
        var out: [String: String] = [:]
        for (k, v) in awsAuthHeaders(method: method, url: URL(string: url)!, headers: headers, body: data.map { Data($0.utf8) },
                                     credentials: credentials ?? creds, region: "us-east-1", serviceName: service, date: date)
        {
            out[k] = v
        }
        return out
    }

    @Test func usesServiceNameParameter() {
        let h = headers()
        #expect(h["Authorization"]?.contains("aws-external-anthropic") == true)
    }

    @Test func differentServiceName() {
        let h = headers(url: "https://bedrock-mantle.us-east-1.api.aws/anthropic/v1/messages", service: "bedrock-mantle")
        #expect(h["Authorization"]?.contains("bedrock-mantle") == true)
        #expect(h["Authorization"]?.contains("aws-external-anthropic") == false)
    }

    @Test func returnsAuthorizationAndDateHeaders() {
        let h = headers()
        #expect(h["Authorization"]?.hasPrefix("AWS4-HMAC-SHA256") == true)
        #expect(h["X-Amz-Date"] != nil)
    }

    @Test func includesSecurityTokenHeader() {
        var c = creds
        c.sessionToken = "FwoGZXIvYXdzEBYaDH7example"
        #expect(headers(credentials: c)["X-Amz-Security-Token"] == "FwoGZXIvYXdzEBYaDH7example")
    }

    @Test func stripsConnectionHeader() throws {
        let auth = headers(headers: ["content-type": "application/json", "connection": "keep-alive"])["Authorization"]!
        let match = try #require(auth.range(of: "SignedHeaders=([^,]+)", options: .regularExpression))
        let signed = auth[match].dropFirst("SignedHeaders=".count).split(separator: ";").map(String.init)
        #expect(!signed.contains("connection"))
        #expect(signed.contains("content-type") && signed.contains("host") && signed.contains("x-amz-date"))
    }

    @Test func handlesNullBody() {
        #expect(headers(method: "GET", url: "https://gateway.us-east-1.api.aws/v1/models", headers: [:], data: nil)["Authorization"] != nil)
    }

    @Test func includesQueryParamsInSigning() {
        let now = Date()
        let with = headers(method: "GET", url: "https://gateway.us-east-1.api.aws/v1/models?limit=10", headers: [:], data: nil, date: now)
        let without = headers(method: "GET", url: "https://gateway.us-east-1.api.aws/v1/models", headers: [:], data: nil, date: now)
        #expect(with["Authorization"] != without["Authorization"])
    }

    @Test func uppercasesMethod() {
        // Both signatures are made for the same instant; the signature covers the request time.
        let now = Date()
        #expect(headers(method: "post", headers: [:], data: "{}", date: now)["Authorization"] == headers(method: "POST", headers: [:], data: "{}", date: now)["Authorization"])
    }

    @Test func raisesOnMissingCredentials() async {
        let chain = AWSCredentialsResolver(accessKey: nil, secretKey: nil, sessionToken: nil, profile: nil, provider: nil,
                                           environment: isolatedEnv(), transport: nil)
        await expectThrows(AnthropicError.self, matching: "Could not resolve AWS credentials") { _ = try await chain.resolve() }
    }
}

/// Exact signatures, checked against AWS's published SigV4 test suite and a Python reference of
/// botocore's `SigV4Auth` algorithm.
@Suite struct SigV4VectorTests {
    let date = Date(timeIntervalSince1970: 1_440_938_160)  // 20150830T123600Z

    @Test func awsTestSuiteGetVanilla() {
        let signer = AWSSigV4Signer(credentials: AWSCredentials(accessKeyID: "AKIDEXAMPLE", secretAccessKey: "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"),
                                    service: "service", region: "us-east-1")
        let h = signer.authHeaders(method: "GET", url: URL(string: "https://example.amazonaws.com/")!, headers: [:], body: nil, date: date)
        #expect(h.first(where: { $0.0 == "X-Amz-Date" })?.1 == "20150830T123600Z")
        #expect(h.first(where: { $0.0 == "Authorization" })?.1
            == "AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/20150830/us-east-1/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=5fa00fa31553b73ebf1942676e86291e8372ff2a2260956d9b8aae1d763fbf31")
    }

    @Test func postWithSessionTokenEncodedPathAndQuery() {
        let creds = AWSCredentials(accessKeyID: "AKIAIOSFODNN7EXAMPLE", secretAccessKey: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
                                   sessionToken: "FwoGZXIvYXdzEBYaDH7example")
        let url = URL(string: "https://bedrock-runtime.us-east-1.amazonaws.com/model/arn:aws:bedrock:us-east-1:123456789012:application-inference-profile%2Fjf2sje1c0jnb/invoke?b=2&a=1")!
        let headers: HTTPHeaders = ["Content-Type": "application/json", "X-Stainless-Lang": "  swift   lang ", "User-Agent": "x", "Connection": "keep-alive"]
        let h = awsAuthHeaders(method: "POST", url: url, headers: headers, body: Data(#"{"hello": "world"}"#.utf8), credentials: creds,
                               region: "us-east-1", serviceName: "bedrock", date: Date(timeIntervalSince1970: 1_774_569_600))
        #expect(h.first(where: { $0.0 == "X-Amz-Security-Token" })?.1 == "FwoGZXIvYXdzEBYaDH7example")
        #expect(h.first(where: { $0.0 == "Authorization" })?.1
            == "AWS4-HMAC-SHA256 Credential=AKIAIOSFODNN7EXAMPLE/20260327/us-east-1/bedrock/aws4_request, SignedHeaders=content-type;host;x-amz-date;x-amz-security-token;x-stainless-lang, Signature=62293e3aba7c4dfbe623bcbcca42aadd39058ec314bd86d5b7b8eec80288aa6b")
    }

    @Test func normalizesPaths() {
        #expect(AWSSigV4Signer.normalizePath("") == "/")
        #expect(AWSSigV4Signer.normalizePath("/a/./b/../c//d/") == "/a/c/d/")
        #expect(AWSSigV4Signer.normalizePath("/..") == "/")
    }
}

/// The AWS credential chain (what boto3's session resolution provides).
@Suite struct AWSCredentialChainTests {
    @Test func environmentVariables() async throws {
        let chain = AWSDefaultCredentialsChain(environment: isolatedEnv([
            "AWS_ACCESS_KEY_ID": "AKENV", "AWS_SECRET_ACCESS_KEY": "envsecret", "AWS_SESSION_TOKEN": "envtoken",
        ]))
        #expect(try await chain.credentials() == AWSCredentials(accessKeyID: "AKENV", secretAccessKey: "envsecret", sessionToken: "envtoken"))
    }

    @Test func sharedCredentialsFileAndProfiles() async throws {
        let credentials = writeTempFile("""
            [default]
            aws_access_key_id = AKDEFAULT
            aws_secret_access_key = defaultsecret
            # a comment
            [work]
            aws_access_key_id=AKWORK
            aws_secret_access_key=worksecret
            aws_session_token=worktoken
            """)
        let env = isolatedEnv(["AWS_SHARED_CREDENTIALS_FILE": credentials])
        #expect(try await AWSDefaultCredentialsChain(environment: env).credentials()?.accessKeyID == "AKDEFAULT")
        #expect(try await AWSDefaultCredentialsChain(environment: env.merging(["AWS_PROFILE": "work"]) { $1 }).credentials()
            == AWSCredentials(accessKeyID: "AKWORK", secretAccessKey: "worksecret", sessionToken: "worktoken"))
        #expect(try await AWSDefaultCredentialsChain(profile: "work", environment: env).credentials()?.accessKeyID == "AKWORK")
    }

    @Test func environmentBeatsFilesUnlessProfileIsExplicit() async throws {
        let credentials = writeTempFile("[work]\naws_access_key_id = AKWORK\naws_secret_access_key = worksecret\n")
        let env = isolatedEnv(["AWS_SHARED_CREDENTIALS_FILE": credentials, "AWS_ACCESS_KEY_ID": "AKENV",
                               "AWS_SECRET_ACCESS_KEY": "envsecret", "AWS_PROFILE": "work"])
        #expect(try await AWSDefaultCredentialsChain(environment: env).credentials()?.accessKeyID == "AKENV")
        #expect(try await AWSDefaultCredentialsChain(profile: "work", environment: env).credentials()?.accessKeyID == "AKWORK")
    }

    @Test func configFileProfileKeysAndRegion() async throws {
        let config = writeTempFile("""
            [default]
            region = us-east-2
            [profile custom]
            region = us-west-1
            aws_access_key_id = AKCONFIG
            aws_secret_access_key = configsecret
            s3 =
              max_concurrent_requests = 20
            """)
        let env = isolatedEnv(["AWS_CONFIG_FILE": config])
        let shared = AWSSharedConfig.load(environment: env)
        #expect(shared.region(profile: "default") == "us-east-2")
        #expect(shared.region(profile: "custom") == "us-west-1")
        #expect(shared.configProfiles["custom"]?["max_concurrent_requests"] == nil)
        #expect(try await AWSDefaultCredentialsChain(profile: "custom", environment: env).credentials()?.accessKeyID == "AKCONFIG")
    }

    @Test func credentialProcess() async throws {
        let config = writeTempFile("""
            [profile proc]
            credential_process = echo '{"Version": 1, "AccessKeyId": "AKPROC", "SecretAccessKey": "procsecret", "SessionToken": "proctoken", "Expiration": "2099-01-01T00:00:00Z"}'
            """)
        let creds = try await AWSDefaultCredentialsChain(profile: "proc", environment: isolatedEnv(["AWS_CONFIG_FILE": config])).credentials()
        #expect(creds?.accessKeyID == "AKPROC")
        #expect(creds?.sessionToken == "proctoken")
        #expect(creds?.expiration == ISO8601DateFormatter().date(from: "2099-01-01T00:00:00Z"))
    }

    @Test func missingExplicitProfileRaises() async {
        await expectThrows(AnthropicError.self, matching: "could not be found") {
            _ = try await AWSDefaultCredentialsChain(profile: "nope", environment: isolatedEnv()).credentials()
        }
    }

    @Test func containerCredentials() async throws {
        let recorder = RequestRecorder { req, _ in
            platformJSON(#"{"AccessKeyId": "AKECS", "SecretAccessKey": "ecssecret", "Token": "ecstoken", "Expiration": "2099-01-01T00:00:00Z"}"#)(req)
        }
        let env = isolatedEnv(["AWS_CONTAINER_CREDENTIALS_RELATIVE_URI": "/v2/credentials/abc", "AWS_CONTAINER_AUTHORIZATION_TOKEN": "tok"])
        let creds = try await AWSDefaultCredentialsChain(environment: env, transport: recorder.transport).credentials()
        #expect(creds == AWSCredentials(accessKeyID: "AKECS", secretAccessKey: "ecssecret", sessionToken: "ecstoken",
                                        expiration: ISO8601DateFormatter().date(from: "2099-01-01T00:00:00Z")))
        #expect(recorder.urls == ["http://169.254.170.2/v2/credentials/abc"])
        #expect(recorder.requests[0].headers["Authorization"] == "tok")
    }

    @Test func instanceMetadataV2() async throws {
        let recorder = RequestRecorder { req, _ in
            switch (req.method, req.url.absoluteString.replacingOccurrences(of: "http://169.254.169.254", with: "")) {
            case ("PUT", "/latest/api/token"):
                #expect(req.headers["x-aws-ec2-metadata-token-ttl-seconds"] == "21600")
                return HTTPResponse.text("imds-token", for: req)
            case ("GET", "/latest/meta-data/iam/security-credentials/"):
                #expect(req.headers["x-aws-ec2-metadata-token"] == "imds-token")
                return HTTPResponse.text("my-role\n", for: req)
            case ("GET", "/latest/meta-data/iam/security-credentials/my-role"):
                return platformJSON(#"{"Code": "Success", "AccessKeyId": "AKIMDS", "SecretAccessKey": "imdssecret", "Token": "imdstoken"}"#)(req)
            default:
                return HTTPResponse.text("", status: 404, for: req)
            }
        }
        var env = isolatedEnv()
        env.removeValue(forKey: "AWS_EC2_METADATA_DISABLED")
        let creds = try await AWSDefaultCredentialsChain(environment: env, transport: recorder.transport).credentials()
        #expect(creds == AWSCredentials(accessKeyID: "AKIMDS", secretAccessKey: "imdssecret", sessionToken: "imdstoken"))
        #expect(recorder.count == 3)
    }

    @Test func instanceMetadataDisabled() async throws {
        let recorder = RequestRecorder()
        #expect(try await AWSDefaultCredentialsChain(environment: isolatedEnv(), transport: recorder.transport).credentials() == nil)
        #expect(recorder.count == 0)
    }

    @Test func customProviderIsUsed() async throws {
        let recorder = RequestRecorder()
        let client = try AnthropicAWS(awsRegion: "us-east-1", workspaceID: "ws-123", transport: recorder.transport,
                                      credentialsProvider: AWSStaticCredentialsProvider(AWSCredentials(accessKeyID: "AKCUSTOM", secretAccessKey: "s")),
                                      environment: isolatedEnv())
        _ = try await client.messages.create(maxTokens: 16, messages: userMessages("Hello"), model: "claude")
        #expect(recorder.requests[0].headers["Authorization"]?.contains("Credential=AKCUSTOM/") == true)
    }
}
