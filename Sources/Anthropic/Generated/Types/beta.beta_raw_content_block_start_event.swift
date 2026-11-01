// Transformed from `anthropic.types.beta.beta_raw_content_block_start_event` (beta_raw_content_block_start_event.py).

import Foundation

public struct BetaRawContentBlockStartEvent: Codable, Hashable, Sendable {
    public var contentBlock: BetaRawContentBlockStartEvent.ContentBlock
    public var index: Int
    public var type: String

    public init(contentBlock: BetaRawContentBlockStartEvent.ContentBlock, index: Int, type: String = "content_block_start") {
        self.contentBlock = contentBlock
        self.index = index
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case contentBlock = "content_block"
        case index
        case type
    }
}

extension BetaRawContentBlockStartEvent {

    public indirect enum ContentBlock: Codable, Hashable, Sendable {
        case text(BetaTextBlock)
        case thinking(BetaThinkingBlock)
        case redactedThinking(BetaRedactedThinkingBlock)
        case toolUse(BetaToolUseBlock)
        case serverToolUse(BetaServerToolUseBlock)
        case webSearchToolResult(BetaWebSearchToolResultBlock)
        case webFetchToolResult(BetaWebFetchToolResultBlock)
        case advisorToolResult(BetaAdvisorToolResultBlock)
        case codeExecutionToolResult(BetaCodeExecutionToolResultBlock)
        case bashCodeExecutionToolResult(BetaBashCodeExecutionToolResultBlock)
        case textEditorCodeExecutionToolResult(BetaTextEditorCodeExecutionToolResultBlock)
        case toolSearchToolResult(BetaToolSearchToolResultBlock)
        case mcpToolUse(BetaMCPToolUseBlock)
        case mcpToolResult(BetaMCPToolResultBlock)
        case containerUpload(BetaContainerUploadBlock)
        case compaction(BetaCompactionBlock)
        case fallback(BetaFallbackBlock)
        case mcpToolListing(BetaMCPToolListingBlock)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "text": self = .text(try BetaTextBlock(from: decoder))
            case "thinking": self = .thinking(try BetaThinkingBlock(from: decoder))
            case "redacted_thinking": self = .redactedThinking(try BetaRedactedThinkingBlock(from: decoder))
            case "tool_use": self = .toolUse(try BetaToolUseBlock(from: decoder))
            case "server_tool_use": self = .serverToolUse(try BetaServerToolUseBlock(from: decoder))
            case "web_search_tool_result": self = .webSearchToolResult(try BetaWebSearchToolResultBlock(from: decoder))
            case "web_fetch_tool_result": self = .webFetchToolResult(try BetaWebFetchToolResultBlock(from: decoder))
            case "advisor_tool_result": self = .advisorToolResult(try BetaAdvisorToolResultBlock(from: decoder))
            case "code_execution_tool_result": self = .codeExecutionToolResult(try BetaCodeExecutionToolResultBlock(from: decoder))
            case "bash_code_execution_tool_result": self = .bashCodeExecutionToolResult(try BetaBashCodeExecutionToolResultBlock(from: decoder))
            case "text_editor_code_execution_tool_result": self = .textEditorCodeExecutionToolResult(try BetaTextEditorCodeExecutionToolResultBlock(from: decoder))
            case "tool_search_tool_result": self = .toolSearchToolResult(try BetaToolSearchToolResultBlock(from: decoder))
            case "mcp_tool_use": self = .mcpToolUse(try BetaMCPToolUseBlock(from: decoder))
            case "mcp_tool_result": self = .mcpToolResult(try BetaMCPToolResultBlock(from: decoder))
            case "container_upload": self = .containerUpload(try BetaContainerUploadBlock(from: decoder))
            case "compaction": self = .compaction(try BetaCompactionBlock(from: decoder))
            case "fallback": self = .fallback(try BetaFallbackBlock(from: decoder))
            case "mcp_tool_listing": self = .mcpToolListing(try BetaMCPToolListingBlock(from: decoder))
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
            case .advisorToolResult(let v): try v.encode(to: encoder)
            case .codeExecutionToolResult(let v): try v.encode(to: encoder)
            case .bashCodeExecutionToolResult(let v): try v.encode(to: encoder)
            case .textEditorCodeExecutionToolResult(let v): try v.encode(to: encoder)
            case .toolSearchToolResult(let v): try v.encode(to: encoder)
            case .mcpToolUse(let v): try v.encode(to: encoder)
            case .mcpToolResult(let v): try v.encode(to: encoder)
            case .containerUpload(let v): try v.encode(to: encoder)
            case .compaction(let v): try v.encode(to: encoder)
            case .fallback(let v): try v.encode(to: encoder)
            case .mcpToolListing(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
