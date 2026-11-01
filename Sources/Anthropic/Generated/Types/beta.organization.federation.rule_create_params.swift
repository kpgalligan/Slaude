// Transformed from `anthropic.types.beta.organization.federation.rule_create_params` (rule_create_params.py).

import Foundation

public struct BetaOrganizationFederationRuleCreateParams: Codable, Hashable, Sendable {
    /// Tagged ID of the federation issuer.
    public var issuerId: String
    /// Conditions the verified JWT must satisfy for this rule to apply.
    ///
    /// At least one of `subject_prefix` (other than a wildcard-only value like `*`),
    /// `claims`, or `condition` is required; `audience` alone is not sufficient.
    public var match: BetaFederationRuleMatchParam
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
    public var target: BetaServiceAccountTargetParam
    /// When true, enable this rule for every workspace in the org (including workspaces
    /// created later).
    public var appliesToAllWorkspaces: Bool?
    /// CEL expressions `{name: expr}` extracting named values from claims.
    ///
    /// Not yet supported; any non-empty value is rejected with 400.
    public var attributes: [String: String]??
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
    public var workspaceId: String??
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?

    public init(issuerId: String, match: BetaFederationRuleMatchParam, name: String, oauthScope: String, target: BetaServiceAccountTargetParam, appliesToAllWorkspaces: Bool? = nil, attributes: [String: String]?? = nil, description: String?? = nil, tokenLifetimeSeconds: Int? = nil, workspaceId: String?? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.issuerId = issuerId
        self.match = match
        self.name = name
        self.oauthScope = oauthScope
        self.target = target
        self.appliesToAllWorkspaces = appliesToAllWorkspaces
        self.attributes = attributes
        self.description = description
        self.tokenLifetimeSeconds = tokenLifetimeSeconds
        self.workspaceId = workspaceId
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case issuerId = "issuer_id"
        case match
        case name
        case oauthScope = "oauth_scope"
        case target
        case appliesToAllWorkspaces = "applies_to_all_workspaces"
        case attributes
        case description
        case tokenLifetimeSeconds = "token_lifetime_seconds"
        case workspaceId = "workspace_id"
        case betas
    }
}
