// Transformed from `anthropic.types.beta.beta_dream_sessions_input` (beta_dream_sessions_input.py).

import Foundation

/// The sessions that a dream reads, given as an entry in `inputs`.
public struct BetaDreamSessionsInput: Codable, Hashable, Sendable {
    /// The IDs of the sessions whose transcripts the dream reads (`sesn_...`).
    ///
    /// Give 1 to 100 IDs, with no duplicates. Each session must be in the same
    /// workspace as the dream. Responses list the IDs in sorted order.
    ///
    /// The
    /// [limits table in the Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#limits)
    /// lists all the limits on a dream.
    public var sessionIds: [String]
    public var type: String

    public init(sessionIds: [String], type: String = "sessions") {
        self.sessionIds = sessionIds
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case sessionIds = "session_ids"
        case type
    }
}
