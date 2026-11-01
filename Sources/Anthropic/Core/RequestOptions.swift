import Foundation

/// A header value in a header layer: a value, or `omit` to remove a header an earlier layer set
/// (Python's `Omit()` in `extra_headers` / `default_headers`).
public enum HeaderValue: Sendable, Hashable, ExpressibleByStringLiteral, CustomStringConvertible {
    case value(String)
    case omit

    public init(stringLiteral value: String) { self = .value(value) }

    public var stringValue: String? { if case .value(let s) = self { return s } else { return nil } }
    public var description: String { stringValue ?? "<omit>" }
}

/// A header layer.
public typealias Headers = [String: HeaderValue]
/// Extra query parameters.
public typealias Query = [String: JSONValue]
/// Extra JSON body properties.
public typealias Body = [String: JSONValue]

/// A file to upload in a multipart request (Python's `FileTypes`).
public struct FileUpload: Sendable, Hashable {
    public var filename: String?
    public var data: Data
    public var contentType: String?
    public var headers: [String: String]

    public init(data: Data, filename: String? = nil, contentType: String? = nil, headers: [String: String] = [:]) {
        self.data = data
        self.filename = filename
        self.contentType = contentType
        self.headers = headers
    }

    /// Reads a file from disk; the filename defaults to the path's last component.
    public init(path: URL, filename: String? = nil, contentType: String? = nil) throws {
        self.init(data: try Data(contentsOf: path), filename: filename ?? path.lastPathComponent, contentType: contentType)
    }

    public init(path: String, filename: String? = nil, contentType: String? = nil) throws {
        try self.init(path: URL(fileURLWithPath: path), filename: filename, contentType: contentType)
    }
}

extension FileUpload: Codable {
    /// Decoding a file reads base64 content (files never travel as JSON on the wire; this exists so
    /// params types holding files stay `Codable`).
    public init(from decoder: Decoder) throws {
        let s = try decoder.singleValueContainer().decode(String.self)
        self.init(data: Data(base64Encoded: s) ?? Data(s.utf8))
    }

    /// Files are never JSON encoded; they are extracted into the multipart body. Encoding one as
    /// JSON (e.g. when logging) renders a placeholder.
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode("<file \(filename ?? "upload") \(data.count) bytes>")
    }
}

/// The fully-resolved options of one API call (`_models.FinalRequestOptions`).
public struct FinalRequestOptions: Sendable {
    public var method: String
    public var url: String
    public var params: [(String, JSONValue)] = []
    public var headers: Headers? = nil
    public var maxRetries: Int? = nil
    /// `nil` means not given (use the client's timeout).
    public var timeout: Timeout? = nil
    public var files: [(String, FileUpload)]? = nil
    public var idempotencyKey: String? = nil
    public var followRedirects: Bool? = nil
    public var content: Data? = nil
    public var jsonData: JSONValue? = nil
    public var extraJSON: Body? = nil
    /// Set by the SDK method that makes the call, for tracing. Not a public option.
    public var spanName: String? = nil
    public var spanRoute: String? = nil

    public init(method: String, url: String, params: [(String, JSONValue)] = [], headers: Headers? = nil,
                maxRetries: Int? = nil, timeout: Timeout? = nil, files: [(String, FileUpload)]? = nil,
                idempotencyKey: String? = nil, jsonData: JSONValue? = nil, extraJSON: Body? = nil, content: Data? = nil)
    {
        self.method = method
        self.url = url
        self.params = params
        self.headers = headers
        self.maxRetries = maxRetries
        self.timeout = timeout
        self.files = files
        self.idempotencyKey = idempotencyKey
        self.jsonData = jsonData
        self.extraJSON = extraJSON
        self.content = content
    }

    public func getMaxRetries(_ clientMaxRetries: Int) -> Int { maxRetries ?? clientMaxRetries }

    /// Query parameter lookup.
    public func param(_ name: String) -> JSONValue? { params.last(where: { $0.0 == name })?.1 }

    mutating func setParam(_ name: String, _ value: JSONValue) {
        if let i = params.firstIndex(where: { $0.0 == name }) { params[i].1 = value } else { params.append((name, value)) }
    }

    mutating func stripRawResponseHeader() {
        headers?.removeValue(forKey: rawResponseHeader)
    }
}

let rawResponseHeader = "X-Stainless-Raw-Response"

/// Per-call request options (`make_request_options`): the trailing `extra_headers`,
/// `extra_query`, `extra_body` and `timeout` arguments of every API method.
public struct RequestOptions: Sendable {
    public var extraHeaders: Headers?
    public var extraQuery: Query?
    public var extraBody: Body?
    public var timeout: Timeout?
    public var maxRetries: Int?

    public init(extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, maxRetries: Int? = nil) {
        self.extraHeaders = extraHeaders
        self.extraQuery = extraQuery
        self.extraBody = extraBody
        self.timeout = timeout
        self.maxRetries = maxRetries
    }
}

/// An ordered JSON object being assembled from typed method arguments.
///
/// Generated methods use this to build request bodies and queries: `nil` arguments are omitted
/// (Python's `omit`), while a double-optional argument holding `.some(nil)` is sent as `null`.
public struct ParamsBuilder: Sendable {
    public private(set) var items: [(String, JSONValue)] = []
    public private(set) var files: [(String, FileUpload)] = []

    public init() {}

    public mutating func set<T: Encodable>(_ key: String, _ value: T?) throws {
        guard let value else { return }
        try put(key, JSONValue.from(value))
    }

    /// Files are pulled out of the JSON payload into the multipart parts (`extract_files`).
    public mutating func setFile(_ key: String, _ value: FileUpload?) {
        guard let value else { return }
        files.append((key, value))
    }

    public mutating func setFiles(_ key: String, _ value: [FileUpload]?) {
        guard let value else { return }
        for f in value { files.append(("\(key)[]", f)) }
    }

    public mutating func put(_ key: String, _ value: JSONValue) {
        if let i = items.firstIndex(where: { $0.0 == key }) { items[i].1 = value } else { items.append((key, value)) }
    }

    public var object: JSONValue {
        var o: [String: JSONValue] = [:]
        for (k, v) in items { o[k] = v }
        return .object(o)
    }

    public var isEmpty: Bool { items.isEmpty }
}

/// Builds a header layer from optional values, dropping the ones not given (`strip_not_given`).
public func stripNotGiven(_ pairs: [(String, String?)]) -> Headers {
    var h: Headers = [:]
    for (k, v) in pairs { if let v { h[k] = .value(v) } }
    return h
}

/// Merges header layers, later layers winning whatever a name's casing (`{**a, **b}`).
public func mergeHeaderLayers(_ layers: Headers?...) -> Headers {
    var out: Headers = [:]
    for layer in layers {
        guard let layer else { continue }
        for (k, v) in layer {
            if let existing = out.keys.first(where: { $0.lowercased() == k.lowercased() }) { out.removeValue(forKey: existing) }
            out[k] = v
        }
    }
    return out
}

/// Folds header layers into one `HTTPHeaders` (`_base_client.build_headers`). Returns the headers and the
/// lowercase names removed with `.omit` and not set again by a later layer.
public func buildHeaderLayers(_ layers: [Headers]) -> (HTTPHeaders, Set<String>) {
    var headers = HTTPHeaders()
    var omitted = Set<String>()
    for layer in layers {
        for (name, value) in layer.sorted(by: { $0.key < $1.key }) {
            switch value {
            case .omit:
                headers.remove(name)
                omitted.insert(name.lowercased())
            case .value(var v):
                if appendHeaders.contains(name.lowercased()) {
                    v = appendHeaderValue(headers[name] ?? "", v)
                }
                // Preserve the casing of the first layer that set the header.
                headers[name] = v
                omitted.remove(name.lowercased())
            }
        }
    }
    return (headers, omitted)
}

/// Composes header layers into a single layer that still carries `.omit` for removed headers
/// (`_base_client.merge_headers`).
public func mergeHeaders(_ layers: Headers?...) -> Headers {
    let (headers, omitted) = buildHeaderLayers(layers.compactMap { $0 })
    var out: Headers = [:]
    for name in omitted { out[name] = .omit }
    for (name, value) in headers { out[name] = .value(value) }
    return out
}

let appendHeaders: Set<String> = ["x-stainless-helper"]

func appendHeaderValue(_ existing: String, _ addition: String) -> String {
    var tokens = existing.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    for raw in addition.split(separator: ",") {
        let t = raw.trimmingCharacters(in: .whitespaces)
        if !t.isEmpty && !tokens.contains(t) { tokens.append(t) }
    }
    return tokens.joined(separator: ", ")
}

/// `_utils.path_template`: interpolates `{name}` placeholders, percent-encoding each value for
/// the URI component it lands in, and rejects dot-segments in the resulting path.
public func pathTemplate(_ template: String, _ values: [String: String]) throws -> String {
    var rest = template
    var fragmentTemplate: String? = nil
    var queryTemplate: String? = nil
    if let i = rest.firstIndex(of: "#") {
        fragmentTemplate = String(rest[rest.index(after: i)...])
        rest = String(rest[..<i])
    }
    if let i = rest.firstIndex(of: "?") {
        queryTemplate = String(rest[rest.index(after: i)...])
        rest = String(rest[..<i])
    }
    let path = try interpolateTemplate(rest, values, safe: "!$&'()*+,;=:@")
    for segment in path.split(separator: "/", omittingEmptySubsequences: false) {
        if segment.range(of: "^(?:\\.|%2[eE]){1,2}$", options: .regularExpression) != nil {
            throw ValueError("Constructed path \(pythonStringRepr(path)) contains dot-segment \(pythonStringRepr(String(segment))) which is not allowed")
        }
    }
    var result = path
    if let q = queryTemplate { result += "?" + (try interpolateTemplate(q, values, safe: "!$'()*+,;:@/?")) }
    if let f = fragmentTemplate { result += "#" + (try interpolateTemplate(f, values, safe: "!$&'()*+,;=:@/?")) }
    return result
}

func interpolateTemplate(_ template: String, _ values: [String: String], safe: String) throws -> String {
    var out = ""
    var i = template.startIndex
    while i < template.endIndex {
        if template[i] == "{", let close = template[i...].firstIndex(of: "}") {
            let name = String(template[template.index(after: i)..<close])
            if !name.isEmpty, name.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" }) {
                guard let v = values[name] else {
                    throw ValueError("a value for placeholder {\(name)} was not provided")
                }
                out += pythonQuote(v, safe: safe)
                i = template.index(after: close)
                continue
            }
        }
        out.append(template[i])
        i = template.index(after: i)
    }
    return out
}

/// `urllib.parse.quote(value, safe=...)`: unreserved characters and `safe` stay, everything else is %-encoded.
public func pythonQuote(_ value: String, safe: String) -> String {
    let safeSet = Set(safe.utf8)
    var out = ""
    for byte in value.utf8 {
        let isUnreserved = (byte >= 0x41 && byte <= 0x5A) || (byte >= 0x61 && byte <= 0x7A) || (byte >= 0x30 && byte <= 0x39)
            || byte == 0x2D || byte == 0x2E || byte == 0x5F || byte == 0x7E
        if isUnreserved || safeSet.contains(byte) {
            out.append(Character(UnicodeScalar(byte)))
        } else {
            out += String(format: "%%%02X", byte)
        }
    }
    return out
}

/// Raises the error the Python SDK raises for an empty path parameter.
@inline(__always)
public func requireNonEmpty(_ value: String, _ name: String) throws {
    if value.isEmpty {
        throw ValueError("Expected a non-empty value for `\(name)` but received ''")
    }
}
