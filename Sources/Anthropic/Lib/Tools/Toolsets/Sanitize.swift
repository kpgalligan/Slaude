// Port of `anthropic/lib/tools/_toolsets/_sanitize.py`.
//
// Every place a page- or model-supplied string is cleaned or cut before it reaches the model, a log, or an
// SDK-written line. Swift strings can't hold an unpaired surrogate, so `wellFormed` has nothing to fold.

import Foundation

/// The API's limit for a text field of a block, for a URL, and the most of an error's text an `is_error` result
/// includes.
public let TOOLSET_FIELD_MAX = 4096
let TOOLSET_LOG_MAX = 200

/// `text` with each unpaired surrogate replaced by U+FFFD, so it can be sent. A Swift `String` is always well formed.
func wellFormed(_ text: String) -> String { text }

private func isLineUnsafe(_ scalar: Unicode.Scalar) -> Bool {
    let v = scalar.value
    return v <= 0x1F || (0x7F...0x9F).contains(v) || v == 0x061C || v == 0x200E || v == 0x200F || v == 0x2028
        || v == 0x2029 || (0x202A...0x202E).contains(v) || (0x2066...0x2069).contains(v)
}

/// `text` on one line, not yet cut: line breaks, control and bidi characters folded to spaces, the ends trimmed.
func folded(_ text: String) -> String {
    var out = String.UnicodeScalarView()
    var inRun = false
    for scalar in wellFormed(text).unicodeScalars {
        if isLineUnsafe(scalar) {
            if !inRun { out.append(" ") }
            inRun = true
        } else {
            out.append(scalar)
            inRun = false
        }
    }
    return pythonStrip(String(out))
}

/// Python's `str.strip()` (whitespace only).
func pythonStrip(_ s: String) -> String {
    s.trimmingCharacters(in: .whitespacesAndNewlines)
}

/// The first `limit` characters (code points, as Python slices) of `s`.
func prefixCodePoints(_ s: String, _ limit: Int) -> String {
    var view = String.UnicodeScalarView()
    for (i, scalar) in s.unicodeScalars.enumerated() {
        if i >= limit { break }
        view.append(scalar)
    }
    return String(view)
}

/// A page- or model-supplied text on one line: `folded`, then cut to `limit`.
func oneLine(_ text: String, limit: Int = TOOLSET_FIELD_MAX) -> String {
    prefixCodePoints(folded(text), limit)
}

/// A model- or page-supplied name for a log record or an SDK-written error text: `oneLine`, cut short.
func logSafe(_ name: String?) -> String {
    oneLine(name ?? "None", limit: TOOLSET_LOG_MAX)
}

/// A model-chosen name as it is echoed inside single quotes: one line, cut short, without quotes and runs of spaces.
func quotedName(_ name: String?) -> String {
    let safe = logSafe(name)
    let replaced = safe.replacingOccurrences(of: "[' ]+", with: " ", options: .regularExpression)
    return pythonStrip(replaced)
}

/// `repr(exc)` as the `is_error` result the model reads, cut to the field limit.
func errorText(_ error: Error) -> String {
    prefixCodePoints(wellFormed(pythonExceptionRepr(error)), TOOLSET_FIELD_MAX)
}

/// The text blocks of a `ToolError`'s content: the API accepts only text on an `is_error` result.
func errorTextContent(_ content: BetaFunctionToolResult) -> JSONValue {
    switch content {
    case .string(let s): return .string(wellFormed(s))
    default:
        var kept: [JSONValue] = []
        for block in (try? JSONValue.from(content))?.arrayValue ?? [] {
            if block["type"] == "text", let text = block["text"]?.stringValue, !text.isEmpty {
                kept.append(block)
            }
        }
        return .array(kept)
    }
}

/// A tab's or download's URL as the model reads it: folded to one line, held to `TOOLSET_FIELD_MAX`.
func boundedTabURL(_ url: String) -> String {
    let line = folded(url)
    if line.unicodeScalars.count <= TOOLSET_FIELD_MAX { return line }
    return "\u{2026}" + prefixCodePoints(line, TOOLSET_FIELD_MAX - 1)
}

/// Python's `repr()` of an exception: `TypeName('message')`.
///
/// The SDK's Python-builtin stand-ins render under their Python names (`ValueError`, `TypeError`), so an
/// `is_error` result reads as upstream's does.
public func pythonExceptionRepr(_ error: Error) -> String {
    if let e = error as? any PythonReprError { return e.pythonRepr }
    let typeName: String
    let message: String
    switch error {
    case let e as ValueError:
        typeName = "ValueError"
        message = e.message
    case let e as ArgumentTypeError:
        typeName = "TypeError"
        message = e.message
    case let e as AnthropicError:
        typeName = String(describing: type(of: e))
        message = e.message
    case let e as CustomStringConvertible:
        typeName = String(describing: type(of: error))
        message = e.description
    default:
        return String(reflecting: error)
    }
    return "\(typeName)(\(pythonStringRepr(message)))"
}

/// An error that renders its own Python-style `repr`, for the `is_error` result a tool's error becomes.
public protocol PythonReprError: Error {
    var pythonRepr: String { get }
}
