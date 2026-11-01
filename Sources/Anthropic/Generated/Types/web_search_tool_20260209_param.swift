// Transformed from `anthropic.types.web_search_tool_20260209_param` (web_search_tool_20260209_param.py).

import Foundation

public struct WebSearchTool20260209Param: Codable, Hashable, Sendable {
    /// Name of the tool.
    ///
    /// This is how the tool will be called by the model and in `tool_use` blocks.
    public var name: String
    public var type: String
    public var allowedCallers: [AllowedCallers]?
    /// If provided, only these domains will be included in results.
    ///
    /// Cannot be used alongside `blocked_domains`.
    public var allowedDomains: [String]??
    /// If provided, these domains will never appear in results.
    ///
    /// Cannot be used alongside `allowed_domains`.
    public var blockedDomains: [String]??
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??
    /// If true, tool will not be included in initial system prompt.
    ///
    /// Only loaded when returned via tool_reference from tool search.
    public var deferLoading: Bool?
    /// Maximum number of times the tool can be used in the API request.
    public var maxUses: Int??
    /// When true, guarantees schema validation on tool names and inputs
    public var strict: Bool?
    /// Parameters for the user's location.
    ///
    /// Used to provide more relevant search results.
    public var userLocation: UserLocationParam??

    public init(name: String = "web_search", type: String = "web_search_20260209", allowedCallers: [AllowedCallers]? = nil, allowedDomains: [String]?? = nil, blockedDomains: [String]?? = nil, cacheControl: CacheControlEphemeralParam?? = nil, deferLoading: Bool? = nil, maxUses: Int?? = nil, strict: Bool? = nil, userLocation: UserLocationParam?? = nil) {
        self.name = name
        self.type = type
        self.allowedCallers = allowedCallers
        self.allowedDomains = allowedDomains
        self.blockedDomains = blockedDomains
        self.cacheControl = cacheControl
        self.deferLoading = deferLoading
        self.maxUses = maxUses
        self.strict = strict
        self.userLocation = userLocation
    }

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case allowedCallers = "allowed_callers"
        case allowedDomains = "allowed_domains"
        case blockedDomains = "blocked_domains"
        case cacheControl = "cache_control"
        case deferLoading = "defer_loading"
        case maxUses = "max_uses"
        case strict
        case userLocation = "user_location"
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

extension WebSearchTool20260209Param {

    public typealias UserLocation = UserLocationParam
}
