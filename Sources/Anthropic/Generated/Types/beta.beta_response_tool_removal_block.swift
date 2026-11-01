// Transformed from `anthropic.types.beta.beta_response_tool_removal_block` (beta_response_tool_removal_block.py).

import Foundation

/// An entry of a `compaction` block's `tool_changes`: a tool of the
/// request's `tools` (or an MCP tool or toolset) that the compacted range
/// withdrew. Send it back unchanged.
public struct BetaResponseToolRemovalBlock: Codable, Hashable, Sendable {
    /// A reference to the withdrawn `tools` entry, MCP tool or MCP toolset.
    public var tool: BetaResponseToolRemovalBlock.Tool
    public var type: String

    public init(tool: BetaResponseToolRemovalBlock.Tool, type: String = "tool_removal") {
        self.tool = tool
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case tool
        case type
    }
}

extension BetaResponseToolRemovalBlock {

    public indirect enum Tool: Codable, Hashable, Sendable {
        case toolReference(BetaResponseToolChangeToolReference)
        case mcpToolReference(BetaResponseToolChangeMCPToolReference)
        case mcpToolsetReference(BetaResponseToolChangeMCPToolsetReference)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "tool_reference": self = .toolReference(try BetaResponseToolChangeToolReference(from: decoder))
            case "mcp_tool_reference": self = .mcpToolReference(try BetaResponseToolChangeMCPToolReference(from: decoder))
            case "mcp_toolset_reference": self = .mcpToolsetReference(try BetaResponseToolChangeMCPToolsetReference(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .toolReference(let v): try v.encode(to: encoder)
            case .mcpToolReference(let v): try v.encode(to: encoder)
            case .mcpToolsetReference(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
