// Transformed from `anthropic.types.beta.organization.telemetry_destination_update_params` (telemetry_destination_update_params.py).

import Foundation

public struct TelemetryDestinationUpdateParams: Codable, Hashable, Sendable {
    /// New human-readable name, 1 to 255 characters. Null clears it.
    public var displayName: String??
    /// The new base URL of the destination's OTLP/HTTP endpoint.
    ///
    /// The same rules as on create apply.
    ///
    /// A change of hostname or port first removes every registered header, so send the
    /// headers for the new endpoint in the same request. When the destination has a
    /// `traces.endpoint_url`, such a change must also set `traces.endpoint_url` to a
    /// URL with the new hostname and port, or to `null`. A change of the path alone
    /// keeps the headers.
    public var endpointUrl: String?
    /// Headers to set or remove.
    ///
    /// The API merges them into the destination's headers by name.
    ///
    /// Names compare case-insensitively. A string value sets or replaces that header. A
    /// `null` value removes it. Headers that you omit don't change. The field itself
    /// can't be `null`.
    ///
    /// A request that sets a header value must also include `endpoint_url`. The current
    /// URL is accepted.
    ///
    /// The resulting set must stay within the same limits as on create. When the
    /// request sets a value, each stored value that it doesn't set counts as 4,096
    /// bytes toward the 16,384-byte limit, because you can't read its real length. So
    /// to change one header of a destination that has four or more other headers, send
    /// the values of the others again in the same request.
    public var headers: [String: String?]??
    /// Whether the destination receives deliveries after the update.
    ///
    /// The field can't be `null`.
    public var state: BetaTelemetryDestinationStateParams?
    /// The traces settings to change. Omitted settings keep their stored values.
    ///
    /// `null` sets every traces setting to its create default.
    public var traces: BetaTelemetryDestinationTracesParams??
    /// The new workspace scope, in the same form as on create.
    ///
    /// The field can't be `null`.
    ///
    /// The API refuses an update that changes the type or sends `workspace_ids` while
    /// the destination's list has more than 750 workspaces. Remove workspaces one at a
    /// time until 750 or fewer remain, then send the update again.
    public var workspaces: BetaTelemetryDestinationWorkspacesParams?
    /// This endpoint is in beta: requests must send `telemetry-destinations-2026-08-11`
    /// in this header.
    public var betas: [AnthropicBetaParam]?

    public init(displayName: String?? = nil, endpointUrl: String? = nil, headers: [String: String?]?? = nil, state: BetaTelemetryDestinationStateParams? = nil, traces: BetaTelemetryDestinationTracesParams?? = nil, workspaces: BetaTelemetryDestinationWorkspacesParams? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.displayName = displayName
        self.endpointUrl = endpointUrl
        self.headers = headers
        self.state = state
        self.traces = traces
        self.workspaces = workspaces
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case endpointUrl = "endpoint_url"
        case headers
        case state
        case traces
        case workspaces
        case betas
    }
}
