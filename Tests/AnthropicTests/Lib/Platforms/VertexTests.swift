import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/test_vertex.py (the async class; the sync twin is the same in Swift).

private let modelsURL = "https://region-aiplatform.googleapis.com/v1/projects/project/locations/region/publishers/anthropic/models/"
private let toolRunnerURL = "https://region-aiplatform.googleapis.com/v1/projects/project/locations/region/publishers/anthropic/models/claude-haiku-4-5@20251001:rawPredict"

private func vertex(_ recorder: RequestRecorder? = nil, region: String? = "region", projectID: String? = "project",
                    accessToken: String? = "my-access-token", baseURL: String? = nil, headers: Headers? = nil,
                    credentials: GoogleCredentials? = nil, loader: GoogleCredentialsLoader? = nil,
                    env: [String: String] = [:]) throws -> AnthropicVertex
{
    let client = try AnthropicVertex(region: region, projectID: projectID, accessToken: accessToken, credentials: credentials,
                                     baseURL: baseURL, defaultHeaders: headers, transport: (recorder ?? RequestRecorder()).transport,
                                     credentialsLoader: loader ?? { throw AnthropicError("ADC must not run in this test") },
                                     environment: isolatedEnv(env))
    client.sleeper = { _ in }
    return client
}

/// A duck-typed stand-in for a `google.auth` credentials object (`_FakeCredentials`).
final class FakeGoogleCredentials: GoogleCredentials, @unchecked Sendable {
    private let lock = NSLock()
    private var _token: String?
    private var _expired: Bool
    private var _refreshCalls = 0
    let projectID: String?

    init(token: String?, expired: Bool = false, projectID: String? = nil) {
        _token = token
        _expired = expired
        self.projectID = projectID
    }

    var token: String? { lock.withLock { _token } }
    var expired: Bool { lock.withLock { _expired } }
    var refreshCalls: Int { lock.withLock { _refreshCalls } }

    func refresh() async throws {
        lock.withLock {
            _refreshCalls += 1
            _token = "refreshed-token"
            _expired = false
        }
    }
}

@Suite struct VertexTests {
    @Test func messagesRetries() async throws {
        let url = modelsURL + "claude-3-sonnet@20240229:rawPredict"
        let recorder = RequestRecorder(sequence: [
            platformJSON(#"{"error": "server error"}"#, status: 500, headers: ["retry-after-ms": "10"]), platformMessageResponse,
        ])
        _ = try await vertex(recorder).withOptions(timeout: 0.2).messages.create(maxTokens: 1024, messages: userMessages("Say hello there!"),
                                                                                  model: "claude-3-sonnet@20240229")
        #expect(recorder.urls == [url, url])
    }

    @Test func requestRewrite() async throws {
        let recorder = RequestRecorder()
        _ = try await vertex(recorder).messages.create(maxTokens: 256, messages: userMessages("Hello"), model: "claude-haiku-4-5@20251001")
        let request = recorder.requests[0]
        #expect(request.url.absoluteString == toolRunnerURL)
        #expect(request.headers["Authorization"] == "Bearer my-access-token")
        #expect(request.headers["anthropic-version"] == nil)
        #expect(request.json["model"] == nil && request.json["stream"] == nil)
        #expect(request.json["anthropic_version"] == .string(ANTHROPIC_API_VERSION))
    }

    @Test func streamingUsesStreamRawPredict() async throws {
        let recorder = RequestRecorder { req, _ in
            let sse = "event: message_start\ndata: {\"type\": \"message_start\", \"message\": \(platformMessageJSON)}\n\nevent: message_stop\ndata: {\"type\": \"message_stop\"}\n\n"
            return HTTPResponse(statusCode: 200, headers: ["content-type": "text/event-stream"], stream: chunked(Data(sse.utf8)), request: req)
        }
        var n = 0
        for try await _ in try await vertex(recorder).messages.createStreaming(maxTokens: 8, messages: userMessages("hi"), model: "claude-x") { n += 1 }
        #expect(n == 2)
        #expect(recorder.urls == [modelsURL + "claude-x:streamRawPredict"])
        #expect(recorder.requests[0].json["stream"] == true)
    }

    /// `test_beta_messages_helpers_are_bound`, plus the routing checks of
    /// `test_beta_tool_runner_routes_through_raw_predict` for the helpers ported so far: `create`,
    /// `parse`, `stream` and `count_tokens` (beta and stable) go through `:rawPredict`
    /// (`:streamRawPredict`, `count-tokens:rawPredict`), with the body rewritten.
    @Test func messagesHelpersRouteThroughRawPredict() async throws {
        let recorder = RequestRecorder { req, _ in
            if req.url.path.hasSuffix(":streamRawPredict") { return platformCitySSEResponse(req) }
            if req.url.path.hasSuffix("count-tokens:rawPredict") { return platformJSON(#"{"input_tokens": 3}"#)(req) }
            return platformJSON(platformCityMessageJSON)(req)
        }
        let client = try vertex(recorder)
        let model: ModelParam = "claude-haiku-4-5@20251001"
        let city = PlatformHelpersCity(city: "Paris")

        _ = try await client.beta.messages.create(maxTokens: 256, messages: betaUserMessages("weather in Paris?"), model: model)
        let betaParsed = try await client.beta.messages.parse(maxTokens: 256, messages: betaUserMessages("weather in Paris?"), model: model,
                                                              outputFormat: PlatformHelpersCity.self)
        let betaStream = try await client.beta.messages.stream(maxTokens: 256, messages: betaUserMessages("weather in Paris?"), model: model,
                                                               outputFormat: PlatformHelpersCity.self)
        let betaStreamed = try await betaStream.getFinalMessage()
        let betaCount = try await client.beta.messages.countTokens(messages: betaUserMessages("weather in Paris?"), model: model)
        let parsed = try await client.messages.parse(maxTokens: 256, messages: userMessages("weather in Paris?"), model: model,
                                                     outputFormat: PlatformHelpersCity.self)
        let stream = try await client.messages.stream(maxTokens: 256, messages: userMessages("weather in Paris?"), model: model,
                                                      outputFormat: PlatformHelpersCity.self)
        let streamed = try await stream.getFinalMessage()

        #expect(betaParsed.parsedOutput == city)
        #expect(betaStreamed.parsedOutput == city)
        #expect(betaCount.inputTokens == 3)
        #expect(parsed.parsedOutput == city)
        #expect(streamed.parsedOutput == city)
        let streamURL = modelsURL + "claude-haiku-4-5@20251001:streamRawPredict"
        let countURL = modelsURL + "count-tokens:rawPredict"
        #expect(recorder.urls == [toolRunnerURL, toolRunnerURL, streamURL, countURL, toolRunnerURL, streamURL])
        for req in recorder.requests {
            #expect(req.headers["Authorization"] == "Bearer my-access-token")
            #expect(req.headers["anthropic-version"] == nil)
            let body = req.json
            #expect(body["output_format"] == nil)
            #expect(body["anthropic_version"] == .string(ANTHROPIC_API_VERSION))
        }
        for i in [0, 1, 4] { #expect(recorder.requests[i].json["model"] == nil && recorder.requests[i].json["stream"] == nil) }
        for i in [2, 5] { #expect(recorder.requests[i].json["model"] == nil && recorder.requests[i].json["stream"] == true) }
        for i in [1, 2, 4, 5] { #expect(recorder.requests[i].json["output_config"]?["format"]?["type"] == "json_schema") }
    }

    @Test func extraBodyAnthropicVersionWins() async throws {
        let recorder = RequestRecorder()
        _ = try await vertex(recorder).messages.create(maxTokens: 1024, messages: userMessages("Hello"), model: "claude-haiku-4-5@20251001",
                                                       extraBody: ["anthropic_version": "vertex-2023-10-16"])
        #expect(recorder.requests[0].json["anthropic_version"] == "vertex-2023-10-16")
    }

    @Test func userProfileIDIsSentInTheHeader() async throws {
        let recorder = RequestRecorder { req, _ in
            req.url.path.hasSuffix("count-tokens:rawPredict") ? platformJSON(#"{"input_tokens": 1}"#)(req) : platformMessageResponse(req)
        }
        let client = try vertex(recorder)
        _ = try await client.messages.create(maxTokens: 1024, messages: userMessages("Say hello there!"), model: "claude-3-sonnet@20240229",
                                             userProfileID: "uprof_test")
        _ = try await client.beta.messages.create(maxTokens: 1024, messages: betaUserMessages("Say hello there!"), model: "claude-3-sonnet@20240229",
                                                  userProfileID: "uprof_test")
        _ = try await client.messages.countTokens(messages: userMessages("Say hello there!"), model: "claude-3-sonnet@20240229",
                                                  userProfileID: "uprof_test")
        #expect(recorder.count == 3)
        #expect(recorder.urls[2] == modelsURL + "count-tokens:rawPredict")
        for request in recorder.requests {
            #expect(request.url.absoluteString.hasPrefix(modelsURL))
            #expect(request.headers["anthropic-user-profile-id"] == "uprof_test")
            #expect(request.json["user_profile_id"] == nil)
        }
    }

    @Test func clientUserProfileIDIsKept() async throws {
        let recorder = RequestRecorder()
        let client = try vertex(recorder).withOptions(defaultHeaders: ["anthropic-user-profile-id": "uprof_client"])
        _ = try await client.messages.create(maxTokens: 1024, messages: userMessages("Say hello there!"), model: "claude-3-sonnet@20240229")
        #expect(recorder.requests[0].headers["anthropic-user-profile-id"] == "uprof_client")
    }

    @Test func batchesAreRejected() async throws {
        let recorder = RequestRecorder()
        await expectThrows(AnthropicError.self, matching: "The Batch API is not supported in the Vertex client yet") {
            _ = try await vertex(recorder).messages.batches.withRawResponse.list()
        }
        #expect(recorder.count == 0)
    }

    @Test func missingProjectRaises() async throws {
        await expectThrows(AnthropicError.self, matching: "No project_id was given") {
            _ = try await vertex(projectID: nil).messages.create(maxTokens: 1, messages: userMessages("hi"), model: "claude")
        }
    }

    @Test func copy() throws {
        let client = try vertex()
        #expect(try client.copy() !== client)
        let copied = try client.copy(region: "another-region", projectID: "another-project")
        #expect(copied.region == "another-region")
        #expect(client.region == "region")
        #expect(copied.projectID == "another-project")
        #expect(client.projectID == "project")
    }

    @Test func withOptions() throws {
        let client = try vertex()
        let copied = try client.withOptions(region: "another-region", projectID: "another-project")
        #expect(copied.region == "another-region")
        #expect(client.region == "region")
        #expect(copied.projectID == "another-project")
        #expect(client.projectID == "project")
    }

    @Test func copyDefaultOptions() throws {
        let client = try vertex()
        let copied = try client.copy(maxRetries: 7)
        #expect(copied.maxRetries == 7)
        #expect(client.maxRetries == 2)
        let copied2 = try copied.copy(maxRetries: 6)
        #expect(copied2.maxRetries == 6)
        #expect(copied.maxRetries == 7)
        let noTimeout = try client.copy(timeout: Timeout.none)
        #expect(noTimeout.timeout == Timeout.none)
        #expect(client.timeout == DEFAULT_TIMEOUT)
    }

    @Test func copyDefaultHeaders() async throws {
        let client = try vertex(baseURL: testBaseURL, headers: ["X-Foo": "bar"])
        #expect(client.defaultHeaders["X-Foo"] == "bar")
        #expect(try client.copy().defaultHeaders["X-Foo"] == "bar")
        var copied = try client.copy(defaultHeaders: ["X-Bar": "stainless"])
        #expect(copied.defaultHeaders["X-Foo"] == "bar")
        #expect(copied.defaultHeaders["X-Bar"] == "stainless")
        #expect(try client.copy(defaultHeaders: ["X-Foo": "stainless"]).defaultHeaders["X-Foo"] == "stainless")
        #expect(try client.copy(setDefaultHeaders: [:]).defaultHeaders["X-Foo"] == nil)
        copied = try client.copy(setDefaultHeaders: ["X-Bar": "Robert"])
        #expect(copied.defaultHeaders["X-Bar"] == "Robert")
        await expectThrows(ValueError.self, matching: "`default_headers` and `set_default_headers` arguments are mutually exclusive") {
            _ = try client.copy(defaultHeaders: ["X-Foo": "Bar"], setDefaultHeaders: [:])
        }
    }

    @Test func copyXStainlessHelperHeaderAppends() throws {
        let client = try vertex(baseURL: testBaseURL, headers: ["x-stainless-helper": "parent"])
        #expect(try client.copy(defaultHeaders: ["x-stainless-helper": "child"]).defaultHeaders["x-stainless-helper"] == "parent, child")
    }

    @Test func globalRegionBaseURL() throws {
        #expect(try vertex(region: "global").baseURL.absoluteString == "https://aiplatform.googleapis.com/v1/")
    }

    @Test func usRegionBaseURL() throws {
        #expect(try vertex(region: "us").baseURL.absoluteString == "https://aiplatform.us.rep.googleapis.com/v1/")
    }

    @Test func euRegionBaseURL() throws {
        #expect(try vertex(region: "eu").baseURL.absoluteString == "https://aiplatform.eu.rep.googleapis.com/v1/")
    }

    @Test(arguments: ["us-central1", "europe-west1", "asia-southeast1"])
    func regionalBaseURL(region: String) throws {
        #expect(try vertex(region: region).baseURL.absoluteString == "https://\(region)-aiplatform.googleapis.com/v1/")
    }

    @Test func envVarBaseURLOverride() throws {
        let env = ["ANTHROPIC_VERTEX_BASE_URL": "https://custom-endpoint.googleapis.com/v1"]
        #expect(try vertex(region: "global", baseURL: "https://test.googleapis.com/v1", env: env).baseURL.absoluteString == "https://test.googleapis.com/v1/")
        #expect(try vertex(region: "global", env: env).baseURL.absoluteString == "https://custom-endpoint.googleapis.com/v1/")
    }

    @Test func regionFromEnvAndRequired() async throws {
        #expect(try vertex(region: nil, env: ["CLOUD_ML_REGION": "us-east5"]).region == "us-east5")
        await expectThrows(ValueError.self, matching: "No region was given") { _ = try vertex(region: nil) }
        #expect(try vertex(projectID: nil, env: ["ANTHROPIC_VERTEX_PROJECT_ID": "env-project"]).projectID == "env-project")
    }

    @Test func credentialsAreRefreshedAndADCBackfillsProject() async throws {
        let recorder = RequestRecorder()
        let creds = FakeGoogleCredentials(token: "stale", expired: true)
        _ = try await vertex(recorder, accessToken: nil, credentials: creds).messages.create(maxTokens: 1, messages: userMessages("hi"), model: "m")
        #expect(creds.refreshCalls == 1)
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer refreshed-token")

        let adc = FakeGoogleCredentials(token: "adc-token")
        let client = try vertex(recorder, accessToken: nil, loader: { (adc, "adc-project") })
        _ = try await client.messages.create(maxTokens: 1, messages: userMessages("hi"), model: "m")
        #expect(recorder.requests[1].headers["Authorization"] == "Bearer adc-token")
        #expect(client.credentials === adc)
    }

    @Test func callerAuthorizationWins() async throws {
        let recorder = RequestRecorder()
        _ = try await vertex(recorder, accessToken: nil).messages.create(maxTokens: 1, messages: userMessages("hi"), model: "m",
                                                                          extraHeaders: ["Authorization": "Bearer mine"])
        #expect(recorder.requests[0].headers.values("Authorization") == ["Bearer mine"])
    }

    @Test func statusErrorMapping() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(#"{"message": "x"}"#, status: 504)(req) }
        let client = try AnthropicVertex(region: "region", projectID: "project", accessToken: "t", maxRetries: 0, transport: recorder.transport,
                                         environment: isolatedEnv())
        await expectThrows(DeadlineExceededError.self, matching: "Error code: 504") {
            _ = try await client.messages.create(maxTokens: 1, messages: userMessages("hi"), model: "m")
        }
    }
}
