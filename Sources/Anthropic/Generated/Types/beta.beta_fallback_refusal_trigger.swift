// Transformed from `anthropic.types.beta.beta_fallback_refusal_trigger` (beta_fallback_refusal_trigger.py).

import Foundation

/// The `from` model declined for policy reasons.
public struct BetaFallbackRefusalTrigger: Codable, Hashable, Sendable {
    /// The policy category that triggered the `from` model's refusal at this hop.
    ///
    /// `null` when the refusal doesn't map to a named category. Same vocabulary as
    /// `stop_details.category`.
    ///
    /// - `cyber` - The request could enable cyber harm, such as malware or exploit
    ///   development. Benign cybersecurity work can also trigger this category.
    /// - `bio` - The request could enable biological harm, such as dangerous lab
    ///   methods. Beneficial life sciences work can also trigger this category.
    /// - `frontier_llm` - The request could assist the development of competing AI
    ///   models, which is restricted under
    ///   [Anthropic's commercial terms](https://www.anthropic.com/legal/commercial-terms).
    ///   Benign machine learning work can also trigger this category.
    /// - `reasoning_extraction` - The request asks the model to reproduce its internal
    ///   reasoning in the response text. To get reasoning in a structured form instead,
    ///   use
    ///   [adaptive thinking](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking).
    /// - `general_harms` - The request could be related to an area that was determined
    ///   as harmful. Benign work might sometimes trigger this category.
    public var category: Category?
    public var type: String

    public init(category: Category? = nil, type: String = "refusal") {
        self.category = category
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case category
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
