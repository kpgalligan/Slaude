// Transformed from `anthropic.types.beta.beta_managed_agents_bash_tool_config_params` (beta_managed_agents_bash_tool_config_params.py).

import Foundation

/// Configuration override for the bash tool.
public struct BetaManagedAgentsBashToolConfigParams: Codable, Hashable, Sendable {
    /// Must be "bash".
    public var name: String
    /// Whether this tool is enabled and available to Claude.
    ///
    /// Overrides the default_config setting.
    public var enabled: Bool??
    /// Permission policy for this tool.
    ///
    /// Controls whether tool calls are auto-approved or require confirmation.
    public var permissionPolicy: BetaManagedAgentsBashToolConfigParams.PermissionPolicy??
    public var type: String?

    public init(name: String = "bash", enabled: Bool?? = nil, permissionPolicy: BetaManagedAgentsBashToolConfigParams.PermissionPolicy?? = nil, type: String? = nil) {
        self.name = name
        self.enabled = enabled
        self.permissionPolicy = permissionPolicy
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case name
        case enabled
        case permissionPolicy = "permission_policy"
        case type
    }
}

extension BetaManagedAgentsBashToolConfigParams {

    public indirect enum PermissionPolicy: Codable, Hashable, Sendable {
        case alwaysAllow(BetaManagedAgentsAlwaysAllowPolicyParam)
        case alwaysAsk(BetaManagedAgentsAlwaysAskPolicyParam)
        case auto(BetaManagedAgentsAutoPolicyParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "always_allow": self = .alwaysAllow(try BetaManagedAgentsAlwaysAllowPolicyParam(from: decoder))
            case "always_ask": self = .alwaysAsk(try BetaManagedAgentsAlwaysAskPolicyParam(from: decoder))
            case "auto": self = .auto(try BetaManagedAgentsAutoPolicyParam(from: decoder))
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
