// Transformed from `anthropic.types.organization.federation.rule_create_params` (rule_create_params.py).

import Foundation

public struct RuleCreateParams: Codable, Hashable, Sendable {
    /// Tagged ID of the federation issuer.
    public var issuerID: String
    /// Conditions the verified JWT must satisfy for this rule to apply.
    ///
    /// At least one of `subject_prefix` (other than a wildcard-only value like `*`),
    /// `claims`, or `condition` is required; `audience` alone is not sufficient.
    public var match: FederationRuleMatchParam
    /// Slug identifier (lowercase, digits, hyphens).
    ///
    /// Unique within the organization; a duplicate name returns 409.
    public var name: String
    /// Space-separated OAuth scopes.
    ///
    /// OAuth callers may only set `workspace:developer` or `workspace:inference`; other
    /// scopes (such as `org:admin`) require a Console session.
    public var oauthScope: String
    /// Identity that tokens minted via this rule act as.
    ///
    /// Currently always a `service_account` target.
    public var target: ServiceAccountTargetParam
    /// When true, enable this rule for every workspace in the org (including workspaces
    /// created later).
    public var appliesToAllWorkspaces: Bool?
    /// Optional free-text description.
    public var description: String??
    /// Lifetime in seconds for access tokens minted via this rule (60-86400).
    ///
    /// Defaults to 3600 (1h). Minted tokens are capped at
    /// `max(60, min(this value, 2 × remaining assertion validity))` seconds.
    public var tokenLifetimeSeconds: Int?
    /// Tagged ID of the workspace to enable this rule for.
    ///
    /// Required unless `applies_to_all_workspaces` is true. Additional workspaces can
    /// be added via the `/federation_rules/{federation_rule_id}/workspaces`
    /// sub-resource.
    public var workspaceID: String??

    public init(issuerID: String, match: FederationRuleMatchParam, name: String, oauthScope: String, target: ServiceAccountTargetParam, appliesToAllWorkspaces: Bool? = nil, description: String?? = nil, tokenLifetimeSeconds: Int? = nil, workspaceID: String?? = nil) {
        self.issuerID = issuerID
        self.match = match
        self.name = name
        self.oauthScope = oauthScope
        self.target = target
        self.appliesToAllWorkspaces = appliesToAllWorkspaces
        self.description = description
        self.tokenLifetimeSeconds = tokenLifetimeSeconds
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case issuerID = "issuer_id"
        case match
        case name
        case oauthScope = "oauth_scope"
        case target
        case appliesToAllWorkspaces = "applies_to_all_workspaces"
        case description
        case tokenLifetimeSeconds = "token_lifetime_seconds"
        case workspaceID = "workspace_id"
    }
}
