// Transformed from `anthropic.types.organization.federation.rule_update_params` (rule_update_params.py).

import Foundation

public struct RuleUpdateParams: Codable, Hashable, Sendable {
    /// When true, enables this rule for every workspace in the org (including
    /// workspaces created later). Setting `false` is rejected with 400 if no workspace
    /// would remain enabled; a rule with only a legacy `workspace_id` binding continues
    /// to mint.
    public var appliesToAllWorkspaces: Bool??
    /// Replaces the description.
    ///
    /// Omit to leave unchanged; send `null` to clear (the field is stored as an empty
    /// string).
    public var description: String??
    /// Replaces the entire match object. All populated matcher fields must pass.
    public var match: FederationRuleMatchParam??
    /// Replaces the slug identifier (lowercase, digits, hyphens).
    ///
    /// Unique within the organization; a duplicate name returns 409.
    public var name: String??
    /// Replaces the space-separated OAuth scopes granted on minted tokens.
    ///
    /// OAuth callers may only set `workspace:developer` or `workspace:inference`; other
    /// scopes (such as `org:admin`) require a Console session.
    public var oauthScope: String??
    /// Replaces the entire target object. Currently always a `service_account` target.
    public var target: ServiceAccountTargetParam??
    /// Replaces the lifetime in seconds for access tokens minted via this rule
    /// (60-86400). Minted tokens are capped at
    /// `max(60, min(this value, 2 × remaining assertion validity))` seconds.
    public var tokenLifetimeSeconds: Int??
    /// Replaces the existing single workspace enablement (the previous one is removed).
    ///
    /// Rejected with 400 if the rule is enabled for more than one workspace; use the
    /// `/federation_rules/{federation_rule_id}/workspaces` sub-resource instead.
    public var workspaceID: String??

    public init(appliesToAllWorkspaces: Bool?? = nil, description: String?? = nil, match: FederationRuleMatchParam?? = nil, name: String?? = nil, oauthScope: String?? = nil, target: ServiceAccountTargetParam?? = nil, tokenLifetimeSeconds: Int?? = nil, workspaceID: String?? = nil) {
        self.appliesToAllWorkspaces = appliesToAllWorkspaces
        self.description = description
        self.match = match
        self.name = name
        self.oauthScope = oauthScope
        self.target = target
        self.tokenLifetimeSeconds = tokenLifetimeSeconds
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case appliesToAllWorkspaces = "applies_to_all_workspaces"
        case description
        case match
        case name
        case oauthScope = "oauth_scope"
        case target
        case tokenLifetimeSeconds = "token_lifetime_seconds"
        case workspaceID = "workspace_id"
    }
}
