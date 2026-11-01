// Transformed from `anthropic.types.beta.organization.beta_telemetry_destination_content_mode` (beta_telemetry_destination_content_mode.py).

import Foundation

public enum BetaTelemetryDestinationContentMode: OpenEnum, CaseIterable {
    case metadataOnly
    case content
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaTelemetryDestinationContentMode] = [.metadataOnly, .content]

    public init(rawValue: String) {
        switch rawValue {
        case "metadata_only": self = .metadataOnly
        case "content": self = .content
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .metadataOnly: return "metadata_only"
        case .content: return "content"
        case .unknown(let value): return value
        }
    }
}
