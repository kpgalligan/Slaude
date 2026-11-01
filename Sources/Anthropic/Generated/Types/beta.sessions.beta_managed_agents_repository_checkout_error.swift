// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_repository_checkout_error` (beta_managed_agents_repository_checkout_error.py).

import Foundation

/// The requested branch or commit does not exist in the repository.
public struct BetaManagedAgentsRepositoryCheckoutError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    /// URL of the repository that could not be cloned.
    ///
    /// Null when it could not be identified.
    public var repositoryURL: String?
    /// What the client should do next.
    ///
    /// Always `retrying`: the session keeps running without the repository.
    public var retryStatus: BetaManagedAgentsRepositoryCheckoutError.RetryStatus
    public var type: String

    public init(message: String, repositoryURL: String? = nil, retryStatus: BetaManagedAgentsRepositoryCheckoutError.RetryStatus, type: String = "repository_checkout_error") {
        self.message = message
        self.repositoryURL = repositoryURL
        self.retryStatus = retryStatus
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case repositoryURL = "repository_url"
        case retryStatus = "retry_status"
        case type
    }
}

extension BetaManagedAgentsRepositoryCheckoutError {

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
