// Transformed from `anthropic.types.beta.beta_response_tool_change_tool_reference` (beta_response_tool_change_tool_reference.py).

import Foundation

/// Reference to a single tool, by the name the model uses to call it, as
/// a ``compaction`` block's ``tool_changes`` entry reports it: a tool
/// declared in ``tools`` or defined by an earlier ``tool_addition`` block.
/// Send it back unchanged with the block.
public struct BetaResponseToolChangeToolReference: Codable, Hashable, Sendable {
    public var name: String
    public var type: String

    public init(name: String, type: String = "tool_reference") {
        self.name = name
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case name
        case type
    }
}
