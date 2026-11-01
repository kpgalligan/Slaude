// Transformed from `anthropic.types.organization.workspaces.workspace_rate_limit_type` (workspace_rate_limit_type.py).

import Foundation

public enum WorkspaceRateLimitType: OpenEnum, CaseIterable {
    case fastItpmca
    case fastOtpm
    case inputTokensPerMinute
    case inputTokensPerMinuteCacheAware
    case outputTokensPerMinute
    case requestsPerMinute
    case tokensPerDay
    case tokensPerMinute
    case toolUsesPerSecond
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [WorkspaceRateLimitType] = [.fastItpmca, .fastOtpm, .inputTokensPerMinute, .inputTokensPerMinuteCacheAware, .outputTokensPerMinute, .requestsPerMinute, .tokensPerDay, .tokensPerMinute, .toolUsesPerSecond]

    public init(rawValue: String) {
        switch rawValue {
        case "fast_itpmca": self = .fastItpmca
        case "fast_otpm": self = .fastOtpm
        case "input_tokens_per_minute": self = .inputTokensPerMinute
        case "input_tokens_per_minute_cache_aware": self = .inputTokensPerMinuteCacheAware
        case "output_tokens_per_minute": self = .outputTokensPerMinute
        case "requests_per_minute": self = .requestsPerMinute
        case "tokens_per_day": self = .tokensPerDay
        case "tokens_per_minute": self = .tokensPerMinute
        case "tool_uses_per_second": self = .toolUsesPerSecond
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .fastItpmca: return "fast_itpmca"
        case .fastOtpm: return "fast_otpm"
        case .inputTokensPerMinute: return "input_tokens_per_minute"
        case .inputTokensPerMinuteCacheAware: return "input_tokens_per_minute_cache_aware"
        case .outputTokensPerMinute: return "output_tokens_per_minute"
        case .requestsPerMinute: return "requests_per_minute"
        case .tokensPerDay: return "tokens_per_day"
        case .tokensPerMinute: return "tokens_per_minute"
        case .toolUsesPerSecond: return "tool_uses_per_second"
        case .unknown(let value): return value
        }
    }
}
