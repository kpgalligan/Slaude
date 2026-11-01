// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_refresh_http_response` (beta_managed_agents_refresh_http_response.py).

import Foundation

/// An HTTP response captured during a credential validation probe.
public struct BetaManagedAgentsRefreshHTTPResponse: Codable, Hashable, Sendable {
    /// Response body. May be truncated and has sensitive values scrubbed.
    public var body: String
    /// Whether `body` was truncated.
    public var bodyTruncated: Bool
    /// Value of the `Content-Type` response header.
    public var contentType: String
    /// HTTP status code.
    public var statusCode: Int

    public init(body: String, bodyTruncated: Bool, contentType: String, statusCode: Int) {
        self.body = body
        self.bodyTruncated = bodyTruncated
        self.contentType = contentType
        self.statusCode = statusCode
    }

    enum CodingKeys: String, CodingKey {
        case body
        case bodyTruncated = "body_truncated"
        case contentType = "content_type"
        case statusCode = "status_code"
    }
}
