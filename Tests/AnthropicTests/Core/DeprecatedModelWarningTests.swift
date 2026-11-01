// Port of `tests/api_resources/test_messages.py::TestAsyncMessages::test_deprecated_model_warning`
// (not transformable by the test generator: it loops over `DEPRECATED_MODELS` under `pytest.warns`).

import Foundation
import Testing
@testable import Anthropic

@Suite struct DeprecatedModelWarningTests {
    static let message = #"{"id":"msg_1","type":"message","role":"assistant","model":"m","content":[],"usage":{"input_tokens":1,"output_tokens":1}}"#

    @Test func deprecatedModelWarning() async throws {
        let client = try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, maxRetries: 0, transport: MockTransport { request in
            HTTPResponse(statusCode: 200, headers: ["content-type": "application/json"], body: Data(Self.message.utf8), request: request)
        }, environment: [:])
        for deprecatedModel in DEPRECATED_MODELS.keys.sorted() {
            let warnings = try await AnthropicWarnings.capture {
                _ = try await client.messages.create(maxTokens: 1024, messages: [.user(UserMessageParam(content: "Hello"))],
                                                     model: ModelParam(rawValue: deprecatedModel))
            }
            #expect(warnings.contains { $0.category == .deprecation && $0.message.contains("The model '\(deprecatedModel)' is deprecated") })
        }
    }

    @Test func currentModelDoesNotWarn() async throws {
        let client = try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, maxRetries: 0, transport: MockTransport { request in
            HTTPResponse(statusCode: 200, headers: ["content-type": "application/json"], body: Data(Self.message.utf8), request: request)
        }, environment: [:])
        let warnings = try await AnthropicWarnings.capture {
            _ = try await client.messages.create(maxTokens: 1024, messages: [.user(UserMessageParam(content: "Hello"))], model: "claude-opus-5-5")
        }
        #expect(warnings.isEmpty)
    }
}
