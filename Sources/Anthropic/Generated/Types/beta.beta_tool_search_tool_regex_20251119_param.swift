// Transformed from `anthropic.types.beta.beta_tool_search_tool_regex_20251119_param` (beta_tool_search_tool_regex_20251119_param.py).

import Foundation

public struct BetaToolSearchToolRegex20251119Param: Codable, Hashable, Sendable {
    /// Name of the tool.
    ///
    /// This is how the tool will be called by the model and in `tool_use` blocks.
    public var name: String
    public var type: TypeValue
    public var allowedCallers: [AllowedCallers]?
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??
    /// If true, tool will not be included in initial system prompt.
    ///
    /// Only loaded when returned via tool_reference from tool search.
    public var deferLoading: Bool?
    /// When true, guarantees schema validation on tool names and inputs
    public var strict: Bool?

    public init(name: String = "tool_search_tool_regex", type: TypeValue, allowedCallers: [AllowedCallers]? = nil, cacheControl: BetaCacheControlEphemeralParam?? = nil, deferLoading: Bool? = nil, strict: Bool? = nil) {
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

    public enum TypeValue: OpenEnum, CaseIterable {
        case toolSearchToolRegex20251119
        case toolSearchToolRegex
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [TypeValue] = [.toolSearchToolRegex20251119, .toolSearchToolRegex]

        public init(rawValue: String) {
            switch rawValue {
            case "tool_search_tool_regex_20251119": self = .toolSearchToolRegex20251119
            case "tool_search_tool_regex": self = .toolSearchToolRegex
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .toolSearchToolRegex20251119: return "tool_search_tool_regex_20251119"
            case .toolSearchToolRegex: return "tool_search_tool_regex"
            case .unknown(let value): return value
            }
        }
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
