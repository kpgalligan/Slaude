// Transformed from `anthropic.types.code_execution_tool_result_block_content` (code_execution_tool_result_block_content.py).

import Foundation

public indirect enum CodeExecutionToolResultBlockContent: Codable, Hashable, Sendable {
    case codeExecutionToolResultError(CodeExecutionToolResultError)
    case codeExecutionResult(CodeExecutionResultBlock)
    case encryptedCodeExecutionResult(EncryptedCodeExecutionResultBlock)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "code_execution_tool_result_error": self = .codeExecutionToolResultError(try CodeExecutionToolResultError(from: decoder))
        case "code_execution_result": self = .codeExecutionResult(try CodeExecutionResultBlock(from: decoder))
        case "encrypted_code_execution_result": self = .encryptedCodeExecutionResult(try EncryptedCodeExecutionResultBlock(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .codeExecutionToolResultError(let v): try v.encode(to: encoder)
        case .codeExecutionResult(let v): try v.encode(to: encoder)
        case .encryptedCodeExecutionResult(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
