// Transformed from `anthropic.types.beta.beta_toolset_tool_use_block` (beta_toolset_tool_use_block.py).

import Foundation

public indirect enum BetaToolsetToolUseBlock: Codable, Hashable, Sendable {
    case betaBrowserToolUseBlock(BetaBrowserToolUseBlock)
    case betaComputerToolUseBlock(BetaComputerToolUseBlock)
    case betaToolUseBlock(BetaToolUseBlock)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        if let v = try? BetaBrowserToolUseBlock(from: decoder) { self = .betaBrowserToolUseBlock(v); return }
        if let v = try? BetaComputerToolUseBlock(from: decoder) { self = .betaComputerToolUseBlock(v); return }
        if let v = try? BetaToolUseBlock(from: decoder) { self = .betaToolUseBlock(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .betaBrowserToolUseBlock(let v): try v.encode(to: encoder)
        case .betaComputerToolUseBlock(let v): try v.encode(to: encoder)
        case .betaToolUseBlock(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
