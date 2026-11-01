// Transformed from `anthropic.types.beta.beta_text_editor_code_execution_tool_result_block_param` (beta_text_editor_code_execution_tool_result_block_param.py).

import Foundation

public struct BetaTextEditorCodeExecutionToolResultBlockParam: Codable, Hashable, Sendable {
    public var content: BetaTextEditorCodeExecutionToolResultBlockParam.Content
    public var toolUseId: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??

    public init(content: BetaTextEditorCodeExecutionToolResultBlockParam.Content, toolUseId: String, type: String = "text_editor_code_execution_tool_result", cacheControl: BetaCacheControlEphemeralParam?? = nil) {
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

extension BetaTextEditorCodeExecutionToolResultBlockParam {

    public indirect enum Content: Codable, Hashable, Sendable {
        case textEditorCodeExecutionToolResultError(BetaTextEditorCodeExecutionToolResultErrorParam)
        case textEditorCodeExecutionViewResult(BetaTextEditorCodeExecutionViewResultBlockParam)
        case textEditorCodeExecutionCreateResult(BetaTextEditorCodeExecutionCreateResultBlockParam)
        case textEditorCodeExecutionStrReplaceResult(BetaTextEditorCodeExecutionStrReplaceResultBlockParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "text_editor_code_execution_tool_result_error": self = .textEditorCodeExecutionToolResultError(try BetaTextEditorCodeExecutionToolResultErrorParam(from: decoder))
            case "text_editor_code_execution_view_result": self = .textEditorCodeExecutionViewResult(try BetaTextEditorCodeExecutionViewResultBlockParam(from: decoder))
            case "text_editor_code_execution_create_result": self = .textEditorCodeExecutionCreateResult(try BetaTextEditorCodeExecutionCreateResultBlockParam(from: decoder))
            case "text_editor_code_execution_str_replace_result": self = .textEditorCodeExecutionStrReplaceResult(try BetaTextEditorCodeExecutionStrReplaceResultBlockParam(from: decoder))
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
