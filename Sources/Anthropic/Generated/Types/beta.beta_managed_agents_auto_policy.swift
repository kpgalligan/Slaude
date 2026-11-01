// Transformed from `anthropic.types.beta.beta_managed_agents_auto_policy` (beta_managed_agents_auto_policy.py).

import Foundation

/// The server decides each tool call individually: it judges, from the tool, its input, and the session content so far, whether the call is safe to execute or high-risk, and evaluates it to allow when judged safe and to deny when judged high-risk. A call the server cannot reach a judgement on evaluates to ask.
public struct BetaManagedAgentsAutoPolicy: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "auto") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
