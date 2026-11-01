// Transformed from `anthropic.types.beta.beta_text_editor_code_execution_tool_result_block` (beta_text_editor_code_execution_tool_result_block.py).

import Foundation

public struct BetaTextEditorCodeExecutionToolResultBlock: Codable, Hashable, Sendable {
    public var content: BetaTextEditorCodeExecutionToolResultBlock.Content
    public var toolUseID: String
    public var type: String

    public init(content: BetaTextEditorCodeExecutionToolResultBlock.Content, toolUseID: String, type: String = "text_editor_code_execution_tool_result") {
        self.content = content
        self.toolUseID = toolUseID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseID = "tool_use_id"
        case type
    }
}

extension BetaTextEditorCodeExecutionToolResultBlock {

    public indirect enum Content: Codable, Hashable, Sendable {
        case textEditorCodeExecutionToolResultError(BetaTextEditorCodeExecutionToolResultError)
        case textEditorCodeExecutionViewResult(BetaTextEditorCodeExecutionViewResultBlock)
        case textEditorCodeExecutionCreateResult(BetaTextEditorCodeExecutionCreateResultBlock)
        case textEditorCodeExecutionStrReplaceResult(BetaTextEditorCodeExecutionStrReplaceResultBlock)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "text_editor_code_execution_tool_result_error": self = .textEditorCodeExecutionToolResultError(try BetaTextEditorCodeExecutionToolResultError(from: decoder))
            case "text_editor_code_execution_view_result": self = .textEditorCodeExecutionViewResult(try BetaTextEditorCodeExecutionViewResultBlock(from: decoder))
            case "text_editor_code_execution_create_result": self = .textEditorCodeExecutionCreateResult(try BetaTextEditorCodeExecutionCreateResultBlock(from: decoder))
            case "text_editor_code_execution_str_replace_result": self = .textEditorCodeExecutionStrReplaceResult(try BetaTextEditorCodeExecutionStrReplaceResultBlock(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .textEditorCodeExecutionToolResultError(let v): try v.encode(to: encoder)
            case .textEditorCodeExecutionViewResult(let v): try v.encode(to: encoder)
            case .textEditorCodeExecutionCreateResult(let v): try v.encode(to: encoder)
            case .textEditorCodeExecutionStrReplaceResult(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
