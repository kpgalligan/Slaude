import Foundation

// What the typed Messages streams (`MessageStream`, `BetaMessageStream`) make of an event that a stream handed out
// undecoded (`LenientStreamEvent`): an event of a known type one of whose fields drifted from the schema (a `null`
// where a number was expected, a required key left out). Such an event still goes into the snapshot, losing only
// what does not decode: the event is decoded leaving out each field that does not (`decodeLeavingOutDrift`), and
// what still cannot be decoded is applied as JSON (a block that did not decode is held as its JSON, and the deltas
// that follow are applied to it by `JSONMessageAccumulator`'s rules). The JSON path (`stream(body:)`) needs none of
// this: it builds the Message from the events' JSON alone.

/// Whether `json`, an event a stream handed out as `unknown`, has a type the Messages events have: one whose fields
/// drifted from the schema, rather than an event type this SDK does not know.
func isUndecodedMessageEvent(_ json: JSONValue) -> Bool {
    switch json["type"]?.stringValue {
    case "message_start", "message_delta", "message_stop", "content_block_start", "content_block_delta", "content_block_stop": return true
    default: return false
    }
}

/// Decodes `json` as `T`, leaving out each field that does not decode, or `nil` when even that does not decode it.
///
/// Each failure names the path of the value that failed (`DecodingError`'s coding path). That value is removed and
/// the decode tried again; a value that cannot be removed (a required key that is missing, or was just removed) takes
/// its container with it, up to the root. So a drifted optional field (`container` with a `null` `expires_at`)
/// loses itself, and a drifted field of a required object loses the nearest optional object around it. An array
/// element that does not decode is removed from its array.
func decodeLeavingOutDrift<T: Decodable>(_ type: T.Type, from json: JSONValue) -> T? {
    var json = json
    // Every round removes a value, so the loop ends; the bound only caps the work on a pathological value.
    for _ in 0..<64 {
        let path: [any CodingKey]
        do {
            return try json.decode(as: T.self)
        } catch let DecodingError.keyNotFound(key, context) {
            path = context.codingPath + [key]
        } catch let DecodingError.typeMismatch(_, context), let DecodingError.valueNotFound(_, context),
                let DecodingError.dataCorrupted(context)
        {
            path = context.codingPath
        } catch {
            return nil
        }
        var target = path[...]
        while !target.isEmpty, !removeValue(at: target, in: &json) { target = target.dropLast() }
        if target.isEmpty { return nil }
    }
    return nil
}

/// Removes the value at `path` from `value`; false when there is none there.
private func removeValue(at path: ArraySlice<any CodingKey>, in value: inout JSONValue) -> Bool {
    guard let first = path.first else { return false }
    let rest = path.dropFirst()
    switch value {
    case .object(var object):
        guard var child = object[first.stringValue] else { return false }
        if rest.isEmpty {
            object.removeValue(forKey: first.stringValue)
        } else {
            guard removeValue(at: rest, in: &child) else { return false }
            object[first.stringValue] = child
        }
        value = .object(object)
        return true
    case .array(var array):
        guard let index = first.intValue, array.indices.contains(index) else { return false }
        if rest.isEmpty {
            array.remove(at: index)
        } else {
            guard removeValue(at: rest, in: &array[index]) else { return false }
        }
        value = .array(array)
        return true
    default:
        return false
    }
}

/// A drifted `message_delta` with the values its typed event requires put back where they did not decode: a `delta`
/// object, and `usage.output_tokens` (the count so far), so that a drift there does not lose the stop reason.
func messageDeltaWithRequiredFields(_ json: JSONValue, outputTokens: Int) -> JSONValue {
    var event = json
    if event["delta"]?.objectValue == nil { event["delta"] = [:] }
    var usage = event["usage"]?.objectValue ?? [:]
    if usage["output_tokens"]?.intValue == nil { usage["output_tokens"] = .int(outputTokens) }
    event["usage"] = .object(usage)
    return event
}

/// The Message of a `message_start` that did not decode, its drifted fields left out. Throws when its Message cannot
/// be built even so (a required field of the Message itself drifted), naming why.
func messageOfUndecodedStart<Start: Decodable>(_ json: JSONValue, as type: Start.Type) throws -> Start {
    if let start = decodeLeavingOutDrift(Start.self, from: json) { return start }
    let reason: String
    do {
        _ = try json.decode(as: Start.self)
        reason = "unknown"
    } catch {
        reason = "\(error)"
    }
    throw AnthropicError("The stream's `message_start` event does not decode, so its Message cannot be built: \(reason)")
}

/// `block` with one `content_block_delta`'s `delta`, given as JSON, applied, for the cases the typed accumulation
/// cannot take it in: a block that did not decode (`held`, its JSON), or a delta that did not decode.
///
/// The delta is applied to the block's JSON by `applyDelta(_:to:index:jsonBufs:mode:)`, and the result decoded
/// (leaving out what does not decode), so that a block whose start was missing a field it then received (a `text`
/// block started without `text`) becomes its typed block. A block that still does not decode stays JSON; a typed
/// block that a delta made undecodable stays as it was, without the delta.
func blockApplyingDelta<Block: Codable>(_ delta: JSONValue, to block: Block, held: JSONValue?, index: Int,
                                        jsonBufs: inout [Int: String], mode: PartialJSONMode,
                                        unknown: (JSONValue) -> Block) throws -> Block
{
    guard var json = held ?? (try? JSONValue.from(block)) else { return block }
    let before = json
    try applyDelta(delta, to: &json, index: index, jsonBufs: &jsonBufs, mode: mode)
    if json == before { return block }
    if let decoded = decodeLeavingOutDrift(Block.self, from: json) { return decoded }
    return held == nil ? block : unknown(json)
}

/// Applies a `content_block_delta`'s `delta` to a content block held as JSON, by `JSONMessageAccumulator`'s rules:
/// text, thinking, signature, citations and compaction deltas to the blocks of their type, and an `input_json_delta`
/// to the block's `input`, parsed as far as it goes (`accumulateToolInput`, which throws for input that is not JSON).
func applyDelta(_ delta: JSONValue, to block: inout JSONValue, index: Int, jsonBufs: inout [Int: String],
                mode: PartialJSONMode) throws
{
    guard case .object = block else { return }
    let blockType = block["type"]?.stringValue
    switch delta["type"]?.stringValue {
    case "text_delta":
        if blockType == "text", let text = delta["text"]?.stringValue { block["text"] = .string((block["text"]?.stringValue ?? "") + text) }
    case "thinking_delta":
        if blockType == "thinking", let text = delta["thinking"]?.stringValue {
            block["thinking"] = .string((block["thinking"]?.stringValue ?? "") + text)
        }
    case "signature_delta":
        if blockType == "thinking", let signature = delta["signature"] { block["signature"] = signature }
    case "citations_delta":
        if blockType == "text", let citation = delta["citation"] { block["citations"] = .array((block["citations"]?.arrayValue ?? []) + [citation]) }
    case "compaction_delta":
        if blockType == "compaction", case .object(let fields) = delta {
            for (k, v) in fields where k != "type" { block[k] = v }
        }
    case "input_json_delta":
        if let partial = delta["partial_json"]?.stringValue,
           let input = try accumulateToolInput(&jsonBufs, index: index, partialJSON: partial, mode: mode)
        {
            block["input"] = .object(input)
        }
    default:
        break
    }
}
