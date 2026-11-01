// Transformed from `anthropic.resources.beta.vaults.credentials` (credentials.py).

import Foundation

public struct BetaVaultsCredentialsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Create a Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault to create the credential in.
    ///
    ///   auth: Authentication configuration for the credential.
    ///
    ///   display_name: Human-readable name for the credential. Up to 255 characters.
    ///
    ///   metadata: Arbitrary key-value metadata to attach to the credential. Maximum 16 pairs, keys
    ///       up to 64 chars, values up to 512 chars.
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
    public func create(_ vaultID: String, auth: CredentialCreateParams.Auth, displayName: String?? = nil, metadata: [String: String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsCredential {
        try await _create(vaultID, auth: auth, displayName: displayName, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(_ vaultID: String, auth: CredentialCreateParams.Auth, displayName: String?? = nil, metadata: [String: String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsCredential> {
        try requireNonEmpty(vaultID, "vault_id")
        var body = ParamsBuilder()
        try body.set("auth", auth)
        try body.set("display_name", displayName)
        try body.set("metadata", metadata)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/vaults/{vault_id}/credentials", ["vault_id": vaultID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.vaults.credentials.create")
        return try await client.requestResponse(BetaManagedAgentsCredential.self, options, stream: _mode == .stream)
    }

    /// Retrieve a Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault containing the credential.
    ///
    ///   credential_id: Unique identifier of the credential to retrieve.
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
    public func retrieve(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsCredential {
        try await _retrieve(credentialID, vaultID: vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsCredential> {
        try requireNonEmpty(vaultID, "vault_id")
        try requireNonEmpty(credentialID, "credential_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/vaults/{vault_id}/credentials/{credential_id}", ["vault_id": vaultID, "credential_id": credentialID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.vaults.credentials.retrieve")
        return try await client.requestResponse(BetaManagedAgentsCredential.self, options, stream: _mode == .stream)
    }

    /// Update a Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault containing the credential.
    ///
    ///   credential_id: Unique identifier of the credential to update.
    ///
    ///   auth: New authentication settings for the credential. The `type` must match the
    ///       credential's current type, which can't be changed.
    ///
    ///   display_name: Updated human-readable name for the credential. 1-255 characters.
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
    public func update(_ credentialID: String, vaultID: String, auth: CredentialUpdateParams.Auth? = nil, displayName: String?? = nil, metadata: [String: String?]?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsCredential {
        try await _update(credentialID, vaultID: vaultID, auth: auth, displayName: displayName, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ credentialID: String, vaultID: String, auth: CredentialUpdateParams.Auth? = nil, displayName: String?? = nil, metadata: [String: String?]?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsCredential> {
        try requireNonEmpty(vaultID, "vault_id")
        try requireNonEmpty(credentialID, "credential_id")
        var body = ParamsBuilder()
        try body.set("auth", auth)
        try body.set("display_name", displayName)
        try body.set("metadata", metadata)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/vaults/{vault_id}/credentials/{credential_id}", ["vault_id": vaultID, "credential_id": credentialID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.vaults.credentials.update")
        return try await client.requestResponse(BetaManagedAgentsCredential.self, options, stream: _mode == .stream)
    }

    /// List Credentials
    ///
    /// Args:
    ///   vault_id: Identifier of the vault to list credentials for.
    ///
    ///   include_archived: Whether to include archived credentials in the results. Defaults to `false`.
    ///
    ///   limit: Maximum number of credentials to return per page. Defaults to 20, maximum 100.
    ///
    ///   page: The `next_page` value from a previous
    ///       [List Credentials](https://platform.claude.com/docs/en/api/beta/vaults/credentials/list)
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
    public func list(_ vaultID: String, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaManagedAgentsCredential> {
        try await _list(vaultID, includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ vaultID: String, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaManagedAgentsCredential>> {
        try requireNonEmpty(vaultID, "vault_id")
        var query = ParamsBuilder()
        try query.set("include_archived", includeArchived)
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/vaults/{vault_id}/credentials", ["vault_id": vaultID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.vaults.credentials.list")
        return try await client.requestPageResponse(PageCursor<BetaManagedAgentsCredential>.self, options, stream: _mode == .stream)
    }

    /// Delete a Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault containing the credential.
    ///
    ///   credential_id: Unique identifier of the credential to delete.
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
    public func delete(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsDeletedCredential {
        try await _delete(credentialID, vaultID: vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsDeletedCredential> {
        try requireNonEmpty(vaultID, "vault_id")
        try requireNonEmpty(credentialID, "credential_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/vaults/{vault_id}/credentials/{credential_id}", ["vault_id": vaultID, "credential_id": credentialID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.vaults.credentials.delete")
        return try await client.requestResponse(BetaManagedAgentsDeletedCredential.self, options, stream: _mode == .stream)
    }

    /// Archive a Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault containing the credential.
    ///
    ///   credential_id: Unique identifier of the credential to archive.
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
    public func archive(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsCredential {
        try await _archive(credentialID, vaultID: vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _archive(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsCredential> {
        try requireNonEmpty(vaultID, "vault_id")
        try requireNonEmpty(credentialID, "credential_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/vaults/{vault_id}/credentials/{credential_id}/archive", ["vault_id": vaultID, "credential_id": credentialID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.vaults.credentials.archive")
        return try await client.requestResponse(BetaManagedAgentsCredential.self, options, stream: _mode == .stream)
    }

    /// Validate an MCP OAuth Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault containing the credential.
    ///
    ///   credential_id: Unique identifier of the credential to validate.
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
    public func mcpOauthValidate(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsCredentialValidation {
        try await _mcpOauthValidate(credentialID, vaultID: vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _mcpOauthValidate(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsCredentialValidation> {
        try requireNonEmpty(vaultID, "vault_id")
        try requireNonEmpty(credentialID, "credential_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/vaults/{vault_id}/credentials/{credential_id}/mcp_oauth_validate", ["vault_id": vaultID, "credential_id": credentialID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.vaults.credentials.mcp_oauth_validate")
        return try await client.requestResponse(BetaManagedAgentsCredentialValidation.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaVaultsCredentialsResource

    /// Create a Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault to create the credential in.
    ///
    ///   auth: Authentication configuration for the credential.
    ///
    ///   display_name: Human-readable name for the credential. Up to 255 characters.
    ///
    ///   metadata: Arbitrary key-value metadata to attach to the credential. Maximum 16 pairs, keys
    ///       up to 64 chars, values up to 512 chars.
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
        public func create(_ vaultID: String, auth: CredentialCreateParams.Auth, displayName: String?? = nil, metadata: [String: String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsCredential> {
            try await resource._create(vaultID, auth: auth, displayName: displayName, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Retrieve a Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault containing the credential.
    ///
    ///   credential_id: Unique identifier of the credential to retrieve.
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
        public func retrieve(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsCredential> {
            try await resource._retrieve(credentialID, vaultID: vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update a Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault containing the credential.
    ///
    ///   credential_id: Unique identifier of the credential to update.
    ///
    ///   auth: New authentication settings for the credential. The `type` must match the
    ///       credential's current type, which can't be changed.
    ///
    ///   display_name: Updated human-readable name for the credential. 1-255 characters.
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
        public func update(_ credentialID: String, vaultID: String, auth: CredentialUpdateParams.Auth? = nil, displayName: String?? = nil, metadata: [String: String?]?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsCredential> {
            try await resource._update(credentialID, vaultID: vaultID, auth: auth, displayName: displayName, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List Credentials
    ///
    /// Args:
    ///   vault_id: Identifier of the vault to list credentials for.
    ///
    ///   include_archived: Whether to include archived credentials in the results. Defaults to `false`.
    ///
    ///   limit: Maximum number of credentials to return per page. Defaults to 20, maximum 100.
    ///
    ///   page: The `next_page` value from a previous
    ///       [List Credentials](https://platform.claude.com/docs/en/api/beta/vaults/credentials/list)
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
        public func list(_ vaultID: String, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaManagedAgentsCredential>> {
            try await resource._list(vaultID, includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete a Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault containing the credential.
    ///
    ///   credential_id: Unique identifier of the credential to delete.
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
        public func delete(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsDeletedCredential> {
            try await resource._delete(credentialID, vaultID: vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Archive a Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault containing the credential.
    ///
    ///   credential_id: Unique identifier of the credential to archive.
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
        public func archive(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsCredential> {
            try await resource._archive(credentialID, vaultID: vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Validate an MCP OAuth Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault containing the credential.
    ///
    ///   credential_id: Unique identifier of the credential to validate.
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
        public func mcpOauthValidate(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsCredentialValidation> {
            try await resource._mcpOauthValidate(credentialID, vaultID: vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaVaultsCredentialsResource

    /// Create a Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault to create the credential in.
    ///
    ///   auth: Authentication configuration for the credential.
    ///
    ///   display_name: Human-readable name for the credential. Up to 255 characters.
    ///
    ///   metadata: Arbitrary key-value metadata to attach to the credential. Maximum 16 pairs, keys
    ///       up to 64 chars, values up to 512 chars.
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
        public func create<R: Sendable>(_ vaultID: String, auth: CredentialCreateParams.Auth, displayName: String?? = nil, metadata: [String: String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsCredential>) async throws -> R) async throws -> R {
            let response = try await resource._create(vaultID, auth: auth, displayName: displayName, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Retrieve a Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault containing the credential.
    ///
    ///   credential_id: Unique identifier of the credential to retrieve.
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
        public func retrieve<R: Sendable>(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsCredential>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(credentialID, vaultID: vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Update a Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault containing the credential.
    ///
    ///   credential_id: Unique identifier of the credential to update.
    ///
    ///   auth: New authentication settings for the credential. The `type` must match the
    ///       credential's current type, which can't be changed.
    ///
    ///   display_name: Updated human-readable name for the credential. 1-255 characters.
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
        public func update<R: Sendable>(_ credentialID: String, vaultID: String, auth: CredentialUpdateParams.Auth? = nil, displayName: String?? = nil, metadata: [String: String?]?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsCredential>) async throws -> R) async throws -> R {
            let response = try await resource._update(credentialID, vaultID: vaultID, auth: auth, displayName: displayName, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List Credentials
    ///
    /// Args:
    ///   vault_id: Identifier of the vault to list credentials for.
    ///
    ///   include_archived: Whether to include archived credentials in the results. Defaults to `false`.
    ///
    ///   limit: Maximum number of credentials to return per page. Defaults to 20, maximum 100.
    ///
    ///   page: The `next_page` value from a previous
    ///       [List Credentials](https://platform.claude.com/docs/en/api/beta/vaults/credentials/list)
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
        public func list<R: Sendable>(_ vaultID: String, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaManagedAgentsCredential>>) async throws -> R) async throws -> R {
            let response = try await resource._list(vaultID, includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete a Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault containing the credential.
    ///
    ///   credential_id: Unique identifier of the credential to delete.
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
        public func delete<R: Sendable>(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsDeletedCredential>) async throws -> R) async throws -> R {
            let response = try await resource._delete(credentialID, vaultID: vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Archive a Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault containing the credential.
    ///
    ///   credential_id: Unique identifier of the credential to archive.
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
        public func archive<R: Sendable>(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsCredential>) async throws -> R) async throws -> R {
            let response = try await resource._archive(credentialID, vaultID: vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Validate an MCP OAuth Credential
    ///
    /// Args:
    ///   vault_id: Identifier of the vault containing the credential.
    ///
    ///   credential_id: Unique identifier of the credential to validate.
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
        public func mcpOauthValidate<R: Sendable>(_ credentialID: String, vaultID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsCredentialValidation>) async throws -> R) async throws -> R {
            let response = try await resource._mcpOauthValidate(credentialID, vaultID: vaultID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
