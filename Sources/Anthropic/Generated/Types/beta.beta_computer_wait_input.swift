// Transformed from `anthropic.types.beta.beta_computer_wait_input` (beta_computer_wait_input.py).

import Foundation

/// Wait for a specified duration.
public struct BetaComputerWaitInput: Codable, Hashable, Sendable {
    /// Duration to wait, in seconds.
    public var duration: Int

    public init(duration: Int) {
        self.duration = duration
    }

    enum CodingKeys: String, CodingKey {
        case duration
    }
}
