// Transformed from `anthropic.types.text_editor_code_execution_str_replace_result_block` (text_editor_code_execution_str_replace_result_block.py).

import Foundation

public struct TextEditorCodeExecutionStrReplaceResultBlock: Codable, Hashable, Sendable {
    public var lines: [String]?
    public var newLines: Int?
    public var newStart: Int?
    public var oldLines: Int?
    public var oldStart: Int?
    public var type: String

    public init(lines: [String]? = nil, newLines: Int? = nil, newStart: Int? = nil, oldLines: Int? = nil, oldStart: Int? = nil, type: String = "text_editor_code_execution_str_replace_result") {
        self.lines = lines
        self.newLines = newLines
        self.newStart = newStart
        self.oldLines = oldLines
        self.oldStart = oldStart
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case lines
        case newLines = "new_lines"
        case newStart = "new_start"
        case oldLines = "old_lines"
        case oldStart = "old_start"
        case type
    }
}
