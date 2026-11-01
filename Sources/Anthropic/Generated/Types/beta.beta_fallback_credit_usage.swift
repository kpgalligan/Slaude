// Transformed from `anthropic.types.beta.beta_fallback_credit_usage` (beta_fallback_credit_usage.py).

import Foundation

/// Outcome of the ``fallback_credit_token`` presented on this request.
public struct BetaFallbackCreditUsage: Codable, Hashable, Sendable {
    /// Whether the fallback-credit reprice was applied to this response's billing.
    ///
    /// A union discriminated on `type`. `redeemed`: the retry is billed as if the
    /// conversation had been on the retry model all along — including when the
    /// resulting shift is zero because there was nothing to move. `not_applied`: no
    /// reprice was applied; the arm's `reason` says why.
    public var status: BetaFallbackCreditUsage.Status

    public init(status: BetaFallbackCreditUsage.Status) {
        self.status = status
    }

    enum CodingKeys: String, CodingKey {
        case status
    }
}

extension BetaFallbackCreditUsage {

    public indirect enum Status: Codable, Hashable, Sendable {
        case redeemed(BetaFallbackCreditRedeemed)
        case notApplied(BetaFallbackCreditNotApplied)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "redeemed": self = .redeemed(try BetaFallbackCreditRedeemed(from: decoder))
            case "not_applied": self = .notApplied(try BetaFallbackCreditNotApplied(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .redeemed(let v): try v.encode(to: encoder)
            case .notApplied(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
