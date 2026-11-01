// Transformed from `anthropic.types.beta.beta_bash_code_execution_output_block` (beta_bash_code_execution_output_block.py).

import Foundation

public struct BetaBashCodeExecutionOutputBlock: Codable, Hashable, Sendable {
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
