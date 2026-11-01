// Transformed from `anthropic.types.beta.organization.beta_analytics_token_type` (beta_analytics_token_type.py).

import Foundation

public enum BetaAnalyticsTokenType: OpenEnum, CaseIterable {
    case cacheCreationEphemeral1hInputTokens
    case cacheCreationEphemeral5mInputTokens
    case cacheReadInputTokens
    case outputTokens
    case uncachedInputTokens
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAnalyticsTokenType] = [.cacheCreationEphemeral1hInputTokens, .cacheCreationEphemeral5mInputTokens, .cacheReadInputTokens, .outputTokens, .uncachedInputTokens]

    public init(rawValue: String) {
        switch rawValue {
        case "cache_creation.ephemeral_1h_input_tokens": self = .cacheCreationEphemeral1hInputTokens
        case "cache_creation.ephemeral_5m_input_tokens": self = .cacheCreationEphemeral5mInputTokens
        case "cache_read_input_tokens": self = .cacheReadInputTokens
        case "output_tokens": self = .outputTokens
        case "uncached_input_tokens": self = .uncachedInputTokens
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .cacheCreationEphemeral1hInputTokens: return "cache_creation.ephemeral_1h_input_tokens"
        case .cacheCreationEphemeral5mInputTokens: return "cache_creation.ephemeral_5m_input_tokens"
        case .cacheReadInputTokens: return "cache_read_input_tokens"
        case .outputTokens: return "output_tokens"
        case .uncachedInputTokens: return "uncached_input_tokens"
        case .unknown(let value): return value
        }
    }
}
