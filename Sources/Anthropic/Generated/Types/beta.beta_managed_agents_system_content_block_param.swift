// Transformed from `anthropic.types.beta.beta_managed_agents_system_content_block_param` (beta_managed_agents_system_content_block_param.py).

import Foundation

/// Content block in a mid-conversation system message. Text-only.
public struct BetaManagedAgentsSystemContentBlockParam: Codable, Hashable, Sendable {
    /// The text content.
    public var text: String
    public var type: String

    public init(text: String, type: String = "text") {
        self.text = text
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case text
        case type
    }
}
