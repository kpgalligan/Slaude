// Transformed from `anthropic.types.beta.organization.analytics.beta_analytics_usage_group_by` (beta_analytics_usage_group_by.py).

import Foundation

public enum BetaAnalyticsUsageGroupBy: OpenEnum, CaseIterable {
    case actor
    case actorType
    case agentId
    case apiKeyId
    case claudeTagCategory
    case claudeTagUserId
    case contextWindow
    case deploymentId
    case environmentId
    case inferenceGeo
    case model
    case product
    case rbacGroupId
    case serviceTier
    case sessionId
    case slackChannelId
    case speed
    case userProfileId
    case workspaceId
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAnalyticsUsageGroupBy] = [.actor, .actorType, .agentId, .apiKeyId, .claudeTagCategory, .claudeTagUserId, .contextWindow, .deploymentId, .environmentId, .inferenceGeo, .model, .product, .rbacGroupId, .serviceTier, .sessionId, .slackChannelId, .speed, .userProfileId, .workspaceId]

    public init(rawValue: String) {
        switch rawValue {
        case "actor": self = .actor
        case "actor_type": self = .actorType
        case "agent_id": self = .agentId
        case "api_key_id": self = .apiKeyId
        case "claude_tag_category": self = .claudeTagCategory
        case "claude_tag_user_id": self = .claudeTagUserId
        case "context_window": self = .contextWindow
        case "deployment_id": self = .deploymentId
        case "environment_id": self = .environmentId
        case "inference_geo": self = .inferenceGeo
        case "model": self = .model
        case "product": self = .product
        case "rbac_group_id": self = .rbacGroupId
        case "service_tier": self = .serviceTier
        case "session_id": self = .sessionId
        case "slack_channel_id": self = .slackChannelId
        case "speed": self = .speed
        case "user_profile_id": self = .userProfileId
        case "workspace_id": self = .workspaceId
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .actor: return "actor"
        case .actorType: return "actor_type"
        case .agentId: return "agent_id"
        case .apiKeyId: return "api_key_id"
        case .claudeTagCategory: return "claude_tag_category"
        case .claudeTagUserId: return "claude_tag_user_id"
        case .contextWindow: return "context_window"
        case .deploymentId: return "deployment_id"
        case .environmentId: return "environment_id"
        case .inferenceGeo: return "inference_geo"
        case .model: return "model"
        case .product: return "product"
        case .rbacGroupId: return "rbac_group_id"
        case .serviceTier: return "service_tier"
        case .sessionId: return "session_id"
        case .slackChannelId: return "slack_channel_id"
        case .speed: return "speed"
        case .userProfileId: return "user_profile_id"
        case .workspaceId: return "workspace_id"
        case .unknown(let value): return value
        }
    }
}
