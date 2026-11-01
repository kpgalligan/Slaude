// Transformed from `anthropic.types.text_editor_code_execution_tool_result_block_param` (text_editor_code_execution_tool_result_block_param.py).

import Foundation

public struct TextEditorCodeExecutionToolResultBlockParam: Codable, Hashable, Sendable {
    public var content: TextEditorCodeExecutionToolResultBlockParam.Content
    public var toolUseId: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??

    public init(content: TextEditorCodeExecutionToolResultBlockParam.Content, toolUseId: String, type: String = "text_editor_code_execution_tool_result", cacheControl: CacheControlEphemeralParam?? = nil) {
        self.content = content
        self.toolUseId = toolUseId
        self.type = type
        self.cacheControl = cacheControl
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseId = "tool_use_id"
        case type
        case cacheControl = "cache_control"
    }
}

extension TextEditorCodeExecutionToolResultBlockParam {

    public indirect enum Content: Codable, Hashable, Sendable {
        case textEditorCodeExecutionToolResultError(TextEditorCodeExecutionToolResultErrorParam)
        case textEditorCodeExecutionViewResult(TextEditorCodeExecutionViewResultBlockParam)
        case textEditorCodeExecutionCreateResult(TextEditorCodeExecutionCreateResultBlockParam)
        case textEditorCodeExecutionStrReplaceResult(TextEditorCodeExecutionStrReplaceResultBlockParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "text_editor_code_execution_tool_result_error": self = .textEditorCodeExecutionToolResultError(try TextEditorCodeExecutionToolResultErrorParam(from: decoder))
            case "text_editor_code_execution_view_result": self = .textEditorCodeExecutionViewResult(try TextEditorCodeExecutionViewResultBlockParam(from: decoder))
            case "text_editor_code_execution_create_result": self = .textEditorCodeExecutionCreateResult(try TextEditorCodeExecutionCreateResultBlockParam(from: decoder))
            case "text_editor_code_execution_str_replace_result": self = .textEditorCodeExecutionStrReplaceResult(try TextEditorCodeExecutionStrReplaceResultBlockParam(from: decoder))
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
