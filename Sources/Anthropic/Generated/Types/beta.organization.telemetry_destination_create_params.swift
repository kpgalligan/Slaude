// Transformed from `anthropic.types.beta.organization.telemetry_destination_create_params` (telemetry_destination_create_params.py).

import Foundation

public struct TelemetryDestinationCreateParams: Codable, Hashable, Sendable {
    /// The base URL of your collector's OTLP/HTTP endpoint, for example
    /// `https://gateway.example.com`.
    ///
    /// The URL must use `https` and a hostname, not an IP address. The port, if given,
    /// must be 443. The URL must not contain a query string, a fragment, or a username
    /// and password. At most 2,048 characters.
    ///
    /// A path prefix, such as `/otlp`, is allowed. Don't include the per-signal path
    /// (`/v1/traces`), because the API appends it on delivery. If your collector takes
    /// traces on another path, also set `traces.endpoint_url`.
    public var endpointURL: String
    /// Which of the organization's workspaces the destination covers.
    public var workspaces: BetaTelemetryDestinationWorkspacesParams
    /// Human-readable name for the destination. Optional. 1 to 255 characters.
    public var displayName: String??
    /// Request headers that the API sends with every delivery, typically your
    /// collector's authentication header (for example `authorization`).
    ///
    /// The API stores the values encrypted and never returns them. Reads show only
    /// `header_names`.
    ///
    /// At most 20 headers. Names are at most 128 characters. Two names can't differ
    /// only in case. Values are printable ASCII, at most 4,096 characters, and can't
    /// begin or end with a space. Names and values together are at most 16,384 bytes.
    ///
    /// Reserved names are rejected, for example `host`, `cookie`, `user-agent`, and
    /// names that start with `content-`, `proxy-`, `x-forwarded-`, or `anthropic-`. For
    /// this check, `_` in a name counts as `-`.
    public var headers: [String: String]?
    /// The settings for the traces that the destination receives.
    ///
    /// If you leave it out, every setting takes its default.
    public var traces: BetaTelemetryDestinationTracesParams?
    /// This endpoint is in beta: requests must send `telemetry-destinations-2026-08-11`
    /// in this header.
    public var betas: [AnthropicBetaParam]?

    public init(endpointURL: String, workspaces: BetaTelemetryDestinationWorkspacesParams, displayName: String?? = nil, headers: [String: String]? = nil, traces: BetaTelemetryDestinationTracesParams? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.endpointURL = endpointURL
        self.workspaces = workspaces
        self.displayName = displayName
        self.headers = headers
        self.traces = traces
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case endpointURL = "endpoint_url"
        case workspaces
        case displayName = "display_name"
        case headers
        case traces
        case betas
    }
}
