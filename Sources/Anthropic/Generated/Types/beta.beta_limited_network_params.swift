// Transformed from `anthropic.types.beta.beta_limited_network_params` (beta_limited_network_params.py).

import Foundation

/// Limited network request params.
///
/// Fields default to null; on update, omitted fields preserve the
/// existing value.
public struct BetaLimitedNetworkParams: Codable, Hashable, Sendable {
    /// Network policy type
    public var type: String
    /// Permits outbound access to MCP server endpoints configured on the agent, beyond
    /// those listed in the `allowed_hosts` array. Defaults to `false`.
    public var allowMCPServers: Bool??
    /// Permits outbound access to public package registries (PyPI, npm, etc.) beyond
    /// those listed in the `allowed_hosts` array. Defaults to `false` on creation. Must
    /// be `true` when `packages` are specified.
    public var allowPackageManagers: Bool??
    /// Specifies domains the container can reach.
    public var allowedHosts: [String]??

    public init(type: String = "limited", allowMCPServers: Bool?? = nil, allowPackageManagers: Bool?? = nil, allowedHosts: [String]?? = nil) {
        self.type = type
        self.allowMCPServers = allowMCPServers
        self.allowPackageManagers = allowPackageManagers
        self.allowedHosts = allowedHosts
    }

    enum CodingKeys: String, CodingKey {
        case type
        case allowMCPServers = "allow_mcp_servers"
        case allowPackageManagers = "allow_package_managers"
        case allowedHosts = "allowed_hosts"
    }
}
