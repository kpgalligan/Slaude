// Transformed from `anthropic.types.beta.beta_file_metadata` (beta_file_metadata.py).

import Foundation

public struct BetaFileMetadata: Codable, Hashable, Sendable {
    /// Unique object identifier.
    ///
    /// The format and length of IDs may change over time.
    public var id: String
    /// RFC 3339 datetime string representing when the file was created.
    public var createdAt: Date
    /// Original filename of the uploaded file.
    public var filename: String
    /// MIME type of the file.
    public var mimeType: String
    /// Size of the file in bytes.
    public var sizeBytes: Int
    /// Object type.
    ///
    /// For files, this is always `"file"`.
    public var type: String
    /// Whether the file can be downloaded.
    public var downloadable: Bool?
    /// RFC 3339 datetime string representing when the file will expire and become
    /// unavailable for download. Null if the file does not expire. For files uploaded
    /// with `expires_in_seconds`, this is the upload time plus that value.
    public var expiresAt: Date?
    /// The scope of this file, indicating the context in which it was created (e.g., a
    /// session).
    public var scope: BetaFileScope?

    public init(id: String, createdAt: Date, filename: String, mimeType: String, sizeBytes: Int, type: String = "file", downloadable: Bool? = nil, expiresAt: Date? = nil, scope: BetaFileScope? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.filename = filename
        self.mimeType = mimeType
        self.sizeBytes = sizeBytes
        self.type = type
        self.downloadable = downloadable
        self.expiresAt = expiresAt
        self.scope = scope
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case filename
        case mimeType = "mime_type"
        case sizeBytes = "size_bytes"
        case type
        case downloadable
        case expiresAt = "expires_at"
        case scope
    }
}
