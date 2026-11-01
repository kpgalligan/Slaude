// Transformed from `anthropic.types.content_block` (content_block.py).

import Foundation

public indirect enum ContentBlock: Codable, Hashable, Sendable {
    case text(TextBlock)
    case thinking(ThinkingBlock)
    case redactedThinking(RedactedThinkingBlock)
    case toolUse(ToolUseBlock)
    case serverToolUse(ServerToolUseBlock)
    case webSearchToolResult(WebSearchToolResultBlock)
    case webFetchToolResult(WebFetchToolResultBlock)
    case codeExecutionToolResult(CodeExecutionToolResultBlock)
    case bashCodeExecutionToolResult(BashCodeExecutionToolResultBlock)
    case textEditorCodeExecutionToolResult(TextEditorCodeExecutionToolResultBlock)
    case toolSearchToolResult(ToolSearchToolResultBlock)
    case containerUpload(ContainerUploadBlock)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "text": self = .text(try TextBlock(from: decoder))
        case "thinking": self = .thinking(try ThinkingBlock(from: decoder))
        case "redacted_thinking": self = .redactedThinking(try RedactedThinkingBlock(from: decoder))
        case "tool_use": self = .toolUse(try ToolUseBlock(from: decoder))
        case "server_tool_use": self = .serverToolUse(try ServerToolUseBlock(from: decoder))
        case "web_search_tool_result": self = .webSearchToolResult(try WebSearchToolResultBlock(from: decoder))
        case "web_fetch_tool_result": self = .webFetchToolResult(try WebFetchToolResultBlock(from: decoder))
        case "code_execution_tool_result": self = .codeExecutionToolResult(try CodeExecutionToolResultBlock(from: decoder))
        case "bash_code_execution_tool_result": self = .bashCodeExecutionToolResult(try BashCodeExecutionToolResultBlock(from: decoder))
        case "text_editor_code_execution_tool_result": self = .textEditorCodeExecutionToolResult(try TextEditorCodeExecutionToolResultBlock(from: decoder))
        case "tool_search_tool_result": self = .toolSearchToolResult(try ToolSearchToolResultBlock(from: decoder))
        case "container_upload": self = .containerUpload(try ContainerUploadBlock(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let v): try v.encode(to: encoder)
        case .thinking(let v): try v.encode(to: encoder)
        case .redactedThinking(let v): try v.encode(to: encoder)
        case .toolUse(let v): try v.encode(to: encoder)
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
