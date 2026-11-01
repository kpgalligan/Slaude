// Transformed from `anthropic.types.code_execution_output_block_param` (code_execution_output_block_param.py).

import Foundation

public struct CodeExecutionOutputBlockParam: Codable, Hashable, Sendable {
    public var fileID: String
    public var type: String

    public init(fileID: String, type: String = "code_execution_output") {
        self.fileID = fileID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case fileID = "file_id"
        case type
    }
}
