// Transformed from `anthropic.types.beta.beta_managed_agents_web_fetch_tool_config` (beta_managed_agents_web_fetch_tool_config.py).

import Foundation

/// Configuration for the web_fetch tool.
public struct BetaManagedAgentsWebFetchToolConfig: Codable, Hashable, Sendable {
    public var enabled: Bool
    public var name: String
    /// Permission policy for tool execution.
    public var permissionPolicy: BetaManagedAgentsWebFetchToolConfig.PermissionPolicy
    public var type: String
    /// Which sources contribute URLs the tool may fetch, always in the object form.
    ///
    /// Null when not set, which allows every source.
    public var urlSources: BetaManagedAgentsWebFetchURLSources?
    public var allowedDomains: [String]?
    public var blockedDomains: [String]?
    public var maxContentTokens: Int?

    public init(enabled: Bool, name: String = "web_fetch", permissionPolicy: BetaManagedAgentsWebFetchToolConfig.PermissionPolicy, type: String = "web_fetch", urlSources: BetaManagedAgentsWebFetchURLSources? = nil, allowedDomains: [String]? = nil, blockedDomains: [String]? = nil, maxContentTokens: Int? = nil) {
        self.enabled = enabled
        self.name = name
        self.permissionPolicy = permissionPolicy
        self.type = type
        self.urlSources = urlSources
        self.allowedDomains = allowedDomains
        self.blockedDomains = blockedDomains
        self.maxContentTokens = maxContentTokens
    }

    enum CodingKeys: String, CodingKey {
        case enabled
        case name
        case permissionPolicy = "permission_policy"
        case type
        case urlSources = "url_sources"
        case allowedDomains = "allowed_domains"
        case blockedDomains = "blocked_domains"
        case maxContentTokens = "max_content_tokens"
    }
}

extension BetaManagedAgentsWebFetchToolConfig {

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
