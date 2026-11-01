// Transformed from `anthropic.resources.files` (files.py).

import Foundation

public struct FilesResource: Sendable {
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
    public func list(ids: [String]?? = nil, limit: Int? = nil, page: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<FileMetadata> {
        try await _list(ids: ids, limit: limit, page: page, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(ids: [String]?? = nil, limit: Int? = nil, page: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<FileMetadata>> {
        var query = ParamsBuilder()
        try query.set("ids", ids)
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/files", query: query, headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.files.list", spanRoute: "/v1/files")
        return try await client.requestPageResponse(PageCursor<FileMetadata>.self, options, stream: _mode == .stream)
    }

    /// Delete File
    ///
    /// Args:
    ///   file_id: ID of the File.
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
    public func delete(_ fileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> DeletedFile {
        try await _delete(fileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ fileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<DeletedFile> {
        try requireNonEmpty(fileID, "file_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/files/{file_id}", ["file_id": fileID]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.files.delete", spanRoute: "/v1/files/{file_id}", spanAttributes: ["anthropic.file.id": fileID])
        return try await client.requestResponse(DeletedFile.self, options, stream: _mode == .stream)
    }

    /// Download File
    ///
    /// Args:
    ///   file_id: ID of the File.
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
    public func download(_ fileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BinaryResponse {
        try await _download(fileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _download(_ fileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BinaryResponse> {
        try requireNonEmpty(fileID, "file_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/files/{file_id}/content", ["file_id": fileID]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), mergeHeaderLayers(["Accept": "application/binary"], extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.files.download", spanRoute: "/v1/files/{file_id}/content", spanAttributes: ["anthropic.file.id": fileID])
        return try await client.requestBinaryResponse(options, stream: _mode == .stream)
    }

    /// Get File Metadata
    ///
    /// Args:
    ///   file_id: ID of the File.
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
    public func retrieveMetadata(_ fileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> FileMetadata {
        try await _retrieveMetadata(fileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieveMetadata(_ fileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<FileMetadata> {
        try requireNonEmpty(fileID, "file_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/files/{file_id}", ["file_id": fileID]), headers: mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.files.retrieve_metadata", spanRoute: "/v1/files/{file_id}", spanAttributes: ["anthropic.file.id": fileID])
        return try await client.requestResponse(FileMetadata.self, options, stream: _mode == .stream)
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
    public func upload(file: FileUpload, expiresInSeconds: Int? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> FileMetadata {
        try await _upload(file: file, expiresInSeconds: expiresInSeconds, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _upload(file: FileUpload, expiresInSeconds: Int? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<FileMetadata> {
        var body = ParamsBuilder()
        body.setFile("file", file)
        try body.set("expires_in_seconds", expiresInSeconds)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/files", body: body, headers: mergeHeaderLayers(["Content-Type": "multipart/form-data"], mergeHeaderLayers(["Content-Type": "multipart/form-data"], mergeHeaders(mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), extraHeaders)))), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.files.upload", spanRoute: "/v1/files", spanCreatedID: SpanCreatedID("anthropic.file.id"))
        return try await client.requestResponse(FileMetadata.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: FilesResource

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
        public func list(ids: [String]?? = nil, limit: Int? = nil, page: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<FileMetadata>> {
            try await resource._list(ids: ids, limit: limit, page: page, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete File
    ///
    /// Args:
    ///   file_id: ID of the File.
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
        public func delete(_ fileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<DeletedFile> {
            try await resource._delete(fileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Download File
    ///
    /// Args:
    ///   file_id: ID of the File.
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
        public func download(_ fileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BinaryResponse> {
            try await resource._download(fileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Get File Metadata
    ///
    /// Args:
    ///   file_id: ID of the File.
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
        public func retrieveMetadata(_ fileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<FileMetadata> {
            try await resource._retrieveMetadata(fileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
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
        public func upload(file: FileUpload, expiresInSeconds: Int? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<FileMetadata> {
            try await resource._upload(file: file, expiresInSeconds: expiresInSeconds, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: FilesResource

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
        public func list<R: Sendable>(ids: [String]?? = nil, limit: Int? = nil, page: String?? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<FileMetadata>>) async throws -> R) async throws -> R {
            let response = try await resource._list(ids: ids, limit: limit, page: page, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete File
    ///
    /// Args:
    ///   file_id: ID of the File.
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
        public func delete<R: Sendable>(_ fileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<DeletedFile>) async throws -> R) async throws -> R {
            let response = try await resource._delete(fileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Download File
    ///
    /// Args:
    ///   file_id: ID of the File.
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
        public func download<R: Sendable>(_ fileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BinaryResponse>) async throws -> R) async throws -> R {
            let response = try await resource._download(fileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Get File Metadata
    ///
    /// Args:
    ///   file_id: ID of the File.
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
        public func retrieveMetadata<R: Sendable>(_ fileID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<FileMetadata>) async throws -> R) async throws -> R {
            let response = try await resource._retrieveMetadata(fileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
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
        public func upload<R: Sendable>(file: FileUpload, expiresInSeconds: Int? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<FileMetadata>) async throws -> R) async throws -> R {
            let response = try await resource._upload(file: file, expiresInSeconds: expiresInSeconds, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
