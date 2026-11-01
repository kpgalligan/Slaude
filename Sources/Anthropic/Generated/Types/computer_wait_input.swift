// Transformed from `anthropic.types.computer_wait_input` (computer_wait_input.py).

import Foundation

/// Wait for a specified duration.
public struct ComputerWaitInput: Codable, Hashable, Sendable {
    /// Duration to wait, in seconds.
    public var duration: Int

    public init(duration: Int) {
        self.duration = duration
    }

    enum CodingKeys: String, CodingKey {
        case duration
    }
}
