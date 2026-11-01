// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_span_model_request_end_event` (beta_managed_agents_span_model_request_end_event.py).

import Foundation

/// Emitted when a model request completes.
public struct BetaManagedAgentsSpanModelRequestEndEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Whether the model request resulted in an error.
    public var isError: Bool?
    /// The id of the corresponding `span.model_request_start` event.
    public var modelRequestStartId: String
    /// Token usage for this model request.
    public var modelUsage: BetaManagedAgentsSpanModelUsage
    /// Timestamp when the model request completed.
    public var processedAt: Date
    public var type: String

    public init(id: String, isError: Bool? = nil, modelRequestStartId: String, modelUsage: BetaManagedAgentsSpanModelUsage, processedAt: Date, type: String = "span.model_request_end") {
        self.id = id
        self.isError = isError
        self.modelRequestStartId = modelRequestStartId
        self.modelUsage = modelUsage
        self.processedAt = processedAt
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case isError = "is_error"
        case modelRequestStartId = "model_request_start_id"
        case modelUsage = "model_usage"
        case processedAt = "processed_at"
        case type
    }
}
