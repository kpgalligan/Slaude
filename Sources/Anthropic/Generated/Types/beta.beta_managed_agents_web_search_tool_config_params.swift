// Transformed from `anthropic.types.beta.beta_managed_agents_web_search_tool_config_params` (beta_managed_agents_web_search_tool_config_params.py).

import Foundation

/// Configuration override for the web_search tool.
public struct BetaManagedAgentsWebSearchToolConfigParams: Codable, Hashable, Sendable {
    /// Must be "web_search".
    public var name: String
    /// Only return search results whose host is one of these domains or a subdomain of
    /// one. Each entry is a plain hostname like "docs.example.com" (no scheme or port;
    /// an optional path suffix is accepted). At most 64 entries; an empty list is
    /// rejected (omit the field instead). Cannot be combined with blocked_domains.
    public var allowedDomains: [String]?
    /// Never return search results whose host is one of these domains or a subdomain of
    /// one. Each entry is a plain hostname like "ads.example.com" (no scheme or port;
    /// an optional path suffix is accepted). At most 64 entries; an empty list is
    /// rejected (omit the field instead). Cannot be combined with allowed_domains.
    public var blockedDomains: [String]?
    /// Whether this tool is enabled and available to Claude.
    ///
    /// Overrides the default_config setting.
    public var enabled: Bool??
    /// Permission policy for this tool.
    ///
    /// Controls whether tool calls are auto-approved or require confirmation.
    public var permissionPolicy: BetaManagedAgentsWebSearchToolConfigParams.PermissionPolicy??
    public var type: String?
    /// Approximate user location for search result localization.
    public var userLocation: BetaManagedAgentsUserLocationParam??

    public init(name: String = "web_search", allowedDomains: [String]? = nil, blockedDomains: [String]? = nil, enabled: Bool?? = nil, permissionPolicy: BetaManagedAgentsWebSearchToolConfigParams.PermissionPolicy?? = nil, type: String? = nil, userLocation: BetaManagedAgentsUserLocationParam?? = nil) {
        self.name = name
        self.allowedDomains = allowedDomains
        self.blockedDomains = blockedDomains
        self.enabled = enabled
        self.permissionPolicy = permissionPolicy
        self.type = type
        self.userLocation = userLocation
    }

    enum CodingKeys: String, CodingKey {
        case name
        case allowedDomains = "allowed_domains"
        case blockedDomains = "blocked_domains"
        case enabled
        case permissionPolicy = "permission_policy"
        case type
        case userLocation = "user_location"
    }
}

extension BetaManagedAgentsWebSearchToolConfigParams {

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
