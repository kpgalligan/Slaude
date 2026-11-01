// Transformed from `anthropic.types.beta.beta_managed_agents_delta_event` (beta_managed_agents_delta_event.py).

import Foundation

/// An incremental update to an event that is still being streamed.
///
/// Deltas are best-effort and may stop early; when the buffered event with id == event_id is produced it carries the complete content. A model request that ends early (an error or interrupt) produces no buffered event — its terminal span.model_request_end closes the preview. Only sent on stream connections that opt in via event_deltas; never appears in event history.
public struct BetaManagedAgentsDeltaEvent: Codable, Hashable, Sendable {
    /// One fragment of the previewed event.
    ///
    /// The delta type is named for the previewed event's field it streams into:
    /// agent.message events stream content_delta fragments, each a partial element of
    /// the content array.
    public var delta: BetaManagedAgentsDeltaContent
    /// The id of the event being previewed.
    ///
    /// Matches event.id on the corresponding event_start and the buffered event that
    /// reconciles the preview.
    public var eventId: String
    public var type: String

    public init(delta: BetaManagedAgentsDeltaContent, eventId: String, type: String = "event_delta") {
        self.delta = delta
        self.eventId = eventId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case delta
        case eventId = "event_id"
        case type
    }
}
