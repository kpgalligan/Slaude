// Transformed from `anthropic.types.beta.beta_code_execution_tool_result_block_param_content_param` (beta_code_execution_tool_result_block_param_content_param.py).

import Foundation

public indirect enum BetaCodeExecutionToolResultBlockParamContentParam: Codable, Hashable, Sendable {
    case codeExecutionToolResultError(BetaCodeExecutionToolResultErrorParam)
    case codeExecutionResult(BetaCodeExecutionResultBlockParam)
    case encryptedCodeExecutionResult(BetaEncryptedCodeExecutionResultBlockParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "code_execution_tool_result_error": self = .codeExecutionToolResultError(try BetaCodeExecutionToolResultErrorParam(from: decoder))
        case "code_execution_result": self = .codeExecutionResult(try BetaCodeExecutionResultBlockParam(from: decoder))
        case "encrypted_code_execution_result": self = .encryptedCodeExecutionResult(try BetaEncryptedCodeExecutionResultBlockParam(from: decoder))
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
