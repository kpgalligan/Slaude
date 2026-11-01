// Transformed from `anthropic.types.browser_state_change_download_started_param` (browser_state_change_download_started_param.py).

import Foundation

/// A file download that started during this call.
public struct BrowserStateChangeDownloadStartedParam: Codable, Hashable, Sendable {
    /// The caller-assigned identifier for this download, stable across the state
    /// changes reporting it.
    public var downloadId: String
    public var type: String
    /// The final post-redirect URL the download was served from.
    public var url: String

    public init(downloadId: String, type: String = "download_started", url: String) {
        self.downloadId = downloadId
        self.type = type
        self.url = url
    }

    enum CodingKeys: String, CodingKey {
        case downloadId = "download_id"
        case type
        case url
    }
}
