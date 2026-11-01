// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_mcp_probe` (beta_managed_agents_mcp_probe.py).

import Foundation

/// The failing step of an MCP validation probe.
public struct BetaManagedAgentsMCPProbe: Codable, Hashable, Sendable {
    /// The HTTP error response from the MCP server, or `null` if the MCP server didn't
    /// return one for the failing step, for example after a timeout or a DNS or TLS
    /// failure.
    public var httpResponse: BetaManagedAgentsRefreshHTTPResponse?
    /// The MCP method that failed (for example `initialize` or `tools/list`).
    public var method: String

    public init(httpResponse: BetaManagedAgentsRefreshHTTPResponse? = nil, method: String) {
        self.httpResponse = httpResponse
        self.method = method
    }

    enum CodingKeys: String, CodingKey {
        case httpResponse = "http_response"
        case method
    }
}
