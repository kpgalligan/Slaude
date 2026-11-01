// Transformed from `anthropic.types.beta.organization.beta_analytics_lines_of_code` (beta_analytics_lines_of_code.py).

import Foundation

/// Lines of code added and removed via Claude Code.
public struct BetaAnalyticsLinesOfCode: Codable, Hashable, Sendable {
    /// Lines of code added
    public var addedCount: Int
    /// Lines of code removed
    public var removedCount: Int

    public init(addedCount: Int, removedCount: Int) {
        self.addedCount = addedCount
        self.removedCount = removedCount
    }

    enum CodingKeys: String, CodingKey {
        case addedCount = "added_count"
        case removedCount = "removed_count"
    }
}
