// Transformed from `anthropic.resources.skills.versions` (versions.py).

import Foundation

public struct SkillsVersionsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Create Skill Version
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
    ///
    ///   files: Files to upload for the skill.
    ///
    ///       All files must be in the same top-level directory and must include a SKILL.md
    ///       file at the root of that directory.
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
    public func create(_ skillID: String, files: [FileUpload], workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> SkillVersion {
        try await _create(skillID, files: files, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(_ skillID: String, files: [FileUpload], workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<SkillVersion> {
        try requireNonEmpty(skillID, "skill_id")
        var body = ParamsBuilder()
        body.setFiles("files", files)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/skills/{skill_id}/versions", ["skill_id": skillID]), body: body, headers: mergeHeaderLayers(["Content-Type": "multipart/form-data"], mergeHeaderLayers(["Content-Type": "multipart/form-data"], mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders))), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.skills.versions.create", spanRoute: "/v1/skills/{skill_id}/versions", spanAttributes: ["anthropic.skill.id": skillID], spanCreatedID: SpanCreatedID("anthropic.skill.version.id"))
        return try await client.requestResponse(SkillVersion.self, options, stream: _mode == .stream)
    }

    /// Get Skill Version
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
    ///
    ///   version: Identifies the skill version: a version ID, or the literal `latest` for the
    ///       skill's most recent version.
    ///
    ///       Requests carrying the `skills-2025-10-02` beta header address versions by their
    ///       Unix epoch timestamp instead (e.g., "1759178010641129").
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
    public func retrieve(_ version: String, skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> SkillVersion {
        try await _retrieve(version, skillID: skillID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ version: String, skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<SkillVersion> {
        try requireNonEmpty(skillID, "skill_id")
        try requireNonEmpty(version, "version")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/skills/{skill_id}/versions/{version}", ["skill_id": skillID, "version": version]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.skills.versions.retrieve", spanRoute: "/v1/skills/{skill_id}/versions/{version}", spanAttributes: ["anthropic.skill.id": skillID, "anthropic.skill.version.id": version])
        return try await client.requestResponse(SkillVersion.self, options, stream: _mode == .stream)
    }

    /// List Skill Versions
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
    ///
    ///   limit: Number of results to return per page.
    ///
    ///       Ranges from `1` to `1000`. Defaults to `20`.
    ///
    ///   page: Optionally set to the `next_page` token from the previous response.
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
    public func list(_ skillID: String, limit: Int?? = nil, page: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<SkillVersion> {
        try await _list(skillID, limit: limit, page: page, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ skillID: String, limit: Int?? = nil, page: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<SkillVersion>> {
        try requireNonEmpty(skillID, "skill_id")
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/skills/{skill_id}/versions", ["skill_id": skillID]), query: query, headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.skills.versions.list", spanRoute: "/v1/skills/{skill_id}/versions", spanAttributes: ["anthropic.skill.id": skillID])
        return try await client.requestPageResponse(PageCursor<SkillVersion>.self, options, stream: _mode == .stream)
    }

    /// Delete Skill Version
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
    ///
    ///   version: Identifies the skill version by its version ID.
    ///
    ///       Requests carrying the `skills-2025-10-02` beta header address versions by their
    ///       Unix epoch timestamp instead (e.g., "1759178010641129").
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
    public func delete(_ version: String, skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> DeletedSkillVersion {
        try await _delete(version, skillID: skillID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ version: String, skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<DeletedSkillVersion> {
        try requireNonEmpty(skillID, "skill_id")
        try requireNonEmpty(version, "version")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/skills/{skill_id}/versions/{version}", ["skill_id": skillID, "version": version]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.skills.versions.delete", spanRoute: "/v1/skills/{skill_id}/versions/{version}", spanAttributes: ["anthropic.skill.id": skillID, "anthropic.skill.version.id": version])
        return try await client.requestResponse(DeletedSkillVersion.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: SkillsVersionsResource

    /// Create Skill Version
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
    ///
    ///   files: Files to upload for the skill.
    ///
    ///       All files must be in the same top-level directory and must include a SKILL.md
    ///       file at the root of that directory.
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
        public func create(_ skillID: String, files: [FileUpload], workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<SkillVersion> {
            try await resource._create(skillID, files: files, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Get Skill Version
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
    ///
    ///   version: Identifies the skill version: a version ID, or the literal `latest` for the
    ///       skill's most recent version.
    ///
    ///       Requests carrying the `skills-2025-10-02` beta header address versions by their
    ///       Unix epoch timestamp instead (e.g., "1759178010641129").
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
        public func retrieve(_ version: String, skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<SkillVersion> {
            try await resource._retrieve(version, skillID: skillID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List Skill Versions
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
    ///
    ///   limit: Number of results to return per page.
    ///
    ///       Ranges from `1` to `1000`. Defaults to `20`.
    ///
    ///   page: Optionally set to the `next_page` token from the previous response.
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
        public func list(_ skillID: String, limit: Int?? = nil, page: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<SkillVersion>> {
            try await resource._list(skillID, limit: limit, page: page, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete Skill Version
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
    ///
    ///   version: Identifies the skill version by its version ID.
    ///
    ///       Requests carrying the `skills-2025-10-02` beta header address versions by their
    ///       Unix epoch timestamp instead (e.g., "1759178010641129").
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
        public func delete(_ version: String, skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<DeletedSkillVersion> {
            try await resource._delete(version, skillID: skillID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: SkillsVersionsResource

    /// Create Skill Version
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
    ///
    ///   files: Files to upload for the skill.
    ///
    ///       All files must be in the same top-level directory and must include a SKILL.md
    ///       file at the root of that directory.
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
        public func create<R: Sendable>(_ skillID: String, files: [FileUpload], workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<SkillVersion>) async throws -> R) async throws -> R {
            let response = try await resource._create(skillID, files: files, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Get Skill Version
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
    ///
    ///   version: Identifies the skill version: a version ID, or the literal `latest` for the
    ///       skill's most recent version.
    ///
    ///       Requests carrying the `skills-2025-10-02` beta header address versions by their
    ///       Unix epoch timestamp instead (e.g., "1759178010641129").
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
        public func retrieve<R: Sendable>(_ version: String, skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<SkillVersion>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(version, skillID: skillID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List Skill Versions
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
    ///
    ///   limit: Number of results to return per page.
    ///
    ///       Ranges from `1` to `1000`. Defaults to `20`.
    ///
    ///   page: Optionally set to the `next_page` token from the previous response.
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
        public func list<R: Sendable>(_ skillID: String, limit: Int?? = nil, page: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<SkillVersion>>) async throws -> R) async throws -> R {
            let response = try await resource._list(skillID, limit: limit, page: page, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete Skill Version
    ///
    /// Args:
    ///   skill_id: Unique identifier for the skill.
    ///
    ///       The format and length of IDs may change over time.
    ///
    ///   version: Identifies the skill version by its version ID.
    ///
    ///       Requests carrying the `skills-2025-10-02` beta header address versions by their
    ///       Unix epoch timestamp instead (e.g., "1759178010641129").
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
        public func delete<R: Sendable>(_ version: String, skillID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<DeletedSkillVersion>) async throws -> R) async throws -> R {
            let response = try await resource._delete(version, skillID: skillID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
