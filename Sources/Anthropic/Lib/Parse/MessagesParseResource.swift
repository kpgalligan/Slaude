import Foundation

// Hand port of `messages.parse(...)`, `beta.messages.parse(...)` and the typed `output_format=`
// argument of `messages.count_tokens(...)`.

extension MessagesResource {
    /// Creates a Message and parses its text blocks into `outputFormat`, whose JSON schema is sent
    /// as `output_config.format`.
    public func parse<Output: StructuredOutput>(
        maxTokens: Int, messages: [MessageParam], model: ModelParam, diagnostics: DiagnosticsParam?? = nil, metadata: MetadataParam? = nil,
        outputConfig: OutputConfigParam? = nil, outputFormat: Output.Type, serviceTier: MessageCreateParamsBase.ServiceTier? = nil,
        speed: MessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: MessageCreateParamsBase.System? = nil,
        thinking: ThinkingConfigParam? = nil, toolChoice: ToolChoiceParam? = nil, tools: [ToolUnionParam]? = nil, extraHeaders: Headers? = nil,
        extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil
    ) async throws -> ParsedMessage<Output> {
        try await _parse(maxTokens: maxTokens, messages: messages, model: model, diagnostics: diagnostics, metadata: metadata,
                         outputConfig: mergeOutputConfig(outputConfig, format: try jsonOutputFormat(Output.self)),
                         parser: structuredOutputParser(Output.self), serviceTier: serviceTier, speed: speed, stopSequences: stopSequences,
                         system: system, thinking: thinking, toolChoice: toolChoice, tools: tools, extraHeaders: extraHeaders,
                         extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    /// Creates a Message without an output format, returned as a `ParsedMessage<Never>`.
    public func parse(
        maxTokens: Int, messages: [MessageParam], model: ModelParam, diagnostics: DiagnosticsParam?? = nil, metadata: MetadataParam? = nil,
        outputConfig: OutputConfigParam? = nil, serviceTier: MessageCreateParamsBase.ServiceTier? = nil,
        speed: MessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: MessageCreateParamsBase.System? = nil,
        thinking: ThinkingConfigParam? = nil, toolChoice: ToolChoiceParam? = nil, tools: [ToolUnionParam]? = nil, extraHeaders: Headers? = nil,
        extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil
    ) async throws -> ParsedMessage<Never> {
        try await _parse(maxTokens: maxTokens, messages: messages, model: model, diagnostics: diagnostics, metadata: metadata,
                         outputConfig: outputConfig, parser: nil as OutputParser<Never>?, serviceTier: serviceTier, speed: speed,
                         stopSequences: stopSequences, system: system, thinking: thinking, toolChoice: toolChoice, tools: tools,
                         extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _parse<Output: Sendable>(
        maxTokens: Int, messages: [MessageParam], model: ModelParam, diagnostics: DiagnosticsParam??, metadata: MetadataParam?,
        outputConfig: OutputConfigParam?, parser: OutputParser<Output>?, serviceTier: MessageCreateParamsBase.ServiceTier?,
        speed: MessageCreateParamsBase.Speed??, stopSequences: [String]?, system: MessageCreateParamsBase.System?, thinking: ThinkingConfigParam?,
        toolChoice: ToolChoiceParam?, tools: [ToolUnionParam]?, extraHeaders: Headers?, extraQuery: Query?, extraBody: Body?, timeout: Timeout?,
        _mode: ResponseMode
    ) async throws -> APIResponse<ParsedMessage<Output>> {
        let raw = try await _create(
            maxTokens: maxTokens, messages: messages, model: model, diagnostics: diagnostics, metadata: metadata, outputConfig: outputConfig,
            serviceTier: serviceTier, speed: speed, stopSequences: stopSequences, system: system, thinking: thinking, toolChoice: toolChoice,
            tools: tools, extraHeaders: mergeHeaders([stainlessHelperHeader: "messages.parse"], extraHeaders), extraQuery: extraQuery,
            extraBody: extraBody, timeout: timeout, _mode: _mode)
        return APIResponse(http: raw.http, options: raw.options, retriesTaken: raw.retriesTaken, client: raw.client) { resp in
            try parseResponse(try await resp.client.decodeBody(Message.self, from: resp.http), parser: parser)
        }
    }

    /// `countTokens` with a typed output format: `outputFormat`'s JSON schema is counted as
    /// `output_config.format`.
    public func countTokens<Output: StructuredOutput>(
        messages: [MessageParam], model: ModelParam, cacheControl: CacheControlEphemeralParam?? = nil, outputConfig: OutputConfigParam? = nil,
        outputFormat: Output.Type, speed: MessageCountTokensParams.Speed?? = nil, system: MessageCountTokensParams.System? = nil,
        thinking: ThinkingConfigParam? = nil, toolChoice: ToolChoiceParam? = nil, tools: [MessageCountTokensToolParam]? = nil,
        userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil,
        timeout: Timeout? = nil
    ) async throws -> MessageTokensCount {
        try await countTokens(messages: messages, model: model, cacheControl: cacheControl,
                              outputConfig: mergeOutputConfig(outputConfig, format: try jsonOutputFormat(Output.self)), speed: speed,
                              system: system, thinking: thinking, toolChoice: toolChoice, tools: tools, userProfileID: userProfileID,
                              workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout)
    }
}

extension MessagesResource.WithRawResponse {
    public func parse<Output: StructuredOutput>(
        maxTokens: Int, messages: [MessageParam], model: ModelParam, diagnostics: DiagnosticsParam?? = nil, metadata: MetadataParam? = nil,
        outputConfig: OutputConfigParam? = nil, outputFormat: Output.Type, serviceTier: MessageCreateParamsBase.ServiceTier? = nil,
        speed: MessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: MessageCreateParamsBase.System? = nil,
        thinking: ThinkingConfigParam? = nil, toolChoice: ToolChoiceParam? = nil, tools: [ToolUnionParam]? = nil, extraHeaders: Headers? = nil,
        extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil
    ) async throws -> APIResponse<ParsedMessage<Output>> {
        try await resource._parse(maxTokens: maxTokens, messages: messages, model: model, diagnostics: diagnostics, metadata: metadata,
                                  outputConfig: mergeOutputConfig(outputConfig, format: try jsonOutputFormat(Output.self)),
                                  parser: structuredOutputParser(Output.self), serviceTier: serviceTier, speed: speed,
                                  stopSequences: stopSequences, system: system, thinking: thinking, toolChoice: toolChoice, tools: tools,
                                  extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
    }
}

extension BetaMessagesResource {
    /// Creates a beta Message and parses its text blocks into `outputFormat`, whose JSON schema is
    /// sent as `output_config.format`.
    public func parse<Output: StructuredOutput>(
        maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil,
        compaction: BetaCompactionConfigParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil,
        contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil,
        fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil,
        inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, metadata: BetaMetadataParam? = nil,
        outputConfig: BetaOutputConfigParam? = nil, outputFormat: Output.Type, serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil,
        speed: BetaMessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil,
        thinking: BetaThinkingConfigParam? = nil, thread: BetaMessageThreadParam?? = nil, toolChoice: BetaToolChoiceParam? = nil,
        tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil,
        extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil
    ) async throws -> ParsedBetaMessage<Output> {
        try validateOutputConfigConflict(outputConfig, hasOutputFormat: true)
        return try await _parse(maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, compaction: compaction,
                                container: container, contextManagement: contextManagement, diagnostics: diagnostics,
                                fallbackCreditToken: fallbackCreditToken, fallbacks: fallbacks, inferenceGeo: inferenceGeo, mcpServers: mcpServers,
                                metadata: metadata, outputConfig: mergeBetaOutputConfig(outputConfig, format: try jsonOutputFormat(Output.self)),
                                parser: structuredOutputParser(Output.self), serviceTier: serviceTier, speed: speed, stopSequences: stopSequences,
                                system: system, thinking: thinking, thread: thread, toolChoice: toolChoice, tools: tools, betas: betas,
                                userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery,
                                extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    /// Creates a beta Message without an output format, returned as a `ParsedBetaMessage<Never>`.
    public func parse(
        maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil,
        compaction: BetaCompactionConfigParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil,
        contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil,
        fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil,
        inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, metadata: BetaMetadataParam? = nil,
        outputConfig: BetaOutputConfigParam? = nil, serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil,
        speed: BetaMessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil,
        thinking: BetaThinkingConfigParam? = nil, thread: BetaMessageThreadParam?? = nil, toolChoice: BetaToolChoiceParam? = nil,
        tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil,
        extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil
    ) async throws -> ParsedBetaMessage<Never> {
        try await _parse(maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, compaction: compaction,
                         container: container, contextManagement: contextManagement, diagnostics: diagnostics,
                         fallbackCreditToken: fallbackCreditToken, fallbacks: fallbacks, inferenceGeo: inferenceGeo, mcpServers: mcpServers,
                         metadata: metadata, outputConfig: outputConfig, parser: nil as OutputParser<Never>?, serviceTier: serviceTier,
                         speed: speed, stopSequences: stopSequences, system: system, thinking: thinking, thread: thread, toolChoice: toolChoice,
                         tools: tools, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders,
                         extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _parse<Output: Sendable>(
        maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam??,
        compaction: BetaCompactionConfigParam??, container: BetaMessageCreateParamsBase.Container??,
        contextManagement: BetaContextManagementConfigParam??, diagnostics: BetaDiagnosticsParam??,
        fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken??, fallbacks: BetaFallbacksParam??, inferenceGeo: String??,
        mcpServers: [BetaRequestMCPServerURLDefinitionParam]?, metadata: BetaMetadataParam?, outputConfig: BetaOutputConfigParam?,
        parser: OutputParser<Output>?, serviceTier: BetaMessageCreateParamsBase.ServiceTier?, speed: BetaMessageCreateParamsBase.Speed??,
        stopSequences: [String]?, system: BetaMessageCreateParamsBase.System?, thinking: BetaThinkingConfigParam?,
        thread: BetaMessageThreadParam??, toolChoice: BetaToolChoiceParam?, tools: [BetaToolUnionParam]?, betas: [AnthropicBetaParam]?,
        userProfileID: String?, workspaceID: String?, extraHeaders: Headers?, extraQuery: Query?, extraBody: Body?, timeout: Timeout?,
        _mode: ResponseMode
    ) async throws -> APIResponse<ParsedBetaMessage<Output>> {
        let raw = try await _create(
            maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, compaction: compaction, container: container,
            contextManagement: contextManagement, diagnostics: diagnostics, fallbackCreditToken: fallbackCreditToken, fallbacks: fallbacks,
            inferenceGeo: inferenceGeo, mcpServers: mcpServers, metadata: metadata, outputConfig: outputConfig, serviceTier: serviceTier,
            speed: speed, stopSequences: stopSequences, system: system, thinking: thinking, thread: thread, toolChoice: toolChoice, tools: tools,
            betas: betas, userProfileID: userProfileID, workspaceID: workspaceID,
            extraHeaders: mergeHeaders([stainlessHelperHeader: "beta.messages.parse"], extraHeaders), extraQuery: extraQuery,
            extraBody: extraBody, timeout: timeout, _mode: _mode)
        return APIResponse(http: raw.http, options: raw.options, retriesTaken: raw.retriesTaken, client: raw.client) { resp in
            try parseBetaResponse(try await resp.client.decodeBody(BetaMessage.self, from: resp.http), parser: parser)
        }
    }
}

extension BetaMessagesResource.WithRawResponse {
    public func parse<Output: StructuredOutput>(
        maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil,
        compaction: BetaCompactionConfigParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil,
        contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil,
        fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil,
        inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, metadata: BetaMetadataParam? = nil,
        outputConfig: BetaOutputConfigParam? = nil, outputFormat: Output.Type, serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil,
        speed: BetaMessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil,
        thinking: BetaThinkingConfigParam? = nil, thread: BetaMessageThreadParam?? = nil, toolChoice: BetaToolChoiceParam? = nil,
        tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil,
        extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil
    ) async throws -> APIResponse<ParsedBetaMessage<Output>> {
        try validateOutputConfigConflict(outputConfig, hasOutputFormat: true)
        return try await resource._parse(
            maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, compaction: compaction, container: container,
            contextManagement: contextManagement, diagnostics: diagnostics, fallbackCreditToken: fallbackCreditToken, fallbacks: fallbacks,
            inferenceGeo: inferenceGeo, mcpServers: mcpServers, metadata: metadata,
            outputConfig: mergeBetaOutputConfig(outputConfig, format: try jsonOutputFormat(Output.self)), parser: structuredOutputParser(Output.self),
            serviceTier: serviceTier, speed: speed, stopSequences: stopSequences, system: system, thinking: thinking, thread: thread,
            toolChoice: toolChoice, tools: tools, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID,
            extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
    }
}
