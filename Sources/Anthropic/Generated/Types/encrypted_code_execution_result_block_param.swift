// Transformed from `anthropic.types.encrypted_code_execution_result_block_param` (encrypted_code_execution_result_block_param.py).

import Foundation

/// The output and exit code of Python code that Claude ran with the code execution tool, with standard output in encrypted form, sent back in a later request.
public struct EncryptedCodeExecutionResultBlockParam: Codable, Hashable, Sendable {
    public var content: [CodeExecutionOutputBlockParam]
    public var encryptedStdout: String
    public var returnCode: Int
    public var stderr: String
    public var type: String

    public init(content: [CodeExecutionOutputBlockParam], encryptedStdout: String, returnCode: Int, stderr: String, type: String = "encrypted_code_execution_result") {
        self.content = content
        self.encryptedStdout = encryptedStdout
        self.returnCode = returnCode
        self.stderr = stderr
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case encryptedStdout = "encrypted_stdout"
        case returnCode = "return_code"
        case stderr
        case type
    }
}
