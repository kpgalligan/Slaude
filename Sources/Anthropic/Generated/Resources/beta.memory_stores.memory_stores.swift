// Transformed from `anthropic.resources.beta.memory_stores.memory_stores` (memory_stores.py).

import Foundation

public struct BetaMemoryStoresResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var memories: BetaMemoryStoresMemoriesResource { BetaMemoryStoresMemoriesResource(client: client) }

    public var memoryVersions: BetaMemoryStoresMemoryVersionsResource { BetaMemoryStoresMemoryVersionsResource(client: client) }

    /// Create a Memory Store
    ///
    /// Args:
    ///   name: The name of the memory store, 1 to 255 characters long, without control
    ///       characters. Names don't have to be unique in a workspace.
    ///
    ///       In a session, the store's directory under `/mnt/memory/` is based on this name.
    ///       The name is lowercased and every run of characters other than ASCII letters and
    ///       digits becomes one hyphen. The session's memory store resource gives the exact
    ///       path in `mount_path`.
    ///
    ///       See the
    ///       [memory guide](https://platform.claude.com/docs/en/managed-agents/memory#how-the-agent-accesses-memory)
    ///       to learn more about how agents access memory stores.
    ///
    ///   description: Free-text description of what the store contains, up to 1,024 characters.
    ///       Included in the agent's system prompt when the store is attached, so word it to
    ///       be useful to the agent.
    ///
    ///   metadata: Key-value pairs for your own use, such as the end user that the store belongs
    ///       to. The agent doesn't see them.
    ///
    ///       A store has at most 16 pairs. Keys are 1 to 64 characters long and values at
    ///       most 512 characters.
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
    public func create(name: String, description: String? = nil, metadata: [String: String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsMemoryStore {
        try await _create(name: name, description: description, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(name: String, description: String? = nil, metadata: [String: String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsMemoryStore> {
        var body = ParamsBuilder()
        try body.set("name", name)
        try body.set("description", description)
        try body.set("metadata", metadata)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/memory_stores", body: body, headers: mergeHeaderLayers(["anthropic-beta": "agent-memory-2026-07-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["agent-memory-2026-07-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.memory_stores.create", spanRoute: "/v1/memory_stores", spanCreatedID: SpanCreatedID("gen_ai.memory.store.id"), qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsMemoryStore.self, options, stream: _mode == .stream)
    }

    /// Retrieve a Memory Store
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to retrieve (`memstore_...`).
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
    public func retrieve(_ memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsMemoryStore {
        try await _retrieve(memoryStoreID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsMemoryStore> {
        try requireNonEmpty(memoryStoreID, "memory_store_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/memory_stores/{memory_store_id}", ["memory_store_id": memoryStoreID]), headers: mergeHeaderLayers(["anthropic-beta": "agent-memory-2026-07-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["agent-memory-2026-07-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.memory_stores.retrieve", spanRoute: "/v1/memory_stores/{memory_store_id}", spanAttributes: ["gen_ai.memory.store.id": memoryStoreID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsMemoryStore.self, options, stream: _mode == .stream)
    }

    /// Update a Memory Store
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to update (`memstore_...`).
    ///
    ///       The request fails with HTTP status 400 if the store is archived.
    ///
    ///   description: New description for the store, up to 1,024 characters. Pass an empty string to
    ///       clear it.
    ///
    ///   metadata: Changes to apply to the memory store's metadata. Keys you leave out keep their
    ///       values.
    ///
    ///       Set a key to a string to add or replace it, or to `null` to remove it. After the
    ///       change, the metadata can hold at most 16 key-value pairs. Keys are 1 to 64
    ///       characters long and values at most 512 characters.
    ///
    ///   name: The new name of the memory store, 1 to 255 characters long, without control
    ///       characters.
    ///
    ///       Sessions created after the change use the new name for the store's directory
    ///       under `/mnt/memory/`.
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
    public func update(_ memoryStoreID: String, description: String?? = nil, metadata: [String: String?]?? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsMemoryStore {
        try await _update(memoryStoreID, description: description, metadata: metadata, name: name, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ memoryStoreID: String, description: String?? = nil, metadata: [String: String?]?? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsMemoryStore> {
        try requireNonEmpty(memoryStoreID, "memory_store_id")
        var body = ParamsBuilder()
        try body.set("description", description)
        try body.set("metadata", metadata)
        try body.set("name", name)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/memory_stores/{memory_store_id}", ["memory_store_id": memoryStoreID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "agent-memory-2026-07-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["agent-memory-2026-07-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.memory_stores.update", spanRoute: "/v1/memory_stores/{memory_store_id}", spanAttributes: ["gen_ai.memory.store.id": memoryStoreID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsMemoryStore.self, options, stream: _mode == .stream)
    }

    /// List Memory Stores
    ///
    /// Args:
    ///   created_at_gte: Return only memory stores created at or after this time (inclusive).
    ///
    ///   created_at_lte: Return only memory stores created at or before this time (inclusive).
    ///
    ///   include_archived: When `true`, archived stores are included in the results. Defaults to `false`
    ///       (archived stores are excluded).
    ///
    ///   limit: Maximum number of stores to return per page. Must be between 1 and 100. Defaults
    ///       to 20 when omitted.
    ///
    ///   page: The `next_page` value from a previous response, to get the next page. Omit it to
    ///       get the first page.
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
    public func list(createdAtGte: MemoryStoreListParams.CreatedAtGte? = nil, createdAtLte: MemoryStoreListParams.CreatedAtLte? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaManagedAgentsMemoryStore> {
        try await _list(createdAtGte: createdAtGte, createdAtLte: createdAtLte, includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(createdAtGte: MemoryStoreListParams.CreatedAtGte? = nil, createdAtLte: MemoryStoreListParams.CreatedAtLte? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaManagedAgentsMemoryStore>> {
        var query = ParamsBuilder()
        try query.set("created_at[gte]", createdAtGte)
        try query.set("created_at[lte]", createdAtLte)
        try query.set("include_archived", includeArchived)
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/memory_stores", query: query, headers: mergeHeaderLayers(["anthropic-beta": "agent-memory-2026-07-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["agent-memory-2026-07-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.memory_stores.list", spanRoute: "/v1/memory_stores", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaManagedAgentsMemoryStore>.self, options, stream: _mode == .stream)
    }

    /// Delete a Memory Store
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to delete (`memstore_...`).
    ///
    ///       Deleting a store also deletes all its memories and memory versions. It can't be
    ///       undone.
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
    public func delete(_ memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsDeletedMemoryStore {
        try await _delete(memoryStoreID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsDeletedMemoryStore> {
        try requireNonEmpty(memoryStoreID, "memory_store_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/memory_stores/{memory_store_id}", ["memory_store_id": memoryStoreID]), headers: mergeHeaderLayers(["anthropic-beta": "agent-memory-2026-07-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["agent-memory-2026-07-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.memory_stores.delete", spanRoute: "/v1/memory_stores/{memory_store_id}", spanAttributes: ["gen_ai.memory.store.id": memoryStoreID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsDeletedMemoryStore.self, options, stream: _mode == .stream)
    }

    /// Archive a Memory Store
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to archive (`memstore_...`).
    ///
    ///       Archiving can't be undone. Archiving a store that is already archived returns it
    ///       unchanged.
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
    public func archive(_ memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsMemoryStore {
        try await _archive(memoryStoreID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _archive(_ memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsMemoryStore> {
        try requireNonEmpty(memoryStoreID, "memory_store_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/memory_stores/{memory_store_id}/archive", ["memory_store_id": memoryStoreID]), headers: mergeHeaderLayers(["anthropic-beta": "agent-memory-2026-07-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["agent-memory-2026-07-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.memory_stores.archive", spanRoute: "/v1/memory_stores/{memory_store_id}/archive", spanAttributes: ["gen_ai.memory.store.id": memoryStoreID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsMemoryStore.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaMemoryStoresResource

        public var memories: BetaMemoryStoresMemoriesResource.WithRawResponse { resource.memories.withRawResponse }

        public var memoryVersions: BetaMemoryStoresMemoryVersionsResource.WithRawResponse { resource.memoryVersions.withRawResponse }

    /// Create a Memory Store
    ///
    /// Args:
    ///   name: The name of the memory store, 1 to 255 characters long, without control
    ///       characters. Names don't have to be unique in a workspace.
    ///
    ///       In a session, the store's directory under `/mnt/memory/` is based on this name.
    ///       The name is lowercased and every run of characters other than ASCII letters and
    ///       digits becomes one hyphen. The session's memory store resource gives the exact
    ///       path in `mount_path`.
    ///
    ///       See the
    ///       [memory guide](https://platform.claude.com/docs/en/managed-agents/memory#how-the-agent-accesses-memory)
    ///       to learn more about how agents access memory stores.
    ///
    ///   description: Free-text description of what the store contains, up to 1,024 characters.
    ///       Included in the agent's system prompt when the store is attached, so word it to
    ///       be useful to the agent.
    ///
    ///   metadata: Key-value pairs for your own use, such as the end user that the store belongs
    ///       to. The agent doesn't see them.
    ///
    ///       A store has at most 16 pairs. Keys are 1 to 64 characters long and values at
    ///       most 512 characters.
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
        public func create(name: String, description: String? = nil, metadata: [String: String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsMemoryStore> {
            try await resource._create(name: name, description: description, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Retrieve a Memory Store
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to retrieve (`memstore_...`).
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
        public func retrieve(_ memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsMemoryStore> {
            try await resource._retrieve(memoryStoreID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update a Memory Store
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to update (`memstore_...`).
    ///
    ///       The request fails with HTTP status 400 if the store is archived.
    ///
    ///   description: New description for the store, up to 1,024 characters. Pass an empty string to
    ///       clear it.
    ///
    ///   metadata: Changes to apply to the memory store's metadata. Keys you leave out keep their
    ///       values.
    ///
    ///       Set a key to a string to add or replace it, or to `null` to remove it. After the
    ///       change, the metadata can hold at most 16 key-value pairs. Keys are 1 to 64
    ///       characters long and values at most 512 characters.
    ///
    ///   name: The new name of the memory store, 1 to 255 characters long, without control
    ///       characters.
    ///
    ///       Sessions created after the change use the new name for the store's directory
    ///       under `/mnt/memory/`.
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
        public func update(_ memoryStoreID: String, description: String?? = nil, metadata: [String: String?]?? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsMemoryStore> {
            try await resource._update(memoryStoreID, description: description, metadata: metadata, name: name, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List Memory Stores
    ///
    /// Args:
    ///   created_at_gte: Return only memory stores created at or after this time (inclusive).
    ///
    ///   created_at_lte: Return only memory stores created at or before this time (inclusive).
    ///
    ///   include_archived: When `true`, archived stores are included in the results. Defaults to `false`
    ///       (archived stores are excluded).
    ///
    ///   limit: Maximum number of stores to return per page. Must be between 1 and 100. Defaults
    ///       to 20 when omitted.
    ///
    ///   page: The `next_page` value from a previous response, to get the next page. Omit it to
    ///       get the first page.
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
        public func list(createdAtGte: MemoryStoreListParams.CreatedAtGte? = nil, createdAtLte: MemoryStoreListParams.CreatedAtLte? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaManagedAgentsMemoryStore>> {
            try await resource._list(createdAtGte: createdAtGte, createdAtLte: createdAtLte, includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete a Memory Store
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to delete (`memstore_...`).
    ///
    ///       Deleting a store also deletes all its memories and memory versions. It can't be
    ///       undone.
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
        public func delete(_ memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsDeletedMemoryStore> {
            try await resource._delete(memoryStoreID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Archive a Memory Store
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to archive (`memstore_...`).
    ///
    ///       Archiving can't be undone. Archiving a store that is already archived returns it
    ///       unchanged.
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
        public func archive(_ memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsMemoryStore> {
            try await resource._archive(memoryStoreID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaMemoryStoresResource

        public var memories: BetaMemoryStoresMemoriesResource.WithStreamingResponse { resource.memories.withStreamingResponse }

        public var memoryVersions: BetaMemoryStoresMemoryVersionsResource.WithStreamingResponse { resource.memoryVersions.withStreamingResponse }

    /// Create a Memory Store
    ///
    /// Args:
    ///   name: The name of the memory store, 1 to 255 characters long, without control
    ///       characters. Names don't have to be unique in a workspace.
    ///
    ///       In a session, the store's directory under `/mnt/memory/` is based on this name.
    ///       The name is lowercased and every run of characters other than ASCII letters and
    ///       digits becomes one hyphen. The session's memory store resource gives the exact
    ///       path in `mount_path`.
    ///
    ///       See the
    ///       [memory guide](https://platform.claude.com/docs/en/managed-agents/memory#how-the-agent-accesses-memory)
    ///       to learn more about how agents access memory stores.
    ///
    ///   description: Free-text description of what the store contains, up to 1,024 characters.
    ///       Included in the agent's system prompt when the store is attached, so word it to
    ///       be useful to the agent.
    ///
    ///   metadata: Key-value pairs for your own use, such as the end user that the store belongs
    ///       to. The agent doesn't see them.
    ///
    ///       A store has at most 16 pairs. Keys are 1 to 64 characters long and values at
    ///       most 512 characters.
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
        public func create<R: Sendable>(name: String, description: String? = nil, metadata: [String: String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsMemoryStore>) async throws -> R) async throws -> R {
            let response = try await resource._create(name: name, description: description, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Retrieve a Memory Store
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to retrieve (`memstore_...`).
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
        public func retrieve<R: Sendable>(_ memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsMemoryStore>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(memoryStoreID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Update a Memory Store
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to update (`memstore_...`).
    ///
    ///       The request fails with HTTP status 400 if the store is archived.
    ///
    ///   description: New description for the store, up to 1,024 characters. Pass an empty string to
    ///       clear it.
    ///
    ///   metadata: Changes to apply to the memory store's metadata. Keys you leave out keep their
    ///       values.
    ///
    ///       Set a key to a string to add or replace it, or to `null` to remove it. After the
    ///       change, the metadata can hold at most 16 key-value pairs. Keys are 1 to 64
    ///       characters long and values at most 512 characters.
    ///
    ///   name: The new name of the memory store, 1 to 255 characters long, without control
    ///       characters.
    ///
    ///       Sessions created after the change use the new name for the store's directory
    ///       under `/mnt/memory/`.
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
        public func update<R: Sendable>(_ memoryStoreID: String, description: String?? = nil, metadata: [String: String?]?? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsMemoryStore>) async throws -> R) async throws -> R {
            let response = try await resource._update(memoryStoreID, description: description, metadata: metadata, name: name, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List Memory Stores
    ///
    /// Args:
    ///   created_at_gte: Return only memory stores created at or after this time (inclusive).
    ///
    ///   created_at_lte: Return only memory stores created at or before this time (inclusive).
    ///
    ///   include_archived: When `true`, archived stores are included in the results. Defaults to `false`
    ///       (archived stores are excluded).
    ///
    ///   limit: Maximum number of stores to return per page. Must be between 1 and 100. Defaults
    ///       to 20 when omitted.
    ///
    ///   page: The `next_page` value from a previous response, to get the next page. Omit it to
    ///       get the first page.
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
        public func list<R: Sendable>(createdAtGte: MemoryStoreListParams.CreatedAtGte? = nil, createdAtLte: MemoryStoreListParams.CreatedAtLte? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaManagedAgentsMemoryStore>>) async throws -> R) async throws -> R {
            let response = try await resource._list(createdAtGte: createdAtGte, createdAtLte: createdAtLte, includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete a Memory Store
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to delete (`memstore_...`).
    ///
    ///       Deleting a store also deletes all its memories and memory versions. It can't be
    ///       undone.
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
        public func delete<R: Sendable>(_ memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsDeletedMemoryStore>) async throws -> R) async throws -> R {
            let response = try await resource._delete(memoryStoreID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Archive a Memory Store
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to archive (`memstore_...`).
    ///
    ///       Archiving can't be undone. Archiving a store that is already archived returns it
    ///       unchanged.
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
        public func archive<R: Sendable>(_ memoryStoreID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsMemoryStore>) async throws -> R) async throws -> R {
            let response = try await resource._archive(memoryStoreID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
