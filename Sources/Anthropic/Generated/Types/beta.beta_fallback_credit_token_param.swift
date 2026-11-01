// Transformed from `anthropic.types.beta.beta_fallback_credit_token_param` (beta_fallback_credit_token_param.py).

import Foundation

/// Object form of ``fallback_credit_token``: the token plus a redemption
/// mode.
///
/// Requires ``anthropic-beta: fallback-credit-2026-07-01``; without that
/// header the field accepts the bare string only. The bare string and the
/// mode-less object are equivalent (both select ``strict``), so wrapping
/// an existing token changes nothing by itself.
public struct BetaFallbackCreditTokenParam: Codable, Hashable, Sendable {
    /// The opaque `fallback_credit_token` from a prior refusal's `stop_details` — the
    /// same string the bare-string form carries.
    public var token: String
    /// How a failing token affects the retry.
    ///
    /// `strict` (the default, and the bare-string behavior): a failing redemption is a
    /// 400 and the retry is not served. `best_effort`: the retry is served either way —
    /// a token-layer failure no longer rejects the request; the retry proceeds at
    /// normal price and the outcome is reported on the response's
    /// `usage.fallback_credit`. Two failures stay hard in both modes: a malformed
    /// token, and combining `fallback_credit_token` with `fallbacks`.
    public var mode: Mode?

    public init(token: String, mode: Mode? = nil) {
        self.token = token
        self.mode = mode
    }

    enum CodingKeys: String, CodingKey {
        case token
        case mode
    }

    public enum Mode: OpenEnum, CaseIterable {
        case strict
        case bestEffort
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Mode] = [.strict, .bestEffort]

        public init(rawValue: String) {
            switch rawValue {
            case "strict": self = .strict
            case "best_effort": self = .bestEffort
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .strict: return "strict"
            case .bestEffort: return "best_effort"
            case .unknown(let value): return value
            }
        }
    }
}
