// Transformed from `anthropic.types.beta.deployment_create_params` (deployment_create_params.py).

import Foundation

public struct DeploymentCreateParams: Codable, Hashable, Sendable {
    /// Agent to deploy.
    ///
    /// Accepts the `agent` ID string, which pins the latest version, or an `agent`
    /// object with both id and version specified. The agent must exist and not be
    /// archived.
    public var agent: DeploymentCreateParams.Agent
    /// ID of the `environment` defining the container configuration for sessions
    /// created from this deployment.
    public var environmentID: String
    /// Events to send to each session immediately after creation.
    ///
    /// At least 1, maximum 50.
    public var initialEvents: [BetaManagedAgentsDeploymentInitialEventParams]
    /// Human-readable name for the deployment.
    public var name: String
    /// Enforced spend ceiling stamped onto each session created from this deployment,
    /// copied at session-creation time. Omit to leave sessions uncapped. The deployment
    /// agent's model must have a public list price, or the request is rejected; a
    /// multiagent roster is re-validated in full when each fire copies the cap, which
    /// fails closed the same way.
    public var budget: BetaManagedAgentsBudgetLimitParam??
    /// Description of what the deployment does.
    public var description: String??
    /// Arbitrary key-value metadata.
    ///
    /// Maximum 16 pairs, keys up to 64 chars, values up to 512 chars.
    public var metadata: [String: String]?
    /// Resources (e.g.
    ///
    /// repositories, files) to mount into each session's container. Maximum 500.
    public var resources: [DeploymentCreateParams.Resource]?
    /// Optional recurring cron schedule.
    ///
    /// When present, the deployment fires automatically. Both expression and timezone
    /// are required when schedule is set.
    public var schedule: BetaManagedAgentsScheduleParams??
    /// Vault IDs for stored credentials the agent can use during sessions created from
    /// this deployment. Maximum 50.
    public var vaultIDs: [String]?
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

    public init(agent: DeploymentCreateParams.Agent, environmentID: String, initialEvents: [BetaManagedAgentsDeploymentInitialEventParams], name: String, budget: BetaManagedAgentsBudgetLimitParam?? = nil, description: String?? = nil, metadata: [String: String]? = nil, resources: [DeploymentCreateParams.Resource]? = nil, schedule: BetaManagedAgentsScheduleParams?? = nil, vaultIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.agent = agent
        self.environmentID = environmentID
        self.initialEvents = initialEvents
        self.name = name
        self.budget = budget
        self.description = description
        self.metadata = metadata
        self.resources = resources
        self.schedule = schedule
        self.vaultIDs = vaultIDs
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case agent
        case environmentID = "environment_id"
        case initialEvents = "initial_events"
        case name
        case budget
        case description
        case metadata
        case resources
        case schedule
        case vaultIDs = "vault_ids"
        case betas
        case workspaceID = "workspace_id"
    }
}

extension DeploymentCreateParams {

    public indirect enum Agent: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case betaManagedAgentsAgentParams(BetaManagedAgentsAgentParams)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? BetaManagedAgentsAgentParams(from: decoder) { self = .betaManagedAgentsAgentParams(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .betaManagedAgentsAgentParams(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

    public indirect enum Resource: Codable, Hashable, Sendable {
        case githubRepository(BetaManagedAgentsGitHubRepositoryResourceParams)
        case file(BetaManagedAgentsFileResourceParams)
        case memoryStore(BetaManagedAgentsMemoryStoreResourceParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "github_repository": self = .githubRepository(try BetaManagedAgentsGitHubRepositoryResourceParams(from: decoder))
            case "file": self = .file(try BetaManagedAgentsFileResourceParams(from: decoder))
            case "memory_store": self = .memoryStore(try BetaManagedAgentsMemoryStoreResourceParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .githubRepository(let v): try v.encode(to: encoder)
            case .file(let v): try v.encode(to: encoder)
            case .memoryStore(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
