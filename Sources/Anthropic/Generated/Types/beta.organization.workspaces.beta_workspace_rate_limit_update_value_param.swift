// Transformed from `anthropic.types.beta.organization.workspaces.beta_workspace_rate_limit_update_value_param` (beta_workspace_rate_limit_update_value_param.py).

import Foundation

public struct BetaWorkspaceRateLimitUpdateValueParam: Codable, Hashable, Sendable {
    /// Rate limiter type.
    public var type: BetaWorkspaceRateLimitType
    /// New limit value.
    ///
    /// Set to null to clear the workspace override and fall back to the organization
    /// limit.
    public var value: Int?

    public init(type: BetaWorkspaceRateLimitType, value: Int? = nil) {
        self.type = type
        self.value = value
    }

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(type, forKey: .type)
        try c.encode(value, forKey: .value)
    }
}
