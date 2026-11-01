// Transformed from `anthropic.types.beta.beta_compaction_config_param` (beta_compaction_config_param.py).

import Foundation

/// Compact the whole conversation and return a signed `compaction` block,
/// alone, that a later request sends back first in `messages`, in place of
/// the messages it summarizes. There is no trigger and no pause flag: sending
/// the parameter compacts, and nothing is sampled after the block.
///
/// The summarization prompt is the server's own unless `instructions` are
/// given, which then replace it for this request; a value that is empty or
/// only whitespace counts as absent.
public struct BetaCompactionConfigParam: Codable, Hashable, Sendable {
    public var type: String
    /// Replaces the server's default summarization prompt for this request.
    ///
    /// An empty or whitespace-only value counts as absent.
    public var instructions: String??

    public init(type: String = "summarize", instructions: String?? = nil) {
        self.type = type
        self.instructions = instructions
    }

    enum CodingKeys: String, CodingKey {
        case type
        case instructions
    }
}
