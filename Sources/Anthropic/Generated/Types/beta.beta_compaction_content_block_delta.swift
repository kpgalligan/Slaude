// Transformed from `anthropic.types.beta.beta_compaction_content_block_delta` (beta_compaction_content_block_delta.py).

import Foundation

public struct BetaCompactionContentBlockDelta: Codable, Hashable, Sendable {
    public var content: String?
    /// Opaque metadata from prior compaction, to be round-tripped verbatim
    public var encryptedContent: String?
    public var type: String

    public init(content: String? = nil, encryptedContent: String? = nil, type: String = "compaction_delta") {
        self.content = content
        self.encryptedContent = encryptedContent
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case encryptedContent = "encrypted_content"
        case type
    }
}
