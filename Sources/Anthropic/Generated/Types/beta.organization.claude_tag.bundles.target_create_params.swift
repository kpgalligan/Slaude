// Transformed from `anthropic.types.beta.organization.claude_tag.bundles.target_create_params` (target_create_params.py).

import Foundation

public struct TargetCreateParams: Codable, Hashable, Sendable {
    public var target: BetaClaudeTagBundleTargetCreateParam
    /// This endpoint is in beta: requests must send
    /// `experimental-claude-tag-2026-10-21` in this header.
    public var betas: [AnthropicBetaParam]?

    public init(target: BetaClaudeTagBundleTargetCreateParam, betas: [AnthropicBetaParam]? = nil) {
        self.target = target
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case target
        case betas
    }
}
