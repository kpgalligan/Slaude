// Transformed from `anthropic.types.beta.beta_managed_agents_agent_toolset_default_config_params` (beta_managed_agents_agent_toolset_default_config_params.py).

import Foundation

/// Default configuration for all tools in a toolset.
public struct BetaManagedAgentsAgentToolsetDefaultConfigParams: Codable, Hashable, Sendable {
    /// Whether tools are enabled and available to Claude by default.
    ///
    /// Defaults to true if not specified.
    public var enabled: Bool??
    /// Default permission policy for tools.
    ///
    /// Controls whether tool calls are auto-approved or require confirmation.
    public var permissionPolicy: BetaManagedAgentsAgentToolsetDefaultConfigParams.PermissionPolicy??

    public init(enabled: Bool?? = nil, permissionPolicy: BetaManagedAgentsAgentToolsetDefaultConfigParams.PermissionPolicy?? = nil) {
        self.enabled = enabled
        self.permissionPolicy = permissionPolicy
    }

    enum CodingKeys: String, CodingKey {
        case enabled
        case permissionPolicy = "permission_policy"
    }
}

extension BetaManagedAgentsAgentToolsetDefaultConfigParams {

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
