// Port of `anthropic/lib/sessions/_accumulate.py` (`AccumulatedEvent`, `accumulate_managed_agents_event`).

import Foundation

/// The `agent.message` snapshot that `accumulateManagedAgentsEvent` builds from a session's preview events.
public typealias AccumulatedEvent = BetaManagedAgentsAgentMessageEvent

/// Placeholder `processed_at` (the Unix epoch) for a preview snapshot until the buffered final event, which carries
/// the real timestamp, replaces it.
let accumulateUnprocessed = Date(timeIntervalSince1970: 0)

/// Fold one preview event into an `agent.message` snapshot and return the new snapshot.
///
/// - `event_start` opens the preview: a new snapshot with empty content is returned (so `accumulated` may be `nil`).
///   Its `processedAt` is an epoch placeholder that the buffered final event's server timestamp replaces.
///   `accumulated` is passed through unchanged when the previewed event is not an `agent.message`: this helper only
///   tracks `agent.message` previews.
/// - `event_delta` is folded into `accumulated`: a new `delta.index` inserts the fragment as a fresh content entry; an
///   existing index returns a copy with that entry appended to. An unrecognised fragment type on an existing index
///   leaves the entry unchanged: deltas are best-effort and the buffered final event is canonical.
/// - `agent.message` is the buffered final event: it is returned, replacing whatever the preview had accumulated.
/// - Any other event, including types this SDK version does not know about, passes `accumulated` through unchanged.
///
/// Swift values are copied, so `accumulated` and `event` are never changed.
public func accumulateManagedAgentsEvent(_ accumulated: AccumulatedEvent?,
                                         _ event: BetaManagedAgentsStreamSessionEvents) throws -> AccumulatedEvent?
{
    switch event {
    case .eventStart(let start):
        return accumulateManagedAgentsEvent(accumulated, start)
    case .agentMessage(let message):
        return message
    case .eventDelta(let delta):
        return try accumulateManagedAgentsEvent(accumulated, delta)
    default:
        // Any other event, including types newer than this SDK, leaves the snapshot unchanged.
        return accumulated
    }
}

/// The buffered final `agent.message` event replaces the preview.
public func accumulateManagedAgentsEvent(_ accumulated: AccumulatedEvent?,
                                         _ event: BetaManagedAgentsAgentMessageEvent) -> BetaManagedAgentsAgentMessageEvent
{
    event
}

/// `event_start`: a fresh snapshot for an `agent.message` preview, `accumulated` for any other.
public func accumulateManagedAgentsEvent(_ accumulated: AccumulatedEvent?, _ event: BetaManagedAgentsStartEvent) -> AccumulatedEvent? {
    if case .agentMessage(let preview) = event.event {
        return BetaManagedAgentsAgentMessageEvent(id: preview.id, content: [], processedAt: accumulateUnprocessed, type: "agent.message")
    }
    // This helper only tracks agent.message previews; agent.thinking previews are start-only and have no deltas to
    // fold, and unrecognised preview types pass through unchanged.
    return accumulated
}

/// `event_delta`: the fragment folded into `accumulated`.
public func accumulateManagedAgentsEvent(_ accumulated: AccumulatedEvent?, _ event: BetaManagedAgentsDeltaEvent) throws -> AccumulatedEvent {
    guard var snapshot = accumulated else {
        throw AnthropicError("event_delta for \(event.eventID) received before its event_start")
    }
    let index = event.delta.index ?? 0
    let fragment = event.delta.content
    // Indices arrive in order: the first delta at a new index opens the slot. A gap means deltas arrived out of
    // order or were mis-routed.
    if index > snapshot.content.count || index < 0 {
        throw AnthropicError("event_delta index \(index) is beyond the end of content (length \(snapshot.content.count))")
    }
    if index == snapshot.content.count {
        // New index: pass the fragment through as a fresh block.
        snapshot.content.append(fragment.type == "text" ? .text(fragment) : .unknown((try? JSONValue.from(fragment)) ?? .null))
    } else if fragment.type == "text", case .text(var existing) = snapshot.content[index], existing.type == "text" {
        existing.text += fragment.text
        snapshot.content[index] = .text(existing)
    }
    return snapshot
}
