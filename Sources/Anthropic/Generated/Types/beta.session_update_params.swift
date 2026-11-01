// Transformed from `anthropic.types.beta.session_update_params` (session_update_params.py).

import Foundation

public struct SessionUpdateParams: Codable, Hashable, Sendable {
    /// Agent configuration update.
    ///
    /// Only `tools` and `mcp_servers` are updatable mid-session. Only valid for
    /// sessions created from an agent or deployment reference. The session must not be
    /// running.
    public var agent: BetaManagedAgentsSessionAgentUpdateParam?
    /// Enforced spend ceiling for the session.
    ///
    /// Set an object to replace the budget of a session that was created with one, or
    /// `null` to remove it; omit to preserve. A budget cannot be added to a session
    /// created without one (rejected with reason `budget_create_only`), and a removed
    /// budget cannot be re-added. Allowed in any non-terminated status. Lowering
    /// `max_list_cost` to at or below the session's consumed list cost is rejected with
    /// reason `budget_not_raised`, and every model the session can run must have a
    /// public list price or the request is rejected with reason `model_not_budgetable`.
    public var budget: BetaManagedAgentsBudgetLimitParam??
    /// Metadata patch.
    ///
    /// Set a key to a string to upsert it, or to null to delete it. Omit the field to
    /// preserve.
    public var metadata: [String: String?]??
    /// Human-readable session title.
    public var title: String??
    /// Vault IDs (`vlt_*`) to attach to the session.
    ///
    /// Not yet supported; requests setting this field are rejected. Reserved for future
    /// use.
    public var vaultIds: [String]?
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

    public init(agent: BetaManagedAgentsSessionAgentUpdateParam? = nil, budget: BetaManagedAgentsBudgetLimitParam?? = nil, metadata: [String: String?]?? = nil, title: String?? = nil, vaultIds: [String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.agent = agent
        self.budget = budget
        self.metadata = metadata
        self.title = title
        self.vaultIds = vaultIds
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case agent
        case budget
        case metadata
        case title
        case vaultIds = "vault_ids"
        case betas
        case workspaceId = "workspace_id"
    }
}
