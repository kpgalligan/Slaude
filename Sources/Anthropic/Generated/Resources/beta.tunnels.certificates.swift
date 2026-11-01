// Transformed from `anthropic.resources.beta.tunnels.certificates` (certificates.py).

import Foundation

public struct BetaTunnelsCertificatesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Registers a public CA certificate on a tunnel. Anthropic verifies the gateway's
    /// server certificate against this CA when it terminates the inner TLS session. A
    /// tunnel holds at most two non-archived certificates.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   ca_certificate_pem: PEM-encoded X.509 CA certificate. Must contain exactly one certificate and no
    ///       private-key material. Maximum 8KB.
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
    public func create(_ tunnelID: String, caCertificatePem: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaTunnelCertificate {
        try await _create(tunnelID, caCertificatePem: caCertificatePem, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(_ tunnelID: String, caCertificatePem: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaTunnelCertificate> {
        try requireNonEmpty(tunnelID, "tunnel_id")
        var body = ParamsBuilder()
        try body.set("ca_certificate_pem", caCertificatePem)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/tunnels/{tunnel_id}/certificates", ["tunnel_id": tunnelID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "mcp-tunnels-2026-06-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["mcp-tunnels-2026-06-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.tunnels.certificates.create")
        return try await client.requestResponse(BetaTunnelCertificate.self, options, stream: _mode == .stream)
    }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Fetches a tunnel certificate by ID.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   certificate_id: ID of the certificate (`tcrt_...`).
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
    public func retrieve(_ certificateID: String, tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaTunnelCertificate {
        try await _retrieve(certificateID, tunnelID: tunnelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ certificateID: String, tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaTunnelCertificate> {
        try requireNonEmpty(tunnelID, "tunnel_id")
        try requireNonEmpty(certificateID, "certificate_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/tunnels/{tunnel_id}/certificates/{certificate_id}", ["tunnel_id": tunnelID, "certificate_id": certificateID]), headers: mergeHeaderLayers(["anthropic-beta": "mcp-tunnels-2026-06-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["mcp-tunnels-2026-06-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.tunnels.certificates.retrieve")
        return try await client.requestResponse(BetaTunnelCertificate.self, options, stream: _mode == .stream)
    }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Lists the certificates registered on a tunnel. Archived certificates are
    /// excluded unless include_archived is set.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   include_archived: Whether to include archived certificates in the results. Defaults to false.
    ///
    ///   limit: Maximum number of certificates to return per page. Defaults to 20, maximum 1000.
    ///
    ///   page: Opaque pagination cursor from a previous `list_tunnel_certificates` response.
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
    public func list(_ tunnelID: String, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaTunnelCertificate> {
        try await _list(tunnelID, includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ tunnelID: String, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaTunnelCertificate>> {
        try requireNonEmpty(tunnelID, "tunnel_id")
        var query = ParamsBuilder()
        try query.set("include_archived", includeArchived)
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/tunnels/{tunnel_id}/certificates", ["tunnel_id": tunnelID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "mcp-tunnels-2026-06-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["mcp-tunnels-2026-06-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.tunnels.certificates.list")
        return try await client.requestPageResponse(PageCursor<BetaTunnelCertificate>.self, options, stream: _mode == .stream)
    }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Archives a tunnel certificate, removing it from the set Anthropic trusts for the
    /// tunnel. The certificate record is retained. Archiving the last non-archived
    /// certificate is permitted; the tunnel rejects MCP traffic until a new certificate
    /// is added.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   certificate_id: ID of the certificate to archive (`tcrt_...`).
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
    public func archive(_ certificateID: String, tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaTunnelCertificate {
        try await _archive(certificateID, tunnelID: tunnelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _archive(_ certificateID: String, tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaTunnelCertificate> {
        try requireNonEmpty(tunnelID, "tunnel_id")
        try requireNonEmpty(certificateID, "certificate_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/tunnels/{tunnel_id}/certificates/{certificate_id}/archive", ["tunnel_id": tunnelID, "certificate_id": certificateID]), headers: mergeHeaderLayers(["anthropic-beta": "mcp-tunnels-2026-06-22"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["mcp-tunnels-2026-06-22"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.tunnels.certificates.archive")
        return try await client.requestResponse(BetaTunnelCertificate.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaTunnelsCertificatesResource

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Registers a public CA certificate on a tunnel. Anthropic verifies the gateway's
    /// server certificate against this CA when it terminates the inner TLS session. A
    /// tunnel holds at most two non-archived certificates.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   ca_certificate_pem: PEM-encoded X.509 CA certificate. Must contain exactly one certificate and no
    ///       private-key material. Maximum 8KB.
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
        public func create(_ tunnelID: String, caCertificatePem: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaTunnelCertificate> {
            try await resource._create(tunnelID, caCertificatePem: caCertificatePem, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Fetches a tunnel certificate by ID.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   certificate_id: ID of the certificate (`tcrt_...`).
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
        public func retrieve(_ certificateID: String, tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaTunnelCertificate> {
            try await resource._retrieve(certificateID, tunnelID: tunnelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Lists the certificates registered on a tunnel. Archived certificates are
    /// excluded unless include_archived is set.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   include_archived: Whether to include archived certificates in the results. Defaults to false.
    ///
    ///   limit: Maximum number of certificates to return per page. Defaults to 20, maximum 1000.
    ///
    ///   page: Opaque pagination cursor from a previous `list_tunnel_certificates` response.
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
        public func list(_ tunnelID: String, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaTunnelCertificate>> {
            try await resource._list(tunnelID, includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Archives a tunnel certificate, removing it from the set Anthropic trusts for the
    /// tunnel. The certificate record is retained. Archiving the last non-archived
    /// certificate is permitted; the tunnel rejects MCP traffic until a new certificate
    /// is added.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   certificate_id: ID of the certificate to archive (`tcrt_...`).
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
        public func archive(_ certificateID: String, tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaTunnelCertificate> {
            try await resource._archive(certificateID, tunnelID: tunnelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaTunnelsCertificatesResource

    /// The Tunnels API is in research preview.
    ///
    /// It requires the
    /// `anthropic-beta: mcp-tunnels-2026-06-22` header and may change without a
    /// deprecation period. It supersedes the Admin API endpoints at
    /// `/v1/organizations/tunnels`, which remain available during a migration window.
    ///
    /// Registers a public CA certificate on a tunnel. Anthropic verifies the gateway's
    /// server certificate against this CA when it terminates the inner TLS session. A
    /// tunnel holds at most two non-archived certificates.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   ca_certificate_pem: PEM-encoded X.509 CA certificate. Must contain exactly one certificate and no
    ///       private-key material. Maximum 8KB.
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
        public func create<R: Sendable>(_ tunnelID: String, caCertificatePem: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaTunnelCertificate>) async throws -> R) async throws -> R {
            let response = try await resource._create(tunnelID, caCertificatePem: caCertificatePem, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
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
    /// Fetches a tunnel certificate by ID.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   certificate_id: ID of the certificate (`tcrt_...`).
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
        public func retrieve<R: Sendable>(_ certificateID: String, tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaTunnelCertificate>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(certificateID, tunnelID: tunnelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
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
    /// Lists the certificates registered on a tunnel. Archived certificates are
    /// excluded unless include_archived is set.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   include_archived: Whether to include archived certificates in the results. Defaults to false.
    ///
    ///   limit: Maximum number of certificates to return per page. Defaults to 20, maximum 1000.
    ///
    ///   page: Opaque pagination cursor from a previous `list_tunnel_certificates` response.
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
        public func list<R: Sendable>(_ tunnelID: String, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaTunnelCertificate>>) async throws -> R) async throws -> R {
            let response = try await resource._list(tunnelID, includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
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
    /// Archives a tunnel certificate, removing it from the set Anthropic trusts for the
    /// tunnel. The certificate record is retained. Archiving the last non-archived
    /// certificate is permitted; the tunnel rejects MCP traffic until a new certificate
    /// is added.
    ///
    /// Args:
    ///   tunnel_id: ID of the tunnel (`tnl_...`).
    ///
    ///   certificate_id: ID of the certificate to archive (`tcrt_...`).
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
        public func archive<R: Sendable>(_ certificateID: String, tunnelID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaTunnelCertificate>) async throws -> R) async throws -> R {
            let response = try await resource._archive(certificateID, tunnelID: tunnelID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
