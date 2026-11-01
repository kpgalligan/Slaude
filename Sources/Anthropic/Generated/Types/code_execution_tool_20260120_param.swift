// Transformed from `anthropic.types.code_execution_tool_20260120_param` (code_execution_tool_20260120_param.py).

import Foundation

/// A `tools` entry for the code execution tool, version `code_execution_20260120`.
///
/// It adds REPL state persistence to version `code_execution_20250825`.
///
/// REPL state persistence applies with programmatic tool calling. With it, the Python interpreter state, such as variable bindings, persists across requests that reuse the container.
///
/// See the [code execution tool guide](https://platform.claude.com/docs/en/agents-and-tools/tool-use/code-execution-tool#tool-versions) to learn what each tool version adds.
public struct CodeExecutionTool20260120Param: Codable, Hashable, Sendable {
    /// Name of the tool.
    ///
    /// This is how the tool will be called by the model and in `tool_use` blocks.
    public var name: String
    public var type: String
    public var allowedCallers: [AllowedCallers]?
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??
    /// If true, tool will not be included in initial system prompt.
    ///
    /// Only loaded when returned via tool_reference from tool search.
    public var deferLoading: Bool?
    /// When true, guarantees schema validation on tool names and inputs
    public var strict: Bool?

    public init(name: String = "code_execution", type: String = "code_execution_20260120", allowedCallers: [AllowedCallers]? = nil, cacheControl: CacheControlEphemeralParam?? = nil, deferLoading: Bool? = nil, strict: Bool? = nil) {
        self.name = name
        self.type = type
        self.allowedCallers = allowedCallers
        self.cacheControl = cacheControl
        self.deferLoading = deferLoading
        self.strict = strict
    }

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case allowedCallers = "allowed_callers"
        case cacheControl = "cache_control"
        case deferLoading = "defer_loading"
        case strict
    }

    public enum AllowedCallers: OpenEnum, CaseIterable {
        case direct
        case codeExecution20250825
        case codeExecution20260120
        case codeExecution20260521
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [AllowedCallers] = [.direct, .codeExecution20250825, .codeExecution20260120, .codeExecution20260521]

        public init(rawValue: String) {
            switch rawValue {
            case "direct": self = .direct
            case "code_execution_20250825": self = .codeExecution20250825
            case "code_execution_20260120": self = .codeExecution20260120
            case "code_execution_20260521": self = .codeExecution20260521
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .direct: return "direct"
            case .codeExecution20250825: return "code_execution_20250825"
            case .codeExecution20260120: return "code_execution_20260120"
            case .codeExecution20260521: return "code_execution_20260521"
            case .unknown(let value): return value
            }
        }
    }
}
