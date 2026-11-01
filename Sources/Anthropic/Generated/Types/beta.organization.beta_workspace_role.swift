// Transformed from `anthropic.types.beta.organization.beta_workspace_role` (beta_workspace_role.py).

import Foundation

public enum BetaWorkspaceRole: OpenEnum, CaseIterable {
    case workspaceAdmin
    case workspaceBilling
    case workspaceDeveloper
    case workspaceRestrictedDeveloper
    case workspaceUser
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaWorkspaceRole] = [.workspaceAdmin, .workspaceBilling, .workspaceDeveloper, .workspaceRestrictedDeveloper, .workspaceUser]

    public init(rawValue: String) {
        switch rawValue {
        case "workspace_admin": self = .workspaceAdmin
        case "workspace_billing": self = .workspaceBilling
        case "workspace_developer": self = .workspaceDeveloper
        case "workspace_restricted_developer": self = .workspaceRestrictedDeveloper
        case "workspace_user": self = .workspaceUser
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .workspaceAdmin: return "workspace_admin"
        case .workspaceBilling: return "workspace_billing"
        case .workspaceDeveloper: return "workspace_developer"
        case .workspaceRestrictedDeveloper: return "workspace_restricted_developer"
        case .workspaceUser: return "workspace_user"
        case .unknown(let value): return value
        }
    }
}
