// Transformed from `anthropic.types.beta.deployment_update_params` (deployment_update_params.py).

import Foundation

public struct DeploymentUpdateParams: Codable, Hashable, Sendable {
    /// Agent to deploy.
    ///
    /// Accepts the `agent` ID string, which re-pins to the latest version, or an
    /// `agent` object with both id and version specified. Omit to preserve. Cannot be
    /// cleared.
    public var agent: DeploymentUpdateParams.Agent?
    /// Spend ceiling for future sessions.
    ///
    /// Full replacement. Omit to preserve; send null to clear (sessions created
    /// afterwards are uncapped). The deployment agent's model must have a public list
    /// price, or the request is rejected; a multiagent roster is re-validated in full
    /// when each fire copies the cap, which fails closed the same way.
    public var budget: BetaManagedAgentsBudgetLimitParam??
    /// Description. Omit to preserve; send empty string or null to clear.
    public var description: String??
    /// ID of the `environment` where sessions run.
    ///
    /// Omit to preserve. Cannot be cleared.
    public var environmentId: String?
    /// Initial events.
    ///
    /// Full replacement. Omit to preserve. Cannot be cleared. At least 1, maximum 50.
    public var initialEvents: [BetaManagedAgentsDeploymentInitialEventParams]?
    /// Metadata patch.
    ///
    /// Set a key to a string to upsert it, or to null to delete it. Omit the field to
    /// preserve. The stored bag is limited to 16 keys (up to 64 chars each) with values
    /// up to 512 chars.
    public var metadata: [String: String?]??
    /// Human-readable name. Must be non-empty. Omit to preserve. Cannot be cleared.
    public var name: String?
    /// Session resources.
    ///
    /// Full replacement. Omit to preserve; send empty array or null to clear.
    /// Maximum 500.
    public var resources: [DeploymentUpdateParams.Resource]??
    /// Cron schedule.
    ///
    /// Full replacement. Omit to preserve; send null to clear (revert to manual-only).
    public var schedule: BetaManagedAgentsScheduleParams??
    /// Vault IDs.
    ///
    /// Full replacement. Omit to preserve; send empty array or null to clear.
    /// Maximum 50.
    public var vaultIds: [String]??
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
    public var workspaceId: String?

    public init(agent: DeploymentUpdateParams.Agent? = nil, budget: BetaManagedAgentsBudgetLimitParam?? = nil, description: String?? = nil, environmentId: String? = nil, initialEvents: [BetaManagedAgentsDeploymentInitialEventParams]? = nil, metadata: [String: String?]?? = nil, name: String? = nil, resources: [DeploymentUpdateParams.Resource]?? = nil, schedule: BetaManagedAgentsScheduleParams?? = nil, vaultIds: [String]?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.agent = agent
        self.budget = budget
        self.description = description
        self.environmentId = environmentId
        self.initialEvents = initialEvents
        self.metadata = metadata
        self.name = name
        self.resources = resources
        self.schedule = schedule
        self.vaultIds = vaultIds
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case agent
        case budget
        case description
        case environmentId = "environment_id"
        case initialEvents = "initial_events"
        case metadata
        case name
        case resources
        case schedule
        case vaultIds = "vault_ids"
        case betas
        case workspaceId = "workspace_id"
    }
}

extension DeploymentUpdateParams {

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
