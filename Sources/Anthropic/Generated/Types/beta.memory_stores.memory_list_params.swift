// Transformed from `anthropic.types.beta.memory_stores.memory_list_params` (memory_list_params.py).

import Foundation

public struct MemoryListParams: Codable, Hashable, Sendable {
    /// How far below `path_prefix` to list.
    ///
    /// Defaults to `0`, which lists every memory below the prefix.
    ///
    /// Pass `1` to list only the direct children. Deeper memories are then grouped into
    /// `memory_prefix` items.
    public var depth: Int?
    /// The maximum number of items to return per page, from 1 to 100. Defaults to 20.
    ///
    /// With `view=full`, a page holds at most 20 items. `memory` and `memory_prefix`
    /// items both count toward the limit.
    public var limit: Int?
    /// The `next_page` value from a previous response, to get the next page.
    ///
    /// Omit it to get the first page.
    public var page: String?
    /// Return only memories whose path starts with this prefix, such as `/notes/`.
    ///
    /// This value appears in request URLs. Do not include secrets or personally
    /// identifiable information.
    ///
    /// Omit it to list the whole store. The prefix must end with `/` and matches whole
    /// segments, so `/notes/` matches `/notes/todo.md` but not
    /// `/notes-archive/todo.md`.
    public var pathPrefix: String?
    /// Whether each memory in the response includes `content`.
    ///
    /// Defaults to `basic`, which sets it to `null`.
    ///
    /// With `full`, a page holds at most 20 items.
    public var view: BetaManagedAgentsMemoryView?
    /// This endpoint is in beta: requests must send `agent-memory-2026-07-22` or
    /// `managed-agents-2026-04-01` in this header.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceId: String?

    public init(depth: Int? = nil, limit: Int? = nil, page: String? = nil, pathPrefix: String? = nil, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.depth = depth
        self.limit = limit
        self.page = page
        self.pathPrefix = pathPrefix
        self.view = view
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case depth
        case limit
        case page
        case pathPrefix = "path_prefix"
        case view
        case betas
        case workspaceId = "workspace_id"
    }
}
