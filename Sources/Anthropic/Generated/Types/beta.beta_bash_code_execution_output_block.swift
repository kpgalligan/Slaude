// Transformed from `anthropic.types.beta.beta_bash_code_execution_output_block` (beta_bash_code_execution_output_block.py).

import Foundation

public struct BetaBashCodeExecutionOutputBlock: Codable, Hashable, Sendable {
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
