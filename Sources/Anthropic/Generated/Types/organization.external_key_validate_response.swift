// Transformed from `anthropic.types.organization.external_key_validate_response` (external_key_validate_response.py).

import Foundation

/// Result of a validation roundtrip against the customer's KMS.
///
/// HTTP 200 for both outcomes — the operation completed; `status` says
/// whether the key works.
public struct ExternalKeyValidateResponse: Codable, Hashable, Sendable {
    /// Error message when status is `failure`. Null otherwise.
    public var error: String?
    /// `success` — encrypt/decrypt roundtrip succeeded.
    ///
    /// `failure` — the roundtrip failed or timed out; see `error`.
    public var status: Status
    public var type: String

    public init(error: String? = nil, status: Status, type: String = "external_key_validation") {
        self.error = error
        self.status = status
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case error
        case status
        case type
    }

    public enum Status: OpenEnum, CaseIterable {
        case failure
        case success
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Status] = [.failure, .success]

        public init(rawValue: String) {
            switch rawValue {
            case "failure": self = .failure
            case "success": self = .success
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .failure: return "failure"
            case .success: return "success"
            case .unknown(let value): return value
            }
        }
    }
}
