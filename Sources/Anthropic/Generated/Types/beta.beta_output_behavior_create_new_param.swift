// Transformed from `anthropic.types.beta.beta_output_behavior_create_new_param` (beta_output_behavior_create_new_param.py).

import Foundation

/// Write the result to a new memory store that starts as a copy of the input memory store. This is the default.
///
/// The new memory store is in the same workspace as the dream. The dream doesn't change the input memory store.
public struct BetaOutputBehaviorCreateNewParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "create_new") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
