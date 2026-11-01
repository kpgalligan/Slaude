// Transformed from `anthropic.types.organization.federation.federation_rule` (federation_rule.py).

import Foundation

/// Authorization rule binding an external OIDC identity to Anthropic.
///
/// Evaluates the match conditions and mints an OAuth access token for the
/// resolved target, scoped to a single workspace where the rule is enabled
/// (chosen by the caller at exchange time when the rule is enabled for more
/// than one). For rules enabled via `workspace_ids` or
/// `applies_to_all_workspaces`, the target service account must be a member
/// of that workspace (it is implicitly a member of the default workspace);
/// rules carrying only the legacy `workspace_id` binding do not enforce
/// this.
public struct FederationRule: Codable, Hashable, Sendable {
    /// Tagged ID of the federation rule.
    public var id: String
    /// When true, this rule is enabled for every workspace in the org (including ones
    /// created after the rule). `workspace_ids` is ignored at exchange time.
    public var appliesToAllWorkspaces: Bool
    /// If set, this rule is archived and rejects token exchange.
    public var archivedAt: Date?
    /// Tagged ID (`user_`/`svac_`) of the actor that archived this rule.
    public var archivedByActorID: String?
    /// When this rule was created.
    public var createdAt: Date
    /// Tagged ID (`user_`/`svac_`) of the actor that created this rule.
    public var createdByActorID: String?
    /// Optional free-text description.
    public var description: String?
    /// Tagged ID of the issuer whose tokens this rule accepts.
    public var issuerID: String
    /// Issuer's display name at read time.
    public var issuerName: String?
    /// Conditions the verified JWT must satisfy for this rule to apply.
    ///
    /// All populated matcher fields must pass.
    public var match: FederationRuleMatch
    /// Admin-chosen slug identifier.
    public var name: String
    /// Space-separated OAuth scopes granted on the minted token.
    public var oauthScope: String
    /// What this rule targets.
    ///
    /// Check `type` before reading the other fields. Tokens minted via a rule whose
    /// target `type` is `service_account` act as that service account.
    public var target: ServiceAccountTarget
    /// Lifetime in seconds of access tokens minted via this rule.
    ///
    /// Minted tokens are capped at
    /// `max(60, min(this value, 2 × remaining assertion validity))` seconds.
    public var tokenLifetimeSeconds: Int
    public var type: String
    /// When this rule was last updated.
    public var updatedAt: Date
    /// Tagged ID (`user_`/`svac_`) of the actor that last updated this rule.
    public var updatedByActorID: String?
    /// Tagged IDs of the workspaces this rule is enabled for.
    ///
    /// May be empty for older rules that only carry the legacy `workspace_id` binding.
    /// Ignored at exchange time when `applies_to_all_workspaces` is true (the list may
    /// still be non-empty).
    public var workspaceIDs: [String]

    public init(id: String, appliesToAllWorkspaces: Bool, archivedAt: Date? = nil, archivedByActorID: String? = nil, createdAt: Date, createdByActorID: String? = nil, description: String? = nil, issuerID: String, issuerName: String? = nil, match: FederationRuleMatch, name: String, oauthScope: String, target: ServiceAccountTarget, tokenLifetimeSeconds: Int, type: String = "federation_rule", updatedAt: Date, updatedByActorID: String? = nil, workspaceIDs: [String]) {
        self.id = id
        self.appliesToAllWorkspaces = appliesToAllWorkspaces
        self.archivedAt = archivedAt
        self.archivedByActorID = archivedByActorID
        self.createdAt = createdAt
        self.createdByActorID = createdByActorID
        self.description = description
        self.issuerID = issuerID
        self.issuerName = issuerName
        self.match = match
        self.name = name
        self.oauthScope = oauthScope
        self.target = target
        self.tokenLifetimeSeconds = tokenLifetimeSeconds
        self.type = type
        self.updatedAt = updatedAt
        self.updatedByActorID = updatedByActorID
        self.workspaceIDs = workspaceIDs
    }

    enum CodingKeys: String, CodingKey {
        case id
        case appliesToAllWorkspaces = "applies_to_all_workspaces"
        case archivedAt = "archived_at"
        case archivedByActorID = "archived_by_actor_id"
        case createdAt = "created_at"
        case createdByActorID = "created_by_actor_id"
        case description
        case issuerID = "issuer_id"
        case issuerName = "issuer_name"
        case match
        case name
        case oauthScope = "oauth_scope"
        case target
        case tokenLifetimeSeconds = "token_lifetime_seconds"
        case type
        case updatedAt = "updated_at"
        case updatedByActorID = "updated_by_actor_id"
        case workspaceIDs = "workspace_ids"
    }
}
