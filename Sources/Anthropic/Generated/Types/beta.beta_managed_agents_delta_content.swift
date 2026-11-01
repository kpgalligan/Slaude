// Transformed from `anthropic.types.beta.beta_managed_agents_delta_content` (beta_managed_agents_delta_content.py).

import Foundation

public struct BetaManagedAgentsDeltaContent: Codable, Hashable, Sendable {
    /// A partial element of the content array at index, typed like the element itself —
    /// the same shape the buffered agent.message carries in content.
    public var content: BetaManagedAgentsTextBlock
    public var type: String
    /// Which entry in the previewed event's content array this fragment lands in.
    ///
    /// Insert content as that entry when the index is new; append to the existing entry
    /// otherwise.
    public var index: Int?

    public init(content: BetaManagedAgentsTextBlock, type: String = "content_delta", index: Int? = nil) {
        self.content = content
        self.type = type
        self.index = index
    }

    enum CodingKeys: String, CodingKey {
        case content
        case type
        case index
    }
}
