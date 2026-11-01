// Transformed from `anthropic.resources.user_profiles.action_urls` (action_urls.py).

import Foundation

public struct UserProfilesActionURLsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Create Action URL
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile the action is for (`uprof_...`).
    ///
    ///   action: The action that the person who opens the URL takes.
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
    public func create(_ userProfileID: String, action: UserProfileEnrollEndUserActionParam, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> UserProfileActionURL {
        try await _create(userProfileID, action: action, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(_ userProfileID: String, action: UserProfileEnrollEndUserActionParam, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<UserProfileActionURL> {
        try requireNonEmpty(userProfileID, "user_profile_id")
        var body = ParamsBuilder()
        try body.set("action", action)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/user_profiles/{user_profile_id}/action_urls", ["user_profile_id": userProfileID]), body: body, headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.user_profiles.action_urls.create", spanRoute: "/v1/user_profiles/{user_profile_id}/action_urls", spanAttributes: ["anthropic.user_profile.id": userProfileID])
        return try await client.requestResponse(UserProfileActionURL.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: UserProfilesActionURLsResource

    /// Create Action URL
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile the action is for (`uprof_...`).
    ///
    ///   action: The action that the person who opens the URL takes.
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
        public func create(_ userProfileID: String, action: UserProfileEnrollEndUserActionParam, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<UserProfileActionURL> {
            try await resource._create(userProfileID, action: action, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: UserProfilesActionURLsResource

    /// Create Action URL
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile the action is for (`uprof_...`).
    ///
    ///   action: The action that the person who opens the URL takes.
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
        public func create<R: Sendable>(_ userProfileID: String, action: UserProfileEnrollEndUserActionParam, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<UserProfileActionURL>) async throws -> R) async throws -> R {
            let response = try await resource._create(userProfileID, action: action, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
