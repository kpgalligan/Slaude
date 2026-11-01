// Transformed from `anthropic.resources.beta.organization.api_keys` (api_keys.py).

import Foundation

public struct BetaOrganizationAPIKeysResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Get API Key
    ///
    /// Args:
    ///   api_key_id: ID of the API key.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ apiKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaAPIKey {
        try await _retrieve(apiKeyID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ apiKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaAPIKey> {
        try requireNonEmpty(apiKeyID, "api_key_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/api_keys/{api_key_id}", ["api_key_id": apiKeyID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.api_keys.retrieve", spanRoute: "/v1/organizations/api_keys/{api_key_id}", spanAttributes: ["anthropic.organization.api_key.id": apiKeyID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaAPIKey.self, options, stream: _mode == .stream)
    }

    /// Update API Key
    ///
    /// Args:
    ///   api_key_id: ID of the API key.
    ///
    ///   name: Name of the API key.
    ///
    ///   status: Status of the API key.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func update(_ apiKeyID: String, name: String?? = nil, status: BetaOrganizationAPIKeyUpdateParams.Status?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaAPIKey {
        try await _update(apiKeyID, name: name, status: status, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ apiKeyID: String, name: String?? = nil, status: BetaOrganizationAPIKeyUpdateParams.Status?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaAPIKey> {
        try requireNonEmpty(apiKeyID, "api_key_id")
        var body = ParamsBuilder()
        try body.set("name", name)
        try body.set("status", status)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/api_keys/{api_key_id}", ["api_key_id": apiKeyID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.api_keys.update", spanRoute: "/v1/organizations/api_keys/{api_key_id}", spanAttributes: ["anthropic.organization.api_key.id": apiKeyID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaAPIKey.self, options, stream: _mode == .stream)
    }

    /// List API Keys
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   created_by_user_id: Filter by the ID of the User who created the object.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   status: Filter by API key status.
    ///
    ///   workspace_id: Filter by Workspace ID.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(afterID: String? = nil, beforeID: String? = nil, createdByUserID: String?? = nil, limit: Int? = nil, status: BetaOrganizationAPIKeyListParams.Status?? = nil, workspaceID: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Page<BetaAPIKey> {
        try await _list(afterID: afterID, beforeID: beforeID, createdByUserID: createdByUserID, limit: limit, status: status, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(afterID: String? = nil, beforeID: String? = nil, createdByUserID: String?? = nil, limit: Int? = nil, status: BetaOrganizationAPIKeyListParams.Status?? = nil, workspaceID: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Page<BetaAPIKey>> {
        var query = ParamsBuilder()
        try query.set("after_id", afterID)
        try query.set("before_id", beforeID)
        try query.set("created_by_user_id", createdByUserID)
        try query.set("limit", limit)
        try query.set("status", status)
        try query.set("workspace_id", workspaceID)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/api_keys", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.api_keys.list", spanRoute: "/v1/organizations/api_keys", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(Page<BetaAPIKey>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationAPIKeysResource

    /// Get API Key
    ///
    /// Args:
    ///   api_key_id: ID of the API key.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ apiKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaAPIKey> {
            try await resource._retrieve(apiKeyID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update API Key
    ///
    /// Args:
    ///   api_key_id: ID of the API key.
    ///
    ///   name: Name of the API key.
    ///
    ///   status: Status of the API key.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update(_ apiKeyID: String, name: String?? = nil, status: BetaOrganizationAPIKeyUpdateParams.Status?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaAPIKey> {
            try await resource._update(apiKeyID, name: name, status: status, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List API Keys
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   created_by_user_id: Filter by the ID of the User who created the object.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   status: Filter by API key status.
    ///
    ///   workspace_id: Filter by Workspace ID.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(afterID: String? = nil, beforeID: String? = nil, createdByUserID: String?? = nil, limit: Int? = nil, status: BetaOrganizationAPIKeyListParams.Status?? = nil, workspaceID: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Page<BetaAPIKey>> {
            try await resource._list(afterID: afterID, beforeID: beforeID, createdByUserID: createdByUserID, limit: limit, status: status, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationAPIKeysResource

    /// Get API Key
    ///
    /// Args:
    ///   api_key_id: ID of the API key.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ apiKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaAPIKey>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(apiKeyID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Update API Key
    ///
    /// Args:
    ///   api_key_id: ID of the API key.
    ///
    ///   name: Name of the API key.
    ///
    ///   status: Status of the API key.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update<R: Sendable>(_ apiKeyID: String, name: String?? = nil, status: BetaOrganizationAPIKeyUpdateParams.Status?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaAPIKey>) async throws -> R) async throws -> R {
            let response = try await resource._update(apiKeyID, name: name, status: status, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List API Keys
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   created_by_user_id: Filter by the ID of the User who created the object.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   status: Filter by API key status.
    ///
    ///   workspace_id: Filter by Workspace ID.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(afterID: String? = nil, beforeID: String? = nil, createdByUserID: String?? = nil, limit: Int? = nil, status: BetaOrganizationAPIKeyListParams.Status?? = nil, workspaceID: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Page<BetaAPIKey>>) async throws -> R) async throws -> R {
            let response = try await resource._list(afterID: afterID, beforeID: beforeID, createdByUserID: createdByUserID, limit: limit, status: status, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
