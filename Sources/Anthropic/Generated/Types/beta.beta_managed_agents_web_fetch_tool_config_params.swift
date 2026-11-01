// Transformed from `anthropic.types.beta.beta_managed_agents_web_fetch_tool_config_params` (beta_managed_agents_web_fetch_tool_config_params.py).

import Foundation

/// Configuration override for the web_fetch tool.
public struct BetaManagedAgentsWebFetchToolConfigParams: Codable, Hashable, Sendable {
    /// Must be "web_fetch".
    public var name: String
    /// Only fetch URLs whose host is one of these domains or a subdomain of one.
    ///
    /// Each entry is a plain hostname like "docs.example.com" (no scheme, port, or
    /// path). At most 64 entries; an empty list is rejected (omit the field instead).
    /// Cannot be combined with blocked_domains.
    public var allowedDomains: [String]?
    /// Never fetch URLs whose host is one of these domains or a subdomain of one.
    ///
    /// Each entry is a plain hostname like "ads.example.com" (no scheme, port, or
    /// path). At most 64 entries; an empty list is rejected (omit the field instead).
    /// Cannot be combined with allowed_domains.
    public var blockedDomains: [String]?
    /// Whether this tool is enabled and available to Claude.
    ///
    /// Overrides the default_config setting.
    public var enabled: Bool??
    /// Maximum number of tokens of fetched text content to include in context per call.
    ///
    /// Does not apply to binary content such as PDFs.
    public var maxContentTokens: Int??
    /// Permission policy for this tool.
    ///
    /// Controls whether tool calls are auto-approved or require confirmation.
    public var permissionPolicy: BetaManagedAgentsWebFetchToolConfigParams.PermissionPolicy??
    public var type: String?
    /// Which sources contribute URLs the tool may fetch. Omit to allow every source.
    public var urlSources: BetaManagedAgentsWebFetchURLSourcesParams??

    public init(name: String = "web_fetch", allowedDomains: [String]? = nil, blockedDomains: [String]? = nil, enabled: Bool?? = nil, maxContentTokens: Int?? = nil, permissionPolicy: BetaManagedAgentsWebFetchToolConfigParams.PermissionPolicy?? = nil, type: String? = nil, urlSources: BetaManagedAgentsWebFetchURLSourcesParams?? = nil) {
        self.name = name
        self.allowedDomains = allowedDomains
        self.blockedDomains = blockedDomains
        self.enabled = enabled
        self.maxContentTokens = maxContentTokens
        self.permissionPolicy = permissionPolicy
        self.type = type
        self.urlSources = urlSources
    }

    enum CodingKeys: String, CodingKey {
        case name
        case allowedDomains = "allowed_domains"
        case blockedDomains = "blocked_domains"
        case enabled
        case maxContentTokens = "max_content_tokens"
        case permissionPolicy = "permission_policy"
        case type
        case urlSources = "url_sources"
    }
}

extension BetaManagedAgentsWebFetchToolConfigParams {

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
