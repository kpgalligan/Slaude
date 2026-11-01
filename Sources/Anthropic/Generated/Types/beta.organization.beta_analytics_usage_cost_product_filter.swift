// Transformed from `anthropic.types.beta.organization.beta_analytics_usage_cost_product_filter` (beta_analytics_usage_cost_product_filter.py).

import Foundation

public enum BetaAnalyticsUsageCostProductFilter: OpenEnum, CaseIterable {
    case chat
    case chatCoworkUnified
    case claudeCode
    case claudeConsole
    case claudeDesign
    case claudeInChrome
    case claudeTag
    case cowork
    case managedAgentsApi
    case messageBatchesApi
    case messagesApi
    case officeAgent
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAnalyticsUsageCostProductFilter] = [.chat, .chatCoworkUnified, .claudeCode, .claudeConsole, .claudeDesign, .claudeInChrome, .claudeTag, .cowork, .managedAgentsApi, .messageBatchesApi, .messagesApi, .officeAgent]

    public init(rawValue: String) {
        switch rawValue {
        case "chat": self = .chat
        case "chat_cowork_unified": self = .chatCoworkUnified
        case "claude_code": self = .claudeCode
        case "claude_console": self = .claudeConsole
        case "claude_design": self = .claudeDesign
        case "claude_in_chrome": self = .claudeInChrome
        case "claude_tag": self = .claudeTag
        case "cowork": self = .cowork
        case "managed_agents_api": self = .managedAgentsApi
        case "message_batches_api": self = .messageBatchesApi
        case "messages_api": self = .messagesApi
        case "office_agent": self = .officeAgent
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .chat: return "chat"
        case .chatCoworkUnified: return "chat_cowork_unified"
        case .claudeCode: return "claude_code"
        case .claudeConsole: return "claude_console"
        case .claudeDesign: return "claude_design"
        case .claudeInChrome: return "claude_in_chrome"
        case .claudeTag: return "claude_tag"
        case .cowork: return "cowork"
        case .managedAgentsApi: return "managed_agents_api"
        case .messageBatchesApi: return "message_batches_api"
        case .messagesApi: return "messages_api"
        case .officeAgent: return "office_agent"
        case .unknown(let value): return value
        }
    }
}
