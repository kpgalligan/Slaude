// Transformed from `anthropic.types.beta.beta_managed_agents_session_thread_agent` (beta_managed_agents_session_thread_agent.py).

import Foundation

/// Resolved `agent` definition for a single `session_thread`.
///
/// Snapshot of the agent at thread creation time. The multiagent roster is not repeated here; read it from `Session.agent`.
public struct BetaManagedAgentsSessionThreadAgent: Codable, Hashable, Sendable {
    public var id: String
    public var description: String?
    /// Execution principal snapshotted from the agent at session creation.
    ///
    /// Always present; `{"type": "service_account"}` when runs carry no customer-named
    /// principal.
    public var executionIdentity: BetaManagedAgentsExecutionIdentity
    public var mcpServers: [BetaManagedAgentsMCPServerURLDefinition]
    /// Model identifier and configuration.
    public var model: BetaManagedAgentsModelConfig
    public var name: String
    public var skills: [BetaManagedAgentsSessionThreadAgent.Skill]
    public var system: String?
    public var tools: [BetaManagedAgentsSessionThreadAgent.Tool]
    public var type: String
    public var version: Int

    public init(id: String, description: String? = nil, executionIdentity: BetaManagedAgentsExecutionIdentity, mcpServers: [BetaManagedAgentsMCPServerURLDefinition], model: BetaManagedAgentsModelConfig, name: String, skills: [BetaManagedAgentsSessionThreadAgent.Skill], system: String? = nil, tools: [BetaManagedAgentsSessionThreadAgent.Tool], type: String = "agent", version: Int) {
        self.id = id
        self.description = description
        self.executionIdentity = executionIdentity
        self.mcpServers = mcpServers
        self.model = model
        self.name = name
        self.skills = skills
        self.system = system
        self.tools = tools
        self.type = type
        self.version = version
    }

    enum CodingKeys: String, CodingKey {
        case id
        case description
        case executionIdentity = "execution_identity"
        case mcpServers = "mcp_servers"
        case model
        case name
        case skills
        case system
        case tools
        case type
        case version
    }
}

extension BetaManagedAgentsSessionThreadAgent {

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
