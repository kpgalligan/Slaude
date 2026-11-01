import Foundation

// Hand port of `messages.stream(...)` and `beta.messages.stream(...)` (the transpiler cannot
// generate them: they return a stream manager rather than an API response).

let stainlessHelperHeader = "x-stainless-helper"
let stainlessHelperMethodHeader = "x-stainless-helper-method"
let stainlessStreamHelperHeader = "x-stainless-stream-helper"

extension MessagesResource {
    /// Creates a Message stream that accumulates the events into the final message.
    ///
    /// Takes the same arguments as `create`; see `MessageStream`.
    public func stream(maxTokens: Int, messages: [MessageParam], model: ModelParam, cacheControl: CacheControlEphemeralParam?? = nil,
                       container: MessageCreateParamsContainerParam?? = nil, diagnostics: DiagnosticsParam?? = nil, inferenceGeo: String?? = nil,
                       metadata: MetadataParam? = nil, outputConfig: OutputConfigParam? = nil, serviceTier: MessageCreateParamsBase.ServiceTier? = nil,
                       speed: MessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: MessageCreateParamsBase.System? = nil,
                       thinking: ThinkingConfigParam? = nil, toolChoice: ToolChoiceParam? = nil, tools: [ToolUnionParam]? = nil,
                       userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil,
                       extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> MessageStream<Never>
    {
        try await _stream(maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, container: container,
                          diagnostics: diagnostics, inferenceGeo: inferenceGeo, metadata: metadata, outputConfig: outputConfig, format: nil,
                          parser: nil as OutputParser<Never>?, serviceTier: serviceTier, speed: speed, stopSequences: stopSequences,
                          system: system, thinking: thinking, toolChoice: toolChoice, tools: tools, userProfileID: userProfileID,
                          workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout)
    }

    /// Creates a Message stream whose text blocks are parsed into `outputFormat` as they complete.
    ///
    /// The type's JSON schema is sent as `output_config.format`.
    public func stream<Output: StructuredOutput>(
        maxTokens: Int, messages: [MessageParam], model: ModelParam, cacheControl: CacheControlEphemeralParam?? = nil,
        container: MessageCreateParamsContainerParam?? = nil, diagnostics: DiagnosticsParam?? = nil, inferenceGeo: String?? = nil,
        metadata: MetadataParam? = nil, outputConfig: OutputConfigParam? = nil, outputFormat: Output.Type,
        serviceTier: MessageCreateParamsBase.ServiceTier? = nil, speed: MessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil,
        system: MessageCreateParamsBase.System? = nil, thinking: ThinkingConfigParam? = nil, toolChoice: ToolChoiceParam? = nil,
        tools: [ToolUnionParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil,
        extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil
    ) async throws -> MessageStream<Output> {
        try await _stream(maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, container: container,
                          diagnostics: diagnostics, inferenceGeo: inferenceGeo, metadata: metadata, outputConfig: outputConfig,
                          format: try jsonOutputFormat(Output.self), parser: structuredOutputParser(Output.self), serviceTier: serviceTier,
                          speed: speed, stopSequences: stopSequences, system: system, thinking: thinking, toolChoice: toolChoice, tools: tools,
                          userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery,
                          extraBody: extraBody, timeout: timeout)
    }

    func _stream<Output: Sendable>(
        maxTokens: Int, messages: [MessageParam], model: ModelParam, cacheControl: CacheControlEphemeralParam??,
        container: MessageCreateParamsContainerParam??, diagnostics: DiagnosticsParam??, inferenceGeo: String??, metadata: MetadataParam?,
        outputConfig: OutputConfigParam?, format: [String: JSONValue]?, parser: OutputParser<Output>?,
        serviceTier: MessageCreateParamsBase.ServiceTier?, speed: MessageCreateParamsBase.Speed??, stopSequences: [String]?,
        system: MessageCreateParamsBase.System?, thinking: ThinkingConfigParam?, toolChoice: ToolChoiceParam?, tools: [ToolUnionParam]?,
        userProfileID: String?, workspaceID: String?, extraHeaders: Headers?, extraQuery: Query?, extraBody: Body?, timeout: Timeout?
    ) async throws -> MessageStream<Output> {
        var outputConfig = outputConfig
        if let format {
            var merged = outputConfig ?? OutputConfigParam()
            merged.format = .some(JSONOutputFormatParam(schema: format, type: "json_schema"))
            outputConfig = merged
        }
        let headers = mergeHeaders([stainlessHelperMethodHeader: "stream", stainlessStreamHelperHeader: "messages"], extraHeaders)
        let raw = try await _createStreaming(
            maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, container: container,
            diagnostics: diagnostics, inferenceGeo: inferenceGeo, metadata: metadata, outputConfig: outputConfig, serviceTier: serviceTier,
            speed: speed, stopSequences: stopSequences, system: system, thinking: thinking, toolChoice: toolChoice, tools: tools,
            userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: headers, extraQuery: extraQuery, extraBody: extraBody,
            timeout: timeout, _mode: .parsed
        ).parse()
        return MessageStream(rawStream: raw, parser: parser)
    }
}

extension BetaMessagesResource {
    /// Creates a beta Message stream that accumulates the events into the final message.
    ///
    /// Takes the same arguments as `create`; see `BetaMessageStream`.
    public func stream(maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam?? = nil,
                       compaction: BetaCompactionConfigParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil,
                       contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil,
                       fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil,
                       inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil, metadata: BetaMetadataParam? = nil,
                       outputConfig: BetaOutputConfigParam? = nil, serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil,
                       speed: BetaMessageCreateParamsBase.Speed?? = nil, stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil,
                       thinking: BetaThinkingConfigParam? = nil, thread: BetaMessageThreadParam?? = nil, toolChoice: BetaToolChoiceParam? = nil,
                       tools: [BetaToolUnionParam]? = nil, betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil,
                       extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil,
                       timeout: Timeout? = nil) async throws -> BetaMessageStream<Never>
    {
        try await _stream(maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, compaction: compaction,
                          container: container, contextManagement: contextManagement, diagnostics: diagnostics,
                          fallbackCreditToken: fallbackCreditToken, fallbacks: fallbacks, inferenceGeo: inferenceGeo, mcpServers: mcpServers,
                          metadata: metadata, outputConfig: outputConfig, format: nil, parser: nil as OutputParser<Never>?, serviceTier: serviceTier,
                          speed: speed, stopSequences: stopSequences, system: system, thinking: thinking, thread: thread, toolChoice: toolChoice,
                          tools: tools, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders,
                          extraQuery: extraQuery, extraBody: extraBody, timeout: timeout)
    }

    /// Creates a beta Message stream whose text blocks are parsed into `outputFormat` as they complete.
    public func stream<Output: StructuredOutput>(
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
    ) async throws -> BetaMessageStream<Output> {
        try validateOutputConfigConflict(outputConfig, hasOutputFormat: true)
        return try await _stream(maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, compaction: compaction,
                                 container: container, contextManagement: contextManagement, diagnostics: diagnostics,
                                 fallbackCreditToken: fallbackCreditToken, fallbacks: fallbacks, inferenceGeo: inferenceGeo, mcpServers: mcpServers,
                                 metadata: metadata, outputConfig: outputConfig, format: try jsonOutputFormat(Output.self),
                                 parser: structuredOutputParser(Output.self), serviceTier: serviceTier, speed: speed, stopSequences: stopSequences,
                                 system: system, thinking: thinking, thread: thread, toolChoice: toolChoice, tools: tools, betas: betas,
                                 userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery,
                                 extraBody: extraBody, timeout: timeout)
    }

    func _stream<Output: Sendable>(
        maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam??,
        compaction: BetaCompactionConfigParam??, container: BetaMessageCreateParamsBase.Container??,
        contextManagement: BetaContextManagementConfigParam??, diagnostics: BetaDiagnosticsParam??,
        fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken??, fallbacks: BetaFallbacksParam??, inferenceGeo: String??,
        mcpServers: [BetaRequestMCPServerURLDefinitionParam]?, metadata: BetaMetadataParam?, outputConfig: BetaOutputConfigParam?,
        format: [String: JSONValue]?, parser: OutputParser<Output>?, serviceTier: BetaMessageCreateParamsBase.ServiceTier?,
        speed: BetaMessageCreateParamsBase.Speed??, stopSequences: [String]?, system: BetaMessageCreateParamsBase.System?,
        thinking: BetaThinkingConfigParam?, thread: BetaMessageThreadParam??, toolChoice: BetaToolChoiceParam?, tools: [BetaToolUnionParam]?,
        betas: [AnthropicBetaParam]?, userProfileID: String?, workspaceID: String?, extraHeaders: Headers?, extraQuery: Query?,
        extraBody: Body?, timeout: Timeout?
    ) async throws -> BetaMessageStream<Output> {
        let headers = mergeHeaders([stainlessHelperMethodHeader: "stream", stainlessStreamHelperHeader: "beta.messages"], extraHeaders)
        let raw = try await _createStreaming(
            maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, compaction: compaction, container: container,
            contextManagement: contextManagement, diagnostics: diagnostics, fallbackCreditToken: fallbackCreditToken, fallbacks: fallbacks,
            inferenceGeo: inferenceGeo, mcpServers: mcpServers, metadata: metadata,
            outputConfig: mergeBetaOutputConfig(outputConfig, format: format), serviceTier: serviceTier, speed: speed,
            stopSequences: stopSequences, system: system, thinking: thinking, thread: thread, toolChoice: toolChoice, tools: tools,
            betas: betas, userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: headers, extraQuery: extraQuery,
            extraBody: extraBody, timeout: timeout, _mode: .parsed
        ).parse()
        return BetaMessageStream(rawStream: raw, parser: parser)
    }
}

/// `output_config` with `format` as its `format`, when given (`lib/_parse/_transform.merge_output_config`).
func mergeBetaOutputConfig(_ outputConfig: BetaOutputConfigParam?, format: [String: JSONValue]?) -> BetaOutputConfigParam? {
    guard let format else { return outputConfig }
    var merged = outputConfig ?? BetaOutputConfigParam()
    merged.format = .some(BetaJSONOutputFormatParam(schema: format, type: "json_schema"))
    return merged
}

func mergeOutputConfig(_ outputConfig: OutputConfigParam?, format: [String: JSONValue]?) -> OutputConfigParam? {
    guard let format else { return outputConfig }
    var merged = outputConfig ?? OutputConfigParam()
    merged.format = .some(JSONOutputFormatParam(schema: format, type: "json_schema"))
    return merged
}
