// Transformed from `anthropic.types.beta.beta_advisor_tool_20260301_param` (beta_advisor_tool_20260301_param.py).

import Foundation

public struct BetaAdvisorTool20260301Param: Codable, Hashable, Sendable {
    /// The model that will complete your prompt.
    ///
    /// See [models](https://docs.anthropic.com/en/docs/models-overview) for additional
    /// details and options.
    public var model: ModelParam
    /// Name of the tool.
    ///
    /// This is how the tool will be called by the model and in `tool_use` blocks.
    public var name: String
    public var type: String
    public var allowedCallers: [AllowedCallers]?
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??
    /// Caching for the advisor's own prompt.
    ///
    /// When set, each advisor call writes a cache entry at the given TTL so subsequent
    /// calls in the same conversation read the stable prefix. When omitted, the advisor
    /// prompt is not cached.
    public var caching: BetaCacheControlEphemeralParam??
    /// If true, tool will not be included in initial system prompt.
    ///
    /// Only loaded when returned via tool_reference from tool search.
    public var deferLoading: Bool?
    /// Bounds the advisor's total output (thinking + text) per call.
    ///
    /// When the advisor hits this cap, the returned advisor_result or
    /// advisor_redacted_result block carries stop_reason='max_tokens', and a truncation
    /// note is appended to the advice text the worker model sees (inside the encrypted
    /// blob in redacted mode). When set, the server also emits a remaining-tokens
    /// budget block in the advisor's prompt so the advisor self-shapes toward the cap.
    /// When omitted, the advisor model's default output cap applies and no budget block
    /// is emitted.
    public var maxTokens: Int??
    /// Maximum number of times the tool can be used in the API request.
    public var maxUses: Int??
    /// When true, guarantees schema validation on tool names and inputs
    public var strict: Bool?

    public init(model: ModelParam, name: String = "advisor", type: String = "advisor_20260301", allowedCallers: [AllowedCallers]? = nil, cacheControl: BetaCacheControlEphemeralParam?? = nil, caching: BetaCacheControlEphemeralParam?? = nil, deferLoading: Bool? = nil, maxTokens: Int?? = nil, maxUses: Int?? = nil, strict: Bool? = nil) {
        self.model = model
        self.name = name
        self.type = type
        self.allowedCallers = allowedCallers
        self.cacheControl = cacheControl
        self.caching = caching
        self.deferLoading = deferLoading
        self.maxTokens = maxTokens
        self.maxUses = maxUses
        self.strict = strict
    }

    enum CodingKeys: String, CodingKey {
        case model
        case name
        case type
        case allowedCallers = "allowed_callers"
        case cacheControl = "cache_control"
        case caching
        case deferLoading = "defer_loading"
        case maxTokens = "max_tokens"
        case maxUses = "max_uses"
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
