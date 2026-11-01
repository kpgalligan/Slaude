// Transformed from `anthropic.types.beta.beta_advisor_result_block` (beta_advisor_result_block.py).

import Foundation

public struct BetaAdvisorResultBlock: Codable, Hashable, Sendable {
    /// The advisor sub-inference's stop reason (same values as the top-level message
    /// `stop_reason`). `max_tokens` indicates the advisor's output was truncated at the
    /// tool's `max_tokens` value or the advisor model's policy cap.
    public var stopReason: String?
    public var text: String
    public var type: String

    public init(stopReason: String? = nil, text: String, type: String = "advisor_result") {
        self.stopReason = stopReason
        self.text = text
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case stopReason = "stop_reason"
        case text
        case type
    }
}
