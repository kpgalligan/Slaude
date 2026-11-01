// Transformed from `anthropic.types.beta.beta_thread_continue_params` (beta_thread_continue_params.py).

import Foundation

/// Resume from the response named by ``previous_message_id``.
public struct BetaThreadContinueParams: Codable, Hashable, Sendable {
    /// The `id` of the previous response in this Thread.
    public var previousMessageID: String
    public var type: String

    public init(previousMessageID: String, type: String = "continue") {
        self.previousMessageID = previousMessageID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case previousMessageID = "previous_message_id"
        case type
    }
}
