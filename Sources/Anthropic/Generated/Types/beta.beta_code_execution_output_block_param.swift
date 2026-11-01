// Transformed from `anthropic.types.beta.beta_code_execution_output_block_param` (beta_code_execution_output_block_param.py).

import Foundation

public struct BetaCodeExecutionOutputBlockParam: Codable, Hashable, Sendable {
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
