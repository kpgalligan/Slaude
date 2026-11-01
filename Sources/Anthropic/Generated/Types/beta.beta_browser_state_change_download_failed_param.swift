// Transformed from `anthropic.types.beta.beta_browser_state_change_download_failed_param` (beta_browser_state_change_download_failed_param.py).

import Foundation

/// A file download that failed — or was cancelled — during this call.
public struct BetaBrowserStateChangeDownloadFailedParam: Codable, Hashable, Sendable {
    /// The caller-assigned identifier for this download, stable across the state
    /// changes reporting it.
    public var downloadID: String
    public var type: String
    /// The final post-redirect URL the download was served from.
    public var url: String
    /// The failure or cancellation detail, when known.
    public var error: String??

    public init(downloadID: String, type: String = "download_failed", url: String, error: String?? = nil) {
        self.downloadID = downloadID
        self.type = type
        self.url = url
        self.error = error
    }

    enum CodingKeys: String, CodingKey {
        case downloadID = "download_id"
        case type
        case url
        case error
    }
}
