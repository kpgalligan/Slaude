// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_text_rubric` (beta_managed_agents_text_rubric.py).

import Foundation

/// Rubric content provided inline as text.
public struct BetaManagedAgentsTextRubric: Codable, Hashable, Sendable {
    /// Rubric content. Plain text or markdown — the grader treats it as freeform text.
    public var content: String
    public var type: String

    public init(content: String, type: String = "text") {
        self.content = content
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case type
    }
}
