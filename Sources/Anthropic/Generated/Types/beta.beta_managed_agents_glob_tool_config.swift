// Transformed from `anthropic.types.beta.beta_managed_agents_glob_tool_config` (beta_managed_agents_glob_tool_config.py).

import Foundation

/// Configuration for the glob tool.
public struct BetaManagedAgentsGlobToolConfig: Codable, Hashable, Sendable {
    public var enabled: Bool
    public var name: String
    /// Permission policy for tool execution.
    public var permissionPolicy: BetaManagedAgentsGlobToolConfig.PermissionPolicy
    public var type: String

    public init(enabled: Bool, name: String = "glob", permissionPolicy: BetaManagedAgentsGlobToolConfig.PermissionPolicy, type: String = "glob") {
        self.enabled = enabled
        self.name = name
        self.permissionPolicy = permissionPolicy
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case enabled
        case name
        case permissionPolicy = "permission_policy"
        case type
    }
}

extension BetaManagedAgentsGlobToolConfig {

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
