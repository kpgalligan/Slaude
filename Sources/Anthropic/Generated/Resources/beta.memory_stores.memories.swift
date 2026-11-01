// Transformed from `anthropic.resources.beta.memory_stores.memories` (memories.py).

import Foundation

public struct BetaMemoryStoresMemoriesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Create a Memory
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to create the memory in (`memstore_...`).
    ///
    ///   content: The UTF-8 text content of the new memory. Pass `""` to create an empty memory.
    ///
    ///       The maximum size is 100 kB (102,400 bytes).
    ///
    ///   path: The path of the new memory, such as `/projects/foo/notes.md`. Paths are
    ///       case-sensitive.
    ///
    ///       A path starts with `/` and has 1 to 20 segments. A segment can't be empty and
    ///       can't be `.` or `..`. A path can't contain control characters, format
    ///       characters, or the line and paragraph separators U+2028 and U+2029. It must be
    ///       in Unicode Normalization Form C and at most 1,024 bytes long.
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
    public func create(_ memoryStoreID: String, content: String?, path: String, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsMemory {
        try await _create(memoryStoreID, content: content, path: path, view: view, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(_ memoryStoreID: String, content: String?, path: String, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsMemory> {
        try requireNonEmpty(memoryStoreID, "memory_store_id")
        var body = ParamsBuilder()
        try body.set("content", content)
        try body.set("path", path)
        var query = ParamsBuilder()
        try query.set("view", view)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/memory_stores/{memory_store_id}/memories", ["memory_store_id": memoryStoreID]), body: body, query: query, headers: mergeHeaderLayers(["anthropic-beta": "agent-memory-2026-07-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["agent-memory-2026-07-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.memory_stores.memories.create", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsMemory.self, options, stream: _mode == .stream)
    }

    /// Retrieve a Memory
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store that holds the memory (`memstore_...`).
    ///
    ///   memory_id: The ID of the memory to retrieve (`mem_...`).
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
    public func retrieve(_ memoryID: String, memoryStoreID: String, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsMemory {
        try await _retrieve(memoryID, memoryStoreID: memoryStoreID, view: view, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ memoryID: String, memoryStoreID: String, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsMemory> {
        try requireNonEmpty(memoryStoreID, "memory_store_id")
        try requireNonEmpty(memoryID, "memory_id")
        var query = ParamsBuilder()
        try query.set("view", view)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/memory_stores/{memory_store_id}/memories/{memory_id}", ["memory_store_id": memoryStoreID, "memory_id": memoryID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "agent-memory-2026-07-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["agent-memory-2026-07-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.memory_stores.memories.retrieve", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsMemory.self, options, stream: _mode == .stream)
    }

    /// Update a Memory
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store that holds the memory (`memstore_...`).
    ///
    ///   memory_id: The ID of the memory to update (`mem_...`).
    ///
    ///   view: Whether a `memory` or `memory_version` in the response includes its `content`.
    ///       Defaults to `full` on retrieve operations and to `basic` on list, create, and
    ///       update operations.
    ///
    ///       With `full`, list operations return at most 20 items per page.
    ///
    ///   content: New UTF-8 text content for the memory. Maximum 100 kB (102,400 bytes). Omit to
    ///       leave the content unchanged (e.g., for a rename-only update).
    ///
    ///   path: The new path of the memory, which renames it. Omit it to keep the current path.
    ///
    ///       The memory keeps its `id`. A path starts with `/` and has 1 to 20 segments. A
    ///       segment can't be empty and can't be `.` or `..`. A path can't contain control
    ///       characters, format characters, or the line and paragraph separators U+2028 and
    ///       U+2029. It must be in Unicode Normalization Form C and at most 1,024 bytes long.
    ///       Paths are case-sensitive.
    ///
    ///   precondition: The condition that the memory must meet for the update to apply. Omit it to
    ///       update unconditionally.
    ///
    ///       If the condition fails, the request fails with HTTP status 409.
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
    public func update(_ memoryID: String, memoryStoreID: String, view: BetaManagedAgentsMemoryView? = nil, content: String?? = nil, path: String?? = nil, precondition: BetaManagedAgentsPreconditionParam? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsMemory {
        try await _update(memoryID, memoryStoreID: memoryStoreID, view: view, content: content, path: path, precondition: precondition, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ memoryID: String, memoryStoreID: String, view: BetaManagedAgentsMemoryView? = nil, content: String?? = nil, path: String?? = nil, precondition: BetaManagedAgentsPreconditionParam? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsMemory> {
        try requireNonEmpty(memoryStoreID, "memory_store_id")
        try requireNonEmpty(memoryID, "memory_id")
        var body = ParamsBuilder()
        try body.set("content", content)
        try body.set("path", path)
        try body.set("precondition", precondition)
        var query = ParamsBuilder()
        try query.set("view", view)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/memory_stores/{memory_store_id}/memories/{memory_id}", ["memory_store_id": memoryStoreID, "memory_id": memoryID]), body: body, query: query, headers: mergeHeaderLayers(["anthropic-beta": "agent-memory-2026-07-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["agent-memory-2026-07-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.memory_stores.memories.update", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsMemory.self, options, stream: _mode == .stream)
    }

    /// List Memories
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to list memories from (`memstore_...`).
    ///
    ///   depth: How far below `path_prefix` to list. Defaults to `0`, which lists every memory
    ///       below the prefix.
    ///
    ///       Pass `1` to list only the direct children. Deeper memories are then grouped into
    ///       `memory_prefix` items.
    ///
    ///   limit: The maximum number of items to return per page, from 1 to 100. Defaults to 20.
    ///
    ///       With `view=full`, a page holds at most 20 items. `memory` and `memory_prefix`
    ///       items both count toward the limit.
    ///
    ///   page: The `next_page` value from a previous response, to get the next page. Omit it to
    ///       get the first page.
    ///
    ///   path_prefix: Return only memories whose path starts with this prefix, such as `/notes/`. This
    ///       value appears in request URLs. Do not include secrets or personally identifiable
    ///       information.
    ///
    ///       Omit it to list the whole store. The prefix must end with `/` and matches whole
    ///       segments, so `/notes/` matches `/notes/todo.md` but not
    ///       `/notes-archive/todo.md`.
    ///
    ///   view: Whether each memory in the response includes `content`. Defaults to `basic`,
    ///       which sets it to `null`.
    ///
    ///       With `full`, a page holds at most 20 items.
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
    public func list(_ memoryStoreID: String, depth: Int? = nil, limit: Int? = nil, page: String? = nil, pathPrefix: String? = nil, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaManagedAgentsMemoryListItem> {
        try await _list(memoryStoreID, depth: depth, limit: limit, page: page, pathPrefix: pathPrefix, view: view, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ memoryStoreID: String, depth: Int? = nil, limit: Int? = nil, page: String? = nil, pathPrefix: String? = nil, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaManagedAgentsMemoryListItem>> {
        try requireNonEmpty(memoryStoreID, "memory_store_id")
        var query = ParamsBuilder()
        try query.set("depth", depth)
        try query.set("limit", limit)
        try query.set("page", page)
        try query.set("path_prefix", pathPrefix)
        try query.set("view", view)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/memory_stores/{memory_store_id}/memories", ["memory_store_id": memoryStoreID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "agent-memory-2026-07-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["agent-memory-2026-07-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.memory_stores.memories.list", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaManagedAgentsMemoryListItem>.self, options, stream: _mode == .stream)
    }

    /// Delete a Memory
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store that holds the memory (`memstore_...`).
    ///
    ///   memory_id: The ID of the memory to delete (`mem_...`).
    ///
    ///   expected_content_sha256: Delete the memory only if its current `content_sha256` equals this value, given
    ///       as 64 lowercase hexadecimal characters. Omit it to delete unconditionally.
    ///
    ///       If the hashes differ, the request fails with HTTP status 409 and nothing is
    ///       deleted.
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
    public func delete(_ memoryID: String, memoryStoreID: String, expectedContentSha256: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsDeletedMemory {
        try await _delete(memoryID, memoryStoreID: memoryStoreID, expectedContentSha256: expectedContentSha256, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ memoryID: String, memoryStoreID: String, expectedContentSha256: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsDeletedMemory> {
        try requireNonEmpty(memoryStoreID, "memory_store_id")
        try requireNonEmpty(memoryID, "memory_id")
        var query = ParamsBuilder()
        try query.set("expected_content_sha256", expectedContentSha256)
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/memory_stores/{memory_store_id}/memories/{memory_id}", ["memory_store_id": memoryStoreID, "memory_id": memoryID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "agent-memory-2026-07-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["agent-memory-2026-07-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.memory_stores.memories.delete", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsDeletedMemory.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaMemoryStoresMemoriesResource

    /// Create a Memory
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to create the memory in (`memstore_...`).
    ///
    ///   content: The UTF-8 text content of the new memory. Pass `""` to create an empty memory.
    ///
    ///       The maximum size is 100 kB (102,400 bytes).
    ///
    ///   path: The path of the new memory, such as `/projects/foo/notes.md`. Paths are
    ///       case-sensitive.
    ///
    ///       A path starts with `/` and has 1 to 20 segments. A segment can't be empty and
    ///       can't be `.` or `..`. A path can't contain control characters, format
    ///       characters, or the line and paragraph separators U+2028 and U+2029. It must be
    ///       in Unicode Normalization Form C and at most 1,024 bytes long.
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
        public func create(_ memoryStoreID: String, content: String?, path: String, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsMemory> {
            try await resource._create(memoryStoreID, content: content, path: path, view: view, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Retrieve a Memory
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store that holds the memory (`memstore_...`).
    ///
    ///   memory_id: The ID of the memory to retrieve (`mem_...`).
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
        public func retrieve(_ memoryID: String, memoryStoreID: String, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsMemory> {
            try await resource._retrieve(memoryID, memoryStoreID: memoryStoreID, view: view, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update a Memory
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store that holds the memory (`memstore_...`).
    ///
    ///   memory_id: The ID of the memory to update (`mem_...`).
    ///
    ///   view: Whether a `memory` or `memory_version` in the response includes its `content`.
    ///       Defaults to `full` on retrieve operations and to `basic` on list, create, and
    ///       update operations.
    ///
    ///       With `full`, list operations return at most 20 items per page.
    ///
    ///   content: New UTF-8 text content for the memory. Maximum 100 kB (102,400 bytes). Omit to
    ///       leave the content unchanged (e.g., for a rename-only update).
    ///
    ///   path: The new path of the memory, which renames it. Omit it to keep the current path.
    ///
    ///       The memory keeps its `id`. A path starts with `/` and has 1 to 20 segments. A
    ///       segment can't be empty and can't be `.` or `..`. A path can't contain control
    ///       characters, format characters, or the line and paragraph separators U+2028 and
    ///       U+2029. It must be in Unicode Normalization Form C and at most 1,024 bytes long.
    ///       Paths are case-sensitive.
    ///
    ///   precondition: The condition that the memory must meet for the update to apply. Omit it to
    ///       update unconditionally.
    ///
    ///       If the condition fails, the request fails with HTTP status 409.
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
        public func update(_ memoryID: String, memoryStoreID: String, view: BetaManagedAgentsMemoryView? = nil, content: String?? = nil, path: String?? = nil, precondition: BetaManagedAgentsPreconditionParam? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsMemory> {
            try await resource._update(memoryID, memoryStoreID: memoryStoreID, view: view, content: content, path: path, precondition: precondition, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List Memories
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to list memories from (`memstore_...`).
    ///
    ///   depth: How far below `path_prefix` to list. Defaults to `0`, which lists every memory
    ///       below the prefix.
    ///
    ///       Pass `1` to list only the direct children. Deeper memories are then grouped into
    ///       `memory_prefix` items.
    ///
    ///   limit: The maximum number of items to return per page, from 1 to 100. Defaults to 20.
    ///
    ///       With `view=full`, a page holds at most 20 items. `memory` and `memory_prefix`
    ///       items both count toward the limit.
    ///
    ///   page: The `next_page` value from a previous response, to get the next page. Omit it to
    ///       get the first page.
    ///
    ///   path_prefix: Return only memories whose path starts with this prefix, such as `/notes/`. This
    ///       value appears in request URLs. Do not include secrets or personally identifiable
    ///       information.
    ///
    ///       Omit it to list the whole store. The prefix must end with `/` and matches whole
    ///       segments, so `/notes/` matches `/notes/todo.md` but not
    ///       `/notes-archive/todo.md`.
    ///
    ///   view: Whether each memory in the response includes `content`. Defaults to `basic`,
    ///       which sets it to `null`.
    ///
    ///       With `full`, a page holds at most 20 items.
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
        public func list(_ memoryStoreID: String, depth: Int? = nil, limit: Int? = nil, page: String? = nil, pathPrefix: String? = nil, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaManagedAgentsMemoryListItem>> {
            try await resource._list(memoryStoreID, depth: depth, limit: limit, page: page, pathPrefix: pathPrefix, view: view, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete a Memory
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store that holds the memory (`memstore_...`).
    ///
    ///   memory_id: The ID of the memory to delete (`mem_...`).
    ///
    ///   expected_content_sha256: Delete the memory only if its current `content_sha256` equals this value, given
    ///       as 64 lowercase hexadecimal characters. Omit it to delete unconditionally.
    ///
    ///       If the hashes differ, the request fails with HTTP status 409 and nothing is
    ///       deleted.
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
        public func delete(_ memoryID: String, memoryStoreID: String, expectedContentSha256: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsDeletedMemory> {
            try await resource._delete(memoryID, memoryStoreID: memoryStoreID, expectedContentSha256: expectedContentSha256, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaMemoryStoresMemoriesResource

    /// Create a Memory
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to create the memory in (`memstore_...`).
    ///
    ///   content: The UTF-8 text content of the new memory. Pass `""` to create an empty memory.
    ///
    ///       The maximum size is 100 kB (102,400 bytes).
    ///
    ///   path: The path of the new memory, such as `/projects/foo/notes.md`. Paths are
    ///       case-sensitive.
    ///
    ///       A path starts with `/` and has 1 to 20 segments. A segment can't be empty and
    ///       can't be `.` or `..`. A path can't contain control characters, format
    ///       characters, or the line and paragraph separators U+2028 and U+2029. It must be
    ///       in Unicode Normalization Form C and at most 1,024 bytes long.
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
        public func create<R: Sendable>(_ memoryStoreID: String, content: String?, path: String, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsMemory>) async throws -> R) async throws -> R {
            let response = try await resource._create(memoryStoreID, content: content, path: path, view: view, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Retrieve a Memory
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store that holds the memory (`memstore_...`).
    ///
    ///   memory_id: The ID of the memory to retrieve (`mem_...`).
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
        public func retrieve<R: Sendable>(_ memoryID: String, memoryStoreID: String, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsMemory>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(memoryID, memoryStoreID: memoryStoreID, view: view, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Update a Memory
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store that holds the memory (`memstore_...`).
    ///
    ///   memory_id: The ID of the memory to update (`mem_...`).
    ///
    ///   view: Whether a `memory` or `memory_version` in the response includes its `content`.
    ///       Defaults to `full` on retrieve operations and to `basic` on list, create, and
    ///       update operations.
    ///
    ///       With `full`, list operations return at most 20 items per page.
    ///
    ///   content: New UTF-8 text content for the memory. Maximum 100 kB (102,400 bytes). Omit to
    ///       leave the content unchanged (e.g., for a rename-only update).
    ///
    ///   path: The new path of the memory, which renames it. Omit it to keep the current path.
    ///
    ///       The memory keeps its `id`. A path starts with `/` and has 1 to 20 segments. A
    ///       segment can't be empty and can't be `.` or `..`. A path can't contain control
    ///       characters, format characters, or the line and paragraph separators U+2028 and
    ///       U+2029. It must be in Unicode Normalization Form C and at most 1,024 bytes long.
    ///       Paths are case-sensitive.
    ///
    ///   precondition: The condition that the memory must meet for the update to apply. Omit it to
    ///       update unconditionally.
    ///
    ///       If the condition fails, the request fails with HTTP status 409.
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
        public func update<R: Sendable>(_ memoryID: String, memoryStoreID: String, view: BetaManagedAgentsMemoryView? = nil, content: String?? = nil, path: String?? = nil, precondition: BetaManagedAgentsPreconditionParam? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsMemory>) async throws -> R) async throws -> R {
            let response = try await resource._update(memoryID, memoryStoreID: memoryStoreID, view: view, content: content, path: path, precondition: precondition, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List Memories
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store to list memories from (`memstore_...`).
    ///
    ///   depth: How far below `path_prefix` to list. Defaults to `0`, which lists every memory
    ///       below the prefix.
    ///
    ///       Pass `1` to list only the direct children. Deeper memories are then grouped into
    ///       `memory_prefix` items.
    ///
    ///   limit: The maximum number of items to return per page, from 1 to 100. Defaults to 20.
    ///
    ///       With `view=full`, a page holds at most 20 items. `memory` and `memory_prefix`
    ///       items both count toward the limit.
    ///
    ///   page: The `next_page` value from a previous response, to get the next page. Omit it to
    ///       get the first page.
    ///
    ///   path_prefix: Return only memories whose path starts with this prefix, such as `/notes/`. This
    ///       value appears in request URLs. Do not include secrets or personally identifiable
    ///       information.
    ///
    ///       Omit it to list the whole store. The prefix must end with `/` and matches whole
    ///       segments, so `/notes/` matches `/notes/todo.md` but not
    ///       `/notes-archive/todo.md`.
    ///
    ///   view: Whether each memory in the response includes `content`. Defaults to `basic`,
    ///       which sets it to `null`.
    ///
    ///       With `full`, a page holds at most 20 items.
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
        public func list<R: Sendable>(_ memoryStoreID: String, depth: Int? = nil, limit: Int? = nil, page: String? = nil, pathPrefix: String? = nil, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaManagedAgentsMemoryListItem>>) async throws -> R) async throws -> R {
            let response = try await resource._list(memoryStoreID, depth: depth, limit: limit, page: page, pathPrefix: pathPrefix, view: view, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete a Memory
    ///
    /// Args:
    ///   memory_store_id: The ID of the memory store that holds the memory (`memstore_...`).
    ///
    ///   memory_id: The ID of the memory to delete (`mem_...`).
    ///
    ///   expected_content_sha256: Delete the memory only if its current `content_sha256` equals this value, given
    ///       as 64 lowercase hexadecimal characters. Omit it to delete unconditionally.
    ///
    ///       If the hashes differ, the request fails with HTTP status 409 and nothing is
    ///       deleted.
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
        public func delete<R: Sendable>(_ memoryID: String, memoryStoreID: String, expectedContentSha256: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsDeletedMemory>) async throws -> R) async throws -> R {
            let response = try await resource._delete(memoryID, memoryStoreID: memoryStoreID, expectedContentSha256: expectedContentSha256, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
