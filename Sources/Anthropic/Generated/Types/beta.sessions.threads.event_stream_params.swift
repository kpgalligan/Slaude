// Transformed from `anthropic.types.beta.sessions.threads.event_stream_params` (event_stream_params.py).

import Foundation

public struct BetaSessionsThreadsEventStreamParams: Codable, Hashable, Sendable {
    public var sessionId: String
    /// When set, this connection also receives streaming deltas (`event_start`,
    /// `event_delta`) while an event is being produced, before the event itself
    /// arrives. Deltas are best-effort; when the final event is produced it carries the
    /// complete content. A model request that ends early (an error or interrupt)
    /// produces no final event — its terminal `span.model_request_end` closes the
    /// preview. Accepts one or more event types to preview and may be repeated:
    /// `agent.message` streams `content_delta` fragments; `agent.thinking` is
    /// start-only — a signal that the agent has begun extended thinking, concluded by
    /// the `agent.thinking` event itself. Only previews of the requested event types
    /// are sent.
    public var eventDeltas: [BetaManagedAgentsDeltaType]?
    /// This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceId: String?

    public init(sessionId: String, eventDeltas: [BetaManagedAgentsDeltaType]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.sessionId = sessionId
        self.eventDeltas = eventDeltas
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case eventDeltas = "event_deltas"
        case betas
        case workspaceId = "workspace_id"
    }
}
