import Foundation

// Port of `lib/_tracing/_content.py` and `lib/_tracing/_utils.py`: the content attributes of a span,
// in content mode, and how they are kept within `max_content_bytes`.

/// A JSON value whose objects keep the order of their keys, as a Python `dict` does, so that a content
/// attribute is the JSON that the Python SDK makes.
public indirect enum OrderedJSON: Sendable, Hashable {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([OrderedJSON])
    case object([Field])

    public struct Field: Sendable, Hashable {
        public var key: String
        public var value: OrderedJSON
        public init(_ key: String, _ value: OrderedJSON) {
            self.key = key
            self.value = value
        }
    }

    /// An object with `fields` in order.
    public static func obj(_ fields: (String, OrderedJSON)...) -> OrderedJSON { .object(fields.map { Field($0.0, $0.1) }) }

    /// `value`, whose objects have their keys in sorted order: a `JSONValue` keeps no order.
    public init(_ value: JSONValue?) {
        switch value {
        case nil, .null?: self = .null
        case .bool(let b)?: self = .bool(b)
        case .int(let i)?: self = .int(i)
        case .double(let d)?: self = .double(d)
        case .string(let s)?: self = .string(s)
        case .array(let a)?: self = .array(a.map { OrderedJSON($0) })
        case .object(let o)?: self = .object(o.keys.sorted().map { Field($0, OrderedJSON(o[$0])) })
        }
    }

    public var jsonValue: JSONValue {
        switch self {
        case .null: return .null
        case .bool(let b): return .bool(b)
        case .int(let i): return .int(i)
        case .double(let d): return .double(d)
        case .string(let s): return .string(s)
        case .array(let a): return .array(a.map(\.jsonValue))
        case .object(let fields):
            var o: [String: JSONValue] = [:]
            for f in fields { o[f.key] = f.value.jsonValue }
            return .object(o)
        }
    }

    public subscript(key: String) -> OrderedJSON? {
        if case .object(let fields) = self { return fields.last(where: { $0.key == key })?.value }
        return nil
    }

    var arrayValue: [OrderedJSON]? { if case .array(let a) = self { return a } else { return nil } }
    var stringValue: String? { if case .string(let s) = self { return s } else { return nil } }

    /// A copy whose `key` is `value`, in the place of the key that it replaces.
    func setting(_ key: String, _ value: OrderedJSON) -> OrderedJSON {
        guard case .object(var fields) = self else { return self }
        if let i = fields.firstIndex(where: { $0.key == key }) { fields[i].value = value } else { fields.append(Field(key, value)) }
        return .object(fields)
    }

    /// Compact JSON for a content attribute: `json.dumps(value, separators=(",", ":"), ensure_ascii=False)` (`to_json`).
    public var json: String {
        var out = ""
        write(into: &out)
        return out
    }

    private func write(into out: inout String) {
        switch self {
        case .null: out += "null"
        case .bool(let b): out += b ? "true" : "false"
        case .int(let i): out += String(i)
        case .double(let d): out += pythonFloatRepr(d)
        case .string(let s): OrderedJSON.writeString(s, into: &out)
        case .array(let a):
            out += "["
            for (i, item) in a.enumerated() {
                if i > 0 { out += "," }
                item.write(into: &out)
            }
            out += "]"
        case .object(let fields):
            out += "{"
            for (i, field) in fields.enumerated() {
                if i > 0 { out += "," }
                OrderedJSON.writeString(field.key, into: &out)
                out += ":"
                field.value.write(into: &out)
            }
            out += "}"
        }
    }

    static func writeString(_ s: String, into out: inout String) {
        out += "\""
        for scalar in s.unicodeScalars {
            switch scalar {
            case "\"": out += "\\\""
            case "\\": out += "\\\\"
            case "\n": out += "\\n"
            case "\r": out += "\\r"
            case "\t": out += "\\t"
            case "\u{08}": out += "\\b"
            case "\u{0C}": out += "\\f"
            default:
                if scalar.value < 0x20 {
                    out += String(format: "\\u%04x", scalar.value)
                } else {
                    out.unicodeScalars.append(scalar)
                }
            }
        }
        out += "\""
    }
}

/// Python's `repr(float)` as JSON writes it.
func pythonFloatRepr(_ d: Double) -> String {
    if d.isNaN { return "NaN" }
    if d.isInfinite { return d > 0 ? "Infinity" : "-Infinity" }
    if d.rounded() == d && abs(d) < 1e16 { return String(format: "%.1f", d) }
    return "\(d)"
}

/// `value[key]` for an object, and `nil` when there is no such entry, or it is `null` (`get`).
func tracingGet(_ value: JSONValue?, _ key: String) -> JSONValue? {
    guard let v = value?[key], !v.isNull else { return nil }
    return v
}

// MARK: - Content attributes

let SYSTEM_INSTRUCTIONS = "gen_ai.system_instructions"
let INPUT_MESSAGES = "gen_ai.input.messages"
let OUTPUT_MESSAGES = "gen_ai.output.messages"
let TOOL_CALL_ARGUMENTS = "gen_ai.tool.call.arguments"
let TOOL_RESULT_CONTENT = "anthropic.tool_result.content"

/// The default `max_content_bytes`. In bytes of UTF-8. What is kept of an emptied attribute can exceed it by itself.
public let CONTENT_LIMIT = OpenTelemetryOptions.defaultMaxContentBytes

/// In the order in which they lose their parts to the limit.
let PART_ATTRIBUTES = [SYSTEM_INSTRUCTIONS, INPUT_MESSAGES, OUTPUT_MESSAGES]

/// Sets the content attributes of `span` within `limit`, the client's `maxContentBytes` (`set_content_attributes`).
///
/// `limit` is in bytes of UTF-8. Each of `attributes` is set as one JSON string, and `stopSequences` as an array of
/// strings, whose size is the total of its strings. Stop sequences that exceed `limit` by themselves are left out
/// whole, before anything else is reduced. Those that stay count toward the limit. A span that lost any content has
/// `anthropic.content.truncated`.
public func setContentAttributes(_ span: any Span, _ attributes: [String: OrderedJSON?], limit: Int, stopSequences: [String] = []) {
    let stopsSize = stopSequences.reduce(0) { $0 + utf8Size($1) }
    let stopsRemoved = !stopSequences.isEmpty && stopsSize > limit
    if !stopSequences.isEmpty && !stopsRemoved { span.setAttribute("gen_ai.request.stop_sequences", .stringArray(stopSequences)) }

    // What fits at the most that it can be stays whole, and none of it is encoded to be measured.
    let room = stopsRemoved ? limit : limit - stopsSize
    var (values, truncated) = fitContent(attributes, limit: room, size: mostUTF8Size)
    if truncated { (values, truncated) = fitContent(attributes, limit: room) }
    for key in values.keys.sorted() { span.setAttribute(key, .string(values[key]!)) }
    if truncated || stopsRemoved { span.setAttribute("anthropic.content.truncated", .bool(true)) }
}

/// The size of `text` in bytes of UTF-8.
func utf8Size(_ text: String) -> Int { text.utf8.count }

/// The most that `utf8Size` can be, without reading all of `text`: no character is more than four bytes.
func mostUTF8Size(_ text: String) -> Int {
    let scalars = text.unicodeScalars.count
    return text.utf8.count == scalars ? scalars : 4 * scalars
}

/// Serializes each content attribute that is not `nil` to JSON, within `limit` bytes of UTF-8 in total (`fit_content`).
///
/// `size` gives the bytes of a string, and never fewer than it has. Returns the JSON of each that stays, and whether
/// any content was removed. First, `gen_ai.tool.call.arguments` that exceed `limit` by themselves are left out
/// whole. Then the parts of the system instructions, then of the input messages, then of the output messages make
/// one list, which loses whole parts from its start until the values fit or one part is left. That part keeps the
/// start of its `content` that fits and ends with a whole character when it is a `text` part, and is removed
/// otherwise. On the span of a tool run, `anthropic.tool_result.content` loses whole content blocks instead, last
/// first. What is kept of an attribute that lost everything, such as an emptied list or a message without parts,
/// can still total more than `limit`.
func fitContent(_ attributes: [String: OrderedJSON?], limit: Int, size: (String) -> Int = utf8Size) -> ([String: String], Bool) {
    var values: [String: String] = [:]
    for (key, value) in attributes {
        if let value, !PART_ATTRIBUTES.contains(key) { values[key] = value.json }
    }
    var argumentsRemoved = false
    if let arguments = values[TOOL_CALL_ARGUMENTS], size(arguments) > limit {
        argumentsRemoved = true
        values.removeValue(forKey: TOOL_CALL_ARGUMENTS)
    }

    // The lists of parts in the order of the one list that they make, and for each attribute that has some, its JSON
    // split where the parts of each list go: one more string than it has lists.
    var lists: [[OrderedJSON]] = []
    var around: [(String, [String])] = []
    for key in PART_ATTRIBUTES {
        guard let value = attributes[key] ?? nil else { continue }
        if key == SYSTEM_INSTRUCTIONS {
            lists.append(value.arrayValue ?? [])
            around.append((key, ["[", "]"]))
            continue
        }
        // A message is its `role` and its `parts`, in this order. Its JSON without parts ends with `[]}`.
        var starts: [String: String] = [:]
        var texts = ["["]
        for message in value.arrayValue ?? [] {
            let role = message["role"] ?? .null
            let roleKey = role.json
            if starts[roleKey] == nil { starts[roleKey] = String(OrderedJSON.obj(("role", role), ("parts", .array([]))).json.dropLast(2)) }
            lists.append(message["parts"]?.arrayValue ?? [])
            texts[texts.count - 1] += (texts.count > 1 ? "," : "") + starts[roleKey]!
            texts.append("]}")
        }
        texts[texts.count - 1] += "]"
        around.append((key, texts))
    }
    var total = values.values.reduce(0) { $0 + size($1) } + around.reduce(0) { $0 + $1.1.reduce(0) { $0 + size($1) } }

    if total > limit, let result = attributes[TOOL_RESULT_CONTENT] ?? nil, let blocks = result.arrayValue {
        let others = total - size(values[TOOL_RESULT_CONTENT]!)
        let (json, truncated) = truncateToolResultContent(blocks, limit: limit - others, size: size)
        values[TOOL_RESULT_CONTENT] = json
        return (values, truncated || argumentsRemoved)
    }

    // Newest first, stopping at the first part that does not fit, so that content far over `limit` costs no more than
    // content at it. The JSON of a list is its brackets, its items, and a comma between each two.
    var kept: [[String]] = Array(repeating: [], count: lists.count)
    var left: [(OrderedJSON, Int)] = []
    for (i, parts) in lists.enumerated() { for part in parts { left.append((part, i)) } }
    var truncated = false
    while let (part, list) = left.popLast() {
        let item = part.json
        let itemSize = size(item) + (kept[list].isEmpty ? 0 : 1)
        if total + itemSize <= limit {
            kept[list].append(item)
            total += itemSize
            continue
        }
        if kept.allSatisfy({ $0.isEmpty }), part["type"] == .string("text"), let content = part["content"]?.stringValue {
            // The last part of all. What is left for the JSON of `content` without its quotes is what `item` has not.
            let start = cutText(content, room: limit - total - size(item) + size(OrderedJSON.string(content).json) - 2)
            kept[list].append(part.setting("content", .string(start)).json)
            truncated = !left.isEmpty || start != content
        } else {
            truncated = true
        }
        break
    }

    var listIndex = 0
    for (key, texts) in around {
        var pieces = texts[0]
        for text in texts.dropFirst() {
            pieces += kept[listIndex].reversed().joined(separator: ",") + text
            listIndex += 1
        }
        values[key] = pieces
    }
    return (values, truncated || argumentsRemoved)
}

/// The longest start of `content` whose JSON, without its quotes, is within `room` bytes of UTF-8 (`cut_text`).
func cutText(_ content: String, room: Int) -> String {
    var room = max(room, 0)
    // No character is less than a byte, so no more than `room` of them fit.
    let data = Array(String(content.unicodeScalars.prefix(room)).utf8)
    let end = min(room, data.count)
    var i = 0
    while i < end {
        let byte = data[i]
        if byte == 0x22 || byte == 0x5C || byte < 0x20 {
            let extra = [0x22, 0x5C, 0x08, 0x0C, 0x0A, 0x0D, 0x09].contains(byte) ? 1 : 5
            if i + 1 + extra > room {
                room = min(room, i)
                break
            }
            room -= extra
        }
        i += 1
    }
    // The bytes of a character after its first are `10xxxxxx`. A cut before one of them would be inside the character.
    while 0 < room && room < data.count && data[room] & 0xC0 == 0x80 { room -= 1 }
    return String(decoding: data[0..<min(room, data.count)], as: UTF8.self)
}

/// Serializes `blocks` to JSON within `limit` bytes of UTF-8, dropping the last blocks first (`truncate_tool_result_content`).
func truncateToolResultContent(_ blocks: [OrderedJSON], limit: Int, size: (String) -> Int = utf8Size) -> (String, Bool) {
    var kept: [String] = []
    var total = 2
    for block in blocks {
        let item = block.json
        total += size(item) + (kept.isEmpty ? 0 : 1)
        if total > limit { break }
        kept.append(item)
    }
    return ("[" + kept.joined(separator: ",") + "]", kept.count < blocks.count)
}

/// The parts of `content`, a string or a list of content blocks (`content_parts`).
public func contentParts(_ content: JSONValue?) -> [OrderedJSON] {
    switch content {
    case .string(let s)?: return [.obj(("type", "text"), ("content", .string(s)))]
    case .array(let blocks)?: return blocks.map(blockPart)
    default: return []
    }
}

func blockPart(_ block: JSONValue) -> OrderedJSON {
    let blockType = tracingGet(block, "type")?.stringValue
    func field(_ key: String) -> OrderedJSON { OrderedJSON(tracingGet(block, key)) }
    switch blockType {
    case "text":
        return .obj(("type", "text"), ("content", field("text")))
    case "thinking":
        return .obj(("type", "reasoning"), ("content", field("thinking")))
    case "tool_use", "server_tool_use":
        var part = OrderedJSON.obj(("type", "tool_call"), ("id", field("id")), ("name", field("name")), ("arguments", field("input")))
        if blockType == "tool_use", let toolset = tracingGet(block, "toolset_name")?.stringValue {
            part = part.setting("anthropic_toolset_name", .string(toolset))
        }
        return part
    case "mcp_tool_use":
        return .obj(("type", "tool_call"), ("id", field("id")), ("name", field("name")), ("arguments", field("input")),
                    ("anthropic_mcp_server_name", field("server_name")))
    case "tool_result":
        return .obj(("type", "tool_call_response"), ("id", field("tool_use_id")),
                    ("response", .array(toolResultContent(tracingGet(block, "content")))))
    default:
        // The result block of an MCP tool or of a server tool, such as `web_search_tool_result`.
        if let blockType, blockType.hasSuffix("_tool_result") {
            return .obj(("type", "tool_call_response"), ("id", field("tool_use_id")),
                        ("response", resultBlockContent(tracingGet(block, "content"))))
        }
        return .obj(("type", .string(blockType.map { "anthropic_\($0)" } ?? "anthropic_unknown")))
    }
}

/// The `content` of a tool result, as content blocks. Only `text` and `search_result` blocks keep more than their
/// `type` (`tool_result_content`).
public func toolResultContent(_ content: JSONValue?) -> [OrderedJSON] {
    switch content {
    case .string(let s)?: return [.obj(("type", "text"), ("text", .string(s)))]
    case .array(let blocks)?:
        return blocks.map { block in
            let type = tracingGet(block, "type")?.stringValue
            if type == "text" || type == "search_result" { return withoutData(block) }
            return .obj(("type", .string(type ?? "unknown")))
        }
    default: return []
    }
}

/// The `content` of a result block other than `tool_result`: a list of content blocks, or the one object it holds
/// (`result_block_content`).
func resultBlockContent(_ content: JSONValue?) -> OrderedJSON {
    switch content {
    case .string(let s)?: return .array([.obj(("type", "text"), ("text", .string(s)))])
    case .array(let blocks)?:
        return .array(blocks.map { block in
            let type = tracingGet(block, "type")?.stringValue
            if type == "text" || type == "search_result" || type == "web_search_result" { return withoutData(block) }
            return .obj(("type", .string(type ?? "unknown")))
        })
    case .object?: return withoutData(content!)
    default: return .array([])
    }
}

/// `value` without its `encrypted_` fields, which are opaque, and without image and document data, which is large
/// and binary, at any depth (`without_data`).
func withoutData(_ value: JSONValue) -> OrderedJSON {
    switch value {
    case .array(let items): return .array(items.map(withoutData))
    case .object(let fields):
        let type = fields["type"]?.stringValue
        if type == "image" || type == "document" { return .obj(("type", .string(type!))) }
        let fileType = fields["file_type"]?.stringValue
        let isFileData = type == "text_editor_code_execution_view_result" && (fileType == "image" || fileType == "pdf")
        return .object(fields.keys.sorted().compactMap { key in
            if key.hasPrefix("encrypted_") || (key == "content" && isFileData) { return nil }
            return OrderedJSON.Field(key, withoutData(fields[key]!))
        })
    default: return OrderedJSON(value)
    }
}

/// Sets the content attributes of a Messages create call, within `limit`, the client's `maxContentBytes`
/// (`set_message_content`). `output` is the response's content, if it has one.
func setMessageContent(_ span: any Span, body: JSONValue?, output: JSONValue?, limit: Int) {
    let messages = tracingGet(body, "messages")?.arrayValue ?? []
    let inputs: [OrderedJSON] = messages.map { message in
        .obj(("role", .string(tracingGet(message, "role")?.stringValue ?? "user")), ("parts", .array(contentParts(tracingGet(message, "content")))))
    }
    let system = tracingGet(body, "system")
    let instructions: OrderedJSON? = system == nil ? nil : .array(contentParts(system))
    let outputs: OrderedJSON? = output == nil ? nil : .array([.obj(("role", "assistant"), ("parts", .array(contentParts(output))))])

    // An array of strings, not JSON, as the conventions type it.
    let stops = (tracingGet(body, "stop_sequences")?.arrayValue ?? []).compactMap(\.stringValue)

    setContentAttributes(span, [SYSTEM_INSTRUCTIONS: instructions, INPUT_MESSAGES: .array(inputs), OUTPUT_MESSAGES: outputs],
                         limit: limit, stopSequences: stops)
}

extension OrderedJSON: ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, ExpressibleByBooleanLiteral, ExpressibleByNilLiteral,
    ExpressibleByArrayLiteral
{
    public init(stringLiteral value: String) { self = .string(value) }
    public init(integerLiteral value: Int) { self = .int(value) }
    public init(booleanLiteral value: Bool) { self = .bool(value) }
    public init(nilLiteral: ()) { self = .null }
    public init(arrayLiteral elements: OrderedJSON...) { self = .array(elements) }
}
