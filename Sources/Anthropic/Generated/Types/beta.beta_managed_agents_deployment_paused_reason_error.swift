// Transformed from `anthropic.types.beta.beta_managed_agents_deployment_paused_reason_error` (beta_managed_agents_deployment_paused_reason_error.py).

import Foundation

public indirect enum BetaManagedAgentsDeploymentPausedReasonError: Codable, Hashable, Sendable {
    case environmentArchivedError(BetaManagedAgentsEnvironmentArchivedDeploymentPausedReasonError)
    case agentArchivedError(BetaManagedAgentsAgentArchivedDeploymentPausedReasonError)
    case environmentNotFoundError(BetaManagedAgentsEnvironmentNotFoundDeploymentPausedReasonError)
    case vaultNotFoundError(BetaManagedAgentsVaultNotFoundDeploymentPausedReasonError)
    case fileNotFoundError(BetaManagedAgentsFileNotFoundDeploymentPausedReasonError)
    case sessionResourceNotFoundError(BetaManagedAgentsSessionResourceNotFoundDeploymentPausedReasonError)
    case workspaceArchivedError(BetaManagedAgentsWorkspaceArchivedDeploymentPausedReasonError)
    case organizationDisabledError(BetaManagedAgentsOrganizationDisabledDeploymentPausedReasonError)
    case memoryStoreArchivedError(BetaManagedAgentsMemoryStoreArchivedDeploymentPausedReasonError)
    case skillNotFoundError(BetaManagedAgentsSkillNotFoundDeploymentPausedReasonError)
    case vaultArchivedError(BetaManagedAgentsVaultArchivedDeploymentPausedReasonError)
    case unknownError(BetaManagedAgentsUnknownDeploymentPausedReasonError)
    case selfHostedResourcesUnsupportedError(BetaManagedAgentsSelfHostedResourcesUnsupportedDeploymentPausedReasonError)
    case mcpEgressBlockedError(BetaManagedAgentsMCPEgressBlockedDeploymentPausedReasonError)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "environment_archived_error": self = .environmentArchivedError(try BetaManagedAgentsEnvironmentArchivedDeploymentPausedReasonError(from: decoder))
        case "agent_archived_error": self = .agentArchivedError(try BetaManagedAgentsAgentArchivedDeploymentPausedReasonError(from: decoder))
        case "environment_not_found_error": self = .environmentNotFoundError(try BetaManagedAgentsEnvironmentNotFoundDeploymentPausedReasonError(from: decoder))
        case "vault_not_found_error": self = .vaultNotFoundError(try BetaManagedAgentsVaultNotFoundDeploymentPausedReasonError(from: decoder))
        case "file_not_found_error": self = .fileNotFoundError(try BetaManagedAgentsFileNotFoundDeploymentPausedReasonError(from: decoder))
        case "session_resource_not_found_error": self = .sessionResourceNotFoundError(try BetaManagedAgentsSessionResourceNotFoundDeploymentPausedReasonError(from: decoder))
        case "workspace_archived_error": self = .workspaceArchivedError(try BetaManagedAgentsWorkspaceArchivedDeploymentPausedReasonError(from: decoder))
        case "organization_disabled_error": self = .organizationDisabledError(try BetaManagedAgentsOrganizationDisabledDeploymentPausedReasonError(from: decoder))
        case "memory_store_archived_error": self = .memoryStoreArchivedError(try BetaManagedAgentsMemoryStoreArchivedDeploymentPausedReasonError(from: decoder))
        case "skill_not_found_error": self = .skillNotFoundError(try BetaManagedAgentsSkillNotFoundDeploymentPausedReasonError(from: decoder))
        case "vault_archived_error": self = .vaultArchivedError(try BetaManagedAgentsVaultArchivedDeploymentPausedReasonError(from: decoder))
        case "unknown_error": self = .unknownError(try BetaManagedAgentsUnknownDeploymentPausedReasonError(from: decoder))
        case "self_hosted_resources_unsupported_error": self = .selfHostedResourcesUnsupportedError(try BetaManagedAgentsSelfHostedResourcesUnsupportedDeploymentPausedReasonError(from: decoder))
        case "mcp_egress_blocked_error": self = .mcpEgressBlockedError(try BetaManagedAgentsMCPEgressBlockedDeploymentPausedReasonError(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .environmentArchivedError(let v): try v.encode(to: encoder)
        case .agentArchivedError(let v): try v.encode(to: encoder)
        case .environmentNotFoundError(let v): try v.encode(to: encoder)
        case .vaultNotFoundError(let v): try v.encode(to: encoder)
        case .fileNotFoundError(let v): try v.encode(to: encoder)
        case .sessionResourceNotFoundError(let v): try v.encode(to: encoder)
        case .workspaceArchivedError(let v): try v.encode(to: encoder)
        case .organizationDisabledError(let v): try v.encode(to: encoder)
        case .memoryStoreArchivedError(let v): try v.encode(to: encoder)
        case .skillNotFoundError(let v): try v.encode(to: encoder)
        case .vaultArchivedError(let v): try v.encode(to: encoder)
        case .unknownError(let v): try v.encode(to: encoder)
        case .selfHostedResourcesUnsupportedError(let v): try v.encode(to: encoder)
        case .mcpEgressBlockedError(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
