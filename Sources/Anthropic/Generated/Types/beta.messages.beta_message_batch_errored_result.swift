// Transformed from `anthropic.types.beta.messages.beta_message_batch_errored_result` (beta_message_batch_errored_result.py).

import Foundation

public struct BetaMessageBatchErroredResult: Codable, Hashable, Sendable {
    public var error: BetaErrorResponse
    public var type: String

    public init(error: BetaErrorResponse, type: String = "errored") {
        self.error = error
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case error
        case type
    }
}
