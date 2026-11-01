// Transformed from `anthropic.types.beta.beta_web_fetch_tool_20260309` (beta_web_fetch_tool_20260309.py).

import Foundation

/// Web fetch tool with use_cache parameter for bypassing cached content.
public struct BetaWebFetchTool20260309: Codable, Hashable, Sendable {
    /// Name of the tool.
    ///
    /// This is how the tool will be called by the model and in `tool_use` blocks.
    public var name: String
    public var type: String
    public var allowedCallers: [AllowedCallers]?
    /// List of domains to allow fetching from
    public var allowedDomains: [String]?
    /// List of domains to block fetching from
    public var blockedDomains: [String]?
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeral?
    /// Citations configuration for fetched documents.
    ///
    /// Citations are disabled by default.
    public var citations: BetaCitationsConfigParam?
    /// If true, tool will not be included in initial system prompt.
    ///
    /// Only loaded when returned via tool_reference from tool search.
    public var deferLoading: Bool?
    /// Maximum number of tokens used by including web page text content in the context.
    ///
    /// The limit is approximate and does not apply to binary content such as PDFs.
    public var maxContentTokens: Int?
    /// Maximum number of times the tool can be used in the API request.
    public var maxUses: Int?
    /// When true, guarantees schema validation on tool names and inputs
    public var strict: Bool?
    /// Which sources contribute to the set of URLs the tool may fetch.
    ///
    /// Omitted means every source.
    public var urlSources: BetaWebFetchURLSources?
    /// Whether to use cached content.
    ///
    /// Set to false to bypass the cache and fetch fresh content. Only set to false when
    /// the user explicitly requests fresh content or when fetching rapidly-changing
    /// sources.
    public var useCache: Bool?

    public init(name: String = "web_fetch", type: String = "web_fetch_20260309", allowedCallers: [AllowedCallers]? = nil, allowedDomains: [String]? = nil, blockedDomains: [String]? = nil, cacheControl: BetaCacheControlEphemeral? = nil, citations: BetaCitationsConfigParam? = nil, deferLoading: Bool? = nil, maxContentTokens: Int? = nil, maxUses: Int? = nil, strict: Bool? = nil, urlSources: BetaWebFetchURLSources? = nil, useCache: Bool? = nil) {
        self.name = name
        self.type = type
        self.allowedCallers = allowedCallers
        self.allowedDomains = allowedDomains
        self.blockedDomains = blockedDomains
        self.cacheControl = cacheControl
        self.citations = citations
        self.deferLoading = deferLoading
        self.maxContentTokens = maxContentTokens
        self.maxUses = maxUses
        self.strict = strict
        self.urlSources = urlSources
        self.useCache = useCache
    }

    enum CodingKeys: String, CodingKey {
        case name
        case type
        case allowedCallers = "allowed_callers"
        case allowedDomains = "allowed_domains"
        case blockedDomains = "blocked_domains"
        case cacheControl = "cache_control"
        case citations
        case deferLoading = "defer_loading"
        case maxContentTokens = "max_content_tokens"
        case maxUses = "max_uses"
        case strict
        case urlSources = "url_sources"
        case useCache = "use_cache"
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
