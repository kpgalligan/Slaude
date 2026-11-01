// Transformed from `anthropic.types.beta.beta_advisor_redacted_result_block_param` (beta_advisor_redacted_result_block_param.py).

import Foundation

public struct BetaAdvisorRedactedResultBlockParam: Codable, Hashable, Sendable {
    /// Opaque blob produced by a prior response; must be round-tripped verbatim.
    public var encryptedContent: String
    public var type: String
    public var stopReason: String??

    public init(encryptedContent: String, type: String = "advisor_redacted_result", stopReason: String?? = nil) {
        self.encryptedContent = encryptedContent
        self.type = type
        self.stopReason = stopReason
    }

    enum CodingKeys: String, CodingKey {
        case encryptedContent = "encrypted_content"
        case type
        case stopReason = "stop_reason"
    }
}
