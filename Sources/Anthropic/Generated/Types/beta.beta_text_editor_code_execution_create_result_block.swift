// Transformed from `anthropic.types.beta.beta_text_editor_code_execution_create_result_block` (beta_text_editor_code_execution_create_result_block.py).

import Foundation

public struct BetaTextEditorCodeExecutionCreateResultBlock: Codable, Hashable, Sendable {
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
