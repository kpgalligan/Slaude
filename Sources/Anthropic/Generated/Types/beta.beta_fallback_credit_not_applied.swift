// Transformed from `anthropic.types.beta.beta_fallback_credit_not_applied` (beta_fallback_credit_not_applied.py).

import Foundation

/// No reprice was applied; ``reason`` says why.
public struct BetaFallbackCreditNotApplied: Codable, Hashable, Sendable {
    /// Why the reprice was not applied.
    ///
    /// A closed enum; additions to the redemption-check vocabulary arrive as deliberate
    /// schema updates.
    public var reason: Reason
    public var type: String
    /// Request fields to remove before retrying, so the retry can redeem this token.
    ///
    /// Present exactly when `reason` is `variant_fields_present` — never null, never an
    /// empty array; absent otherwise. Fields are named only from your own request, and
    /// only after the sealed variant hash matched. A served best-effort retry has
    /// already been billed at normal price; nothing redeems retroactively, but a
    /// corrected re-send inside the token's five-minute window can still redeem.
    public var removeToRedeem: [String]?

    public init(reason: Reason, type: String = "not_applied", removeToRedeem: [String]? = nil) {
        self.reason = reason
        self.type = type
        self.removeToRedeem = removeToRedeem
    }

    enum CodingKeys: String, CodingKey {
        case reason
        case type
        case removeToRedeem = "remove_to_redeem"
    }

    public enum Reason: OpenEnum, CaseIterable {
        case bodyMismatch
        case continuationExcluded
        case continuationOnly
        case expired
        case invalidTargetModel
        case notEnabled
        case repriceUnavailable
        case temporarilyUnavailable
        case variantFieldsPresent
        case wrongOrganization
        case wrongPlatform
        case wrongWorkspace
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Reason] = [.bodyMismatch, .continuationExcluded, .continuationOnly, .expired, .invalidTargetModel, .notEnabled, .repriceUnavailable, .temporarilyUnavailable, .variantFieldsPresent, .wrongOrganization, .wrongPlatform, .wrongWorkspace]

        public init(rawValue: String) {
            switch rawValue {
            case "body_mismatch": self = .bodyMismatch
            case "continuation_excluded": self = .continuationExcluded
            case "continuation_only": self = .continuationOnly
            case "expired": self = .expired
            case "invalid_target_model": self = .invalidTargetModel
            case "not_enabled": self = .notEnabled
            case "reprice_unavailable": self = .repriceUnavailable
            case "temporarily_unavailable": self = .temporarilyUnavailable
            case "variant_fields_present": self = .variantFieldsPresent
            case "wrong_organization": self = .wrongOrganization
            case "wrong_platform": self = .wrongPlatform
            case "wrong_workspace": self = .wrongWorkspace
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .bodyMismatch: return "body_mismatch"
            case .continuationExcluded: return "continuation_excluded"
            case .continuationOnly: return "continuation_only"
            case .expired: return "expired"
            case .invalidTargetModel: return "invalid_target_model"
            case .notEnabled: return "not_enabled"
            case .repriceUnavailable: return "reprice_unavailable"
            case .temporarilyUnavailable: return "temporarily_unavailable"
            case .variantFieldsPresent: return "variant_fields_present"
            case .wrongOrganization: return "wrong_organization"
            case .wrongPlatform: return "wrong_platform"
            case .wrongWorkspace: return "wrong_workspace"
            case .unknown(let value): return value
            }
        }
    }
}
