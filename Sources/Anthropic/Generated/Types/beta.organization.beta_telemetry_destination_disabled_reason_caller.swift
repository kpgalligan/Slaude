// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_disabled_reason_caller` (beta_telemetry_destination_disabled_reason_caller.py).

import Foundation

/// A caller disabled the destination with an update that set `state` to `disabled`.
public struct BetaTelemetryDestinationDisabledReasonCaller: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "caller") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
