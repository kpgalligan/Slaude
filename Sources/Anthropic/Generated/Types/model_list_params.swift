// Transformed from `anthropic.types.model_list_params` (model_list_params.py).

import Foundation

public struct ModelListParams: Codable, Hashable, Sendable {
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately after this object.
    public var afterID: String?
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately before this object.
    public var beforeID: String?
    /// Filter the list to models in any of the given lifecycle stages (`active`,
    /// `deprecated`, or `retired`). Up to 3 values. When omitted, the list contains the
    /// `active` and `deprecated` models; `retired` models appear only when `retired` is
    /// requested explicitly.
    public var lifecycle: [Lifecycle]?
    /// Number of items to return per page.
    ///
    /// Defaults to `20`. Ranges from `1` to `1000`.
    public var limit: Int?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(afterID: String? = nil, beforeID: String? = nil, lifecycle: [Lifecycle]? = nil, limit: Int? = nil, workspaceID: String? = nil) {
        self.afterID = afterID
        self.beforeID = beforeID
        self.lifecycle = lifecycle
        self.limit = limit
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case afterID = "after_id"
        case beforeID = "before_id"
        case lifecycle
        case limit
        case workspaceID = "workspace_id"
    }

    public enum Lifecycle: OpenEnum, CaseIterable {
        case active
        case deprecated
        case retired
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Lifecycle] = [.active, .deprecated, .retired]

        public init(rawValue: String) {
            switch rawValue {
            case "active": self = .active
            case "deprecated": self = .deprecated
            case "retired": self = .retired
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .active: return "active"
            case .deprecated: return "deprecated"
            case .retired: return "retired"
            case .unknown(let value): return value
            }
        }
    }
}
