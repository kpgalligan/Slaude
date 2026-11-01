// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_delivery_health` (beta_telemetry_destination_delivery_health.py).

import Foundation

/// The most recent delivery results that the API records for a telemetry destination.
///
/// Changes to the destination's configuration or state don't reset these fields. Changes to these fields don't change `updated_at`. The values can lag behind the latest deliveries.
///
/// See the [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#delivery-and-health) to learn how the API delivers spans and when it disables a destination.
public struct BetaTelemetryDestinationDeliveryHealth: Codable, Hashable, Sendable {
    /// A message that describes the most recent failed delivery to the destination, or
    /// `null` if no delivery has failed yet.
    ///
    /// Examples are `temporary DNS failure`, `TLS failure`, `timeout`,
    /// `connection failure`, `invalid address`, `HTTP error (status 503)`, and
    /// `redirect (status 301)`. The message is `invalid address` both for a hostname
    /// that doesn't exist and for an address that isn't publicly routable. It never
    /// contains the endpoint's response body, a header value, a network address, or TLS
    /// details.
    ///
    /// `last_error` and `last_error_at` always change together. A later successful
    /// delivery doesn't clear them. If `last_success_at` is later than `last_error_at`,
    /// a delivery has succeeded since this failure.
    ///
    /// See the
    /// [OpenTelemetry export guide](https://platform.claude.com/docs/en/manage-claude/opentelemetry#delivery-errors)
    /// to learn the likely cause of each error.
    public var lastError: String?
    /// Time of the failure that `last_error` describes.
    ///
    /// Changes together with `last_error`. Null until a delivery first fails.
    public var lastErrorAt: Date?
    /// Time of the most recent successful delivery to the destination, or `null` if no
    /// delivery has succeeded yet.
    public var lastSuccessAt: Date?

    public init(lastError: String? = nil, lastErrorAt: Date? = nil, lastSuccessAt: Date? = nil) {
        self.lastError = lastError
        self.lastErrorAt = lastErrorAt
        self.lastSuccessAt = lastSuccessAt
    }

    enum CodingKeys: String, CodingKey {
        case lastError = "last_error"
        case lastErrorAt = "last_error_at"
        case lastSuccessAt = "last_success_at"
    }
}
