// Transformed from `anthropic.types.beta.beta_compaction_block_param` (beta_compaction_block_param.py).

import Foundation

/// A compaction block containing summary of previous context.
///
/// Users should round-trip these blocks from responses to subsequent requests
/// to maintain context across compaction boundaries.
///
/// When content is None, the block represents a failed compaction. The server
/// treats these as no-ops. Empty string content is not allowed.
public struct BetaCompactionBlockParam: Codable, Hashable, Sendable {
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??
    /// Summary of previously compacted content, or null if compaction failed
    public var content: String??
    /// Opaque metadata from prior compaction, to be round-tripped verbatim
    public var encryptedContent: String??
    /// The block's signature as returned, to be sent back verbatim
    public var signature: String??
    /// The tool changes of the compacted range, as the server returned them on this
    /// block: the `tool_addition` and `tool_removal` entries that take the request's
    /// `tools` to the tool set in effect at the end of the range. Send them back
    /// unchanged with the block.
    public var toolChanges: [BetaCompactionBlockParam.ToolChange]??

    public init(type: String = "compaction", cacheControl: BetaCacheControlEphemeralParam?? = nil, content: String?? = nil, encryptedContent: String?? = nil, signature: String?? = nil, toolChanges: [BetaCompactionBlockParam.ToolChange]?? = nil) {
        self.type = type
        self.cacheControl = cacheControl
        self.content = content
        self.encryptedContent = encryptedContent
        self.signature = signature
        self.toolChanges = toolChanges
    }

    enum CodingKeys: String, CodingKey {
        case type
        case cacheControl = "cache_control"
        case content
        case encryptedContent = "encrypted_content"
        case signature
        case toolChanges = "tool_changes"
    }
}

extension BetaCompactionBlockParam {

    public indirect enum ToolChange: Codable, Hashable, Sendable {
        case toolAddition(BetaRequestToolAdditionBlockParam)
        case toolRemoval(BetaRequestToolRemovalBlockParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "tool_addition": self = .toolAddition(try BetaRequestToolAdditionBlockParam(from: decoder))
            case "tool_removal": self = .toolRemoval(try BetaRequestToolRemovalBlockParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .toolAddition(let v): try v.encode(to: encoder)
            case .toolRemoval(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
