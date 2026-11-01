// Transformed from `anthropic.types.content_block_param` (content_block_param.py).

import Foundation

public indirect enum ContentBlockParam: Codable, Hashable, Sendable {
    case text(TextBlockParam)
    case image(ImageBlockParam)
    case document(DocumentBlockParam)
    case searchResult(SearchResultBlockParam)
    case thinking(ThinkingBlockParam)
    case redactedThinking(RedactedThinkingBlockParam)
    case toolUse(ToolUseBlockParam)
    case toolResult(ToolResultBlockParam)
    case serverToolUse(ServerToolUseBlockParam)
    case webSearchToolResult(WebSearchToolResultBlockParam)
    case webFetchToolResult(WebFetchToolResultBlockParam)
    case codeExecutionToolResult(CodeExecutionToolResultBlockParam)
    case bashCodeExecutionToolResult(BashCodeExecutionToolResultBlockParam)
    case textEditorCodeExecutionToolResult(TextEditorCodeExecutionToolResultBlockParam)
    case toolSearchToolResult(ToolSearchToolResultBlockParam)
    case containerUpload(ContainerUploadBlockParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "text": self = .text(try TextBlockParam(from: decoder))
        case "image": self = .image(try ImageBlockParam(from: decoder))
        case "document": self = .document(try DocumentBlockParam(from: decoder))
        case "search_result": self = .searchResult(try SearchResultBlockParam(from: decoder))
        case "thinking": self = .thinking(try ThinkingBlockParam(from: decoder))
        case "redacted_thinking": self = .redactedThinking(try RedactedThinkingBlockParam(from: decoder))
        case "tool_use": self = .toolUse(try ToolUseBlockParam(from: decoder))
        case "tool_result": self = .toolResult(try ToolResultBlockParam(from: decoder))
        case "server_tool_use": self = .serverToolUse(try ServerToolUseBlockParam(from: decoder))
        case "web_search_tool_result": self = .webSearchToolResult(try WebSearchToolResultBlockParam(from: decoder))
        case "web_fetch_tool_result": self = .webFetchToolResult(try WebFetchToolResultBlockParam(from: decoder))
        case "code_execution_tool_result": self = .codeExecutionToolResult(try CodeExecutionToolResultBlockParam(from: decoder))
        case "bash_code_execution_tool_result": self = .bashCodeExecutionToolResult(try BashCodeExecutionToolResultBlockParam(from: decoder))
        case "text_editor_code_execution_tool_result": self = .textEditorCodeExecutionToolResult(try TextEditorCodeExecutionToolResultBlockParam(from: decoder))
        case "tool_search_tool_result": self = .toolSearchToolResult(try ToolSearchToolResultBlockParam(from: decoder))
        case "container_upload": self = .containerUpload(try ContainerUploadBlockParam(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let v): try v.encode(to: encoder)
        case .image(let v): try v.encode(to: encoder)
        case .document(let v): try v.encode(to: encoder)
        case .searchResult(let v): try v.encode(to: encoder)
        case .thinking(let v): try v.encode(to: encoder)
        case .redactedThinking(let v): try v.encode(to: encoder)
        case .toolUse(let v): try v.encode(to: encoder)
        case .toolResult(let v): try v.encode(to: encoder)
        case .serverToolUse(let v): try v.encode(to: encoder)
        case .webSearchToolResult(let v): try v.encode(to: encoder)
        case .webFetchToolResult(let v): try v.encode(to: encoder)
        case .codeExecutionToolResult(let v): try v.encode(to: encoder)
        case .bashCodeExecutionToolResult(let v): try v.encode(to: encoder)
        case .textEditorCodeExecutionToolResult(let v): try v.encode(to: encoder)
        case .toolSearchToolResult(let v): try v.encode(to: encoder)
        case .containerUpload(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
