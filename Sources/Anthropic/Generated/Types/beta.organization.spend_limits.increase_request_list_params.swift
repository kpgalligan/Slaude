// Transformed from `anthropic.types.beta.organization.spend_limits.increase_request_list_params` (increase_request_list_params.py).

import Foundation

public struct IncreaseRequestListParams: Codable, Hashable, Sendable {
    /// Filter by requester, as `user_...` tagged IDs.
    public var actorIDs: [String]??
    public var limit: Int?
    /// Opaque cursor from a previous response's `next_page`.
    public var page: String??
    /// Filter by status. Omit to return all.
    public var status: [BetaSpendLimitIncreaseRequestStatus]??

    public init(actorIDs: [String]?? = nil, limit: Int? = nil, page: String?? = nil, status: [BetaSpendLimitIncreaseRequestStatus]?? = nil) {
        self.actorIDs = actorIDs
        self.limit = limit
        self.page = page
        self.status = status
    }

    enum CodingKeys: String, CodingKey {
        case actorIDs = "actor_ids"
        case limit
        case page
        case status
    }
}
