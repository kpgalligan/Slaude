// Transformed from `anthropic.resources.beta.models` (models.py).

import Foundation

public struct BetaModelsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Get a specific model.
    ///
    /// The Models API response can be used to determine information about a specific
    /// model or resolve a model alias to a model ID.
    ///
    /// Args:
    ///   model_id: Model identifier or alias.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ modelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaModelInfo {
        try await _retrieve(modelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ modelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaModelInfo> {
        try requireNonEmpty(modelID, "model_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/models/{model_id}", ["model_id": modelID]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.models.retrieve")
        return try await client.requestResponse(BetaModelInfo.self, options, stream: _mode == .stream)
    }

    /// List available models.
    ///
    /// The Models API response can be used to determine which models are available for
    /// use in the API. More recently released models are listed first.
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   lifecycle: Filter the list to models in any of the given lifecycle stages (`active`,
    ///       `deprecated`, or `retired`). Up to 3 values. When omitted, the list contains the
    ///       `active` and `deprecated` models; `retired` models appear only when `retired` is
    ///       requested explicitly.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(afterID: String? = nil, beforeID: String? = nil, lifecycle: [BetaModelListParams.Lifecycle]? = nil, limit: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Page<BetaModelInfo> {
        try await _list(afterID: afterID, beforeID: beforeID, lifecycle: lifecycle, limit: limit, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(afterID: String? = nil, beforeID: String? = nil, lifecycle: [BetaModelListParams.Lifecycle]? = nil, limit: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Page<BetaModelInfo>> {
        var query = ParamsBuilder()
        try query.set("after_id", afterID)
        try query.set("before_id", beforeID)
        try query.set("lifecycle", lifecycle)
        try query.set("limit", limit)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/models", query: query, headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.models.list")
        return try await client.requestPageResponse(Page<BetaModelInfo>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaModelsResource

    /// Get a specific model.
    ///
    /// The Models API response can be used to determine information about a specific
    /// model or resolve a model alias to a model ID.
    ///
    /// Args:
    ///   model_id: Model identifier or alias.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ modelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaModelInfo> {
            try await resource._retrieve(modelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List available models.
    ///
    /// The Models API response can be used to determine which models are available for
    /// use in the API. More recently released models are listed first.
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   lifecycle: Filter the list to models in any of the given lifecycle stages (`active`,
    ///       `deprecated`, or `retired`). Up to 3 values. When omitted, the list contains the
    ///       `active` and `deprecated` models; `retired` models appear only when `retired` is
    ///       requested explicitly.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(afterID: String? = nil, beforeID: String? = nil, lifecycle: [BetaModelListParams.Lifecycle]? = nil, limit: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Page<BetaModelInfo>> {
            try await resource._list(afterID: afterID, beforeID: beforeID, lifecycle: lifecycle, limit: limit, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaModelsResource

    /// Get a specific model.
    ///
    /// The Models API response can be used to determine information about a specific
    /// model or resolve a model alias to a model ID.
    ///
    /// Args:
    ///   model_id: Model identifier or alias.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ modelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaModelInfo>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(modelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List available models.
    ///
    /// The Models API response can be used to determine which models are available for
    /// use in the API. More recently released models are listed first.
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   lifecycle: Filter the list to models in any of the given lifecycle stages (`active`,
    ///       `deprecated`, or `retired`). Up to 3 values. When omitted, the list contains the
    ///       `active` and `deprecated` models; `retired` models appear only when `retired` is
    ///       requested explicitly.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(afterID: String? = nil, beforeID: String? = nil, lifecycle: [BetaModelListParams.Lifecycle]? = nil, limit: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Page<BetaModelInfo>>) async throws -> R) async throws -> R {
            let response = try await resource._list(afterID: afterID, beforeID: beforeID, lifecycle: lifecycle, limit: limit, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
