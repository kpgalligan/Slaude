// Transformed from `anthropic.types.message_content_param` (message_content_param.py).

import Foundation

public indirect enum MessageContentParam: Codable, Hashable, Sendable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
    case string(String)
    case unions([Unions])
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(stringLiteral value: String) { self = .string(value) }

    public init(arrayLiteral elements: Unions...) { self = .unions(elements) }

    public init(from decoder: Decoder) throws {
        if let v = try? String(from: decoder) { self = .string(v); return }
        if let v = try? [Unions](from: decoder) { self = .unions(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let v): try v.encode(to: encoder)
        case .unions(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }

    public indirect enum Unions: Codable, Hashable, Sendable {
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
            if let v = try? TextBlockParam(from: decoder) { self = .textBlockParam(v); return }
            if let v = try? ImageBlockParam(from: decoder) { self = .imageBlockParam(v); return }
            if let v = try? DocumentBlockParam(from: decoder) { self = .documentBlockParam(v); return }
            if let v = try? SearchResultBlockParam(from: decoder) { self = .searchResultBlockParam(v); return }
            if let v = try? ThinkingBlockParam(from: decoder) { self = .thinkingBlockParam(v); return }
            if let v = try? RedactedThinkingBlockParam(from: decoder) { self = .redactedThinkingBlockParam(v); return }
            if let v = try? ToolUseBlockParam(from: decoder) { self = .toolUseBlockParam(v); return }
            if let v = try? ToolResultBlockParam(from: decoder) { self = .toolResultBlockParam(v); return }
            if let v = try? ServerToolUseBlockParam(from: decoder) { self = .serverToolUseBlockParam(v); return }
            if let v = try? WebSearchToolResultBlockParam(from: decoder) { self = .webSearchToolResultBlockParam(v); return }
            if let v = try? WebFetchToolResultBlockParam(from: decoder) { self = .webFetchToolResultBlockParam(v); return }
            if let v = try? CodeExecutionToolResultBlockParam(from: decoder) { self = .codeExecutionToolResultBlockParam(v); return }
            if let v = try? BashCodeExecutionToolResultBlockParam(from: decoder) { self = .bashCodeExecutionToolResultBlockParam(v); return }
            if let v = try? TextEditorCodeExecutionToolResultBlockParam(from: decoder) { self = .textEditorCodeExecutionToolResultBlockParam(v); return }
            if let v = try? ToolSearchToolResultBlockParam(from: decoder) { self = .toolSearchToolResultBlockParam(v); return }
            if let v = try? ContainerUploadBlockParam(from: decoder) { self = .containerUploadBlockParam(v); return }
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
