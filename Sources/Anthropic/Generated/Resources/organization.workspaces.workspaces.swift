// Transformed from `anthropic.resources.organization.workspaces.workspaces` (workspaces.py).

import Foundation

public struct OrganizationWorkspacesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var rateLimits: OrganizationWorkspacesRateLimitsResource { OrganizationWorkspacesRateLimitsResource(client: client) }

    public var members: OrganizationWorkspacesMembersResource { OrganizationWorkspacesMembersResource(client: client) }

    public var serviceAccounts: OrganizationWorkspacesServiceAccountsResource { OrganizationWorkspacesServiceAccountsResource(client: client) }

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
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func create(name: String, dataResidency: DataResidencyCreateConfigParam?? = nil, displayColor: String?? = nil, externalKeyID: String?? = nil, tags: [String: String]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Workspace {
        try await _create(name: name, dataResidency: dataResidency, displayColor: displayColor, externalKeyID: externalKeyID, tags: tags, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(name: String, dataResidency: DataResidencyCreateConfigParam?? = nil, displayColor: String?? = nil, externalKeyID: String?? = nil, tags: [String: String]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Workspace> {
        var body = ParamsBuilder()
        try body.set("name", name)
        try body.set("data_residency", dataResidency)
        try body.set("display_color", displayColor)
        try body.set("external_key_id", externalKeyID)
        try body.set("tags", tags)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/workspaces", body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.create", spanRoute: "/v1/organizations/workspaces", spanCreatedID: SpanCreatedID("anthropic.organization.workspace.id"))
        return try await client.requestResponse(Workspace.self, options, stream: _mode == .stream)
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
    public func retrieve(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Workspace {
        try await _retrieve(workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Workspace> {
        try requireNonEmpty(workspaceID, "workspace_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}", ["workspace_id": workspaceID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.retrieve", spanRoute: "/v1/organizations/workspaces/{workspace_id}", spanAttributes: ["anthropic.organization.workspace.id": workspaceID])
        return try await client.requestResponse(Workspace.self, options, stream: _mode == .stream)
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
    public func update(_ workspaceID: String, dataResidency: DataResidencyUpdateConfigParam?? = nil, displayColor: String? = nil, externalKeyID: String? = nil, name: String? = nil, tags: [String: String?]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Workspace {
        try await _update(workspaceID, dataResidency: dataResidency, displayColor: displayColor, externalKeyID: externalKeyID, name: name, tags: tags, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ workspaceID: String, dataResidency: DataResidencyUpdateConfigParam?? = nil, displayColor: String? = nil, externalKeyID: String? = nil, name: String? = nil, tags: [String: String?]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Workspace> {
        try requireNonEmpty(workspaceID, "workspace_id")
        var body = ParamsBuilder()
        try body.set("data_residency", dataResidency)
        try body.set("display_color", displayColor)
        try body.set("external_key_id", externalKeyID)
        try body.set("name", name)
        try body.set("tags", tags)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}", ["workspace_id": workspaceID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.update", spanRoute: "/v1/organizations/workspaces/{workspace_id}", spanAttributes: ["anthropic.organization.workspace.id": workspaceID])
        return try await client.requestResponse(Workspace.self, options, stream: _mode == .stream)
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
    public func list(afterID: String? = nil, beforeID: String? = nil, includeArchived: Bool? = nil, includeDefault: Bool? = nil, limit: Int? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Page<Workspace> {
        try await _list(afterID: afterID, beforeID: beforeID, includeArchived: includeArchived, includeDefault: includeDefault, limit: limit, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(afterID: String? = nil, beforeID: String? = nil, includeArchived: Bool? = nil, includeDefault: Bool? = nil, limit: Int? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Page<Workspace>> {
        var query = ParamsBuilder()
        try query.set("after_id", afterID)
        try query.set("before_id", beforeID)
        try query.set("include_archived", includeArchived)
        try query.set("include_default", includeDefault)
        try query.set("limit", limit)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/workspaces", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.list", spanRoute: "/v1/organizations/workspaces")
        return try await client.requestPageResponse(Page<Workspace>.self, options, stream: _mode == .stream)
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
    public func archive(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Workspace {
        try await _archive(workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _archive(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Workspace> {
        try requireNonEmpty(workspaceID, "workspace_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/workspaces/{workspace_id}/archive", ["workspace_id": workspaceID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.workspaces.archive", spanRoute: "/v1/organizations/workspaces/{workspace_id}/archive", spanAttributes: ["anthropic.organization.workspace.id": workspaceID])
        return try await client.requestResponse(Workspace.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: OrganizationWorkspacesResource

        public var rateLimits: OrganizationWorkspacesRateLimitsResource.WithRawResponse { resource.rateLimits.withRawResponse }

        public var members: OrganizationWorkspacesMembersResource.WithRawResponse { resource.members.withRawResponse }

        public var serviceAccounts: OrganizationWorkspacesServiceAccountsResource.WithRawResponse { resource.serviceAccounts.withRawResponse }

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
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create(name: String, dataResidency: DataResidencyCreateConfigParam?? = nil, displayColor: String?? = nil, externalKeyID: String?? = nil, tags: [String: String]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Workspace> {
            try await resource._create(name: name, dataResidency: dataResidency, displayColor: displayColor, externalKeyID: externalKeyID, tags: tags, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
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
        public func retrieve(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Workspace> {
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
        public func update(_ workspaceID: String, dataResidency: DataResidencyUpdateConfigParam?? = nil, displayColor: String? = nil, externalKeyID: String? = nil, name: String? = nil, tags: [String: String?]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Workspace> {
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
        public func list(afterID: String? = nil, beforeID: String? = nil, includeArchived: Bool? = nil, includeDefault: Bool? = nil, limit: Int? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Page<Workspace>> {
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
        public func archive(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Workspace> {
            try await resource._archive(workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: OrganizationWorkspacesResource

        public var rateLimits: OrganizationWorkspacesRateLimitsResource.WithStreamingResponse { resource.rateLimits.withStreamingResponse }

        public var members: OrganizationWorkspacesMembersResource.WithStreamingResponse { resource.members.withStreamingResponse }

        public var serviceAccounts: OrganizationWorkspacesServiceAccountsResource.WithStreamingResponse { resource.serviceAccounts.withStreamingResponse }

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
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create<R: Sendable>(name: String, dataResidency: DataResidencyCreateConfigParam?? = nil, displayColor: String?? = nil, externalKeyID: String?? = nil, tags: [String: String]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Workspace>) async throws -> R) async throws -> R {
            let response = try await resource._create(name: name, dataResidency: dataResidency, displayColor: displayColor, externalKeyID: externalKeyID, tags: tags, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
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
        public func retrieve<R: Sendable>(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Workspace>) async throws -> R) async throws -> R {
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
        public func update<R: Sendable>(_ workspaceID: String, dataResidency: DataResidencyUpdateConfigParam?? = nil, displayColor: String? = nil, externalKeyID: String? = nil, name: String? = nil, tags: [String: String?]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Workspace>) async throws -> R) async throws -> R {
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
        public func list<R: Sendable>(afterID: String? = nil, beforeID: String? = nil, includeArchived: Bool? = nil, includeDefault: Bool? = nil, limit: Int? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Page<Workspace>>) async throws -> R) async throws -> R {
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
        public func archive<R: Sendable>(_ workspaceID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Workspace>) async throws -> R) async throws -> R {
            let response = try await resource._archive(workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
