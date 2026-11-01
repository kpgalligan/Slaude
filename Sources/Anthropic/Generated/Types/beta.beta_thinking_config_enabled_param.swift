// Transformed from `anthropic.types.beta.beta_thinking_config_enabled_param` (beta_thinking_config_enabled_param.py).

import Foundation

public struct BetaThinkingConfigEnabledParam: Codable, Hashable, Sendable {
    /// Determines how many tokens Claude can use for its internal reasoning process.
    ///
    /// Larger budgets can enable more thorough analysis for complex problems, improving
    /// response quality.
    ///
    /// Must be ≥1024 and less than `max_tokens`.
    ///
    /// See
    /// [extended thinking](https://platform.claude.com/docs/en/build-with-claude/extended-thinking)
    /// for details.
    public var budgetTokens: Int
    public var type: String
    /// Controls for block binding: what happens when a thinking block this request
    /// sends back fails the conversation check. `null`, absent or an empty object means
    /// every default.
    public var blockBinding: BetaThinkingBlockBindingParam??
    /// Controls how thinking content appears in the response.
    ///
    /// When set to `summarized`, thinking is returned normally. When set to `omitted`,
    /// thinking content is redacted but a signature is returned for multi-turn
    /// continuity. The default depends on the model; see
    /// [Controlling thinking display](https://platform.claude.com/docs/en/build-with-claude/thinking#controlling-thinking-display).
    public var display: Display??

    public init(budgetTokens: Int, type: String = "enabled", blockBinding: BetaThinkingBlockBindingParam?? = nil, display: Display?? = nil) {
        self.budgetTokens = budgetTokens
        self.type = type
        self.blockBinding = blockBinding
        self.display = display
    }

    enum CodingKeys: String, CodingKey {
        case budgetTokens = "budget_tokens"
        case type
        case blockBinding = "block_binding"
        case display
    }

    public enum Display: OpenEnum, CaseIterable {
        case summarized
        case omitted
        case updates
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Display] = [.summarized, .omitted, .updates]

        public init(rawValue: String) {
            switch rawValue {
            case "summarized": self = .summarized
            case "omitted": self = .omitted
            case "updates": self = .updates
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .summarized: return "summarized"
            case .omitted: return "omitted"
            case .updates: return "updates"
            case .unknown(let value): return value
            }
        }
    }
}
