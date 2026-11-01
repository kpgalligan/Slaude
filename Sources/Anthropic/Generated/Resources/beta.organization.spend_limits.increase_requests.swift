// Transformed from `anthropic.resources.beta.organization.spend_limits.increase_requests` (increase_requests.py).

import Foundation

public struct BetaOrganizationSpendLimitsIncreaseRequestsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Retrieve a spend limit increase request.
    ///
    /// While `pending`, the response includes a live `spend_summary` for the requester
    /// at the request's period.
    ///
    /// Args:
    ///   spend_limit_increase_request_id: ID of the spend limit increase request.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ spendLimitIncreaseRequestID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaSpendLimitIncreaseRequest {
        try await _retrieve(spendLimitIncreaseRequestID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ spendLimitIncreaseRequestID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaSpendLimitIncreaseRequest> {
        try requireNonEmpty(spendLimitIncreaseRequestID, "spend_limit_increase_request_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}", ["spend_limit_increase_request_id": spendLimitIncreaseRequestID]), headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.spend_limits.increase_requests.retrieve", spanRoute: "/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}", spanAttributes: ["anthropic.organization.spend_limit_increase_request.id": spendLimitIncreaseRequestID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaSpendLimitIncreaseRequest.self, options, stream: _mode == .stream)
    }

    /// List spend limit increase requests, most recent first.
    ///
    /// Pending requests include a live `spend_summary` for the requester. Requests
    /// whose requester is no longer a member are excluded.
    ///
    /// Args:
    ///   actor_ids: Filter by requester, as `user_...` tagged IDs.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   status: Filter by status. Omit to return all.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(actorIDs: [String]?? = nil, limit: Int? = nil, page: String?? = nil, status: [BetaSpendLimitIncreaseRequestStatus]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaSpendLimitIncreaseRequest> {
        try await _list(actorIDs: actorIDs, limit: limit, page: page, status: status, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(actorIDs: [String]?? = nil, limit: Int? = nil, page: String?? = nil, status: [BetaSpendLimitIncreaseRequestStatus]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaSpendLimitIncreaseRequest>> {
        var query = ParamsBuilder()
        try query.set("actor_ids", actorIDs)
        try query.set("limit", limit)
        try query.set("page", page)
        try query.set("status", status)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/spend_limit_increase_requests", query: query, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.spend_limits.increase_requests.list", spanRoute: "/v1/organizations/spend_limit_increase_requests", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaSpendLimitIncreaseRequest>.self, options, stream: _mode == .stream)
    }

    /// Approve a pending spend limit increase request.
    ///
    /// Writes a per-user spend limit at `amount` for the requester and transitions the
    /// request to `approved`. `period` defaults to the period the member was blocked
    /// on. Anthropic emails the requester unless `suppress_notification` is set.
    ///
    /// Args:
    ///   spend_limit_increase_request_id: ID of the spend limit increase request.
    ///
    ///   amount: New per-user spend limit as a non-negative integer decimal string (minor units).
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func approve(_ spendLimitIncreaseRequestID: String, amount: String, period: BetaSpendLimitPeriod?? = nil, suppressNotification: Bool? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> IncreaseRequestApproveResponse {
        try await _approve(spendLimitIncreaseRequestID, amount: amount, period: period, suppressNotification: suppressNotification, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _approve(_ spendLimitIncreaseRequestID: String, amount: String, period: BetaSpendLimitPeriod?? = nil, suppressNotification: Bool? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<IncreaseRequestApproveResponse> {
        try requireNonEmpty(spendLimitIncreaseRequestID, "spend_limit_increase_request_id")
        var body = ParamsBuilder()
        try body.set("amount", amount)
        try body.set("period", period)
        try body.set("suppress_notification", suppressNotification)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}/approve", ["spend_limit_increase_request_id": spendLimitIncreaseRequestID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.spend_limits.increase_requests.approve", spanRoute: "/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}/approve", spanAttributes: ["anthropic.organization.spend_limit_increase_request.id": spendLimitIncreaseRequestID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(IncreaseRequestApproveResponse.self, options, stream: _mode == .stream)
    }

    /// Deny a pending spend limit increase request.
    ///
    /// Idempotent on `denied`; denying an already-`approved` request returns 400.
    /// Anthropic emails the requester unless `suppress_notification` is set.
    ///
    /// Args:
    ///   spend_limit_increase_request_id: ID of the spend limit increase request.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func deny(_ spendLimitIncreaseRequestID: String, suppressNotification: Bool? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaSpendLimitIncreaseRequest {
        try await _deny(spendLimitIncreaseRequestID, suppressNotification: suppressNotification, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _deny(_ spendLimitIncreaseRequestID: String, suppressNotification: Bool? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaSpendLimitIncreaseRequest> {
        try requireNonEmpty(spendLimitIncreaseRequestID, "spend_limit_increase_request_id")
        var body = ParamsBuilder()
        try body.set("suppress_notification", suppressNotification)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}/deny", ["spend_limit_increase_request_id": spendLimitIncreaseRequestID]), body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.spend_limits.increase_requests.deny", spanRoute: "/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}/deny", spanAttributes: ["anthropic.organization.spend_limit_increase_request.id": spendLimitIncreaseRequestID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaSpendLimitIncreaseRequest.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationSpendLimitsIncreaseRequestsResource

    /// Retrieve a spend limit increase request.
    ///
    /// While `pending`, the response includes a live `spend_summary` for the requester
    /// at the request's period.
    ///
    /// Args:
    ///   spend_limit_increase_request_id: ID of the spend limit increase request.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ spendLimitIncreaseRequestID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaSpendLimitIncreaseRequest> {
            try await resource._retrieve(spendLimitIncreaseRequestID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List spend limit increase requests, most recent first.
    ///
    /// Pending requests include a live `spend_summary` for the requester. Requests
    /// whose requester is no longer a member are excluded.
    ///
    /// Args:
    ///   actor_ids: Filter by requester, as `user_...` tagged IDs.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   status: Filter by status. Omit to return all.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(actorIDs: [String]?? = nil, limit: Int? = nil, page: String?? = nil, status: [BetaSpendLimitIncreaseRequestStatus]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaSpendLimitIncreaseRequest>> {
            try await resource._list(actorIDs: actorIDs, limit: limit, page: page, status: status, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Approve a pending spend limit increase request.
    ///
    /// Writes a per-user spend limit at `amount` for the requester and transitions the
    /// request to `approved`. `period` defaults to the period the member was blocked
    /// on. Anthropic emails the requester unless `suppress_notification` is set.
    ///
    /// Args:
    ///   spend_limit_increase_request_id: ID of the spend limit increase request.
    ///
    ///   amount: New per-user spend limit as a non-negative integer decimal string (minor units).
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func approve(_ spendLimitIncreaseRequestID: String, amount: String, period: BetaSpendLimitPeriod?? = nil, suppressNotification: Bool? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<IncreaseRequestApproveResponse> {
            try await resource._approve(spendLimitIncreaseRequestID, amount: amount, period: period, suppressNotification: suppressNotification, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Deny a pending spend limit increase request.
    ///
    /// Idempotent on `denied`; denying an already-`approved` request returns 400.
    /// Anthropic emails the requester unless `suppress_notification` is set.
    ///
    /// Args:
    ///   spend_limit_increase_request_id: ID of the spend limit increase request.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func deny(_ spendLimitIncreaseRequestID: String, suppressNotification: Bool? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaSpendLimitIncreaseRequest> {
            try await resource._deny(spendLimitIncreaseRequestID, suppressNotification: suppressNotification, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationSpendLimitsIncreaseRequestsResource

    /// Retrieve a spend limit increase request.
    ///
    /// While `pending`, the response includes a live `spend_summary` for the requester
    /// at the request's period.
    ///
    /// Args:
    ///   spend_limit_increase_request_id: ID of the spend limit increase request.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ spendLimitIncreaseRequestID: String, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaSpendLimitIncreaseRequest>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(spendLimitIncreaseRequestID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List spend limit increase requests, most recent first.
    ///
    /// Pending requests include a live `spend_summary` for the requester. Requests
    /// whose requester is no longer a member are excluded.
    ///
    /// Args:
    ///   actor_ids: Filter by requester, as `user_...` tagged IDs.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   status: Filter by status. Omit to return all.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(actorIDs: [String]?? = nil, limit: Int? = nil, page: String?? = nil, status: [BetaSpendLimitIncreaseRequestStatus]?? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaSpendLimitIncreaseRequest>>) async throws -> R) async throws -> R {
            let response = try await resource._list(actorIDs: actorIDs, limit: limit, page: page, status: status, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Approve a pending spend limit increase request.
    ///
    /// Writes a per-user spend limit at `amount` for the requester and transitions the
    /// request to `approved`. `period` defaults to the period the member was blocked
    /// on. Anthropic emails the requester unless `suppress_notification` is set.
    ///
    /// Args:
    ///   spend_limit_increase_request_id: ID of the spend limit increase request.
    ///
    ///   amount: New per-user spend limit as a non-negative integer decimal string (minor units).
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func approve<R: Sendable>(_ spendLimitIncreaseRequestID: String, amount: String, period: BetaSpendLimitPeriod?? = nil, suppressNotification: Bool? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<IncreaseRequestApproveResponse>) async throws -> R) async throws -> R {
            let response = try await resource._approve(spendLimitIncreaseRequestID, amount: amount, period: period, suppressNotification: suppressNotification, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Deny a pending spend limit increase request.
    ///
    /// Idempotent on `denied`; denying an already-`approved` request returns 400.
    /// Anthropic emails the requester unless `suppress_notification` is set.
    ///
    /// Args:
    ///   spend_limit_increase_request_id: ID of the spend limit increase request.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func deny<R: Sendable>(_ spendLimitIncreaseRequestID: String, suppressNotification: Bool? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaSpendLimitIncreaseRequest>) async throws -> R) async throws -> R {
            let response = try await resource._deny(spendLimitIncreaseRequestID, suppressNotification: suppressNotification, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
