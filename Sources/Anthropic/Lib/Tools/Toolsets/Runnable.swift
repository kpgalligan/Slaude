// Port of `anthropic/lib/tools/_toolsets/_runnable.py`: the runnable-toolset contract for the toolset families
// (`browser_toolset_20260801`, `computer_toolset_20260801`).
//
// A toolset is one nameless `tools[]` entry declaring a family of member tools. Each member call is its own
// `tool_use` whose `name` is the member and whose `toolset_name` is the family, and the `tool_result` echoes
// `toolset_name`. Dispatch keys on `(toolset_name, name)`, never on `name` alone.

import Foundation

/// The `tool_result` content a member call renders to (`BetaToolsetContent`, or a string).
public typealias BetaToolsetContent = BetaToolResultBlockParam.Content_

/// What a member receives alongside its input: the `tool_use` block the call answers.
public struct BetaToolsetCallContext: Sendable, Hashable {
    public var toolUse: BetaToolUseBlock?
    public init(toolUse: BetaToolUseBlock? = nil) { self.toolUse = toolUse }
}

/// A toolset the tool runner can run (`BetaRunnableToolset`). Subclass it and override `toolsetName`,
/// `toDict()` and `call(context:name:input:)`.
open class BetaRunnableToolset: BetaToolLike, @unchecked Sendable {
    private let closedLock = NSLock()
    private var _toolsetClosed = false

    public init() {}

    /// The family this toolset answers for, matched against `tool_use.toolset_name`.
    open var toolsetName: String { "" }

    /// The `tools[]` entry to send. SDK-side behaviour options never appear here.
    open func toDict() throws -> JSONValue {
        throw ToolsetContractError("\(type(of: self)) must override toDict()")
    }

    /// Execute member `name` with the raw `tool_use.input` and return the tool-result content. Throw a `ToolError`
    /// for a model-visible failure.
    open func call(context: BetaToolsetCallContext, name: String, input: BetaToolInput) async throws -> BetaToolsetContent {
        throw ToolsetContractError("\(type(of: self)) must override call(context:name:input:)")
    }

    /// Release any resource the toolset holds. The tool runner never closes a toolset. The default only marks the
    /// toolset closed; override it in a toolset that owns a resource and call `super.close()`.
    open func close() async throws {
        markClosed()
    }

    open var helperTag: String? { nil }

    public func toToolParam() throws -> JSONValue { try toDict() }

    /// Whether `close()` ran. A member call on a closed toolset raises `ToolsetClosedError`.
    public var isClosed: Bool { closedLock.withLock { _toolsetClosed } }

    public func markClosed() { closedLock.withLock { _toolsetClosed = true } }

    func refuseIfClosed() throws {
        if isClosed { throw ToolsetClosedError("this \(pythonStringRepr(toolsetName)) toolset is closed") }
    }

    func checkToolUse(_ toolUse: BetaToolUseBlock) throws {
        if toolUse.toolsetName != toolsetName {
            throw ToolsetContractError(
                "tool_use \(pythonStringRepr(toolUse.id)) (toolset_name=\(toolUse.toolsetName.map(pythonStringRepr) ?? "None"), "
                    + "name=\(pythonStringRepr(toolUse.name))) is not a member call of the \(pythonStringRepr(toolsetName)) toolset")
        }
    }

    /// Runs one member `tool_use` and builds its `tool_result` block, for callers driving `messages.create`
    /// themselves. A `ToolsetUsageError` propagates; a `ToolError` or any other error becomes an `is_error` result.
    public func toolResult(_ toolUse: BetaToolUseBlock) async throws -> BetaToolResultBlockParam {
        try await toolResultJSON(toolUse).decode()
    }

    /// `toolResult` as the JSON block the runner sends.
    func toolResultJSON(_ toolUse: BetaToolUseBlock) async throws -> JSONValue {
        try checkToolUse(toolUse)
        try refuseIfClosed()
        let content: BetaToolsetContent
        do {
            content = try await call(context: BetaToolsetCallContext(toolUse: toolUse), name: toolUse.name, input: toolUse.input)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return try memberErrorResult(toolUse, error)
        }
        return toolsetResultBlock(toolUse, try JSONValue.from(content))
    }
}

/// What the runner answers for a toolset member it did not run because an earlier member failed in the same turn.
public let NOT_EXECUTED = "Not executed: an earlier action in this turn failed."

/// Each family's wording of `NOT_EXECUTED`, by `toolset_name`.
public let HALT_TEXT: [String: String] = [
    "browser": NOT_EXECUTED, "computer": "Not executed: an earlier computer action in this turn failed.",
]

let toolsetLog = ToolLogger(name: "anthropic.lib.tools._toolsets._runnable")

func notExecutedResult(_ toolUse: BetaToolUseBlock) -> JSONValue {
    toolsetResultBlock(toolUse, .string(HALT_TEXT[toolUse.toolsetName ?? ""] ?? NOT_EXECUTED), isError: true)
}

/// The rule for an error out of a member call: a `ToolsetUsageError` propagates, a `ToolError` is the member's own
/// refusal, and anything else becomes a refusal reading `Type: message`.
func classify(_ error: Error) throws -> ToolError {
    if let e = error as? ToolsetUsageError { throw e }
    if let e = error as? ToolError { return e }
    let name: String
    let message: String
    switch error {
    case let e as ValueError: (name, message) = ("ValueError", e.message)
    case let e as ArgumentTypeError: (name, message) = ("TypeError", e.message)
    case let e as AnthropicError: (name, message) = (String(describing: type(of: e)), e.message)
    default: (name, message) = (String(describing: type(of: error)), String(describing: error))
    }
    return ToolError(.string(wellFormed(message.isEmpty ? name : "\(name): \(message)")))
}

/// The rule for an error out of a developer hook (`confirm`, `urlPolicy`, the file policy): a `ToolsetUsageError`
/// stops the run, a `ToolError` is returned as raised, and anything else fails closed as `fallback`.
func hookRefusal(_ error: Error, fallback: ToolError) throws -> ToolError {
    var result = try classify(error)
    if result !== (error as? ToolError) {
        toolsetLog.exception("A toolset hook raised; failing closed with \(pythonStringRepr(fallback.message))", error)
        result = fallback
    }
    return result
}

/// `classify` for the runner: the refusal as an `is_error` result, an unexpected error logged first.
func memberErrorResult(_ toolUse: BetaToolUseBlock, _ error: Error) throws -> JSONValue {
    let refusal = try classify(error)
    var content = refusal.content
    if refusal !== (error as? ToolError) {
        toolsetLog.exception(
            "Error occurred while calling toolset member: \(logSafe(toolUse.toolsetName))/\(logSafe(toolUse.name))", error)
        content = .string(errorText(error))
    }
    return toolsetResultBlock(toolUse, errorTextContent(content), isError: true)
}

/// The `tool_result` answering a member `tool_use`. `toolset_name` is echoed on error paths too.
func toolsetResultBlock(_ toolUse: BetaToolUseBlock, _ content: JSONValue, isError: Bool = false) -> JSONValue {
    var content = content
    if isError && isEmptyContent(content) {
        content = "The tool call failed with an empty error message."
    }
    var block: [String: JSONValue] = [
        "type": "tool_result",
        "tool_use_id": .string(toolUse.id),
        "toolset_name": toolUse.toolsetName.map { .string($0) } ?? .null,
        "content": content,
    ]
    if isError { block["is_error"] = true }
    return .object(block)
}

/// Python truthiness of a content value (`not content`).
func isEmptyContent(_ content: JSONValue) -> Bool {
    switch content {
    case .null: return true
    case .string(let s): return s.isEmpty
    case .array(let a): return a.isEmpty
    default: return false
    }
}
