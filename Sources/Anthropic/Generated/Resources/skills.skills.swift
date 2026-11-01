// Transformed from `anthropic.resources.skills.skills` (skills.py).

import Foundation

public struct SkillsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var versions: SkillsVersionsResource { SkillsVersionsResource(client: client) }

    /// Create Skill
    ///
    /// Args:
    ///   files: Files to upload for the skill.
    ///
    ///       All files must be in the same top-level directory and must include a SKILL.md
    ///       file at the root of that directory.
    ///
    ///   display_name: Human-readable, single-line label for the Skill. Maximum 255 characters. Always
    ///       set: derived from the SKILL.md frontmatter `name` when omitted at creation. Not
    ///       unique.
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
    public func create(files: [FileUpload], displayName: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Skill {
        try await _create(files: files, displayName: displayName, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(files: [FileUpload], displayName: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Skill> {
        var body = ParamsBuilder()
        body.setFiles("files", files)
        try body.set("display_name", displayName)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/skills", body: body, headers: mergeHeaderLayers(["Content-Type": "multipart/form-data"], mergeHeaderLayers(["Content-Type": "multipart/form-data"], mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders))), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.skills.create", spanRoute: "/v1/skills", spanCreatedID: SpanCreatedID("anthropic.skill.id"))
        return try await client.requestResponse(Skill.self, options, stream: _mode == .stream)
    }

    /// Get Skill
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
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
    public func retrieve(_ skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Skill {
        try await _retrieve(skillID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Skill> {
        try requireNonEmpty(skillID, "skill_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/skills/{skill_id}", ["skill_id": skillID]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.skills.retrieve", spanRoute: "/v1/skills/{skill_id}", spanAttributes: ["anthropic.skill.id": skillID])
        return try await client.requestResponse(Skill.self, options, stream: _mode == .stream)
    }

    /// List Skills
    ///
    /// Args:
    ///   limit: Number of results to return per page.
    ///
    ///       Ranges from `1` to `1000`. Defaults to `20`.
    ///
    ///   page: Pagination token for fetching a specific page of results.
    ///
    ///       Pass the value from a previous response's `next_page` field to get the next page
    ///       of results.
    ///
    ///   source: Filter skills by source.
    ///
    ///       If provided, only skills from the specified source will be returned:
    ///
    ///       - `"custom"`: only return user-created skills
    ///       - `"anthropic"`: only return Anthropic-created skills
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
    public func list(limit: Int? = nil, page: String?? = nil, source: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<Skill> {
        try await _list(limit: limit, page: page, source: source, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(limit: Int? = nil, page: String?? = nil, source: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<Skill>> {
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        try query.set("source", source)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/skills", query: query, headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.skills.list", spanRoute: "/v1/skills")
        return try await client.requestPageResponse(PageCursor<Skill>.self, options, stream: _mode == .stream)
    }

    /// Delete Skill
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
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
    public func delete(_ skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> DeletedSkill {
        try await _delete(skillID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<DeletedSkill> {
        try requireNonEmpty(skillID, "skill_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/skills/{skill_id}", ["skill_id": skillID]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.skills.delete", spanRoute: "/v1/skills/{skill_id}", spanAttributes: ["anthropic.skill.id": skillID])
        return try await client.requestResponse(DeletedSkill.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: SkillsResource

        public var versions: SkillsVersionsResource.WithRawResponse { resource.versions.withRawResponse }

    /// Create Skill
    ///
    /// Args:
    ///   files: Files to upload for the skill.
    ///
    ///       All files must be in the same top-level directory and must include a SKILL.md
    ///       file at the root of that directory.
    ///
    ///   display_name: Human-readable, single-line label for the Skill. Maximum 255 characters. Always
    ///       set: derived from the SKILL.md frontmatter `name` when omitted at creation. Not
    ///       unique.
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
        public func create(files: [FileUpload], displayName: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Skill> {
            try await resource._create(files: files, displayName: displayName, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Get Skill
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
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
        public func retrieve(_ skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Skill> {
            try await resource._retrieve(skillID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List Skills
    ///
    /// Args:
    ///   limit: Number of results to return per page.
    ///
    ///       Ranges from `1` to `1000`. Defaults to `20`.
    ///
    ///   page: Pagination token for fetching a specific page of results.
    ///
    ///       Pass the value from a previous response's `next_page` field to get the next page
    ///       of results.
    ///
    ///   source: Filter skills by source.
    ///
    ///       If provided, only skills from the specified source will be returned:
    ///
    ///       - `"custom"`: only return user-created skills
    ///       - `"anthropic"`: only return Anthropic-created skills
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
        public func list(limit: Int? = nil, page: String?? = nil, source: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<Skill>> {
            try await resource._list(limit: limit, page: page, source: source, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete Skill
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
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
        public func delete(_ skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<DeletedSkill> {
            try await resource._delete(skillID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: SkillsResource

        public var versions: SkillsVersionsResource.WithStreamingResponse { resource.versions.withStreamingResponse }

    /// Create Skill
    ///
    /// Args:
    ///   files: Files to upload for the skill.
    ///
    ///       All files must be in the same top-level directory and must include a SKILL.md
    ///       file at the root of that directory.
    ///
    ///   display_name: Human-readable, single-line label for the Skill. Maximum 255 characters. Always
    ///       set: derived from the SKILL.md frontmatter `name` when omitted at creation. Not
    ///       unique.
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
        public func create<R: Sendable>(files: [FileUpload], displayName: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Skill>) async throws -> R) async throws -> R {
            let response = try await resource._create(files: files, displayName: displayName, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Get Skill
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
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
        public func retrieve<R: Sendable>(_ skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Skill>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(skillID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List Skills
    ///
    /// Args:
    ///   limit: Number of results to return per page.
    ///
    ///       Ranges from `1` to `1000`. Defaults to `20`.
    ///
    ///   page: Pagination token for fetching a specific page of results.
    ///
    ///       Pass the value from a previous response's `next_page` field to get the next page
    ///       of results.
    ///
    ///   source: Filter skills by source.
    ///
    ///       If provided, only skills from the specified source will be returned:
    ///
    ///       - `"custom"`: only return user-created skills
    ///       - `"anthropic"`: only return Anthropic-created skills
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
        public func list<R: Sendable>(limit: Int? = nil, page: String?? = nil, source: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<Skill>>) async throws -> R) async throws -> R {
            let response = try await resource._list(limit: limit, page: page, source: source, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete Skill
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
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
        public func delete<R: Sendable>(_ skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<DeletedSkill>) async throws -> R) async throws -> R {
            let response = try await resource._delete(skillID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
