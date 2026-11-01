// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_disabled_reason_sustained_failure` (beta_telemetry_destination_disabled_reason_sustained_failure.py).

import Foundation

/// The API disabled the destination because deliveries to it failed, with no successful delivery in between, for longer than a threshold that Anthropic configures and that is not part of this contract. The reason is `invalid_address` instead when the most recent failed delivery failed with an invalid address.
public struct BetaTelemetryDestinationDisabledReasonSustainedFailure: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "sustained_failure") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
