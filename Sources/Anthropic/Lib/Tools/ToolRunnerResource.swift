// `client.beta.messages.tool_runner(...)` (the hand-written method on `resources/beta/messages/messages.py`).

import Foundation

extension BetaMessageThread {
    /// Run the tool loop over this thread, yielding the stream of each reply (`thread.tool_runner(stream=True)`).
    /// Replies are parsed into the thread's output format, if it has one.
    ///
    /// - Parameter runToolsEagerly: Run each tool as soon as its call is complete, before the reply finishes. See
    ///   `client.beta.messages.streamingToolRunner(...)`.
    public func streamingToolRunner(maxIterations: Int? = nil, runToolsEagerly: Bool = false, extraHeaders: Headers? = nil,
                                    extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) throws
        -> BetaStreamingToolRunner<Output>
    {
        try BetaStreamingToolRunner<Output>(
            thread: inner,
            options: ToolRunnerRequestOptions(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout),
            maxIterations: maxIterations, runToolsEagerly: runToolsEagerly, parser: parser)
    }
}

extension BetaMessagesResource {
    /// Run the tools the model calls until it stops asking for them, yielding each assistant message.
    ///
    /// The loop runs over a message thread by default, so each turn sends only new messages. Pass `thread: false`
    /// to send the full history every turn.
    ///
    /// - Parameters:
    ///   - tools: Function tools (`BetaFunctionTool`), builtin tools, toolsets and raw tool definitions.
    ///   - maxIterations: How many replies the loop asks for at most. There is no limit by default.
    ///   - thread: `false` sends the full history with every request instead of continuing a message thread.
    public func toolRunner(
        maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, tools: [any BetaToolLike], maxIterations: Int? = nil,
        cacheControl: BetaCacheControlEphemeralParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil,
        contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil,
        fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil,
        inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil,
        metadata: BetaMetadataParam? = nil, outputConfig: BetaOutputConfigParam? = nil,
        serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil, speed: BetaMessageCreateParamsBase.Speed?? = nil,
        stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil, thinking: BetaThinkingConfigParam? = nil,
        thread: Bool? = nil, toolChoice: BetaToolChoiceParam? = nil, betas: [AnthropicBetaParam]? = nil,
        userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil,
        extraBody: Body? = nil, timeout: Timeout? = nil
    ) throws -> BetaToolRunner {
        let messageThread = try toolRunnerThread(
            maxTokens: maxTokens, messages: messages, model: model, tools: tools, cacheControl: cacheControl, container: container,
            contextManagement: contextManagement, diagnostics: diagnostics, fallbackCreditToken: fallbackCreditToken,
            fallbacks: fallbacks, inferenceGeo: inferenceGeo, mcpServers: mcpServers, metadata: metadata,
            outputConfig: outputConfig, outputFormat: nil, serviceTier: serviceTier, speed: speed, stopSequences: stopSequences,
            system: system, thinking: thinking, thread: thread, toolChoice: toolChoice, betas: betas, userProfileID: userProfileID,
            workspaceID: workspaceID)

        return try BetaToolRunner(thread: messageThread, options: ToolRunnerRequestOptions(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout), maxIterations: maxIterations)
    }

    /// `toolRunner(...)` with an output format: each reply's text is parsed into `outputFormat`
    /// (`tool_runner(output_format=...)`).
    public func toolRunner<Output: StructuredOutput>(
        maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, tools: [any BetaToolLike], maxIterations: Int? = nil,
        cacheControl: BetaCacheControlEphemeralParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil,
        contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil,
        fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil,
        inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil,
        metadata: BetaMetadataParam? = nil, outputConfig: BetaOutputConfigParam? = nil, outputFormat: Output.Type,
        serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil, speed: BetaMessageCreateParamsBase.Speed?? = nil,
        stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil, thinking: BetaThinkingConfigParam? = nil,
        thread: Bool? = nil, toolChoice: BetaToolChoiceParam? = nil, betas: [AnthropicBetaParam]? = nil,
        userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil,
        extraBody: Body? = nil, timeout: Timeout? = nil
    ) throws -> BetaParsedToolRunner<Output> {
        let messageThread = try toolRunnerThread(
            maxTokens: maxTokens, messages: messages, model: model, tools: tools, cacheControl: cacheControl, container: container,
            contextManagement: contextManagement, diagnostics: diagnostics, fallbackCreditToken: fallbackCreditToken,
            fallbacks: fallbacks, inferenceGeo: inferenceGeo, mcpServers: mcpServers, metadata: metadata,
            outputConfig: outputConfig, outputFormat: try toolRunnerOutputFormat(Output.self), serviceTier: serviceTier, speed: speed, stopSequences: stopSequences,
            system: system, thinking: thinking, thread: thread, toolChoice: toolChoice, betas: betas, userProfileID: userProfileID,
            workspaceID: workspaceID)

        return try BetaParsedToolRunner<Output>(
            thread: messageThread, options: ToolRunnerRequestOptions(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout),
            maxIterations: maxIterations, parser: structuredOutputParser(Output.self))
    }

    /// Run the tools the model calls until it stops asking for them, yielding the stream of each assistant message
    /// (`tool_runner(stream=True)`). Takes the arguments of `toolRunner(...)`.
    ///
    /// - Parameter runToolsEagerly: Run each tool as soon as its call is complete, before the reply finishes, instead
    ///   of once you are done with the reply. This is optimistic: if the reply is interrupted or changes course, the
    ///   tool may have already run, so use `runner.deferToolCall()` to hold the calls that aren't safe to run twice.
    ///   The calls run one at a time, and reading the stream waits while one runs. A toolset call runs early too.
    public func streamingToolRunner(
        maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, tools: [any BetaToolLike], maxIterations: Int? = nil, runToolsEagerly: Bool = false,
        cacheControl: BetaCacheControlEphemeralParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil,
        contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil,
        fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil,
        inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil,
        metadata: BetaMetadataParam? = nil, outputConfig: BetaOutputConfigParam? = nil,
        serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil, speed: BetaMessageCreateParamsBase.Speed?? = nil,
        stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil, thinking: BetaThinkingConfigParam? = nil,
        thread: Bool? = nil, toolChoice: BetaToolChoiceParam? = nil, betas: [AnthropicBetaParam]? = nil,
        userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil,
        extraBody: Body? = nil, timeout: Timeout? = nil
    ) throws -> BetaStreamingToolRunner<Never> {
        let messageThread = try toolRunnerThread(
            maxTokens: maxTokens, messages: messages, model: model, tools: tools, cacheControl: cacheControl, container: container,
            contextManagement: contextManagement, diagnostics: diagnostics, fallbackCreditToken: fallbackCreditToken,
            fallbacks: fallbacks, inferenceGeo: inferenceGeo, mcpServers: mcpServers, metadata: metadata,
            outputConfig: outputConfig, outputFormat: nil, serviceTier: serviceTier, speed: speed, stopSequences: stopSequences,
            system: system, thinking: thinking, thread: thread, toolChoice: toolChoice, betas: betas, userProfileID: userProfileID,
            workspaceID: workspaceID)

        return try BetaStreamingToolRunner<Never>(
            thread: messageThread, options: ToolRunnerRequestOptions(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout),
            maxIterations: maxIterations, runToolsEagerly: runToolsEagerly, parser: nil)
    }

    /// `streamingToolRunner(...)` with an output format: each reply's text is parsed into `outputFormat`.
    public func streamingToolRunner<Output: StructuredOutput>(
        maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, tools: [any BetaToolLike], maxIterations: Int? = nil, runToolsEagerly: Bool = false,
        cacheControl: BetaCacheControlEphemeralParam?? = nil, container: BetaMessageCreateParamsBase.Container?? = nil,
        contextManagement: BetaContextManagementConfigParam?? = nil, diagnostics: BetaDiagnosticsParam?? = nil,
        fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken?? = nil, fallbacks: BetaFallbacksParam?? = nil,
        inferenceGeo: String?? = nil, mcpServers: [BetaRequestMCPServerURLDefinitionParam]? = nil,
        metadata: BetaMetadataParam? = nil, outputConfig: BetaOutputConfigParam? = nil, outputFormat: Output.Type,
        serviceTier: BetaMessageCreateParamsBase.ServiceTier? = nil, speed: BetaMessageCreateParamsBase.Speed?? = nil,
        stopSequences: [String]? = nil, system: BetaMessageCreateParamsBase.System? = nil, thinking: BetaThinkingConfigParam? = nil,
        thread: Bool? = nil, toolChoice: BetaToolChoiceParam? = nil, betas: [AnthropicBetaParam]? = nil,
        userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil,
        extraBody: Body? = nil, timeout: Timeout? = nil
    ) throws -> BetaStreamingToolRunner<Output> {
        let messageThread = try toolRunnerThread(
            maxTokens: maxTokens, messages: messages, model: model, tools: tools, cacheControl: cacheControl, container: container,
            contextManagement: contextManagement, diagnostics: diagnostics, fallbackCreditToken: fallbackCreditToken,
            fallbacks: fallbacks, inferenceGeo: inferenceGeo, mcpServers: mcpServers, metadata: metadata,
            outputConfig: outputConfig, outputFormat: try toolRunnerOutputFormat(Output.self), serviceTier: serviceTier, speed: speed, stopSequences: stopSequences,
            system: system, thinking: thinking, thread: thread, toolChoice: toolChoice, betas: betas, userProfileID: userProfileID,
            workspaceID: workspaceID)

        return try BetaStreamingToolRunner<Output>(
            thread: messageThread, options: ToolRunnerRequestOptions(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout),
            maxIterations: maxIterations, runToolsEagerly: runToolsEagerly, parser: structuredOutputParser(Output.self))
    }

    private func toolRunnerThread(
        maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, tools: [any BetaToolLike],
        cacheControl: BetaCacheControlEphemeralParam??, container: BetaMessageCreateParamsBase.Container??,
        contextManagement: BetaContextManagementConfigParam??, diagnostics: BetaDiagnosticsParam??,
        fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken??, fallbacks: BetaFallbacksParam??,
        inferenceGeo: String??, mcpServers: [BetaRequestMCPServerURLDefinitionParam]?, metadata: BetaMetadataParam?,
        outputConfig: BetaOutputConfigParam?, outputFormat: @autoclosure () throws -> [String: JSONValue]?,
        serviceTier: BetaMessageCreateParamsBase.ServiceTier?, speed: BetaMessageCreateParamsBase.Speed??,
        stopSequences: [String]?, system: BetaMessageCreateParamsBase.System?, thinking: BetaThinkingConfigParam?, thread: Bool?,
        toolChoice: BetaToolChoiceParam?, betas: [AnthropicBetaParam]?, userProfileID: String?, workspaceID: String?
    ) throws -> MessageThread {
        let format = try outputFormat()
        try validateOutputConfigConflict(outputConfig, hasOutputFormat: format != nil)
        let (fields, jsonMessages, threading) = try toolRunnerParams(
            maxTokens: maxTokens, messages: messages, model: model, cacheControl: cacheControl, container: container,
            contextManagement: contextManagement, diagnostics: diagnostics, fallbackCreditToken: fallbackCreditToken,
            fallbacks: fallbacks, inferenceGeo: inferenceGeo, mcpServers: mcpServers, metadata: metadata,
            outputConfig: outputConfig, serviceTier: serviceTier, speed: speed, stopSequences: stopSequences, system: system,
            thinking: thinking, thread: thread, toolChoice: toolChoice, betas: betas, userProfileID: userProfileID,
            workspaceID: workspaceID)
        return try MessageThread.forToolRunner(
            client: client, fields: fields, messages: jsonMessages, tools: tools, threading: threading, outputFormat: format)
    }

    func toolRunnerParams(
        maxTokens: Int, messages: [BetaMessageParam], model: ModelParam, cacheControl: BetaCacheControlEphemeralParam??,
        container: BetaMessageCreateParamsBase.Container??, contextManagement: BetaContextManagementConfigParam??,
        diagnostics: BetaDiagnosticsParam??, fallbackCreditToken: BetaMessageCreateParamsBase.FallbackCreditToken??,
        fallbacks: BetaFallbacksParam??, inferenceGeo: String??, mcpServers: [BetaRequestMCPServerURLDefinitionParam]?,
        metadata: BetaMetadataParam?, outputConfig: BetaOutputConfigParam?, serviceTier: BetaMessageCreateParamsBase.ServiceTier?,
        speed: BetaMessageCreateParamsBase.Speed??, stopSequences: [String]?, system: BetaMessageCreateParamsBase.System?,
        thinking: BetaThinkingConfigParam?, thread: Bool?, toolChoice: BetaToolChoiceParam?, betas: [AnthropicBetaParam]?,
        userProfileID: String?, workspaceID: String?
    ) throws -> ([String: JSONValue], [JSONValue], Bool) {
        if thread == true { try rejectThreadParam(.bool(true)) }
        warnIfDeprecatedModel(model.rawValue)
        warnIfThinkingEnabledDeprecated(model.rawValue, thinking: thinking)
        var body = ParamsBuilder()
        try body.set("max_tokens", maxTokens)
        try body.set("model", model)
        try body.set("cache_control", cacheControl)
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
        try body.set("tool_choice", toolChoice)
        try body.set("betas", betas)
        try body.set("user_profile_id", userProfileID)
        try body.set("workspace_id", workspaceID)
        var fields: [String: JSONValue] = [:]
        for (k, v) in body.items { fields[k] = v }
        return (fields, try messages.map { try JSONValue.from($0) }, thread != false)
    }
}
