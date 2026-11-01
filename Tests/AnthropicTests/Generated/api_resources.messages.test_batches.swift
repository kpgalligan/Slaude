// Transformed from `tests/api_resources/messages/test_batches.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestMessagesBatches {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#, validateBody: { try MockRoute.roundTrip(BatchCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.messages.batches.create(requests: [BatchCreateParams.Request(customID: "my-custom-id-1", params: MessageCreateParamsBase.MessageCreateParamsNonStreaming(maxTokens: 1024, messages: [MessageParam.userMessageParam(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5")))])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#, validateBody: { try MockRoute.roundTrip(BatchCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.messages.batches.create(requests: [BatchCreateParams.Request(customID: "my-custom-id-1", params: MessageCreateParamsBase.MessageCreateParamsNonStreaming(maxTokens: 1024, messages: [MessageParam.userMessageParam(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5"), cacheControl: CacheControlEphemeralParam(type: "ephemeral", ttl: "5m"), container: MessageCreateParamsContainerParam.containerParams(ContainerParams(id: "id", skills: [SkillParams(skillID: "pdf", type: "anthropic", version: "latest")])), diagnostics: DiagnosticsParam(previousMessageID: "previous_message_id"), inferenceGeo: "inference_geo", metadata: MetadataParam(userID: "13803d75-b4b5-4c3e-b2a2-6f21399b021b"), outputConfig: OutputConfigParam(effort: "low", format: JSONOutputFormatParam(schema: ["foo": "bar"], type: "json_schema")), serviceTier: "auto", speed: "standard", stopSequences: ["string"], system: .textBlockParams([TextBlockParam(text: "Today's date is 2024-06-01.", type: "text", cacheControl: CacheControlEphemeralParam(type: "ephemeral", ttl: "5m"), citations: [TextCitationParam.charLocation(CitationCharLocationParam(citedText: "The grass is green. The sky is blue.", documentIndex: 0, documentTitle: "x", endCharIndex: 0, startCharIndex: 0, type: "char_location"))])]), thinking: ThinkingConfigParam.adaptive(ThinkingConfigAdaptiveParam(type: "adaptive", display: "summarized")), toolChoice: ToolChoiceParam.auto(ToolChoiceAutoParam(type: "auto", disableParallelToolUse: true)), tools: [ToolUnionParam.toolParam(ToolParam(inputSchema: ToolParam.InputSchema.inputSchemaTyped(ToolParam.InputSchemaTyped(type: "object", properties: ["location": "bar", "unit": "bar"], required: ["location"])), name: "name", allowedCallers: ["direct"], cacheControl: CacheControlEphemeralParam(type: "ephemeral", ttl: "5m"), deferLoading: true, description: "Get the current weather in a given location", eagerInputStreaming: true, inputExamples: [["foo": "bar"]], strict: true, type: "custom"))], stream: false))], userProfileID: "anthropic-user-profile-id", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#, validateBody: { try MockRoute.roundTrip(BatchCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.messages.batches.withRawResponse.create(requests: [BatchCreateParams.Request(customID: "my-custom-id-1", params: MessageCreateParamsBase.MessageCreateParamsNonStreaming(maxTokens: 1024, messages: [MessageParam.userMessageParam(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5")))])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#, validateBody: { try MockRoute.roundTrip(BatchCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.messages.batches.withStreamingResponse.create(requests: [BatchCreateParams.Request(customID: "my-custom-id-1", params: MessageCreateParamsBase.MessageCreateParamsNonStreaming(maxTokens: 1024, messages: [MessageParam.userMessageParam(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5")))], body: { response in
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
        let value = try await client.messages.batches.retrieve("message_batch_id")
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/messages/batches/{message_batch_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#)
        let client = try route.client()
        let value = try await client.messages.batches.retrieve("message_batch_id", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/messages/batches/{message_batch_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#)
        let client = try route.client()
        let response = try await client.messages.batches.withRawResponse.retrieve("message_batch_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/messages/batches/{message_batch_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#)
        let client = try route.client()
        let (response, value) = try await client.messages.batches.withStreamingResponse.retrieve("message_batch_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `message_batch_id` but received ''") { _ = try await client.messages.batches.withRawResponse.retrieve("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/messages/batches", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.messages.batches.list()
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/messages/batches", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.messages.batches.list(afterID: "after_id", beforeID: "before_id", limit: 1, workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/messages/batches", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.messages.batches.withRawResponse.list()
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/messages/batches", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.messages.batches.withStreamingResponse.list(body: { response in
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
        let value = try await client.messages.batches.delete("message_batch_id")
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/messages/batches/{message_batch_id}", json: #"{"id": "string", "type": "message_batch_deleted"}"#)
        let client = try route.client()
        let value = try await client.messages.batches.delete("message_batch_id", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/messages/batches/{message_batch_id}", json: #"{"id": "string", "type": "message_batch_deleted"}"#)
        let client = try route.client()
        let response = try await client.messages.batches.withRawResponse.delete("message_batch_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/messages/batches/{message_batch_id}", json: #"{"id": "string", "type": "message_batch_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.messages.batches.withStreamingResponse.delete("message_batch_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `message_batch_id` but received ''") { _ = try await client.messages.batches.withRawResponse.delete("") }
    }

    @Test func methodCancel() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches/{message_batch_id}/cancel", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#)
        let client = try route.client()
        let value = try await client.messages.batches.cancel("message_batch_id")
        try route.verifyRoundTrip(value)
    }

    @Test func methodCancelWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches/{message_batch_id}/cancel", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#)
        let client = try route.client()
        let value = try await client.messages.batches.cancel("message_batch_id", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCancel() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches/{message_batch_id}/cancel", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#)
        let client = try route.client()
        let response = try await client.messages.batches.withRawResponse.cancel("message_batch_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCancel() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/batches/{message_batch_id}/cancel", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "cancel_initiated_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "processing_status": "in_progress", "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}, "results_url": "string", "type": "message_batch"}"#)
        let client = try route.client()
        let (response, value) = try await client.messages.batches.withStreamingResponse.cancel("message_batch_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsCancel() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `message_batch_id` but received ''") { _ = try await client.messages.batches.withRawResponse.cancel("") }
    }
}
