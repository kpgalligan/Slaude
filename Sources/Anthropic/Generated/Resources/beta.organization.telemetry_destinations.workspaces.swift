// Transformed from `anthropic.resources.beta.organization.telemetry_destinations.workspaces` (workspaces.py).

import Foundation

public struct BetaOrganizationTelemetryDestinationsWorkspacesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// List the workspaces on a destination's workspace list, newest entry first.
    ///
    /// A destination whose `workspaces.type` is `all` doesn't have a list, so its page
    /// is empty. The list includes archived workspaces.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#choose-workspaces-for-a-destination)
    /// to learn more about choosing the workspaces of a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
    ///
    ///   limit: Number of entries to return per page, between 1 and 1,000. Defaults to 20.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`. Leave it out to get the
    ///       first page.
    ///
    ///   betas: This endpoint is in beta: requests must send `telemetry-destinations-2026-08-11`
    ///       in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(_ destinationID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaTelemetryDestinationWorkspace> {
        try await _list(destinationID, limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ destinationID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaTelemetryDestinationWorkspace>> {
        try requireNonEmpty(destinationID, "destination_id")
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/telemetry_destinations/{destination_id}/workspaces", ["destination_id": destinationID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "telemetry-destinations-2026-08-11"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["telemetry-destinations-2026-08-11"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.telemetry_destinations.workspaces.list", spanRoute: "/v1/organizations/telemetry_destinations/{destination_id}/workspaces", spanAttributes: ["anthropic.organization.telemetry_destination.id": destinationID], qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaTelemetryDestinationWorkspace>.self, options, stream: _mode == .stream)
    }

    /// Add one workspace to a destination's workspace list.
    ///
    /// Under `include` the workspace's spans start going to the destination. Under
    /// `exclude` they stop. A list holds at most 1,000 workspaces.
    ///
    /// Adding a workspace that is already on the list changes nothing and returns the
    /// existing entry. An archived workspace that isn't on the list yet can't be added.
    /// A destination whose `workspaces.type` is `all` doesn't have a list, so the API
    /// returns 400. To change which workspaces such a destination covers, update its
    /// `workspaces`.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#choose-workspaces-for-a-destination)
    /// to learn more about choosing the workspaces of a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
    ///
    ///   workspace_id: ID of the workspace to add (`wrkspc_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `telemetry-destinations-2026-08-11`
    ///       in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func add(_ workspaceID: String, destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaTelemetryDestinationWorkspace {
        try await _add(workspaceID, destinationID: destinationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _add(_ workspaceID: String, destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaTelemetryDestinationWorkspace> {
        try requireNonEmpty(destinationID, "destination_id")
        try requireNonEmpty(workspaceID, "workspace_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/telemetry_destinations/{destination_id}/workspaces/{workspace_id}", ["destination_id": destinationID, "workspace_id": workspaceID]), headers: mergeHeaderLayers(["anthropic-beta": "telemetry-destinations-2026-08-11"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["telemetry-destinations-2026-08-11"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.telemetry_destinations.workspaces.add", spanRoute: "/v1/organizations/telemetry_destinations/{destination_id}/workspaces/{workspace_id}", spanAttributes: ["anthropic.organization.telemetry_destination.id": destinationID, "anthropic.organization.telemetry_destination.workspace.id": workspaceID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaTelemetryDestinationWorkspace.self, options, stream: _mode == .stream)
    }

    /// Remove one workspace from a destination's workspace list.
    ///
    /// Under `include` the workspace's spans stop going to the destination. Under
    /// `exclude` they start. An archived workspace can be removed too.
    ///
    /// The API returns 404 when the workspace isn't on the list. A destination whose
    /// `workspaces.type` is `all` doesn't have a list, so the API returns 400.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#choose-workspaces-for-a-destination)
    /// to learn more about choosing the workspaces of a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
    ///
    ///   workspace_id: ID of the workspace to remove (`wrkspc_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `telemetry-destinations-2026-08-11`
    ///       in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func remove(_ workspaceID: String, destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaDeletedTelemetryDestinationWorkspace {
        try await _remove(workspaceID, destinationID: destinationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _remove(_ workspaceID: String, destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaDeletedTelemetryDestinationWorkspace> {
        try requireNonEmpty(destinationID, "destination_id")
        try requireNonEmpty(workspaceID, "workspace_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/telemetry_destinations/{destination_id}/workspaces/{workspace_id}", ["destination_id": destinationID, "workspace_id": workspaceID]), headers: mergeHeaderLayers(["anthropic-beta": "telemetry-destinations-2026-08-11"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["telemetry-destinations-2026-08-11"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.telemetry_destinations.workspaces.remove", spanRoute: "/v1/organizations/telemetry_destinations/{destination_id}/workspaces/{workspace_id}", spanAttributes: ["anthropic.organization.telemetry_destination.id": destinationID, "anthropic.organization.telemetry_destination.workspace.id": workspaceID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaDeletedTelemetryDestinationWorkspace.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationTelemetryDestinationsWorkspacesResource

    /// List the workspaces on a destination's workspace list, newest entry first.
    ///
    /// A destination whose `workspaces.type` is `all` doesn't have a list, so its page
    /// is empty. The list includes archived workspaces.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#choose-workspaces-for-a-destination)
    /// to learn more about choosing the workspaces of a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
    ///
    ///   limit: Number of entries to return per page, between 1 and 1,000. Defaults to 20.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`. Leave it out to get the
    ///       first page.
    ///
    ///   betas: This endpoint is in beta: requests must send `telemetry-destinations-2026-08-11`
    ///       in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(_ destinationID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaTelemetryDestinationWorkspace>> {
            try await resource._list(destinationID, limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Add one workspace to a destination's workspace list.
    ///
    /// Under `include` the workspace's spans start going to the destination. Under
    /// `exclude` they stop. A list holds at most 1,000 workspaces.
    ///
    /// Adding a workspace that is already on the list changes nothing and returns the
    /// existing entry. An archived workspace that isn't on the list yet can't be added.
    /// A destination whose `workspaces.type` is `all` doesn't have a list, so the API
    /// returns 400. To change which workspaces such a destination covers, update its
    /// `workspaces`.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#choose-workspaces-for-a-destination)
    /// to learn more about choosing the workspaces of a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
    ///
    ///   workspace_id: ID of the workspace to add (`wrkspc_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `telemetry-destinations-2026-08-11`
    ///       in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func add(_ workspaceID: String, destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaTelemetryDestinationWorkspace> {
            try await resource._add(workspaceID, destinationID: destinationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Remove one workspace from a destination's workspace list.
    ///
    /// Under `include` the workspace's spans stop going to the destination. Under
    /// `exclude` they start. An archived workspace can be removed too.
    ///
    /// The API returns 404 when the workspace isn't on the list. A destination whose
    /// `workspaces.type` is `all` doesn't have a list, so the API returns 400.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#choose-workspaces-for-a-destination)
    /// to learn more about choosing the workspaces of a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
    ///
    ///   workspace_id: ID of the workspace to remove (`wrkspc_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `telemetry-destinations-2026-08-11`
    ///       in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func remove(_ workspaceID: String, destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaDeletedTelemetryDestinationWorkspace> {
            try await resource._remove(workspaceID, destinationID: destinationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationTelemetryDestinationsWorkspacesResource

    /// List the workspaces on a destination's workspace list, newest entry first.
    ///
    /// A destination whose `workspaces.type` is `all` doesn't have a list, so its page
    /// is empty. The list includes archived workspaces.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#choose-workspaces-for-a-destination)
    /// to learn more about choosing the workspaces of a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
    ///
    ///   limit: Number of entries to return per page, between 1 and 1,000. Defaults to 20.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`. Leave it out to get the
    ///       first page.
    ///
    ///   betas: This endpoint is in beta: requests must send `telemetry-destinations-2026-08-11`
    ///       in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(_ destinationID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaTelemetryDestinationWorkspace>>) async throws -> R) async throws -> R {
            let response = try await resource._list(destinationID, limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Add one workspace to a destination's workspace list.
    ///
    /// Under `include` the workspace's spans start going to the destination. Under
    /// `exclude` they stop. A list holds at most 1,000 workspaces.
    ///
    /// Adding a workspace that is already on the list changes nothing and returns the
    /// existing entry. An archived workspace that isn't on the list yet can't be added.
    /// A destination whose `workspaces.type` is `all` doesn't have a list, so the API
    /// returns 400. To change which workspaces such a destination covers, update its
    /// `workspaces`.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#choose-workspaces-for-a-destination)
    /// to learn more about choosing the workspaces of a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
    ///
    ///   workspace_id: ID of the workspace to add (`wrkspc_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `telemetry-destinations-2026-08-11`
    ///       in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func add<R: Sendable>(_ workspaceID: String, destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaTelemetryDestinationWorkspace>) async throws -> R) async throws -> R {
            let response = try await resource._add(workspaceID, destinationID: destinationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Remove one workspace from a destination's workspace list.
    ///
    /// Under `include` the workspace's spans stop going to the destination. Under
    /// `exclude` they start. An archived workspace can be removed too.
    ///
    /// The API returns 404 when the workspace isn't on the list. A destination whose
    /// `workspaces.type` is `all` doesn't have a list, so the API returns 400.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#choose-workspaces-for-a-destination)
    /// to learn more about choosing the workspaces of a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
    ///
    ///   workspace_id: ID of the workspace to remove (`wrkspc_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `telemetry-destinations-2026-08-11`
    ///       in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func remove<R: Sendable>(_ workspaceID: String, destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaDeletedTelemetryDestinationWorkspace>) async throws -> R) async throws -> R {
            let response = try await resource._remove(workspaceID, destinationID: destinationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
