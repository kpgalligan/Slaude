// Transformed from `anthropic.types.beta.agent_create_params` (agent_create_params.py).

import Foundation

public struct AgentCreateParams: Codable, Hashable, Sendable {
    /// Model identifier.
    ///
    /// Accepts the
    /// [model string](https://platform.claude.com/docs/en/about-claude/models/overview#latest-models-comparison),
    /// e.g. `claude-opus-5-5`, or a `model_config` object for additional configuration
    /// control
    public var model: AgentCreateParams.Model
    /// Human-readable name for the agent.
    public var name: String
    /// Description of what the agent does.
    public var description: String??
    /// Execution principal for runs of this agent.
    ///
    /// Omitting it, sending null, or sending `{"type": "service_account"}` stores the
    /// default.
    public var executionIdentity: BetaManagedAgentsExecutionIdentityParams??
    /// MCP servers this agent connects to.
    ///
    /// Maximum 20. Names must be unique within the array. Every server must be
    /// referenced by an `mcp_toolset` in `tools`; unreferenced servers are rejected.
    /// See the
    /// [MCP connector guide](https://platform.claude.com/docs/en/managed-agents/mcp-connector).
    public var mcpServers: [BetaManagedAgentsURLMCPServerParams]?
    /// Arbitrary key-value metadata.
    ///
    /// Maximum 16 pairs, keys up to 64 chars, values up to 512 chars.
    public var metadata: [String: String]?
    /// Multiagent orchestration configuration.
    public var multiagent: BetaManagedAgentsMultiagentParams??
    /// Skills available to the agent.
    public var skills: [BetaManagedAgentsSkillParams]?
    /// System prompt for the agent.
    public var system: String??
    /// Tool configurations available to the agent.
    ///
    /// Maximum of 256 tools across all toolsets allowed.
    public var tools: [AgentCreateParams.Tool]?
    /// This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(model: AgentCreateParams.Model, name: String, description: String?? = nil, executionIdentity: BetaManagedAgentsExecutionIdentityParams?? = nil, mcpServers: [BetaManagedAgentsURLMCPServerParams]? = nil, metadata: [String: String]? = nil, multiagent: BetaManagedAgentsMultiagentParams?? = nil, skills: [BetaManagedAgentsSkillParams]? = nil, system: String?? = nil, tools: [AgentCreateParams.Tool]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.model = model
        self.name = name
        self.description = description
        self.executionIdentity = executionIdentity
        self.mcpServers = mcpServers
        self.metadata = metadata
        self.multiagent = multiagent
        self.skills = skills
        self.system = system
        self.tools = tools
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case model
        case name
        case description
        case executionIdentity = "execution_identity"
        case mcpServers = "mcp_servers"
        case metadata
        case multiagent
        case skills
        case system
        case tools
        case betas
        case workspaceID = "workspace_id"
    }
}

extension AgentCreateParams {

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
