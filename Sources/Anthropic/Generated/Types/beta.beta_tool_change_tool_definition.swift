// Transformed from `anthropic.types.beta.beta_tool_change_tool_definition` (beta_tool_change_tool_definition.py).

import Foundation

/// A tool defined by value, as a `compaction` block's `tool_changes` entry
/// reports it: `definition` is the tool's definition as it was sent, in the
/// form of a `tools` entry, without `cache_control`. Send it back unchanged
/// with the block.
public struct BetaToolChangeToolDefinition: Codable, Hashable, Sendable {
    public var definition: BetaResponseToolUnion
    public var type: String

    public init(definition: BetaResponseToolUnion, type: String = "tool_definition") {
        self.definition = definition
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case definition
        case type
    }
}
