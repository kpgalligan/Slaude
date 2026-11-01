// Transformed from `anthropic.types.beta.messages.beta_message_batch` (beta_message_batch.py).

import Foundation

public struct BetaMessageBatch: Codable, Hashable, Sendable {
    /// Unique object identifier.
    ///
    /// The format and length of IDs may change over time.
    public var id: String
    /// RFC 3339 datetime string representing the time at which the Message Batch was
    /// archived and its results became unavailable.
    public var archivedAt: Date?
    /// RFC 3339 datetime string representing the time at which cancellation was
    /// initiated for the Message Batch. Specified only if cancellation was initiated.
    public var cancelInitiatedAt: Date?
    /// RFC 3339 datetime string representing the time at which the Message Batch was
    /// created.
    public var createdAt: Date
    /// RFC 3339 datetime string representing the time at which processing for the
    /// Message Batch ended. Specified only once processing ends.
    ///
    /// Processing ends when every request in a Message Batch has either succeeded,
    /// errored, canceled, or expired.
    public var endedAt: Date?
    /// RFC 3339 datetime string representing the time at which the Message Batch will
    /// expire and end processing, which is 24 hours after creation.
    public var expiresAt: Date
    /// Processing status of the Message Batch.
    public var processingStatus: ProcessingStatus
    /// Tallies requests within the Message Batch, categorized by their status.
    ///
    /// Requests start as `processing` and move to one of the other statuses only once
    /// processing of the entire batch ends. The sum of all values always matches the
    /// total number of requests in the batch.
    public var requestCounts: BetaMessageBatchRequestCounts
    /// URL to a `.jsonl` file containing the results of the Message Batch requests.
    ///
    /// Specified only once processing ends.
    ///
    /// Results in the file are not guaranteed to be in the same order as requests. Use
    /// the `custom_id` field to match results to requests.
    public var resultsURL: String?
    /// Object type.
    ///
    /// For Message Batches, this is always `"message_batch"`.
    public var type: String

    public init(id: String, archivedAt: Date? = nil, cancelInitiatedAt: Date? = nil, createdAt: Date, endedAt: Date? = nil, expiresAt: Date, processingStatus: ProcessingStatus, requestCounts: BetaMessageBatchRequestCounts, resultsURL: String? = nil, type: String = "message_batch") {
        self.id = id
        self.archivedAt = archivedAt
        self.cancelInitiatedAt = cancelInitiatedAt
        self.createdAt = createdAt
        self.endedAt = endedAt
        self.expiresAt = expiresAt
        self.processingStatus = processingStatus
        self.requestCounts = requestCounts
        self.resultsURL = resultsURL
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case archivedAt = "archived_at"
        case cancelInitiatedAt = "cancel_initiated_at"
        case createdAt = "created_at"
        case endedAt = "ended_at"
        case expiresAt = "expires_at"
        case processingStatus = "processing_status"
        case requestCounts = "request_counts"
        case resultsURL = "results_url"
        case type
    }

    public enum ProcessingStatus: OpenEnum, CaseIterable {
        case inProgress
        case canceling
        case ended
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [ProcessingStatus] = [.inProgress, .canceling, .ended]

        public init(rawValue: String) {
            switch rawValue {
            case "in_progress": self = .inProgress
            case "canceling": self = .canceling
            case "ended": self = .ended
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .inProgress: return "in_progress"
            case .canceling: return "canceling"
            case .ended: return "ended"
            case .unknown(let value): return value
            }
        }
    }
}
