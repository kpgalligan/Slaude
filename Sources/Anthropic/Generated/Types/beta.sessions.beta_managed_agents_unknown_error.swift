// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_unknown_error` (beta_managed_agents_unknown_error.py).

import Foundation

/// An unknown or unexpected error occurred during session execution.
///
/// A fallback variant; clients that don't recognize a new error code can match on `retry_status` and `message` alone.
public struct BetaManagedAgentsUnknownError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    /// What the client should do next.
    public var retryStatus: BetaManagedAgentsUnknownError.RetryStatus
    public var type: String

    public init(message: String, retryStatus: BetaManagedAgentsUnknownError.RetryStatus, type: String = "unknown_error") {
        self.message = message
        self.retryStatus = retryStatus
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case retryStatus = "retry_status"
        case type
    }
}

extension BetaManagedAgentsUnknownError {

    public indirect enum RetryStatus: Codable, Hashable, Sendable {
        case retrying(BetaManagedAgentsRetryStatusRetrying)
        case exhausted(BetaManagedAgentsRetryStatusExhausted)
        case terminal(BetaManagedAgentsRetryStatusTerminal)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "retrying": self = .retrying(try BetaManagedAgentsRetryStatusRetrying(from: decoder))
            case "exhausted": self = .exhausted(try BetaManagedAgentsRetryStatusExhausted(from: decoder))
            case "terminal": self = .terminal(try BetaManagedAgentsRetryStatusTerminal(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .retrying(let v): try v.encode(to: encoder)
            case .exhausted(let v): try v.encode(to: encoder)
            case .terminal(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
