// Transformed from `anthropic.resources.beta.memory_stores.memory_versions` (memory_versions.py).

import Foundation

public struct BetaMemoryStoresMemoryVersionsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Retrieve a Memory Version
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store that holds the version (`memstore_...`).
    ///
    ///   memory_version_id: The ID of the memory version to retrieve (`memver_...`).
    ///
    ///   view: Whether a `memory` or `memory_version` in the response includes its `content`.
    ///       Defaults to `full` on retrieve operations and to `basic` on list, create, and
    ///       update operations.
    ///
    ///       With `full`, list operations return at most 20 items per page.
    ///
    ///   betas: This endpoint is in beta: requests must send `agent-memory-2026-07-22` or
    ///       `managed-agents-2026-04-01` in this header.
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
    public func retrieve(_ memoryVersionID: String, memoryStoreID: String, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsMemoryVersion {
        try await _retrieve(memoryVersionID, memoryStoreID: memoryStoreID, view: view, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ memoryVersionID: String, memoryStoreID: String, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsMemoryVersion> {
        try requireNonEmpty(memoryStoreID, "memory_store_id")
        try requireNonEmpty(memoryVersionID, "memory_version_id")
        var query = ParamsBuilder()
        try query.set("view", view)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/memory_stores/{memory_store_id}/memory_versions/{memory_version_id}", ["memory_store_id": memoryStoreID, "memory_version_id": memoryVersionID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "agent-memory-2026-07-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["agent-memory-2026-07-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.memory_stores.memory_versions.retrieve", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsMemoryVersion.self, options, stream: _mode == .stream)
    }

    /// List Memory Versions
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store whose version history to list (`memstore_...`).
    ///
    ///   api_key_id: Return only versions written with the API key that has this ID.
    ///
    ///   created_at_gte: Return versions created at or after this time (inclusive).
    ///
    ///   created_at_lte: Return versions created at or before this time (inclusive).
    ///
    ///   limit: The maximum number of versions to return per page, from 1 to 100. Defaults
    ///       to 20.
    ///
    ///       With `view=full`, a page holds at most 20 versions.
    ///
    ///   memory_id: Return only versions of the memory with this ID (`mem_...`).
    ///
    ///       The filter still works after the memory is deleted. While that memory's versions
    ///       are retained, the results include the version whose `operation` is `deleted`.
    ///
    ///   operation: Return only versions that record this kind of change.
    ///
    ///   page: The `next_page` value from a previous response, to get the next page. Omit it to
    ///       get the first page.
    ///
    ///   service_account_id: Return only versions written by the service account with this ID (`svac_...`).
    ///
    ///   session_id: Return only versions written by the session with this ID.
    ///
    ///   view: Whether a `memory` or `memory_version` in the response includes its `content`.
    ///       Defaults to `full` on retrieve operations and to `basic` on list, create, and
    ///       update operations.
    ///
    ///       With `full`, list operations return at most 20 items per page.
    ///
    ///   betas: This endpoint is in beta: requests must send `agent-memory-2026-07-22` or
    ///       `managed-agents-2026-04-01` in this header.
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
    public func list(_ memoryStoreID: String, apiKeyID: String? = nil, createdAtGte: MemoryVersionListParams.CreatedAtGte? = nil, createdAtLte: MemoryVersionListParams.CreatedAtLte? = nil, limit: Int? = nil, memoryID: String? = nil, operation: BetaManagedAgentsMemoryVersionOperation? = nil, page: String? = nil, serviceAccountID: String? = nil, sessionID: String? = nil, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaManagedAgentsMemoryVersion> {
        try await _list(memoryStoreID, apiKeyID: apiKeyID, createdAtGte: createdAtGte, createdAtLte: createdAtLte, limit: limit, memoryID: memoryID, operation: operation, page: page, serviceAccountID: serviceAccountID, sessionID: sessionID, view: view, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ memoryStoreID: String, apiKeyID: String? = nil, createdAtGte: MemoryVersionListParams.CreatedAtGte? = nil, createdAtLte: MemoryVersionListParams.CreatedAtLte? = nil, limit: Int? = nil, memoryID: String? = nil, operation: BetaManagedAgentsMemoryVersionOperation? = nil, page: String? = nil, serviceAccountID: String? = nil, sessionID: String? = nil, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaManagedAgentsMemoryVersion>> {
        try requireNonEmpty(memoryStoreID, "memory_store_id")
        var query = ParamsBuilder()
        try query.set("api_key_id", apiKeyID)
        try query.set("created_at[gte]", createdAtGte)
        try query.set("created_at[lte]", createdAtLte)
        try query.set("limit", limit)
        try query.set("memory_id", memoryID)
        try query.set("operation", operation)
        try query.set("page", page)
        try query.set("service_account_id", serviceAccountID)
        try query.set("session_id", sessionID)
        try query.set("view", view)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/memory_stores/{memory_store_id}/memory_versions", ["memory_store_id": memoryStoreID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "agent-memory-2026-07-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["agent-memory-2026-07-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.memory_stores.memory_versions.list", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaManagedAgentsMemoryVersion>.self, options, stream: _mode == .stream)
    }

    /// Redact a Memory Version
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store that holds the version (`memstore_...`).
    ///
    ///   memory_version_id: The ID of the memory version to redact (`memver_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `agent-memory-2026-07-22` or
    ///       `managed-agents-2026-04-01` in this header.
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
    public func redact(_ memoryVersionID: String, memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsMemoryVersion {
        try await _redact(memoryVersionID, memoryStoreID: memoryStoreID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _redact(_ memoryVersionID: String, memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsMemoryVersion> {
        try requireNonEmpty(memoryStoreID, "memory_store_id")
        try requireNonEmpty(memoryVersionID, "memory_version_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/memory_stores/{memory_store_id}/memory_versions/{memory_version_id}/redact", ["memory_store_id": memoryStoreID, "memory_version_id": memoryVersionID]), headers: mergeHeaderLayers(["anthropic-beta": "agent-memory-2026-07-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["agent-memory-2026-07-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.memory_stores.memory_versions.redact", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsMemoryVersion.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaMemoryStoresMemoryVersionsResource

    /// Retrieve a Memory Version
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store that holds the version (`memstore_...`).
    ///
    ///   memory_version_id: The ID of the memory version to retrieve (`memver_...`).
    ///
    ///   view: Whether a `memory` or `memory_version` in the response includes its `content`.
    ///       Defaults to `full` on retrieve operations and to `basic` on list, create, and
    ///       update operations.
    ///
    ///       With `full`, list operations return at most 20 items per page.
    ///
    ///   betas: This endpoint is in beta: requests must send `agent-memory-2026-07-22` or
    ///       `managed-agents-2026-04-01` in this header.
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
        public func retrieve(_ memoryVersionID: String, memoryStoreID: String, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsMemoryVersion> {
            try await resource._retrieve(memoryVersionID, memoryStoreID: memoryStoreID, view: view, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List Memory Versions
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store whose version history to list (`memstore_...`).
    ///
    ///   api_key_id: Return only versions written with the API key that has this ID.
    ///
    ///   created_at_gte: Return versions created at or after this time (inclusive).
    ///
    ///   created_at_lte: Return versions created at or before this time (inclusive).
    ///
    ///   limit: The maximum number of versions to return per page, from 1 to 100. Defaults
    ///       to 20.
    ///
    ///       With `view=full`, a page holds at most 20 versions.
    ///
    ///   memory_id: Return only versions of the memory with this ID (`mem_...`).
    ///
    ///       The filter still works after the memory is deleted. While that memory's versions
    ///       are retained, the results include the version whose `operation` is `deleted`.
    ///
    ///   operation: Return only versions that record this kind of change.
    ///
    ///   page: The `next_page` value from a previous response, to get the next page. Omit it to
    ///       get the first page.
    ///
    ///   service_account_id: Return only versions written by the service account with this ID (`svac_...`).
    ///
    ///   session_id: Return only versions written by the session with this ID.
    ///
    ///   view: Whether a `memory` or `memory_version` in the response includes its `content`.
    ///       Defaults to `full` on retrieve operations and to `basic` on list, create, and
    ///       update operations.
    ///
    ///       With `full`, list operations return at most 20 items per page.
    ///
    ///   betas: This endpoint is in beta: requests must send `agent-memory-2026-07-22` or
    ///       `managed-agents-2026-04-01` in this header.
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
        public func list(_ memoryStoreID: String, apiKeyID: String? = nil, createdAtGte: MemoryVersionListParams.CreatedAtGte? = nil, createdAtLte: MemoryVersionListParams.CreatedAtLte? = nil, limit: Int? = nil, memoryID: String? = nil, operation: BetaManagedAgentsMemoryVersionOperation? = nil, page: String? = nil, serviceAccountID: String? = nil, sessionID: String? = nil, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaManagedAgentsMemoryVersion>> {
            try await resource._list(memoryStoreID, apiKeyID: apiKeyID, createdAtGte: createdAtGte, createdAtLte: createdAtLte, limit: limit, memoryID: memoryID, operation: operation, page: page, serviceAccountID: serviceAccountID, sessionID: sessionID, view: view, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Redact a Memory Version
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store that holds the version (`memstore_...`).
    ///
    ///   memory_version_id: The ID of the memory version to redact (`memver_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `agent-memory-2026-07-22` or
    ///       `managed-agents-2026-04-01` in this header.
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
        public func redact(_ memoryVersionID: String, memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsMemoryVersion> {
            try await resource._redact(memoryVersionID, memoryStoreID: memoryStoreID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaMemoryStoresMemoryVersionsResource

    /// Retrieve a Memory Version
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store that holds the version (`memstore_...`).
    ///
    ///   memory_version_id: The ID of the memory version to retrieve (`memver_...`).
    ///
    ///   view: Whether a `memory` or `memory_version` in the response includes its `content`.
    ///       Defaults to `full` on retrieve operations and to `basic` on list, create, and
    ///       update operations.
    ///
    ///       With `full`, list operations return at most 20 items per page.
    ///
    ///   betas: This endpoint is in beta: requests must send `agent-memory-2026-07-22` or
    ///       `managed-agents-2026-04-01` in this header.
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
        public func retrieve<R: Sendable>(_ memoryVersionID: String, memoryStoreID: String, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsMemoryVersion>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(memoryVersionID, memoryStoreID: memoryStoreID, view: view, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List Memory Versions
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store whose version history to list (`memstore_...`).
    ///
    ///   api_key_id: Return only versions written with the API key that has this ID.
    ///
    ///   created_at_gte: Return versions created at or after this time (inclusive).
    ///
    ///   created_at_lte: Return versions created at or before this time (inclusive).
    ///
    ///   limit: The maximum number of versions to return per page, from 1 to 100. Defaults
    ///       to 20.
    ///
    ///       With `view=full`, a page holds at most 20 versions.
    ///
    ///   memory_id: Return only versions of the memory with this ID (`mem_...`).
    ///
    ///       The filter still works after the memory is deleted. While that memory's versions
    ///       are retained, the results include the version whose `operation` is `deleted`.
    ///
    ///   operation: Return only versions that record this kind of change.
    ///
    ///   page: The `next_page` value from a previous response, to get the next page. Omit it to
    ///       get the first page.
    ///
    ///   service_account_id: Return only versions written by the service account with this ID (`svac_...`).
    ///
    ///   session_id: Return only versions written by the session with this ID.
    ///
    ///   view: Whether a `memory` or `memory_version` in the response includes its `content`.
    ///       Defaults to `full` on retrieve operations and to `basic` on list, create, and
    ///       update operations.
    ///
    ///       With `full`, list operations return at most 20 items per page.
    ///
    ///   betas: This endpoint is in beta: requests must send `agent-memory-2026-07-22` or
    ///       `managed-agents-2026-04-01` in this header.
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
        public func list<R: Sendable>(_ memoryStoreID: String, apiKeyID: String? = nil, createdAtGte: MemoryVersionListParams.CreatedAtGte? = nil, createdAtLte: MemoryVersionListParams.CreatedAtLte? = nil, limit: Int? = nil, memoryID: String? = nil, operation: BetaManagedAgentsMemoryVersionOperation? = nil, page: String? = nil, serviceAccountID: String? = nil, sessionID: String? = nil, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaManagedAgentsMemoryVersion>>) async throws -> R) async throws -> R {
            let response = try await resource._list(memoryStoreID, apiKeyID: apiKeyID, createdAtGte: createdAtGte, createdAtLte: createdAtLte, limit: limit, memoryID: memoryID, operation: operation, page: page, serviceAccountID: serviceAccountID, sessionID: sessionID, view: view, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Redact a Memory Version
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store that holds the version (`memstore_...`).
    ///
    ///   memory_version_id: The ID of the memory version to redact (`memver_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `agent-memory-2026-07-22` or
    ///       `managed-agents-2026-04-01` in this header.
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
        public func redact<R: Sendable>(_ memoryVersionID: String, memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsMemoryVersion>) async throws -> R) async throws -> R {
            let response = try await resource._redact(memoryVersionID, memoryStoreID: memoryStoreID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
