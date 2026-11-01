// Transformed from `anthropic.types.beta.beta_browser_file_upload_input` (beta_browser_file_upload_input.py).

import Foundation

/// Set the value of a file-input element to one or more files.
///
/// The target must be an
/// element reference; at least one of paths or document_ids is required.
public struct BetaBrowserFileUploadInput: Codable, Hashable, Sendable {
    /// An element on the page, identified by a reference from a prior `read_page` or
    /// `find` result. References are scoped to the tab that produced them and become
    /// stale after navigation or a major re-render.
    public var target: BetaBrowserRefTarget
    /// References to files the harness has staged, for deployments where the browser
    /// executor cannot read the caller's filesystem.
    public var documentIDs: [String]?
    /// File paths on the browser executor's filesystem.
    public var paths: [String]?
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(target: BetaBrowserRefTarget, documentIDs: [String]? = nil, paths: [String]? = nil, tabID: String? = nil) {
        self.target = target
        self.documentIDs = documentIDs
        self.paths = paths
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case target
        case documentIDs = "document_ids"
        case paths
        case tabID = "tab_id"
    }
}
