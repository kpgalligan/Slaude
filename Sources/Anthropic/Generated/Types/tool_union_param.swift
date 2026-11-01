// Transformed from `anthropic.types.tool_union_param` (tool_union_param.py).

import Foundation

public indirect enum ToolUnionParam: Codable, Hashable, Sendable {
    case toolParam(ToolParam)
    case toolBash20250124Param(ToolBash20250124Param)
    case codeExecutionTool20250522Param(CodeExecutionTool20250522Param)
    case codeExecutionTool20250825Param(CodeExecutionTool20250825Param)
    case codeExecutionTool20260120Param(CodeExecutionTool20260120Param)
    case codeExecutionTool20260521Param(CodeExecutionTool20260521Param)
    case browserToolset20260801Param(BrowserToolset20260801Param)
    case memoryTool20250818Param(MemoryTool20250818Param)
    case computerToolset20260801Param(ComputerToolset20260801Param)
    case toolTextEditor20250124Param(ToolTextEditor20250124Param)
    case toolTextEditor20250429Param(ToolTextEditor20250429Param)
    case toolTextEditor20250728Param(ToolTextEditor20250728Param)
    case webSearchTool20250305Param(WebSearchTool20250305Param)
    case webFetchTool20250910Param(WebFetchTool20250910Param)
    case webSearchTool20260209Param(WebSearchTool20260209Param)
    case webFetchTool20260209Param(WebFetchTool20260209Param)
    case webFetchTool20260309Param(WebFetchTool20260309Param)
    case webSearchTool20260318Param(WebSearchTool20260318Param)
    case webFetchTool20260318Param(WebFetchTool20260318Param)
    case toolSearchToolBm25_20251119Param(ToolSearchToolBm25_20251119Param)
    case toolSearchToolRegex20251119Param(ToolSearchToolRegex20251119Param)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        if let v = try? ToolParam(from: decoder) { self = .toolParam(v); return }
        if _Coding.constantsMatch(decoder, ["name": "bash", "type": "bash_20250124"]), let v = try? ToolBash20250124Param(from: decoder) { self = .toolBash20250124Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "code_execution", "type": "code_execution_20250522"]), let v = try? CodeExecutionTool20250522Param(from: decoder) { self = .codeExecutionTool20250522Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "code_execution", "type": "code_execution_20250825"]), let v = try? CodeExecutionTool20250825Param(from: decoder) { self = .codeExecutionTool20250825Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "code_execution", "type": "code_execution_20260120"]), let v = try? CodeExecutionTool20260120Param(from: decoder) { self = .codeExecutionTool20260120Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "code_execution", "type": "code_execution_20260521"]), let v = try? CodeExecutionTool20260521Param(from: decoder) { self = .codeExecutionTool20260521Param(v); return }
        if _Coding.constantsMatch(decoder, ["type": "browser_toolset_20260801"]), let v = try? BrowserToolset20260801Param(from: decoder) { self = .browserToolset20260801Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "memory", "type": "memory_20250818"]), let v = try? MemoryTool20250818Param(from: decoder) { self = .memoryTool20250818Param(v); return }
        if _Coding.constantsMatch(decoder, ["type": "computer_toolset_20260801"]), let v = try? ComputerToolset20260801Param(from: decoder) { self = .computerToolset20260801Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "str_replace_editor", "type": "text_editor_20250124"]), let v = try? ToolTextEditor20250124Param(from: decoder) { self = .toolTextEditor20250124Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "str_replace_based_edit_tool", "type": "text_editor_20250429"]), let v = try? ToolTextEditor20250429Param(from: decoder) { self = .toolTextEditor20250429Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "str_replace_based_edit_tool", "type": "text_editor_20250728"]), let v = try? ToolTextEditor20250728Param(from: decoder) { self = .toolTextEditor20250728Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "web_search", "type": "web_search_20250305"]), let v = try? WebSearchTool20250305Param(from: decoder) { self = .webSearchTool20250305Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "web_fetch", "type": "web_fetch_20250910"]), let v = try? WebFetchTool20250910Param(from: decoder) { self = .webFetchTool20250910Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "web_search", "type": "web_search_20260209"]), let v = try? WebSearchTool20260209Param(from: decoder) { self = .webSearchTool20260209Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "web_fetch", "type": "web_fetch_20260209"]), let v = try? WebFetchTool20260209Param(from: decoder) { self = .webFetchTool20260209Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "web_fetch", "type": "web_fetch_20260309"]), let v = try? WebFetchTool20260309Param(from: decoder) { self = .webFetchTool20260309Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "web_search", "type": "web_search_20260318"]), let v = try? WebSearchTool20260318Param(from: decoder) { self = .webSearchTool20260318Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "web_fetch", "type": "web_fetch_20260318"]), let v = try? WebFetchTool20260318Param(from: decoder) { self = .webFetchTool20260318Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "tool_search_tool_bm25"]), let v = try? ToolSearchToolBm25_20251119Param(from: decoder) { self = .toolSearchToolBm25_20251119Param(v); return }
        if _Coding.constantsMatch(decoder, ["name": "tool_search_tool_regex"]), let v = try? ToolSearchToolRegex20251119Param(from: decoder) { self = .toolSearchToolRegex20251119Param(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .toolParam(let v): try v.encode(to: encoder)
        case .toolBash20250124Param(let v): try v.encode(to: encoder)
        case .codeExecutionTool20250522Param(let v): try v.encode(to: encoder)
        case .codeExecutionTool20250825Param(let v): try v.encode(to: encoder)
        case .codeExecutionTool20260120Param(let v): try v.encode(to: encoder)
        case .codeExecutionTool20260521Param(let v): try v.encode(to: encoder)
        case .browserToolset20260801Param(let v): try v.encode(to: encoder)
        case .memoryTool20250818Param(let v): try v.encode(to: encoder)
        case .computerToolset20260801Param(let v): try v.encode(to: encoder)
        case .toolTextEditor20250124Param(let v): try v.encode(to: encoder)
        case .toolTextEditor20250429Param(let v): try v.encode(to: encoder)
        case .toolTextEditor20250728Param(let v): try v.encode(to: encoder)
        case .webSearchTool20250305Param(let v): try v.encode(to: encoder)
        case .webFetchTool20250910Param(let v): try v.encode(to: encoder)
        case .webSearchTool20260209Param(let v): try v.encode(to: encoder)
        case .webFetchTool20260209Param(let v): try v.encode(to: encoder)
        case .webFetchTool20260309Param(let v): try v.encode(to: encoder)
        case .webSearchTool20260318Param(let v): try v.encode(to: encoder)
        case .webFetchTool20260318Param(let v): try v.encode(to: encoder)
        case .toolSearchToolBm25_20251119Param(let v): try v.encode(to: encoder)
        case .toolSearchToolRegex20251119Param(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
