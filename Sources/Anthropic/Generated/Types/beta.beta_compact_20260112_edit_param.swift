// Transformed from `anthropic.types.beta.beta_compact_20260112_edit_param` (beta_compact_20260112_edit_param.py).

import Foundation

/// Automatically compact older context when reaching the configured trigger threshold.
public struct BetaCompact20260112EditParam: Codable, Hashable, Sendable {
    public var type: String
    /// Additional instructions for summarization.
    public var instructions: String??
    /// Whether to pause after compaction and return the compaction block to the user.
    public var pauseAfterCompaction: Bool?
    /// When to trigger compaction. Defaults to 150000 input tokens.
    public var trigger: BetaInputTokensTriggerParam??

    public init(type: String = "compact_20260112", instructions: String?? = nil, pauseAfterCompaction: Bool? = nil, trigger: BetaInputTokensTriggerParam?? = nil) {
        self.type = type
        self.instructions = instructions
        self.pauseAfterCompaction = pauseAfterCompaction
        self.trigger = trigger
    }

    enum CodingKeys: String, CodingKey {
        case type
        case instructions
        case pauseAfterCompaction = "pause_after_compaction"
        case trigger
    }
}
