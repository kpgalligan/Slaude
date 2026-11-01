// Transformed from `anthropic.types.bash_code_execution_output_block` (bash_code_execution_output_block.py).

import Foundation

public struct BashCodeExecutionOutputBlock: Codable, Hashable, Sendable {
    public var fileId: String
    public var type: String

    public init(fileId: String, type: String = "bash_code_execution_output") {
        self.fileId = fileId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case type
    }
}
