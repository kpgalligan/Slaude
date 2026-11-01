// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_traces` (beta_telemetry_destination_traces.py).

import Foundation

/// A telemetry destination's settings for the traces it receives.
public struct BetaTelemetryDestinationTraces: Codable, Hashable, Sendable {
    /// What the exported spans contain.
    public var contentMode: BetaTelemetryDestinationContentMode
    /// Whether the destination receives traces.
    ///
    /// A destination whose `enabled` is false keeps its other settings.
    public var enabled: Bool
    /// The full URL that the API posts traces to, exactly as registered, or `null` if
    /// the destination doesn't have one.
    ///
    /// When it is `null`, the API posts traces to `endpoint_url` with `/v1/traces`
    /// appended.
    public var endpointURL: String?
    /// The most bytes of content that one exported span can contain, or `null` if only
    /// the API's maximum applies.
    ///
    /// Content means model prompts and responses, and tool inputs and outputs. The API
    /// shortens longer content to this size before it delivers the span. A destination
    /// whose `content_mode` is `metadata_only` keeps this value. It applies once
    /// `content_mode` is `content`.
    public var maxContentBytes: Int?

    public init(contentMode: BetaTelemetryDestinationContentMode, enabled: Bool, endpointURL: String? = nil, maxContentBytes: Int? = nil) {
        self.contentMode = contentMode
        self.enabled = enabled
        self.endpointURL = endpointURL
        self.maxContentBytes = maxContentBytes
    }

    enum CodingKeys: String, CodingKey {
        case contentMode = "content_mode"
        case enabled
        case endpointURL = "endpoint_url"
        case maxContentBytes = "max_content_bytes"
    }
}
