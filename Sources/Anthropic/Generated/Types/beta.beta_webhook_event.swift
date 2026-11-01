// Transformed from `anthropic.types.beta.beta_webhook_event` (beta_webhook_event.py).

import Foundation

public struct BetaWebhookEvent: Codable, Hashable, Sendable {
    /// Unique event identifier for idempotency.
    public var id: String
    /// RFC 3339 timestamp when the event occurred.
    public var createdAt: Date
    public var data: BetaWebhookEventData
    /// Object type. Always `event` for webhook payloads.
    public var type: String

    public init(id: String, createdAt: Date, data: BetaWebhookEventData, type: String = "event") {
        self.id = id
        self.createdAt = createdAt
        self.data = data
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case data
        case type
    }
}
