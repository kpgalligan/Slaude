import Foundation

/// A JSON parser that accepts truncated documents, standing in for `jiter.from_json(..., partial_mode=...)`.
///
/// The streaming helpers use it to parse tool inputs while their `input_json_delta` chunks arrive. The parser itself
/// is `JSONTextParser` (`Core/JSONText.swift`), shared with `RawJSON.parse`.
public enum PartialJSON {
    public static func parse(_ text: String, mode: PartialJSONMode = .on) throws -> JSONValue {
        try parse(Data(text.utf8), mode: mode)
    }

    public static func parse(_ data: Data, mode: PartialJSONMode = .on) throws -> JSONValue {
        try JSONTextParser.parse(data, mode: mode).jsonValue
    }

    /// Like `parse`, keeping each object's keys in document order (a tool input in the model's own order).
    public static func parseRaw(_ text: String, mode: PartialJSONMode = .on) throws -> RawJSON {
        try JSONTextParser.parse(Data(text.utf8), mode: mode)
    }
}
