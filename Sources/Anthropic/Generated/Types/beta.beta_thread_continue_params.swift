// Transformed from `anthropic.types.beta.beta_thread_continue_params` (beta_thread_continue_params.py).

import Foundation

/// Resume from the response named by ``previous_message_id``.
public struct BetaThreadContinueParams: Codable, Hashable, Sendable {
    /// The `id` of the previous response in this Thread.
    public var previousMessageId: String
    public var type: String

    public init(previousMessageId: String, type: String = "continue") {
        self.previousMessageId = previousMessageId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case previousMessageId = "previous_message_id"
        case type
    }
}
