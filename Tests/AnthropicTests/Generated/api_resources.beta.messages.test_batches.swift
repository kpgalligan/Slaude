// Transformed from `tests/api_resources/beta/messages/test_batches.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaMessagesBatches {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#, validateBody: { try MockRoute.roundTrip(BetaMessagesBatchCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.messages.batches.create(requests: [BetaMessagesBatchCreateParams.Request(customID: "my-custom-id-1", params: BetaMessageCreateParamsBase.MessageCreateParamsNonStreaming(maxTokens: 1024, messages: [BetaMessageParam.user(BetaUserMessageParam(content: BetaMessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5")))], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#, validateBody: { try MockRoute.roundTrip(BetaMessagesBatchCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.messages.batches.create(requests: [BetaMessagesBatchCreateParams.Request(customID: "my-custom-id-1", params: BetaMessageCreateParamsBase.MessageCreateParamsNonStreaming(maxTokens: 1024, messages: [BetaMessageParam.user(BetaUserMessageParam(content: BetaMessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5"), cacheControl: BetaCacheControlEphemeralParam(type: "ephemeral", ttl: "5m"), compaction: BetaCompactionConfigParam(type: "summarize", instructions: "instructions"), container: BetaMessageCreateParamsBase.Container.betaContainerParams(BetaContainerParams(id: "id", skills: [BetaSkillParams(skillID: "pdf", type: "anthropic", version: "latest")])), contextManagement: BetaContextManagementConfigParam(edits: [BetaContextManagementConfigParam.Edit.clearToolUses20250919(BetaClearToolUses20250919EditParam(type: "clear_tool_uses_20250919", clearAtLeast: BetaInputTokensClearAtLeastParam(type: "input_tokens", value: 0), clearToolInputs: .bool(true), excludeTools: ["string"], keep: BetaToolUsesKeepParam(type: "tool_uses", value: 0), trigger: BetaClearToolUses20250919EditParam.Trigger.inputTokens(BetaInputTokensTriggerParam(type: "input_tokens", value: 1))))]), diagnostics: BetaDiagnosticsParam(previousMessageID: "previous_message_id"), fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken.string("x"), fallbacks: BetaFallbacksParam.default("default"), inferenceGeo: "inference_geo", mcpServers: [BetaRequestMCPServerURLDefinitionParam(name: "name", type: "url", url: "url", authorizationToken: "authorization_token", toolConfiguration: BetaRequestMCPServerToolConfigurationParam(allowedTools: ["string"], enabled: true))], metadata: BetaMetadataParam(userID: "13803d75-b4b5-4c3e-b2a2-6f21399b021b"), outputConfig: BetaOutputConfigParam(effort: "low", format: BetaJSONOutputFormatParam(schema: ["foo": "bar"], type: "json_schema"), taskBudget: BetaTokenTaskBudgetParam(total: 1024, type: "tokens", remaining: 0)), serviceTier: "auto", speed: "standard", stopSequences: ["string"], system: .betaTextBlockParams([BetaTextBlockParam(text: "Today's date is 2024-06-01.", type: "text", cacheControl: BetaCacheControlEphemeralParam(type: "ephemeral", ttl: "5m"), citations: [BetaTextCitationParam.charLocation(BetaCitationCharLocationParam(citedText: "The grass is green. The sky is blue.", documentIndex: 0, documentTitle: "x", endCharIndex: 0, startCharIndex: 0, type: "char_location"))])]), thinking: BetaThinkingConfigParam.adaptive(BetaThinkingConfigAdaptiveParam(type: "adaptive", blockBinding: BetaThinkingBlockBindingParam(prefixMismatchBehavior: BetaThinkingPrefixMismatchBehavior(rawValue: "error")), display: "summarized")), thread: BetaMessageThreadParam.create(BetaThreadCreateParams(type: "create")), toolChoice: BetaToolChoiceParam.auto(BetaToolChoiceAutoParam(type: "auto", disableParallelToolUse: true)), tools: [BetaToolUnionParam.betaToolParam(BetaToolParam(inputSchema: BetaToolParam.InputSchema.inputSchemaTyped(BetaToolParam.InputSchemaTyped(type: "object", properties: ["location": "bar", "unit": "bar"], required: ["location"])), name: "name", allowedCallers: ["direct"], cacheControl: BetaCacheControlEphemeralParam(type: "ephemeral", ttl: "5m"), deferLoading: true, description: "Get the current weather in a given location", eagerInputStreaming: true, inputExamples: [["foo": "bar"]], strict: true, type: "custom"))], stream: false))], betas: [AnthropicBetaParam(rawValue: "string")], userProfileID: "anthropic-user-profile-id", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#, validateBody: { try MockRoute.roundTrip(BetaMessagesBatchCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.messages.batches.withRawResponse.create(requests: [BetaMessagesBatchCreateParams.Request(customID: "my-custom-id-1", params: BetaMessageCreateParamsBase.MessageCreateParamsNonStreaming(maxTokens: 1024, messages: [BetaMessageParam.user(BetaUserMessageParam(content: BetaMessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5")))], extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#, validateBody: { try MockRoute.roundTrip(BetaMessagesBatchCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.messages.batches.withStreamingResponse.create(requests: [BetaMessagesBatchCreateParams.Request(customID: "my-custom-id-1", params: BetaMessageCreateParamsBase.MessageCreateParamsNonStreaming(maxTokens: 1024, messages: [BetaMessageParam.user(BetaUserMessageParam(content: BetaMessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5")))], extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/messages/batches/{message_batch_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#)
        let client = try route.client()
        let value = try await client.beta.messages.batches.retrieve("message_batch_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/messages/batches/{message_batch_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#)
        let client = try route.client()
        let value = try await client.beta.messages.batches.retrieve("message_batch_id", betas: [AnthropicBetaParam(rawValue: "string")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/messages/batches/{message_batch_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#)
        let client = try route.client()
        let response = try await client.beta.messages.batches.withRawResponse.retrieve("message_batch_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/messages/batches/{message_batch_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.messages.batches.withStreamingResponse.retrieve("message_batch_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `message_batch_id` but received ''") { _ = try await client.beta.messages.batches.withRawResponse.retrieve("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/messages/batches", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.messages.batches.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/messages/batches", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.messages.batches.list(afterID: "after_id", beforeID: "before_id", limit: 1, betas: [AnthropicBetaParam(rawValue: "string")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/messages/batches", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.messages.batches.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/messages/batches", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.messages.batches.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/messages/batches/{message_batch_id}", json: #"{"id": "string", "type": "message_batch_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.messages.batches.delete("message_batch_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/messages/batches/{message_batch_id}", json: #"{"id": "string", "type": "message_batch_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.messages.batches.delete("message_batch_id", betas: [AnthropicBetaParam(rawValue: "string")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/messages/batches/{message_batch_id}", json: #"{"id": "string", "type": "message_batch_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.messages.batches.withRawResponse.delete("message_batch_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/messages/batches/{message_batch_id}", json: #"{"id": "string", "type": "message_batch_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.messages.batches.withStreamingResponse.delete("message_batch_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `message_batch_id` but received ''") { _ = try await client.beta.messages.batches.withRawResponse.delete("") }
    }

    @Test func methodCancel() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches/{message_batch_id}/cancel", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#)
        let client = try route.client()
        let value = try await client.beta.messages.batches.cancel("message_batch_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCancelWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches/{message_batch_id}/cancel", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#)
        let client = try route.client()
        let value = try await client.beta.messages.batches.cancel("message_batch_id", betas: [AnthropicBetaParam(rawValue: "string")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCancel() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches/{message_batch_id}/cancel", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#)
        let client = try route.client()
        let response = try await client.beta.messages.batches.withRawResponse.cancel("message_batch_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCancel() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches/{message_batch_id}/cancel", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.messages.batches.withStreamingResponse.cancel("message_batch_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsCancel() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `message_batch_id` but received ''") { _ = try await client.beta.messages.batches.withRawResponse.cancel("") }
    }
}
