// Transformed from `anthropic.types.code_execution_tool_result_block_param_content_param` (code_execution_tool_result_block_param_content_param.py).

import Foundation

public indirect enum CodeExecutionToolResultBlockParamContentParam: Codable, Hashable, Sendable {
    case codeExecutionToolResultError(CodeExecutionToolResultErrorParam)
    case codeExecutionResult(CodeExecutionResultBlockParam)
    case encryptedCodeExecutionResult(EncryptedCodeExecutionResultBlockParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "code_execution_tool_result_error": self = .codeExecutionToolResultError(try CodeExecutionToolResultErrorParam(from: decoder))
        case "code_execution_result": self = .codeExecutionResult(try CodeExecutionResultBlockParam(from: decoder))
        case "encrypted_code_execution_result": self = .encryptedCodeExecutionResult(try EncryptedCodeExecutionResultBlockParam(from: decoder))
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
