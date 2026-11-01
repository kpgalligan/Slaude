// Transformed from `anthropic.types.beta.beta_managed_agents_session_agent_update_param` (beta_managed_agents_session_agent_update_param.py).

import Foundation

/// Mid-session agent configuration update.
///
/// Only `tools` and `mcp_servers` are updatable. Full replacement: the provided array becomes the new value. To preserve existing entries, GET the session, modify the array, and POST it back.
public struct BetaManagedAgentsSessionAgentUpdateParam: Codable, Hashable, Sendable {
    /// Replacement MCP server list.
    ///
    /// Full replacement: the provided array becomes the new value. Send an empty array
    /// to clear; omit to preserve.
    public var mcpServers: [BetaManagedAgentsURLMCPServerParams]?
    /// Replacement tool list.
    ///
    /// Full replacement: the provided array becomes the new value. Send an empty array
    /// to clear; omit to preserve.
    public var tools: [BetaManagedAgentsSessionAgentUpdateParam.Tool]?

    public init(mcpServers: [BetaManagedAgentsURLMCPServerParams]? = nil, tools: [BetaManagedAgentsSessionAgentUpdateParam.Tool]? = nil) {
        self.mcpServers = mcpServers
        self.tools = tools
    }

    enum CodingKeys: String, CodingKey {
        case mcpServers = "mcp_servers"
        case tools
    }
}

extension BetaManagedAgentsSessionAgentUpdateParam {

    public indirect enum Tool: Codable, Hashable, Sendable {
        case agentToolset20260401(BetaManagedAgentsAgentToolset20260401Params)
        case mcpToolset(BetaManagedAgentsMCPToolsetParams)
        case custom(BetaManagedAgentsCustomToolParams)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "agent_toolset_20260401": self = .agentToolset20260401(try BetaManagedAgentsAgentToolset20260401Params(from: decoder))
            case "mcp_toolset": self = .mcpToolset(try BetaManagedAgentsMCPToolsetParams(from: decoder))
            case "custom": self = .custom(try BetaManagedAgentsCustomToolParams(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .agentToolset20260401(let v): try v.encode(to: encoder)
            case .mcpToolset(let v): try v.encode(to: encoder)
            case .custom(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
