// Transformed from `anthropic.resources.organization.federation.rules.rules` (rules.py).

import Foundation

public struct OrganizationFederationRulesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var workspaces: OrganizationFederationRulesWorkspacesResource { OrganizationFederationRulesWorkspacesResource(client: client) }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Create a federation rule owned by your organization.
    ///
    /// The referenced issuer and the target service account must already exist in the
    /// same organization; invalid references are rejected with a 400 error. The
    /// workspace reference is validated. Membership is not checked at rule creation:
    /// token exchange resolves a single enabled workspace per call and is rejected
    /// unless the target service account is a member of that workspace (it is
    /// implicitly a member of the default workspace). Rules on well-known shared
    /// issuers (GitHub Actions, GitLab, Buildkite, Terraform Cloud, Google) must
    /// constrain tenant identity via an identity-bearing claim, a tenant-pinning
    /// subject prefix (such as `repo:YOUR_ORG/...`), or a CEL condition referencing one
    /// of those identity claims (e.g. `claims.repository_owner`). OAuth callers may
    /// only manage rules whose `oauth_scope` is `workspace:developer` or
    /// `workspace:inference`; other scopes require a Console session.
    ///
    /// Args:
    ///   issuer_id: Tagged ID of the federation issuer.
    ///
    ///   match: Conditions the verified JWT must satisfy for this rule to apply. At least one of
    ///       `subject_prefix` (other than a wildcard-only value like `*`), `claims`, or
    ///       `condition` is required; `audience` alone is not sufficient.
    ///
    ///   name: Slug identifier (lowercase, digits, hyphens). Unique within the organization; a
    ///       duplicate name returns 409.
    ///
    ///   oauth_scope: Space-separated OAuth scopes. OAuth callers may only set `workspace:developer`
    ///       or `workspace:inference`; other scopes (such as `org:admin`) require a Console
    ///       session.
    ///
    ///   target: Identity that tokens minted via this rule act as. Currently always a
    ///       `service_account` target.
    ///
    ///   applies_to_all_workspaces: When true, enable this rule for every workspace in the org (including workspaces
    ///       created later).
    ///
    ///   description: Optional free-text description.
    ///
    ///   token_lifetime_seconds: Lifetime in seconds for access tokens minted via this rule (60-86400). Defaults
    ///       to 3600 (1h). Minted tokens are capped at
    ///       `max(60, min(this value, 2 × remaining assertion validity))` seconds.
    ///
    ///   workspace_id: Tagged ID of the workspace to enable this rule for. Required unless
    ///       `applies_to_all_workspaces` is true. Additional workspaces can be added via the
    ///       `/federation_rules/{federation_rule_id}/workspaces` sub-resource.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func create(issuerID: String, match: FederationRuleMatchParam, name: String, oauthScope: String, target: ServiceAccountTargetParam, appliesToAllWorkspaces: Bool? = nil, description: String?? = nil, tokenLifetimeSeconds: Int? = nil, workspaceID: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> FederationRule {
        try await _create(issuerID: issuerID, match: match, name: name, oauthScope: oauthScope, target: target, appliesToAllWorkspaces: appliesToAllWorkspaces, description: description, tokenLifetimeSeconds: tokenLifetimeSeconds, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(issuerID: String, match: FederationRuleMatchParam, name: String, oauthScope: String, target: ServiceAccountTargetParam, appliesToAllWorkspaces: Bool? = nil, description: String?? = nil, tokenLifetimeSeconds: Int? = nil, workspaceID: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<FederationRule> {
        var body = ParamsBuilder()
        try body.set("issuer_id", issuerID)
        try body.set("match", match)
        try body.set("name", name)
        try body.set("oauth_scope", oauthScope)
        try body.set("target", target)
        try body.set("applies_to_all_workspaces", appliesToAllWorkspaces)
        try body.set("description", description)
        try body.set("token_lifetime_seconds", tokenLifetimeSeconds)
        try body.set("workspace_id", workspaceID)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/federation_rules", body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.federation.rules.create", spanRoute: "/v1/organizations/federation_rules", spanCreatedID: SpanCreatedID("anthropic.organization.federation_rule.id"))
        return try await client.requestResponse(FederationRule.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Retrieve a federation rule by its ID (`fdrl_...`).
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ federationRuleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> FederationRule {
        try await _retrieve(federationRuleID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ federationRuleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<FederationRule> {
        try requireNonEmpty(federationRuleID, "federation_rule_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/federation_rules/{federation_rule_id}", ["federation_rule_id": federationRuleID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.federation.rules.retrieve", spanRoute: "/v1/organizations/federation_rules/{federation_rule_id}", spanAttributes: ["anthropic.organization.federation_rule.id": federationRuleID])
        return try await client.requestResponse(FederationRule.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Partially update a federation rule.
    ///
    /// `issuer_id` is immutable. `match` and `target` are replaced as whole objects
    /// when set. Referenced service accounts and workspaces must exist in your
    /// organization; invalid references are rejected with a 400 error. Archived rules
    /// cannot be updated; this returns 400. Create a new rule instead. Rules on
    /// well-known shared issuers (GitHub Actions, GitLab, Buildkite, Terraform Cloud,
    /// Google) must constrain tenant identity via an identity-bearing claim, a
    /// tenant-pinning subject prefix (such as `repo:YOUR_ORG/...`), or a CEL condition
    /// referencing one of those identity claims (e.g. `claims.repository_owner`). On
    /// these issuers the requirement is re-checked on every update; if an existing
    /// rule's stored match does not yet constrain tenant identity, any update (even a
    /// rename or description change) must also supply a conforming `match` in the same
    /// request. OAuth callers may only manage rules whose `oauth_scope` is
    /// `workspace:developer` or `workspace:inference`; other scopes require a Console
    /// session.
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule to update.
    ///
    ///   applies_to_all_workspaces: When true, enables this rule for every workspace in the org (including
    ///       workspaces created later). Setting `false` is rejected with 400 if no workspace
    ///       would remain enabled; a rule with only a legacy `workspace_id` binding continues
    ///       to mint.
    ///
    ///   description: Replaces the description. Omit to leave unchanged; send `null` to clear (the
    ///       field is stored as an empty string).
    ///
    ///   match: Replaces the entire match object. All populated matcher fields must pass.
    ///
    ///   name: Replaces the slug identifier (lowercase, digits, hyphens). Unique within the
    ///       organization; a duplicate name returns 409.
    ///
    ///   oauth_scope: Replaces the space-separated OAuth scopes granted on minted tokens. OAuth
    ///       callers may only set `workspace:developer` or `workspace:inference`; other
    ///       scopes (such as `org:admin`) require a Console session.
    ///
    ///   target: Replaces the entire target object. Currently always a `service_account` target.
    ///
    ///   token_lifetime_seconds: Replaces the lifetime in seconds for access tokens minted via this rule
    ///       (60-86400). Minted tokens are capped at
    ///       `max(60, min(this value, 2 × remaining assertion validity))` seconds.
    ///
    ///   workspace_id: Replaces the existing single workspace enablement (the previous one is removed).
    ///       Rejected with 400 if the rule is enabled for more than one workspace; use the
    ///       `/federation_rules/{federation_rule_id}/workspaces` sub-resource instead.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func update(_ federationRuleID: String, appliesToAllWorkspaces: Bool?? = nil, description: String?? = nil, match: FederationRuleMatchParam?? = nil, name: String?? = nil, oauthScope: String?? = nil, target: ServiceAccountTargetParam?? = nil, tokenLifetimeSeconds: Int?? = nil, workspaceID: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> FederationRule {
        try await _update(federationRuleID, appliesToAllWorkspaces: appliesToAllWorkspaces, description: description, match: match, name: name, oauthScope: oauthScope, target: target, tokenLifetimeSeconds: tokenLifetimeSeconds, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ federationRuleID: String, appliesToAllWorkspaces: Bool?? = nil, description: String?? = nil, match: FederationRuleMatchParam?? = nil, name: String?? = nil, oauthScope: String?? = nil, target: ServiceAccountTargetParam?? = nil, tokenLifetimeSeconds: Int?? = nil, workspaceID: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<FederationRule> {
        try requireNonEmpty(federationRuleID, "federation_rule_id")
        var body = ParamsBuilder()
        try body.set("applies_to_all_workspaces", appliesToAllWorkspaces)
        try body.set("description", description)
        try body.set("match", match)
        try body.set("name", name)
        try body.set("oauth_scope", oauthScope)
        try body.set("target", target)
        try body.set("token_lifetime_seconds", tokenLifetimeSeconds)
        try body.set("workspace_id", workspaceID)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/federation_rules/{federation_rule_id}", ["federation_rule_id": federationRuleID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.federation.rules.update", spanRoute: "/v1/organizations/federation_rules/{federation_rule_id}", spanAttributes: ["anthropic.organization.federation_rule.id": federationRuleID])
        return try await client.requestResponse(FederationRule.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List federation rules in your organization.
    ///
    /// Optionally filter by issuer with `issuer_id`. Archived rules are excluded unless
    /// `include_archived=true`.
    ///
    /// Args:
    ///   include_archived: Include archived resources. Defaults to false.
    ///
    ///   issuer_id: Filter to rules referencing this federation issuer.
    ///
    ///   limit: Number of results per page.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(includeArchived: Bool? = nil, issuerID: String?? = nil, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<FederationRule> {
        try await _list(includeArchived: includeArchived, issuerID: issuerID, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(includeArchived: Bool? = nil, issuerID: String?? = nil, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<FederationRule>> {
        var query = ParamsBuilder()
        try query.set("include_archived", includeArchived)
        try query.set("issuer_id", issuerID)
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/federation_rules", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.federation.rules.list", spanRoute: "/v1/organizations/federation_rules")
        return try await client.requestPageResponse(PageCursor<FederationRule>.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Archive a federation rule.
    ///
    /// Token exchange through this rule stops immediately. Idempotent; re-archiving
    /// returns the rule with its original `archived_at`. Archiving clears the rule's
    /// workspace targeting (`workspace_id` and `workspace_ids` are emptied). Tokens
    /// already minted before archive remain valid until they expire. OAuth callers may
    /// only manage rules whose `oauth_scope` is `workspace:developer` or
    /// `workspace:inference`; other scopes require a Console session.
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule to archive.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func archive(_ federationRuleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> FederationRule {
        try await _archive(federationRuleID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _archive(_ federationRuleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<FederationRule> {
        try requireNonEmpty(federationRuleID, "federation_rule_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/federation_rules/{federation_rule_id}/archive", ["federation_rule_id": federationRuleID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.federation.rules.archive", spanRoute: "/v1/organizations/federation_rules/{federation_rule_id}/archive", spanAttributes: ["anthropic.organization.federation_rule.id": federationRuleID])
        return try await client.requestResponse(FederationRule.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: OrganizationFederationRulesResource

        public var workspaces: OrganizationFederationRulesWorkspacesResource.WithRawResponse { resource.workspaces.withRawResponse }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Create a federation rule owned by your organization.
    ///
    /// The referenced issuer and the target service account must already exist in the
    /// same organization; invalid references are rejected with a 400 error. The
    /// workspace reference is validated. Membership is not checked at rule creation:
    /// token exchange resolves a single enabled workspace per call and is rejected
    /// unless the target service account is a member of that workspace (it is
    /// implicitly a member of the default workspace). Rules on well-known shared
    /// issuers (GitHub Actions, GitLab, Buildkite, Terraform Cloud, Google) must
    /// constrain tenant identity via an identity-bearing claim, a tenant-pinning
    /// subject prefix (such as `repo:YOUR_ORG/...`), or a CEL condition referencing one
    /// of those identity claims (e.g. `claims.repository_owner`). OAuth callers may
    /// only manage rules whose `oauth_scope` is `workspace:developer` or
    /// `workspace:inference`; other scopes require a Console session.
    ///
    /// Args:
    ///   issuer_id: Tagged ID of the federation issuer.
    ///
    ///   match: Conditions the verified JWT must satisfy for this rule to apply. At least one of
    ///       `subject_prefix` (other than a wildcard-only value like `*`), `claims`, or
    ///       `condition` is required; `audience` alone is not sufficient.
    ///
    ///   name: Slug identifier (lowercase, digits, hyphens). Unique within the organization; a
    ///       duplicate name returns 409.
    ///
    ///   oauth_scope: Space-separated OAuth scopes. OAuth callers may only set `workspace:developer`
    ///       or `workspace:inference`; other scopes (such as `org:admin`) require a Console
    ///       session.
    ///
    ///   target: Identity that tokens minted via this rule act as. Currently always a
    ///       `service_account` target.
    ///
    ///   applies_to_all_workspaces: When true, enable this rule for every workspace in the org (including workspaces
    ///       created later).
    ///
    ///   description: Optional free-text description.
    ///
    ///   token_lifetime_seconds: Lifetime in seconds for access tokens minted via this rule (60-86400). Defaults
    ///       to 3600 (1h). Minted tokens are capped at
    ///       `max(60, min(this value, 2 × remaining assertion validity))` seconds.
    ///
    ///   workspace_id: Tagged ID of the workspace to enable this rule for. Required unless
    ///       `applies_to_all_workspaces` is true. Additional workspaces can be added via the
    ///       `/federation_rules/{federation_rule_id}/workspaces` sub-resource.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create(issuerID: String, match: FederationRuleMatchParam, name: String, oauthScope: String, target: ServiceAccountTargetParam, appliesToAllWorkspaces: Bool? = nil, description: String?? = nil, tokenLifetimeSeconds: Int? = nil, workspaceID: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<FederationRule> {
            try await resource._create(issuerID: issuerID, match: match, name: name, oauthScope: oauthScope, target: target, appliesToAllWorkspaces: appliesToAllWorkspaces, description: description, tokenLifetimeSeconds: tokenLifetimeSeconds, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Retrieve a federation rule by its ID (`fdrl_...`).
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ federationRuleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<FederationRule> {
            try await resource._retrieve(federationRuleID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Partially update a federation rule.
    ///
    /// `issuer_id` is immutable. `match` and `target` are replaced as whole objects
    /// when set. Referenced service accounts and workspaces must exist in your
    /// organization; invalid references are rejected with a 400 error. Archived rules
    /// cannot be updated; this returns 400. Create a new rule instead. Rules on
    /// well-known shared issuers (GitHub Actions, GitLab, Buildkite, Terraform Cloud,
    /// Google) must constrain tenant identity via an identity-bearing claim, a
    /// tenant-pinning subject prefix (such as `repo:YOUR_ORG/...`), or a CEL condition
    /// referencing one of those identity claims (e.g. `claims.repository_owner`). On
    /// these issuers the requirement is re-checked on every update; if an existing
    /// rule's stored match does not yet constrain tenant identity, any update (even a
    /// rename or description change) must also supply a conforming `match` in the same
    /// request. OAuth callers may only manage rules whose `oauth_scope` is
    /// `workspace:developer` or `workspace:inference`; other scopes require a Console
    /// session.
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule to update.
    ///
    ///   applies_to_all_workspaces: When true, enables this rule for every workspace in the org (including
    ///       workspaces created later). Setting `false` is rejected with 400 if no workspace
    ///       would remain enabled; a rule with only a legacy `workspace_id` binding continues
    ///       to mint.
    ///
    ///   description: Replaces the description. Omit to leave unchanged; send `null` to clear (the
    ///       field is stored as an empty string).
    ///
    ///   match: Replaces the entire match object. All populated matcher fields must pass.
    ///
    ///   name: Replaces the slug identifier (lowercase, digits, hyphens). Unique within the
    ///       organization; a duplicate name returns 409.
    ///
    ///   oauth_scope: Replaces the space-separated OAuth scopes granted on minted tokens. OAuth
    ///       callers may only set `workspace:developer` or `workspace:inference`; other
    ///       scopes (such as `org:admin`) require a Console session.
    ///
    ///   target: Replaces the entire target object. Currently always a `service_account` target.
    ///
    ///   token_lifetime_seconds: Replaces the lifetime in seconds for access tokens minted via this rule
    ///       (60-86400). Minted tokens are capped at
    ///       `max(60, min(this value, 2 × remaining assertion validity))` seconds.
    ///
    ///   workspace_id: Replaces the existing single workspace enablement (the previous one is removed).
    ///       Rejected with 400 if the rule is enabled for more than one workspace; use the
    ///       `/federation_rules/{federation_rule_id}/workspaces` sub-resource instead.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update(_ federationRuleID: String, appliesToAllWorkspaces: Bool?? = nil, description: String?? = nil, match: FederationRuleMatchParam?? = nil, name: String?? = nil, oauthScope: String?? = nil, target: ServiceAccountTargetParam?? = nil, tokenLifetimeSeconds: Int?? = nil, workspaceID: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<FederationRule> {
            try await resource._update(federationRuleID, appliesToAllWorkspaces: appliesToAllWorkspaces, description: description, match: match, name: name, oauthScope: oauthScope, target: target, tokenLifetimeSeconds: tokenLifetimeSeconds, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List federation rules in your organization.
    ///
    /// Optionally filter by issuer with `issuer_id`. Archived rules are excluded unless
    /// `include_archived=true`.
    ///
    /// Args:
    ///   include_archived: Include archived resources. Defaults to false.
    ///
    ///   issuer_id: Filter to rules referencing this federation issuer.
    ///
    ///   limit: Number of results per page.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(includeArchived: Bool? = nil, issuerID: String?? = nil, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<FederationRule>> {
            try await resource._list(includeArchived: includeArchived, issuerID: issuerID, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Archive a federation rule.
    ///
    /// Token exchange through this rule stops immediately. Idempotent; re-archiving
    /// returns the rule with its original `archived_at`. Archiving clears the rule's
    /// workspace targeting (`workspace_id` and `workspace_ids` are emptied). Tokens
    /// already minted before archive remain valid until they expire. OAuth callers may
    /// only manage rules whose `oauth_scope` is `workspace:developer` or
    /// `workspace:inference`; other scopes require a Console session.
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule to archive.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func archive(_ federationRuleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<FederationRule> {
            try await resource._archive(federationRuleID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: OrganizationFederationRulesResource

        public var workspaces: OrganizationFederationRulesWorkspacesResource.WithStreamingResponse { resource.workspaces.withStreamingResponse }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Create a federation rule owned by your organization.
    ///
    /// The referenced issuer and the target service account must already exist in the
    /// same organization; invalid references are rejected with a 400 error. The
    /// workspace reference is validated. Membership is not checked at rule creation:
    /// token exchange resolves a single enabled workspace per call and is rejected
    /// unless the target service account is a member of that workspace (it is
    /// implicitly a member of the default workspace). Rules on well-known shared
    /// issuers (GitHub Actions, GitLab, Buildkite, Terraform Cloud, Google) must
    /// constrain tenant identity via an identity-bearing claim, a tenant-pinning
    /// subject prefix (such as `repo:YOUR_ORG/...`), or a CEL condition referencing one
    /// of those identity claims (e.g. `claims.repository_owner`). OAuth callers may
    /// only manage rules whose `oauth_scope` is `workspace:developer` or
    /// `workspace:inference`; other scopes require a Console session.
    ///
    /// Args:
    ///   issuer_id: Tagged ID of the federation issuer.
    ///
    ///   match: Conditions the verified JWT must satisfy for this rule to apply. At least one of
    ///       `subject_prefix` (other than a wildcard-only value like `*`), `claims`, or
    ///       `condition` is required; `audience` alone is not sufficient.
    ///
    ///   name: Slug identifier (lowercase, digits, hyphens). Unique within the organization; a
    ///       duplicate name returns 409.
    ///
    ///   oauth_scope: Space-separated OAuth scopes. OAuth callers may only set `workspace:developer`
    ///       or `workspace:inference`; other scopes (such as `org:admin`) require a Console
    ///       session.
    ///
    ///   target: Identity that tokens minted via this rule act as. Currently always a
    ///       `service_account` target.
    ///
    ///   applies_to_all_workspaces: When true, enable this rule for every workspace in the org (including workspaces
    ///       created later).
    ///
    ///   description: Optional free-text description.
    ///
    ///   token_lifetime_seconds: Lifetime in seconds for access tokens minted via this rule (60-86400). Defaults
    ///       to 3600 (1h). Minted tokens are capped at
    ///       `max(60, min(this value, 2 × remaining assertion validity))` seconds.
    ///
    ///   workspace_id: Tagged ID of the workspace to enable this rule for. Required unless
    ///       `applies_to_all_workspaces` is true. Additional workspaces can be added via the
    ///       `/federation_rules/{federation_rule_id}/workspaces` sub-resource.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create<R: Sendable>(issuerID: String, match: FederationRuleMatchParam, name: String, oauthScope: String, target: ServiceAccountTargetParam, appliesToAllWorkspaces: Bool? = nil, description: String?? = nil, tokenLifetimeSeconds: Int? = nil, workspaceID: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<FederationRule>) async throws -> R) async throws -> R {
            let response = try await resource._create(issuerID: issuerID, match: match, name: name, oauthScope: oauthScope, target: target, appliesToAllWorkspaces: appliesToAllWorkspaces, description: description, tokenLifetimeSeconds: tokenLifetimeSeconds, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Retrieve a federation rule by its ID (`fdrl_...`).
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ federationRuleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<FederationRule>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(federationRuleID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Partially update a federation rule.
    ///
    /// `issuer_id` is immutable. `match` and `target` are replaced as whole objects
    /// when set. Referenced service accounts and workspaces must exist in your
    /// organization; invalid references are rejected with a 400 error. Archived rules
    /// cannot be updated; this returns 400. Create a new rule instead. Rules on
    /// well-known shared issuers (GitHub Actions, GitLab, Buildkite, Terraform Cloud,
    /// Google) must constrain tenant identity via an identity-bearing claim, a
    /// tenant-pinning subject prefix (such as `repo:YOUR_ORG/...`), or a CEL condition
    /// referencing one of those identity claims (e.g. `claims.repository_owner`). On
    /// these issuers the requirement is re-checked on every update; if an existing
    /// rule's stored match does not yet constrain tenant identity, any update (even a
    /// rename or description change) must also supply a conforming `match` in the same
    /// request. OAuth callers may only manage rules whose `oauth_scope` is
    /// `workspace:developer` or `workspace:inference`; other scopes require a Console
    /// session.
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule to update.
    ///
    ///   applies_to_all_workspaces: When true, enables this rule for every workspace in the org (including
    ///       workspaces created later). Setting `false` is rejected with 400 if no workspace
    ///       would remain enabled; a rule with only a legacy `workspace_id` binding continues
    ///       to mint.
    ///
    ///   description: Replaces the description. Omit to leave unchanged; send `null` to clear (the
    ///       field is stored as an empty string).
    ///
    ///   match: Replaces the entire match object. All populated matcher fields must pass.
    ///
    ///   name: Replaces the slug identifier (lowercase, digits, hyphens). Unique within the
    ///       organization; a duplicate name returns 409.
    ///
    ///   oauth_scope: Replaces the space-separated OAuth scopes granted on minted tokens. OAuth
    ///       callers may only set `workspace:developer` or `workspace:inference`; other
    ///       scopes (such as `org:admin`) require a Console session.
    ///
    ///   target: Replaces the entire target object. Currently always a `service_account` target.
    ///
    ///   token_lifetime_seconds: Replaces the lifetime in seconds for access tokens minted via this rule
    ///       (60-86400). Minted tokens are capped at
    ///       `max(60, min(this value, 2 × remaining assertion validity))` seconds.
    ///
    ///   workspace_id: Replaces the existing single workspace enablement (the previous one is removed).
    ///       Rejected with 400 if the rule is enabled for more than one workspace; use the
    ///       `/federation_rules/{federation_rule_id}/workspaces` sub-resource instead.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update<R: Sendable>(_ federationRuleID: String, appliesToAllWorkspaces: Bool?? = nil, description: String?? = nil, match: FederationRuleMatchParam?? = nil, name: String?? = nil, oauthScope: String?? = nil, target: ServiceAccountTargetParam?? = nil, tokenLifetimeSeconds: Int?? = nil, workspaceID: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<FederationRule>) async throws -> R) async throws -> R {
            let response = try await resource._update(federationRuleID, appliesToAllWorkspaces: appliesToAllWorkspaces, description: description, match: match, name: name, oauthScope: oauthScope, target: target, tokenLifetimeSeconds: tokenLifetimeSeconds, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List federation rules in your organization.
    ///
    /// Optionally filter by issuer with `issuer_id`. Archived rules are excluded unless
    /// `include_archived=true`.
    ///
    /// Args:
    ///   include_archived: Include archived resources. Defaults to false.
    ///
    ///   issuer_id: Filter to rules referencing this federation issuer.
    ///
    ///   limit: Number of results per page.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(includeArchived: Bool? = nil, issuerID: String?? = nil, limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<FederationRule>>) async throws -> R) async throws -> R {
            let response = try await resource._list(includeArchived: includeArchived, issuerID: issuerID, limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Archive a federation rule.
    ///
    /// Token exchange through this rule stops immediately. Idempotent; re-archiving
    /// returns the rule with its original `archived_at`. Archiving clears the rule's
    /// workspace targeting (`workspace_id` and `workspace_ids` are emptied). Tokens
    /// already minted before archive remain valid until they expire. OAuth callers may
    /// only manage rules whose `oauth_scope` is `workspace:developer` or
    /// `workspace:inference`; other scopes require a Console session.
    ///
    /// Args:
    ///   federation_rule_id: ID of the federation rule to archive.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func archive<R: Sendable>(_ federationRuleID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<FederationRule>) async throws -> R) async throws -> R {
            let response = try await resource._archive(federationRuleID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
