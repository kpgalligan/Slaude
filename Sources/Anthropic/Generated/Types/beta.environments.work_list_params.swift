// Transformed from `anthropic.types.beta.environments.work_list_params` (work_list_params.py).

import Foundation

public struct WorkListParams: Codable, Hashable, Sendable {
    /// Maximum number of work items to return
    public var limit: Int?
    /// Opaque cursor from previous response for pagination
    public var page: String??
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?

    public init(limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil) {
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
