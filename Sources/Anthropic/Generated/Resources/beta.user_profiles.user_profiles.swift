// Transformed from `anthropic.resources.beta.user_profiles.user_profiles` (user_profiles.py).

import Foundation

public struct BetaUserProfilesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var actionURLs: BetaUserProfilesActionURLsResource { BetaUserProfilesActionURLsResource(client: client) }

    /// Create User Profile
    ///
    /// Args:
    ///   access_type: How the platform uses the API for this entity. `application` (default): the
    ///       profile represents an individual end-user of the platform's product.
    ///       `passthrough`: the profile identifies a company the platform resells Claude
    ///       access to.
    ///
    ///       - `application` - The user profile represents an individual end-user of a
    ///         product that the platform builds on the API. New profiles get this value by
    ///         default.
    ///       - `passthrough` - The user profile represents a company that the platform
    ///         resells Claude access to.
    ///
    ///   external_id: Platform's own identifier for this user. Not enforced unique. Maximum 255
    ///       characters. Legacy field, accepted only under the `user-profiles-2026-03-24` and
    ///       `user-profiles-2026-08-18` beta headers; without one of them, send
    ///       `external_user_details.reference_id`.
    ///
    ///   external_user_details: Details about the entity this profile represents, as the platform states them.
    ///       Every field is optional. Not accepted under the legacy
    ///       `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta headers, which
    ///       take the top-level `external_id` (and, under `user-profiles-2026-08-18`,
    ///       `external_user_onboarded_at`) instead.
    ///
    ///   external_user_onboarded_at: When the entity this profile represents opened its account with the platform, in
    ///       RFC 3339 format: for an `application` profile, when the end-user signed up; for
    ///       a `passthrough` profile, when the company became the platform's customer. Must
    ///       be a complete timestamp no more than 1 minute in the future. Optional. Legacy
    ///       field, accepted only under the `user-profiles-2026-08-18` beta header; without a
    ///       legacy header, send `external_user_details.onboarded_at`.
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
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
    public func create(accessType: BetaUserProfileCreateParams.AccessType? = nil, externalID: String?? = nil, externalUserDetails: BetaUserProfileExternalUserDetailsParams? = nil, externalUserOnboardedAt: BetaUserProfileCreateParams.ExternalUserOnboardedAt? = nil, metadata: [String: String]? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaUserProfile {
        try await _create(accessType: accessType, externalID: externalID, externalUserDetails: externalUserDetails, externalUserOnboardedAt: externalUserOnboardedAt, metadata: metadata, name: name, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(accessType: BetaUserProfileCreateParams.AccessType? = nil, externalID: String?? = nil, externalUserDetails: BetaUserProfileExternalUserDetailsParams? = nil, externalUserOnboardedAt: BetaUserProfileCreateParams.ExternalUserOnboardedAt? = nil, metadata: [String: String]? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaUserProfile> {
        var body = ParamsBuilder()
        try body.set("access_type", accessType)
        try body.set("external_id", externalID)
        try body.set("external_user_details", externalUserDetails)
        try body.set("external_user_onboarded_at", externalUserOnboardedAt)
        try body.set("metadata", metadata)
        try body.set("name", name)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/user_profiles", body: body, headers: mergeHeaderLayers(["anthropic-beta": "user-profiles-2026-08-18"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["user-profiles-2026-08-18"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.user_profiles.create")
        return try await client.requestResponse(BetaUserProfile.self, options, stream: _mode == .stream)
    }

    /// Get User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to get (`uprof_...`).
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
    public func retrieve(_ userProfileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaUserProfile {
        try await _retrieve(userProfileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ userProfileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaUserProfile> {
        try requireNonEmpty(userProfileID, "user_profile_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/user_profiles/{user_profile_id}", ["user_profile_id": userProfileID]), headers: mergeHeaderLayers(["anthropic-beta": "user-profiles-2026-08-18"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["user-profiles-2026-08-18"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.user_profiles.retrieve")
        return try await client.requestResponse(BetaUserProfile.self, options, stream: _mode == .stream)
    }

    /// Update User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to update (`uprof_...`).
    ///
    ///   access_type: If present, replaces the stored access type. Omit to leave unchanged.
    ///
    ///       - `application` - The user profile represents an individual end-user of a
    ///         product that the platform builds on the API. New profiles get this value by
    ///         default.
    ///       - `passthrough` - The user profile represents a company that the platform
    ///         resells Claude access to.
    ///
    ///   external_id: If present, replaces the stored external_id. Omit to leave unchanged. Maximum
    ///       255 characters. Legacy field, accepted only under the `user-profiles-2026-03-24`
    ///       and `user-profiles-2026-08-18` beta headers; without one of them, send
    ///       `external_user_details.reference_id`.
    ///
    ///   external_user_details: Details about the entity this profile represents, as the platform states them.
    ///       Each field sent replaces the stored value; omit a field to leave it unchanged.
    ///       Once set, a value cannot be cleared and `null` is rejected. Not accepted under
    ///       the legacy `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta
    ///       headers.
    ///
    ///   external_user_onboarded_at: If present, replaces the stored account creation time. Omit to leave unchanged;
    ///       once set, the value cannot be cleared and `null` is rejected. Must be a complete
    ///       RFC 3339 timestamp no more than 1 minute in the future. Legacy field, accepted
    ///       only under the `user-profiles-2026-08-18` beta header; without a legacy header,
    ///       send `external_user_details.onboarded_at`.
    ///
    ///   metadata: Key-value pairs to merge into the stored metadata. Keys provided overwrite
    ///       existing values. To remove a key, set its value to an empty string. Keys not
    ///       provided are left unchanged. Maximum 16 keys, with keys up to 64 characters and
    ///       values up to 512 characters.
    ///
    ///   name: If present, replaces the stored name. Omit to leave unchanged. Maximum 255
    ///       characters.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
    public func update(_ userProfileID: String, accessType: BetaUserProfileUpdateParams.AccessType?? = nil, externalID: String?? = nil, externalUserDetails: BetaUserProfileExternalUserDetailsParams? = nil, externalUserOnboardedAt: BetaUserProfileUpdateParams.ExternalUserOnboardedAt? = nil, metadata: [String: String]? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaUserProfile {
        try await _update(userProfileID, accessType: accessType, externalID: externalID, externalUserDetails: externalUserDetails, externalUserOnboardedAt: externalUserOnboardedAt, metadata: metadata, name: name, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ userProfileID: String, accessType: BetaUserProfileUpdateParams.AccessType?? = nil, externalID: String?? = nil, externalUserDetails: BetaUserProfileExternalUserDetailsParams? = nil, externalUserOnboardedAt: BetaUserProfileUpdateParams.ExternalUserOnboardedAt? = nil, metadata: [String: String]? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaUserProfile> {
        try requireNonEmpty(userProfileID, "user_profile_id")
        var body = ParamsBuilder()
        try body.set("access_type", accessType)
        try body.set("external_id", externalID)
        try body.set("external_user_details", externalUserDetails)
        try body.set("external_user_onboarded_at", externalUserOnboardedAt)
        try body.set("metadata", metadata)
        try body.set("name", name)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/user_profiles/{user_profile_id}", ["user_profile_id": userProfileID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "user-profiles-2026-08-18"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["user-profiles-2026-08-18"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.user_profiles.update")
        return try await client.requestResponse(BetaUserProfile.self, options, stream: _mode == .stream)
    }

    /// List User Profiles
    ///
    /// Args:
    ///   limit: The maximum number of user profiles to return, from 1 to 100. Defaults to 20.
    ///
    ///   order: The sort direction, applied to the field that `order_by` selects. Defaults to
    ///       `desc`.
    ///
    ///       - `asc` - Oldest first when `order_by` is `created_at`, or names in ascending
    ///         order when `order_by` is `name`.
    ///       - `desc` - Newest first when `order_by` is `created_at`, or names in descending
    ///         order when `order_by` is `name`. This is the default.
    ///
    ///   order_by: The field to sort user profiles by, in the direction that `order` sets. Defaults
    ///       to `created_at`.
    ///
    ///       - `created_at` - Sort by when each user profile was created. This is the
    ///         default.
    ///       - `name` - Sort by `name`, ignoring the case of ASCII letters. Profiles without
    ///         a name come last in either direction.
    ///
    ///   page: The cursor for the page to return, taken from `next_page` in a previous
    ///       response.
    ///
    ///       Leave it out to get the first page.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
    public func list(limit: Int? = nil, order: BetaUserProfileListParams.Order? = nil, orderBy: BetaUserProfileListParams.OrderBy? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaUserProfile> {
        try await _list(limit: limit, order: order, orderBy: orderBy, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(limit: Int? = nil, order: BetaUserProfileListParams.Order? = nil, orderBy: BetaUserProfileListParams.OrderBy? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaUserProfile>> {
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("order", order)
        try query.set("order_by", orderBy)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/user_profiles", query: query, headers: mergeHeaderLayers(["anthropic-beta": "user-profiles-2026-08-18"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["user-profiles-2026-08-18"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.user_profiles.list")
        return try await client.requestPageResponse(PageCursor<BetaUserProfile>.self, options, stream: _mode == .stream)
    }

    /// Delete User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to delete (`uprof_...`).
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
    public func delete(_ userProfileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaDeletedUserProfile {
        try await _delete(userProfileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ userProfileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaDeletedUserProfile> {
        try requireNonEmpty(userProfileID, "user_profile_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/user_profiles/{user_profile_id}", ["user_profile_id": userProfileID]), headers: mergeHeaderLayers(["anthropic-beta": "user-profiles-2026-08-18"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["user-profiles-2026-08-18"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.user_profiles.delete")
        return try await client.requestResponse(BetaDeletedUserProfile.self, options, stream: _mode == .stream)
    }

    /// Create Enrollment URL
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to create an enrollment URL for (`uprof_...`).
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
    public func createEnrollmentURL(_ userProfileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaUserProfileEnrollmentURL {
        try await _createEnrollmentURL(userProfileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _createEnrollmentURL(_ userProfileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaUserProfileEnrollmentURL> {
        try requireNonEmpty(userProfileID, "user_profile_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/user_profiles/{user_profile_id}/enrollment_url", ["user_profile_id": userProfileID]), headers: mergeHeaderLayers(["anthropic-beta": "user-profiles-2026-08-18"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["user-profiles-2026-08-18"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.user_profiles.create_enrollment_url")
        return try await client.requestResponse(BetaUserProfileEnrollmentURL.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaUserProfilesResource

        public var actionURLs: BetaUserProfilesActionURLsResource.WithRawResponse { resource.actionURLs.withRawResponse }

    /// Create User Profile
    ///
    /// Args:
    ///   access_type: How the platform uses the API for this entity. `application` (default): the
    ///       profile represents an individual end-user of the platform's product.
    ///       `passthrough`: the profile identifies a company the platform resells Claude
    ///       access to.
    ///
    ///       - `application` - The user profile represents an individual end-user of a
    ///         product that the platform builds on the API. New profiles get this value by
    ///         default.
    ///       - `passthrough` - The user profile represents a company that the platform
    ///         resells Claude access to.
    ///
    ///   external_id: Platform's own identifier for this user. Not enforced unique. Maximum 255
    ///       characters. Legacy field, accepted only under the `user-profiles-2026-03-24` and
    ///       `user-profiles-2026-08-18` beta headers; without one of them, send
    ///       `external_user_details.reference_id`.
    ///
    ///   external_user_details: Details about the entity this profile represents, as the platform states them.
    ///       Every field is optional. Not accepted under the legacy
    ///       `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta headers, which
    ///       take the top-level `external_id` (and, under `user-profiles-2026-08-18`,
    ///       `external_user_onboarded_at`) instead.
    ///
    ///   external_user_onboarded_at: When the entity this profile represents opened its account with the platform, in
    ///       RFC 3339 format: for an `application` profile, when the end-user signed up; for
    ///       a `passthrough` profile, when the company became the platform's customer. Must
    ///       be a complete timestamp no more than 1 minute in the future. Optional. Legacy
    ///       field, accepted only under the `user-profiles-2026-08-18` beta header; without a
    ///       legacy header, send `external_user_details.onboarded_at`.
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
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func create(accessType: BetaUserProfileCreateParams.AccessType? = nil, externalID: String?? = nil, externalUserDetails: BetaUserProfileExternalUserDetailsParams? = nil, externalUserOnboardedAt: BetaUserProfileCreateParams.ExternalUserOnboardedAt? = nil, metadata: [String: String]? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaUserProfile> {
            try await resource._create(accessType: accessType, externalID: externalID, externalUserDetails: externalUserDetails, externalUserOnboardedAt: externalUserOnboardedAt, metadata: metadata, name: name, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Get User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to get (`uprof_...`).
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func retrieve(_ userProfileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaUserProfile> {
            try await resource._retrieve(userProfileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to update (`uprof_...`).
    ///
    ///   access_type: If present, replaces the stored access type. Omit to leave unchanged.
    ///
    ///       - `application` - The user profile represents an individual end-user of a
    ///         product that the platform builds on the API. New profiles get this value by
    ///         default.
    ///       - `passthrough` - The user profile represents a company that the platform
    ///         resells Claude access to.
    ///
    ///   external_id: If present, replaces the stored external_id. Omit to leave unchanged. Maximum
    ///       255 characters. Legacy field, accepted only under the `user-profiles-2026-03-24`
    ///       and `user-profiles-2026-08-18` beta headers; without one of them, send
    ///       `external_user_details.reference_id`.
    ///
    ///   external_user_details: Details about the entity this profile represents, as the platform states them.
    ///       Each field sent replaces the stored value; omit a field to leave it unchanged.
    ///       Once set, a value cannot be cleared and `null` is rejected. Not accepted under
    ///       the legacy `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta
    ///       headers.
    ///
    ///   external_user_onboarded_at: If present, replaces the stored account creation time. Omit to leave unchanged;
    ///       once set, the value cannot be cleared and `null` is rejected. Must be a complete
    ///       RFC 3339 timestamp no more than 1 minute in the future. Legacy field, accepted
    ///       only under the `user-profiles-2026-08-18` beta header; without a legacy header,
    ///       send `external_user_details.onboarded_at`.
    ///
    ///   metadata: Key-value pairs to merge into the stored metadata. Keys provided overwrite
    ///       existing values. To remove a key, set its value to an empty string. Keys not
    ///       provided are left unchanged. Maximum 16 keys, with keys up to 64 characters and
    ///       values up to 512 characters.
    ///
    ///   name: If present, replaces the stored name. Omit to leave unchanged. Maximum 255
    ///       characters.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func update(_ userProfileID: String, accessType: BetaUserProfileUpdateParams.AccessType?? = nil, externalID: String?? = nil, externalUserDetails: BetaUserProfileExternalUserDetailsParams? = nil, externalUserOnboardedAt: BetaUserProfileUpdateParams.ExternalUserOnboardedAt? = nil, metadata: [String: String]? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaUserProfile> {
            try await resource._update(userProfileID, accessType: accessType, externalID: externalID, externalUserDetails: externalUserDetails, externalUserOnboardedAt: externalUserOnboardedAt, metadata: metadata, name: name, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List User Profiles
    ///
    /// Args:
    ///   limit: The maximum number of user profiles to return, from 1 to 100. Defaults to 20.
    ///
    ///   order: The sort direction, applied to the field that `order_by` selects. Defaults to
    ///       `desc`.
    ///
    ///       - `asc` - Oldest first when `order_by` is `created_at`, or names in ascending
    ///         order when `order_by` is `name`.
    ///       - `desc` - Newest first when `order_by` is `created_at`, or names in descending
    ///         order when `order_by` is `name`. This is the default.
    ///
    ///   order_by: The field to sort user profiles by, in the direction that `order` sets. Defaults
    ///       to `created_at`.
    ///
    ///       - `created_at` - Sort by when each user profile was created. This is the
    ///         default.
    ///       - `name` - Sort by `name`, ignoring the case of ASCII letters. Profiles without
    ///         a name come last in either direction.
    ///
    ///   page: The cursor for the page to return, taken from `next_page` in a previous
    ///       response.
    ///
    ///       Leave it out to get the first page.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func list(limit: Int? = nil, order: BetaUserProfileListParams.Order? = nil, orderBy: BetaUserProfileListParams.OrderBy? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaUserProfile>> {
            try await resource._list(limit: limit, order: order, orderBy: orderBy, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to delete (`uprof_...`).
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func delete(_ userProfileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaDeletedUserProfile> {
            try await resource._delete(userProfileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Create Enrollment URL
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to create an enrollment URL for (`uprof_...`).
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func createEnrollmentURL(_ userProfileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaUserProfileEnrollmentURL> {
            try await resource._createEnrollmentURL(userProfileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaUserProfilesResource

        public var actionURLs: BetaUserProfilesActionURLsResource.WithStreamingResponse { resource.actionURLs.withStreamingResponse }

    /// Create User Profile
    ///
    /// Args:
    ///   access_type: How the platform uses the API for this entity. `application` (default): the
    ///       profile represents an individual end-user of the platform's product.
    ///       `passthrough`: the profile identifies a company the platform resells Claude
    ///       access to.
    ///
    ///       - `application` - The user profile represents an individual end-user of a
    ///         product that the platform builds on the API. New profiles get this value by
    ///         default.
    ///       - `passthrough` - The user profile represents a company that the platform
    ///         resells Claude access to.
    ///
    ///   external_id: Platform's own identifier for this user. Not enforced unique. Maximum 255
    ///       characters. Legacy field, accepted only under the `user-profiles-2026-03-24` and
    ///       `user-profiles-2026-08-18` beta headers; without one of them, send
    ///       `external_user_details.reference_id`.
    ///
    ///   external_user_details: Details about the entity this profile represents, as the platform states them.
    ///       Every field is optional. Not accepted under the legacy
    ///       `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta headers, which
    ///       take the top-level `external_id` (and, under `user-profiles-2026-08-18`,
    ///       `external_user_onboarded_at`) instead.
    ///
    ///   external_user_onboarded_at: When the entity this profile represents opened its account with the platform, in
    ///       RFC 3339 format: for an `application` profile, when the end-user signed up; for
    ///       a `passthrough` profile, when the company became the platform's customer. Must
    ///       be a complete timestamp no more than 1 minute in the future. Optional. Legacy
    ///       field, accepted only under the `user-profiles-2026-08-18` beta header; without a
    ///       legacy header, send `external_user_details.onboarded_at`.
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
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func create<R: Sendable>(accessType: BetaUserProfileCreateParams.AccessType? = nil, externalID: String?? = nil, externalUserDetails: BetaUserProfileExternalUserDetailsParams? = nil, externalUserOnboardedAt: BetaUserProfileCreateParams.ExternalUserOnboardedAt? = nil, metadata: [String: String]? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaUserProfile>) async throws -> R) async throws -> R {
            let response = try await resource._create(accessType: accessType, externalID: externalID, externalUserDetails: externalUserDetails, externalUserOnboardedAt: externalUserOnboardedAt, metadata: metadata, name: name, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Get User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to get (`uprof_...`).
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func retrieve<R: Sendable>(_ userProfileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaUserProfile>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(userProfileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
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
    ///       - `application` - The user profile represents an individual end-user of a
    ///         product that the platform builds on the API. New profiles get this value by
    ///         default.
    ///       - `passthrough` - The user profile represents a company that the platform
    ///         resells Claude access to.
    ///
    ///   external_id: If present, replaces the stored external_id. Omit to leave unchanged. Maximum
    ///       255 characters. Legacy field, accepted only under the `user-profiles-2026-03-24`
    ///       and `user-profiles-2026-08-18` beta headers; without one of them, send
    ///       `external_user_details.reference_id`.
    ///
    ///   external_user_details: Details about the entity this profile represents, as the platform states them.
    ///       Each field sent replaces the stored value; omit a field to leave it unchanged.
    ///       Once set, a value cannot be cleared and `null` is rejected. Not accepted under
    ///       the legacy `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta
    ///       headers.
    ///
    ///   external_user_onboarded_at: If present, replaces the stored account creation time. Omit to leave unchanged;
    ///       once set, the value cannot be cleared and `null` is rejected. Must be a complete
    ///       RFC 3339 timestamp no more than 1 minute in the future. Legacy field, accepted
    ///       only under the `user-profiles-2026-08-18` beta header; without a legacy header,
    ///       send `external_user_details.onboarded_at`.
    ///
    ///   metadata: Key-value pairs to merge into the stored metadata. Keys provided overwrite
    ///       existing values. To remove a key, set its value to an empty string. Keys not
    ///       provided are left unchanged. Maximum 16 keys, with keys up to 64 characters and
    ///       values up to 512 characters.
    ///
    ///   name: If present, replaces the stored name. Omit to leave unchanged. Maximum 255
    ///       characters.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func update<R: Sendable>(_ userProfileID: String, accessType: BetaUserProfileUpdateParams.AccessType?? = nil, externalID: String?? = nil, externalUserDetails: BetaUserProfileExternalUserDetailsParams? = nil, externalUserOnboardedAt: BetaUserProfileUpdateParams.ExternalUserOnboardedAt? = nil, metadata: [String: String]? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaUserProfile>) async throws -> R) async throws -> R {
            let response = try await resource._update(userProfileID, accessType: accessType, externalID: externalID, externalUserDetails: externalUserDetails, externalUserOnboardedAt: externalUserOnboardedAt, metadata: metadata, name: name, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List User Profiles
    ///
    /// Args:
    ///   limit: The maximum number of user profiles to return, from 1 to 100. Defaults to 20.
    ///
    ///   order: The sort direction, applied to the field that `order_by` selects. Defaults to
    ///       `desc`.
    ///
    ///       - `asc` - Oldest first when `order_by` is `created_at`, or names in ascending
    ///         order when `order_by` is `name`.
    ///       - `desc` - Newest first when `order_by` is `created_at`, or names in descending
    ///         order when `order_by` is `name`. This is the default.
    ///
    ///   order_by: The field to sort user profiles by, in the direction that `order` sets. Defaults
    ///       to `created_at`.
    ///
    ///       - `created_at` - Sort by when each user profile was created. This is the
    ///         default.
    ///       - `name` - Sort by `name`, ignoring the case of ASCII letters. Profiles without
    ///         a name come last in either direction.
    ///
    ///   page: The cursor for the page to return, taken from `next_page` in a previous
    ///       response.
    ///
    ///       Leave it out to get the first page.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func list<R: Sendable>(limit: Int? = nil, order: BetaUserProfileListParams.Order? = nil, orderBy: BetaUserProfileListParams.OrderBy? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaUserProfile>>) async throws -> R) async throws -> R {
            let response = try await resource._list(limit: limit, order: order, orderBy: orderBy, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete User Profile
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to delete (`uprof_...`).
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func delete<R: Sendable>(_ userProfileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaDeletedUserProfile>) async throws -> R) async throws -> R {
            let response = try await resource._delete(userProfileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Create Enrollment URL
    ///
    /// Args:
    ///   user_profile_id: The ID of the user profile to create an enrollment URL for (`uprof_...`).
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func createEnrollmentURL<R: Sendable>(_ userProfileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaUserProfileEnrollmentURL>) async throws -> R) async throws -> R {
            let response = try await resource._createEnrollmentURL(userProfileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
