// Transformed from `anthropic.types.beta.beta_advisor_redacted_result_block` (beta_advisor_redacted_result_block.py).

import Foundation

public struct BetaAdvisorRedactedResultBlock: Codable, Hashable, Sendable {
    /// Opaque blob containing the advisor's output.
    ///
    /// Round-trip verbatim; do not inspect or modify.
    public var encryptedContent: String
    /// The advisor sub-inference's stop reason (same values as the top-level message
    /// `stop_reason`).
    public var stopReason: String?
    public var type: String

    public init(encryptedContent: String, stopReason: String? = nil, type: String = "advisor_redacted_result") {
        self.encryptedContent = encryptedContent
        self.stopReason = stopReason
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case encryptedContent = "encrypted_content"
        case stopReason = "stop_reason"
        case type
    }
}
