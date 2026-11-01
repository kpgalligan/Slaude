// Transformed from `anthropic.types.bash_code_execution_result_block_param` (bash_code_execution_result_block_param.py).

import Foundation

public struct BashCodeExecutionResultBlockParam: Codable, Hashable, Sendable {
    public var content: [BashCodeExecutionOutputBlockParam]
    public var returnCode: Int
    public var stderr: String
    public var stdout: String
    public var type: String

    public init(content: [BashCodeExecutionOutputBlockParam], returnCode: Int, stderr: String, stdout: String, type: String = "bash_code_execution_result") {
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
