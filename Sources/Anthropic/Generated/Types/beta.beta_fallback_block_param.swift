// Transformed from `anthropic.types.beta.beta_fallback_block_param` (beta_fallback_block_param.py).

import Foundation

/// A `fallback` block echoed back from a prior response.
///
/// Accepted in `messages[].content` and not rendered into the prompt; not
/// validated against the request's `fallbacks` chain or top-level `model`.
///
/// Echo the assistant turn back verbatim, including this block in its
/// original position. The block marks the boundary between content produced
/// before and after a fallback hop, and the server relies on that boundary
/// to validate the turn: when thinking runs flank the boundary, omitting
/// the block merges them into one span the server cannot validate (the
/// request is rejected), and moving it into the middle of a single run is
/// likewise rejected; between non-thinking blocks the block's placement has
/// no validation effect.
public struct BetaFallbackBlockParam: Codable, Hashable, Sendable {
    /// Identifies one hop of a fallback transition.
    public var to: BetaFallbackInfoParam
    public var type: String
    /// The response block's `trigger`, echoed verbatim.
    ///
    /// Accepted and ignored by the server; any object or `null` is allowed.
    public var trigger: JSONValue

    public init(to: BetaFallbackInfoParam, type: String = "fallback", trigger: JSONValue) {
        self.to = to
        self.type = type
        self.trigger = trigger
    }

    enum CodingKeys: String, CodingKey {
        case to
        case type
        case trigger
    }
}
