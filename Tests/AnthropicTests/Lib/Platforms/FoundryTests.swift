import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/test_azure.py.

private func foundry(_ recorder: RequestRecorder? = nil, resource: String? = nil, apiKey: String? = nil,
                     provider: AzureADTokenProvider? = nil, baseURL: String? = nil, headers: Headers? = nil, maxRetries: Int = 2,
                     env: [String: String] = [:]) throws -> AnthropicFoundry
{
    try AnthropicFoundry(resource: resource, apiKey: apiKey, azureADTokenProvider: provider, baseURL: baseURL, maxRetries: maxRetries,
                         defaultHeaders: headers, transport: (recorder ?? RequestRecorder()).transport, environment: isolatedEnv(env))
}

/// `client._build_request(client._prepare_options(FinalRequestOptions(...))).headers`
private func builtHeaders(_ client: AnthropicFoundry, headers: Headers? = nil) async throws -> HTTPHeaders {
    let options = try await client.prepareOptions(FinalRequestOptions(method: "post", url: "/v1/messages", headers: headers))
    return try client.buildRequest(options).headers
}

@Suite struct FoundryTests {
    @Test func basicInitializationWithAPIKey() throws {
        let client = try foundry(resource: "example-resource", apiKey: "test-key")
        #expect(client.apiKey == "test-key")
        #expect(client.baseURL.absoluteString == "https://example-resource.services.ai.azure.com/anthropic/")
    }

    @Test func initializationWithBaseURL() throws {
        let client = try foundry(apiKey: "test-key", baseURL: "https://example.services.ai.azure.com/anthropic/")
        #expect(client.baseURL.absoluteString == "https://example.services.ai.azure.com/anthropic/")
    }

    @Test func initializationWithAzureADTokenProvider() async throws {
        let client = try foundry(resource: "example-resource", provider: { "test-token" })
        #expect(client.azureADTokenProvider != nil)
        #expect(try await client.azureADToken() == "test-token")
    }

    @Test func asyncAzureADTokenProvider() async throws {
        let client = try foundry(resource: "example-resource", provider: {
            try await Task.sleep(nanoseconds: 1_000)
            return "async-test-token"
        })
        #expect(try await client.azureADToken() == "async-test-token")
    }

    @Test func initializationFromEnvironmentVariables() throws {
        let client = try foundry(env: ["ANTHROPIC_FOUNDRY_API_KEY": "env-key", "ANTHROPIC_API_VERSION": "2023-06-01",
                                       "ANTHROPIC_FOUNDRY_RESOURCE": "env-resource"])
        #expect(client.apiKey == "env-key")
        #expect(client.baseURL.absoluteString.contains("env-resource.services.ai.azure.com"))
    }

    @Test func missingCredentialsError() async {
        await expectThrows(AnthropicError.self, matching: "Missing credentials") { _ = try foundry(resource: "example-resource") }
    }

    @Test func missingResourceError() async {
        await expectThrows(ValueError.self, matching: "base_url.*resource") { _ = try foundry(apiKey: "test-key") }
        await expectThrows(ValueError.self, matching: "mutually exclusive") {
            _ = try foundry(resource: "r", apiKey: "test-key", baseURL: "https://example.com")
        }
    }

    @Test func copy() throws {
        let client = try foundry(resource: "example-resource", provider: { "test-token" }, headers: ["x-app": "1"], maxRetries: 5)
        let copied = try client.copy() as! AnthropicFoundry
        #expect(copied.baseURL == client.baseURL)
        #expect(copied.azureADTokenProvider != nil)
        #expect(copied.defaultHeaders["x-app"] == "1")
        #expect(copied.maxRetries == 5)
        #expect((copied.transport as? MockTransport) != nil)
    }

    @Test func withOptionsOverrides() throws {
        let client = try foundry(resource: "example-resource", apiKey: "test-key", headers: ["x-app": "1"])
        let derived = try client.withOptions(timeout: 10, defaultHeaders: ["x-extra": "2"])
        #expect(derived.timeout == 10)
        #expect(derived.apiKey == "test-key")
        #expect(derived.baseURL == client.baseURL)
        #expect(derived.defaultHeaders["x-app"] == "1")
        #expect(derived.defaultHeaders["x-extra"] == "2")
        #expect(derived is AnthropicFoundry)
    }

    @Test func copyXStainlessHelperHeaderAppends() throws {
        let client = try foundry(resource: "example-resource", apiKey: "test-key", headers: ["x-stainless-helper": "parent"])
        let copied = try client.withOptions(defaultHeaders: ["x-stainless-helper": "child"])
        #expect(copied.defaultHeaders["x-stainless-helper"] == "parent, child")
    }

    // MARK: TestFoundryDoesNotLeakAnthropicAPIKey

    @Test func noXAPIKeyWithAzureADTokenProvider() async throws {
        let client = try foundry(resource: "example-resource", provider: { "azure-token" }, env: ["ANTHROPIC_API_KEY": "sk-ant-should-not-leak"])
        let headers = try await builtHeaders(client)
        #expect(headers["x-api-key"] == nil)
        #expect(headers["authorization"] == "Bearer azure-token")
    }

    @Test func apiKeyModeSendsFoundryKeyAsXAPIKey() async throws {
        let client = try foundry(resource: "example-resource", apiKey: "foundry-key", env: ["ANTHROPIC_API_KEY": "sk-ant-should-not-leak"])
        let headers = try await builtHeaders(client)
        #expect(headers["x-api-key"] == "foundry-key")
        #expect(headers["api-key"] == "foundry-key")
        #expect(headers["authorization"] == nil)
        #expect(!headers.map(\.value).contains("sk-ant-should-not-leak"))
    }

    // MARK: TestFoundryCallerAuthHeaderCasing

    @Test func callerAuthorizationHeaderWinsCaseInsensitively() async throws {
        let client = try foundry(resource: "example-resource", provider: { "azure-token" })
        let headers = try await builtHeaders(client, headers: ["authorization": "Bearer per-request"])
        #expect(headers.values("authorization") == ["Bearer per-request"])
    }

    @Test func callerAPIKeyHeaderWinsCaseInsensitively() async throws {
        let client = try foundry(resource: "example-resource", apiKey: "foundry-key")
        let headers = try await builtHeaders(client, headers: ["X-Api-Key": "per-request-key"])
        #expect(headers.values("x-api-key") == ["per-request-key"])
    }

    // MARK: TestFoundryUserProfiles

    @Test func userProfileRequests() async throws {
        let recorder = RequestRecorder { req, _ in
            if req.method == "DELETE" { return platformJSON(#"{"id": "uprof_test", "type": "user_profile_deleted"}"#)(req) }
            return platformJSON(#"{"id": "uprof_test", "type": "user_profile"}"#)(req)
        }
        let client = try foundry(recorder, resource: "example-resource", apiKey: "foundry-key")
        _ = try await client.userProfiles.withRawResponse.create()
        _ = try await client.userProfiles.withRawResponse.retrieve("uprof_test")
        _ = try await client.userProfiles.withRawResponse.update("uprof_test")
        _ = try await client.userProfiles.withRawResponse.list()
        _ = try await client.userProfiles.withRawResponse.delete("uprof_test")
        let url = "https://example-resource.services.ai.azure.com/anthropic/v1/user_profiles"
        #expect(recorder.requests.map { "\($0.method) \($0.url.absoluteString)" } == [
            "POST \(url)", "GET \(url)/uprof_test", "POST \(url)/uprof_test", "GET \(url)", "DELETE \(url)/uprof_test",
        ])
        for request in recorder.requests { #expect(request.headers["x-api-key"] == "foundry-key") }
    }

    @Test func userProfileIDHeader() async throws {
        let recorder = RequestRecorder()
        let client = try foundry(recorder, resource: "example-resource", apiKey: "foundry-key", headers: ["anthropic-user-profile-id": "uprof_client"])
        _ = try await client.messages.create(maxTokens: 16, messages: userMessages("Hello"), model: "claude", userProfileID: "uprof_test")
        _ = try await client.messages.create(maxTokens: 16, messages: userMessages("Hello"), model: "claude")
        #expect(recorder.requests.map { $0.headers["anthropic-user-profile-id"] } == ["uprof_test", "uprof_client"])
        #expect(recorder.urls[0] == "https://example-resource.services.ai.azure.com/anthropic/v1/messages")
    }
}
