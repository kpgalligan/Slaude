// Transformed from `anthropic.types.beta.beta_managed_agents_deployment_run` (beta_managed_agents_deployment_run.py).

import Foundation

/// A persistent, append-only record of a single deployment execution.
///
/// Records session creation success or failure — no session lifecycle tracking.
public struct BetaManagedAgentsDeploymentRun: Codable, Hashable, Sendable {
    /// Unique identifier for this run (`drun_...`).
    public var id: String
    /// Snapshot of the agent at fire time.
    ///
    /// Always fully resolved — deployments pin agent + version.
    public var agent: BetaManagedAgentsAgentReference
    /// Time this run record was persisted.
    public var createdAt: Date
    /// ID of the deployment that produced this run.
    public var deploymentId: String
    /// Populated on creation failure.
    ///
    /// Null on success. Exactly one of `session_id` or `error` is non-null.
    public var error: BetaManagedAgentsDeploymentRun.Error??
    /// Populated on success.
    ///
    /// Null on creation failure. Exactly one of `session_id` or `error` is non-null.
    public var sessionId: String?
    /// What triggered this run and trigger-specific metadata.
    public var triggerContext: BetaManagedAgentsTriggerContext
    public var type: String

    public init(id: String, agent: BetaManagedAgentsAgentReference, createdAt: Date, deploymentId: String, error: BetaManagedAgentsDeploymentRun.Error?? = nil, sessionId: String? = nil, triggerContext: BetaManagedAgentsTriggerContext, type: String = "deployment_run") {
        self.id = id
        self.agent = agent
        self.createdAt = createdAt
        self.deploymentId = deploymentId
        self.error = error
        self.sessionId = sessionId
        self.triggerContext = triggerContext
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case agent
        case createdAt = "created_at"
        case deploymentId = "deployment_id"
        case error
        case sessionId = "session_id"
        case triggerContext = "trigger_context"
        case type
    }
}

extension BetaManagedAgentsDeploymentRun {

    public indirect enum Error: Codable, Hashable, Sendable {
        case environmentArchivedError(BetaManagedAgentsEnvironmentArchivedRunError)
        case agentArchivedError(BetaManagedAgentsAgentArchivedRunError)
        case environmentNotFoundError(BetaManagedAgentsEnvironmentNotFoundRunError)
        case vaultNotFoundError(BetaManagedAgentsVaultNotFoundRunError)
        case vaultArchivedError(BetaManagedAgentsVaultArchivedRunError)
        case fileNotFoundError(BetaManagedAgentsFileNotFoundRunError)
        case memoryStoreArchivedError(BetaManagedAgentsMemoryStoreArchivedRunError)
        case skillNotFoundError(BetaManagedAgentsSkillNotFoundRunError)
        case sessionResourceNotFoundError(BetaManagedAgentsSessionResourceNotFoundRunError)
        case workspaceArchivedError(BetaManagedAgentsWorkspaceArchivedRunError)
        case organizationDisabledError(BetaManagedAgentsOrganizationDisabledRunError)
        case sessionRateLimitedError(BetaManagedAgentsSessionRateLimitedRunError)
        case sessionCreationRejectedError(BetaManagedAgentsSessionCreationRejectedRunError)
        case unknownError(BetaManagedAgentsUnknownRunError)
        case selfHostedResourcesUnsupportedError(BetaManagedAgentsSelfHostedResourcesUnsupportedRunError)
        case mcpEgressBlockedError(BetaManagedAgentsMCPEgressBlockedRunError)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "environment_archived_error": self = .environmentArchivedError(try BetaManagedAgentsEnvironmentArchivedRunError(from: decoder))
            case "agent_archived_error": self = .agentArchivedError(try BetaManagedAgentsAgentArchivedRunError(from: decoder))
            case "environment_not_found_error": self = .environmentNotFoundError(try BetaManagedAgentsEnvironmentNotFoundRunError(from: decoder))
            case "vault_not_found_error": self = .vaultNotFoundError(try BetaManagedAgentsVaultNotFoundRunError(from: decoder))
            case "vault_archived_error": self = .vaultArchivedError(try BetaManagedAgentsVaultArchivedRunError(from: decoder))
            case "file_not_found_error": self = .fileNotFoundError(try BetaManagedAgentsFileNotFoundRunError(from: decoder))
            case "memory_store_archived_error": self = .memoryStoreArchivedError(try BetaManagedAgentsMemoryStoreArchivedRunError(from: decoder))
            case "skill_not_found_error": self = .skillNotFoundError(try BetaManagedAgentsSkillNotFoundRunError(from: decoder))
            case "session_resource_not_found_error": self = .sessionResourceNotFoundError(try BetaManagedAgentsSessionResourceNotFoundRunError(from: decoder))
            case "workspace_archived_error": self = .workspaceArchivedError(try BetaManagedAgentsWorkspaceArchivedRunError(from: decoder))
            case "organization_disabled_error": self = .organizationDisabledError(try BetaManagedAgentsOrganizationDisabledRunError(from: decoder))
            case "session_rate_limited_error": self = .sessionRateLimitedError(try BetaManagedAgentsSessionRateLimitedRunError(from: decoder))
            case "session_creation_rejected_error": self = .sessionCreationRejectedError(try BetaManagedAgentsSessionCreationRejectedRunError(from: decoder))
            case "unknown_error": self = .unknownError(try BetaManagedAgentsUnknownRunError(from: decoder))
            case "self_hosted_resources_unsupported_error": self = .selfHostedResourcesUnsupportedError(try BetaManagedAgentsSelfHostedResourcesUnsupportedRunError(from: decoder))
            case "mcp_egress_blocked_error": self = .mcpEgressBlockedError(try BetaManagedAgentsMCPEgressBlockedRunError(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .environmentArchivedError(let v): try v.encode(to: encoder)
            case .agentArchivedError(let v): try v.encode(to: encoder)
            case .environmentNotFoundError(let v): try v.encode(to: encoder)
            case .vaultNotFoundError(let v): try v.encode(to: encoder)
            case .vaultArchivedError(let v): try v.encode(to: encoder)
            case .fileNotFoundError(let v): try v.encode(to: encoder)
            case .memoryStoreArchivedError(let v): try v.encode(to: encoder)
            case .skillNotFoundError(let v): try v.encode(to: encoder)
            case .sessionResourceNotFoundError(let v): try v.encode(to: encoder)
            case .workspaceArchivedError(let v): try v.encode(to: encoder)
            case .organizationDisabledError(let v): try v.encode(to: encoder)
            case .sessionRateLimitedError(let v): try v.encode(to: encoder)
            case .sessionCreationRejectedError(let v): try v.encode(to: encoder)
            case .unknownError(let v): try v.encode(to: encoder)
            case .selfHostedResourcesUnsupportedError(let v): try v.encode(to: encoder)
            case .mcpEgressBlockedError(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
