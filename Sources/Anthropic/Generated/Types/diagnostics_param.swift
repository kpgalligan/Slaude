// Transformed from `anthropic.types.diagnostics_param` (diagnostics_param.py).

import Foundation

/// Request-level diagnostics.
///
/// Currently carries the previous response
/// id for prompt-cache divergence reporting.
public struct DiagnosticsParam: Codable, Hashable, Sendable {
    /// The `id` (`msg_...`) from this client's previous /v1/messages response.
    ///
    /// The server compares that request's prompt fingerprint against this one and
    /// returns `diagnostics.cache_miss_reason` when the prompt-cache prefix could not
    /// be reused. Pass `null` on the first turn to opt in without a prior message to
    /// compare.
    public var previousMessageId: String??

    public init(previousMessageId: String?? = nil) {
        self.previousMessageId = previousMessageId
    }

    enum CodingKeys: String, CodingKey {
        case previousMessageId = "previous_message_id"
    }
}
