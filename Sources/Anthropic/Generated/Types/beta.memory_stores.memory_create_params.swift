// Transformed from `anthropic.types.beta.memory_stores.memory_create_params` (memory_create_params.py).

import Foundation

public struct MemoryCreateParams: Codable, Hashable, Sendable {
    /// The UTF-8 text content of the new memory. Pass `""` to create an empty memory.
    ///
    /// The maximum size is 100 kB (102,400 bytes).
    public var content: String?
    /// The path of the new memory, such as `/projects/foo/notes.md`.
    ///
    /// Paths are case-sensitive.
    ///
    /// A path starts with `/` and has 1 to 20 segments. A segment can't be empty and
    /// can't be `.` or `..`. A path can't contain control characters, format
    /// characters, or the line and paragraph separators U+2028 and U+2029. It must be
    /// in Unicode Normalization Form C and at most 1,024 bytes long.
    public var path: String
    /// Whether a `memory` or `memory_version` in the response includes its `content`.
    ///
    /// Defaults to `full` on retrieve operations and to `basic` on list, create, and
    /// update operations.
    ///
    /// With `full`, list operations return at most 20 items per page.
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

    public init(content: String? = nil, path: String, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.content = content
        self.path = path
        self.view = view
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case content
        case path
        case view
        case betas
        case workspaceId = "workspace_id"
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(content, forKey: .content)
        try c.encode(path, forKey: .path)
        try c.encodeIfPresent(view, forKey: .view)
        try c.encodeIfPresent(betas, forKey: .betas)
        try c.encodeIfPresent(workspaceId, forKey: .workspaceId)
    }
}
