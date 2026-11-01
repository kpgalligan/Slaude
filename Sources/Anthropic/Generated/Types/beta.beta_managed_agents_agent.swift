// Transformed from `anthropic.types.beta.beta_managed_agents_agent` (beta_managed_agents_agent.py).

import Foundation

/// A Managed Agents `agent`.
public struct BetaManagedAgentsAgent: Codable, Hashable, Sendable {
    public var id: String
    /// When the agent was archived. Null if not archived.
    public var archivedAt: Date?
    /// A timestamp in RFC 3339 format
    public var createdAt: Date
    public var description: String?
    /// Execution principal for runs of this agent.
    ///
    /// Always present; `{"type": "service_account"}` when runs carry no customer-named
    /// principal.
    public var executionIdentity: BetaManagedAgentsExecutionIdentity
    public var mcpServers: [BetaManagedAgentsMCPServerURLDefinition]
    public var metadata: [String: String]
    /// Model identifier and configuration.
    public var model: BetaManagedAgentsModelConfig
    /// Multiagent orchestration configuration. Null when the agent is single-threaded.
    public var multiagent: BetaManagedAgentsMultiagent?
    public var name: String
    public var skills: [BetaManagedAgentsAgent.Skill]
    public var system: String?
    public var tools: [BetaManagedAgentsAgent.Tool]
    public var type: String
    /// A timestamp in RFC 3339 format
    public var updatedAt: Date
    /// The agent's current version.
    ///
    /// Starts at 1 and increments when the agent is modified.
    public var version: Int

    public init(id: String, archivedAt: Date? = nil, createdAt: Date, description: String? = nil, executionIdentity: BetaManagedAgentsExecutionIdentity, mcpServers: [BetaManagedAgentsMCPServerURLDefinition], metadata: [String: String], model: BetaManagedAgentsModelConfig, multiagent: BetaManagedAgentsMultiagent? = nil, name: String, skills: [BetaManagedAgentsAgent.Skill], system: String? = nil, tools: [BetaManagedAgentsAgent.Tool], type: String = "agent", updatedAt: Date, version: Int) {
        self.id = id
        self.archivedAt = archivedAt
        self.createdAt = createdAt
        self.description = description
        self.executionIdentity = executionIdentity
        self.mcpServers = mcpServers
        self.metadata = metadata
        self.model = model
        self.multiagent = multiagent
        self.name = name
        self.skills = skills
        self.system = system
        self.tools = tools
        self.type = type
        self.updatedAt = updatedAt
        self.version = version
    }

    enum CodingKeys: String, CodingKey {
        case id
        case archivedAt = "archived_at"
        case createdAt = "created_at"
        case description
        case executionIdentity = "execution_identity"
        case mcpServers = "mcp_servers"
        case metadata
        case model
        case multiagent
        case name
        case skills
        case system
        case tools
        case type
        case updatedAt = "updated_at"
        case version
    }
}

extension BetaManagedAgentsAgent {

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
