// Transformed from `anthropic.types.beta.memory_stores.beta_managed_agents_session_actor` (beta_managed_agents_session_actor.py).

import Foundation

/// An agent acting during a session, for example through the session's mounted filesystem. It names the session itself, not the user or API key that started the session.
public struct BetaManagedAgentsSessionActor: Codable, Hashable, Sendable {
    /// ID of the session (a `sesn_...` value).
    ///
    /// Look up the session via [Retrieve a session](/en/api/beta/sessions/retrieve) for
    /// further provenance.
    public var sessionId: String
    public var type: String

    public init(sessionId: String, type: String = "session_actor") {
        self.sessionId = sessionId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case type
    }
}
