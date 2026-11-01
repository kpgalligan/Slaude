// Transformed from `anthropic.types.browser_file_upload_tool_use_block` (browser_file_upload_tool_use_block.py).

import Foundation

public struct BrowserFileUploadToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    /// Which party invoked the tool call: the model directly, or a server tool on its
    /// behalf.
    public var caller: ToolUseCaller
    /// Set the value of a file-input element to one or more files.
    ///
    /// The target must be an element reference; at least one of paths or document_ids
    /// is required.
    public var input: BrowserFileUploadInput
    public var name: String
    public var toolsetName: String
    public var type: String

    public init(id: String, caller: ToolUseCaller, input: BrowserFileUploadInput, name: String = "file_upload", toolsetName: String = "browser", type: String = "tool_use") {
        self.id = id
        self.caller = caller
        self.input = input
        self.name = name
        self.toolsetName = toolsetName
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case caller
        case input
        case name
        case toolsetName = "toolset_name"
        case type
    }
}
