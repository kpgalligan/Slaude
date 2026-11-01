// Transformed from `anthropic.types.beta.parsed_beta_message` (parsed_beta_message.py).

import Foundation



public indirect enum ParsedBetaMessageParsedBetaContentBlock: Codable, Hashable, Sendable {
    case json(JSONValue)
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
    case mcpToolListing(BetaMCPToolListingBlock)
    case fallback(BetaFallbackBlock)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        let tag = _Coding.discriminator(decoder, "type")
        if tag == "thinking" { self = .thinking(try BetaThinkingBlock(from: decoder)); return }
        if tag == "redacted_thinking" { self = .redactedThinking(try BetaRedactedThinkingBlock(from: decoder)); return }
        if tag == "tool_use" { self = .toolUse(try BetaToolUseBlock(from: decoder)); return }
        if tag == "server_tool_use" { self = .serverToolUse(try BetaServerToolUseBlock(from: decoder)); return }
        if tag == "web_search_tool_result" { self = .webSearchToolResult(try BetaWebSearchToolResultBlock(from: decoder)); return }
        if tag == "web_fetch_tool_result" { self = .webFetchToolResult(try BetaWebFetchToolResultBlock(from: decoder)); return }
        if tag == "advisor_tool_result" { self = .advisorToolResult(try BetaAdvisorToolResultBlock(from: decoder)); return }
        if tag == "code_execution_tool_result" { self = .codeExecutionToolResult(try BetaCodeExecutionToolResultBlock(from: decoder)); return }
        if tag == "bash_code_execution_tool_result" { self = .bashCodeExecutionToolResult(try BetaBashCodeExecutionToolResultBlock(from: decoder)); return }
        if tag == "text_editor_code_execution_tool_result" { self = .textEditorCodeExecutionToolResult(try BetaTextEditorCodeExecutionToolResultBlock(from: decoder)); return }
        if tag == "tool_search_tool_result" { self = .toolSearchToolResult(try BetaToolSearchToolResultBlock(from: decoder)); return }
        if tag == "mcp_tool_use" { self = .mcpToolUse(try BetaMCPToolUseBlock(from: decoder)); return }
        if tag == "mcp_tool_result" { self = .mcpToolResult(try BetaMCPToolResultBlock(from: decoder)); return }
        if tag == "container_upload" { self = .containerUpload(try BetaContainerUploadBlock(from: decoder)); return }
        if tag == "compaction" { self = .compaction(try BetaCompactionBlock(from: decoder)); return }
        if tag == "mcp_tool_listing" { self = .mcpToolListing(try BetaMCPToolListingBlock(from: decoder)); return }
        if tag == "fallback" { self = .fallback(try BetaFallbackBlock(from: decoder)); return }
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
        case .advisorToolResult(let v): try v.encode(to: encoder)
        case .codeExecutionToolResult(let v): try v.encode(to: encoder)
        case .bashCodeExecutionToolResult(let v): try v.encode(to: encoder)
        case .textEditorCodeExecutionToolResult(let v): try v.encode(to: encoder)
        case .toolSearchToolResult(let v): try v.encode(to: encoder)
        case .mcpToolUse(let v): try v.encode(to: encoder)
        case .mcpToolResult(let v): try v.encode(to: encoder)
        case .containerUpload(let v): try v.encode(to: encoder)
        case .compaction(let v): try v.encode(to: encoder)
        case .mcpToolListing(let v): try v.encode(to: encoder)
        case .fallback(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
