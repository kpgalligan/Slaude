// Transformed from `anthropic.types.text_editor_code_execution_create_result_block` (text_editor_code_execution_create_result_block.py).

import Foundation

public struct TextEditorCodeExecutionCreateResultBlock: Codable, Hashable, Sendable {
    public var isFileUpdate: Bool
    public var type: String

    public init(isFileUpdate: Bool, type: String = "text_editor_code_execution_create_result") {
        self.isFileUpdate = isFileUpdate
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case isFileUpdate = "is_file_update"
        case type
    }
}
