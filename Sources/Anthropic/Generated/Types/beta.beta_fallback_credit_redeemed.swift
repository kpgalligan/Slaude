// Transformed from `anthropic.types.beta.beta_fallback_credit_redeemed` (beta_fallback_credit_redeemed.py).

import Foundation

/// The reprice was applied: the retry is billed as if the conversation
/// had been on the retry model all along.
public struct BetaFallbackCreditRedeemed: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "redeemed") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
