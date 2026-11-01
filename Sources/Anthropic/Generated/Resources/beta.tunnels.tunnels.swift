// Transformed from `anthropic.resources.beta.tunnels.tunnels` (tunnels.py).

import Foundation

public struct BetaTunnelsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var certificates: BetaTunnelsCertificatesResource { BetaTunnelsCertificatesResource(client: client) }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Creates a tunnel. Creation allocates a fresh hostname and provisions the tunnel;
    /// it is not idempotent. The new tunnel rejects MCP traffic until at least one CA
    /// certificate is added.
    ///
    /// Args:
    ///   display_name: Optional human-readable name for the tunnel (1-255 characters).
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
    public func create(displayName: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaTunnel {
        try await _create(displayName: displayName, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(displayName: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaTunnel> {
        var body = ParamsBuilder()
        try body.set("display_name", displayName)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/tunnels", body: body, headers: mergeHeaderLayers(["anthropic-beta": "mcp-tunnels-2026-06-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["mcp-tunnels-2026-06-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.tunnels.create")
        return try await client.requestResponse(BetaTunnel.self, options, stream: _mode == .stream)
    }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Fetches a tunnel by ID.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
    public func retrieve(_ tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaTunnel {
        try await _retrieve(tunnelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaTunnel> {
        try requireNonEmpty(tunnelID, "tunnel_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/tunnels/{tunnel_id}", ["tunnel_id": tunnelID]), headers: mergeHeaderLayers(["anthropic-beta": "mcp-tunnels-2026-06-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["mcp-tunnels-2026-06-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.tunnels.retrieve")
        return try await client.requestResponse(BetaTunnel.self, options, stream: _mode == .stream)
    }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Lists tunnels. Results are ordered by creation time, newest first; archived
    /// tunnels are excluded unless include_archived is set.
    ///
    /// Args:
    ///   include_archived: Whether to include archived tunnels in the results. Defaults to false.
    ///
    ///   limit: Maximum number of tunnels to return per page. Defaults to 20, maximum 1000.
    ///
    ///   page: Opaque pagination cursor from a previous `list_tunnels` response.
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
    public func list(includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaTunnel> {
        try await _list(includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaTunnel>> {
        var query = ParamsBuilder()
        try query.set("include_archived", includeArchived)
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/tunnels", query: query, headers: mergeHeaderLayers(["anthropic-beta": "mcp-tunnels-2026-06-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["mcp-tunnels-2026-06-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.tunnels.list")
        return try await client.requestPageResponse(PageCursor<BetaTunnel>.self, options, stream: _mode == .stream)
    }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Archives a tunnel. Archival is irreversible: every non-archived certificate on
    /// the tunnel is archived in the same operation, the hostname is retired and never
    /// re-allocated, and the tunnel token is invalidated. Retrying against an
    /// already-archived tunnel returns the existing record unchanged.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
    public func archive(_ tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaTunnel {
        try await _archive(tunnelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _archive(_ tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaTunnel> {
        try requireNonEmpty(tunnelID, "tunnel_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/tunnels/{tunnel_id}/archive", ["tunnel_id": tunnelID]), headers: mergeHeaderLayers(["anthropic-beta": "mcp-tunnels-2026-06-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["mcp-tunnels-2026-06-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.tunnels.archive")
        return try await client.requestResponse(BetaTunnel.self, options, stream: _mode == .stream)
    }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Reveals a tunnel's connector token. The value is fetched live on each call;
    /// Anthropic does not store it. Repeated calls return the same value until the
    /// token is rotated. Exposed as POST so the token does not appear in intermediary
    /// access logs.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
    public func revealToken(_ tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaTunnelToken {
        try await _revealToken(tunnelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _revealToken(_ tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaTunnelToken> {
        try requireNonEmpty(tunnelID, "tunnel_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/tunnels/{tunnel_id}/reveal_token", ["tunnel_id": tunnelID]), headers: mergeHeaderLayers(["anthropic-beta": "mcp-tunnels-2026-06-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["mcp-tunnels-2026-06-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.tunnels.reveal_token")
        return try await client.requestResponse(BetaTunnelToken.self, options, stream: _mode == .stream)
    }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Rotates a tunnel's connector token. Rotation invalidates the current token for
    /// new connections and returns a fresh value; established connections are not
    /// severed. A connector restarted after rotation must use the new value.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   reason: Optional free-text reason for the rotation, recorded for audit.
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
    public func rotateToken(_ tunnelID: String, reason: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaTunnelToken {
        try await _rotateToken(tunnelID, reason: reason, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _rotateToken(_ tunnelID: String, reason: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaTunnelToken> {
        try requireNonEmpty(tunnelID, "tunnel_id")
        var body = ParamsBuilder()
        try body.set("reason", reason)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/tunnels/{tunnel_id}/rotate_token", ["tunnel_id": tunnelID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "mcp-tunnels-2026-06-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["mcp-tunnels-2026-06-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.tunnels.rotate_token")
        return try await client.requestResponse(BetaTunnelToken.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaTunnelsResource

        public var certificates: BetaTunnelsCertificatesResource.WithRawResponse { resource.certificates.withRawResponse }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Creates a tunnel. Creation allocates a fresh hostname and provisions the tunnel;
    /// it is not idempotent. The new tunnel rejects MCP traffic until at least one CA
    /// certificate is added.
    ///
    /// Args:
    ///   display_name: Optional human-readable name for the tunnel (1-255 characters).
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
        public func create(displayName: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaTunnel> {
            try await resource._create(displayName: displayName, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Fetches a tunnel by ID.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
        public func retrieve(_ tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaTunnel> {
            try await resource._retrieve(tunnelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Lists tunnels. Results are ordered by creation time, newest first; archived
    /// tunnels are excluded unless include_archived is set.
    ///
    /// Args:
    ///   include_archived: Whether to include archived tunnels in the results. Defaults to false.
    ///
    ///   limit: Maximum number of tunnels to return per page. Defaults to 20, maximum 1000.
    ///
    ///   page: Opaque pagination cursor from a previous `list_tunnels` response.
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
        public func list(includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaTunnel>> {
            try await resource._list(includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Archives a tunnel. Archival is irreversible: every non-archived certificate on
    /// the tunnel is archived in the same operation, the hostname is retired and never
    /// re-allocated, and the tunnel token is invalidated. Retrying against an
    /// already-archived tunnel returns the existing record unchanged.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
        public func archive(_ tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaTunnel> {
            try await resource._archive(tunnelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Reveals a tunnel's connector token. The value is fetched live on each call;
    /// Anthropic does not store it. Repeated calls return the same value until the
    /// token is rotated. Exposed as POST so the token does not appear in intermediary
    /// access logs.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
        public func revealToken(_ tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaTunnelToken> {
            try await resource._revealToken(tunnelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Rotates a tunnel's connector token. Rotation invalidates the current token for
    /// new connections and returns a fresh value; established connections are not
    /// severed. A connector restarted after rotation must use the new value.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   reason: Optional free-text reason for the rotation, recorded for audit.
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
        public func rotateToken(_ tunnelID: String, reason: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaTunnelToken> {
            try await resource._rotateToken(tunnelID, reason: reason, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaTunnelsResource

        public var certificates: BetaTunnelsCertificatesResource.WithStreamingResponse { resource.certificates.withStreamingResponse }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Creates a tunnel. Creation allocates a fresh hostname and provisions the tunnel;
    /// it is not idempotent. The new tunnel rejects MCP traffic until at least one CA
    /// certificate is added.
    ///
    /// Args:
    ///   display_name: Optional human-readable name for the tunnel (1-255 characters).
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
        public func create<R: Sendable>(displayName: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaTunnel>) async throws -> R) async throws -> R {
            let response = try await resource._create(displayName: displayName, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Fetches a tunnel by ID.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
        public func retrieve<R: Sendable>(_ tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaTunnel>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(tunnelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Lists tunnels. Results are ordered by creation time, newest first; archived
    /// tunnels are excluded unless include_archived is set.
    ///
    /// Args:
    ///   include_archived: Whether to include archived tunnels in the results. Defaults to false.
    ///
    ///   limit: Maximum number of tunnels to return per page. Defaults to 20, maximum 1000.
    ///
    ///   page: Opaque pagination cursor from a previous `list_tunnels` response.
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
        public func list<R: Sendable>(includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaTunnel>>) async throws -> R) async throws -> R {
            let response = try await resource._list(includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Archives a tunnel. Archival is irreversible: every non-archived certificate on
    /// the tunnel is archived in the same operation, the hostname is retired and never
    /// re-allocated, and the tunnel token is invalidated. Retrying against an
    /// already-archived tunnel returns the existing record unchanged.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
        public func archive<R: Sendable>(_ tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaTunnel>) async throws -> R) async throws -> R {
            let response = try await resource._archive(tunnelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Reveals a tunnel's connector token. The value is fetched live on each call;
    /// Anthropic does not store it. Repeated calls return the same value until the
    /// token is rotated. Exposed as POST so the token does not appear in intermediary
    /// access logs.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
        public func revealToken<R: Sendable>(_ tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaTunnelToken>) async throws -> R) async throws -> R {
            let response = try await resource._revealToken(tunnelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Rotates a tunnel's connector token. Rotation invalidates the current token for
    /// new connections and returns a fresh value; established connections are not
    /// severed. A connector restarted after rotation must use the new value.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   reason: Optional free-text reason for the rotation, recorded for audit.
    ///
    ///   betas: This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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
        public func rotateToken<R: Sendable>(_ tunnelID: String, reason: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaTunnelToken>) async throws -> R) async throws -> R {
            let response = try await resource._rotateToken(tunnelID, reason: reason, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
