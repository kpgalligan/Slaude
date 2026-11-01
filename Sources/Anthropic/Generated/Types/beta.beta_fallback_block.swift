// Transformed from `anthropic.types.beta.beta_fallback_block` (beta_fallback_block.py).

import Foundation

/// Marks the point in `content` where one model's output gives way to the next.
///
/// One block appears per hop where a preceding model actually ran this turn and
/// declined. A turn where no preceding model ran and declined has no such
/// boundary and carries no block — the signal for whether a fallback model
/// served the response is the presence of a `fallback_message` entry in
/// `usage.iterations`, not this block.
///
/// The block is treated like a server-tool content block for streaming: it
/// arrives via the standard `content_block_start` / `content_block_stop`
/// pair and carries no deltas.
public struct BetaFallbackBlock: Codable, Hashable, Sendable {
    /// The model whose output ends at this point — the model that declined at this hop.
    ///
    /// When the declining hop is the requested model, its `model` echoes the top-level
    /// `model` string the caller sent (alias or canonical); when the declining hop is a
    /// fallback model, its `model` is that model's canonical id.
    public var from: BetaFallbackInfo?
    /// The fallback model producing the content that follows this block.
    ///
    /// Its `model` is always the canonical id.
    public var to: BetaFallbackInfo
    /// What caused the `from` model to hand over at this hop.
    public var trigger: BetaFallbackRefusalTrigger
    public var type: String

    public init(from: BetaFallbackInfo? = nil, to: BetaFallbackInfo, trigger: BetaFallbackRefusalTrigger, type: String = "fallback") {
        self.from = from
        self.to = to
        self.trigger = trigger
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case from
        case to
        case trigger
        case type
    }
}
