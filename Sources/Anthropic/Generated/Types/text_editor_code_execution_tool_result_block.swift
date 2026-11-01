// Transformed from `anthropic.types.text_editor_code_execution_tool_result_block` (text_editor_code_execution_tool_result_block.py).

import Foundation

public struct TextEditorCodeExecutionToolResultBlock: Codable, Hashable, Sendable {
    public var content: TextEditorCodeExecutionToolResultBlock.Content
    public var toolUseID: String
    public var type: String

    public init(content: TextEditorCodeExecutionToolResultBlock.Content, toolUseID: String, type: String = "text_editor_code_execution_tool_result") {
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

extension TextEditorCodeExecutionToolResultBlock {

    public indirect enum Content: Codable, Hashable, Sendable {
        case textEditorCodeExecutionToolResultError(TextEditorCodeExecutionToolResultError)
        case textEditorCodeExecutionViewResult(TextEditorCodeExecutionViewResultBlock)
        case textEditorCodeExecutionCreateResult(TextEditorCodeExecutionCreateResultBlock)
        case textEditorCodeExecutionStrReplaceResult(TextEditorCodeExecutionStrReplaceResultBlock)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "text_editor_code_execution_tool_result_error": self = .textEditorCodeExecutionToolResultError(try TextEditorCodeExecutionToolResultError(from: decoder))
            case "text_editor_code_execution_view_result": self = .textEditorCodeExecutionViewResult(try TextEditorCodeExecutionViewResultBlock(from: decoder))
            case "text_editor_code_execution_create_result": self = .textEditorCodeExecutionCreateResult(try TextEditorCodeExecutionCreateResultBlock(from: decoder))
            case "text_editor_code_execution_str_replace_result": self = .textEditorCodeExecutionStrReplaceResult(try TextEditorCodeExecutionStrReplaceResultBlock(from: decoder))
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
