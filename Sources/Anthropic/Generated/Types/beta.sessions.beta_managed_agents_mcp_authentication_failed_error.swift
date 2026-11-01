// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_mcp_authentication_failed_error` (beta_managed_agents_mcp_authentication_failed_error.py).

import Foundation

/// Authentication to an MCP server failed.
public struct BetaManagedAgentsMCPAuthenticationFailedError: Codable, Hashable, Sendable {
    /// Name of the MCP server that failed authentication.
    public var mcpServerName: String
    /// Human-readable error description.
    public var message: String
    /// What the client should do next.
    public var retryStatus: BetaManagedAgentsMCPAuthenticationFailedError.RetryStatus
    public var type: String

    public init(mcpServerName: String, message: String, retryStatus: BetaManagedAgentsMCPAuthenticationFailedError.RetryStatus, type: String = "mcp_authentication_failed_error") {
        self.mcpServerName = mcpServerName
        self.message = message
        self.retryStatus = retryStatus
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case mcpServerName = "mcp_server_name"
        case message
        case retryStatus = "retry_status"
        case type
    }
}

extension BetaManagedAgentsMCPAuthenticationFailedError {

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
