// Transformed from `anthropic.types.beta.beta_raw_message_delta_event` (beta_raw_message_delta_event.py).

import Foundation

public struct BetaRawMessageDeltaEvent: Codable, Hashable, Sendable {
    /// Information about context management strategies applied during the request
    public var contextManagement: BetaContextManagementResponse?
    public var delta: BetaRawMessageDeltaEvent.Delta
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
    public var usage: BetaMessageDeltaUsage
    /// Changes the API made to the request's input before showing it to the model, and
    /// blocks that failed a binding check but were left unchanged: one entry per block,
    /// in request order. Two entry types today. `thinking_dropped` — a `thinking`,
    /// `redacted_thinking` or `connector_text` block from the request's `messages` that
    /// was removed from the prompt instead of being shown to the model because it
    /// failed a binding check. `thinking_mismatch_allowed` — a `thinking` or
    /// `redacted_thinking` block that failed the conversation check (the conversation
    /// before it differs from the one it was created in, or it carries no record of one
    /// on a model that requires it) and was shown to the model all the same, because
    /// that check is not enforced for this request. More entry types may be added over
    /// time; ignore types you do not recognize.
    ///
    /// Requires `anthropic-beta: thinking-binding-controls-2026-08-01`. Present on
    /// every such response from a model that supports extended thinking, as `[]` when
    /// there is no entry to report; without the beta, blocks are removed or left in
    /// place all the same but nothing is reported. Removed blocks contribute nothing to
    /// `usage.input_tokens`; blocks left in place count as sent. When streaming, the
    /// array is final in `message_start`; the final `message_delta` event carries it
    /// only when a server-side model fallback happened mid-stream, in which case it
    /// holds the serving model's entries and replaces the one in `message_start`.
    public var inputTransformations: [BetaInputTransformation]?

    public init(contextManagement: BetaContextManagementResponse? = nil, delta: BetaRawMessageDeltaEvent.Delta, type: String = "message_delta", usage: BetaMessageDeltaUsage, inputTransformations: [BetaInputTransformation]? = nil) {
        self.contextManagement = contextManagement
        self.delta = delta
        self.type = type
        self.usage = usage
        self.inputTransformations = inputTransformations
    }

    enum CodingKeys: String, CodingKey {
        case contextManagement = "context_management"
        case delta
        case type
        case usage
        case inputTransformations = "input_transformations"
    }
}

extension BetaRawMessageDeltaEvent {

    public struct Delta: Codable, Hashable, Sendable {
        /// Information about the container used in this request.
        ///
        /// This will be non-null if a container tool (e.g. code execution) was used.
        public var container: BetaContainer?
        /// Structured information about why model output stopped.
        ///
        /// This is `null` when the `stop_reason` has no additional detail to report.
        public var stopDetails: BetaRefusalStopDetails?
        public var stopReason: BetaStopReason?
        public var stopSequence: String?

        public init(container: BetaContainer? = nil, stopDetails: BetaRefusalStopDetails? = nil, stopReason: BetaStopReason? = nil, stopSequence: String? = nil) {
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
