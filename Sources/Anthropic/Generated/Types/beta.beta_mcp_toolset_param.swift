// Transformed from `anthropic.types.beta.beta_mcp_toolset_param` (beta_mcp_toolset_param.py).

import Foundation

/// Configuration for a group of tools from an MCP server.
///
/// Allows configuring enabled status and defer_loading for all tools
/// from an MCP server, with optional per-tool overrides.
public struct BetaMCPToolsetParam: Codable, Hashable, Sendable {
    /// Name of the MCP server to configure tools for
    public var mcpServerName: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??
    /// Configuration overrides for specific tools, keyed by tool name
    public var configs: [String: BetaMCPToolConfigParam]??
    /// Default configuration applied to all tools from this server
    public var defaultConfig: BetaMCPToolDefaultConfigParam?
    /// The server's tool listing, pinned: when present, the server is not asked for its
    /// tools before sampling and exactly these entries, with `default_config` and
    /// `configs` applied, are the toolset's tools. Copy it from the `mcp_tool_listing`
    /// block of an earlier response.
    public var tools: [BetaMCPToolParamParam]??

    public init(mcpServerName: String, type: String = "mcp_toolset", cacheControl: BetaCacheControlEphemeralParam?? = nil, configs: [String: BetaMCPToolConfigParam]?? = nil, defaultConfig: BetaMCPToolDefaultConfigParam? = nil, tools: [BetaMCPToolParamParam]?? = nil) {
        self.mcpServerName = mcpServerName
        self.type = type
        self.cacheControl = cacheControl
        self.configs = configs
        self.defaultConfig = defaultConfig
        self.tools = tools
    }

    enum CodingKeys: String, CodingKey {
        case mcpServerName = "mcp_server_name"
        case type
        case cacheControl = "cache_control"
        case configs
        case defaultConfig = "default_config"
        case tools
    }
}
