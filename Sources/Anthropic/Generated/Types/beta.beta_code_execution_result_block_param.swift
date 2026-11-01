// Transformed from `anthropic.types.beta.beta_code_execution_result_block_param` (beta_code_execution_result_block_param.py).

import Foundation

public struct BetaCodeExecutionResultBlockParam: Codable, Hashable, Sendable {
    public var content: [BetaCodeExecutionOutputBlockParam]
    public var returnCode: Int
    public var stderr: String
    public var stdout: String
    public var type: String

    public init(content: [BetaCodeExecutionOutputBlockParam], returnCode: Int, stderr: String, stdout: String, type: String = "code_execution_result") {
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
