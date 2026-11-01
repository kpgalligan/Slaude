// Transformed from `anthropic.types.beta.beta_browser_state_change_param` (beta_browser_state_change_param.py).

import Foundation

public indirect enum BetaBrowserStateChangeParam: Codable, Hashable, Sendable {
    case tabOpened(BetaBrowserStateChangeTabOpenedParam)
    case downloadStarted(BetaBrowserStateChangeDownloadStartedParam)
    case downloadCompleted(BetaBrowserStateChangeDownloadCompletedParam)
    case downloadFailed(BetaBrowserStateChangeDownloadFailedParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "tab_opened": self = .tabOpened(try BetaBrowserStateChangeTabOpenedParam(from: decoder))
        case "download_started": self = .downloadStarted(try BetaBrowserStateChangeDownloadStartedParam(from: decoder))
        case "download_completed": self = .downloadCompleted(try BetaBrowserStateChangeDownloadCompletedParam(from: decoder))
        case "download_failed": self = .downloadFailed(try BetaBrowserStateChangeDownloadFailedParam(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .tabOpened(let v): try v.encode(to: encoder)
        case .downloadStarted(let v): try v.encode(to: encoder)
        case .downloadCompleted(let v): try v.encode(to: encoder)
        case .downloadFailed(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
