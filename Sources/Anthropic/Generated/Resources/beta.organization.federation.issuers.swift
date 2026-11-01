// Transformed from `anthropic.resources.beta.organization.federation.issuers` (issuers.py).

import Foundation

public struct BetaOrganizationFederationIssuersResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Register an OIDC issuer that Anthropic will trust for workload identity
    /// federation in your organization.
    ///
    /// The `jwks` field controls how the issuer's signing keys are obtained and takes
    /// one of three shapes selected by `type`: `discovery` (resolve keys through OIDC
    /// discovery), `explicit_url` (fetch keys from a fixed JWKS URL), or `inline`
    /// (provide a static key set). When `jwks.type` is `discovery` and no
    /// `discovery_base` is set, the issuer URL must be publicly reachable over HTTPS so
    /// Anthropic can fetch the discovery document; for `explicit_url` and `inline`
    /// modes the issuer URL is only matched as the JWT's `iss` claim and is not
    /// fetched.
    ///
    /// Args:
    ///   issuer_url: The `iss` claim value to match against.
    ///
    ///   name: Slug identifier (lowercase, digits, hyphens). Unique within the organization; a
    ///       duplicate name returns 409.
    ///
    ///   check_jti: Whether the jwt-bearer exchange enforces JTI single-use (replay protection) for
    ///       tokens from this issuer. Defaults to true. Applies only to assertions carrying a
    ///       `jti` claim; tokens without one are accepted without single-use enforcement.
    ///
    ///   jwks: How signing keys are obtained. Defaults to OIDC discovery.
    ///
    ///   max_jwt_lifetime_seconds: Maximum allowed iat→exp spread for assertions from this issuer (1-176400
    ///       seconds, i.e. up to 49h). Defaults to 3600 (1h). Assertions must carry both
    ///       `iat` and `exp`; a missing `iat` is rejected.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func create(issuerURL: String, name: String, checkJti: Bool?? = nil, jwks: BetaOrganizationFederationIssuerCreateParams.JWKS? = nil, maxJwtLifetimeSeconds: Int?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaFederationIssuer {
        try await _create(issuerURL: issuerURL, name: name, checkJti: checkJti, jwks: jwks, maxJwtLifetimeSeconds: maxJwtLifetimeSeconds, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(issuerURL: String, name: String, checkJti: Bool?? = nil, jwks: BetaOrganizationFederationIssuerCreateParams.JWKS? = nil, maxJwtLifetimeSeconds: Int?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaFederationIssuer> {
        var body = ParamsBuilder()
        try body.set("issuer_url", issuerURL)
        try body.set("name", name)
        try body.set("check_jti", checkJti)
        try body.set("jwks", jwks)
        try body.set("max_jwt_lifetime_seconds", maxJwtLifetimeSeconds)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/federation_issuers", body: body, headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ","))]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.federation.issuers.create")
        return try await client.requestResponse(BetaFederationIssuer.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Retrieve a federation issuer by its ID (`fdis_...`).
    ///
    /// Args:
    ///   federation_issuer_id: ID of the federation issuer.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ federationIssuerID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaFederationIssuer {
        try await _retrieve(federationIssuerID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ federationIssuerID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaFederationIssuer> {
        try requireNonEmpty(federationIssuerID, "federation_issuer_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/federation_issuers/{federation_issuer_id}", ["federation_issuer_id": federationIssuerID]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ","))]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.federation.issuers.retrieve")
        return try await client.requestResponse(BetaFederationIssuer.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Partially update a federation issuer.
    ///
    /// Setting `jwks` replaces the full JWKS shape at once. Archived issuers cannot be
    /// updated; this returns 400. Create a new issuer instead.
    ///
    /// Updating an issuer that backs a rule with a scope outside `workspace:developer`
    /// or `workspace:inference` requires a Console session.
    ///
    /// Args:
    ///   federation_issuer_id: ID of the federation issuer to update.
    ///
    ///   check_jti: Whether the jwt-bearer exchange enforces JTI single-use (replay protection) for
    ///       tokens from this issuer. Applies only to assertions carrying a `jti` claim;
    ///       tokens without one are accepted without single-use enforcement.
    ///
    ///   issuer_url: Replaces the `iss` claim value to match against. For discovery-mode issuers
    ///       without a `discovery_base`, this is also the URL Anthropic fetches the OIDC
    ///       discovery document and signing keys from, so changing it repoints the JWKS
    ///       source. Changing the issuer URL to a well-known shared platform is rejected
    ///       while any live rule under this issuer would not constrain tenant identity.
    ///
    ///   jwks: Replaces the entire JWKS configuration.
    ///
    ///   jwks_polling_disabled: Only `false` is accepted, to re-enable polling after the system pauses it.
    ///       Polling is paused automatically; sending `true` is rejected.
    ///
    ///   max_jwt_lifetime_seconds: Maximum allowed iat→exp spread for assertions from this issuer (1-176400
    ///       seconds, i.e. up to 49h). Assertions must carry both `iat` and `exp`; a missing
    ///       `iat` is rejected.
    ///
    ///   name: Replaces the slug identifier (lowercase, digits, hyphens). Unique within the
    ///       organization; a duplicate name returns 409.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func update(_ federationIssuerID: String, checkJti: Bool?? = nil, issuerURL: String?? = nil, jwks: BetaOrganizationFederationIssuerUpdateParams.JWKS?? = nil, jwksPollingDisabled: Bool?? = nil, maxJwtLifetimeSeconds: Int?? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaFederationIssuer {
        try await _update(federationIssuerID, checkJti: checkJti, issuerURL: issuerURL, jwks: jwks, jwksPollingDisabled: jwksPollingDisabled, maxJwtLifetimeSeconds: maxJwtLifetimeSeconds, name: name, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ federationIssuerID: String, checkJti: Bool?? = nil, issuerURL: String?? = nil, jwks: BetaOrganizationFederationIssuerUpdateParams.JWKS?? = nil, jwksPollingDisabled: Bool?? = nil, maxJwtLifetimeSeconds: Int?? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaFederationIssuer> {
        try requireNonEmpty(federationIssuerID, "federation_issuer_id")
        var body = ParamsBuilder()
        try body.set("check_jti", checkJti)
        try body.set("issuer_url", issuerURL)
        try body.set("jwks", jwks)
        try body.set("jwks_polling_disabled", jwksPollingDisabled)
        try body.set("max_jwt_lifetime_seconds", maxJwtLifetimeSeconds)
        try body.set("name", name)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/federation_issuers/{federation_issuer_id}", ["federation_issuer_id": federationIssuerID]), body: body, headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ","))]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.federation.issuers.update")
        return try await client.requestResponse(BetaFederationIssuer.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List federation issuers in your organization.
    ///
    /// Archived issuers are excluded unless `include_archived=true`.
    ///
    /// Args:
    ///   include_archived: Include archived resources. Defaults to false.
    ///
    ///   limit: Number of results per page.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(includeArchived: Bool? = nil, limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaFederationIssuer> {
        try await _list(includeArchived: includeArchived, limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(includeArchived: Bool? = nil, limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaFederationIssuer>> {
        var query = ParamsBuilder()
        try query.set("include_archived", includeArchived)
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/federation_issuers", query: query, headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ","))]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.federation.issuers.list")
        return try await client.requestPageResponse(PageCursor<BetaFederationIssuer>.self, options, stream: _mode == .stream)
    }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Archive a federation issuer.
    ///
    /// Idempotent; re-archiving returns the issuer with its original `archived_at`.
    /// Rejected with 400 if any live (non-archived) federation rule still references
    /// the issuer; archive those rules first (a rule's issuer cannot be changed), or
    /// recreate them against another issuer.
    ///
    /// Args:
    ///   federation_issuer_id: ID of the federation issuer to archive.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func archive(_ federationIssuerID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaFederationIssuer {
        try await _archive(federationIssuerID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _archive(_ federationIssuerID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaFederationIssuer> {
        try requireNonEmpty(federationIssuerID, "federation_issuer_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/federation_issuers/{federation_issuer_id}/archive", ["federation_issuer_id": federationIssuerID]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ","))]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.federation.issuers.archive")
        return try await client.requestResponse(BetaFederationIssuer.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationFederationIssuersResource

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Register an OIDC issuer that Anthropic will trust for workload identity
    /// federation in your organization.
    ///
    /// The `jwks` field controls how the issuer's signing keys are obtained and takes
    /// one of three shapes selected by `type`: `discovery` (resolve keys through OIDC
    /// discovery), `explicit_url` (fetch keys from a fixed JWKS URL), or `inline`
    /// (provide a static key set). When `jwks.type` is `discovery` and no
    /// `discovery_base` is set, the issuer URL must be publicly reachable over HTTPS so
    /// Anthropic can fetch the discovery document; for `explicit_url` and `inline`
    /// modes the issuer URL is only matched as the JWT's `iss` claim and is not
    /// fetched.
    ///
    /// Args:
    ///   issuer_url: The `iss` claim value to match against.
    ///
    ///   name: Slug identifier (lowercase, digits, hyphens). Unique within the organization; a
    ///       duplicate name returns 409.
    ///
    ///   check_jti: Whether the jwt-bearer exchange enforces JTI single-use (replay protection) for
    ///       tokens from this issuer. Defaults to true. Applies only to assertions carrying a
    ///       `jti` claim; tokens without one are accepted without single-use enforcement.
    ///
    ///   jwks: How signing keys are obtained. Defaults to OIDC discovery.
    ///
    ///   max_jwt_lifetime_seconds: Maximum allowed iat→exp spread for assertions from this issuer (1-176400
    ///       seconds, i.e. up to 49h). Defaults to 3600 (1h). Assertions must carry both
    ///       `iat` and `exp`; a missing `iat` is rejected.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create(issuerURL: String, name: String, checkJti: Bool?? = nil, jwks: BetaOrganizationFederationIssuerCreateParams.JWKS? = nil, maxJwtLifetimeSeconds: Int?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaFederationIssuer> {
            try await resource._create(issuerURL: issuerURL, name: name, checkJti: checkJti, jwks: jwks, maxJwtLifetimeSeconds: maxJwtLifetimeSeconds, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Retrieve a federation issuer by its ID (`fdis_...`).
    ///
    /// Args:
    ///   federation_issuer_id: ID of the federation issuer.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ federationIssuerID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaFederationIssuer> {
            try await resource._retrieve(federationIssuerID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Partially update a federation issuer.
    ///
    /// Setting `jwks` replaces the full JWKS shape at once. Archived issuers cannot be
    /// updated; this returns 400. Create a new issuer instead.
    ///
    /// Updating an issuer that backs a rule with a scope outside `workspace:developer`
    /// or `workspace:inference` requires a Console session.
    ///
    /// Args:
    ///   federation_issuer_id: ID of the federation issuer to update.
    ///
    ///   check_jti: Whether the jwt-bearer exchange enforces JTI single-use (replay protection) for
    ///       tokens from this issuer. Applies only to assertions carrying a `jti` claim;
    ///       tokens without one are accepted without single-use enforcement.
    ///
    ///   issuer_url: Replaces the `iss` claim value to match against. For discovery-mode issuers
    ///       without a `discovery_base`, this is also the URL Anthropic fetches the OIDC
    ///       discovery document and signing keys from, so changing it repoints the JWKS
    ///       source. Changing the issuer URL to a well-known shared platform is rejected
    ///       while any live rule under this issuer would not constrain tenant identity.
    ///
    ///   jwks: Replaces the entire JWKS configuration.
    ///
    ///   jwks_polling_disabled: Only `false` is accepted, to re-enable polling after the system pauses it.
    ///       Polling is paused automatically; sending `true` is rejected.
    ///
    ///   max_jwt_lifetime_seconds: Maximum allowed iat→exp spread for assertions from this issuer (1-176400
    ///       seconds, i.e. up to 49h). Assertions must carry both `iat` and `exp`; a missing
    ///       `iat` is rejected.
    ///
    ///   name: Replaces the slug identifier (lowercase, digits, hyphens). Unique within the
    ///       organization; a duplicate name returns 409.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update(_ federationIssuerID: String, checkJti: Bool?? = nil, issuerURL: String?? = nil, jwks: BetaOrganizationFederationIssuerUpdateParams.JWKS?? = nil, jwksPollingDisabled: Bool?? = nil, maxJwtLifetimeSeconds: Int?? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaFederationIssuer> {
            try await resource._update(federationIssuerID, checkJti: checkJti, issuerURL: issuerURL, jwks: jwks, jwksPollingDisabled: jwksPollingDisabled, maxJwtLifetimeSeconds: maxJwtLifetimeSeconds, name: name, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List federation issuers in your organization.
    ///
    /// Archived issuers are excluded unless `include_archived=true`.
    ///
    /// Args:
    ///   include_archived: Include archived resources. Defaults to false.
    ///
    ///   limit: Number of results per page.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(includeArchived: Bool? = nil, limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaFederationIssuer>> {
            try await resource._list(includeArchived: includeArchived, limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Archive a federation issuer.
    ///
    /// Idempotent; re-archiving returns the issuer with its original `archived_at`.
    /// Rejected with 400 if any live (non-archived) federation rule still references
    /// the issuer; archive those rules first (a rule's issuer cannot be changed), or
    /// recreate them against another issuer.
    ///
    /// Args:
    ///   federation_issuer_id: ID of the federation issuer to archive.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func archive(_ federationIssuerID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaFederationIssuer> {
            try await resource._archive(federationIssuerID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationFederationIssuersResource

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Register an OIDC issuer that Anthropic will trust for workload identity
    /// federation in your organization.
    ///
    /// The `jwks` field controls how the issuer's signing keys are obtained and takes
    /// one of three shapes selected by `type`: `discovery` (resolve keys through OIDC
    /// discovery), `explicit_url` (fetch keys from a fixed JWKS URL), or `inline`
    /// (provide a static key set). When `jwks.type` is `discovery` and no
    /// `discovery_base` is set, the issuer URL must be publicly reachable over HTTPS so
    /// Anthropic can fetch the discovery document; for `explicit_url` and `inline`
    /// modes the issuer URL is only matched as the JWT's `iss` claim and is not
    /// fetched.
    ///
    /// Args:
    ///   issuer_url: The `iss` claim value to match against.
    ///
    ///   name: Slug identifier (lowercase, digits, hyphens). Unique within the organization; a
    ///       duplicate name returns 409.
    ///
    ///   check_jti: Whether the jwt-bearer exchange enforces JTI single-use (replay protection) for
    ///       tokens from this issuer. Defaults to true. Applies only to assertions carrying a
    ///       `jti` claim; tokens without one are accepted without single-use enforcement.
    ///
    ///   jwks: How signing keys are obtained. Defaults to OIDC discovery.
    ///
    ///   max_jwt_lifetime_seconds: Maximum allowed iat→exp spread for assertions from this issuer (1-176400
    ///       seconds, i.e. up to 49h). Defaults to 3600 (1h). Assertions must carry both
    ///       `iat` and `exp`; a missing `iat` is rejected.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create<R: Sendable>(issuerURL: String, name: String, checkJti: Bool?? = nil, jwks: BetaOrganizationFederationIssuerCreateParams.JWKS? = nil, maxJwtLifetimeSeconds: Int?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaFederationIssuer>) async throws -> R) async throws -> R {
            let response = try await resource._create(issuerURL: issuerURL, name: name, checkJti: checkJti, jwks: jwks, maxJwtLifetimeSeconds: maxJwtLifetimeSeconds, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Retrieve a federation issuer by its ID (`fdis_...`).
    ///
    /// Args:
    ///   federation_issuer_id: ID of the federation issuer.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ federationIssuerID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaFederationIssuer>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(federationIssuerID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Partially update a federation issuer.
    ///
    /// Setting `jwks` replaces the full JWKS shape at once. Archived issuers cannot be
    /// updated; this returns 400. Create a new issuer instead.
    ///
    /// Updating an issuer that backs a rule with a scope outside `workspace:developer`
    /// or `workspace:inference` requires a Console session.
    ///
    /// Args:
    ///   federation_issuer_id: ID of the federation issuer to update.
    ///
    ///   check_jti: Whether the jwt-bearer exchange enforces JTI single-use (replay protection) for
    ///       tokens from this issuer. Applies only to assertions carrying a `jti` claim;
    ///       tokens without one are accepted without single-use enforcement.
    ///
    ///   issuer_url: Replaces the `iss` claim value to match against. For discovery-mode issuers
    ///       without a `discovery_base`, this is also the URL Anthropic fetches the OIDC
    ///       discovery document and signing keys from, so changing it repoints the JWKS
    ///       source. Changing the issuer URL to a well-known shared platform is rejected
    ///       while any live rule under this issuer would not constrain tenant identity.
    ///
    ///   jwks: Replaces the entire JWKS configuration.
    ///
    ///   jwks_polling_disabled: Only `false` is accepted, to re-enable polling after the system pauses it.
    ///       Polling is paused automatically; sending `true` is rejected.
    ///
    ///   max_jwt_lifetime_seconds: Maximum allowed iat→exp spread for assertions from this issuer (1-176400
    ///       seconds, i.e. up to 49h). Assertions must carry both `iat` and `exp`; a missing
    ///       `iat` is rejected.
    ///
    ///   name: Replaces the slug identifier (lowercase, digits, hyphens). Unique within the
    ///       organization; a duplicate name returns 409.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update<R: Sendable>(_ federationIssuerID: String, checkJti: Bool?? = nil, issuerURL: String?? = nil, jwks: BetaOrganizationFederationIssuerUpdateParams.JWKS?? = nil, jwksPollingDisabled: Bool?? = nil, maxJwtLifetimeSeconds: Int?? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaFederationIssuer>) async throws -> R) async throws -> R {
            let response = try await resource._update(federationIssuerID, checkJti: checkJti, issuerURL: issuerURL, jwks: jwks, jwksPollingDisabled: jwksPollingDisabled, maxJwtLifetimeSeconds: maxJwtLifetimeSeconds, name: name, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// List federation issuers in your organization.
    ///
    /// Archived issuers are excluded unless `include_archived=true`.
    ///
    /// Args:
    ///   include_archived: Include archived resources. Defaults to false.
    ///
    ///   limit: Number of results per page.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(includeArchived: Bool? = nil, limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaFederationIssuer>>) async throws -> R) async throws -> R {
            let response = try await resource._list(includeArchived: includeArchived, limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// **Requires an OAuth access token with the `org:admin` scope**, from
    /// `ant auth login --scope org:admin` or a workload identity federation rule; Admin
    /// API keys are not accepted. See
    /// [Manage WIF with the Admin API](/docs/en/manage-claude/wif-admin-api).
    ///
    /// Archive a federation issuer.
    ///
    /// Idempotent; re-archiving returns the issuer with its original `archived_at`.
    /// Rejected with 400 if any live (non-archived) federation rule still references
    /// the issuer; archive those rules first (a rule's issuer cannot be changed), or
    /// recreate them against another issuer.
    ///
    /// Args:
    ///   federation_issuer_id: ID of the federation issuer to archive.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func archive<R: Sendable>(_ federationIssuerID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaFederationIssuer>) async throws -> R) async throws -> R {
            let response = try await resource._archive(federationIssuerID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
