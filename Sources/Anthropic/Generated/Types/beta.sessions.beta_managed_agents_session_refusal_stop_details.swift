// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_refusal_stop_details` (beta_managed_agents_session_refusal_stop_details.py).

import Foundation

/// Structured information about a refusal.
public struct BetaManagedAgentsSessionRefusalStopDetails: Codable, Hashable, Sendable {
    /// The policy category that triggered the refusal, or `null` when there is no named
    /// category. New values can be added over time.
    public var category: Category?
    /// Human-readable explanation of the refusal, or `null` when none is available.
    ///
    /// The wording can change, so do not parse it.
    public var explanation: String?
    public var type: String

    public init(category: Category? = nil, explanation: String? = nil, type: String = "refusal") {
        self.category = category
        self.explanation = explanation
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case category
        case explanation
        case type
    }

    public enum Category: OpenEnum, CaseIterable {
        case cyber
        case bio
        case frontierLlm
        case reasoningExtraction
        case generalHarms
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Category] = [.cyber, .bio, .frontierLlm, .reasoningExtraction, .generalHarms]

        public init(rawValue: String) {
            switch rawValue {
            case "cyber": self = .cyber
            case "bio": self = .bio
            case "frontier_llm": self = .frontierLlm
            case "reasoning_extraction": self = .reasoningExtraction
            case "general_harms": self = .generalHarms
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .cyber: return "cyber"
            case .bio: return "bio"
            case .frontierLlm: return "frontier_llm"
            case .reasoningExtraction: return "reasoning_extraction"
            case .generalHarms: return "general_harms"
            case .unknown(let value): return value
            }
        }
    }
}
