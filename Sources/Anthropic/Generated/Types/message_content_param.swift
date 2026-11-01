// Transformed from `anthropic.types.message_content_param` (message_content_param.py).

import Foundation

public indirect enum MessageContentParam: Codable, Hashable, Sendable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
    case string(String)
    case items([Item])
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(stringLiteral value: String) { self = .string(value) }

    public init(arrayLiteral elements: Item...) { self = .items(elements) }

    public init(from decoder: Decoder) throws {
        if let v = try? String(from: decoder) { self = .string(v); return }
        if let v = try? [Item](from: decoder) { self = .items(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let v): try v.encode(to: encoder)
        case .items(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }

    public indirect enum Item: Codable, Hashable, Sendable {
        case textBlockParam(TextBlockParam)
        case imageBlockParam(ImageBlockParam)
        case documentBlockParam(DocumentBlockParam)
        case searchResultBlockParam(SearchResultBlockParam)
        case thinkingBlockParam(ThinkingBlockParam)
        case redactedThinkingBlockParam(RedactedThinkingBlockParam)
        case toolUseBlockParam(ToolUseBlockParam)
        case toolResultBlockParam(ToolResultBlockParam)
        case serverToolUseBlockParam(ServerToolUseBlockParam)
        case webSearchToolResultBlockParam(WebSearchToolResultBlockParam)
        case webFetchToolResultBlockParam(WebFetchToolResultBlockParam)
        case codeExecutionToolResultBlockParam(CodeExecutionToolResultBlockParam)
        case bashCodeExecutionToolResultBlockParam(BashCodeExecutionToolResultBlockParam)
        case textEditorCodeExecutionToolResultBlockParam(TextEditorCodeExecutionToolResultBlockParam)
        case toolSearchToolResultBlockParam(ToolSearchToolResultBlockParam)
        case containerUploadBlockParam(ContainerUploadBlockParam)
        case contentBlock(ContentBlock)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            if _Coding.constantsMatch(decoder, ["type": "text"]), let v = try? TextBlockParam(from: decoder) { self = .textBlockParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "image"]), let v = try? ImageBlockParam(from: decoder) { self = .imageBlockParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "document"]), let v = try? DocumentBlockParam(from: decoder) { self = .documentBlockParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "search_result"]), let v = try? SearchResultBlockParam(from: decoder) { self = .searchResultBlockParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "thinking"]), let v = try? ThinkingBlockParam(from: decoder) { self = .thinkingBlockParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "redacted_thinking"]), let v = try? RedactedThinkingBlockParam(from: decoder) { self = .redactedThinkingBlockParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "tool_use"]), let v = try? ToolUseBlockParam(from: decoder) { self = .toolUseBlockParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "tool_result"]), let v = try? ToolResultBlockParam(from: decoder) { self = .toolResultBlockParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "server_tool_use"]), let v = try? ServerToolUseBlockParam(from: decoder) { self = .serverToolUseBlockParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "web_search_tool_result"]), let v = try? WebSearchToolResultBlockParam(from: decoder) { self = .webSearchToolResultBlockParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "web_fetch_tool_result"]), let v = try? WebFetchToolResultBlockParam(from: decoder) { self = .webFetchToolResultBlockParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "code_execution_tool_result"]), let v = try? CodeExecutionToolResultBlockParam(from: decoder) { self = .codeExecutionToolResultBlockParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "bash_code_execution_tool_result"]), let v = try? BashCodeExecutionToolResultBlockParam(from: decoder) { self = .bashCodeExecutionToolResultBlockParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "text_editor_code_execution_tool_result"]), let v = try? TextEditorCodeExecutionToolResultBlockParam(from: decoder) { self = .textEditorCodeExecutionToolResultBlockParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "tool_search_tool_result"]), let v = try? ToolSearchToolResultBlockParam(from: decoder) { self = .toolSearchToolResultBlockParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "container_upload"]), let v = try? ContainerUploadBlockParam(from: decoder) { self = .containerUploadBlockParam(v); return }
            if let v = try? ContentBlock(from: decoder) { self = .contentBlock(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .textBlockParam(let v): try v.encode(to: encoder)
            case .imageBlockParam(let v): try v.encode(to: encoder)
            case .documentBlockParam(let v): try v.encode(to: encoder)
            case .searchResultBlockParam(let v): try v.encode(to: encoder)
            case .thinkingBlockParam(let v): try v.encode(to: encoder)
            case .redactedThinkingBlockParam(let v): try v.encode(to: encoder)
            case .toolUseBlockParam(let v): try v.encode(to: encoder)
            case .toolResultBlockParam(let v): try v.encode(to: encoder)
            case .serverToolUseBlockParam(let v): try v.encode(to: encoder)
            case .webSearchToolResultBlockParam(let v): try v.encode(to: encoder)
            case .webFetchToolResultBlockParam(let v): try v.encode(to: encoder)
            case .codeExecutionToolResultBlockParam(let v): try v.encode(to: encoder)
            case .bashCodeExecutionToolResultBlockParam(let v): try v.encode(to: encoder)
            case .textEditorCodeExecutionToolResultBlockParam(let v): try v.encode(to: encoder)
            case .toolSearchToolResultBlockParam(let v): try v.encode(to: encoder)
            case .containerUploadBlockParam(let v): try v.encode(to: encoder)
            case .contentBlock(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
