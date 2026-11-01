// Transformed from `anthropic.types.beta.beta_advisor_result_block_param` (beta_advisor_result_block_param.py).

import Foundation

public struct BetaAdvisorResultBlockParam: Codable, Hashable, Sendable {
    public var text: String
    public var type: String
    public var stopReason: String??

    public init(text: String, type: String = "advisor_result", stopReason: String?? = nil) {
        self.text = text
        self.type = type
        self.stopReason = stopReason
    }

    enum CodingKeys: String, CodingKey {
        case text
        case type
        case stopReason = "stop_reason"
    }
}
