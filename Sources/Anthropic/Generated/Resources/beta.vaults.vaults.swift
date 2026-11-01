// Transformed from `anthropic.resources.beta.vaults.vaults` (vaults.py).

import Foundation

public struct BetaVaultsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var credentials: BetaVaultsCredentialsResource { BetaVaultsCredentialsResource(client: client) }

    /// Create a Vault
    ///
    /// Args:
    ///   display_name: Human-readable name for the vault.
    ///
    /// 1-255 characters.
    ///
    ///   metadata: Arbitrary key-value metadata to attach to the vault. Maximum 16 pairs, keys up
    ///       to 64 chars, values up to 512 chars.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
    public func create(displayName: String, metadata: [String: String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsVault {
        try await _create(displayName: displayName, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(displayName: String, metadata: [String: String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsVault> {
        var body = ParamsBuilder()
        try body.set("display_name", displayName)
        try body.set("metadata", metadata)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/vaults", body: body, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.vaults.create")
        return try await client.requestResponse(BetaManagedAgentsVault.self, options, stream: _mode == .stream)
    }

    /// Retrieve a Vault
    ///
    /// Args:
    ///   vault_id: Unique identifier of the vault to retrieve.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
    public func retrieve(_ vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsVault {
        try await _retrieve(vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsVault> {
        try requireNonEmpty(vaultID, "vault_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/vaults/{vault_id}", ["vault_id": vaultID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.vaults.retrieve")
        return try await client.requestResponse(BetaManagedAgentsVault.self, options, stream: _mode == .stream)
    }

    /// Update a Vault
    ///
    /// Args:
    ///   vault_id: Unique identifier of the vault to update.
    ///
    ///   display_name: Updated human-readable name for the vault. 1-255 characters.
    ///
    ///   metadata: Metadata patch. Set a key to a string to upsert it, or to null to delete it.
    ///       Omitted keys are preserved.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
    public func update(_ vaultID: String, displayName: String?? = nil, metadata: [String: String?]?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsVault {
        try await _update(vaultID, displayName: displayName, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ vaultID: String, displayName: String?? = nil, metadata: [String: String?]?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsVault> {
        try requireNonEmpty(vaultID, "vault_id")
        var body = ParamsBuilder()
        try body.set("display_name", displayName)
        try body.set("metadata", metadata)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/vaults/{vault_id}", ["vault_id": vaultID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.vaults.update")
        return try await client.requestResponse(BetaManagedAgentsVault.self, options, stream: _mode == .stream)
    }

    /// List Vaults
    ///
    /// Args:
    ///   include_archived: Whether to include archived vaults in the results. Defaults to `false`.
    ///
    ///   limit: Maximum number of vaults to return per page. Defaults to 20, maximum 100.
    ///
    ///   page: The `next_page` value from a previous
    ///       [List Vaults](https://platform.claude.com/docs/en/api/beta/vaults/list)
    ///       response, to get the next page. Leave it out to get the first page.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
    public func list(includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaManagedAgentsVault> {
        try await _list(includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaManagedAgentsVault>> {
        var query = ParamsBuilder()
        try query.set("include_archived", includeArchived)
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/vaults", query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.vaults.list")
        return try await client.requestPageResponse(PageCursor<BetaManagedAgentsVault>.self, options, stream: _mode == .stream)
    }

    /// Delete a Vault
    ///
    /// Args:
    ///   vault_id: Unique identifier of the vault to delete.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
    public func delete(_ vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsDeletedVault {
        try await _delete(vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsDeletedVault> {
        try requireNonEmpty(vaultID, "vault_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/vaults/{vault_id}", ["vault_id": vaultID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.vaults.delete")
        return try await client.requestResponse(BetaManagedAgentsDeletedVault.self, options, stream: _mode == .stream)
    }

    /// Archive a Vault
    ///
    /// Args:
    ///   vault_id: Unique identifier of the vault to archive.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
    public func archive(_ vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsVault {
        try await _archive(vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _archive(_ vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsVault> {
        try requireNonEmpty(vaultID, "vault_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/vaults/{vault_id}/archive", ["vault_id": vaultID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.vaults.archive")
        return try await client.requestResponse(BetaManagedAgentsVault.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaVaultsResource

        public var credentials: BetaVaultsCredentialsResource.WithRawResponse { resource.credentials.withRawResponse }

    /// Create a Vault
    ///
    /// Args:
    ///   display_name: Human-readable name for the vault.
    ///
    /// 1-255 characters.
    ///
    ///   metadata: Arbitrary key-value metadata to attach to the vault. Maximum 16 pairs, keys up
    ///       to 64 chars, values up to 512 chars.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
        public func create(displayName: String, metadata: [String: String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsVault> {
            try await resource._create(displayName: displayName, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Retrieve a Vault
    ///
    /// Args:
    ///   vault_id: Unique identifier of the vault to retrieve.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
        public func retrieve(_ vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsVault> {
            try await resource._retrieve(vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update a Vault
    ///
    /// Args:
    ///   vault_id: Unique identifier of the vault to update.
    ///
    ///   display_name: Updated human-readable name for the vault. 1-255 characters.
    ///
    ///   metadata: Metadata patch. Set a key to a string to upsert it, or to null to delete it.
    ///       Omitted keys are preserved.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
        public func update(_ vaultID: String, displayName: String?? = nil, metadata: [String: String?]?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsVault> {
            try await resource._update(vaultID, displayName: displayName, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List Vaults
    ///
    /// Args:
    ///   include_archived: Whether to include archived vaults in the results. Defaults to `false`.
    ///
    ///   limit: Maximum number of vaults to return per page. Defaults to 20, maximum 100.
    ///
    ///   page: The `next_page` value from a previous
    ///       [List Vaults](https://platform.claude.com/docs/en/api/beta/vaults/list)
    ///       response, to get the next page. Leave it out to get the first page.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
        public func list(includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaManagedAgentsVault>> {
            try await resource._list(includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete a Vault
    ///
    /// Args:
    ///   vault_id: Unique identifier of the vault to delete.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
        public func delete(_ vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsDeletedVault> {
            try await resource._delete(vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Archive a Vault
    ///
    /// Args:
    ///   vault_id: Unique identifier of the vault to archive.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
        public func archive(_ vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsVault> {
            try await resource._archive(vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaVaultsResource

        public var credentials: BetaVaultsCredentialsResource.WithStreamingResponse { resource.credentials.withStreamingResponse }

    /// Create a Vault
    ///
    /// Args:
    ///   display_name: Human-readable name for the vault.
    ///
    /// 1-255 characters.
    ///
    ///   metadata: Arbitrary key-value metadata to attach to the vault. Maximum 16 pairs, keys up
    ///       to 64 chars, values up to 512 chars.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
        public func create<R: Sendable>(displayName: String, metadata: [String: String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsVault>) async throws -> R) async throws -> R {
            let response = try await resource._create(displayName: displayName, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Retrieve a Vault
    ///
    /// Args:
    ///   vault_id: Unique identifier of the vault to retrieve.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
        public func retrieve<R: Sendable>(_ vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsVault>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Update a Vault
    ///
    /// Args:
    ///   vault_id: Unique identifier of the vault to update.
    ///
    ///   display_name: Updated human-readable name for the vault. 1-255 characters.
    ///
    ///   metadata: Metadata patch. Set a key to a string to upsert it, or to null to delete it.
    ///       Omitted keys are preserved.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
        public func update<R: Sendable>(_ vaultID: String, displayName: String?? = nil, metadata: [String: String?]?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsVault>) async throws -> R) async throws -> R {
            let response = try await resource._update(vaultID, displayName: displayName, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List Vaults
    ///
    /// Args:
    ///   include_archived: Whether to include archived vaults in the results. Defaults to `false`.
    ///
    ///   limit: Maximum number of vaults to return per page. Defaults to 20, maximum 100.
    ///
    ///   page: The `next_page` value from a previous
    ///       [List Vaults](https://platform.claude.com/docs/en/api/beta/vaults/list)
    ///       response, to get the next page. Leave it out to get the first page.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
        public func list<R: Sendable>(includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaManagedAgentsVault>>) async throws -> R) async throws -> R {
            let response = try await resource._list(includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete a Vault
    ///
    /// Args:
    ///   vault_id: Unique identifier of the vault to delete.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
        public func delete<R: Sendable>(_ vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsDeletedVault>) async throws -> R) async throws -> R {
            let response = try await resource._delete(vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Archive a Vault
    ///
    /// Args:
    ///   vault_id: Unique identifier of the vault to archive.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    ///       header.
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
        public func archive<R: Sendable>(_ vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsVault>) async throws -> R) async throws -> R {
            let response = try await resource._archive(vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
