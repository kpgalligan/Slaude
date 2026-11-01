// Transformed from `anthropic.types.beta.beta_code_execution_result_block` (beta_code_execution_result_block.py).

import Foundation

public struct BetaCodeExecutionResultBlock: Codable, Hashable, Sendable {
    public var content: [BetaCodeExecutionOutputBlock]
    public var returnCode: Int
    public var stderr: String
    public var stdout: String
    public var type: String

    public init(content: [BetaCodeExecutionOutputBlock], returnCode: Int, stderr: String, stdout: String, type: String = "code_execution_result") {
        self.content = content
        self.returnCode = returnCode
        self.stderr = stderr
        self.stdout = stdout
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case returnCode = "return_code"
        case stderr
        case stdout
        case type
    }
}
