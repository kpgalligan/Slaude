// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_disabled_reason_redirect` (beta_telemetry_destination_disabled_reason_redirect.py).

import Foundation

/// The API disabled the destination because the endpoint answered a delivery with a 3xx status. Redirects are never followed, and one such answer disables the destination at once.
public struct BetaTelemetryDestinationDisabledReasonRedirect: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "redirect") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
