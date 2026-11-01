// Transformed from `anthropic.types.beta.beta_browser_state_change_download_completed_param` (beta_browser_state_change_download_completed_param.py).

import Foundation

/// A file download that finished during this call, reported with the
/// same `download_id` as its `download_started` — or without a prior
/// `download_started`, when the download finished during the call that
/// started it (at most one state change per `download_id` per result).
public struct BetaBrowserStateChangeDownloadCompletedParam: Codable, Hashable, Sendable {
    /// The caller-assigned identifier for this download, stable across the state
    /// changes reporting it.
    public var downloadId: String
    public var type: String
    /// The final post-redirect URL the download was served from.
    public var url: String
    /// Where the executor saved the file, on the executor's filesystem.
    ///
    /// Only included when another tool in the same environment can read the file at
    /// that path.
    public var path: String??
    /// The completed download's size.
    public var sizeBytes: Int??

    public init(downloadId: String, type: String = "download_completed", url: String, path: String?? = nil, sizeBytes: Int?? = nil) {
        self.downloadId = downloadId
        self.type = type
        self.url = url
        self.path = path
        self.sizeBytes = sizeBytes
    }

    enum CodingKeys: String, CodingKey {
        case downloadId = "download_id"
        case type
        case url
        case path
        case sizeBytes = "size_bytes"
    }
}
