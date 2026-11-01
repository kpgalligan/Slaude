// Transformed from `anthropic.types.beta.beta_managed_agents_agent_toolset20260401_edit_input` (beta_managed_agents_agent_toolset20260401_edit_input.py).

import Foundation

/// Input payload for the `edit` tool.
///
/// Performs a string
/// replacement in the named file; by default `old_string` must
/// occur exactly once.
public struct BetaManagedAgentsAgentToolset20260401EditInput: Codable, Hashable, Sendable {
    /// Path of the file to edit.
    public var filePath: String
    /// Replacement text.
    public var newString: String
    /// Substring to find and replace.
    public var oldString: String
    /// When true, replace every occurrence of `old_string` instead of requiring a
    /// unique match.
    public var replaceAll: Bool?

    public init(filePath: String, newString: String, oldString: String, replaceAll: Bool? = nil) {
        self.filePath = filePath
        self.newString = newString
        self.oldString = oldString
        self.replaceAll = replaceAll
    }

    enum CodingKeys: String, CodingKey {
        case filePath = "file_path"
        case newString = "new_string"
        case oldString = "old_string"
        case replaceAll = "replace_all"
    }
}
