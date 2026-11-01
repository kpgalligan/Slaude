// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_text_rubric_params` (beta_managed_agents_text_rubric_params.py).

import Foundation

/// Rubric content provided inline as text.
public struct BetaManagedAgentsTextRubricParams: Codable, Hashable, Sendable {
    /// Rubric content.
    ///
    /// Plain text or markdown — the grader treats it as freeform text. Maximum 262144
    /// characters.
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
