// Transformed from `anthropic.types.raw_message_delta_event` (raw_message_delta_event.py).

import Foundation

public struct RawMessageDeltaEvent: Codable, Hashable, Sendable {
    public var delta: RawMessageDeltaEvent.Delta
    public var type: String
    /// Billing and rate-limit usage.
    ///
    /// Anthropic's API bills and rate-limits by token counts, as tokens represent the
    /// underlying cost to our systems.
    ///
    /// Under the hood, the API transforms requests into a format suitable for the
    /// model. The model's output then goes through a parsing stage before becoming an
    /// API response. As a result, the token counts in `usage` will not match one-to-one
    /// with the exact visible content of an API request or response.
    ///
    /// For example, `output_tokens` will be non-zero, even for an empty string response
    /// from Claude.
    ///
    /// Total input tokens in a request is the summation of `input_tokens`,
    /// `cache_creation_input_tokens`, and `cache_read_input_tokens`.
    public var usage: MessageDeltaUsage

    public init(delta: RawMessageDeltaEvent.Delta, type: String = "message_delta", usage: MessageDeltaUsage) {
        self.delta = delta
        self.type = type
        self.usage = usage
    }

    enum CodingKeys: String, CodingKey {
        case delta
        case type
        case usage
    }
}

extension RawMessageDeltaEvent {

    public struct Delta: Codable, Hashable, Sendable {
        /// Information about the container used in this request.
        ///
        /// This will be non-null if a container tool (e.g. code execution) was used.
        public var container: Container?
        /// Structured information about why model output stopped.
        ///
        /// This is `null` when the `stop_reason` has no additional detail to report.
        public var stopDetails: RefusalStopDetails?
        public var stopReason: StopReason?
        public var stopSequence: String?

        public init(container: Container? = nil, stopDetails: RefusalStopDetails? = nil, stopReason: StopReason? = nil, stopSequence: String? = nil) {
            self.container = container
            self.stopDetails = stopDetails
            self.stopReason = stopReason
            self.stopSequence = stopSequence
        }

        enum CodingKeys: String, CodingKey {
            case container
            case stopDetails = "stop_details"
            case stopReason = "stop_reason"
            case stopSequence = "stop_sequence"
        }
    }
}
