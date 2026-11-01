// Transformed from `anthropic.types.beta.beta_thinking_block_binding_param` (beta_thinking_block_binding_param.py).

import Foundation

/// Controls for block binding: what happens when a thinking block this
/// request sends back fails the conversation check. Every field is optional;
/// an empty object means every default.
public struct BetaThinkingBlockBindingParam: Codable, Hashable, Sendable {
    /// "error" (default) | "drop_block".
    ///
    /// What happens when a thinking block in `messages` fails the conversation check
    /// (it was created in a different conversation, or the messages before it have
    /// changed since). "error" fails the request with a 400 error. "drop_block" removes
    /// the failing blocks and the request proceeds; each removal is reported in
    /// `input_transformations`.
    public var prefixMismatchBehavior: BetaThinkingPrefixMismatchBehavior??

    public init(prefixMismatchBehavior: BetaThinkingPrefixMismatchBehavior?? = nil) {
        self.prefixMismatchBehavior = prefixMismatchBehavior
    }

    enum CodingKeys: String, CodingKey {
        case prefixMismatchBehavior = "prefix_mismatch_behavior"
    }
}
