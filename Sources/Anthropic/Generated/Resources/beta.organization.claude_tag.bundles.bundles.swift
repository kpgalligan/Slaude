// Transformed from `anthropic.resources.beta.organization.claude_tag.bundles.bundles` (bundles.py).

import Foundation

public struct BetaOrganizationClaudeTagBundlesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var targets: BetaOrganizationClaudeTagBundlesTargetsResource { BetaOrganizationClaudeTagBundlesTargetsResource(client: client) }

    /// Get one Bundle.
    ///
    /// What the Bundle grants (connectors, repositories and
    /// credentials) is never returned.
    ///
    /// Args:
    ///   bundle_id: The Bundle's identifier, starting with `capp_`.
    ///
    ///   betas: This endpoint is in beta: requests must send
    ///       `experimental-claude-tag-2026-10-21` in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ bundleID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaClaudeTagBundle {
        try await _retrieve(bundleID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ bundleID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaClaudeTagBundle> {
        try requireNonEmpty(bundleID, "bundle_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/claude_tag/bundles/{bundle_id}", ["bundle_id": bundleID]), headers: mergeHeaderLayers(["anthropic-beta": "experimental-claude-tag-2026-10-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["experimental-claude-tag-2026-10-21"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.claude_tag.bundles.retrieve", spanRoute: "/v1/organizations/claude_tag/bundles/{bundle_id}", spanAttributes: ["anthropic.organization.claude_tag.bundle.id": bundleID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaClaudeTagBundle.self, options, stream: _mode == .stream)
    }

    /// List the organization's Bundles, newest first by `created_at`.
    ///
    /// A Bundle that
    /// Claude Tag manages for itself is not listed.
    ///
    /// Args:
    ///   limit: Number of items to return per page, between 1 and 100. Defaults to 20.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   betas: This endpoint is in beta: requests must send
    ///       `experimental-claude-tag-2026-10-21` in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaClaudeTagBundle> {
        try await _list(limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaClaudeTagBundle>> {
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/claude_tag/bundles", query: query, headers: mergeHeaderLayers(["anthropic-beta": "experimental-claude-tag-2026-10-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["experimental-claude-tag-2026-10-21"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.claude_tag.bundles.list", spanRoute: "/v1/organizations/claude_tag/bundles", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaClaudeTagBundle>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationClaudeTagBundlesResource

        public var targets: BetaOrganizationClaudeTagBundlesTargetsResource.WithRawResponse { resource.targets.withRawResponse }

    /// Get one Bundle.
    ///
    /// What the Bundle grants (connectors, repositories and
    /// credentials) is never returned.
    ///
    /// Args:
    ///   bundle_id: The Bundle's identifier, starting with `capp_`.
    ///
    ///   betas: This endpoint is in beta: requests must send
    ///       `experimental-claude-tag-2026-10-21` in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ bundleID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaClaudeTagBundle> {
            try await resource._retrieve(bundleID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List the organization's Bundles, newest first by `created_at`.
    ///
    /// A Bundle that
    /// Claude Tag manages for itself is not listed.
    ///
    /// Args:
    ///   limit: Number of items to return per page, between 1 and 100. Defaults to 20.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   betas: This endpoint is in beta: requests must send
    ///       `experimental-claude-tag-2026-10-21` in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaClaudeTagBundle>> {
            try await resource._list(limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationClaudeTagBundlesResource

        public var targets: BetaOrganizationClaudeTagBundlesTargetsResource.WithStreamingResponse { resource.targets.withStreamingResponse }

    /// Get one Bundle.
    ///
    /// What the Bundle grants (connectors, repositories and
    /// credentials) is never returned.
    ///
    /// Args:
    ///   bundle_id: The Bundle's identifier, starting with `capp_`.
    ///
    ///   betas: This endpoint is in beta: requests must send
    ///       `experimental-claude-tag-2026-10-21` in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ bundleID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaClaudeTagBundle>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(bundleID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List the organization's Bundles, newest first by `created_at`.
    ///
    /// A Bundle that
    /// Claude Tag manages for itself is not listed.
    ///
    /// Args:
    ///   limit: Number of items to return per page, between 1 and 100. Defaults to 20.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   betas: This endpoint is in beta: requests must send
    ///       `experimental-claude-tag-2026-10-21` in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaClaudeTagBundle>>) async throws -> R) async throws -> R {
            let response = try await resource._list(limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
