// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_credential_host_unreachable_error` (beta_managed_agents_credential_host_unreachable_error.py).

import Foundation

/// An `environment_variable` credential's `auth.networking.allowed_hosts` includes a host the environment's network policy does not permit.
public struct BetaManagedAgentsCredentialHostUnreachableError: Codable, Hashable, Sendable {
    /// ID of the affected credential.
    public var credentialID: String
    /// Human-readable error description.
    public var message: String
    /// What the client should do next.
    public var retryStatus: BetaManagedAgentsCredentialHostUnreachableError.RetryStatus
    public var type: String
    /// ID of the vault containing the affected credential.
    public var vaultID: String

    public init(credentialID: String, message: String, retryStatus: BetaManagedAgentsCredentialHostUnreachableError.RetryStatus, type: String = "credential_host_unreachable_error", vaultID: String) {
        self.credentialID = credentialID
        self.message = message
        self.retryStatus = retryStatus
        self.type = type
        self.vaultID = vaultID
    }

    enum CodingKeys: String, CodingKey {
        case credentialID = "credential_id"
        case message
        case retryStatus = "retry_status"
        case type
        case vaultID = "vault_id"
    }
}

extension BetaManagedAgentsCredentialHostUnreachableError {

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
