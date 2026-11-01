// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_repository_clone_error` (beta_managed_agents_repository_clone_error.py).

import Foundation

/// The repository could not be cloned.
public struct BetaManagedAgentsRepositoryCloneError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    /// URL of the repository that could not be cloned.
    ///
    /// Null when it could not be identified.
    public var repositoryUrl: String?
    /// What the client should do next.
    ///
    /// Always `retrying`: the session keeps running without the repository.
    public var retryStatus: BetaManagedAgentsRepositoryCloneError.RetryStatus
    public var type: String

    public init(message: String, repositoryUrl: String? = nil, retryStatus: BetaManagedAgentsRepositoryCloneError.RetryStatus, type: String = "repository_clone_error") {
        self.message = message
        self.repositoryUrl = repositoryUrl
        self.retryStatus = retryStatus
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case repositoryUrl = "repository_url"
        case retryStatus = "retry_status"
        case type
    }
}

extension BetaManagedAgentsRepositoryCloneError {

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
