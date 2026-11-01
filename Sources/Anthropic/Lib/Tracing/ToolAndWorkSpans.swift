import Foundation

// Port of `lib/_tracing/_tools.py` and `lib/_tracing/_work.py`: the `INTERNAL` spans of the tool runners
// and of the work items of a self-hosted environment.

extension BaseClient {
    /// Starts the span of one loop of the Messages tool runner. The runner sets its status and ends it
    /// (`start_tool_runner_span`). `jsonOutput` is whether the request sets a JSON schema output format.
    /// Never throws: a loop whose span cannot start runs without one.
    public func startToolRunnerSpan(model: String, jsonOutput: Bool) -> (any Span)? {
        guard let tracer else { return nil }
        let otel = self.otel
        return tracer.startSpan("anthropic.messages.tool_runner", kind: .internal, attributes: tracingAttributes([
            "gen_ai.operation.name": "invoke_agent",
            "gen_ai.provider.name": .string(otel.providerName),
            "gen_ai.request.model": .string(model),
            "gen_ai.conversation.id": otel.conversationID.map { .string($0) },
            "gen_ai.output.type": jsonOutput ? "json" : nil,
        ]))
    }

    /// Runs `body` in the span of one client tool run, which ends with the result that `body` set on the run
    /// (`tool_use_span`).
    ///
    /// The span is named `anthropic.tool_use` for an agent-toolset tool (`agentTool`), `anthropic.mcp_tool_use` for a
    /// tool that the MCP helper made (`mcpTool`), and `anthropic.custom_tool_use` for any other tool, followed by the
    /// tool's name. Its conversation ID is the one that the client's options set, or else `conversationID`.
    public func withToolUseSpan<R>(toolUseID: String, toolName: String, description: String? = nil, input: JSONValue?,
                                   toolsetName: String? = nil, agentTool: Bool = false, mcpTool: Bool = false, sessionID: String? = nil,
                                   sessionThreadID: String? = nil, conversationID: String? = nil,
                                   _ body: (ToolRun) async throws -> R) async rethrows -> R
    {
        let run = ToolRun()
        guard let tracer else { return try await body(run) }
        let otel = self.otel
        let operation = agentTool ? "anthropic.tool_use" : mcpTool ? "anthropic.mcp_tool_use" : "anthropic.custom_tool_use"
        let span = tracer.startSpan(toolName.isEmpty ? operation : "\(operation) \(toolName)", kind: .internal, attributes: tracingAttributes([
            "gen_ai.operation.name": "execute_tool",
            "gen_ai.provider.name": .string(otel.providerName),
            "gen_ai.tool.name": .string(toolName),
            "anthropic.toolset.name": toolsetName.map { .string($0) },
            // A function tool without a description has an empty one.
            "gen_ai.tool.description": description.flatMap { $0.isEmpty ? nil : .string($0) },
            "gen_ai.tool.call.id": .string(toolUseID),
            "gen_ai.conversation.id": (otel.conversationID ?? conversationID).map { .string($0) },
            "anthropic.session.id": sessionID.map { .string($0) },
            "anthropic.session.thread.id": sessionThreadID.map { .string($0) },
            "gen_ai.tool.type": "function",
        ]))
        defer { endToolUseSpan(span, input: input, run: run) }
        return try await TracingContext.withSpan(span) { try await body(run) }
    }

    /// Ends the span with the run's result. An error result fails it with `tool_error`, and none leaves its status
    /// unset (`end_tool_use_span`).
    func endToolUseSpan(_ span: any Span, input: JSONValue?, run: ToolRun) {
        let result = run.result
        if span.isRecording && otel.recordsContent {
            let content: OrderedJSON? = result == nil ? nil : .array(toolResultContent(run.content ?? tracingGet(result, "content")))
            setContentAttributes(span, [TOOL_CALL_ARGUMENTS: input.map { OrderedJSON($0) }, TOOL_RESULT_CONTENT: content],
                                 limit: otel.maxContentBytes)
        }
        if let result, tracingGet(result, "is_error") == .bool(true) {
            span.setStatus(.error)
            span.setAttribute(ERROR_TYPE, "tool_error")
        } else if result != nil {
            span.setStatus(.ok)
        }
        span.end()
    }
}

/// Sets the status of a tool runner's span, if it has one: `OK`, or what `error` makes it (`set_tool_runner_status`).
public func setToolRunnerStatus(_ span: (any Span)?, error: Error? = nil) {
    guard let span else { return }
    if let error { setErrorStatus(span, error) } else { span.setStatus(.ok) }
}

/// Ends a tool runner's span, if it has one (`end_tool_runner_span`).
public func endToolRunnerSpan(_ span: (any Span)?) { span?.end() }

/// What a tool runner made of one tool run to send back to the model, for the run's span (`ToolRun`).
public final class ToolRun: @unchecked Sendable {
    private let lock = NSLock()
    private var _result: JSONValue?
    private var _content: JSONValue?

    public init() {}

    /// The `tool_result` block. It stays `nil` when the run was interrupted before the runner made anything of it.
    public var result: JSONValue? {
        get { lock.withLock { _result } }
        set { lock.withLock { _result = newValue } }
    }

    /// What the span records in place of the result's content: the Sessions tool runner sends some blocks as the text
    /// of their JSON, and the span has the blocks themselves.
    public var content: JSONValue? {
        get { lock.withLock { _content } }
        set { lock.withLock { _content = newValue } }
    }
}

/// The `anthropic.environment.work` span of the work item that a work poller returned last (`WorkSpan`).
///
/// The poller starts it when a poll returns the item, and ends it with status `OK` when its consumer asks for the next
/// item or stops polling. A consumer that handles the item with `span` current ends the span first, with how the
/// handling went.
public final class WorkSpan: @unchecked Sendable {
    private let lock = NSLock()
    private var _span: (any Span)?

    public init() {}

    /// `nil` without a tracer, before the first item, and once the span has ended.
    public var span: (any Span)? { lock.withLock { _span } }

    /// Starts the span of the work item `workID` of the environment `environmentID`. Never throws: an item whose span
    /// cannot start is handled without one.
    public func start(_ client: BaseClient, environmentID: String?, workID: String?, sessionID: String?) {
        guard let tracer = client.tracer else { return }
        let span = tracer.startSpan("anthropic.environment.work", kind: .internal, attributes: tracingAttributes([
            "gen_ai.provider.name": .string(client.otel.providerName),
            "anthropic.environment.id": environmentID.map { .string($0) },
            "anthropic.environment.work.id": workID.map { .string($0) },
            // An item that the generated type does not model can have no data, or data without an ID.
            "anthropic.session.id": sessionID.map { .string($0) },
        ]))
        lock.withLock { _span = span }
    }

    /// Ends the span, unless it has ended. The status stays unset when `error` is a cancellation, and when the consumer
    /// stopped before it `finished` with the item, as a worker that lost the item's lease does.
    public func end(error: Error? = nil, finished: Bool = true) {
        let span: (any Span)? = lock.withLock {
            let s = _span
            _span = nil
            return s
        }
        guard let span else { return }
        if let error { setErrorStatus(span, error) } else if finished { span.setStatus(.ok) }
        span.end()
    }
}
