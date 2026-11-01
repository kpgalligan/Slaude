// Transformed from `anthropic.types.beta.beta_web_search_tool_20260318_param` (beta_web_search_tool_20260318_param.py).

import Foundation

public struct BetaWebSearchTool20260318Param: Codable, Hashable, Sendable {
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
    public var cacheControl: BetaCacheControlEphemeralParam??
    /// If true, tool will not be included in initial system prompt.
    ///
    /// Only loaded when returned via tool_reference from tool search.
    public var deferLoading: Bool?
    /// Maximum number of times the tool can be used in the API request.
    public var maxUses: Int??
    /// How this tool's result blocks appear in the API response when the result was
    /// consumed by a completed code_execution call in the same turn. 'full' returns the
    /// complete content (default). 'excluded' drops the nested server_tool_use and
    /// result block pair entirely. Results from direct calls, or from code_execution
    /// calls that paused before completing, are always returned in full so they can be
    /// sent back on the next turn.
    public var responseInclusion: ResponseInclusion?
    /// When true, guarantees schema validation on tool names and inputs
    public var strict: Bool?
    /// Parameters for the user's location.
    ///
    /// Used to provide more relevant search results.
    public var userLocation: BetaUserLocationParam??

    public init(name: String = "web_search", type: String = "web_search_20260318", allowedCallers: [AllowedCallers]? = nil, allowedDomains: [String]?? = nil, blockedDomains: [String]?? = nil, cacheControl: BetaCacheControlEphemeralParam?? = nil, deferLoading: Bool? = nil, maxUses: Int?? = nil, responseInclusion: ResponseInclusion? = nil, strict: Bool? = nil, userLocation: BetaUserLocationParam?? = nil) {
        self.name = name
        self.type = type
        self.allowedCallers = allowedCallers
        self.allowedDomains = allowedDomains
        self.blockedDomains = blockedDomains
        self.cacheControl = cacheControl
        self.deferLoading = deferLoading
        self.maxUses = maxUses
        self.responseInclusion = responseInclusion
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
        case responseInclusion = "response_inclusion"
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

    public enum ResponseInclusion: OpenEnum, CaseIterable {
        case full
        case excluded
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [ResponseInclusion] = [.full, .excluded]

        public init(rawValue: String) {
            switch rawValue {
            case "full": self = .full
            case "excluded": self = .excluded
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .full: return "full"
            case .excluded: return "excluded"
            case .unknown(let value): return value
            }
        }
    }
}
