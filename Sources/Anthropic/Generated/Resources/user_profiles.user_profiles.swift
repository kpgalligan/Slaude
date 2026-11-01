// Transformed from `anthropic.resources.user_profiles.user_profiles` (user_profiles.py).

import Foundation

public struct UserProfilesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var actionURLs: UserProfilesActionURLsResource { UserProfilesActionURLsResource(client: client) }

    /// Create User Profile
    ///
    /// Args:
    ///   access_type: How the platform uses the API for this entity. `application` (default): the
    ///       profile represents an individual end-user of the platform's product.
    ///       `passthrough`: the profile identifies a company the platform resells Claude
    ///       access to.
    ///
    ///   external_user_details: Details about the entity this profile represents, as the platform states them.
    ///       Every field is optional. Not accepted under the legacy
    ///       `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta headers, which
    ///       take the top-level `external_id` (and, under `user-profiles-2026-08-18`,
    ///       `external_user_onboarded_at`) instead.
    ///
    ///   metadata: Free-form key-value data to attach to this user profile. Maximum 16 keys, with
    ///       keys up to 64 characters and values up to 512 characters. Values must be
    ///       non-empty strings.
    ///
    ///   name: Optional for all profiles. Real-world name of the entity this profile represents
    ///       (company or individual); for a company the platform resells Claude access to
    ///       (`access_type` `passthrough`), that company's name where known. Maximum 255
    ///       characters.
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
    public func create(accessType: UserProfileAccessType? = nil, externalUserDetails: UserProfileExternalUserDetailsParams? = nil, metadata: [String: String]? = nil, name: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> UserProfile {
        try await _create(accessType: accessType, externalUserDetails: externalUserDetails, metadata: metadata, name: name, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(accessType: UserProfileAccessType? = nil, externalUserDetails: UserProfileExternalUserDetailsParams? = nil, metadata: [String: String]? = nil, name: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<UserProfile> {
        var body = ParamsBuilder()
        try body.set("access_type", accessType)
        try body.set("external_user_details", externalUserDetails)
        try body.set("metadata", metadata)
        try body.set("name", name)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/user_profiles", body: body, headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.user_profiles.create")
        return try await client.requestResponse(UserProfile.self, options, stream: _mode == .stream)
    }

    /// Get User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to get (`uprof_...`).
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
    public func retrieve(_ userProfileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> UserProfile {
        try await _retrieve(userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ userProfileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<UserProfile> {
        try requireNonEmpty(userProfileID, "user_profile_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/user_profiles/{user_profile_id}", ["user_profile_id": userProfileID]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.user_profiles.retrieve")
        return try await client.requestResponse(UserProfile.self, options, stream: _mode == .stream)
    }

    /// Update User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to update (`uprof_...`).
    ///
    ///   access_type: If present, replaces the stored access type. Omit to leave unchanged.
    ///
    ///   external_user_details: Details about the entity this profile represents, as the platform states them.
    ///       Each field sent replaces the stored value; omit a field to leave it unchanged.
    ///       Once set, a value cannot be cleared and `null` is rejected. Not accepted under
    ///       the legacy `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta
    ///       headers.
    ///
    ///   metadata: Key-value pairs to merge into the stored metadata. Keys provided overwrite
    ///       existing values. To remove a key, set its value to an empty string. Keys not
    ///       provided are left unchanged. Maximum 16 keys, with keys up to 64 characters and
    ///       values up to 512 characters.
    ///
    ///   name: If present, replaces the stored name. Omit to leave unchanged. Maximum 255
    ///       characters.
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
    public func update(_ userProfileID: String, accessType: UserProfileAccessType?? = nil, externalUserDetails: UserProfileExternalUserDetailsParams? = nil, metadata: [String: String]? = nil, name: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> UserProfile {
        try await _update(userProfileID, accessType: accessType, externalUserDetails: externalUserDetails, metadata: metadata, name: name, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ userProfileID: String, accessType: UserProfileAccessType?? = nil, externalUserDetails: UserProfileExternalUserDetailsParams? = nil, metadata: [String: String]? = nil, name: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<UserProfile> {
        try requireNonEmpty(userProfileID, "user_profile_id")
        var body = ParamsBuilder()
        try body.set("access_type", accessType)
        try body.set("external_user_details", externalUserDetails)
        try body.set("metadata", metadata)
        try body.set("name", name)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/user_profiles/{user_profile_id}", ["user_profile_id": userProfileID]), body: body, headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.user_profiles.update")
        return try await client.requestResponse(UserProfile.self, options, stream: _mode == .stream)
    }

    /// List User Profiles
    ///
    /// Args:
    ///   enforcement_status:
    ///       Return only the user profiles whose `enforcement_status` is one of these values:
    ///       `unrestricted`, `pending`, `restricted` or `banned`. Repeat the parameter to
    ///       match any of several. With it set, a page may hold fewer than `limit` profiles,
    ///       or none, and still carry a `next_page`: the service examines a bounded number of
    ///       profiles per request, and only a null `next_page` means the listing is complete.
    ///       Rejected with `invalid_request_error` under the `user-profiles-2026-09-04` and
    ///       earlier beta headers. Fails with `overloaded_error` when a profile's enforcement
    ///       actions cannot be read for the moment.
    ///
    ///   limit: The maximum number of user profiles to return, from 1 to 100. Defaults to 20.
    ///
    ///   order: The sort direction, applied to the field that `order_by` selects. Defaults to
    ///       `desc`.
    ///
    ///   order_by: The field to sort user profiles by, in the direction that `order` sets. Defaults
    ///       to `created_at`.
    ///
    ///   page: The cursor for the page to return, taken from `next_page` in a previous
    ///       response.
    ///
    ///       Leave it out to get the first page.
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
    public func list(enforcementStatus: [UserProfileEnforcementStatus]? = nil, limit: Int? = nil, order: UserProfileListOrder? = nil, orderBy: UserProfileListOrderBy? = nil, page: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<UserProfile> {
        try await _list(enforcementStatus: enforcementStatus, limit: limit, order: order, orderBy: orderBy, page: page, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(enforcementStatus: [UserProfileEnforcementStatus]? = nil, limit: Int? = nil, order: UserProfileListOrder? = nil, orderBy: UserProfileListOrderBy? = nil, page: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<UserProfile>> {
        var query = ParamsBuilder()
        try query.set("enforcement_status", enforcementStatus)
        try query.set("limit", limit)
        try query.set("order", order)
        try query.set("order_by", orderBy)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/user_profiles", query: query, headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.user_profiles.list")
        return try await client.requestPageResponse(PageCursor<UserProfile>.self, options, stream: _mode == .stream)
    }

    /// Delete User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to delete (`uprof_...`).
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
    public func delete(_ userProfileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> DeletedUserProfile {
        try await _delete(userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ userProfileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<DeletedUserProfile> {
        try requireNonEmpty(userProfileID, "user_profile_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/user_profiles/{user_profile_id}", ["user_profile_id": userProfileID]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.user_profiles.delete")
        return try await client.requestResponse(DeletedUserProfile.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: UserProfilesResource

        public var actionURLs: UserProfilesActionURLsResource.WithRawResponse { resource.actionURLs.withRawResponse }

    /// Create User Profile
    ///
    /// Args:
    ///   access_type: How the platform uses the API for this entity. `application` (default): the
    ///       profile represents an individual end-user of the platform's product.
    ///       `passthrough`: the profile identifies a company the platform resells Claude
    ///       access to.
    ///
    ///   external_user_details: Details about the entity this profile represents, as the platform states them.
    ///       Every field is optional. Not accepted under the legacy
    ///       `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta headers, which
    ///       take the top-level `external_id` (and, under `user-profiles-2026-08-18`,
    ///       `external_user_onboarded_at`) instead.
    ///
    ///   metadata: Free-form key-value data to attach to this user profile. Maximum 16 keys, with
    ///       keys up to 64 characters and values up to 512 characters. Values must be
    ///       non-empty strings.
    ///
    ///   name: Optional for all profiles. Real-world name of the entity this profile represents
    ///       (company or individual); for a company the platform resells Claude access to
    ///       (`access_type` `passthrough`), that company's name where known. Maximum 255
    ///       characters.
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
        public func create(accessType: UserProfileAccessType? = nil, externalUserDetails: UserProfileExternalUserDetailsParams? = nil, metadata: [String: String]? = nil, name: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<UserProfile> {
            try await resource._create(accessType: accessType, externalUserDetails: externalUserDetails, metadata: metadata, name: name, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Get User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to get (`uprof_...`).
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
        public func retrieve(_ userProfileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<UserProfile> {
            try await resource._retrieve(userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to update (`uprof_...`).
    ///
    ///   access_type: If present, replaces the stored access type. Omit to leave unchanged.
    ///
    ///   external_user_details: Details about the entity this profile represents, as the platform states them.
    ///       Each field sent replaces the stored value; omit a field to leave it unchanged.
    ///       Once set, a value cannot be cleared and `null` is rejected. Not accepted under
    ///       the legacy `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta
    ///       headers.
    ///
    ///   metadata: Key-value pairs to merge into the stored metadata. Keys provided overwrite
    ///       existing values. To remove a key, set its value to an empty string. Keys not
    ///       provided are left unchanged. Maximum 16 keys, with keys up to 64 characters and
    ///       values up to 512 characters.
    ///
    ///   name: If present, replaces the stored name. Omit to leave unchanged. Maximum 255
    ///       characters.
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
        public func update(_ userProfileID: String, accessType: UserProfileAccessType?? = nil, externalUserDetails: UserProfileExternalUserDetailsParams? = nil, metadata: [String: String]? = nil, name: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<UserProfile> {
            try await resource._update(userProfileID, accessType: accessType, externalUserDetails: externalUserDetails, metadata: metadata, name: name, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List User Profiles
    ///
    /// Args:
    ///   enforcement_status:
    ///       Return only the user profiles whose `enforcement_status` is one of these values:
    ///       `unrestricted`, `pending`, `restricted` or `banned`. Repeat the parameter to
    ///       match any of several. With it set, a page may hold fewer than `limit` profiles,
    ///       or none, and still carry a `next_page`: the service examines a bounded number of
    ///       profiles per request, and only a null `next_page` means the listing is complete.
    ///       Rejected with `invalid_request_error` under the `user-profiles-2026-09-04` and
    ///       earlier beta headers. Fails with `overloaded_error` when a profile's enforcement
    ///       actions cannot be read for the moment.
    ///
    ///   limit: The maximum number of user profiles to return, from 1 to 100. Defaults to 20.
    ///
    ///   order: The sort direction, applied to the field that `order_by` selects. Defaults to
    ///       `desc`.
    ///
    ///   order_by: The field to sort user profiles by, in the direction that `order` sets. Defaults
    ///       to `created_at`.
    ///
    ///   page: The cursor for the page to return, taken from `next_page` in a previous
    ///       response.
    ///
    ///       Leave it out to get the first page.
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
        public func list(enforcementStatus: [UserProfileEnforcementStatus]? = nil, limit: Int? = nil, order: UserProfileListOrder? = nil, orderBy: UserProfileListOrderBy? = nil, page: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<UserProfile>> {
            try await resource._list(enforcementStatus: enforcementStatus, limit: limit, order: order, orderBy: orderBy, page: page, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to delete (`uprof_...`).
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
        public func delete(_ userProfileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<DeletedUserProfile> {
            try await resource._delete(userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: UserProfilesResource

        public var actionURLs: UserProfilesActionURLsResource.WithStreamingResponse { resource.actionURLs.withStreamingResponse }

    /// Create User Profile
    ///
    /// Args:
    ///   access_type: How the platform uses the API for this entity. `application` (default): the
    ///       profile represents an individual end-user of the platform's product.
    ///       `passthrough`: the profile identifies a company the platform resells Claude
    ///       access to.
    ///
    ///   external_user_details: Details about the entity this profile represents, as the platform states them.
    ///       Every field is optional. Not accepted under the legacy
    ///       `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta headers, which
    ///       take the top-level `external_id` (and, under `user-profiles-2026-08-18`,
    ///       `external_user_onboarded_at`) instead.
    ///
    ///   metadata: Free-form key-value data to attach to this user profile. Maximum 16 keys, with
    ///       keys up to 64 characters and values up to 512 characters. Values must be
    ///       non-empty strings.
    ///
    ///   name: Optional for all profiles. Real-world name of the entity this profile represents
    ///       (company or individual); for a company the platform resells Claude access to
    ///       (`access_type` `passthrough`), that company's name where known. Maximum 255
    ///       characters.
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
        public func create<R: Sendable>(accessType: UserProfileAccessType? = nil, externalUserDetails: UserProfileExternalUserDetailsParams? = nil, metadata: [String: String]? = nil, name: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<UserProfile>) async throws -> R) async throws -> R {
            let response = try await resource._create(accessType: accessType, externalUserDetails: externalUserDetails, metadata: metadata, name: name, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Get User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to get (`uprof_...`).
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
        public func retrieve<R: Sendable>(_ userProfileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<UserProfile>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Update User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to update (`uprof_...`).
    ///
    ///   access_type: If present, replaces the stored access type. Omit to leave unchanged.
    ///
    ///   external_user_details: Details about the entity this profile represents, as the platform states them.
    ///       Each field sent replaces the stored value; omit a field to leave it unchanged.
    ///       Once set, a value cannot be cleared and `null` is rejected. Not accepted under
    ///       the legacy `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta
    ///       headers.
    ///
    ///   metadata: Key-value pairs to merge into the stored metadata. Keys provided overwrite
    ///       existing values. To remove a key, set its value to an empty string. Keys not
    ///       provided are left unchanged. Maximum 16 keys, with keys up to 64 characters and
    ///       values up to 512 characters.
    ///
    ///   name: If present, replaces the stored name. Omit to leave unchanged. Maximum 255
    ///       characters.
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
        public func update<R: Sendable>(_ userProfileID: String, accessType: UserProfileAccessType?? = nil, externalUserDetails: UserProfileExternalUserDetailsParams? = nil, metadata: [String: String]? = nil, name: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<UserProfile>) async throws -> R) async throws -> R {
            let response = try await resource._update(userProfileID, accessType: accessType, externalUserDetails: externalUserDetails, metadata: metadata, name: name, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List User Profiles
    ///
    /// Args:
    ///   enforcement_status:
    ///       Return only the user profiles whose `enforcement_status` is one of these values:
    ///       `unrestricted`, `pending`, `restricted` or `banned`. Repeat the parameter to
    ///       match any of several. With it set, a page may hold fewer than `limit` profiles,
    ///       or none, and still carry a `next_page`: the service examines a bounded number of
    ///       profiles per request, and only a null `next_page` means the listing is complete.
    ///       Rejected with `invalid_request_error` under the `user-profiles-2026-09-04` and
    ///       earlier beta headers. Fails with `overloaded_error` when a profile's enforcement
    ///       actions cannot be read for the moment.
    ///
    ///   limit: The maximum number of user profiles to return, from 1 to 100. Defaults to 20.
    ///
    ///   order: The sort direction, applied to the field that `order_by` selects. Defaults to
    ///       `desc`.
    ///
    ///   order_by: The field to sort user profiles by, in the direction that `order` sets. Defaults
    ///       to `created_at`.
    ///
    ///   page: The cursor for the page to return, taken from `next_page` in a previous
    ///       response.
    ///
    ///       Leave it out to get the first page.
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
        public func list<R: Sendable>(enforcementStatus: [UserProfileEnforcementStatus]? = nil, limit: Int? = nil, order: UserProfileListOrder? = nil, orderBy: UserProfileListOrderBy? = nil, page: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<UserProfile>>) async throws -> R) async throws -> R {
            let response = try await resource._list(enforcementStatus: enforcementStatus, limit: limit, order: order, orderBy: orderBy, page: page, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to delete (`uprof_...`).
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
        public func delete<R: Sendable>(_ userProfileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<DeletedUserProfile>) async throws -> R) async throws -> R {
            let response = try await resource._delete(userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
