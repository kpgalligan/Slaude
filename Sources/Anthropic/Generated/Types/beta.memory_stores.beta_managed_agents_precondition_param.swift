// Transformed from `anthropic.types.beta.memory_stores.beta_managed_agents_precondition_param` (beta_managed_agents_precondition_param.py).

import Foundation

/// Optional condition that must hold for an update to apply.
///
/// When omitted, the update is unconditional. Asserts the current state of the memory being updated. When an update changes `path`, the precondition still refers to the memory's current content, not the destination path. Currently the only supported variant is `content_sha256`.
public struct BetaManagedAgentsPreconditionParam: Codable, Hashable, Sendable {
    public var type: String
    /// Expected `content_sha256` of the stored memory (64 lowercase hexadecimal
    /// characters). Typically the `content_sha256` returned by a prior read or list
    /// call. Because the server applies no content normalization, clients can also
    /// compute this locally as the SHA-256 of the UTF-8 content bytes.
    public var contentSha256: String?

    public init(type: String = "content_sha256", contentSha256: String? = nil) {
        self.type = type
        self.contentSha256 = contentSha256
    }

    enum CodingKeys: String, CodingKey {
        case type
        case contentSha256 = "content_sha256"
    }
}
