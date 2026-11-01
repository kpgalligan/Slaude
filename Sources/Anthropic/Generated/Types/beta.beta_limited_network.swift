// Transformed from `anthropic.types.beta.beta_limited_network` (beta_limited_network.py).

import Foundation

/// Limited network access.
public struct BetaLimitedNetwork: Codable, Hashable, Sendable {
    /// Permits outbound access to MCP server endpoints configured on the agent, beyond
    /// those listed in the `allowed_hosts` array.
    public var allowMCPServers: Bool
    /// Permits outbound access to public package registries (PyPI, npm, etc.) beyond
    /// those listed in the `allowed_hosts` array.
    public var allowPackageManagers: Bool
    /// Specifies domains the container can reach.
    public var allowedHosts: [String]
    /// Network policy type
    public var type: String

    public init(allowMCPServers: Bool, allowPackageManagers: Bool, allowedHosts: [String], type: String = "limited") {
        self.allowMCPServers = allowMCPServers
        self.allowPackageManagers = allowPackageManagers
        self.allowedHosts = allowedHosts
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case allowMCPServers = "allow_mcp_servers"
        case allowPackageManagers = "allow_package_managers"
        case allowedHosts = "allowed_hosts"
        case type
    }
}
