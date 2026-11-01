// Transformed from `anthropic.types.beta.beta_managed_agents_session_updated_event` (beta_managed_agents_session_updated_event.py).

import Foundation

/// Emitted when an UpdateSession request changed at least one field.
///
/// Carries only the fields that changed; absent fields were not part of the update. The new configuration applies from the next turn.
public struct BetaManagedAgentsSessionUpdatedEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Timestamp when the update was applied.
    public var processedAt: Date
    public var type: String
    /// The session's effective agent configuration after the update.
    ///
    /// Present only when the update changed `agent` (tools or mcp_servers); when
    /// present it is the full materialised snapshot, not a diff.
    public var agent: BetaManagedAgentsSessionAgent?
    /// The session's budget after the update: the new budget when set or replaced, or
    /// null when the update removed it. Present only when the update changed the
    /// budget.
    public var budget: BetaManagedAgentsBudgetLimit?
    /// The session's full metadata bag after the update.
    ///
    /// Present when the update set non-empty metadata; absent when metadata was
    /// unchanged or cleared to empty.
    public var metadata: [String: String]?
    /// The session's new title. Present only when the update changed it.
    public var title: String?

    public init(id: String, processedAt: Date, type: String = "session.updated", agent: BetaManagedAgentsSessionAgent? = nil, budget: BetaManagedAgentsBudgetLimit? = nil, metadata: [String: String]? = nil, title: String? = nil) {
        self.id = id
        self.processedAt = processedAt
        self.type = type
        self.agent = agent
        self.budget = budget
        self.metadata = metadata
        self.title = title
    }

    enum CodingKeys: String, CodingKey {
        case id
        case processedAt = "processed_at"
        case type
        case agent
        case budget
        case metadata
        case title
    }
}
