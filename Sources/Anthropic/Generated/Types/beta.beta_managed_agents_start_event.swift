// Transformed from `anthropic.types.beta.beta_managed_agents_start_event` (beta_managed_agents_start_event.py).

import Foundation

/// Opens a preview of a buffered event.
///
/// Carries the previewed event's type and id only. Followed by zero or more event_delta events with the same event id, normally concluded by the buffered event carrying that id. If the producing model request ends without that event (an error or interrupt mid-stream), its terminal span.model_request_end closes the preview. Only sent on stream connections that opt in via event_deltas; never appears in event history.
public struct BetaManagedAgentsStartEvent: Codable, Hashable, Sendable {
    /// The previewed event's type and id.
    ///
    /// The event type determines which delta types the preview's event_delta events
    /// carry: agent.message events stream content_delta fragments; agent.thinking
    /// previews are start-only — no deltas follow, and the buffered agent.thinking with
    /// the same id concludes them.
    public var event: BetaManagedAgentsStartEventPreview
    public var type: String

    public init(event: BetaManagedAgentsStartEventPreview, type: String = "event_start") {
        self.event = event
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case event
        case type
    }
}
