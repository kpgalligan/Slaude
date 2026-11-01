// Transformed from `anthropic.types.browser_state_change_param` (browser_state_change_param.py).

import Foundation

public indirect enum BrowserStateChangeParam: Codable, Hashable, Sendable {
    case tabOpened(BrowserStateChangeTabOpenedParam)
    case downloadStarted(BrowserStateChangeDownloadStartedParam)
    case downloadCompleted(BrowserStateChangeDownloadCompletedParam)
    case downloadFailed(BrowserStateChangeDownloadFailedParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "tab_opened": self = .tabOpened(try BrowserStateChangeTabOpenedParam(from: decoder))
        case "download_started": self = .downloadStarted(try BrowserStateChangeDownloadStartedParam(from: decoder))
        case "download_completed": self = .downloadCompleted(try BrowserStateChangeDownloadCompletedParam(from: decoder))
        case "download_failed": self = .downloadFailed(try BrowserStateChangeDownloadFailedParam(from: decoder))
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
