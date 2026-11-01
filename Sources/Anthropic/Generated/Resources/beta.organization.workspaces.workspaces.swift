// Transformed from `anthropic.resources.beta.organization.workspaces.workspaces` (workspaces.py).

import Foundation

public struct BetaOrganizationWorkspacesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var rateLimits: BetaOrganizationWorkspacesRateLimitsResource { BetaOrganizationWorkspacesRateLimitsResource(client: client) }

    public var members: BetaOrganizationWorkspacesMembersResource { BetaOrganizationWorkspacesMembersResource(client: client) }

    public var serviceAccounts: BetaOrganizationWorkspacesServiceAccountsResource { BetaOrganizationWorkspacesServiceAccountsResource(client: client) }

    /// Create Workspace
    ///
    /// Args:
    ///   name: Name of the Workspace.
    ///
    ///   data_residency: Data residency configuration for the workspace. If omitted, defaults to
    ///       `workspace_geo: "us"`, `allowed_inference_geos: "unrestricted"`, and
    ///       `default_inference_geo: "global"`.
    ///
    ///   display_color: Hex color code representing the Workspace in the Anthropic Console.
    ///
    ///   external_key_id: ID of the customer-managed encryption key (CMEK) configuration to use for this
    ///       Workspace. Setting this field requires CMEK to be enabled for your organization.
    ///       When set, data stored for this Workspace is encrypted with the referenced key.
    ///       Create key configurations with the External Keys API. On Claude Platform on AWS
    ///       the value is the AWS KMS key ARN, and the key must be a single-Region key in the
    ///       same AWS account and Region as the Workspace. On that platform the key is
    ///       validated against this Workspace when it is attached, so a key-policy problem is
    ///       reported as an error on this request. This field is write-once: once a key is
    ///       attached to a Workspace it cannot be detached or replaced. To rotate key
    ///       material, rotate the underlying key on your cloud KMS; the `external_key_id`
    ///       stays the same.
    ///
    ///   tags: User-defined tags as string key-value pairs. Keys may not begin with
    ///       `anthropic`.
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
    public func create(name: String, dataResidency: BetaDataResidencyCreateConfigParam?? = nil, displayColor: String?? = nil, externalKeyID: String?? = nil, tags: [String: String]?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaWorkspace {
        try await _create(name: name, dataResidency: dataResidency, displayColor: displayColor, externalKeyID: externalKeyID, tags: tags, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(name: String, dataResidency: BetaDataResidencyCreateConfigParam?? = nil, displayColor: String?? = nil, externalKeyID: String?? = nil, tags: [String: String]?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaWorkspace> {
        var body = ParamsBuilder()
        try body.set("name", name)
        try body.set("data_residency", dataResidency)
        try body.set("display_color", displayColor)
        try body.set("external_key_id", externalKeyID)
        try body.set("tags", tags)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/workspaces", body: body, headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ","))]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.create", spanRoute: "/v1/organizations/workspaces", spanCreatedID: SpanCreatedID("anthropic.organization.workspace.id"), qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaWorkspace.self, options, stream: _mode == .stream)
    }

    /// Get Workspace
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaWorkspace {
        try await _retrieve(workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaWorkspace> {
        try requireNonEmpty(workspaceID, "workspace_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}", ["workspace_id": workspaceID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.retrieve", spanRoute: "/v1/organizations/workspaces/{workspace_id}", spanAttributes: ["anthropic.organization.workspace.id": workspaceID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaWorkspace.self, options, stream: _mode == .stream)
    }

    /// Update Workspace
    ///
    /// Args:
    ///   data_residency: Data residency configuration for the workspace.
    ///
    ///   display_color: Hex color code representing the Workspace in the Anthropic Console.
    ///
    ///   external_key_id: ID of the customer-managed encryption key (CMEK) configuration to use for this
    ///       Workspace. Setting this field requires CMEK to be enabled for your organization.
    ///       When set, data stored for this Workspace is encrypted with the referenced key.
    ///       Create key configurations with the External Keys API. On Claude Platform on AWS
    ///       the value is the AWS KMS key ARN, and the key must be a single-Region key in the
    ///       same AWS account and Region as the Workspace. On that platform the key is
    ///       validated against this Workspace when it is attached, so a key-policy problem is
    ///       reported as an error on this request. This field is write-once: once a key is
    ///       attached to a Workspace it cannot be detached or replaced. To rotate key
    ///       material, rotate the underlying key on your cloud KMS; the `external_key_id`
    ///       stays the same.
    ///
    ///   name: Name of the Workspace.
    ///
    ///   tags: User-defined tags as string key-value pairs. Keys may not begin with
    ///       `anthropic`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func update(_ workspaceID: String, dataResidency: BetaDataResidencyUpdateConfigParam?? = nil, displayColor: String? = nil, externalKeyID: String? = nil, name: String? = nil, tags: [String: String?]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaWorkspace {
        try await _update(workspaceID, dataResidency: dataResidency, displayColor: displayColor, externalKeyID: externalKeyID, name: name, tags: tags, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ workspaceID: String, dataResidency: BetaDataResidencyUpdateConfigParam?? = nil, displayColor: String? = nil, externalKeyID: String? = nil, name: String? = nil, tags: [String: String?]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaWorkspace> {
        try requireNonEmpty(workspaceID, "workspace_id")
        var body = ParamsBuilder()
        try body.set("data_residency", dataResidency)
        try body.set("display_color", displayColor)
        try body.set("external_key_id", externalKeyID)
        try body.set("name", name)
        try body.set("tags", tags)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}", ["workspace_id": workspaceID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.update", spanRoute: "/v1/organizations/workspaces/{workspace_id}", spanAttributes: ["anthropic.organization.workspace.id": workspaceID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaWorkspace.self, options, stream: _mode == .stream)
    }

    /// List Workspaces
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   include_archived: Whether to include Workspaces that have been archived in the response
    ///
    ///   include_default: Whether to include the organization's default Workspace in the response
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(afterID: String? = nil, beforeID: String? = nil, includeArchived: Bool? = nil, includeDefault: Bool? = nil, limit: Int? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Page<BetaWorkspace> {
        try await _list(afterID: afterID, beforeID: beforeID, includeArchived: includeArchived, includeDefault: includeDefault, limit: limit, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(afterID: String? = nil, beforeID: String? = nil, includeArchived: Bool? = nil, includeDefault: Bool? = nil, limit: Int? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Page<BetaWorkspace>> {
        var query = ParamsBuilder()
        try query.set("after_id", afterID)
        try query.set("before_id", beforeID)
        try query.set("include_archived", includeArchived)
        try query.set("include_default", includeDefault)
        try query.set("limit", limit)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/workspaces", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.list", spanRoute: "/v1/organizations/workspaces", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(Page<BetaWorkspace>.self, options, stream: _mode == .stream)
    }

    /// Archive Workspace
    ///
    /// Args:
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func archive(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaWorkspace {
        try await _archive(workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _archive(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaWorkspace> {
        try requireNonEmpty(workspaceID, "workspace_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}/archive", ["workspace_id": workspaceID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.archive", spanRoute: "/v1/organizations/workspaces/{workspace_id}/archive", spanAttributes: ["anthropic.organization.workspace.id": workspaceID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaWorkspace.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationWorkspacesResource

        public var rateLimits: BetaOrganizationWorkspacesRateLimitsResource.WithRawResponse { resource.rateLimits.withRawResponse }

        public var members: BetaOrganizationWorkspacesMembersResource.WithRawResponse { resource.members.withRawResponse }

        public var serviceAccounts: BetaOrganizationWorkspacesServiceAccountsResource.WithRawResponse { resource.serviceAccounts.withRawResponse }

    /// Create Workspace
    ///
    /// Args:
    ///   name: Name of the Workspace.
    ///
    ///   data_residency: Data residency configuration for the workspace. If omitted, defaults to
    ///       `workspace_geo: "us"`, `allowed_inference_geos: "unrestricted"`, and
    ///       `default_inference_geo: "global"`.
    ///
    ///   display_color: Hex color code representing the Workspace in the Anthropic Console.
    ///
    ///   external_key_id: ID of the customer-managed encryption key (CMEK) configuration to use for this
    ///       Workspace. Setting this field requires CMEK to be enabled for your organization.
    ///       When set, data stored for this Workspace is encrypted with the referenced key.
    ///       Create key configurations with the External Keys API. On Claude Platform on AWS
    ///       the value is the AWS KMS key ARN, and the key must be a single-Region key in the
    ///       same AWS account and Region as the Workspace. On that platform the key is
    ///       validated against this Workspace when it is attached, so a key-policy problem is
    ///       reported as an error on this request. This field is write-once: once a key is
    ///       attached to a Workspace it cannot be detached or replaced. To rotate key
    ///       material, rotate the underlying key on your cloud KMS; the `external_key_id`
    ///       stays the same.
    ///
    ///   tags: User-defined tags as string key-value pairs. Keys may not begin with
    ///       `anthropic`.
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
        public func create(name: String, dataResidency: BetaDataResidencyCreateConfigParam?? = nil, displayColor: String?? = nil, externalKeyID: String?? = nil, tags: [String: String]?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaWorkspace> {
            try await resource._create(name: name, dataResidency: dataResidency, displayColor: displayColor, externalKeyID: externalKeyID, tags: tags, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Get Workspace
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaWorkspace> {
            try await resource._retrieve(workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update Workspace
    ///
    /// Args:
    ///   data_residency: Data residency configuration for the workspace.
    ///
    ///   display_color: Hex color code representing the Workspace in the Anthropic Console.
    ///
    ///   external_key_id: ID of the customer-managed encryption key (CMEK) configuration to use for this
    ///       Workspace. Setting this field requires CMEK to be enabled for your organization.
    ///       When set, data stored for this Workspace is encrypted with the referenced key.
    ///       Create key configurations with the External Keys API. On Claude Platform on AWS
    ///       the value is the AWS KMS key ARN, and the key must be a single-Region key in the
    ///       same AWS account and Region as the Workspace. On that platform the key is
    ///       validated against this Workspace when it is attached, so a key-policy problem is
    ///       reported as an error on this request. This field is write-once: once a key is
    ///       attached to a Workspace it cannot be detached or replaced. To rotate key
    ///       material, rotate the underlying key on your cloud KMS; the `external_key_id`
    ///       stays the same.
    ///
    ///   name: Name of the Workspace.
    ///
    ///   tags: User-defined tags as string key-value pairs. Keys may not begin with
    ///       `anthropic`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update(_ workspaceID: String, dataResidency: BetaDataResidencyUpdateConfigParam?? = nil, displayColor: String? = nil, externalKeyID: String? = nil, name: String? = nil, tags: [String: String?]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaWorkspace> {
            try await resource._update(workspaceID, dataResidency: dataResidency, displayColor: displayColor, externalKeyID: externalKeyID, name: name, tags: tags, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List Workspaces
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   include_archived: Whether to include Workspaces that have been archived in the response
    ///
    ///   include_default: Whether to include the organization's default Workspace in the response
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(afterID: String? = nil, beforeID: String? = nil, includeArchived: Bool? = nil, includeDefault: Bool? = nil, limit: Int? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Page<BetaWorkspace>> {
            try await resource._list(afterID: afterID, beforeID: beforeID, includeArchived: includeArchived, includeDefault: includeDefault, limit: limit, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Archive Workspace
    ///
    /// Args:
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func archive(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaWorkspace> {
            try await resource._archive(workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationWorkspacesResource

        public var rateLimits: BetaOrganizationWorkspacesRateLimitsResource.WithStreamingResponse { resource.rateLimits.withStreamingResponse }

        public var members: BetaOrganizationWorkspacesMembersResource.WithStreamingResponse { resource.members.withStreamingResponse }

        public var serviceAccounts: BetaOrganizationWorkspacesServiceAccountsResource.WithStreamingResponse { resource.serviceAccounts.withStreamingResponse }

    /// Create Workspace
    ///
    /// Args:
    ///   name: Name of the Workspace.
    ///
    ///   data_residency: Data residency configuration for the workspace. If omitted, defaults to
    ///       `workspace_geo: "us"`, `allowed_inference_geos: "unrestricted"`, and
    ///       `default_inference_geo: "global"`.
    ///
    ///   display_color: Hex color code representing the Workspace in the Anthropic Console.
    ///
    ///   external_key_id: ID of the customer-managed encryption key (CMEK) configuration to use for this
    ///       Workspace. Setting this field requires CMEK to be enabled for your organization.
    ///       When set, data stored for this Workspace is encrypted with the referenced key.
    ///       Create key configurations with the External Keys API. On Claude Platform on AWS
    ///       the value is the AWS KMS key ARN, and the key must be a single-Region key in the
    ///       same AWS account and Region as the Workspace. On that platform the key is
    ///       validated against this Workspace when it is attached, so a key-policy problem is
    ///       reported as an error on this request. This field is write-once: once a key is
    ///       attached to a Workspace it cannot be detached or replaced. To rotate key
    ///       material, rotate the underlying key on your cloud KMS; the `external_key_id`
    ///       stays the same.
    ///
    ///   tags: User-defined tags as string key-value pairs. Keys may not begin with
    ///       `anthropic`.
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
        public func create<R: Sendable>(name: String, dataResidency: BetaDataResidencyCreateConfigParam?? = nil, displayColor: String?? = nil, externalKeyID: String?? = nil, tags: [String: String]?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaWorkspace>) async throws -> R) async throws -> R {
            let response = try await resource._create(name: name, dataResidency: dataResidency, displayColor: displayColor, externalKeyID: externalKeyID, tags: tags, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Get Workspace
    ///
    /// Args:
    ///   workspace_id: ID of the Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaWorkspace>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Update Workspace
    ///
    /// Args:
    ///   data_residency: Data residency configuration for the workspace.
    ///
    ///   display_color: Hex color code representing the Workspace in the Anthropic Console.
    ///
    ///   external_key_id: ID of the customer-managed encryption key (CMEK) configuration to use for this
    ///       Workspace. Setting this field requires CMEK to be enabled for your organization.
    ///       When set, data stored for this Workspace is encrypted with the referenced key.
    ///       Create key configurations with the External Keys API. On Claude Platform on AWS
    ///       the value is the AWS KMS key ARN, and the key must be a single-Region key in the
    ///       same AWS account and Region as the Workspace. On that platform the key is
    ///       validated against this Workspace when it is attached, so a key-policy problem is
    ///       reported as an error on this request. This field is write-once: once a key is
    ///       attached to a Workspace it cannot be detached or replaced. To rotate key
    ///       material, rotate the underlying key on your cloud KMS; the `external_key_id`
    ///       stays the same.
    ///
    ///   name: Name of the Workspace.
    ///
    ///   tags: User-defined tags as string key-value pairs. Keys may not begin with
    ///       `anthropic`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update<R: Sendable>(_ workspaceID: String, dataResidency: BetaDataResidencyUpdateConfigParam?? = nil, displayColor: String? = nil, externalKeyID: String? = nil, name: String? = nil, tags: [String: String?]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaWorkspace>) async throws -> R) async throws -> R {
            let response = try await resource._update(workspaceID, dataResidency: dataResidency, displayColor: displayColor, externalKeyID: externalKeyID, name: name, tags: tags, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List Workspaces
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   include_archived: Whether to include Workspaces that have been archived in the response
    ///
    ///   include_default: Whether to include the organization's default Workspace in the response
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(afterID: String? = nil, beforeID: String? = nil, includeArchived: Bool? = nil, includeDefault: Bool? = nil, limit: Int? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Page<BetaWorkspace>>) async throws -> R) async throws -> R {
            let response = try await resource._list(afterID: afterID, beforeID: beforeID, includeArchived: includeArchived, includeDefault: includeDefault, limit: limit, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Archive Workspace
    ///
    /// Args:
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func archive<R: Sendable>(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaWorkspace>) async throws -> R) async throws -> R {
            let response = try await resource._archive(workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
