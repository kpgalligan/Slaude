// Transformed from `anthropic.types.beta.beta_managed_agents_agent_with_overrides_params` (beta_managed_agents_agent_with_overrides_params.py).

import Foundation

/// Reference to an `agent` plus optional configuration overrides.
///
/// Each provided field replaces the agent's value for the caller's use; the agent resource is unchanged.
public struct BetaManagedAgentsAgentWithOverridesParams: Codable, Hashable, Sendable {
    /// The `agent` ID.
    public var id: String
    public var type: String
    /// Replacement MCP server list.
    ///
    /// Full replacement: the provided array becomes the MCP servers. Send an empty
    /// array to clear; omit to preserve the agent's servers.
    public var mcpServers: [BetaManagedAgentsURLMCPServerParams]?
    /// Replacement model.
    ///
    /// Accepts the model string, e.g. `claude-opus-5-5`, or a `model_config` object.
    /// Omit to use the agent's model.
    public var model: BetaManagedAgentsAgentWithOverridesParams.Model?
    /// Replacement skill list.
    ///
    /// Full replacement: the provided array becomes the skills. Send an empty array to
    /// clear; omit to preserve the agent's skills.
    public var skills: [BetaManagedAgentsSkillParams]?
    /// Replacement system prompt.
    ///
    /// Up to 100,000 characters. Set to null to clear the agent's system prompt; omit
    /// to preserve it.
    public var system: String??
    /// Replacement tool list.
    ///
    /// Full replacement: the provided array becomes the tool configuration. Send an
    /// empty array to clear; omit to preserve the agent's tools.
    public var tools: [BetaManagedAgentsAgentWithOverridesParams.Tool]?
    /// The specific `agent` version to use. Omit to use the latest version.
    public var version: Int?

    public init(id: String, type: String = "agent_with_overrides", mcpServers: [BetaManagedAgentsURLMCPServerParams]? = nil, model: BetaManagedAgentsAgentWithOverridesParams.Model? = nil, skills: [BetaManagedAgentsSkillParams]? = nil, system: String?? = nil, tools: [BetaManagedAgentsAgentWithOverridesParams.Tool]? = nil, version: Int? = nil) {
        self.id = id
        self.type = type
        self.mcpServers = mcpServers
        self.model = model
        self.skills = skills
        self.system = system
        self.tools = tools
        self.version = version
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case mcpServers = "mcp_servers"
        case model
        case skills
        case system
        case tools
        case version
    }
}

extension BetaManagedAgentsAgentWithOverridesParams {

    public indirect enum Model: Codable, Hashable, Sendable {
        case betaManagedAgentsModelParam(BetaManagedAgentsModelParam)
        case betaManagedAgentsModelConfigParams(BetaManagedAgentsModelConfigParams)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            if let v = try? BetaManagedAgentsModelParam(from: decoder) { self = .betaManagedAgentsModelParam(v); return }
            if let v = try? BetaManagedAgentsModelConfigParams(from: decoder) { self = .betaManagedAgentsModelConfigParams(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .betaManagedAgentsModelParam(let v): try v.encode(to: encoder)
            case .betaManagedAgentsModelConfigParams(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

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
