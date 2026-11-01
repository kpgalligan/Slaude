// Transformed from `anthropic.resources.beta.messages.messages` (messages.py).

import Foundation

public struct BetaMessagesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var batches: BetaMessagesBatchesResource { BetaMessagesBatchesResource(client: client) }

    public func create(maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil, compaction: BetaCompactionConfigParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil, contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil, fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil, inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, metadata: BetaMetadataParam? = nil, outputConfig: BetaOutputConfigParam? = nil, serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil, speed: BetaMessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil, thinking: BetaThinkingConfigParam? = nil, thread: BetaMessageThreadParam?? = nil, toolChoice: BetaToolChoiceParam? = nil, tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaMessage {
        try await _create(maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, compaction: compaction, container: container, contextManagement: contextManagement, diagnostics: diagnostics, fallbackCreditToken: fallbackCreditToken, fallbacks: fallbacks, inferenceGeo: inferenceGeo, mcpServers: mcpServers, metadata: metadata, outputConfig: outputConfig, serviceTier: serviceTier, speed: speed, stopSequences: stopSequences, system: system, thinking: thinking, thread: thread, toolChoice: toolChoice, tools: tools, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil, compaction: BetaCompactionConfigParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil, contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil, fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil, inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, metadata: BetaMetadataParam? = nil, outputConfig: BetaOutputConfigParam? = nil, serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil, speed: BetaMessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil, thinking: BetaThinkingConfigParam? = nil, thread: BetaMessageThreadParam?? = nil, toolChoice: BetaToolChoiceParam? = nil, tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaMessage> {
        warnIfDeprecatedModel(model.rawValue)
        warnIfThinkingEnabledDeprecated(model.rawValue, thinking: thinking)
        var timeout = timeout
        if timeout == nil && client.timeout == DEFAULT_TIMEOUT && !client.timeoutOverridden { timeout = try client.calculateNonstreamingTimeout(maxTokens: maxTokens, maxNonstreamingTokens: MODEL_NONSTREAMING_TOKENS[model.rawValue]) }
        var body = ParamsBuilder()
        try body.set("max_tokens", maxTokens)
        try body.set("messages", messages)
        try body.set("model", model)
        try body.set("cache_control", cacheControl)
        try body.set("compaction", compaction)
        try body.set("container", container)
        try body.set("context_management", contextManagement)
        try body.set("diagnostics", diagnostics)
        try body.set("fallback_credit_token", fallbackCreditToken)
        try body.set("fallbacks", fallbacks)
        try body.set("inference_geo", inferenceGeo)
        try body.set("mcp_servers", mcpServers)
        try body.set("metadata", metadata)
        try body.set("output_config", outputConfig)
        try body.set("service_tier", serviceTier)
        try body.set("speed", speed)
        try body.set("stop_sequences", stopSequences)
        try body.set("system", system)
        try body.set("thinking", thinking)
        try body.set("thread", thread)
        try body.set("tool_choice", toolChoice)
        try body.set("tools", tools)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/messages", body: body, headers: mergeHeaders(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ",")), ("anthropic-user-profile-id", userProfileID), ("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.messages.create", spanRoute: "/v1/messages", spanBodyAttributes: messagesCreateRequestAttributes, qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaMessage.self, options, stream: _mode == .stream)
    }

    public func createStreaming(maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil, compaction: BetaCompactionConfigParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil, contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil, fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil, inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, metadata: BetaMetadataParam? = nil, outputConfig: BetaOutputConfigParam? = nil, serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil, speed: BetaMessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil, thinking: BetaThinkingConfigParam? = nil, thread: BetaMessageThreadParam?? = nil, toolChoice: BetaToolChoiceParam? = nil, tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Stream<BetaRawMessageStreamEvent> {
        try await _createStreaming(maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, compaction: compaction, container: container, contextManagement: contextManagement, diagnostics: diagnostics, fallbackCreditToken: fallbackCreditToken, fallbacks: fallbacks, inferenceGeo: inferenceGeo, mcpServers: mcpServers, metadata: metadata, outputConfig: outputConfig, serviceTier: serviceTier, speed: speed, stopSequences: stopSequences, system: system, thinking: thinking, thread: thread, toolChoice: toolChoice, tools: tools, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _createStreaming(maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil, compaction: BetaCompactionConfigParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil, contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil, fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil, inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, metadata: BetaMetadataParam? = nil, outputConfig: BetaOutputConfigParam? = nil, serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil, speed: BetaMessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil, thinking: BetaThinkingConfigParam? = nil, thread: BetaMessageThreadParam?? = nil, toolChoice: BetaToolChoiceParam? = nil, tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Stream<BetaRawMessageStreamEvent>> {
        warnIfDeprecatedModel(model.rawValue)
        warnIfThinkingEnabledDeprecated(model.rawValue, thinking: thinking)
        var body = ParamsBuilder()
        try body.set("max_tokens", maxTokens)
        try body.set("messages", messages)
        try body.set("model", model)
        try body.set("cache_control", cacheControl)
        try body.set("compaction", compaction)
        try body.set("container", container)
        try body.set("context_management", contextManagement)
        try body.set("diagnostics", diagnostics)
        try body.set("fallback_credit_token", fallbackCreditToken)
        try body.set("fallbacks", fallbacks)
        try body.set("inference_geo", inferenceGeo)
        try body.set("mcp_servers", mcpServers)
        try body.set("metadata", metadata)
        try body.set("output_config", outputConfig)
        try body.set("service_tier", serviceTier)
        try body.set("speed", speed)
        try body.set("stop_sequences", stopSequences)
        try body.set("system", system)
        try body.set("thinking", thinking)
        try body.set("thread", thread)
        try body.set("tool_choice", toolChoice)
        try body.set("tools", tools)
        body.put("stream", true)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/messages", body: body, headers: mergeHeaders(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ",")), ("anthropic-user-profile-id", userProfileID), ("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.messages.create", spanRoute: "/v1/messages", spanBodyAttributes: messagesCreateRequestAttributes, qualifiers: ["beta": "true"])
        return try await client.requestStreamResponse(BetaRawMessageStreamEvent.self, options)
    }

    /// Count the number of tokens in a Message.
    ///
    /// The Token Count API can be used to count the number of tokens in a Message,
    /// including tools, images, and documents, without creating it.
    ///
    /// Learn more about token counting in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/token-counting)
    ///
    /// Args:
    ///   messages: Input messages.
    ///
    ///       Our models are trained to operate on alternating `user` and `assistant`
    ///       conversational turns. When creating a new `Message`, you specify the prior
    ///       conversational turns with the `messages` parameter, and the model then generates
    ///       the next `Message` in the conversation. Consecutive `user` or `assistant` turns
    ///       in your request will be combined into a single turn.
    ///
    ///       Each input message must be an object with a `role` and `content`. You can
    ///       specify a single `user`-role message, or you can include multiple `user` and
    ///       `assistant` messages.
    ///
    ///       If the final message uses the `assistant` role, the response content will
    ///       continue immediately from the content in that message. This can be used to
    ///       constrain part of the model's response. This is called prefill. On models that
    ///       don't support prefill, creating a message that ends with a partial `assistant`
    ///       response returns a 400 error. See
    ///       [Prefill not supported](https://platform.claude.com/docs/en/api/errors#prefill-not-supported).
    ///
    ///       Example with a single `user` message:
    ///
    ///       ```json
    ///       [{ "role": "user", "content": "Hello, Claude" }]
    ///       ```
    ///
    ///       Example with multiple conversational turns:
    ///
    ///       ```json
    ///       [
    ///         { "role": "user", "content": "Hello there." },
    ///         { "role": "assistant", "content": "Hi, I'm Claude. How can I help you?" },
    ///         { "role": "user", "content": "Can you explain LLMs in plain English?" }
    ///       ]
    ///       ```
    ///
    ///       Example with a partially-filled response from Claude, for models that support
    ///       prefill:
    ///
    ///       ```json
    ///       [
    ///         {
    ///           "role": "user",
    ///           "content": "What's the Greek name for Sun? (A) Sol (B) Helios (C) Sun"
    ///         },
    ///         { "role": "assistant", "content": "The best answer is (" }
    ///       ]
    ///       ```
    ///
    ///       Each input message `content` may be either a single `string` or an array of
    ///       content blocks, where each block has a specific `type`. Using a `string` for
    ///       `content` is shorthand for an array of one content block of type `"text"`. The
    ///       following input messages are equivalent:
    ///
    ///       ```json
    ///       { "role": "user", "content": "Hello, Claude" }
    ///       ```
    ///
    ///       ```json
    ///       { "role": "user", "content": [{ "type": "text", "text": "Hello, Claude" }] }
    ///       ```
    ///
    ///       See
    ///       [input examples](https://platform.claude.com/docs/en/build-with-claude/working-with-messages).
    ///
    ///       Note that if you want to include a
    ///       [system prompt](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices#give-claude-a-role),
    ///       you can use the top-level `system` parameter.
    ///
    ///       There is a limit of 100,000 messages in a single request.
    ///
    ///   model: The model that will complete your prompt.
    ///
    ///       See [models](https://docs.anthropic.com/en/docs/models-overview) for additional
    ///       details and options.
    ///
    ///   cache_control: Top-level cache control automatically applies a cache_control marker to the last
    ///       cacheable block in the request.
    ///
    ///   compaction: Compaction configuration.
    ///
    ///       When set on `POST /v1/messages`, the request is a compaction request: the
    ///       conversation in `messages` is summarized and the response holds only the
    ///       resulting `compaction` block (`stop_reason` `"compaction"`), which later
    ///       requests send first in `messages` in place of the messages it summarizes.
    ///       `POST /v1/messages/count_tokens` accepts this parameter and ignores it: the
    ///       count it returns is for the conversation in `messages` as sent. Cannot be
    ///       combined with `context_management`.
    ///
    ///   context_management: Context management configuration.
    ///
    ///       This allows you to control how Claude manages context across multiple requests,
    ///       such as whether to clear function results or not.
    ///
    ///   mcp_servers: MCP servers to be utilized in this request
    ///
    ///   output_config: Configuration options for the model's output, such as the output format.
    ///
    ///   speed: The inference speed mode for this request. `"fast"` enables high
    ///       output-tokens-per-second inference.
    ///
    ///       Some models require the `fast-mode-2026-02-01` beta header for any `speed`
    ///       value. See
    ///       [fast mode](https://platform.claude.com/docs/en/build-with-claude/fast-mode) for
    ///       which models.
    ///
    ///   system: System prompt.
    ///
    ///       A system prompt is a way of providing context and instructions to Claude, such
    ///       as specifying a particular goal or role. See our
    ///       [guide to system prompts](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices#give-claude-a-role).
    ///
    ///   thinking: Configuration for Claude's thinking.
    ///
    ///       With `{"type": "adaptive"}`, Claude decides when and how much to think. With
    ///       `{"type": "enabled"}` (manual extended thinking), you set a `budget_tokens` of
    ///       at least 1,024. Thinking tokens count toward your `max_tokens` limit.
    ///
    ///       Which `type` values are accepted, and what happens when you omit `thinking`,
    ///       depend on the model. See
    ///       [thinking](https://platform.claude.com/docs/en/build-with-claude/thinking#configuring-thinking)
    ///       for each model's behavior.
    ///
    ///   tool_choice: How the model should use the provided tools. The model can use a specific tool,
    ///       any available tool, decide by itself, or not use tools at all.
    ///
    ///   tools: Definitions of tools that the model may use.
    ///
    ///       If you include `tools` in your API request, the model may return `tool_use`
    ///       content blocks that represent the model's use of those tools. You can then run
    ///       those tools using the tool input generated by the model and then optionally
    ///       return results back to the model using `tool_result` content blocks.
    ///
    ///       There are two types of tools: **client tools** and **server tools**. The
    ///       behavior described below applies to client tools. For
    ///       [server tools](https://platform.claude.com/docs/en/agents-and-tools/tool-use/server-tools),
    ///       see their individual documentation as each has its own behavior (e.g., the
    ///       [web search tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-search-tool)).
    ///
    ///       Each tool definition includes:
    ///
    ///       - `name`: Name of the tool.
    ///       - `description`: Optional, but strongly-recommended description of the tool.
    ///       - `input_schema`: [JSON schema](https://json-schema.org/draft/2020-12) for the
    ///         tool `input` shape that the model will produce in `tool_use` output content
    ///         blocks.
    ///
    ///       For example, if you defined `tools` as:
    ///
    ///       ```json
    ///       [
    ///         {
    ///           "name": "get_stock_price",
    ///           "description": "Get the current stock price for a given ticker symbol.",
    ///           "input_schema": {
    ///             "type": "object",
    ///             "properties": {
    ///               "ticker": {
    ///                 "type": "string",
    ///                 "description": "The stock ticker symbol, e.g. AAPL for Apple Inc."
    ///               }
    ///             },
    ///             "required": ["ticker"]
    ///           }
    ///         }
    ///       ]
    ///       ```
    ///
    ///       And then asked the model "What's the S&P 500 at today?", the model might produce
    ///       `tool_use` content blocks in the response like this:
    ///
    ///       ```json
    ///       [
    ///         {
    ///           "type": "tool_use",
    ///           "id": "toolu_01D7FLrfh4GYq7yT1ULFeyMV",
    ///           "name": "get_stock_price",
    ///           "input": { "ticker": "^GSPC" }
    ///         }
    ///       ]
    ///       ```
    ///
    ///       You might then run your `get_stock_price` tool with `{"ticker": "^GSPC"}` as an
    ///       input, and return the following back to the model in a subsequent `user`
    ///       message:
    ///
    ///       ```json
    ///       [
    ///         {
    ///           "type": "tool_result",
    ///           "tool_use_id": "toolu_01D7FLrfh4GYq7yT1ULFeyMV",
    ///           "content": "259.75 USD"
    ///         }
    ///       ]
    ///       ```
    ///
    ///       Tools can be used for workflows that include running client-side tools and
    ///       functions, or more generally whenever you want the model to produce a particular
    ///       JSON structure of output.
    ///
    ///       See our
    ///       [guide](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview)
    ///       for more details.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   user_profile_id: The user profile ID to attribute this request to. Use when acting on behalf of a
    ///       party other than your organization.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func countTokens(messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil, compaction: BetaCompactionConfigParam?? = nil, contextManagement: BetaContextManagementConfigParam?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, outputConfig: BetaOutputConfigParam? = nil, speed: BetaMessageCountTokensParams.Speed?? = nil, system: BetaMessageCountTokensParams.System? = nil, thinking: BetaThinkingConfigParam? = nil, toolChoice: BetaToolChoiceParam? = nil, tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaMessageTokensCount {
        try await _countTokens(messages: messages, model: model, cacheControl: cacheControl, compaction: compaction, contextManagement: contextManagement, mcpServers: mcpServers, outputConfig: outputConfig, speed: speed, system: system, thinking: thinking, toolChoice: toolChoice, tools: tools, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _countTokens(messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil, compaction: BetaCompactionConfigParam?? = nil, contextManagement: BetaContextManagementConfigParam?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, outputConfig: BetaOutputConfigParam? = nil, speed: BetaMessageCountTokensParams.Speed?? = nil, system: BetaMessageCountTokensParams.System? = nil, thinking: BetaThinkingConfigParam? = nil, toolChoice: BetaToolChoiceParam? = nil, tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaMessageTokensCount> {
        var body = ParamsBuilder()
        try body.set("messages", messages)
        try body.set("model", model)
        try body.set("cache_control", cacheControl)
        try body.set("compaction", compaction)
        try body.set("context_management", contextManagement)
        try body.set("mcp_servers", mcpServers)
        try body.set("output_config", outputConfig)
        try body.set("speed", speed)
        try body.set("system", system)
        try body.set("thinking", thinking)
        try body.set("tool_choice", toolChoice)
        try body.set("tools", tools)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/messages/count_tokens", body: body, headers: mergeHeaderLayers(["anthropic-beta": "token-counting-2024-11-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["token-counting-2024-11-01"], separator: ",")), ("anthropic-user-profile-id", userProfileID), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.messages.count_tokens", spanRoute: "/v1/messages/count_tokens", spanBodyAttributes: messagesCountTokensRequestAttributes, qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaMessageTokensCount.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaMessagesResource

        public var batches: BetaMessagesBatchesResource.WithRawResponse { resource.batches.withRawResponse }

        public func create(maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil, compaction: BetaCompactionConfigParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil, contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil, fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil, inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, metadata: BetaMetadataParam? = nil, outputConfig: BetaOutputConfigParam? = nil, serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil, speed: BetaMessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil, thinking: BetaThinkingConfigParam? = nil, thread: BetaMessageThreadParam?? = nil, toolChoice: BetaToolChoiceParam? = nil, tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaMessage> {
            try await resource._create(maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, compaction: compaction, container: container, contextManagement: contextManagement, diagnostics: diagnostics, fallbackCreditToken: fallbackCreditToken, fallbacks: fallbacks, inferenceGeo: inferenceGeo, mcpServers: mcpServers, metadata: metadata, outputConfig: outputConfig, serviceTier: serviceTier, speed: speed, stopSequences: stopSequences, system: system, thinking: thinking, thread: thread, toolChoice: toolChoice, tools: tools, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

        public func createStreaming(maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil, compaction: BetaCompactionConfigParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil, contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil, fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil, inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, metadata: BetaMetadataParam? = nil, outputConfig: BetaOutputConfigParam? = nil, serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil, speed: BetaMessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil, thinking: BetaThinkingConfigParam? = nil, thread: BetaMessageThreadParam?? = nil, toolChoice: BetaToolChoiceParam? = nil, tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Stream<BetaRawMessageStreamEvent>> {
            try await resource._createStreaming(maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, compaction: compaction, container: container, contextManagement: contextManagement, diagnostics: diagnostics, fallbackCreditToken: fallbackCreditToken, fallbacks: fallbacks, inferenceGeo: inferenceGeo, mcpServers: mcpServers, metadata: metadata, outputConfig: outputConfig, serviceTier: serviceTier, speed: speed, stopSequences: stopSequences, system: system, thinking: thinking, thread: thread, toolChoice: toolChoice, tools: tools, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Count the number of tokens in a Message.
    ///
    /// The Token Count API can be used to count the number of tokens in a Message,
    /// including tools, images, and documents, without creating it.
    ///
    /// Learn more about token counting in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/token-counting)
    ///
    /// Args:
    ///   messages: Input messages.
    ///
    ///       Our models are trained to operate on alternating `user` and `assistant`
    ///       conversational turns. When creating a new `Message`, you specify the prior
    ///       conversational turns with the `messages` parameter, and the model then generates
    ///       the next `Message` in the conversation. Consecutive `user` or `assistant` turns
    ///       in your request will be combined into a single turn.
    ///
    ///       Each input message must be an object with a `role` and `content`. You can
    ///       specify a single `user`-role message, or you can include multiple `user` and
    ///       `assistant` messages.
    ///
    ///       If the final message uses the `assistant` role, the response content will
    ///       continue immediately from the content in that message. This can be used to
    ///       constrain part of the model's response. This is called prefill. On models that
    ///       don't support prefill, creating a message that ends with a partial `assistant`
    ///       response returns a 400 error. See
    ///       [Prefill not supported](https://platform.claude.com/docs/en/api/errors#prefill-not-supported).
    ///
    ///       Example with a single `user` message:
    ///
    ///       ```json
    ///       [{ "role": "user", "content": "Hello, Claude" }]
    ///       ```
    ///
    ///       Example with multiple conversational turns:
    ///
    ///       ```json
    ///       [
    ///         { "role": "user", "content": "Hello there." },
    ///         { "role": "assistant", "content": "Hi, I'm Claude. How can I help you?" },
    ///         { "role": "user", "content": "Can you explain LLMs in plain English?" }
    ///       ]
    ///       ```
    ///
    ///       Example with a partially-filled response from Claude, for models that support
    ///       prefill:
    ///
    ///       ```json
    ///       [
    ///         {
    ///           "role": "user",
    ///           "content": "What's the Greek name for Sun? (A) Sol (B) Helios (C) Sun"
    ///         },
    ///         { "role": "assistant", "content": "The best answer is (" }
    ///       ]
    ///       ```
    ///
    ///       Each input message `content` may be either a single `string` or an array of
    ///       content blocks, where each block has a specific `type`. Using a `string` for
    ///       `content` is shorthand for an array of one content block of type `"text"`. The
    ///       following input messages are equivalent:
    ///
    ///       ```json
    ///       { "role": "user", "content": "Hello, Claude" }
    ///       ```
    ///
    ///       ```json
    ///       { "role": "user", "content": [{ "type": "text", "text": "Hello, Claude" }] }
    ///       ```
    ///
    ///       See
    ///       [input examples](https://platform.claude.com/docs/en/build-with-claude/working-with-messages).
    ///
    ///       Note that if you want to include a
    ///       [system prompt](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices#give-claude-a-role),
    ///       you can use the top-level `system` parameter.
    ///
    ///       There is a limit of 100,000 messages in a single request.
    ///
    ///   model: The model that will complete your prompt.
    ///
    ///       See [models](https://docs.anthropic.com/en/docs/models-overview) for additional
    ///       details and options.
    ///
    ///   cache_control: Top-level cache control automatically applies a cache_control marker to the last
    ///       cacheable block in the request.
    ///
    ///   compaction: Compaction configuration.
    ///
    ///       When set on `POST /v1/messages`, the request is a compaction request: the
    ///       conversation in `messages` is summarized and the response holds only the
    ///       resulting `compaction` block (`stop_reason` `"compaction"`), which later
    ///       requests send first in `messages` in place of the messages it summarizes.
    ///       `POST /v1/messages/count_tokens` accepts this parameter and ignores it: the
    ///       count it returns is for the conversation in `messages` as sent. Cannot be
    ///       combined with `context_management`.
    ///
    ///   context_management: Context management configuration.
    ///
    ///       This allows you to control how Claude manages context across multiple requests,
    ///       such as whether to clear function results or not.
    ///
    ///   mcp_servers: MCP servers to be utilized in this request
    ///
    ///   output_config: Configuration options for the model's output, such as the output format.
    ///
    ///   speed: The inference speed mode for this request. `"fast"` enables high
    ///       output-tokens-per-second inference.
    ///
    ///       Some models require the `fast-mode-2026-02-01` beta header for any `speed`
    ///       value. See
    ///       [fast mode](https://platform.claude.com/docs/en/build-with-claude/fast-mode) for
    ///       which models.
    ///
    ///   system: System prompt.
    ///
    ///       A system prompt is a way of providing context and instructions to Claude, such
    ///       as specifying a particular goal or role. See our
    ///       [guide to system prompts](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices#give-claude-a-role).
    ///
    ///   thinking: Configuration for Claude's thinking.
    ///
    ///       With `{"type": "adaptive"}`, Claude decides when and how much to think. With
    ///       `{"type": "enabled"}` (manual extended thinking), you set a `budget_tokens` of
    ///       at least 1,024. Thinking tokens count toward your `max_tokens` limit.
    ///
    ///       Which `type` values are accepted, and what happens when you omit `thinking`,
    ///       depend on the model. See
    ///       [thinking](https://platform.claude.com/docs/en/build-with-claude/thinking#configuring-thinking)
    ///       for each model's behavior.
    ///
    ///   tool_choice: How the model should use the provided tools. The model can use a specific tool,
    ///       any available tool, decide by itself, or not use tools at all.
    ///
    ///   tools: Definitions of tools that the model may use.
    ///
    ///       If you include `tools` in your API request, the model may return `tool_use`
    ///       content blocks that represent the model's use of those tools. You can then run
    ///       those tools using the tool input generated by the model and then optionally
    ///       return results back to the model using `tool_result` content blocks.
    ///
    ///       There are two types of tools: **client tools** and **server tools**. The
    ///       behavior described below applies to client tools. For
    ///       [server tools](https://platform.claude.com/docs/en/agents-and-tools/tool-use/server-tools),
    ///       see their individual documentation as each has its own behavior (e.g., the
    ///       [web search tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-search-tool)).
    ///
    ///       Each tool definition includes:
    ///
    ///       - `name`: Name of the tool.
    ///       - `description`: Optional, but strongly-recommended description of the tool.
    ///       - `input_schema`: [JSON schema](https://json-schema.org/draft/2020-12) for the
    ///         tool `input` shape that the model will produce in `tool_use` output content
    ///         blocks.
    ///
    ///       For example, if you defined `tools` as:
    ///
    ///       ```json
    ///       [
    ///         {
    ///           "name": "get_stock_price",
    ///           "description": "Get the current stock price for a given ticker symbol.",
    ///           "input_schema": {
    ///             "type": "object",
    ///             "properties": {
    ///               "ticker": {
    ///                 "type": "string",
    ///                 "description": "The stock ticker symbol, e.g. AAPL for Apple Inc."
    ///               }
    ///             },
    ///             "required": ["ticker"]
    ///           }
    ///         }
    ///       ]
    ///       ```
    ///
    ///       And then asked the model "What's the S&P 500 at today?", the model might produce
    ///       `tool_use` content blocks in the response like this:
    ///
    ///       ```json
    ///       [
    ///         {
    ///           "type": "tool_use",
    ///           "id": "toolu_01D7FLrfh4GYq7yT1ULFeyMV",
    ///           "name": "get_stock_price",
    ///           "input": { "ticker": "^GSPC" }
    ///         }
    ///       ]
    ///       ```
    ///
    ///       You might then run your `get_stock_price` tool with `{"ticker": "^GSPC"}` as an
    ///       input, and return the following back to the model in a subsequent `user`
    ///       message:
    ///
    ///       ```json
    ///       [
    ///         {
    ///           "type": "tool_result",
    ///           "tool_use_id": "toolu_01D7FLrfh4GYq7yT1ULFeyMV",
    ///           "content": "259.75 USD"
    ///         }
    ///       ]
    ///       ```
    ///
    ///       Tools can be used for workflows that include running client-side tools and
    ///       functions, or more generally whenever you want the model to produce a particular
    ///       JSON structure of output.
    ///
    ///       See our
    ///       [guide](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview)
    ///       for more details.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   user_profile_id: The user profile ID to attribute this request to. Use when acting on behalf of a
    ///       party other than your organization.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func countTokens(messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil, compaction: BetaCompactionConfigParam?? = nil, contextManagement: BetaContextManagementConfigParam?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, outputConfig: BetaOutputConfigParam? = nil, speed: BetaMessageCountTokensParams.Speed?? = nil, system: BetaMessageCountTokensParams.System? = nil, thinking: BetaThinkingConfigParam? = nil, toolChoice: BetaToolChoiceParam? = nil, tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaMessageTokensCount> {
            try await resource._countTokens(messages: messages, model: model, cacheControl: cacheControl, compaction: compaction, contextManagement: contextManagement, mcpServers: mcpServers, outputConfig: outputConfig, speed: speed, system: system, thinking: thinking, toolChoice: toolChoice, tools: tools, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaMessagesResource

        public var batches: BetaMessagesBatchesResource.WithStreamingResponse { resource.batches.withStreamingResponse }

        public func create<R: Sendable>(maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil, compaction: BetaCompactionConfigParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil, contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil, fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil, inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, metadata: BetaMetadataParam? = nil, outputConfig: BetaOutputConfigParam? = nil, serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil, speed: BetaMessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil, thinking: BetaThinkingConfigParam? = nil, thread: BetaMessageThreadParam?? = nil, toolChoice: BetaToolChoiceParam? = nil, tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaMessage>) async throws -> R) async throws -> R {
            let response = try await resource._create(maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, compaction: compaction, container: container, contextManagement: contextManagement, diagnostics: diagnostics, fallbackCreditToken: fallbackCreditToken, fallbacks: fallbacks, inferenceGeo: inferenceGeo, mcpServers: mcpServers, metadata: metadata, outputConfig: outputConfig, serviceTier: serviceTier, speed: speed, stopSequences: stopSequences, system: system, thinking: thinking, thread: thread, toolChoice: toolChoice, tools: tools, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

        public func createStreaming<R: Sendable>(maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil, compaction: BetaCompactionConfigParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil, contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil, fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil, inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, metadata: BetaMetadataParam? = nil, outputConfig: BetaOutputConfigParam? = nil, serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil, speed: BetaMessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil, thinking: BetaThinkingConfigParam? = nil, thread: BetaMessageThreadParam?? = nil, toolChoice: BetaToolChoiceParam? = nil, tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Stream<BetaRawMessageStreamEvent>>) async throws -> R) async throws -> R {
            let response = try await resource._createStreaming(maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, compaction: compaction, container: container, contextManagement: contextManagement, diagnostics: diagnostics, fallbackCreditToken: fallbackCreditToken, fallbacks: fallbacks, inferenceGeo: inferenceGeo, mcpServers: mcpServers, metadata: metadata, outputConfig: outputConfig, serviceTier: serviceTier, speed: speed, stopSequences: stopSequences, system: system, thinking: thinking, thread: thread, toolChoice: toolChoice, tools: tools, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Count the number of tokens in a Message.
    ///
    /// The Token Count API can be used to count the number of tokens in a Message,
    /// including tools, images, and documents, without creating it.
    ///
    /// Learn more about token counting in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/token-counting)
    ///
    /// Args:
    ///   messages: Input messages.
    ///
    ///       Our models are trained to operate on alternating `user` and `assistant`
    ///       conversational turns. When creating a new `Message`, you specify the prior
    ///       conversational turns with the `messages` parameter, and the model then generates
    ///       the next `Message` in the conversation. Consecutive `user` or `assistant` turns
    ///       in your request will be combined into a single turn.
    ///
    ///       Each input message must be an object with a `role` and `content`. You can
    ///       specify a single `user`-role message, or you can include multiple `user` and
    ///       `assistant` messages.
    ///
    ///       If the final message uses the `assistant` role, the response content will
    ///       continue immediately from the content in that message. This can be used to
    ///       constrain part of the model's response. This is called prefill. On models that
    ///       don't support prefill, creating a message that ends with a partial `assistant`
    ///       response returns a 400 error. See
    ///       [Prefill not supported](https://platform.claude.com/docs/en/api/errors#prefill-not-supported).
    ///
    ///       Example with a single `user` message:
    ///
    ///       ```json
    ///       [{ "role": "user", "content": "Hello, Claude" }]
    ///       ```
    ///
    ///       Example with multiple conversational turns:
    ///
    ///       ```json
    ///       [
    ///         { "role": "user", "content": "Hello there." },
    ///         { "role": "assistant", "content": "Hi, I'm Claude. How can I help you?" },
    ///         { "role": "user", "content": "Can you explain LLMs in plain English?" }
    ///       ]
    ///       ```
    ///
    ///       Example with a partially-filled response from Claude, for models that support
    ///       prefill:
    ///
    ///       ```json
    ///       [
    ///         {
    ///           "role": "user",
    ///           "content": "What's the Greek name for Sun? (A) Sol (B) Helios (C) Sun"
    ///         },
    ///         { "role": "assistant", "content": "The best answer is (" }
    ///       ]
    ///       ```
    ///
    ///       Each input message `content` may be either a single `string` or an array of
    ///       content blocks, where each block has a specific `type`. Using a `string` for
    ///       `content` is shorthand for an array of one content block of type `"text"`. The
    ///       following input messages are equivalent:
    ///
    ///       ```json
    ///       { "role": "user", "content": "Hello, Claude" }
    ///       ```
    ///
    ///       ```json
    ///       { "role": "user", "content": [{ "type": "text", "text": "Hello, Claude" }] }
    ///       ```
    ///
    ///       See
    ///       [input examples](https://platform.claude.com/docs/en/build-with-claude/working-with-messages).
    ///
    ///       Note that if you want to include a
    ///       [system prompt](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices#give-claude-a-role),
    ///       you can use the top-level `system` parameter.
    ///
    ///       There is a limit of 100,000 messages in a single request.
    ///
    ///   model: The model that will complete your prompt.
    ///
    ///       See [models](https://docs.anthropic.com/en/docs/models-overview) for additional
    ///       details and options.
    ///
    ///   cache_control: Top-level cache control automatically applies a cache_control marker to the last
    ///       cacheable block in the request.
    ///
    ///   compaction: Compaction configuration.
    ///
    ///       When set on `POST /v1/messages`, the request is a compaction request: the
    ///       conversation in `messages` is summarized and the response holds only the
    ///       resulting `compaction` block (`stop_reason` `"compaction"`), which later
    ///       requests send first in `messages` in place of the messages it summarizes.
    ///       `POST /v1/messages/count_tokens` accepts this parameter and ignores it: the
    ///       count it returns is for the conversation in `messages` as sent. Cannot be
    ///       combined with `context_management`.
    ///
    ///   context_management: Context management configuration.
    ///
    ///       This allows you to control how Claude manages context across multiple requests,
    ///       such as whether to clear function results or not.
    ///
    ///   mcp_servers: MCP servers to be utilized in this request
    ///
    ///   output_config: Configuration options for the model's output, such as the output format.
    ///
    ///   speed: The inference speed mode for this request. `"fast"` enables high
    ///       output-tokens-per-second inference.
    ///
    ///       Some models require the `fast-mode-2026-02-01` beta header for any `speed`
    ///       value. See
    ///       [fast mode](https://platform.claude.com/docs/en/build-with-claude/fast-mode) for
    ///       which models.
    ///
    ///   system: System prompt.
    ///
    ///       A system prompt is a way of providing context and instructions to Claude, such
    ///       as specifying a particular goal or role. See our
    ///       [guide to system prompts](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices#give-claude-a-role).
    ///
    ///   thinking: Configuration for Claude's thinking.
    ///
    ///       With `{"type": "adaptive"}`, Claude decides when and how much to think. With
    ///       `{"type": "enabled"}` (manual extended thinking), you set a `budget_tokens` of
    ///       at least 1,024. Thinking tokens count toward your `max_tokens` limit.
    ///
    ///       Which `type` values are accepted, and what happens when you omit `thinking`,
    ///       depend on the model. See
    ///       [thinking](https://platform.claude.com/docs/en/build-with-claude/thinking#configuring-thinking)
    ///       for each model's behavior.
    ///
    ///   tool_choice: How the model should use the provided tools. The model can use a specific tool,
    ///       any available tool, decide by itself, or not use tools at all.
    ///
    ///   tools: Definitions of tools that the model may use.
    ///
    ///       If you include `tools` in your API request, the model may return `tool_use`
    ///       content blocks that represent the model's use of those tools. You can then run
    ///       those tools using the tool input generated by the model and then optionally
    ///       return results back to the model using `tool_result` content blocks.
    ///
    ///       There are two types of tools: **client tools** and **server tools**. The
    ///       behavior described below applies to client tools. For
    ///       [server tools](https://platform.claude.com/docs/en/agents-and-tools/tool-use/server-tools),
    ///       see their individual documentation as each has its own behavior (e.g., the
    ///       [web search tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-search-tool)).
    ///
    ///       Each tool definition includes:
    ///
    ///       - `name`: Name of the tool.
    ///       - `description`: Optional, but strongly-recommended description of the tool.
    ///       - `input_schema`: [JSON schema](https://json-schema.org/draft/2020-12) for the
    ///         tool `input` shape that the model will produce in `tool_use` output content
    ///         blocks.
    ///
    ///       For example, if you defined `tools` as:
    ///
    ///       ```json
    ///       [
    ///         {
    ///           "name": "get_stock_price",
    ///           "description": "Get the current stock price for a given ticker symbol.",
    ///           "input_schema": {
    ///             "type": "object",
    ///             "properties": {
    ///               "ticker": {
    ///                 "type": "string",
    ///                 "description": "The stock ticker symbol, e.g. AAPL for Apple Inc."
    ///               }
    ///             },
    ///             "required": ["ticker"]
    ///           }
    ///         }
    ///       ]
    ///       ```
    ///
    ///       And then asked the model "What's the S&P 500 at today?", the model might produce
    ///       `tool_use` content blocks in the response like this:
    ///
    ///       ```json
    ///       [
    ///         {
    ///           "type": "tool_use",
    ///           "id": "toolu_01D7FLrfh4GYq7yT1ULFeyMV",
    ///           "name": "get_stock_price",
    ///           "input": { "ticker": "^GSPC" }
    ///         }
    ///       ]
    ///       ```
    ///
    ///       You might then run your `get_stock_price` tool with `{"ticker": "^GSPC"}` as an
    ///       input, and return the following back to the model in a subsequent `user`
    ///       message:
    ///
    ///       ```json
    ///       [
    ///         {
    ///           "type": "tool_result",
    ///           "tool_use_id": "toolu_01D7FLrfh4GYq7yT1ULFeyMV",
    ///           "content": "259.75 USD"
    ///         }
    ///       ]
    ///       ```
    ///
    ///       Tools can be used for workflows that include running client-side tools and
    ///       functions, or more generally whenever you want the model to produce a particular
    ///       JSON structure of output.
    ///
    ///       See our
    ///       [guide](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview)
    ///       for more details.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   user_profile_id: The user profile ID to attribute this request to. Use when acting on behalf of a
    ///       party other than your organization.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func countTokens<R: Sendable>(messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil, compaction: BetaCompactionConfigParam?? = nil, contextManagement: BetaContextManagementConfigParam?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, outputConfig: BetaOutputConfigParam? = nil, speed: BetaMessageCountTokensParams.Speed?? = nil, system: BetaMessageCountTokensParams.System? = nil, thinking: BetaThinkingConfigParam? = nil, toolChoice: BetaToolChoiceParam? = nil, tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaMessageTokensCount>) async throws -> R) async throws -> R {
            let response = try await resource._countTokens(messages: messages, model: model, cacheControl: cacheControl, compaction: compaction, contextManagement: contextManagement, mcpServers: mcpServers, outputConfig: outputConfig, speed: speed, system: system, thinking: thinking, toolChoice: toolChoice, tools: tools, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }

    public indirect enum CreateStream: Codable, Hashable, Sendable {
        case false_(Bool)
        case true_(Bool)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            if let v = try? Bool(from: decoder) { self = .false_(v); return }
            if let v = try? Bool(from: decoder) { self = .true_(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .false_(let v): try v.encode(to: encoder)
            case .true_(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
