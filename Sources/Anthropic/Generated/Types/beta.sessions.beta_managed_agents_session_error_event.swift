// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_error_event` (beta_managed_agents_session_error_event.py).

import Foundation

/// An error event indicating a problem occurred during session execution.
public struct BetaManagedAgentsSessionErrorEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    public var error: BetaManagedAgentsSessionErrorEvent.Error
    /// Timestamp when the error occurred.
    public var processedAt: Date
    public var type: String

    public init(id: String, error: BetaManagedAgentsSessionErrorEvent.Error, processedAt: Date, type: String = "session.error") {
        self.id = id
        self.error = error
        self.processedAt = processedAt
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case error
        case processedAt = "processed_at"
        case type
    }
}

extension BetaManagedAgentsSessionErrorEvent {

    public indirect enum Error: Codable, Hashable, Sendable {
        case unknownError(BetaManagedAgentsUnknownError)
        case modelOverloadedError(BetaManagedAgentsModelOverloadedError)
        case modelRateLimitedError(BetaManagedAgentsModelRateLimitedError)
        case modelRequestFailedError(BetaManagedAgentsModelRequestFailedError)
        case mcpConnectionFailedError(BetaManagedAgentsMCPConnectionFailedError)
        case mcpAuthenticationFailedError(BetaManagedAgentsMCPAuthenticationFailedError)
        case billingError(BetaManagedAgentsBillingError)
        case credentialHostUnreachableError(BetaManagedAgentsCredentialHostUnreachableError)
        case repositoryAuthenticationError(BetaManagedAgentsRepositoryAuthenticationError)
        case repositoryForbiddenError(BetaManagedAgentsRepositoryForbiddenError)
        case repositoryNotFoundError(BetaManagedAgentsRepositoryNotFoundError)
        case repositoryCheckoutError(BetaManagedAgentsRepositoryCheckoutError)
        case repositoryCloneError(BetaManagedAgentsRepositoryCloneError)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "unknown_error": self = .unknownError(try BetaManagedAgentsUnknownError(from: decoder))
            case "model_overloaded_error": self = .modelOverloadedError(try BetaManagedAgentsModelOverloadedError(from: decoder))
            case "model_rate_limited_error": self = .modelRateLimitedError(try BetaManagedAgentsModelRateLimitedError(from: decoder))
            case "model_request_failed_error": self = .modelRequestFailedError(try BetaManagedAgentsModelRequestFailedError(from: decoder))
            case "mcp_connection_failed_error": self = .mcpConnectionFailedError(try BetaManagedAgentsMCPConnectionFailedError(from: decoder))
            case "mcp_authentication_failed_error": self = .mcpAuthenticationFailedError(try BetaManagedAgentsMCPAuthenticationFailedError(from: decoder))
            case "billing_error": self = .billingError(try BetaManagedAgentsBillingError(from: decoder))
            case "credential_host_unreachable_error": self = .credentialHostUnreachableError(try BetaManagedAgentsCredentialHostUnreachableError(from: decoder))
            case "repository_authentication_error": self = .repositoryAuthenticationError(try BetaManagedAgentsRepositoryAuthenticationError(from: decoder))
            case "repository_forbidden_error": self = .repositoryForbiddenError(try BetaManagedAgentsRepositoryForbiddenError(from: decoder))
            case "repository_not_found_error": self = .repositoryNotFoundError(try BetaManagedAgentsRepositoryNotFoundError(from: decoder))
            case "repository_checkout_error": self = .repositoryCheckoutError(try BetaManagedAgentsRepositoryCheckoutError(from: decoder))
            case "repository_clone_error": self = .repositoryCloneError(try BetaManagedAgentsRepositoryCloneError(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .unknownError(let v): try v.encode(to: encoder)
            case .modelOverloadedError(let v): try v.encode(to: encoder)
            case .modelRateLimitedError(let v): try v.encode(to: encoder)
            case .modelRequestFailedError(let v): try v.encode(to: encoder)
            case .mcpConnectionFailedError(let v): try v.encode(to: encoder)
            case .mcpAuthenticationFailedError(let v): try v.encode(to: encoder)
            case .billingError(let v): try v.encode(to: encoder)
            case .credentialHostUnreachableError(let v): try v.encode(to: encoder)
            case .repositoryAuthenticationError(let v): try v.encode(to: encoder)
            case .repositoryForbiddenError(let v): try v.encode(to: encoder)
            case .repositoryNotFoundError(let v): try v.encode(to: encoder)
            case .repositoryCheckoutError(let v): try v.encode(to: encoder)
            case .repositoryCloneError(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
