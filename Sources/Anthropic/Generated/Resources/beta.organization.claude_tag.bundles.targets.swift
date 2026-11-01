// Transformed from `anthropic.resources.beta.organization.claude_tag.bundles.targets` (targets.py).

import Foundation

public struct BetaOrganizationClaudeTagBundlesTargetsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Attach a Bundle to a Slack channel or a Slack workspace.
    ///
    /// A Bundle attached to a
    /// workspace can be used in the workspace and in every channel in it. Attaching a
    /// Bundle to a channel or workspace it is already attached to returns the existing
    /// Bundle Target. The channel or workspace must be set up: attaching never sets a
    /// channel up. A group direct message takes no Bundle and returns 400.
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
    public func create(_ bundleID: String, target: BetaClaudeTagBundleTargetCreateParam, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaClaudeTagBundleTarget {
        try await _create(bundleID, target: target, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(_ bundleID: String, target: BetaClaudeTagBundleTargetCreateParam, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaClaudeTagBundleTarget> {
        try requireNonEmpty(bundleID, "bundle_id")
        var body = ParamsBuilder()
        try body.merge(target)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/claude_tag/bundles/{bundle_id}/targets", ["bundle_id": bundleID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "experimental-claude-tag-2026-10-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["experimental-claude-tag-2026-10-21"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.claude_tag.bundles.targets.create", spanRoute: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets", spanAttributes: ["anthropic.organization.claude_tag.bundle.id": bundleID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaClaudeTagBundleTarget.self, options, stream: _mode == .stream)
    }

    /// Get one Bundle Target.
    ///
    /// Returns 404 when `target_id` is the identifier of another
    /// Bundle's Bundle Target, or the Bundle Target was detached.
    ///
    /// Args:
    ///   bundle_id: The Bundle's identifier, starting with `capp_`.
    ///
    ///   target_id: The Bundle Target's identifier, starting with `btgt_`. Attach Bundle and List
    ///       Bundle Targets return it. It is never the identifier of the channel or
    ///       workspace.
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
    public func retrieve(_ targetID: String, bundleID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaClaudeTagBundleTarget {
        try await _retrieve(targetID, bundleID: bundleID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ targetID: String, bundleID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaClaudeTagBundleTarget> {
        try requireNonEmpty(bundleID, "bundle_id")
        try requireNonEmpty(targetID, "target_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/claude_tag/bundles/{bundle_id}/targets/{target_id}", ["bundle_id": bundleID, "target_id": targetID]), headers: mergeHeaderLayers(["anthropic-beta": "experimental-claude-tag-2026-10-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["experimental-claude-tag-2026-10-21"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.claude_tag.bundles.targets.retrieve", spanRoute: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets/{target_id}", spanAttributes: ["anthropic.organization.claude_tag.bundle.id": bundleID, "anthropic.organization.claude_tag.bundle.target.id": targetID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaClaudeTagBundleTarget.self, options, stream: _mode == .stream)
    }

    /// List the Slack channels and Slack workspaces a Bundle is attached to, newest
    /// first by `created_at`. Only channels and workspaces the organization owns are
    /// listed; a Bundle that is attached to anything else has no Bundle Target for it.
    ///
    /// Args:
    ///   bundle_id: The Bundle's identifier, starting with `capp_`.
    ///
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
    public func list(_ bundleID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaClaudeTagBundleTarget> {
        try await _list(bundleID, limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ bundleID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaClaudeTagBundleTarget>> {
        try requireNonEmpty(bundleID, "bundle_id")
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/claude_tag/bundles/{bundle_id}/targets", ["bundle_id": bundleID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "experimental-claude-tag-2026-10-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["experimental-claude-tag-2026-10-21"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.claude_tag.bundles.targets.list", spanRoute: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets", spanAttributes: ["anthropic.organization.claude_tag.bundle.id": bundleID], qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaClaudeTagBundleTarget>.self, options, stream: _mode == .stream)
    }

    /// Detach a Bundle from a Slack channel or a Slack workspace.
    ///
    /// A repeated detach
    /// returns 404.
    ///
    /// Args:
    ///   bundle_id: The Bundle's identifier, starting with `capp_`.
    ///
    ///   target_id: The Bundle Target's identifier, starting with `btgt_`. Attach Bundle and List
    ///       Bundle Targets return it. It is never the identifier of the channel or
    ///       workspace.
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
    public func delete(_ targetID: String, bundleID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaClaudeTagDeletedBundleTarget {
        try await _delete(targetID, bundleID: bundleID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ targetID: String, bundleID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaClaudeTagDeletedBundleTarget> {
        try requireNonEmpty(bundleID, "bundle_id")
        try requireNonEmpty(targetID, "target_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/claude_tag/bundles/{bundle_id}/targets/{target_id}", ["bundle_id": bundleID, "target_id": targetID]), headers: mergeHeaderLayers(["anthropic-beta": "experimental-claude-tag-2026-10-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["experimental-claude-tag-2026-10-21"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.claude_tag.bundles.targets.delete", spanRoute: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets/{target_id}", spanAttributes: ["anthropic.organization.claude_tag.bundle.id": bundleID, "anthropic.organization.claude_tag.bundle.target.id": targetID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaClaudeTagDeletedBundleTarget.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationClaudeTagBundlesTargetsResource

    /// Attach a Bundle to a Slack channel or a Slack workspace.
    ///
    /// A Bundle attached to a
    /// workspace can be used in the workspace and in every channel in it. Attaching a
    /// Bundle to a channel or workspace it is already attached to returns the existing
    /// Bundle Target. The channel or workspace must be set up: attaching never sets a
    /// channel up. A group direct message takes no Bundle and returns 400.
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
        public func create(_ bundleID: String, target: BetaClaudeTagBundleTargetCreateParam, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaClaudeTagBundleTarget> {
            try await resource._create(bundleID, target: target, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Get one Bundle Target.
    ///
    /// Returns 404 when `target_id` is the identifier of another
    /// Bundle's Bundle Target, or the Bundle Target was detached.
    ///
    /// Args:
    ///   bundle_id: The Bundle's identifier, starting with `capp_`.
    ///
    ///   target_id: The Bundle Target's identifier, starting with `btgt_`. Attach Bundle and List
    ///       Bundle Targets return it. It is never the identifier of the channel or
    ///       workspace.
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
        public func retrieve(_ targetID: String, bundleID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaClaudeTagBundleTarget> {
            try await resource._retrieve(targetID, bundleID: bundleID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List the Slack channels and Slack workspaces a Bundle is attached to, newest
    /// first by `created_at`. Only channels and workspaces the organization owns are
    /// listed; a Bundle that is attached to anything else has no Bundle Target for it.
    ///
    /// Args:
    ///   bundle_id: The Bundle's identifier, starting with `capp_`.
    ///
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
        public func list(_ bundleID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaClaudeTagBundleTarget>> {
            try await resource._list(bundleID, limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Detach a Bundle from a Slack channel or a Slack workspace.
    ///
    /// A repeated detach
    /// returns 404.
    ///
    /// Args:
    ///   bundle_id: The Bundle's identifier, starting with `capp_`.
    ///
    ///   target_id: The Bundle Target's identifier, starting with `btgt_`. Attach Bundle and List
    ///       Bundle Targets return it. It is never the identifier of the channel or
    ///       workspace.
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
        public func delete(_ targetID: String, bundleID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaClaudeTagDeletedBundleTarget> {
            try await resource._delete(targetID, bundleID: bundleID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationClaudeTagBundlesTargetsResource

    /// Attach a Bundle to a Slack channel or a Slack workspace.
    ///
    /// A Bundle attached to a
    /// workspace can be used in the workspace and in every channel in it. Attaching a
    /// Bundle to a channel or workspace it is already attached to returns the existing
    /// Bundle Target. The channel or workspace must be set up: attaching never sets a
    /// channel up. A group direct message takes no Bundle and returns 400.
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
        public func create<R: Sendable>(_ bundleID: String, target: BetaClaudeTagBundleTargetCreateParam, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaClaudeTagBundleTarget>) async throws -> R) async throws -> R {
            let response = try await resource._create(bundleID, target: target, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Get one Bundle Target.
    ///
    /// Returns 404 when `target_id` is the identifier of another
    /// Bundle's Bundle Target, or the Bundle Target was detached.
    ///
    /// Args:
    ///   bundle_id: The Bundle's identifier, starting with `capp_`.
    ///
    ///   target_id: The Bundle Target's identifier, starting with `btgt_`. Attach Bundle and List
    ///       Bundle Targets return it. It is never the identifier of the channel or
    ///       workspace.
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
        public func retrieve<R: Sendable>(_ targetID: String, bundleID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaClaudeTagBundleTarget>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(targetID, bundleID: bundleID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List the Slack channels and Slack workspaces a Bundle is attached to, newest
    /// first by `created_at`. Only channels and workspaces the organization owns are
    /// listed; a Bundle that is attached to anything else has no Bundle Target for it.
    ///
    /// Args:
    ///   bundle_id: The Bundle's identifier, starting with `capp_`.
    ///
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
        public func list<R: Sendable>(_ bundleID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaClaudeTagBundleTarget>>) async throws -> R) async throws -> R {
            let response = try await resource._list(bundleID, limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Detach a Bundle from a Slack channel or a Slack workspace.
    ///
    /// A repeated detach
    /// returns 404.
    ///
    /// Args:
    ///   bundle_id: The Bundle's identifier, starting with `capp_`.
    ///
    ///   target_id: The Bundle Target's identifier, starting with `btgt_`. Attach Bundle and List
    ///       Bundle Targets return it. It is never the identifier of the channel or
    ///       workspace.
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
        public func delete<R: Sendable>(_ targetID: String, bundleID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaClaudeTagDeletedBundleTarget>) async throws -> R) async throws -> R {
            let response = try await resource._delete(targetID, bundleID: bundleID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
