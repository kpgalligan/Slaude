// Transformed from `anthropic.types.code_execution_output_block_param` (code_execution_output_block_param.py).

import Foundation

public struct CodeExecutionOutputBlockParam: Codable, Hashable, Sendable {
    public var fileId: String
    public var type: String

    public init(fileId: String, type: String = "code_execution_output") {
        self.fileId = fileId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case type
    }
}
