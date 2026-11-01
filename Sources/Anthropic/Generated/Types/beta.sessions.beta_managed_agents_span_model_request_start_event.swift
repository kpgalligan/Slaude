// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_span_model_request_start_event` (beta_managed_agents_span_model_request_start_event.py).

import Foundation

/// Emitted when a model request is initiated by the agent.
public struct BetaManagedAgentsSpanModelRequestStartEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Timestamp when the model request started.
    public var processedAt: Date
    public var type: String

    public init(id: String, processedAt: Date, type: String = "span.model_request_start") {
        self.id = id
        self.processedAt = processedAt
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case processedAt = "processed_at"
        case type
    }
}
