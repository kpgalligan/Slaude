// Transformed from `anthropic.resources.beta.organization.webhooks` (webhooks.py).

import Foundation

public struct BetaOrganizationWebhooksResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Create an organization webhook endpoint.
    ///
    /// An organization webhook endpoint belongs to the organization rather than to one
    /// of its workspaces. An organization can have at most 32 organization webhook
    /// endpoints, enabled or disabled.
    ///
    /// The response includes the endpoint's signing secret. No read returns it, so
    /// store it when you receive it.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   enabled_events: The event types to deliver to the endpoint. Must list at least one.
    ///
    ///   url: The HTTPS URL that deliveries are sent to.
    ///
    ///   description: Notes about the endpoint.
    ///
    ///   name: A short label for the endpoint.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func create(enabledEvents: [WebhookCreateParams.EnabledEvents], url: String, description: String? = nil, name: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaNewOrganizationWebhookEndpoint {
        try await _create(enabledEvents: enabledEvents, url: url, description: description, name: name, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(enabledEvents: [WebhookCreateParams.EnabledEvents], url: String, description: String? = nil, name: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaNewOrganizationWebhookEndpoint> {
        var body = ParamsBuilder()
        try body.set("enabled_events", enabledEvents)
        try body.set("url", url)
        try body.set("description", description)
        try body.set("name", name)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/webhooks", body: body, headers: mergeHeaderLayers(["anthropic-beta": "webhooks-2026-10-07"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["webhooks-2026-10-07"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.webhooks.create", spanRoute: "/v1/organizations/webhooks", spanCreatedID: SpanCreatedID("anthropic.organization.webhook.id"), qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaNewOrganizationWebhookEndpoint.self, options, stream: _mode == .stream)
    }

    /// Retrieve an organization webhook endpoint by ID.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   webhook_endpoint_id: ID of the webhook endpoint.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ webhookEndpointID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaOrganizationWebhookEndpoint {
        try await _retrieve(webhookEndpointID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ webhookEndpointID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaOrganizationWebhookEndpoint> {
        try requireNonEmpty(webhookEndpointID, "webhook_endpoint_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/webhooks/{webhook_endpoint_id}", ["webhook_endpoint_id": webhookEndpointID]), headers: mergeHeaderLayers(["anthropic-beta": "webhooks-2026-10-07"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["webhooks-2026-10-07"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.webhooks.retrieve", spanRoute: "/v1/organizations/webhooks/{webhook_endpoint_id}", spanAttributes: ["anthropic.organization.webhook.id": webhookEndpointID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaOrganizationWebhookEndpoint.self, options, stream: _mode == .stream)
    }

    /// Update an organization webhook endpoint.
    ///
    /// Only the fields you send are changed.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   webhook_endpoint_id: ID of the webhook endpoint.
    ///
    ///   description: Notes about the endpoint.
    ///
    ///   enabled_events: The event types to deliver to the endpoint. Replaces the whole set; an empty
    ///       list leaves it unchanged.
    ///
    ///   name: A short label for the endpoint.
    ///
    ///   state: `disabled` stops deliveries. `enabled` resumes them and clears
    ///       `disabled_reason`. Events that happen while the endpoint is disabled are never
    ///       delivered.
    ///
    ///   url: The HTTPS URL that deliveries are sent to.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func update(_ webhookEndpointID: String, description: String? = nil, enabledEvents: [WebhookUpdateParams.EnabledEvents]? = nil, name: String? = nil, state: WebhookUpdateParams.State? = nil, url: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaOrganizationWebhookEndpoint {
        try await _update(webhookEndpointID, description: description, enabledEvents: enabledEvents, name: name, state: state, url: url, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ webhookEndpointID: String, description: String? = nil, enabledEvents: [WebhookUpdateParams.EnabledEvents]? = nil, name: String? = nil, state: WebhookUpdateParams.State? = nil, url: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaOrganizationWebhookEndpoint> {
        try requireNonEmpty(webhookEndpointID, "webhook_endpoint_id")
        var body = ParamsBuilder()
        try body.set("description", description)
        try body.set("enabled_events", enabledEvents)
        try body.set("name", name)
        try body.set("state", state)
        try body.set("url", url)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/webhooks/{webhook_endpoint_id}", ["webhook_endpoint_id": webhookEndpointID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "webhooks-2026-10-07"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["webhooks-2026-10-07"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.webhooks.update", spanRoute: "/v1/organizations/webhooks/{webhook_endpoint_id}", spanAttributes: ["anthropic.organization.webhook.id": webhookEndpointID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaOrganizationWebhookEndpoint.self, options, stream: _mode == .stream)
    }

    /// List the organization's webhook endpoints.
    ///
    /// An organization webhook endpoint belongs to the organization rather than to one
    /// of its workspaces. The list does not include webhook endpoints that belong to a
    /// workspace.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of a webhook endpoint to use as a cursor. Returns the first `limit` endpoints
    ///       that come before it in list order, not the `limit` endpoints just before it.
    ///
    ///   limit: Number of items to return per page, up to `100`. The default, `0`, means `20`.
    ///
    ///   order: Sort order by `created_at`. Defaults to `desc`, newest first.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(afterID: String?? = nil, beforeID: String?? = nil, limit: Int? = nil, order: WebhookListParams.Order?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Page<BetaOrganizationWebhookEndpoint> {
        try await _list(afterID: afterID, beforeID: beforeID, limit: limit, order: order, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(afterID: String?? = nil, beforeID: String?? = nil, limit: Int? = nil, order: WebhookListParams.Order?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Page<BetaOrganizationWebhookEndpoint>> {
        var query = ParamsBuilder()
        try query.set("after_id", afterID)
        try query.set("before_id", beforeID)
        try query.set("limit", limit)
        try query.set("order", order)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/webhooks", query: query, headers: mergeHeaderLayers(["anthropic-beta": "webhooks-2026-10-07"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["webhooks-2026-10-07"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.webhooks.list", spanRoute: "/v1/organizations/webhooks", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(Page<BetaOrganizationWebhookEndpoint>.self, options, stream: _mode == .stream)
    }

    /// Delete an organization webhook endpoint.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   webhook_endpoint_id: ID of the webhook endpoint.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func delete(_ webhookEndpointID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaDeletedOrganizationWebhookEndpoint {
        try await _delete(webhookEndpointID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ webhookEndpointID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaDeletedOrganizationWebhookEndpoint> {
        try requireNonEmpty(webhookEndpointID, "webhook_endpoint_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/webhooks/{webhook_endpoint_id}", ["webhook_endpoint_id": webhookEndpointID]), headers: mergeHeaderLayers(["anthropic-beta": "webhooks-2026-10-07"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["webhooks-2026-10-07"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.webhooks.delete", spanRoute: "/v1/organizations/webhooks/{webhook_endpoint_id}", spanAttributes: ["anthropic.organization.webhook.id": webhookEndpointID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaDeletedOrganizationWebhookEndpoint.self, options, stream: _mode == .stream)
    }

    /// Replace an organization webhook endpoint's signing secret.
    ///
    /// The old secret stops
    /// working immediately. The new secret is returned only in this response.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   webhook_endpoint_id: ID of the webhook endpoint.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func regenerateSigningSecret(_ webhookEndpointID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaOrganizationWebhookEndpointSigningSecret {
        try await _regenerateSigningSecret(webhookEndpointID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _regenerateSigningSecret(_ webhookEndpointID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaOrganizationWebhookEndpointSigningSecret> {
        try requireNonEmpty(webhookEndpointID, "webhook_endpoint_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/webhooks/{webhook_endpoint_id}/regenerate_signing_secret", ["webhook_endpoint_id": webhookEndpointID]), headers: mergeHeaderLayers(["anthropic-beta": "webhooks-2026-10-07"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["webhooks-2026-10-07"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.webhooks.regenerate_signing_secret", spanRoute: "/v1/organizations/webhooks/{webhook_endpoint_id}/regenerate_signing_secret", spanAttributes: ["anthropic.organization.webhook.id": webhookEndpointID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaOrganizationWebhookEndpointSigningSecret.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationWebhooksResource

    /// Create an organization webhook endpoint.
    ///
    /// An organization webhook endpoint belongs to the organization rather than to one
    /// of its workspaces. An organization can have at most 32 organization webhook
    /// endpoints, enabled or disabled.
    ///
    /// The response includes the endpoint's signing secret. No read returns it, so
    /// store it when you receive it.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   enabled_events: The event types to deliver to the endpoint. Must list at least one.
    ///
    ///   url: The HTTPS URL that deliveries are sent to.
    ///
    ///   description: Notes about the endpoint.
    ///
    ///   name: A short label for the endpoint.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create(enabledEvents: [WebhookCreateParams.EnabledEvents], url: String, description: String? = nil, name: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaNewOrganizationWebhookEndpoint> {
            try await resource._create(enabledEvents: enabledEvents, url: url, description: description, name: name, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Retrieve an organization webhook endpoint by ID.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   webhook_endpoint_id: ID of the webhook endpoint.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ webhookEndpointID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaOrganizationWebhookEndpoint> {
            try await resource._retrieve(webhookEndpointID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update an organization webhook endpoint.
    ///
    /// Only the fields you send are changed.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   webhook_endpoint_id: ID of the webhook endpoint.
    ///
    ///   description: Notes about the endpoint.
    ///
    ///   enabled_events: The event types to deliver to the endpoint. Replaces the whole set; an empty
    ///       list leaves it unchanged.
    ///
    ///   name: A short label for the endpoint.
    ///
    ///   state: `disabled` stops deliveries. `enabled` resumes them and clears
    ///       `disabled_reason`. Events that happen while the endpoint is disabled are never
    ///       delivered.
    ///
    ///   url: The HTTPS URL that deliveries are sent to.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update(_ webhookEndpointID: String, description: String? = nil, enabledEvents: [WebhookUpdateParams.EnabledEvents]? = nil, name: String? = nil, state: WebhookUpdateParams.State? = nil, url: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaOrganizationWebhookEndpoint> {
            try await resource._update(webhookEndpointID, description: description, enabledEvents: enabledEvents, name: name, state: state, url: url, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List the organization's webhook endpoints.
    ///
    /// An organization webhook endpoint belongs to the organization rather than to one
    /// of its workspaces. The list does not include webhook endpoints that belong to a
    /// workspace.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of a webhook endpoint to use as a cursor. Returns the first `limit` endpoints
    ///       that come before it in list order, not the `limit` endpoints just before it.
    ///
    ///   limit: Number of items to return per page, up to `100`. The default, `0`, means `20`.
    ///
    ///   order: Sort order by `created_at`. Defaults to `desc`, newest first.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(afterID: String?? = nil, beforeID: String?? = nil, limit: Int? = nil, order: WebhookListParams.Order?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Page<BetaOrganizationWebhookEndpoint>> {
            try await resource._list(afterID: afterID, beforeID: beforeID, limit: limit, order: order, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete an organization webhook endpoint.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   webhook_endpoint_id: ID of the webhook endpoint.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func delete(_ webhookEndpointID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaDeletedOrganizationWebhookEndpoint> {
            try await resource._delete(webhookEndpointID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Replace an organization webhook endpoint's signing secret.
    ///
    /// The old secret stops
    /// working immediately. The new secret is returned only in this response.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   webhook_endpoint_id: ID of the webhook endpoint.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func regenerateSigningSecret(_ webhookEndpointID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaOrganizationWebhookEndpointSigningSecret> {
            try await resource._regenerateSigningSecret(webhookEndpointID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationWebhooksResource

    /// Create an organization webhook endpoint.
    ///
    /// An organization webhook endpoint belongs to the organization rather than to one
    /// of its workspaces. An organization can have at most 32 organization webhook
    /// endpoints, enabled or disabled.
    ///
    /// The response includes the endpoint's signing secret. No read returns it, so
    /// store it when you receive it.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   enabled_events: The event types to deliver to the endpoint. Must list at least one.
    ///
    ///   url: The HTTPS URL that deliveries are sent to.
    ///
    ///   description: Notes about the endpoint.
    ///
    ///   name: A short label for the endpoint.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create<R: Sendable>(enabledEvents: [WebhookCreateParams.EnabledEvents], url: String, description: String? = nil, name: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaNewOrganizationWebhookEndpoint>) async throws -> R) async throws -> R {
            let response = try await resource._create(enabledEvents: enabledEvents, url: url, description: description, name: name, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Retrieve an organization webhook endpoint by ID.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   webhook_endpoint_id: ID of the webhook endpoint.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ webhookEndpointID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaOrganizationWebhookEndpoint>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(webhookEndpointID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Update an organization webhook endpoint.
    ///
    /// Only the fields you send are changed.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   webhook_endpoint_id: ID of the webhook endpoint.
    ///
    ///   description: Notes about the endpoint.
    ///
    ///   enabled_events: The event types to deliver to the endpoint. Replaces the whole set; an empty
    ///       list leaves it unchanged.
    ///
    ///   name: A short label for the endpoint.
    ///
    ///   state: `disabled` stops deliveries. `enabled` resumes them and clears
    ///       `disabled_reason`. Events that happen while the endpoint is disabled are never
    ///       delivered.
    ///
    ///   url: The HTTPS URL that deliveries are sent to.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update<R: Sendable>(_ webhookEndpointID: String, description: String? = nil, enabledEvents: [WebhookUpdateParams.EnabledEvents]? = nil, name: String? = nil, state: WebhookUpdateParams.State? = nil, url: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaOrganizationWebhookEndpoint>) async throws -> R) async throws -> R {
            let response = try await resource._update(webhookEndpointID, description: description, enabledEvents: enabledEvents, name: name, state: state, url: url, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List the organization's webhook endpoints.
    ///
    /// An organization webhook endpoint belongs to the organization rather than to one
    /// of its workspaces. The list does not include webhook endpoints that belong to a
    /// workspace.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of a webhook endpoint to use as a cursor. Returns the first `limit` endpoints
    ///       that come before it in list order, not the `limit` endpoints just before it.
    ///
    ///   limit: Number of items to return per page, up to `100`. The default, `0`, means `20`.
    ///
    ///   order: Sort order by `created_at`. Defaults to `desc`, newest first.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(afterID: String?? = nil, beforeID: String?? = nil, limit: Int? = nil, order: WebhookListParams.Order?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Page<BetaOrganizationWebhookEndpoint>>) async throws -> R) async throws -> R {
            let response = try await resource._list(afterID: afterID, beforeID: beforeID, limit: limit, order: order, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete an organization webhook endpoint.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   webhook_endpoint_id: ID of the webhook endpoint.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func delete<R: Sendable>(_ webhookEndpointID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaDeletedOrganizationWebhookEndpoint>) async throws -> R) async throws -> R {
            let response = try await resource._delete(webhookEndpointID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Replace an organization webhook endpoint's signing secret.
    ///
    /// The old secret stops
    /// working immediately. The new secret is returned only in this response.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: webhooks-2026-10-07`. A request without it returns `404`,
    /// exactly as if this API did not exist. Anthropic turns organization webhook
    /// endpoints on for each organization; until yours is on, requests also return
    /// `404`. Organization webhook endpoints are in beta and are not available to
    /// organizations with HIPAA readiness enabled.
    ///
    /// Args:
    ///   webhook_endpoint_id: ID of the webhook endpoint.
    ///
    ///   betas: This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func regenerateSigningSecret<R: Sendable>(_ webhookEndpointID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaOrganizationWebhookEndpointSigningSecret>) async throws -> R) async throws -> R {
            let response = try await resource._regenerateSigningSecret(webhookEndpointID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
