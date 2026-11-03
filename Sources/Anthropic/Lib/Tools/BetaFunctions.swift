// Port of `anthropic/lib/tools/_beta_functions.py`.
//
// Python builds a function tool from a decorated function, inferring the JSON schema from its signature and
// docstring with pydantic. Swift has no runtime signature to read, so a tool is built from an explicit name,
// description and JSON input schema plus an async closure: either over the raw JSON input, or over a `Decodable`
// input type (the counterpart of pydantic's argument validation).

import Foundation

/// What a tool returns: a string, or a list of content blocks (`BetaFunctionToolResultType`).
public typealias BetaFunctionToolResult = BetaToolResultBlockParam.Content_

/// A tool's input: the `tool_use.input` object.
public typealias BetaToolInput = [String: JSONValue]

#if compiler(>=6.2)
    /// What a typed tool's input must be: `Decodable`, with a metatype the tool's `@Sendable` function may capture
    /// (SE-0470). Every concrete type qualifies unless its `Decodable` conformance is actor-isolated, which would make
    /// decoding off that actor a data race.
    public typealias BetaToolDecodableInput = Decodable & SendableMetatype
#else
    /// What a typed tool's input must be. `SendableMetatype` (SE-0470) arrives with Swift 6.2.
    public typealias BetaToolDecodableInput = Decodable
#endif

/// An error a tool raises to return structured content with `is_error: true` (`ToolError`).
///
/// When the tool runner catches it, it uses `content` as the tool result instead of the error's `repr`.
open class ToolError: Error, CustomStringConvertible, LocalizedError, PythonReprError, @unchecked Sendable {
    public let content: BetaFunctionToolResult
    public let message: String
    /// The error this one was raised from (Python's `raise ... from cause`), if any.
    public let cause: Error?

    public init(_ content: BetaFunctionToolResult, cause: Error? = nil) {
        self.content = content
        self.cause = cause
        switch content {
        case .string(let s): message = s
        default:
            var parts: [String] = []
            for block in (try? JSONValue.from(content))?.arrayValue ?? [] {
                if let text = block["text"], !text.isNull {
                    parts.append(text.stringValue ?? text.description)
                } else {
                    parts.append("[\(block["type"]?.stringValue ?? "unknown")]")
                }
            }
            message = parts.isEmpty ? "Tool error" : parts.joined(separator: " ")
        }
    }

    public convenience init(_ message: String) { self.init(.string(message)) }

    open var description: String { message }
    public var errorDescription: String? { message }
    open var pythonRepr: String { "\(String(describing: type(of: self)))(\(pythonStringRepr(message)))" }
}

/// Anything the tool runners can run by name: a function tool or a builtin tool (`BetaRunnableTool`).
public protocol BetaRunnableTool: BetaToolLike, AnyObject {
    /// The name the model calls the tool by.
    var name: String { get }
    /// Runs the tool with the model's input. `nil` sends `content: null`.
    func call(_ input: JSONValue) async throws -> BetaFunctionToolResult?
    /// Releases what the tool holds (`close` / the context manager's exit). Called by the session tool runner.
    func closeTool() async throws
}

extension BetaRunnableTool {
    public func closeTool() async throws {}
}

/// A tool whose definition is a builtin (non-`custom`) tool type and whose behaviour the application supplies
/// (`BetaBuiltinFunctionTool`). Subclass it and override `toDict()` and `call(_:)`.
open class BetaBuiltinFunctionTool: BetaRunnableTool, @unchecked Sendable {
    public init() {}

    /// The `tools[]` entry to send.
    open func toDict() throws -> JSONValue {
        throw ArgumentTypeError("\(type(of: self)) must override toDict()")
    }

    open func call(_ input: JSONValue) async throws -> BetaFunctionToolResult? {
        throw ArgumentTypeError("\(type(of: self)) must override call(_:)")
    }

    open func closeTool() async throws {}

    public func toToolParam() throws -> JSONValue { try toDict() }

    /// The tool's name: its `mcp_server_name`, or its `name`.
    open var name: String { (try? builtinToolName(toDict())) ?? "" }
}

/// The name of a builtin tool's definition, or the `ValueError` upstream raises for a definition without one.
func builtinToolName(_ raw: JSONValue) throws -> String {
    if let server = raw["mcp_server_name"]?.stringValue { return server }
    guard let name = raw["name"]?.stringValue else {
        throw ValueError("Tool of type \(pythonRepr(raw["type"] ?? .null)) does not have a name")
    }
    return name
}

/// A tool backed by an async Swift closure (`BetaFunctionTool`, what `@beta_async_tool` builds).
///
/// ```swift
/// let getWeather = BetaFunctionTool(
///     name: "get_weather",
///     description: "Lookup the weather for a given city",
///     inputSchema: ["type": "object", "properties": ["location": ["type": "string"]], "required": ["location"]]
/// ) { (input: WeatherInput) in
///     "Sunny in \(input.location)"
/// }
/// ```
public final class BetaFunctionTool: BetaRunnableTool, @unchecked Sendable {
    public typealias Function = @Sendable (BetaToolInput) async throws -> BetaFunctionToolResult?
    public typealias AllowedCaller = BetaToolParam.AllowedCallers

    public let name: String
    public let description: String
    public let inputSchema: [String: JSONValue]
    public let deferLoading: Bool?
    public let cacheControl: BetaCacheControlEphemeralParam?
    public let allowedCallers: [AllowedCaller]?
    public let eagerInputStreaming: Bool?
    public let inputExamples: [[String: JSONValue]]?
    public let strict: Bool?
    /// The helper telemetry tag the tool's requests carry (`tag_helper`).
    public var helperTag: String?

    private let body: Body
    private let state = LazyEntry()
    private let onClose: (@Sendable () async throws -> Void)?

    private enum Body: Sendable {
        case function(Function)
        /// An async context manager: entered on the first call, exited by `closeTool()`.
        case lazy(@Sendable () async throws -> (Function, @Sendable () async throws -> Void))
    }

    private init(name: String, description: String, inputSchema: [String: JSONValue], deferLoading: Bool?,
                 cacheControl: BetaCacheControlEphemeralParam?, allowedCallers: [AllowedCaller]?, eagerInputStreaming: Bool?,
                 inputExamples: [[String: JSONValue]]?, strict: Bool?, close: (@Sendable () async throws -> Void)?, body: Body)
    {
        self.name = name
        self.description = description
        self.inputSchema = inputSchema
        self.deferLoading = deferLoading
        self.cacheControl = cacheControl
        self.allowedCallers = allowedCallers
        self.eagerInputStreaming = eagerInputStreaming
        self.inputExamples = inputExamples
        self.strict = strict
        self.onClose = close
        self.body = body
    }

    /// A tool over the raw JSON input.
    ///
    /// - Parameters:
    ///   - close: Optional cleanup, run when a runner that closes its tools ends (the session tool runner does).
    public convenience init(name: String, description: String = "", inputSchema: [String: JSONValue],
                            deferLoading: Bool? = nil, cacheControl: BetaCacheControlEphemeralParam? = nil,
                            allowedCallers: [AllowedCaller]? = nil, eagerInputStreaming: Bool? = nil,
                            inputExamples: [[String: JSONValue]]? = nil, strict: Bool? = nil,
                            close: (@Sendable () async throws -> Void)? = nil, _ function: @escaping Function)
    {
        self.init(name: name, description: description, inputSchema: inputSchema, deferLoading: deferLoading,
                  cacheControl: cacheControl, allowedCallers: allowedCallers, eagerInputStreaming: eagerInputStreaming,
                  inputExamples: inputExamples, strict: strict, close: close, body: .function(function))
    }

    /// A tool over a `Decodable` input. Input that doesn't decode raises
    /// `ValueError("Invalid arguments for function <name>")`, as pydantic's validation does upstream.
    public convenience init<Input: BetaToolDecodableInput>(name: String, description: String = "", inputSchema: [String: JSONValue],
                                                           deferLoading: Bool? = nil, cacheControl: BetaCacheControlEphemeralParam? = nil,
                                                           allowedCallers: [AllowedCaller]? = nil, eagerInputStreaming: Bool? = nil,
                                                           inputExamples: [[String: JSONValue]]? = nil, strict: Bool? = nil,
                                                           close: (@Sendable () async throws -> Void)? = nil,
                                                           _ function: @escaping @Sendable (Input) async throws -> BetaFunctionToolResult?)
    {
        self.init(name: name, description: description, inputSchema: inputSchema, deferLoading: deferLoading,
                  cacheControl: cacheControl, allowedCallers: allowedCallers, eagerInputStreaming: eagerInputStreaming,
                  inputExamples: inputExamples, strict: strict, close: close,
                  body: .function(typedFunction(name: name, function)))
    }

    /// A tool defined by an async context manager (`@beta_async_tool` over an `@asynccontextmanager`): `enter` runs
    /// on the first call and returns the function to call plus its exit, which `closeTool()` runs.
    public convenience init(name: String, description: String = "", inputSchema: [String: JSONValue],
                            deferLoading: Bool? = nil, cacheControl: BetaCacheControlEphemeralParam? = nil,
                            allowedCallers: [AllowedCaller]? = nil, eagerInputStreaming: Bool? = nil,
                            inputExamples: [[String: JSONValue]]? = nil, strict: Bool? = nil,
                            close: (@Sendable () async throws -> Void)? = nil,
                            enter: @escaping @Sendable () async throws -> (Function, @Sendable () async throws -> Void))
    {
        self.init(name: name, description: description, inputSchema: inputSchema, deferLoading: deferLoading,
                  cacheControl: cacheControl, allowedCallers: allowedCallers, eagerInputStreaming: eagerInputStreaming,
                  inputExamples: inputExamples, strict: strict, close: close, body: .lazy(enter))
    }

    /// The `tools[]` entry for this tool (`to_dict()`).
    public func toDict() -> BetaToolParam {
        BetaToolParam(inputSchema: .dictionary(inputSchema), name: name, allowedCallers: allowedCallers,
                      cacheControl: cacheControl.map { .some($0) }, deferLoading: deferLoading, description: description,
                      eagerInputStreaming: eagerInputStreaming.map { .some($0) }, inputExamples: inputExamples,
                      strict: strict)
    }

    public func toToolParam() throws -> JSONValue { try JSONValue.from(toDict()) }

    /// Runs the tool's function with `input` (`call`). A non-object input raises `ArgumentTypeError`.
    public func call(_ input: JSONValue) async throws -> BetaFunctionToolResult? {
        guard case .object(let object) = input else {
            throw ArgumentTypeError("Input must be a dictionary, got \(pythonTypeName(input))")
        }
        switch body {
        case .function(let f): return try await f(object)
        case .lazy(let enter):
            let f = try await state.entered(enter)
            return try await f(object)
        }
    }

    /// Runs the optional `close` hook and, for a context-manager tool that was entered, its exit
    /// (`aclose_runnable_tool`). Errors are logged, never raised.
    public func closeTool() async throws {
        if let onClose {
            do { try await onClose() } catch {
                toolsLog.warning("tool.close failed tool=\(name) error=\(error)")
            }
        }
        if let exit = await state.takeExit() {
            do { try await exit() } catch {
                toolsLog.warning("tool context-manager cleanup failed tool=\(name) error=\(error)")
            }
        }
    }
}

let toolsLog = ToolLogger(name: "anthropic.lib.tools._beta_functions")

private func typedFunction<Input: BetaToolDecodableInput>(name: String, _ f: @escaping @Sendable (Input) async throws -> BetaFunctionToolResult?)
    -> BetaFunctionTool.Function
{
    { input in
        let decoded: Input
        do { decoded = try JSONValue.object(input).decode(as: Input.self) } catch {
            throw ValueError("Invalid arguments for function \(name)")
        }
        return try await f(decoded)
    }
}

/// The context-manager state of a lazily entered tool.
private actor LazyEntry {
    private var function: BetaFunctionTool.Function?
    private var exit: (@Sendable () async throws -> Void)?
    private var entering: Task<BetaFunctionTool.Function, Error>?

    func entered(_ enter: @escaping @Sendable () async throws -> (BetaFunctionTool.Function, @Sendable () async throws -> Void))
        async throws -> BetaFunctionTool.Function
    {
        if let function { return function }
        if let entering { return try await entering.value }
        let task = Task { () async throws -> BetaFunctionTool.Function in
            let (f, e) = try await enter()
            self.store(f, e)
            return f
        }
        entering = task
        do {
            return try await task.value
        } catch {
            entering = nil
            throw error
        }
    }

    private func store(_ f: @escaping BetaFunctionTool.Function, _ e: @escaping @Sendable () async throws -> Void) {
        function = f
        exit = e
    }

    func takeExit() -> (@Sendable () async throws -> Void)? {
        let e = exit
        exit = nil
        return e
    }
}

/// Runs a runnable tool's optional cleanup (`aclose_runnable_tool`): never raises.
public func acloseRunnableTool(_ tool: any BetaRunnableTool) async {
    do { try await tool.closeTool() } catch {
        toolsLog.warning("tool.close failed tool=\(tool.name) error=\(error)")
    }
}

