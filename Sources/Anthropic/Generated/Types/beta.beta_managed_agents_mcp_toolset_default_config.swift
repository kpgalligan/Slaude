// Transformed from `anthropic.types.beta.beta_managed_agents_mcp_toolset_default_config` (beta_managed_agents_mcp_toolset_default_config.py).

import Foundation

/// Resolved default configuration for all tools from an MCP server.
public struct BetaManagedAgentsMCPToolsetDefaultConfig: Codable, Hashable, Sendable {
    public var enabled: Bool
    /// Permission policy for tool execution.
    public var permissionPolicy: BetaManagedAgentsMCPToolsetDefaultConfig.PermissionPolicy

    public init(enabled: Bool, permissionPolicy: BetaManagedAgentsMCPToolsetDefaultConfig.PermissionPolicy) {
        self.enabled = enabled
        self.permissionPolicy = permissionPolicy
    }

    enum CodingKeys: String, CodingKey {
        case enabled
        case permissionPolicy = "permission_policy"
    }
}

extension BetaManagedAgentsMCPToolsetDefaultConfig {

    public indirect enum PermissionPolicy: Codable, Hashable, Sendable {
        case alwaysAllow(BetaManagedAgentsAlwaysAllowPolicy)
        case alwaysAsk(BetaManagedAgentsAlwaysAskPolicy)
        case auto(BetaManagedAgentsAutoPolicy)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "always_allow": self = .alwaysAllow(try BetaManagedAgentsAlwaysAllowPolicy(from: decoder))
            case "always_ask": self = .alwaysAsk(try BetaManagedAgentsAlwaysAskPolicy(from: decoder))
            case "auto": self = .auto(try BetaManagedAgentsAutoPolicy(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .alwaysAllow(let v): try v.encode(to: encoder)
            case .alwaysAsk(let v): try v.encode(to: encoder)
            case .auto(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
