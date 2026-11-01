// Transformed from `anthropic.types.beta.messages.beta_message_batch_individual_response` (beta_message_batch_individual_response.py).

import Foundation

/// This is a single line in the response `.jsonl` file and does not represent the response as a whole.
public struct BetaMessageBatchIndividualResponse: Codable, Hashable, Sendable {
    /// Developer-provided ID created for each request in a Message Batch.
    ///
    /// Useful for matching results to requests, as results may be given out of request
    /// order.
    ///
    /// Must be unique for each request within the Message Batch.
    public var customID: String
    /// Processing result for this request.
    ///
    /// Contains a Message output if processing was successful, an error response if
    /// processing failed, or the reason why processing was not attempted, such as
    /// cancellation or expiration.
    public var result: BetaMessageBatchResult

    public init(customID: String, result: BetaMessageBatchResult) {
        self.customID = customID
        self.result = result
    }

    enum CodingKeys: String, CodingKey {
        case customID = "custom_id"
        case result
    }
}
