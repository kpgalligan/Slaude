// Transformed from `anthropic.types.beta.beta_request_tool_addition_block_param` (beta_request_tool_addition_block_param.py).

import Foundation

/// Mid-conversation directive to make a tool available.
///
/// ``tool`` is a reference to a tool (or MCP toolset) declared in the
/// request's ``tools``. Under the ``inline-tools-2026-09-15`` beta it may
/// instead be a reference to a tool defined earlier in ``messages``, or a
/// ``tool_definition`` object that carries an inline tool definition in
/// ``definition`` (the same object a ``tools`` entry holds). An ``mcp_toolset``
/// definition also requires the ``mcp-client-2026-09-15`` beta. The tool is
/// offered to the model from this point in the conversation onward.
public struct BetaRequestToolAdditionBlockParam: Codable, Hashable, Sendable {
    public var tool: BetaRequestToolAdditionBlockParam.Tool
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??

    public init(tool: BetaRequestToolAdditionBlockParam.Tool, type: String = "tool_addition", cacheControl: BetaCacheControlEphemeralParam?? = nil) {
        self.tool = tool
        self.type = type
        self.cacheControl = cacheControl
    }

    enum CodingKeys: String, CodingKey {
        case tool
        case type
        case cacheControl = "cache_control"
    }
}

extension BetaRequestToolAdditionBlockParam {

    public indirect enum Tool: Codable, Hashable, Sendable {
        case toolReference(BetaToolChangeToolReferenceParam)
        case mcpToolReference(BetaToolChangeMCPToolReferenceParam)
        case mcpToolsetReference(BetaToolChangeMCPToolsetReferenceParam)
        case toolDefinition(BetaToolChangeToolDefinitionParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "tool_reference": self = .toolReference(try BetaToolChangeToolReferenceParam(from: decoder))
            case "mcp_tool_reference": self = .mcpToolReference(try BetaToolChangeMCPToolReferenceParam(from: decoder))
            case "mcp_toolset_reference": self = .mcpToolsetReference(try BetaToolChangeMCPToolsetReferenceParam(from: decoder))
            case "tool_definition": self = .toolDefinition(try BetaToolChangeToolDefinitionParam(from: decoder))
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
