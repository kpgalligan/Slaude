// Transformed from `anthropic.types.parsed_message` (parsed_message.py).

import Foundation



public indirect enum ParsedMessageParsedContentBlock: Codable, Hashable, Sendable {
    case json(JSONValue)
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
        let tag = _Coding.discriminator(decoder, "type")
        if tag == "thinking" { self = .thinking(try ThinkingBlock(from: decoder)); return }
        if tag == "redacted_thinking" { self = .redactedThinking(try RedactedThinkingBlock(from: decoder)); return }
        if tag == "tool_use" { self = .toolUse(try ToolUseBlock(from: decoder)); return }
        if tag == "server_tool_use" { self = .serverToolUse(try ServerToolUseBlock(from: decoder)); return }
        if tag == "web_search_tool_result" { self = .webSearchToolResult(try WebSearchToolResultBlock(from: decoder)); return }
        if tag == "web_fetch_tool_result" { self = .webFetchToolResult(try WebFetchToolResultBlock(from: decoder)); return }
        if tag == "code_execution_tool_result" { self = .codeExecutionToolResult(try CodeExecutionToolResultBlock(from: decoder)); return }
        if tag == "bash_code_execution_tool_result" { self = .bashCodeExecutionToolResult(try BashCodeExecutionToolResultBlock(from: decoder)); return }
        if tag == "text_editor_code_execution_tool_result" { self = .textEditorCodeExecutionToolResult(try TextEditorCodeExecutionToolResultBlock(from: decoder)); return }
        if tag == "tool_search_tool_result" { self = .toolSearchToolResult(try ToolSearchToolResultBlock(from: decoder)); return }
        if tag == "container_upload" { self = .containerUpload(try ContainerUploadBlock(from: decoder)); return }
        if let v = try? JSONValue(from: decoder) { self = .json(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .json(let v): try v.encode(to: encoder)
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
