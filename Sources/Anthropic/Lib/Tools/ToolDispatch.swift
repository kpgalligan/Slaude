// Port of `anthropic/lib/tools/_tool_dispatch.py`: the tool-dispatch helpers both tool runners share.

import Foundation

/// An insertion-ordered dictionary, for the registries Python keeps in (ordered) dicts.
struct OrderedDict<Value> {
    private(set) var keys: [String] = []
    private var storage: [String: Value] = [:]

    init() {}

    subscript(key: String) -> Value? {
        get { storage[key] }
        set {
            if let newValue {
                if storage[key] == nil { keys.append(key) }
                storage[key] = newValue
            } else if storage.removeValue(forKey: key) != nil {
                keys.removeAll { $0 == key }
            }
        }
    }

    var values: [Value] { keys.map { storage[$0]! } }
    var items: [(String, Value)] { keys.map { ($0, storage[$0]!) } }
    var isEmpty: Bool { keys.isEmpty }
    func contains(_ key: String) -> Bool { storage[key] != nil }
}

/// Index a runner's tools by `name` and its toolsets by family (`toolset_name`). On a duplicate key the later one
/// wins (`index_runnables`).
func indexRunnables(_ tools: [any BetaToolLike]) -> (OrderedDict<any BetaRunnableTool>, OrderedDict<BetaRunnableToolset>) {
    var byName = OrderedDict<any BetaRunnableTool>()
    var byFamily = OrderedDict<BetaRunnableToolset>()
    for tool in tools {
        if let toolset = tool as? BetaRunnableToolset {
            byFamily[toolset.toolsetName] = toolset
        } else if let runnable = tool as? any BetaRunnableTool {
            byName[runnable.name] = runnable
        }
    }
    return (byName, byFamily)
}

/// Fold mid-conversation `tool_removal` / `tool_addition` blocks over the locally runnable `toolNames`
/// (`available_tool_names`). The blocks arrive in `role: "system"` messages, and in the `tool_changes` of a
/// `compaction` block.
func availableToolNames(_ messages: [JSONValue], _ toolNames: [String]) -> Set<String> {
    var available = Set(toolNames)
    for message in messages {
        guard case .array(let content)? = message["content"] else { continue }
        let role = message["role"]?.stringValue
        for block in content {
            if role == "system" {
                applyToolChange(block, &available)
            } else if role == "assistant", block["type"] == "compaction" {
                for change in block["tool_changes"]?.arrayValue ?? [] {
                    applyToolChange(change, &available)
                }
            }
        }
    }
    return available
}

private func applyToolChange(_ block: JSONValue, _ available: inout Set<String>) {
    guard let type = block["type"]?.stringValue, type == "tool_removal" || type == "tool_addition" else { return }
    guard let tool = block["tool"], let name = changedToolName(tool) else { return }
    if type == "tool_removal" { available.remove(name) } else { available.insert(name) }
}

/// The locally runnable tool name a tool-change `tool` resolves to: `tool_reference` names one directly and
/// `tool_definition` carries one by value; MCP references and unknown types resolve to `nil`.
private func changedToolName(_ tool: JSONValue) -> String? {
    switch tool["type"]?.stringValue {
    case "tool_reference": return tool["name"]?.stringValue
    case "tool_definition": return tool["definition"]?["name"]?.stringValue
    default: return nil
    }
}

/// A tool definition's family, as the API computes it for a toolset: its `type` ("custom" when absent) without a
/// trailing `_YYYYMMDD` date and then without `_toolset` (`tool_family`).
func toolFamily(_ definition: JSONValue) -> String {
    var type = definition["type"]?.stringValue ?? ""
    if type.isEmpty { type = "custom" }
    let undated = type.replacingOccurrences(of: "_[0-9]{8}$", with: "", options: .regularExpression)
    return undated.hasSuffix("_toolset") ? String(undated.dropLast("_toolset".count)) : undated
}

/// Render an error raised by a tool as tool-result content (`tool_error_content`): a `ToolError` has its own
/// structured content; anything else is rendered with its `repr`, cut to the field limit.
func toolErrorContent(_ error: Error) -> JSONValue {
    if let e = error as? ToolError { return toolResultContent(e.content) }
    return .string(errorText(error))
}

/// A tool's result in a form the next request can encode (`tool_result_content`). `nil` sends `content: null`.
func toolResultContent(_ content: BetaFunctionToolResult?) -> JSONValue {
    guard let content else { return .null }
    return (try? JSONValue.from(content)) ?? .null
}
