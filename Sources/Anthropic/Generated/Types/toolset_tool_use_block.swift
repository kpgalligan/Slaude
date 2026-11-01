// Transformed from `anthropic.types.toolset_tool_use_block` (toolset_tool_use_block.py).

import Foundation

public indirect enum ToolsetToolUseBlock: Codable, Hashable, Sendable {
    case browserToolUseBlock(BrowserToolUseBlock)
    case computerToolUseBlock(ComputerToolUseBlock)
    case toolUseBlock(ToolUseBlock)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        if let v = try? BrowserToolUseBlock(from: decoder) { self = .browserToolUseBlock(v); return }
        if let v = try? ComputerToolUseBlock(from: decoder) { self = .computerToolUseBlock(v); return }
        if _Coding.constantsMatch(decoder, ["type": "tool_use"]), let v = try? ToolUseBlock(from: decoder) { self = .toolUseBlock(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .browserToolUseBlock(let v): try v.encode(to: encoder)
        case .computerToolUseBlock(let v): try v.encode(to: encoder)
        case .toolUseBlock(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
