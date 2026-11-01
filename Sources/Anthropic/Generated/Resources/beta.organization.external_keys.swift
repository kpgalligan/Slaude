// Transformed from `anthropic.resources.beta.organization.external_keys` (external_keys.py).

import Foundation

public struct BetaOrganizationExternalKeysResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Create an external key config owned by the caller's organization.
    ///
    /// Args:
    ///   provider_config: KMS provider identity and auth coordinates.
    ///
    ///   display_name: Human-friendly display name.
    ///
    ///   geo: Data residency geo. Only `us` is supported.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func create(providerConfig: BetaOrganizationExternalKeyCreateParams.ProviderConfig, displayName: String?? = nil, geo: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaExternalKey {
        try await _create(providerConfig: providerConfig, displayName: displayName, geo: geo, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(providerConfig: BetaOrganizationExternalKeyCreateParams.ProviderConfig, displayName: String?? = nil, geo: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaExternalKey> {
        var body = ParamsBuilder()
        try body.set("provider_config", providerConfig)
        try body.set("display_name", displayName)
        try body.set("geo", geo)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/external_keys", body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.external_keys.create", spanRoute: "/v1/organizations/external_keys", spanCreatedID: SpanCreatedID("anthropic.organization.external_key.id"), qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaExternalKey.self, options, stream: _mode == .stream)
    }

    /// Retrieve a single external key config in the caller's organization by ID.
    ///
    /// Args:
    ///   external_key_id: ID of the External Key.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ externalKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaExternalKey {
        try await _retrieve(externalKeyID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ externalKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaExternalKey> {
        try requireNonEmpty(externalKeyID, "external_key_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/external_keys/{external_key_id}", ["external_key_id": externalKeyID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.external_keys.retrieve", spanRoute: "/v1/organizations/external_keys/{external_key_id}", spanAttributes: ["anthropic.organization.external_key.id": externalKeyID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaExternalKey.self, options, stream: _mode == .stream)
    }

    /// Partially update an external key config.
    ///
    /// Omitted fields are left unchanged.
    ///
    /// `display_name` is always editable. `geo` and `provider_config` cannot be changed
    /// once any workspace references this config, because previously encrypted data
    /// requires the original key identity to decrypt.
    ///
    /// Args:
    ///   external_key_id: ID of the External Key.
    ///
    ///   display_name: Human-friendly display name.
    ///
    ///   geo: Data residency geo. Only `us` is supported.
    ///
    ///   provider_config: KMS provider identity and auth coordinates.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func update(_ externalKeyID: String, displayName: String?? = nil, geo: String?? = nil, providerConfig: BetaOrganizationExternalKeyUpdateParams.ProviderConfig?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaExternalKey {
        try await _update(externalKeyID, displayName: displayName, geo: geo, providerConfig: providerConfig, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ externalKeyID: String, displayName: String?? = nil, geo: String?? = nil, providerConfig: BetaOrganizationExternalKeyUpdateParams.ProviderConfig?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaExternalKey> {
        try requireNonEmpty(externalKeyID, "external_key_id")
        var body = ParamsBuilder()
        try body.set("display_name", displayName)
        try body.set("geo", geo)
        try body.set("provider_config", providerConfig)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/external_keys/{external_key_id}", ["external_key_id": externalKeyID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.external_keys.update", spanRoute: "/v1/organizations/external_keys/{external_key_id}", spanAttributes: ["anthropic.organization.external_key.id": externalKeyID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaExternalKey.self, options, stream: _mode == .stream)
    }

    /// List external key configs in the caller's organization.
    ///
    /// Results are ordered by creation time (newest first). Use the `next_page` cursor
    /// from the response to fetch subsequent pages.
    ///
    /// Args:
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
    public func list(limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaExternalKey> {
        try await _list(limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaExternalKey>> {
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/external_keys", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.external_keys.list", spanRoute: "/v1/organizations/external_keys", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaExternalKey>.self, options, stream: _mode == .stream)
    }

    /// Delete an external key config.
    ///
    /// The request is rejected if any workspace still references this config.
    ///
    /// Args:
    ///   external_key_id: ID of the External Key.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func delete(_ externalKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaOrganizationExternalKeyDeleteResponse {
        try await _delete(externalKeyID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ externalKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaOrganizationExternalKeyDeleteResponse> {
        try requireNonEmpty(externalKeyID, "external_key_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/external_keys/{external_key_id}", ["external_key_id": externalKeyID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.external_keys.delete", spanRoute: "/v1/organizations/external_keys/{external_key_id}", spanAttributes: ["anthropic.organization.external_key.id": externalKeyID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaOrganizationExternalKeyDeleteResponse.self, options, stream: _mode == .stream)
    }

    /// Validate an external key config against the customer's KMS.
    ///
    /// Anthropic performs an encrypt/decrypt roundtrip against the configured KMS key
    /// and waits up to 30 seconds for the result. The response status is `success` if
    /// the roundtrip succeeded, or `failure` with an error message if it failed or
    /// timed out.
    ///
    /// Args:
    ///   external_key_id: ID of the External Key.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func validate(_ externalKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaOrganizationExternalKeyValidateResponse {
        try await _validate(externalKeyID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _validate(_ externalKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaOrganizationExternalKeyValidateResponse> {
        try requireNonEmpty(externalKeyID, "external_key_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/external_keys/{external_key_id}/validate", ["external_key_id": externalKeyID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.external_keys.validate", spanRoute: "/v1/organizations/external_keys/{external_key_id}/validate", spanAttributes: ["anthropic.organization.external_key.id": externalKeyID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaOrganizationExternalKeyValidateResponse.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationExternalKeysResource

    /// Create an external key config owned by the caller's organization.
    ///
    /// Args:
    ///   provider_config: KMS provider identity and auth coordinates.
    ///
    ///   display_name: Human-friendly display name.
    ///
    ///   geo: Data residency geo. Only `us` is supported.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create(providerConfig: BetaOrganizationExternalKeyCreateParams.ProviderConfig, displayName: String?? = nil, geo: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaExternalKey> {
            try await resource._create(providerConfig: providerConfig, displayName: displayName, geo: geo, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Retrieve a single external key config in the caller's organization by ID.
    ///
    /// Args:
    ///   external_key_id: ID of the External Key.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ externalKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaExternalKey> {
            try await resource._retrieve(externalKeyID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Partially update an external key config.
    ///
    /// Omitted fields are left unchanged.
    ///
    /// `display_name` is always editable. `geo` and `provider_config` cannot be changed
    /// once any workspace references this config, because previously encrypted data
    /// requires the original key identity to decrypt.
    ///
    /// Args:
    ///   external_key_id: ID of the External Key.
    ///
    ///   display_name: Human-friendly display name.
    ///
    ///   geo: Data residency geo. Only `us` is supported.
    ///
    ///   provider_config: KMS provider identity and auth coordinates.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update(_ externalKeyID: String, displayName: String?? = nil, geo: String?? = nil, providerConfig: BetaOrganizationExternalKeyUpdateParams.ProviderConfig?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaExternalKey> {
            try await resource._update(externalKeyID, displayName: displayName, geo: geo, providerConfig: providerConfig, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List external key configs in the caller's organization.
    ///
    /// Results are ordered by creation time (newest first). Use the `next_page` cursor
    /// from the response to fetch subsequent pages.
    ///
    /// Args:
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
        public func list(limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaExternalKey>> {
            try await resource._list(limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete an external key config.
    ///
    /// The request is rejected if any workspace still references this config.
    ///
    /// Args:
    ///   external_key_id: ID of the External Key.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func delete(_ externalKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaOrganizationExternalKeyDeleteResponse> {
            try await resource._delete(externalKeyID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Validate an external key config against the customer's KMS.
    ///
    /// Anthropic performs an encrypt/decrypt roundtrip against the configured KMS key
    /// and waits up to 30 seconds for the result. The response status is `success` if
    /// the roundtrip succeeded, or `failure` with an error message if it failed or
    /// timed out.
    ///
    /// Args:
    ///   external_key_id: ID of the External Key.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func validate(_ externalKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaOrganizationExternalKeyValidateResponse> {
            try await resource._validate(externalKeyID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationExternalKeysResource

    /// Create an external key config owned by the caller's organization.
    ///
    /// Args:
    ///   provider_config: KMS provider identity and auth coordinates.
    ///
    ///   display_name: Human-friendly display name.
    ///
    ///   geo: Data residency geo. Only `us` is supported.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create<R: Sendable>(providerConfig: BetaOrganizationExternalKeyCreateParams.ProviderConfig, displayName: String?? = nil, geo: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaExternalKey>) async throws -> R) async throws -> R {
            let response = try await resource._create(providerConfig: providerConfig, displayName: displayName, geo: geo, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Retrieve a single external key config in the caller's organization by ID.
    ///
    /// Args:
    ///   external_key_id: ID of the External Key.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ externalKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaExternalKey>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(externalKeyID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Partially update an external key config.
    ///
    /// Omitted fields are left unchanged.
    ///
    /// `display_name` is always editable. `geo` and `provider_config` cannot be changed
    /// once any workspace references this config, because previously encrypted data
    /// requires the original key identity to decrypt.
    ///
    /// Args:
    ///   external_key_id: ID of the External Key.
    ///
    ///   display_name: Human-friendly display name.
    ///
    ///   geo: Data residency geo. Only `us` is supported.
    ///
    ///   provider_config: KMS provider identity and auth coordinates.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update<R: Sendable>(_ externalKeyID: String, displayName: String?? = nil, geo: String?? = nil, providerConfig: BetaOrganizationExternalKeyUpdateParams.ProviderConfig?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaExternalKey>) async throws -> R) async throws -> R {
            let response = try await resource._update(externalKeyID, displayName: displayName, geo: geo, providerConfig: providerConfig, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List external key configs in the caller's organization.
    ///
    /// Results are ordered by creation time (newest first). Use the `next_page` cursor
    /// from the response to fetch subsequent pages.
    ///
    /// Args:
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
        public func list<R: Sendable>(limit: Int? = nil, page: String?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaExternalKey>>) async throws -> R) async throws -> R {
            let response = try await resource._list(limit: limit, page: page, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete an external key config.
    ///
    /// The request is rejected if any workspace still references this config.
    ///
    /// Args:
    ///   external_key_id: ID of the External Key.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func delete<R: Sendable>(_ externalKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaOrganizationExternalKeyDeleteResponse>) async throws -> R) async throws -> R {
            let response = try await resource._delete(externalKeyID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Validate an external key config against the customer's KMS.
    ///
    /// Anthropic performs an encrypt/decrypt roundtrip against the configured KMS key
    /// and waits up to 30 seconds for the result. The response status is `success` if
    /// the roundtrip succeeded, or `failure` with an error message if it failed or
    /// timed out.
    ///
    /// Args:
    ///   external_key_id: ID of the External Key.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func validate<R: Sendable>(_ externalKeyID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaOrganizationExternalKeyValidateResponse>) async throws -> R) async throws -> R {
            let response = try await resource._validate(externalKeyID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
