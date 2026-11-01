// Transformed from `anthropic.types.text_editor_code_execution_str_replace_result_block_param` (text_editor_code_execution_str_replace_result_block_param.py).

import Foundation

public struct TextEditorCodeExecutionStrReplaceResultBlockParam: Codable, Hashable, Sendable {
    public var type: String
    public var lines: [String]??
    public var newLines: Int??
    public var newStart: Int??
    public var oldLines: Int??
    public var oldStart: Int??

    public init(type: String = "text_editor_code_execution_str_replace_result", lines: [String]?? = nil, newLines: Int?? = nil, newStart: Int?? = nil, oldLines: Int?? = nil, oldStart: Int?? = nil) {
        self.type = type
        self.lines = lines
        self.newLines = newLines
        self.newStart = newStart
        self.oldLines = oldLines
        self.oldStart = oldStart
    }

    enum CodingKeys: String, CodingKey {
        case type
        case lines
        case newLines = "new_lines"
        case newStart = "new_start"
        case oldLines = "old_lines"
        case oldStart = "old_start"
    }
}
