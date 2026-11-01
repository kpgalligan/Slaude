// Transformed from `anthropic.types.beta.organization.spend_limit_list_params` (spend_limit_list_params.py).

import Foundation

public struct SpendLimitListParams: Codable, Hashable, Sendable {
    /// Maximum number of limits per page. Defaults to `20`.
    public var limit: Int?
    /// Opaque cursor from a previous response's `next_page` field.
    public var page: String??
    /// Return only limits with these scope types.
    ///
    /// Omit for all. A scope type that doesn't apply to the organization gets a 400
    /// error.
    public var scopeType: [ScopeType]??
    /// Return only the limits whose `scope.workspace_id` is this workspace
    /// (`wrkspc_...`). Claude Console organizations only; other organizations get a 400
    /// error.
    public var workspaceID: String??
    /// This endpoint is in beta: requests must send `spend-limit-reads-2026-09-26` in
    /// this header.
    public var betas: [AnthropicBetaParam]?

    public init(limit: Int? = nil, page: String?? = nil, scopeType: [ScopeType]?? = nil, workspaceID: String?? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.limit = limit
        self.page = page
        self.scopeType = scopeType
        self.workspaceID = workspaceID
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case limit
        case page
        case scopeType = "scope_type"
        case workspaceID = "workspace_id"
        case betas
    }

    public enum ScopeType: OpenEnum, CaseIterable {
        case organization
        case organizationService
        case rbacGroup
        case seatTier
        case usageTier
        case user
        case workspace
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [ScopeType] = [.organization, .organizationService, .rbacGroup, .seatTier, .usageTier, .user, .workspace]

        public init(rawValue: String) {
            switch rawValue {
            case "organization": self = .organization
            case "organization_service": self = .organizationService
            case "rbac_group": self = .rbacGroup
            case "seat_tier": self = .seatTier
            case "usage_tier": self = .usageTier
            case "user": self = .user
            case "workspace": self = .workspace
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .organization: return "organization"
            case .organizationService: return "organization_service"
            case .rbacGroup: return "rbac_group"
            case .seatTier: return "seat_tier"
            case .usageTier: return "usage_tier"
            case .user: return "user"
            case .workspace: return "workspace"
            case .unknown(let value): return value
            }
        }
    }
}
