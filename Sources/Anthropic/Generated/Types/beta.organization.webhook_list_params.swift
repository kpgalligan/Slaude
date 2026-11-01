// Transformed from `anthropic.types.beta.organization.webhook_list_params` (webhook_list_params.py).

import Foundation

public struct WebhookListParams: Codable, Hashable, Sendable {
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately after this object.
    public var afterID: String??
    /// ID of a webhook endpoint to use as a cursor.
    ///
    /// Returns the first `limit` endpoints that come before it in list order, not the
    /// `limit` endpoints just before it.
    public var beforeID: String??
    /// Number of items to return per page, up to `100`. The default, `0`, means `20`.
    public var limit: Int?
    /// Sort order by `created_at`. Defaults to `desc`, newest first.
    public var order: Order??
    /// This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    /// header.
    public var betas: [AnthropicBetaParam]?

    public init(afterID: String?? = nil, beforeID: String?? = nil, limit: Int? = nil, order: Order?? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.afterID = afterID
        self.beforeID = beforeID
        self.limit = limit
        self.order = order
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case afterID = "after_id"
        case beforeID = "before_id"
        case limit
        case order
        case betas
    }

    public enum Order: OpenEnum, CaseIterable {
        case asc
        case desc
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Order] = [.asc, .desc]

        public init(rawValue: String) {
            switch rawValue {
            case "asc": self = .asc
            case "desc": self = .desc
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .asc: return "asc"
            case .desc: return "desc"
            case .unknown(let value): return value
            }
        }
    }
}
