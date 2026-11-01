import Foundation

// Port of `lib/_tracing/_api_call.py` and `lib/_tracing/_response.py`: the `gen_ai.*` and
// `anthropic.*` attributes of a call span, and the attributes that some methods start their span with.

/// Records the call's `result` on its span, and ends the span (`finish_api_call_span`).
///
/// The body of a stream or of an unread raw response keeps the span until the application has read, closed or
/// dropped it. Anything else ends it now. Never throws.
func finishApiCallSpan(_ client: BaseClient, _ span: any Span, _ result: ApiCallResult) {
    let observer = recordApiCall(client, span, result)
    if let response = result.response {
        endApiCallSpanWhenBodyEnds(span, response, result, observer: observer)
        return
    }
    endApiCallSpan(span, result)
}

/// Sets the `gen_ai.*` and `anthropic.*` attributes of the call (`record_api_call`).
///
/// Returns the observer that records a streamed Message as the application reads it, and `nil` for any other result.
func recordApiCall(_ client: BaseClient, _ span: any Span, _ result: ApiCallResult) -> (any StreamObserver)? {
    guard span.isRecording else { return nil }
    setResponseHeaderAttributes(span, result)
    setCreatedIDAttribute(span, result)
    // What to record follows from what the method says the call returns, which is also known when the call fails.
    if result.castTo == Message.self || result.castTo == BetaMessage.self {
        return recordMessagesCreate(client, span, result)
    }
    setResponseAttributes(span, result)
    return nil
}

func setResponseHeaderAttributes(_ span: any Span, _ result: ApiCallResult) {
    guard let response = result.finalAttempt else { return }
    for (attribute, header) in RESPONSE_HEADER_ATTRIBUTES {
        if let value = response.headers[header], !value.isEmpty { span.setAttribute(attribute, .string(value)) }
    }
}

/// Sets the ID of the object that the call created, which the body of a raw response has too.
func setCreatedIDAttribute(_ span: any Span, _ result: ApiCallResult) {
    guard let created = result.options.spanCreatedID, result.error == nil else { return }
    if let id = responseData(result)?[created.field]?.stringValue { span.setAttribute(created.attribute, .string(id)) }
}

func setResponseAttributes(_ span: any Span, _ result: ApiCallResult) {
    if result.castTo == MessageTokensCount.self || result.castTo == BetaMessageTokensCount.self {
        if let tokens = responseData(result)?["input_tokens"]?.intValue {
            span.setAttribute("anthropic.message.count_tokens.input_tokens", .int(tokens))
        }
    }
    // Other Sessions methods return a Session too, and only the span of the one that creates it, which names the
    // attribute of the created ID, has its Agent's name and model.
    if result.castTo == BetaManagedAgentsSession.self && result.options.spanCreatedID != nil, let session = responseData(result) {
        guard let name = session["agent"]?["name"]?.stringValue else { return }
        span.setAttribute("gen_ai.agent.name", .string(name))
        guard let model = session["agent"]?["model"]?["id"]?.stringValue else { return }
        span.setAttribute("gen_ai.request.model", .string(model))
    }
}

/// Records the response of a `messages.create` call, and in content mode the request's messages too
/// (`record_messages_create`). A streamed Message is recorded from its events as the application reads them, by the
/// observer that is returned.
func recordMessagesCreate(_ client: BaseClient, _ span: any Span, _ result: ApiCallResult) -> (any StreamObserver)? {
    let body = result.options.jsonData
    let otel = client.otel
    // A raw response of a streaming request has no stream until the application parses it.
    if let response = result.response, result.data.isStream || (tracingGet(body, "stream") == .bool(true) && !response.isClosed) {
        return StreamedMessage(span, body: body, requestHeaders: response.request.headers, content: otel.recordsContent,
                               maxContentBytes: otel.maxContentBytes, startTime: result.startTime)
    }
    let data = responseData(result)
    if let message = data, message.objectValue != nil {
        setResponse(span, message, complete: true, beta: result.castTo == BetaMessage.self)
    }
    if otel.recordsContent {
        setMessageContent(span, body: body, output: tracingGet(data, "content"), limit: otel.maxContentBytes)
    }
    return nil
}

/// What an API call's response gave, as JSON: the parsed body, or the decoded body of a raw response
/// (`response_data`). `withStreamingResponse` has not read its body, so that gives `nil`, and so does a stream.
func responseData(_ result: ApiCallResult) -> JSONValue? {
    switch result.data {
    case .none: return nil
    case .response(let http):
        return http.isClosed ? jsonBody(http) : nil
    case .value(let value):
        if value is TracedEventStream { return nil }
        // The body as the API sent it, which has what the model of the value leaves out.
        if let http = result.response, let body = jsonBody(http) { return body }
        if let json = value as? JSONValue { return json }
        if let encodable = value as? any Encodable { return try? JSONValue.from(encodable) }
        return nil
    }
}

func jsonBody(_ response: HTTPResponse) -> JSONValue? {
    let mediaType = (response.headers["content-type"] ?? "").split(separator: ";").first.map {
        $0.trimmingCharacters(in: .whitespaces).lowercased()
    }
    guard mediaType == "application/json", let data = response.bufferedBody else { return nil }
    return try? JSONValue.parse(data)
}

func setTimeToFirstChunk(_ span: any Span, startTime: Date) {
    span.setAttribute("gen_ai.response.time_to_first_chunk", .double(Date().timeIntervalSince(startTime)))
}

/// Sets the attributes that come from a Message (`set_response`).
///
/// The stop reason and the output usage need `complete`: a streamed Message has them from its `message_delta`.
/// Nothing validates a response against its type unless the client is told to, so a field can be missing or of
/// another type: the attributes stop at the first one that is.
func setResponse(_ span: any Span, _ message: JSONValue, complete: Bool, beta: Bool) {
    if let id = message["id"]?.stringValue { span.setAttribute("gen_ai.response.id", .string(id)) }
    if let model = message["model"]?.stringValue { span.setAttribute("gen_ai.response.model", .string(model)) }
    if complete, let stopReason = tracingGet(message, "stop_reason")?.stringValue {
        span.setAttribute("anthropic.message.stop_reason", .string(stopReason))
    }

    guard let usage = message["usage"], usage.objectValue != nil, let inputTokens = usage["input_tokens"]?.intValue else { return }
    let cacheWrite = tracingGet(usage, "cache_creation_input_tokens")?.intValue
    let cacheRead = tracingGet(usage, "cache_read_input_tokens")?.intValue
    span.setAttribute("gen_ai.usage.input_tokens", .int(inputTokens + (cacheRead ?? 0) + (cacheWrite ?? 0)))
    if let cacheWrite { span.setAttribute("gen_ai.usage.cache_write.input_tokens", .int(cacheWrite)) }
    if let cacheRead { span.setAttribute("gen_ai.usage.cache_read.input_tokens", .int(cacheRead)) }
    if let cacheCreation = tracingGet(usage, "cache_creation") {
        guard let fiveMinutes = cacheCreation["ephemeral_5m_input_tokens"]?.intValue else { return }
        span.setAttribute("anthropic.usage.cache_creation.ephemeral_5m_input_tokens", .int(fiveMinutes))
        guard let oneHour = cacheCreation["ephemeral_1h_input_tokens"]?.intValue else { return }
        span.setAttribute("anthropic.usage.cache_creation.ephemeral_1h_input_tokens", .int(oneHour))
    }
    if let tier = tracingGet(usage, "service_tier")?.stringValue { span.setAttribute("anthropic.response.service_tier", .string(tier)) }
    guard complete else { return }

    guard let outputTokens = usage["output_tokens"]?.intValue else { return }
    span.setAttribute("gen_ai.usage.output_tokens", .int(outputTokens))
    if let details = tracingGet(usage, "output_tokens_details") {
        guard let thinking = details["thinking_tokens"]?.intValue else { return }
        span.setAttribute("gen_ai.usage.reasoning.output_tokens", .int(thinking))
    }

    // Only the beta usage has the iterations. The usage above leaves out the tokens of their compactions.
    guard beta, let iterations = tracingGet(usage, "iterations")?.arrayValue, !iterations.isEmpty else { return }
    let compactions = iterations.filter { $0["type"]?.stringValue == "compaction" }
    guard !compactions.isEmpty else { return }
    var input = 0, output = 0
    for entry in compactions {
        guard let i = entry["input_tokens"]?.intValue, let o = entry["output_tokens"]?.intValue,
              let read = entry["cache_read_input_tokens"]?.intValue, let write = entry["cache_creation_input_tokens"]?.intValue
        else { return }
        input += i + read + write
        output += o
    }
    span.setAttribute("anthropic.usage.compaction.input_tokens", .int(input))
    span.setAttribute("anthropic.usage.compaction.output_tokens", .int(output))
}

// MARK: - Request attributes

/// The attributes that the span of a `messages.create` call starts with, from the request's `body` and headers
/// (`messages_create_request_attributes`). Never throws.
public func messagesCreateRequestAttributes(_ client: BaseClient, _ body: JSONValue?, _ headers: Headers?) -> SpanAttributes {
    var values: [String: AttributeValue?] = [:]
    values["gen_ai.operation.name"] = "chat"
    values["gen_ai.request.model"] = AttributeValue(json: tracingGet(body, "model"))
    values["gen_ai.request.max_tokens"] = AttributeValue(json: tracingGet(body, "max_tokens"))
    if let temperature = tracingGet(body, "temperature")?.doubleValue { values["gen_ai.request.temperature"] = .double(temperature) }
    if let topP = tracingGet(body, "top_p")?.doubleValue { values["gen_ai.request.top_p"] = .double(topP) }
    values["gen_ai.request.top_k"] = AttributeValue(json: tracingGet(body, "top_k"))
    if tracingGet(body, "stream") == .bool(true) { values["gen_ai.request.stream"] = .bool(true) }
    values["gen_ai.request.reasoning.level"] = AttributeValue(json: tracingGet(tracingGet(body, "output_config"), "effort"))
    // `output_format` is the deprecated form of `output_config.format`.
    let formats = [tracingGet(tracingGet(body, "output_config"), "format"), tracingGet(body, "output_format")]
    if formats.contains(where: { tracingGet($0, "type") == .string("json_schema") }) { values["gen_ai.output.type"] = "json" }
    values["anthropic.request.service_tier"] = AttributeValue(json: tracingGet(body, "service_tier"))
    let thinking = tracingGet(body, "thinking")
    values["anthropic.thinking.type"] = AttributeValue(json: tracingGet(thinking, "type"))
    values["anthropic.thinking.budget_tokens"] = AttributeValue(json: tracingGet(thinking, "budget_tokens"))
    let betaHeader = requestHeader(client, headers, "anthropic-beta") ?? ""
    let betas = betaHeader.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    if !betas.isEmpty { values["anthropic.beta"] = .stringArray(betas) }
    return tracingAttributes(values)
}

/// The attributes that the span of a `messages.count_tokens` call starts with (`messages_count_tokens_request_attributes`).
public func messagesCountTokensRequestAttributes(_ client: BaseClient, _ body: JSONValue?, _ headers: Headers?) -> SpanAttributes {
    tracingAttributes(["gen_ai.request.model": tracingGet(body, "model")?.stringValue.map { .string($0) }])
}

/// The attributes that the span of a `messages.batches.create` call starts with: how many requests the prepared body has.
public func batchCreateRequestAttributes(_ client: BaseClient, _ body: JSONValue?, _ headers: Headers?) -> SpanAttributes {
    tracingAttributes(["anthropic.message.batch.request_count": tracingCount(tracingGet(body, "requests")).map { .int($0) }])
}

/// The attributes that the span of a `sessions.create` call starts with, from the request's `body`
/// (`sessions_create_request_attributes`).
public func sessionsCreateRequestAttributes(_ client: BaseClient, _ body: JSONValue?, _ headers: Headers?) -> SpanAttributes {
    let agent = tracingGet(body, "agent")
    let agentID = agent?.stringValue ?? tracingGet(agent, "id")?.stringValue
    return tracingAttributes([
        "gen_ai.agent.id": agentID.map { .string($0) },
        "anthropic.session.environment.id": AttributeValue(json: tracingGet(body, "environment_id")),
    ])
}

/// The value that the call's attempts send for the header `name`: the call's own, or else the client's default
/// (`request_header`).
func requestHeader(_ client: BaseClient, _ headers: Headers?, _ name: String) -> String? {
    var value: String? = nil
    for layer in [client.defaultHeaders, headers ?? [:]] {
        for (key, header) in layer where key.lowercased() == name {
            value = header.stringValue
        }
    }
    return value
}
