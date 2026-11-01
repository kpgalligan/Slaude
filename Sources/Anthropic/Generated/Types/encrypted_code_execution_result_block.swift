// Transformed from `anthropic.types.encrypted_code_execution_result_block` (encrypted_code_execution_result_block.py).

import Foundation

/// The output and exit code of Python code that Claude ran with the code execution tool, with standard output in encrypted form.
///
/// The API returns this block in place of `code_execution_result` when the code called the web search tool.
///
/// See the [programmatic tool calling guide](https://platform.claude.com/docs/en/agents-and-tools/tool-use/programmatic-tool-calling) to learn more about programmatic tool calling.
public struct EncryptedCodeExecutionResultBlock: Codable, Hashable, Sendable {
    public var content: [CodeExecutionOutputBlock]
    public var encryptedStdout: String
    public var returnCode: Int
    public var stderr: String
    public var type: String

    public init(content: [CodeExecutionOutputBlock], encryptedStdout: String, returnCode: Int, stderr: String, type: String = "encrypted_code_execution_result") {
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
