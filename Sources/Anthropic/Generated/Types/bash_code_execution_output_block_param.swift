// Transformed from `anthropic.types.bash_code_execution_output_block_param` (bash_code_execution_output_block_param.py).

import Foundation

public struct BashCodeExecutionOutputBlockParam: Codable, Hashable, Sendable {
    public var fileID: String
    public var type: String

    public init(fileID: String, type: String = "bash_code_execution_output") {
        self.fileID = fileID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case fileID = "file_id"
        case type
    }
}
