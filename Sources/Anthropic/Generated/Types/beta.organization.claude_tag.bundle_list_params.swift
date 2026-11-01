// Transformed from `anthropic.types.beta.organization.claude_tag.bundle_list_params` (bundle_list_params.py).

import Foundation

public struct BundleListParams: Codable, Hashable, Sendable {
    /// Number of items to return per page, between 1 and 100. Defaults to 20.
    public var limit: Int?
    /// Opaque cursor from a previous response's `next_page`.
    public var page: String?
    /// This endpoint is in beta: requests must send
    /// `experimental-claude-tag-2026-10-21` in this header.
    public var betas: [AnthropicBetaParam]?

    public init(limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.limit = limit
        self.page = page
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case limit
        case page
        case betas
    }
}
