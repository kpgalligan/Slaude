// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_inline_agent` (beta_managed_agents_inline_agent.py).

import Foundation

/// An agent that has no Agent resource, and so no `id` or `version`.
///
/// It is defined inline, in a workflow run's plan or when a session thread is spawned, and is not saved.
public struct BetaManagedAgentsInlineAgent: Codable, Hashable, Sendable {
    public var description: String?
    /// The session's execution principal.
    public var executionIdentity: BetaManagedAgentsExecutionIdentity
    public var mcpServers: [BetaManagedAgentsMCPServerURLDefinition]
    /// Model identifier and configuration.
    public var model: BetaManagedAgentsModelConfig
    /// The name that the agent's definition gave, or one that the server assigned.
    public var name: String
    public var skills: [BetaManagedAgentsInlineAgent.Skill]
    public var system: String?
    public var tools: [BetaManagedAgentsInlineAgent.Tool]
    public var type: String

    public init(description: String? = nil, executionIdentity: BetaManagedAgentsExecutionIdentity, mcpServers: [BetaManagedAgentsMCPServerURLDefinition], model: BetaManagedAgentsModelConfig, name: String, skills: [BetaManagedAgentsInlineAgent.Skill], system: String? = nil, tools: [BetaManagedAgentsInlineAgent.Tool], type: String = "inline") {
        self.description = description
        self.executionIdentity = executionIdentity
        self.mcpServers = mcpServers
        self.model = model
        self.name = name
        self.skills = skills
        self.system = system
        self.tools = tools
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case description
        case executionIdentity = "execution_identity"
        case mcpServers = "mcp_servers"
        case model
        case name
        case skills
        case system
        case tools
        case type
    }
}

extension BetaManagedAgentsInlineAgent {

    public indirect enum Skill: Codable, Hashable, Sendable {
        case anthropic(BetaManagedAgentsAnthropicSkill)
        case custom(BetaManagedAgentsCustomSkill)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "anthropic": self = .anthropic(try BetaManagedAgentsAnthropicSkill(from: decoder))
            case "custom": self = .custom(try BetaManagedAgentsCustomSkill(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .anthropic(let v): try v.encode(to: encoder)
            case .custom(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

    public indirect enum Tool: Codable, Hashable, Sendable {
        case agentToolset20260401(BetaManagedAgentsAgentToolset20260401)
        case mcpToolset(BetaManagedAgentsMCPToolset)
        case custom(BetaManagedAgentsCustomTool)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "agent_toolset_20260401": self = .agentToolset20260401(try BetaManagedAgentsAgentToolset20260401(from: decoder))
            case "mcp_toolset": self = .mcpToolset(try BetaManagedAgentsMCPToolset(from: decoder))
            case "custom": self = .custom(try BetaManagedAgentsCustomTool(from: decoder))
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
