// Transformed from `anthropic.types.beta.agent_update_params` (agent_update_params.py).

import Foundation

public struct AgentUpdateParams: Codable, Hashable, Sendable {
    /// Description. Omit to preserve; send empty string or null to clear.
    public var description: String??
    /// Execution principal for runs of this agent.
    ///
    /// Full replacement. Omit to preserve; send null or `{"type": "service_account"}`
    /// to restore the default.
    public var executionIdentity: BetaManagedAgentsExecutionIdentityParams??
    /// MCP servers.
    ///
    /// Full replacement. Omit to preserve; send empty array or `null` to clear. Names
    /// must be unique. Maximum 20. Every server must be referenced by an `mcp_toolset`
    /// in the agent's resulting `tools`; unreferenced servers are rejected. See the
    /// [MCP connector guide](https://platform.claude.com/docs/en/managed-agents/mcp-connector).
    public var mcpServers: [BetaManagedAgentsURLMCPServerParams]??
    /// Metadata patch.
    ///
    /// Set a key to a string to upsert it, or to null to delete it. Omit the field to
    /// preserve. The stored bag is limited to 16 keys (up to 64 chars each) with values
    /// up to 512 chars.
    public var metadata: [String: String?]??
    /// Model identifier.
    ///
    /// Accepts the
    /// [model string](https://platform.claude.com/docs/en/about-claude/models/overview#latest-models-comparison),
    /// e.g. `claude-opus-5-5`, or a `model_config` object for additional configuration
    /// control. Omit to preserve. Cannot be cleared.
    public var model: AgentUpdateParams.Model?
    /// Multiagent orchestration configuration.
    ///
    /// Full replacement. Omit to preserve; send null to clear.
    public var multiagent: BetaManagedAgentsMultiagentParams??
    /// Human-readable name. Must be non-empty. Omit to preserve. Cannot be cleared.
    public var name: String?
    /// Skills. Full replacement. Omit to preserve; send empty array or null to clear.
    public var skills: [BetaManagedAgentsSkillParams]??
    /// System prompt. Omit to preserve; send empty string or null to clear.
    public var system: String??
    /// Tool configurations available to the agent.
    ///
    /// Full replacement. Omit to preserve; send empty array or null to clear. Maximum
    /// of 256 tools across all toolsets allowed.
    public var tools: [AgentUpdateParams.Tool]??
    /// The agent's current version, used to prevent concurrent overwrites.
    ///
    /// Obtain this value from a create or retrieve response. Must be at least 1 if
    /// specified. When supplied, the request fails if it does not match the server's
    /// current version; omit to apply the update unconditionally.
    public var version: Int?
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

    public init(description: String?? = nil, executionIdentity: BetaManagedAgentsExecutionIdentityParams?? = nil, mcpServers: [BetaManagedAgentsURLMCPServerParams]?? = nil, metadata: [String: String?]?? = nil, model: AgentUpdateParams.Model? = nil, multiagent: BetaManagedAgentsMultiagentParams?? = nil, name: String? = nil, skills: [BetaManagedAgentsSkillParams]?? = nil, system: String?? = nil, tools: [AgentUpdateParams.Tool]?? = nil, version: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
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
        self.version = version
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
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
        case version
        case betas
        case workspaceID = "workspace_id"
    }
}

extension AgentUpdateParams {

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
