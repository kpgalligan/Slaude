// Transformed from `anthropic.types.beta.beta_tool_text_editor_20241022` (beta_tool_text_editor_20241022.py).

import Foundation

public struct BetaToolTextEditor20241022: Codable, Hashable, Sendable {
    /// Name of the tool.
    ///
    /// This is how the tool will be called by the model and in `tool_use` blocks.
    public var name: String
    public var type: String
    public var allowedCallers: [AllowedCallers]?
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeral?
    /// If true, tool will not be included in initial system prompt.
    ///
    /// Only loaded when returned via tool_reference from tool search.
    public var deferLoading: Bool?
    public var inputExamples: [[String: JSONValue]]?
    /// When true, guarantees schema validation on tool names and inputs
    public var strict: Bool?

    public init(name: String = "str_replace_editor", type: String = "text_editor_20241022", allowedCallers: [AllowedCallers]? = nil, cacheControl: BetaCacheControlEphemeral? = nil, deferLoading: Bool? = nil, inputExamples: [[String: JSONValue]]? = nil, strict: Bool? = nil) {
        self.name = name
        self.type = type
        self.allowedCallers = allowedCallers
        self.cacheControl = cacheControl
        self.deferLoading = deferLoading
        self.inputExamples = inputExamples
        self.strict = strict
    }

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case allowedCallers = "allowed_callers"
        case cacheControl = "cache_control"
        case deferLoading = "defer_loading"
        case inputExamples = "input_examples"
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
