// Transformed from `anthropic.types.computer_hold_key_input` (computer_hold_key_input.py).

import Foundation

/// Hold down a key or key-combination for a specified duration.
///
/// Uses the same key
/// syntax as `key`.
public struct ComputerHoldKeyInput: Codable, Hashable, Sendable {
    /// Duration to hold the key, in seconds.
    public var duration: Int
    /// The key or key-combination to hold.
    public var text: String

    public init(duration: Int, text: String) {
        self.duration = duration
        self.text = text
    }

    enum CodingKeys: String, CodingKey {
        case duration
        case text
    }
}
