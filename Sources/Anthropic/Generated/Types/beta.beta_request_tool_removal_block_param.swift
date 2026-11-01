// Transformed from `anthropic.types.beta.beta_request_tool_removal_block_param` (beta_request_tool_removal_block_param.py).

import Foundation

/// Mid-conversation directive to withdraw a tool.
///
/// ``tool`` references a tool (or MCP toolset) by name: one declared in the
/// request's ``tools`` or defined earlier in ``messages``. It is no longer
/// offered to the model from this point in the conversation onward.
public struct BetaRequestToolRemovalBlockParam: Codable, Hashable, Sendable {
    public var tool: BetaRequestToolRemovalBlockParam.Tool
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??

    public init(tool: BetaRequestToolRemovalBlockParam.Tool, type: String = "tool_removal", cacheControl: BetaCacheControlEphemeralParam?? = nil) {
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

extension BetaRequestToolRemovalBlockParam {

    public indirect enum Tool: Codable, Hashable, Sendable {
        case toolReference(BetaToolChangeToolReferenceParam)
        case mcpToolReference(BetaToolChangeMCPToolReferenceParam)
        case mcpToolsetReference(BetaToolChangeMCPToolsetReferenceParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "tool_reference": self = .toolReference(try BetaToolChangeToolReferenceParam(from: decoder))
            case "mcp_tool_reference": self = .mcpToolReference(try BetaToolChangeMCPToolReferenceParam(from: decoder))
            case "mcp_toolset_reference": self = .mcpToolsetReference(try BetaToolChangeMCPToolsetReferenceParam(from: decoder))
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
