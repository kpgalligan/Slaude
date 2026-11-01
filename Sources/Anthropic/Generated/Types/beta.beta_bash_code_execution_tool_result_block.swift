// Transformed from `anthropic.types.beta.beta_bash_code_execution_tool_result_block` (beta_bash_code_execution_tool_result_block.py).

import Foundation

public struct BetaBashCodeExecutionToolResultBlock: Codable, Hashable, Sendable {
    public var content: BetaBashCodeExecutionToolResultBlock.Content
    public var toolUseId: String
    public var type: String

    public init(content: BetaBashCodeExecutionToolResultBlock.Content, toolUseId: String, type: String = "bash_code_execution_tool_result") {
        self.content = content
        self.toolUseId = toolUseId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseId = "tool_use_id"
        case type
    }
}

extension BetaBashCodeExecutionToolResultBlock {

    public indirect enum Content: Codable, Hashable, Sendable {
        case bashCodeExecutionToolResultError(BetaBashCodeExecutionToolResultError)
        case bashCodeExecutionResult(BetaBashCodeExecutionResultBlock)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "bash_code_execution_tool_result_error": self = .bashCodeExecutionToolResultError(try BetaBashCodeExecutionToolResultError(from: decoder))
            case "bash_code_execution_result": self = .bashCodeExecutionResult(try BetaBashCodeExecutionResultBlock(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .bashCodeExecutionToolResultError(let v): try v.encode(to: encoder)
            case .bashCodeExecutionResult(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
