// Transformed from `tests/api_resources/test_messages.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestMessages {
    @Test func methodCreateOverload1() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages", json: #"{"id": "string", "container": {"id": "string", "expires_at": "2024-01-01T00:00:00Z", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}]}, "content": [{"text": "string", "type": "text"}], "diagnostics": {"cache_miss_reason": {"cache_missed_input_tokens": 0, "type": "model_changed"}}, "model": "claude-haiku-5-5", "role": "assistant", "stop_details": {"category": "cyber", "explanation": "string", "type": "refusal"}, "stop_reason": "end_turn", "stop_sequence": "string", "type": "message", "usage": {"cache_creation": {"ephemeral_1h_input_tokens": 0, "ephemeral_5m_input_tokens": 0}, "cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "inference_geo": "string", "input_tokens": 0, "output_tokens": 0, "output_tokens_details": {"thinking_tokens": 0}, "server_tool_use": {"web_fetch_requests": 0, "web_search_requests": 0}, "service_tier": "standard", "speed": "standard"}}"#, validateBody: { try MockRoute.roundTrip(MessageCreateParamsBase.self, $0) })
        let client = try route.client()
        let value = try await client.messages.create(maxTokens: 1024, messages: [MessageParam.user(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5"))
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParamsOverload1() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages", json: #"{"id": "string", "container": {"id": "string", "expires_at": "2024-01-01T00:00:00Z", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}]}, "content": [{"text": "string", "type": "text"}], "diagnostics": {"cache_miss_reason": {"cache_missed_input_tokens": 0, "type": "model_changed"}}, "model": "claude-haiku-5-5", "role": "assistant", "stop_details": {"category": "cyber", "explanation": "string", "type": "refusal"}, "stop_reason": "end_turn", "stop_sequence": "string", "type": "message", "usage": {"cache_creation": {"ephemeral_1h_input_tokens": 0, "ephemeral_5m_input_tokens": 0}, "cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "inference_geo": "string", "input_tokens": 0, "output_tokens": 0, "output_tokens_details": {"thinking_tokens": 0}, "server_tool_use": {"web_fetch_requests": 0, "web_search_requests": 0}, "service_tier": "standard", "speed": "standard"}}"#, validateBody: { try MockRoute.roundTrip(MessageCreateParamsBase.self, $0) })
        let client = try route.client()
        let value = try await client.messages.create(maxTokens: 1024, messages: [MessageParam.user(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5"), cacheControl: CacheControlEphemeralParam(type: "ephemeral", ttl: "5m"), container: MessageCreateParamsContainerParam.containerParams(ContainerParams(id: "id", skills: [SkillParams(skillID: "pdf", type: "anthropic", version: "latest")])), diagnostics: DiagnosticsParam(previousMessageID: "previous_message_id"), inferenceGeo: "inference_geo", metadata: MetadataParam(userID: "13803d75-b4b5-4c3e-b2a2-6f21399b021b"), outputConfig: OutputConfigParam(effort: "low", format: JSONOutputFormatParam(schema: ["foo": "bar"], type: "json_schema")), serviceTier: "auto", speed: "standard", stopSequences: ["string"], system: .textBlockParams([TextBlockParam(text: "Today's date is 2024-06-01.", type: "text", cacheControl: CacheControlEphemeralParam(type: "ephemeral", ttl: "5m"), citations: [TextCitationParam.charLocation(CitationCharLocationParam(citedText: "The grass is green. The sky is blue.", documentIndex: 0, documentTitle: "x", endCharIndex: 0, startCharIndex: 0, type: "char_location"))])]), thinking: ThinkingConfigParam.adaptive(ThinkingConfigAdaptiveParam(type: "adaptive", display: "summarized")), toolChoice: ToolChoiceParam.auto(ToolChoiceAutoParam(type: "auto", disableParallelToolUse: true)), tools: [ToolUnionParam.toolParam(ToolParam(inputSchema: ToolParam.InputSchema.inputSchemaTyped(ToolParam.InputSchemaTyped(type: "object", properties: ["location": "bar", "unit": "bar"], required: ["location"])), name: "name", allowedCallers: ["direct"], cacheControl: CacheControlEphemeralParam(type: "ephemeral", ttl: "5m"), deferLoading: true, description: "Get the current weather in a given location", eagerInputStreaming: true, inputExamples: [["foo": "bar"]], strict: true, type: "custom"))], userProfileID: "anthropic-user-profile-id", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreateOverload1() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages", json: #"{"id": "string", "container": {"id": "string", "expires_at": "2024-01-01T00:00:00Z", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}]}, "content": [{"text": "string", "type": "text"}], "diagnostics": {"cache_miss_reason": {"cache_missed_input_tokens": 0, "type": "model_changed"}}, "model": "claude-haiku-5-5", "role": "assistant", "stop_details": {"category": "cyber", "explanation": "string", "type": "refusal"}, "stop_reason": "end_turn", "stop_sequence": "string", "type": "message", "usage": {"cache_creation": {"ephemeral_1h_input_tokens": 0, "ephemeral_5m_input_tokens": 0}, "cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "inference_geo": "string", "input_tokens": 0, "output_tokens": 0, "output_tokens_details": {"thinking_tokens": 0}, "server_tool_use": {"web_fetch_requests": 0, "web_search_requests": 0}, "service_tier": "standard", "speed": "standard"}}"#, validateBody: { try MockRoute.roundTrip(MessageCreateParamsBase.self, $0) })
        let client = try route.client()
        let response = try await client.messages.withRawResponse.create(maxTokens: 1024, messages: [MessageParam.user(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5"))
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreateOverload1() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages", json: #"{"id": "string", "container": {"id": "string", "expires_at": "2024-01-01T00:00:00Z", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}]}, "content": [{"text": "string", "type": "text"}], "diagnostics": {"cache_miss_reason": {"cache_missed_input_tokens": 0, "type": "model_changed"}}, "model": "claude-haiku-5-5", "role": "assistant", "stop_details": {"category": "cyber", "explanation": "string", "type": "refusal"}, "stop_reason": "end_turn", "stop_sequence": "string", "type": "message", "usage": {"cache_creation": {"ephemeral_1h_input_tokens": 0, "ephemeral_5m_input_tokens": 0}, "cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "inference_geo": "string", "input_tokens": 0, "output_tokens": 0, "output_tokens_details": {"thinking_tokens": 0}, "server_tool_use": {"web_fetch_requests": 0, "web_search_requests": 0}, "service_tier": "standard", "speed": "standard"}}"#, validateBody: { try MockRoute.roundTrip(MessageCreateParamsBase.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.messages.withStreamingResponse.create(maxTokens: 1024, messages: [MessageParam.user(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5"), body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodCreateOverload2() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages", sse: "event: message_start\ndata: {\"message\": {\"id\": \"string\", \"container\": {\"id\": \"string\", \"expires_at\": \"2024-01-01T00:00:00Z\"}, \"content\": [{\"text\": \"string\", \"type\": \"text\"}], \"diagnostics\": {}, \"model\": \"claude-haiku-5-5\", \"role\": \"assistant\", \"stop_details\": {\"type\": \"refusal\"}, \"stop_reason\": \"end_turn\", \"stop_sequence\": \"string\", \"type\": \"message\", \"usage\": {\"input_tokens\": 0, \"output_tokens\": 0}}, \"type\": \"message_start\"}\n\nevent: message_stop\ndata: {\"type\": \"message_stop\"}\n\n", validateBody: { try MockRoute.roundTrip(MessageCreateParamsBase.self, $0, dropKeys: ["stream"]) })
        let client = try route.client()
        let value = try await client.messages.createStreaming(maxTokens: 1024, messages: [MessageParam.user(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5"))
        try await route.drain(value)
    }

    @Test func methodCreateWithAllParamsOverload2() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages", sse: "event: message_start\ndata: {\"message\": {\"id\": \"string\", \"container\": {\"id\": \"string\", \"expires_at\": \"2024-01-01T00:00:00Z\"}, \"content\": [{\"text\": \"string\", \"type\": \"text\"}], \"diagnostics\": {}, \"model\": \"claude-haiku-5-5\", \"role\": \"assistant\", \"stop_details\": {\"type\": \"refusal\"}, \"stop_reason\": \"end_turn\", \"stop_sequence\": \"string\", \"type\": \"message\", \"usage\": {\"input_tokens\": 0, \"output_tokens\": 0}}, \"type\": \"message_start\"}\n\nevent: message_stop\ndata: {\"type\": \"message_stop\"}\n\n", validateBody: { try MockRoute.roundTrip(MessageCreateParamsBase.self, $0, dropKeys: ["stream"]) })
        let client = try route.client()
        let value = try await client.messages.createStreaming(maxTokens: 1024, messages: [MessageParam.user(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5"), cacheControl: CacheControlEphemeralParam(type: "ephemeral", ttl: "5m"), container: MessageCreateParamsContainerParam.containerParams(ContainerParams(id: "id", skills: [SkillParams(skillID: "pdf", type: "anthropic", version: "latest")])), diagnostics: DiagnosticsParam(previousMessageID: "previous_message_id"), inferenceGeo: "inference_geo", metadata: MetadataParam(userID: "13803d75-b4b5-4c3e-b2a2-6f21399b021b"), outputConfig: OutputConfigParam(effort: "low", format: JSONOutputFormatParam(schema: ["foo": "bar"], type: "json_schema")), serviceTier: "auto", speed: "standard", stopSequences: ["string"], system: .textBlockParams([TextBlockParam(text: "Today's date is 2024-06-01.", type: "text", cacheControl: CacheControlEphemeralParam(type: "ephemeral", ttl: "5m"), citations: [TextCitationParam.charLocation(CitationCharLocationParam(citedText: "The grass is green. The sky is blue.", documentIndex: 0, documentTitle: "x", endCharIndex: 0, startCharIndex: 0, type: "char_location"))])]), thinking: ThinkingConfigParam.adaptive(ThinkingConfigAdaptiveParam(type: "adaptive", display: "summarized")), toolChoice: ToolChoiceParam.auto(ToolChoiceAutoParam(type: "auto", disableParallelToolUse: true)), tools: [ToolUnionParam.toolParam(ToolParam(inputSchema: ToolParam.InputSchema.inputSchemaTyped(ToolParam.InputSchemaTyped(type: "object", properties: ["location": "bar", "unit": "bar"], required: ["location"])), name: "name", allowedCallers: ["direct"], cacheControl: CacheControlEphemeralParam(type: "ephemeral", ttl: "5m"), deferLoading: true, description: "Get the current weather in a given location", eagerInputStreaming: true, inputExamples: [["foo": "bar"]], strict: true, type: "custom"))], userProfileID: "anthropic-user-profile-id", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        try await route.drain(value)
    }

    @Test func rawResponseCreateOverload2() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages", sse: "event: message_start\ndata: {\"message\": {\"id\": \"string\", \"container\": {\"id\": \"string\", \"expires_at\": \"2024-01-01T00:00:00Z\"}, \"content\": [{\"text\": \"string\", \"type\": \"text\"}], \"diagnostics\": {}, \"model\": \"claude-haiku-5-5\", \"role\": \"assistant\", \"stop_details\": {\"type\": \"refusal\"}, \"stop_reason\": \"end_turn\", \"stop_sequence\": \"string\", \"type\": \"message\", \"usage\": {\"input_tokens\": 0, \"output_tokens\": 0}}, \"type\": \"message_start\"}\n\nevent: message_stop\ndata: {\"type\": \"message_stop\"}\n\n", validateBody: { try MockRoute.roundTrip(MessageCreateParamsBase.self, $0, dropKeys: ["stream"]) })
        let client = try route.client()
        let response = try await client.messages.withRawResponse.createStreaming(maxTokens: 1024, messages: [MessageParam.user(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5"))
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try await route.drain(value)
    }

    @Test func streamingResponseCreateOverload2() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages", sse: "event: message_start\ndata: {\"message\": {\"id\": \"string\", \"container\": {\"id\": \"string\", \"expires_at\": \"2024-01-01T00:00:00Z\"}, \"content\": [{\"text\": \"string\", \"type\": \"text\"}], \"diagnostics\": {}, \"model\": \"claude-haiku-5-5\", \"role\": \"assistant\", \"stop_details\": {\"type\": \"refusal\"}, \"stop_reason\": \"end_turn\", \"stop_sequence\": \"string\", \"type\": \"message\", \"usage\": {\"input_tokens\": 0, \"output_tokens\": 0}}, \"type\": \"message_start\"}\n\nevent: message_stop\ndata: {\"type\": \"message_stop\"}\n\n", validateBody: { try MockRoute.roundTrip(MessageCreateParamsBase.self, $0, dropKeys: ["stream"]) })
        let client = try route.client()
        let (response, value) = try await client.messages.withStreamingResponse.createStreaming(maxTokens: 1024, messages: [MessageParam.user(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5"), body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try await route.drain(value)
        #expect(response.isClosed)
    }

    @Test func methodCountTokens() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/count_tokens", json: #"{"input_tokens": 0}"#, validateBody: { try MockRoute.roundTrip(MessageCountTokensParams.self, $0) })
        let client = try route.client()
        let value = try await client.messages.countTokens(messages: [MessageParam.user(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5"))
        try route.verifyRoundTrip(value)
    }

    @Test func methodCountTokensWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/count_tokens", json: #"{"input_tokens": 0}"#, validateBody: { try MockRoute.roundTrip(MessageCountTokensParams.self, $0) })
        let client = try route.client()
        let value = try await client.messages.countTokens(messages: [MessageParam.user(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5"), cacheControl: CacheControlEphemeralParam(type: "ephemeral", ttl: "5m"), outputConfig: OutputConfigParam(effort: "low", format: JSONOutputFormatParam(schema: ["foo": "bar"], type: "json_schema")), speed: "standard", system: .textBlockParams([TextBlockParam(text: "Today's date is 2024-06-01.", type: "text", cacheControl: CacheControlEphemeralParam(type: "ephemeral", ttl: "5m"), citations: [TextCitationParam.charLocation(CitationCharLocationParam(citedText: "The grass is green. The sky is blue.", documentIndex: 0, documentTitle: "x", endCharIndex: 0, startCharIndex: 0, type: "char_location"))])]), thinking: ThinkingConfigParam.adaptive(ThinkingConfigAdaptiveParam(type: "adaptive", display: "summarized")), toolChoice: ToolChoiceParam.auto(ToolChoiceAutoParam(type: "auto", disableParallelToolUse: true)), tools: [MessageCountTokensToolParam.toolParam(ToolParam(inputSchema: ToolParam.InputSchema.inputSchemaTyped(ToolParam.InputSchemaTyped(type: "object", properties: ["location": "bar", "unit": "bar"], required: ["location"])), name: "name", allowedCallers: ["direct"], cacheControl: CacheControlEphemeralParam(type: "ephemeral", ttl: "5m"), deferLoading: true, description: "Get the current weather in a given location", eagerInputStreaming: true, inputExamples: [["foo": "bar"]], strict: true, type: "custom"))], userProfileID: "anthropic-user-profile-id", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCountTokens() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/count_tokens", json: #"{"input_tokens": 0}"#, validateBody: { try MockRoute.roundTrip(MessageCountTokensParams.self, $0) })
        let client = try route.client()
        let response = try await client.messages.withRawResponse.countTokens(messages: [MessageParam.user(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5"))
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCountTokens() async throws {
        let route = MockRoute(method: "POST", path: "/v1/messages/count_tokens", json: #"{"input_tokens": 0}"#, validateBody: { try MockRoute.roundTrip(MessageCountTokensParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.messages.withStreamingResponse.countTokens(messages: [MessageParam.user(UserMessageParam(content: MessageContentParam.string("Hello, world"), role: "user"))], model: ModelParam(rawValue: "claude-opus-5-5"), body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }
}
