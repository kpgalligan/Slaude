// Transformed from `anthropic.types.messages.message_batch_errored_result` (message_batch_errored_result.py).

import Foundation

public struct MessageBatchErroredResult: Codable, Hashable, Sendable {
    public var error: ErrorResponse
    public var type: String

    public init(error: ErrorResponse, type: String = "errored") {
        self.error = error
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case error
        case type
    }
}
