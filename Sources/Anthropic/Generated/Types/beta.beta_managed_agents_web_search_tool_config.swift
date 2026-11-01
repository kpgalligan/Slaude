// Transformed from `anthropic.types.beta.beta_managed_agents_web_search_tool_config` (beta_managed_agents_web_search_tool_config.py).

import Foundation

/// Configuration for the web_search tool.
public struct BetaManagedAgentsWebSearchToolConfig: Codable, Hashable, Sendable {
    public var enabled: Bool
    public var name: String
    /// Permission policy for tool execution.
    public var permissionPolicy: BetaManagedAgentsWebSearchToolConfig.PermissionPolicy
    public var type: String
    public var allowedDomains: [String]?
    public var blockedDomains: [String]?
    /// Approximate user location for search result localization.
    public var userLocation: BetaManagedAgentsUserLocation?

    public init(enabled: Bool, name: String = "web_search", permissionPolicy: BetaManagedAgentsWebSearchToolConfig.PermissionPolicy, type: String = "web_search", allowedDomains: [String]? = nil, blockedDomains: [String]? = nil, userLocation: BetaManagedAgentsUserLocation? = nil) {
        self.enabled = enabled
        self.name = name
        self.permissionPolicy = permissionPolicy
        self.type = type
        self.allowedDomains = allowedDomains
        self.blockedDomains = blockedDomains
        self.userLocation = userLocation
    }

    enum CodingKeys: String, CodingKey {
        case enabled
        case name
        case permissionPolicy = "permission_policy"
        case type
        case allowedDomains = "allowed_domains"
        case blockedDomains = "blocked_domains"
        case userLocation = "user_location"
    }
}

extension BetaManagedAgentsWebSearchToolConfig {

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
