// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination` (beta_telemetry_destination.py).

import Foundation

/// An OpenTelemetry destination: an OTLP/HTTP endpoint, the request headers sent with every delivery to it, what the exported spans contain, and which workspaces it covers. A destination belongs to an organization. A workspace's spans go to every enabled destination that covers it.
public struct BetaTelemetryDestination: Codable, Hashable, Sendable {
    /// The unique ID of the destination (`tdst_...`).
    public var id: String
    /// Time the destination was created.
    public var createdAt: Date
    /// The most recent delivery results for this destination.
    public var deliveryHealth: BetaTelemetryDestinationDeliveryHealth
    /// Human-readable name for the destination. Null when none was set.
    public var displayName: String?
    /// The base URL of the destination's OTLP/HTTP endpoint, exactly as registered.
    ///
    /// The API appends the per-signal path, such as `/v1/traces`, on delivery, unless
    /// `traces.endpoint_url` is set.
    public var endpointUrl: String
    /// Names of the registered request headers.
    ///
    /// Header values are write-only and are never returned.
    public var headerNames: [String]
    /// Whether the destination receives deliveries.
    public var state: BetaTelemetryDestinationState
    /// The destination's settings for the traces it receives.
    public var traces: BetaTelemetryDestinationTraces
    public var type: String
    /// Time of the last change to the destination's configuration or state.
    ///
    /// Changes to `delivery_health` don't change it.
    ///
    /// An update that sets a header value always changes it, even when the value is the
    /// same as before. Adding or removing a single workspace on the destination's list
    /// doesn't change it. An update that changes the list does.
    public var updatedAt: Date
    /// Which of the organization's workspaces the destination covers.
    public var workspaces: BetaTelemetryDestinationWorkspaces

    public init(id: String, createdAt: Date, deliveryHealth: BetaTelemetryDestinationDeliveryHealth, displayName: String? = nil, endpointUrl: String, headerNames: [String], state: BetaTelemetryDestinationState, traces: BetaTelemetryDestinationTraces, type: String = "telemetry_destination", updatedAt: Date, workspaces: BetaTelemetryDestinationWorkspaces) {
        self.id = id
        self.createdAt = createdAt
        self.deliveryHealth = deliveryHealth
        self.displayName = displayName
        self.endpointUrl = endpointUrl
        self.headerNames = headerNames
        self.state = state
        self.traces = traces
        self.type = type
        self.updatedAt = updatedAt
        self.workspaces = workspaces
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case deliveryHealth = "delivery_health"
        case displayName = "display_name"
        case endpointUrl = "endpoint_url"
        case headerNames = "header_names"
        case state
        case traces
        case type
        case updatedAt = "updated_at"
        case workspaces
    }
}
