// Transformed from `anthropic.types.beta.beta_response_tool_addition_block` (beta_response_tool_addition_block.py).

import Foundation

/// An entry of a `compaction` block's `tool_changes`: a tool the
/// compacted range made available, as a reference to a `tools` entry or
/// MCP toolset, or as the tool definition in effect at the end of the
/// range, by value. Send it back unchanged.
public struct BetaResponseToolAdditionBlock: Codable, Hashable, Sendable {
    /// The tool made available: a reference to a `tools` entry or MCP toolset, or a
    /// `tool_definition` carrying the definition by value.
    public var tool: BetaResponseToolAdditionBlock.Tool
    public var type: String

    public init(tool: BetaResponseToolAdditionBlock.Tool, type: String = "tool_addition") {
        self.tool = tool
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case tool
        case type
    }
}

extension BetaResponseToolAdditionBlock {

    public indirect enum Tool: Codable, Hashable, Sendable {
        case toolReference(BetaResponseToolChangeToolReference)
        case mcpToolReference(BetaResponseToolChangeMCPToolReference)
        case mcpToolsetReference(BetaResponseToolChangeMCPToolsetReference)
        case toolDefinition(BetaToolChangeToolDefinition)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "tool_reference": self = .toolReference(try BetaResponseToolChangeToolReference(from: decoder))
            case "mcp_tool_reference": self = .mcpToolReference(try BetaResponseToolChangeMCPToolReference(from: decoder))
            case "mcp_toolset_reference": self = .mcpToolsetReference(try BetaResponseToolChangeMCPToolsetReference(from: decoder))
            case "tool_definition": self = .toolDefinition(try BetaToolChangeToolDefinition(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .toolReference(let v): try v.encode(to: encoder)
            case .mcpToolReference(let v): try v.encode(to: encoder)
            case .mcpToolsetReference(let v): try v.encode(to: encoder)
            case .toolDefinition(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
