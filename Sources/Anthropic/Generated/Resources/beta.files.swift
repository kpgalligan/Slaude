// Transformed from `anthropic.resources.beta.files` (files.py).

import Foundation

public struct BetaFilesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// List Files
    ///
    /// Args:
    ///   ids: Restrict the result set to Files whose `id` is in this list. At most 100 entries
    ///       (after de-duplication). Mutually exclusive with `page` and `limit`. When
    ///       supplied, the response is always a single page (`next_page` is null). IDs that
    ///       do not resolve to a visible File — including deleted Files — are silently
    ///       omitted.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   page: Opaque page cursor returned in a prior list response's `next_page`. Prefixed
    ///       `page_`.
    ///
    ///   scope_id: Filter by scope ID. Only returns files associated with the specified scope
    ///       (e.g., a session ID).
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
    public func list(ids: [String]?? = nil, limit: Int? = nil, page: String?? = nil, scopeID: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaFileMetadata> {
        try await _list(ids: ids, limit: limit, page: page, scopeID: scopeID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(ids: [String]?? = nil, limit: Int? = nil, page: String?? = nil, scopeID: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaFileMetadata>> {
        var query = ParamsBuilder()
        try query.set("ids", ids)
        try query.set("limit", limit)
        try query.set("page", page)
        try query.set("scope_id", scopeID)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/files", query: query, headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.files.list", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaFileMetadata>.self, options, stream: _mode == .stream)
    }

    /// Delete File
    ///
    /// Args:
    ///   file_id: ID of the File.
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
    public func delete(_ fileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaDeletedFile {
        try await _delete(fileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ fileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaDeletedFile> {
        try requireNonEmpty(fileID, "file_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/files/{file_id}", ["file_id": fileID]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.files.delete", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaDeletedFile.self, options, stream: _mode == .stream)
    }

    /// Download File
    ///
    /// Args:
    ///   file_id: ID of the File.
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
    public func download(_ fileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BinaryResponse {
        try await _download(fileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _download(_ fileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BinaryResponse> {
        try requireNonEmpty(fileID, "file_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/files/{file_id}/content", ["file_id": fileID]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ",")), ("anthropic-workspace-id", workspaceID)]), mergeHeaderLayers(["Accept": "application/binary"], extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.files.download", qualifiers: ["beta": "true"])
        return try await client.requestBinaryResponse(options, stream: _mode == .stream)
    }

    /// Get File Metadata
    ///
    /// Args:
    ///   file_id: ID of the File.
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
    public func retrieveMetadata(_ fileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaFileMetadata {
        try await _retrieveMetadata(fileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieveMetadata(_ fileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaFileMetadata> {
        try requireNonEmpty(fileID, "file_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/files/{file_id}", ["file_id": fileID]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.files.retrieve_metadata", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaFileMetadata.self, options, stream: _mode == .stream)
    }

    /// Upload File
    ///
    /// Args:
    ///   file: The file to upload.
    ///
    /// Only the final path component of the part's `filename` is
    ///       kept; an absent or empty `filename` is replaced with `unnamed` plus the
    ///       extension for the file's stored `mime_type`, when known.
    ///
    ///   expires_in_seconds: Seconds from upload until the file expires and its bytes become permanently
    ///       unavailable. Must be between 3600 (one hour) and 7776000 (ninety days).
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
    public func upload(file: FileUpload, expiresInSeconds: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaFileMetadata {
        try await _upload(file: file, expiresInSeconds: expiresInSeconds, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _upload(file: FileUpload, expiresInSeconds: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaFileMetadata> {
        var body = ParamsBuilder()
        body.setFile("file", file)
        try body.set("expires_in_seconds", expiresInSeconds)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/files", body: body, headers: mergeHeaderLayers(["Content-Type": "multipart/form-data"], mergeHeaderLayers(["Content-Type": "multipart/form-data"], mergeHeaders(mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)))), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.files.upload", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaFileMetadata.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaFilesResource

    /// List Files
    ///
    /// Args:
    ///   ids: Restrict the result set to Files whose `id` is in this list. At most 100 entries
    ///       (after de-duplication). Mutually exclusive with `page` and `limit`. When
    ///       supplied, the response is always a single page (`next_page` is null). IDs that
    ///       do not resolve to a visible File — including deleted Files — are silently
    ///       omitted.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   page: Opaque page cursor returned in a prior list response's `next_page`. Prefixed
    ///       `page_`.
    ///
    ///   scope_id: Filter by scope ID. Only returns files associated with the specified scope
    ///       (e.g., a session ID).
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
        public func list(ids: [String]?? = nil, limit: Int? = nil, page: String?? = nil, scopeID: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaFileMetadata>> {
            try await resource._list(ids: ids, limit: limit, page: page, scopeID: scopeID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete File
    ///
    /// Args:
    ///   file_id: ID of the File.
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
        public func delete(_ fileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaDeletedFile> {
            try await resource._delete(fileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Download File
    ///
    /// Args:
    ///   file_id: ID of the File.
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
        public func download(_ fileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BinaryResponse> {
            try await resource._download(fileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Get File Metadata
    ///
    /// Args:
    ///   file_id: ID of the File.
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
        public func retrieveMetadata(_ fileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaFileMetadata> {
            try await resource._retrieveMetadata(fileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Upload File
    ///
    /// Args:
    ///   file: The file to upload.
    ///
    /// Only the final path component of the part's `filename` is
    ///       kept; an absent or empty `filename` is replaced with `unnamed` plus the
    ///       extension for the file's stored `mime_type`, when known.
    ///
    ///   expires_in_seconds: Seconds from upload until the file expires and its bytes become permanently
    ///       unavailable. Must be between 3600 (one hour) and 7776000 (ninety days).
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
        public func upload(file: FileUpload, expiresInSeconds: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaFileMetadata> {
            try await resource._upload(file: file, expiresInSeconds: expiresInSeconds, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaFilesResource

    /// List Files
    ///
    /// Args:
    ///   ids: Restrict the result set to Files whose `id` is in this list. At most 100 entries
    ///       (after de-duplication). Mutually exclusive with `page` and `limit`. When
    ///       supplied, the response is always a single page (`next_page` is null). IDs that
    ///       do not resolve to a visible File — including deleted Files — are silently
    ///       omitted.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   page: Opaque page cursor returned in a prior list response's `next_page`. Prefixed
    ///       `page_`.
    ///
    ///   scope_id: Filter by scope ID. Only returns files associated with the specified scope
    ///       (e.g., a session ID).
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
        public func list<R: Sendable>(ids: [String]?? = nil, limit: Int? = nil, page: String?? = nil, scopeID: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaFileMetadata>>) async throws -> R) async throws -> R {
            let response = try await resource._list(ids: ids, limit: limit, page: page, scopeID: scopeID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete File
    ///
    /// Args:
    ///   file_id: ID of the File.
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
        public func delete<R: Sendable>(_ fileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaDeletedFile>) async throws -> R) async throws -> R {
            let response = try await resource._delete(fileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Download File
    ///
    /// Args:
    ///   file_id: ID of the File.
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
        public func download<R: Sendable>(_ fileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BinaryResponse>) async throws -> R) async throws -> R {
            let response = try await resource._download(fileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Get File Metadata
    ///
    /// Args:
    ///   file_id: ID of the File.
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
        public func retrieveMetadata<R: Sendable>(_ fileID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaFileMetadata>) async throws -> R) async throws -> R {
            let response = try await resource._retrieveMetadata(fileID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Upload File
    ///
    /// Args:
    ///   file: The file to upload.
    ///
    /// Only the final path component of the part's `filename` is
    ///       kept; an absent or empty `filename` is replaced with `unnamed` plus the
    ///       extension for the file's stored `mime_type`, when known.
    ///
    ///   expires_in_seconds: Seconds from upload until the file expires and its bytes become permanently
    ///       unavailable. Must be between 3600 (one hour) and 7776000 (ninety days).
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
        public func upload<R: Sendable>(file: FileUpload, expiresInSeconds: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaFileMetadata>) async throws -> R) async throws -> R {
            let response = try await resource._upload(file: file, expiresInSeconds: expiresInSeconds, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
