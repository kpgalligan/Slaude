// Transformed from `anthropic.types.beta.organization.beta_analytics_product_filter` (beta_analytics_product_filter.py).

import Foundation

public enum BetaAnalyticsProductFilter: OpenEnum, CaseIterable {
    case chat
    case chatCoworkUnified
    case claudeTag
    case claudeCode
    case claudeDesign
    case claudeInChrome
    case cowork
    case officeAgent
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAnalyticsProductFilter] = [.chat, .chatCoworkUnified, .claudeTag, .claudeCode, .claudeDesign, .claudeInChrome, .cowork, .officeAgent]

    public init(rawValue: String) {
        switch rawValue {
        case "chat": self = .chat
        case "chat_cowork_unified": self = .chatCoworkUnified
        case "claude-tag": self = .claudeTag
        case "claude_code": self = .claudeCode
        case "claude_design": self = .claudeDesign
        case "claude_in_chrome": self = .claudeInChrome
        case "cowork": self = .cowork
        case "office_agent": self = .officeAgent
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .chat: return "chat"
        case .chatCoworkUnified: return "chat_cowork_unified"
        case .claudeTag: return "claude-tag"
        case .claudeCode: return "claude_code"
        case .claudeDesign: return "claude_design"
        case .claudeInChrome: return "claude_in_chrome"
        case .cowork: return "cowork"
        case .officeAgent: return "office_agent"
        case .unknown(let value): return value
        }
    }
}
