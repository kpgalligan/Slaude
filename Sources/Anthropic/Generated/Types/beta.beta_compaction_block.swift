// Transformed from `anthropic.types.beta.beta_compaction_block` (beta_compaction_block.py).

import Foundation

/// A compaction block returned when autocompact is triggered.
///
/// When content is None, it indicates the compaction failed to produce a valid
/// summary (e.g., malformed output from the model). Clients may round-trip
/// compaction blocks with null content; the server treats them as no-ops.
public struct BetaCompactionBlock: Codable, Hashable, Sendable {
    /// Summary of compacted content, or null if compaction failed
    public var content: String?
    /// Opaque metadata from prior compaction, to be round-tripped verbatim
    public var encryptedContent: String?
    public var type: String
    /// Signature over the summary, to be sent back with the block verbatim
    public var signature: String?
    /// The tool changes of the compacted range: the `tool_addition` and `tool_removal`
    /// blocks that take the request's `tools` to the tool set in effect at the end of
    /// the range, or `[]` when the range changed no tool. Absent when the server did
    /// not compute them. Send the block back unchanged.
    public var toolChanges: [BetaCompactionBlock.ToolChange]?

    public init(content: String? = nil, encryptedContent: String? = nil, type: String = "compaction", signature: String? = nil, toolChanges: [BetaCompactionBlock.ToolChange]? = nil) {
        self.content = content
        self.encryptedContent = encryptedContent
        self.type = type
        self.signature = signature
        self.toolChanges = toolChanges
    }

    enum CodingKeys: String, CodingKey {
        case content
        case encryptedContent = "encrypted_content"
        case type
        case signature
        case toolChanges = "tool_changes"
    }
}

extension BetaCompactionBlock {

    public indirect enum ToolChange: Codable, Hashable, Sendable {
        case toolAddition(BetaResponseToolAdditionBlock)
        case toolRemoval(BetaResponseToolRemovalBlock)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "tool_addition": self = .toolAddition(try BetaResponseToolAdditionBlock(from: decoder))
            case "tool_removal": self = .toolRemoval(try BetaResponseToolRemovalBlock(from: decoder))
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
