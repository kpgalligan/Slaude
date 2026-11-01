// Transformed from `anthropic.types.beta.beta_computer_screenshot_input` (beta_computer_screenshot_input.py).

import Foundation

/// Take a screenshot of the screen.
public struct BetaComputerScreenshotInput: Codable, Hashable, Sendable {
    public init() {
    }

    public init(from decoder: Decoder) throws {}
    public func encode(to encoder: Encoder) throws {
        _ = encoder.container(keyedBy: AnyCodingKey.self)
    }
}
