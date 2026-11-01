import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/test_scoped_client.py.

private let agentJSON = #"{"id": "agent_test"}"#

private func parent(_ recorder: RequestRecorder? = nil, apiKey: String = "parent-key", headers: Headers? = nil,
                    env: [String: String] = [:]) throws -> Anthropic
{
    try Anthropic(apiKey: apiKey, defaultHeaders: headers, transport: (recorder ?? RequestRecorder()).transport, environment: env)
}

@Suite struct ScopedClientTests {
    @Test func setsBearerAuthTokenOnCopy() throws {
        let scoped = try ScopedClient.copyWithBearerAuth(try parent(), authToken: "env-key", helper: .environmentsWorkPoller)
        #expect(scoped.authToken == "env-key")
    }

    @Test func clearsParentAPIKeyOnCopy() throws {
        let scoped = try ScopedClient.copyWithBearerAuth(try parent(), authToken: "env-key", helper: .environmentsWorkPoller)
        #expect(scoped.apiKey == nil)
    }

    /// A parent with a credentials provider (e.g. workload identity): the sub-client uses the
    /// explicit bearer as the one credential, not the provider's auth on top of it.
    @Test func clearsInheritedCredentialsProvider() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(agentJSON)(req) }
        let p = try Anthropic(credentials: StaticToken("provider-token"), transport: recorder.transport, environment: [:])
        let scoped = try ScopedClient.copyWithBearerAuth(p, authToken: "env-key", helper: .environmentsWorkPoller)
        #expect(scoped.credentials == nil)
        _ = try await scoped.beta.agents.withRawResponse.retrieve("agent_test")
        #expect(recorder.requests[0].headers.values("authorization") == ["Bearer env-key"])
    }

    @Test func stampsHelperTelemetryHeader() throws {
        let scoped = try ScopedClient.copyWithBearerAuth(try parent(), authToken: "env-key", helper: .environmentsWorker)
        #expect(scoped.customHeaders["x-stainless-helper"] == "environments-worker")
    }

    @Test func doesNotMutateParentClient() throws {
        let p = try parent()
        _ = try ScopedClient.copyWithBearerAuth(p, authToken: "env-key", helper: .environmentsWorkPoller)
        #expect(p.apiKey == "parent-key")
        #expect(p.authToken == nil)
    }

    @Test func emptyAuthTokenRaises() async {
        await expectThrows(ValueError.self, matching: "auth_token") {
            _ = try ScopedClient.copyWithBearerAuth(try parent(), authToken: "", helper: .environmentsWorkPoller)
        }
    }

    @Test func clientPathClearsAPIKeyAndSetsBearer() throws {
        let scoped = try ScopedClient.copyWithBearerAuth(try parent(), authToken: "env-key", helper: .sessionToolRunner)
        #expect(type(of: scoped) == Anthropic.self)
        #expect(scoped.apiKey == nil)
        #expect(scoped.authToken == "env-key")
        #expect(scoped.customHeaders["x-stainless-helper"] == "session-tool-runner")
    }

    @Test func stripsInheritedAuthorizationFromParentDefaultHeaders() throws {
        let p = try parent(headers: ["Authorization": "Bearer parent-token", "X-Api-Key": "parent-key"])
        let scoped = try ScopedClient.copyWithBearerAuth(p, authToken: "env-key", helper: .environmentsWorker)
        let custom = Set(scoped.customHeaders.keys.map { $0.lowercased() })
        #expect(!custom.contains("authorization"))
        #expect(!custom.contains("x-api-key"))
        let parentCustom = Dictionary(uniqueKeysWithValues: p.customHeaders.map { ($0.key.lowercased(), $0.value) })
        #expect(parentCustom["authorization"] == "Bearer parent-token")
        #expect(parentCustom["x-api-key"] == "parent-key")
    }

    @Test func scopedSubClientSendsOnlyBearerOnTheWire() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(agentJSON)(req) }
        let p = try parent(recorder, headers: ["Authorization": "Bearer parent-token", "X-Api-Key": "parent-key"])
        let scoped = try ScopedClient.copyWithBearerAuth(p, authToken: "env-key", helper: .environmentsWorker)
        _ = try await scoped.beta.agents.withRawResponse.retrieve("agent_test")
        #expect(recorder.count == 1)
        let h = recorder.requests[0].headers
        #expect(h["authorization"] == "Bearer env-key")
        #expect(h["x-api-key"] == nil)
        #expect(h["x-stainless-helper"] == "environments-worker")
    }

    @Test func keepsTheHostOfTheParent() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(agentJSON)(req) }
        let p = try Anthropic(apiKey: "parent-key", baseURL: "https://parent.example", defaultHeaders: ["anthropic-workspace-id": "wrkspc_parent"],
                              transport: recorder.transport, environment: [:])
        let scoped = try ScopedClient.copyWithBearerAuth(p, authToken: "env-key", helper: .environmentsWorker)
        _ = try await scoped.beta.agents.withRawResponse.retrieve("agent_test")
        _ = try await ScopedClient.copyScopedClient(scoped).beta.agents.withRawResponse.retrieve("agent_test")
        #expect(recorder.count == 2)
        for req in recorder.requests {
            #expect(req.url.host == "parent.example")
            #expect(req.headers["anthropic-workspace-id"] == "wrkspc_parent")
            #expect(req.headers.values("authorization") == ["Bearer env-key"])
        }
    }

    /// `copy()` drops the base URL and headers that came with the parent's credential (here an
    /// in-memory profile config), but the bearer is for the deployment and workspace the parent
    /// talks to.
    @Test func keepsTheHostAndHeadersOfTheParentsCredential() async throws {
        let tmp = try TempDir()
        let recorder = RequestRecorder { req, _ in platformJSON(agentJSON)(req) }
        let p = try Anthropic(config: [
            "base_url": "https://parent.example",
            "workspace_id": "wrkspc_parent",
            "authentication": ["type": "user_oauth", "credentials_path": .string(tmp.child("credentials.json").path)],
        ], transport: recorder.transport, environment: ["HOME": tmp.home.path])
        let scoped = try ScopedClient.copyWithBearerAuth(p, authToken: "env-key", helper: .environmentsWorker)
        _ = try await scoped.beta.agents.withRawResponse.retrieve("agent_test")
        _ = try await ScopedClient.copyScopedClient(scoped).beta.agents.withRawResponse.retrieve("agent_test")
        #expect(recorder.count == 2)
        for req in recorder.requests {
            #expect(req.url.host == "parent.example")
            #expect(req.headers["anthropic-workspace-id"] == "wrkspc_parent")
            #expect(req.headers.values("authorization") == ["Bearer env-key"])
        }
    }

    @Test func awsClientInAPIKeyModeSendsOnlyTheBearer() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(agentJSON)(req) }
        let p = try AnthropicAWS(apiKey: "parent-key", awsRegion: "us-east-1", workspaceID: "ws-123", transport: recorder.transport,
                                 environment: isolatedEnv())
        let scoped = try ScopedClient.copyWithBearerAuth(p, authToken: "env-key", helper: .environmentsWorker)
        _ = try await scoped.beta.agents.withRawResponse.retrieve("agent_test")
        #expect(scoped.apiKey == nil)
        #expect(p.apiKey == "parent-key")
        #expect(recorder.count == 1)
        #expect(recorder.requests[0].headers.values("authorization") == ["Bearer env-key"])
        #expect(recorder.requests[0].headers["x-api-key"] == nil)
    }

    @Test func copyOfAScopedClientKeepsItsBearerAlone() throws {
        let env = ["ANTHROPIC_CUSTOM_HEADERS": "authorization: Bearer env-secret\nX-Api-Key: env-api-key\nx-team: a",
                   "ANTHROPIC_API_KEY": "env-account-key"]
        let scoped = try ScopedClient.copyWithBearerAuth(try parent(env: env), authToken: "env-key", helper: .sessionToolRunner)
        let copy = try ScopedClient.copyScopedClient(scoped)
        #expect(copy.apiKey == nil)
        #expect(copy.defaultHeaders["Authorization"] == "Bearer env-key")
        #expect(copy.defaultHeaders["X-Api-Key"] == nil)
        let names = Set(copy.defaultHeaders.keys.map { $0.lowercased() })
        #expect(names.isSuperset(of: ["x-team", "x-stainless-helper"]))
        #expect(Set(copy.customHeaders.keys.map { $0.lowercased() }).isDisjoint(with: ["authorization", "x-api-key"]))
    }
}

// Port of lib/_retry.py's contract (no dedicated upstream test file).
@Suite struct HelperRetryTests {
    @Test func backoffAndJitter() {
        #expect(HelperRetry.backoff(attempt: 1, cap: 30) == 2)
        #expect(HelperRetry.backoff(attempt: 3, cap: 30) == 8)
        #expect(HelperRetry.backoff(attempt: 10, cap: 30) == 30)
        for _ in 0..<20 {
            let j = HelperRetry.jitter(1, 2)
            #expect(j >= 1 && j < 2)
        }
    }

    @Test func fatalStatusErrors() {
        let request = HTTPRequest(method: "GET", url: URL(string: "https://x.test")!)
        func error(_ status: Int) -> APIStatusError {
            makeStatusError("x", body: nil, response: HTTPResponse(statusCode: status, body: Data(), request: request))
        }
        #expect(HelperRetry.isFatalStatusError(error(401)))
        #expect(HelperRetry.isFatalStatusError(error(404)))
        #expect(!HelperRetry.isFatalStatusError(error(408)))
        #expect(!HelperRetry.isFatalStatusError(error(409)))
        #expect(!HelperRetry.isFatalStatusError(error(429)))
        #expect(!HelperRetry.isFatalStatusError(error(500)))
        #expect(!HelperRetry.isFatalStatusError(ValueError("x")))
        #expect(HelperRetry.isTransient(APIConnectionError(request: request)))
        #expect(!HelperRetry.isTransient(ValueError("bug")))
    }
}
