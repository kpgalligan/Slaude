// Transformed from `anthropic.resources.beta.organization.telemetry_destinations.telemetry_destinations` (telemetry_destinations.py).

import Foundation

public struct BetaOrganizationTelemetryDestinationsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var workspaces: BetaOrganizationTelemetryDestinationsWorkspacesResource { BetaOrganizationTelemetryDestinationsWorkspacesResource(client: client) }

    /// Register an OpenTelemetry destination for the organization.
    ///
    /// The destination starts in state `enabled`. An organization can have at most 10
    /// destinations, including disabled ones.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#add-a-destination)
    /// to learn more about adding a destination.
    ///
    /// Args:
    ///   endpoint_url: The base URL of your collector's OTLP/HTTP endpoint, for example
    ///       `https://gateway.example.com`.
    ///
    ///       The URL must use `https` and a hostname, not an IP address. The port, if given,
    ///       must be 443. The URL must not contain a query string, a fragment, or a username
    ///       and password. At most 2,048 characters.
    ///
    ///       A path prefix, such as `/otlp`, is allowed. Don't include the per-signal path
    ///       (`/v1/traces`), because the API appends it on delivery. If your collector takes
    ///       traces on another path, also set `traces.endpoint_url`.
    ///
    ///   workspaces: Which of the organization's workspaces the destination covers.
    ///
    ///   display_name: Human-readable name for the destination. Optional. 1 to 255 characters.
    ///
    ///   headers: Request headers that the API sends with every delivery, typically your
    ///       collector's authentication header (for example `authorization`).
    ///
    ///       The API stores the values encrypted and never returns them. Reads show only
    ///       `header_names`.
    ///
    ///       At most 20 headers. Names are at most 128 characters. Two names can't differ
    ///       only in case. Values are printable ASCII, at most 4,096 characters, and can't
    ///       begin or end with a space. Names and values together are at most 16,384 bytes.
    ///
    ///       Reserved names are rejected, for example `host`, `cookie`, `user-agent`, and
    ///       names that start with `content-`, `proxy-`, `x-forwarded-`, or `anthropic-`. For
    ///       this check, `_` in a name counts as `-`.
    ///
    ///   traces: The settings for the traces that the destination receives. If you leave it out,
    ///       every setting takes its default.
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
    public func create(endpointURL: String, workspaces: BetaTelemetryDestinationWorkspacesParams, displayName: String?? = nil, headers: [String: String]? = nil, traces: BetaTelemetryDestinationTracesParams? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaTelemetryDestination {
        try await _create(endpointURL: endpointURL, workspaces: workspaces, displayName: displayName, headers: headers, traces: traces, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(endpointURL: String, workspaces: BetaTelemetryDestinationWorkspacesParams, displayName: String?? = nil, headers: [String: String]? = nil, traces: BetaTelemetryDestinationTracesParams? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaTelemetryDestination> {
        var body = ParamsBuilder()
        try body.set("endpoint_url", endpointURL)
        try body.set("workspaces", workspaces)
        try body.set("display_name", displayName)
        try body.set("headers", headers)
        try body.set("traces", traces)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/telemetry_destinations", body: body, headers: mergeHeaderLayers(["anthropic-beta": "telemetry-destinations-2026-08-11"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["telemetry-destinations-2026-08-11"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.telemetry_destinations.create", spanRoute: "/v1/organizations/telemetry_destinations", spanCreatedID: SpanCreatedID("anthropic.organization.telemetry_destination.id"), qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaTelemetryDestination.self, options, stream: _mode == .stream)
    }

    /// Read a destination's configuration, state, and most recent delivery results.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#delivery-and-health)
    /// to learn how the API delivers spans and when it disables a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
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
    public func retrieve(_ destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaTelemetryDestination {
        try await _retrieve(destinationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaTelemetryDestination> {
        try requireNonEmpty(destinationID, "destination_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/telemetry_destinations/{destination_id}", ["destination_id": destinationID]), headers: mergeHeaderLayers(["anthropic-beta": "telemetry-destinations-2026-08-11"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["telemetry-destinations-2026-08-11"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.telemetry_destinations.retrieve", spanRoute: "/v1/organizations/telemetry_destinations/{destination_id}", spanAttributes: ["anthropic.organization.telemetry_destination.id": destinationID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaTelemetryDestination.self, options, stream: _mode == .stream)
    }

    /// Change a telemetry destination's settings, its state, or which workspaces it
    /// covers.
    ///
    /// Send at least one field. Omitted fields keep their stored values, except the
    /// registered headers, which a change of the endpoint's hostname or port removes.
    /// Only `display_name`, `traces`, `traces.endpoint_url`, `traces.content_mode`,
    /// `traces.max_content_bytes`, and individual `headers` values accept `null`.
    ///
    /// If another request changes the destination while the update runs, the API
    /// returns a 409 `conflict_error`. Read the destination again, then retry the
    /// update.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#delivery-and-health)
    /// to learn more about changing a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
    ///
    ///   display_name: New human-readable name, 1 to 255 characters. Null clears it.
    ///
    ///   endpoint_url: The new base URL of the destination's OTLP/HTTP endpoint. The same rules as on
    ///       create apply.
    ///
    ///       A change of hostname or port first removes every registered header, so send the
    ///       headers for the new endpoint in the same request. When the destination has a
    ///       `traces.endpoint_url`, such a change must also set `traces.endpoint_url` to a
    ///       URL with the new hostname and port, or to `null`. A change of the path alone
    ///       keeps the headers.
    ///
    ///   headers: Headers to set or remove. The API merges them into the destination's headers by
    ///       name.
    ///
    ///       Names compare case-insensitively. A string value sets or replaces that header. A
    ///       `null` value removes it. Headers that you omit don't change. The field itself
    ///       can't be `null`.
    ///
    ///       A request that sets a header value must also include `endpoint_url`. The current
    ///       URL is accepted.
    ///
    ///       The resulting set must stay within the same limits as on create. When the
    ///       request sets a value, each stored value that it doesn't set counts as 4,096
    ///       bytes toward the 16,384-byte limit, because you can't read its real length. So
    ///       to change one header of a destination that has four or more other headers, send
    ///       the values of the others again in the same request.
    ///
    ///   state: Whether the destination receives deliveries after the update. The field can't be
    ///       `null`.
    ///
    ///   traces: The traces settings to change. Omitted settings keep their stored values.
    ///
    ///       `null` sets every traces setting to its create default.
    ///
    ///   workspaces: The new workspace scope, in the same form as on create. The field can't be
    ///       `null`.
    ///
    ///       The API refuses an update that changes the type or sends `workspace_ids` while
    ///       the destination's list has more than 750 workspaces. Remove workspaces one at a
    ///       time until 750 or fewer remain, then send the update again.
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
    public func update(_ destinationID: String, displayName: String?? = nil, endpointURL: String? = nil, headers: [String: String?]?? = nil, state: BetaTelemetryDestinationStateParams? = nil, traces: BetaTelemetryDestinationTracesParams?? = nil, workspaces: BetaTelemetryDestinationWorkspacesParams? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaTelemetryDestination {
        try await _update(destinationID, displayName: displayName, endpointURL: endpointURL, headers: headers, state: state, traces: traces, workspaces: workspaces, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ destinationID: String, displayName: String?? = nil, endpointURL: String? = nil, headers: [String: String?]?? = nil, state: BetaTelemetryDestinationStateParams? = nil, traces: BetaTelemetryDestinationTracesParams?? = nil, workspaces: BetaTelemetryDestinationWorkspacesParams? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaTelemetryDestination> {
        try requireNonEmpty(destinationID, "destination_id")
        var body = ParamsBuilder()
        try body.set("display_name", displayName)
        try body.set("endpoint_url", endpointURL)
        try body.set("headers", headers)
        try body.set("state", state)
        try body.set("traces", traces)
        try body.set("workspaces", workspaces)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/telemetry_destinations/{destination_id}", ["destination_id": destinationID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "telemetry-destinations-2026-08-11"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["telemetry-destinations-2026-08-11"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.telemetry_destinations.update", spanRoute: "/v1/organizations/telemetry_destinations/{destination_id}", spanAttributes: ["anthropic.organization.telemetry_destination.id": destinationID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaTelemetryDestination.self, options, stream: _mode == .stream)
    }

    /// List the organization's destinations, newest first, optionally only those that
    /// cover given workspaces.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#set-up-api-tracing)
    /// to learn more about destinations.
    ///
    /// Args:
    ///   limit: Number of destinations to return per page, between 1 and 1,000. Defaults to 20.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`. Leave it out to get the
    ///       first page.
    ///
    ///   workspace_ids: Return only the destinations that cover at least one of these workspaces
    ///       (`wrkspc_...`).
    ///
    ///       Send at most 100 IDs, as `workspace_ids[]`. A destination covers a workspace
    ///       when its `workspaces.type` is `all`, when its `include` list has the workspace,
    ///       or when its `exclude` list doesn't have it. Destinations in either state can
    ///       match. An ID that isn't the ID of one of the organization's workspaces doesn't
    ///       match any destination, not even one whose type is `all`.
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
    public func list(limit: Int? = nil, page: String? = nil, workspaceIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaTelemetryDestination> {
        try await _list(limit: limit, page: page, workspaceIDs: workspaceIDs, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(limit: Int? = nil, page: String? = nil, workspaceIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaTelemetryDestination>> {
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        try query.set("workspace_ids", workspaceIDs)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/telemetry_destinations", query: query, headers: mergeHeaderLayers(["anthropic-beta": "telemetry-destinations-2026-08-11"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["telemetry-destinations-2026-08-11"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.telemetry_destinations.list", spanRoute: "/v1/organizations/telemetry_destinations", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaTelemetryDestination>.self, options, stream: _mode == .stream)
    }

    /// Delete a destination and its workspace list.
    ///
    /// The API stops sending spans to the destination. The spans of the workspaces it
    /// covered still go to the other destinations that cover them. A deleted
    /// destination can't be read, listed, or restored.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#delivery-and-health)
    /// to learn more about managing a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
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
    public func delete(_ destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaDeletedTelemetryDestination {
        try await _delete(destinationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaDeletedTelemetryDestination> {
        try requireNonEmpty(destinationID, "destination_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/telemetry_destinations/{destination_id}", ["destination_id": destinationID]), headers: mergeHeaderLayers(["anthropic-beta": "telemetry-destinations-2026-08-11"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["telemetry-destinations-2026-08-11"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.telemetry_destinations.delete", spanRoute: "/v1/organizations/telemetry_destinations/{destination_id}", spanAttributes: ["anthropic.organization.telemetry_destination.id": destinationID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaDeletedTelemetryDestination.self, options, stream: _mode == .stream)
    }

    /// Send one test span, named `anthropic.test`, to the destination with its
    /// registered headers, once and without retries, and report the destination's
    /// answer. The response is 200 whether or not the destination answered with a 2xx
    /// status: its `result` has the type `success`, or the type `failure` and the
    /// reason in `error`. The destination's configuration, `state` and
    /// `delivery_health` do not change. A disabled destination can be tested too. Wait
    /// 10 seconds between tests of one destination; a request that comes sooner may be
    /// answered with status 429.
    ///
    /// Args:
    ///   destination_id: ID of the destination to test (starts with `tdst_`).
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
    public func test(_ destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaTelemetryDestinationTestResponse {
        try await _test(destinationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _test(_ destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaTelemetryDestinationTestResponse> {
        try requireNonEmpty(destinationID, "destination_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/telemetry_destinations/{destination_id}/test", ["destination_id": destinationID]), headers: mergeHeaderLayers(["anthropic-beta": "telemetry-destinations-2026-08-11"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["telemetry-destinations-2026-08-11"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.telemetry_destinations.test", spanRoute: "/v1/organizations/telemetry_destinations/{destination_id}/test", spanAttributes: ["anthropic.organization.telemetry_destination.id": destinationID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaTelemetryDestinationTestResponse.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationTelemetryDestinationsResource

        public var workspaces: BetaOrganizationTelemetryDestinationsWorkspacesResource.WithRawResponse { resource.workspaces.withRawResponse }

    /// Register an OpenTelemetry destination for the organization.
    ///
    /// The destination starts in state `enabled`. An organization can have at most 10
    /// destinations, including disabled ones.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#add-a-destination)
    /// to learn more about adding a destination.
    ///
    /// Args:
    ///   endpoint_url: The base URL of your collector's OTLP/HTTP endpoint, for example
    ///       `https://gateway.example.com`.
    ///
    ///       The URL must use `https` and a hostname, not an IP address. The port, if given,
    ///       must be 443. The URL must not contain a query string, a fragment, or a username
    ///       and password. At most 2,048 characters.
    ///
    ///       A path prefix, such as `/otlp`, is allowed. Don't include the per-signal path
    ///       (`/v1/traces`), because the API appends it on delivery. If your collector takes
    ///       traces on another path, also set `traces.endpoint_url`.
    ///
    ///   workspaces: Which of the organization's workspaces the destination covers.
    ///
    ///   display_name: Human-readable name for the destination. Optional. 1 to 255 characters.
    ///
    ///   headers: Request headers that the API sends with every delivery, typically your
    ///       collector's authentication header (for example `authorization`).
    ///
    ///       The API stores the values encrypted and never returns them. Reads show only
    ///       `header_names`.
    ///
    ///       At most 20 headers. Names are at most 128 characters. Two names can't differ
    ///       only in case. Values are printable ASCII, at most 4,096 characters, and can't
    ///       begin or end with a space. Names and values together are at most 16,384 bytes.
    ///
    ///       Reserved names are rejected, for example `host`, `cookie`, `user-agent`, and
    ///       names that start with `content-`, `proxy-`, `x-forwarded-`, or `anthropic-`. For
    ///       this check, `_` in a name counts as `-`.
    ///
    ///   traces: The settings for the traces that the destination receives. If you leave it out,
    ///       every setting takes its default.
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
        public func create(endpointURL: String, workspaces: BetaTelemetryDestinationWorkspacesParams, displayName: String?? = nil, headers: [String: String]? = nil, traces: BetaTelemetryDestinationTracesParams? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaTelemetryDestination> {
            try await resource._create(endpointURL: endpointURL, workspaces: workspaces, displayName: displayName, headers: headers, traces: traces, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Read a destination's configuration, state, and most recent delivery results.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#delivery-and-health)
    /// to learn how the API delivers spans and when it disables a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
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
        public func retrieve(_ destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaTelemetryDestination> {
            try await resource._retrieve(destinationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Change a telemetry destination's settings, its state, or which workspaces it
    /// covers.
    ///
    /// Send at least one field. Omitted fields keep their stored values, except the
    /// registered headers, which a change of the endpoint's hostname or port removes.
    /// Only `display_name`, `traces`, `traces.endpoint_url`, `traces.content_mode`,
    /// `traces.max_content_bytes`, and individual `headers` values accept `null`.
    ///
    /// If another request changes the destination while the update runs, the API
    /// returns a 409 `conflict_error`. Read the destination again, then retry the
    /// update.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#delivery-and-health)
    /// to learn more about changing a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
    ///
    ///   display_name: New human-readable name, 1 to 255 characters. Null clears it.
    ///
    ///   endpoint_url: The new base URL of the destination's OTLP/HTTP endpoint. The same rules as on
    ///       create apply.
    ///
    ///       A change of hostname or port first removes every registered header, so send the
    ///       headers for the new endpoint in the same request. When the destination has a
    ///       `traces.endpoint_url`, such a change must also set `traces.endpoint_url` to a
    ///       URL with the new hostname and port, or to `null`. A change of the path alone
    ///       keeps the headers.
    ///
    ///   headers: Headers to set or remove. The API merges them into the destination's headers by
    ///       name.
    ///
    ///       Names compare case-insensitively. A string value sets or replaces that header. A
    ///       `null` value removes it. Headers that you omit don't change. The field itself
    ///       can't be `null`.
    ///
    ///       A request that sets a header value must also include `endpoint_url`. The current
    ///       URL is accepted.
    ///
    ///       The resulting set must stay within the same limits as on create. When the
    ///       request sets a value, each stored value that it doesn't set counts as 4,096
    ///       bytes toward the 16,384-byte limit, because you can't read its real length. So
    ///       to change one header of a destination that has four or more other headers, send
    ///       the values of the others again in the same request.
    ///
    ///   state: Whether the destination receives deliveries after the update. The field can't be
    ///       `null`.
    ///
    ///   traces: The traces settings to change. Omitted settings keep their stored values.
    ///
    ///       `null` sets every traces setting to its create default.
    ///
    ///   workspaces: The new workspace scope, in the same form as on create. The field can't be
    ///       `null`.
    ///
    ///       The API refuses an update that changes the type or sends `workspace_ids` while
    ///       the destination's list has more than 750 workspaces. Remove workspaces one at a
    ///       time until 750 or fewer remain, then send the update again.
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
        public func update(_ destinationID: String, displayName: String?? = nil, endpointURL: String? = nil, headers: [String: String?]?? = nil, state: BetaTelemetryDestinationStateParams? = nil, traces: BetaTelemetryDestinationTracesParams?? = nil, workspaces: BetaTelemetryDestinationWorkspacesParams? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaTelemetryDestination> {
            try await resource._update(destinationID, displayName: displayName, endpointURL: endpointURL, headers: headers, state: state, traces: traces, workspaces: workspaces, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List the organization's destinations, newest first, optionally only those that
    /// cover given workspaces.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#set-up-api-tracing)
    /// to learn more about destinations.
    ///
    /// Args:
    ///   limit: Number of destinations to return per page, between 1 and 1,000. Defaults to 20.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`. Leave it out to get the
    ///       first page.
    ///
    ///   workspace_ids: Return only the destinations that cover at least one of these workspaces
    ///       (`wrkspc_...`).
    ///
    ///       Send at most 100 IDs, as `workspace_ids[]`. A destination covers a workspace
    ///       when its `workspaces.type` is `all`, when its `include` list has the workspace,
    ///       or when its `exclude` list doesn't have it. Destinations in either state can
    ///       match. An ID that isn't the ID of one of the organization's workspaces doesn't
    ///       match any destination, not even one whose type is `all`.
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
        public func list(limit: Int? = nil, page: String? = nil, workspaceIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaTelemetryDestination>> {
            try await resource._list(limit: limit, page: page, workspaceIDs: workspaceIDs, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete a destination and its workspace list.
    ///
    /// The API stops sending spans to the destination. The spans of the workspaces it
    /// covered still go to the other destinations that cover them. A deleted
    /// destination can't be read, listed, or restored.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#delivery-and-health)
    /// to learn more about managing a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
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
        public func delete(_ destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaDeletedTelemetryDestination> {
            try await resource._delete(destinationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Send one test span, named `anthropic.test`, to the destination with its
    /// registered headers, once and without retries, and report the destination's
    /// answer. The response is 200 whether or not the destination answered with a 2xx
    /// status: its `result` has the type `success`, or the type `failure` and the
    /// reason in `error`. The destination's configuration, `state` and
    /// `delivery_health` do not change. A disabled destination can be tested too. Wait
    /// 10 seconds between tests of one destination; a request that comes sooner may be
    /// answered with status 429.
    ///
    /// Args:
    ///   destination_id: ID of the destination to test (starts with `tdst_`).
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
        public func test(_ destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaTelemetryDestinationTestResponse> {
            try await resource._test(destinationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationTelemetryDestinationsResource

        public var workspaces: BetaOrganizationTelemetryDestinationsWorkspacesResource.WithStreamingResponse { resource.workspaces.withStreamingResponse }

    /// Register an OpenTelemetry destination for the organization.
    ///
    /// The destination starts in state `enabled`. An organization can have at most 10
    /// destinations, including disabled ones.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#add-a-destination)
    /// to learn more about adding a destination.
    ///
    /// Args:
    ///   endpoint_url: The base URL of your collector's OTLP/HTTP endpoint, for example
    ///       `https://gateway.example.com`.
    ///
    ///       The URL must use `https` and a hostname, not an IP address. The port, if given,
    ///       must be 443. The URL must not contain a query string, a fragment, or a username
    ///       and password. At most 2,048 characters.
    ///
    ///       A path prefix, such as `/otlp`, is allowed. Don't include the per-signal path
    ///       (`/v1/traces`), because the API appends it on delivery. If your collector takes
    ///       traces on another path, also set `traces.endpoint_url`.
    ///
    ///   workspaces: Which of the organization's workspaces the destination covers.
    ///
    ///   display_name: Human-readable name for the destination. Optional. 1 to 255 characters.
    ///
    ///   headers: Request headers that the API sends with every delivery, typically your
    ///       collector's authentication header (for example `authorization`).
    ///
    ///       The API stores the values encrypted and never returns them. Reads show only
    ///       `header_names`.
    ///
    ///       At most 20 headers. Names are at most 128 characters. Two names can't differ
    ///       only in case. Values are printable ASCII, at most 4,096 characters, and can't
    ///       begin or end with a space. Names and values together are at most 16,384 bytes.
    ///
    ///       Reserved names are rejected, for example `host`, `cookie`, `user-agent`, and
    ///       names that start with `content-`, `proxy-`, `x-forwarded-`, or `anthropic-`. For
    ///       this check, `_` in a name counts as `-`.
    ///
    ///   traces: The settings for the traces that the destination receives. If you leave it out,
    ///       every setting takes its default.
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
        public func create<R: Sendable>(endpointURL: String, workspaces: BetaTelemetryDestinationWorkspacesParams, displayName: String?? = nil, headers: [String: String]? = nil, traces: BetaTelemetryDestinationTracesParams? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaTelemetryDestination>) async throws -> R) async throws -> R {
            let response = try await resource._create(endpointURL: endpointURL, workspaces: workspaces, displayName: displayName, headers: headers, traces: traces, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Read a destination's configuration, state, and most recent delivery results.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#delivery-and-health)
    /// to learn how the API delivers spans and when it disables a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
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
        public func retrieve<R: Sendable>(_ destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaTelemetryDestination>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(destinationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Change a telemetry destination's settings, its state, or which workspaces it
    /// covers.
    ///
    /// Send at least one field. Omitted fields keep their stored values, except the
    /// registered headers, which a change of the endpoint's hostname or port removes.
    /// Only `display_name`, `traces`, `traces.endpoint_url`, `traces.content_mode`,
    /// `traces.max_content_bytes`, and individual `headers` values accept `null`.
    ///
    /// If another request changes the destination while the update runs, the API
    /// returns a 409 `conflict_error`. Read the destination again, then retry the
    /// update.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#delivery-and-health)
    /// to learn more about changing a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
    ///
    ///   display_name: New human-readable name, 1 to 255 characters. Null clears it.
    ///
    ///   endpoint_url: The new base URL of the destination's OTLP/HTTP endpoint. The same rules as on
    ///       create apply.
    ///
    ///       A change of hostname or port first removes every registered header, so send the
    ///       headers for the new endpoint in the same request. When the destination has a
    ///       `traces.endpoint_url`, such a change must also set `traces.endpoint_url` to a
    ///       URL with the new hostname and port, or to `null`. A change of the path alone
    ///       keeps the headers.
    ///
    ///   headers: Headers to set or remove. The API merges them into the destination's headers by
    ///       name.
    ///
    ///       Names compare case-insensitively. A string value sets or replaces that header. A
    ///       `null` value removes it. Headers that you omit don't change. The field itself
    ///       can't be `null`.
    ///
    ///       A request that sets a header value must also include `endpoint_url`. The current
    ///       URL is accepted.
    ///
    ///       The resulting set must stay within the same limits as on create. When the
    ///       request sets a value, each stored value that it doesn't set counts as 4,096
    ///       bytes toward the 16,384-byte limit, because you can't read its real length. So
    ///       to change one header of a destination that has four or more other headers, send
    ///       the values of the others again in the same request.
    ///
    ///   state: Whether the destination receives deliveries after the update. The field can't be
    ///       `null`.
    ///
    ///   traces: The traces settings to change. Omitted settings keep their stored values.
    ///
    ///       `null` sets every traces setting to its create default.
    ///
    ///   workspaces: The new workspace scope, in the same form as on create. The field can't be
    ///       `null`.
    ///
    ///       The API refuses an update that changes the type or sends `workspace_ids` while
    ///       the destination's list has more than 750 workspaces. Remove workspaces one at a
    ///       time until 750 or fewer remain, then send the update again.
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
        public func update<R: Sendable>(_ destinationID: String, displayName: String?? = nil, endpointURL: String? = nil, headers: [String: String?]?? = nil, state: BetaTelemetryDestinationStateParams? = nil, traces: BetaTelemetryDestinationTracesParams?? = nil, workspaces: BetaTelemetryDestinationWorkspacesParams? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaTelemetryDestination>) async throws -> R) async throws -> R {
            let response = try await resource._update(destinationID, displayName: displayName, endpointURL: endpointURL, headers: headers, state: state, traces: traces, workspaces: workspaces, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List the organization's destinations, newest first, optionally only those that
    /// cover given workspaces.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#set-up-api-tracing)
    /// to learn more about destinations.
    ///
    /// Args:
    ///   limit: Number of destinations to return per page, between 1 and 1,000. Defaults to 20.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`. Leave it out to get the
    ///       first page.
    ///
    ///   workspace_ids: Return only the destinations that cover at least one of these workspaces
    ///       (`wrkspc_...`).
    ///
    ///       Send at most 100 IDs, as `workspace_ids[]`. A destination covers a workspace
    ///       when its `workspaces.type` is `all`, when its `include` list has the workspace,
    ///       or when its `exclude` list doesn't have it. Destinations in either state can
    ///       match. An ID that isn't the ID of one of the organization's workspaces doesn't
    ///       match any destination, not even one whose type is `all`.
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
        public func list<R: Sendable>(limit: Int? = nil, page: String? = nil, workspaceIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaTelemetryDestination>>) async throws -> R) async throws -> R {
            let response = try await resource._list(limit: limit, page: page, workspaceIDs: workspaceIDs, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete a destination and its workspace list.
    ///
    /// The API stops sending spans to the destination. The spans of the workspaces it
    /// covered still go to the other destinations that cover them. A deleted
    /// destination can't be read, listed, or restored.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#delivery-and-health)
    /// to learn more about managing a destination.
    ///
    /// Args:
    ///   destination_id: ID of the destination (`tdst_...`).
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
        public func delete<R: Sendable>(_ destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaDeletedTelemetryDestination>) async throws -> R) async throws -> R {
            let response = try await resource._delete(destinationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Send one test span, named `anthropic.test`, to the destination with its
    /// registered headers, once and without retries, and report the destination's
    /// answer. The response is 200 whether or not the destination answered with a 2xx
    /// status: its `result` has the type `success`, or the type `failure` and the
    /// reason in `error`. The destination's configuration, `state` and
    /// `delivery_health` do not change. A disabled destination can be tested too. Wait
    /// 10 seconds between tests of one destination; a request that comes sooner may be
    /// answered with status 429.
    ///
    /// Args:
    ///   destination_id: ID of the destination to test (starts with `tdst_`).
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
        public func test<R: Sendable>(_ destinationID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaTelemetryDestinationTestResponse>) async throws -> R) async throws -> R {
            let response = try await resource._test(destinationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
