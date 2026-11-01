// Transformed from `anthropic.types.beta.messages.beta_message_batch_request_counts` (beta_message_batch_request_counts.py).

import Foundation

public struct BetaMessageBatchRequestCounts: Codable, Hashable, Sendable {
    /// Number of requests in the Message Batch that have been canceled.
    ///
    /// This is zero until processing of the entire Message Batch has ended.
    public var canceled: Int
    /// Number of requests in the Message Batch that encountered an error.
    ///
    /// This is zero until processing of the entire Message Batch has ended.
    public var errored: Int
    /// Number of requests in the Message Batch that have expired.
    ///
    /// This is zero until processing of the entire Message Batch has ended.
    public var expired: Int
    /// Number of requests in the Message Batch that are processing.
    public var processing: Int
    /// Number of requests in the Message Batch that have completed successfully.
    ///
    /// This is zero until processing of the entire Message Batch has ended.
    public var succeeded: Int

    public init(canceled: Int, errored: Int, expired: Int, processing: Int, succeeded: Int) {
        self.canceled = canceled
        self.errored = errored
        self.expired = expired
        self.processing = processing
        self.succeeded = succeeded
    }

    enum CodingKeys: String, CodingKey {
        case canceled
        case errored
        case expired
        case processing
        case succeeded
    }
}
