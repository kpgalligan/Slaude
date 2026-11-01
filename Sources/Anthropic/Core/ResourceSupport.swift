import Foundation

/// How a resource method hands back its response.
public enum ResponseMode: Sendable, Equatable {
    /// Parse the body (the default method call).
    case parsed
    /// Read the body eagerly and return the `APIResponse` (`with_raw_response`).
    case raw
    /// Return the `APIResponse` without reading the body (`with_streaming_response`).
    case stream
}

extension BaseClient {
    /// Builds the options of one API call from a generated method's arguments
    /// (`make_request_options` plus the `_post(path, body=..., ...)` call).
    public func makeRequestOptions(method: String, url: String, body: ParamsBuilder? = nil, query: ParamsBuilder? = nil,
                                   headers: Headers?, extraQuery: Query?, extraBody: Body?, timeout: Timeout?,
                                   mode: ResponseMode, spanName: String? = nil,
                                   qualifiers: [String: String]? = nil) throws -> FinalRequestOptions
    {
        var o = FinalRequestOptions(method: method, url: url)
        var h = headers ?? [:]
        switch mode {
        case .parsed: break
        case .raw: h[rawResponseHeader] = "raw"
        case .stream: h[rawResponseHeader] = "stream"
        }
        if !h.isEmpty || headers != nil { o.headers = h }
        if let body {
            if !body.isEmpty || body.files.isEmpty { o.jsonData = body.object }
            if !body.files.isEmpty { o.files = body.files }
        }
        if let query { o.params = query.items }
        if let extraQuery {
            for (k, v) in extraQuery.sorted(by: { $0.key < $1.key }) { o.setParam(k, v) }
        }
        o.extraJSON = extraBody
        o.timeout = timeout
        o.spanName = spanName
        o.qualifiers = qualifiers
        return o
    }

    /// A JSON Lines response.
    public func requestJSONLResponse<T: Decodable & Sendable>(_ type: T.Type, _ options: FinalRequestOptions) async throws -> APIResponse<JSONLDecoder<T>> {
        let raw = try await sendRequest(options, stream: true, castTo: JSONLDecoder<T>.self)
        return APIResponse(raw, client: self) { resp in
            JSONLDecoder<T>(response: resp.http, client: resp.client)
        }
    }
}

/// A decoder for [JSON Lines](https://jsonlines.org) responses (`_decoders.jsonl.AsyncJSONLDecoder`).
///
/// The body is read only as lines are requested. The response is closed when the lines are read to
/// completion or decoding fails, when `close()` is called, or as soon as the decoder and every
/// iterator over it have been dropped. Like a `Stream`, a decoder has a single position.
public final class JSONLDecoder<Element: Decodable & Sendable>: AsyncSequence, @unchecked Sendable {
    /// The HTTP response this decoder was constructed from.
    public let httpResponse: HTTPResponse
    let client: BaseClient
    let state: State

    init(response: HTTPResponse, client: BaseClient) {
        self.httpResponse = response
        self.client = client
        self.state = State(bytes: nil, response: response, client: client)
    }

    /// Decodes `bytes` (Python's `raw_iterator`) rather than the response body.
    init(bytes: ByteStream, response: HTTPResponse, client: BaseClient) {
        self.httpResponse = response
        self.client = client
        self.state = State(bytes: bytes, response: response, client: client)
    }

    final class State: @unchecked Sendable {
        // Created on first use when no explicit byte source was given, so the body can still be
        // read raw before iteration starts.
        private var bytes: ByteStream.AsyncIterator?
        let response: HTTPResponse
        let client: BaseClient
        private var ready: [Data] = []
        private var buf = Data()
        private var done = false
        private var finished = false

        init(bytes: ByteStream?, response: HTTPResponse, client: BaseClient) {
            self.bytes = bytes?.makeAsyncIterator()
            self.response = response
            self.client = client
        }

        deinit { response.close() }

        func finish() {
            finished = true
            response.close()
        }

        /// The next complete line (`__decode__`), skipping blank ones.
        private func nextLine() async throws -> Data? {
            while true {
                if !ready.isEmpty { return ready.removeFirst() }
                if done { return nil }
                if bytes == nil { bytes = response.bytes().makeAsyncIterator() }
                guard let chunk = try await bytes!.next() else {
                    done = true
                    if !buf.allSatisfy({ $0 == 0x0A || $0 == 0x0D || $0 == 0x20 || $0 == 0x09 }) { ready.append(buf) } // flush
                    buf = Data()
                    continue
                }
                for line in splitLinesKeepEnds(chunk) {
                    buf.append(line)
                    if let last = buf.last, last == 0x0A || last == 0x0D {
                        ready.append(buf)
                        buf = Data()
                    }
                }
                ready.removeAll { line in line.allSatisfy { $0 == 0x0A || $0 == 0x0D || $0 == 0x20 || $0 == 0x09 } }
            }
        }

        func next() async throws -> Element? {
            if finished { return nil }
            do {
                guard let line = try await nextLine() else {
                    finish()
                    return nil
                }
                return try client.decodeData(Element.self, line, response: response)
            } catch {
                finish()
                throw error
            }
        }
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        let state: State
        public mutating func next() async throws -> Element? { try await state.next() }
    }

    public func makeAsyncIterator() -> AsyncIterator { AsyncIterator(state: state) }

    /// Closes the response body stream. Called automatically when the lines are read to completion.
    public func close() { state.finish() }
}


// MARK: - Model deprecation warnings (`_data/deprecated_models.py`, `_data/models_to_warn_with_thinking_enabled.py`)

public let DEPRECATED_MODELS: [String: String] = [
    "claude-mythos-preview": "June 30th, 2026",
    "claude-sonnet-4-5": "November 30th, 2026",
    "claude-sonnet-4-5-20250929": "November 30th, 2026",
]

public let MODELS_TO_WARN_WITH_THINKING_ENABLED: [String] = ["claude-opus-4-6", "claude-mythos-preview"]

/// Receives the SDK's warnings (Python's `warnings.warn`). Defaults to writing to standard error.
public enum AnthropicWarnings {
    public enum Category: String, Sendable { case deprecation = "DeprecationWarning", user = "UserWarning" }

    nonisolated(unsafe) private static var handler: (@Sendable (String, Category) -> Void) = { message, category in
        FileHandle.standardError.write(Data("\(category.rawValue): \(message)\n".utf8))
    }
    private static let lock = NSLock()

    /// Replaces the warning handler (e.g. to silence or record warnings in tests).
    public static func setHandler(_ h: @escaping @Sendable (String, Category) -> Void) {
        lock.withLock { handler = h }
    }

    /// A handler scoped to the current task tree (see `capture`); it takes precedence over the global one.
    @TaskLocal static var scopedHandler: (@Sendable (String, Category) -> Void)? = nil

    public static func warn(_ message: String, _ category: Category) {
        if let scoped = scopedHandler {
            scoped(message, category)
            return
        }
        let h = lock.withLock { handler }
        h(message, category)
    }

    /// Runs `body`, collecting the warnings raised in it (and the tasks it starts) instead of
    /// reporting them — like `pytest.warns` / `warnings.catch_warnings(record=True)`.
    public static func capture(_ body: () async throws -> Void) async rethrows -> [(message: String, category: Category)] {
        let box = WarningRecorder()
        try await $scopedHandler.withValue({ message, category in box.append(message, category) }) {
            try await body()
        }
        return box.items
    }
}

final class WarningRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var _items: [(message: String, category: AnthropicWarnings.Category)] = []
    func append(_ message: String, _ category: AnthropicWarnings.Category) { lock.withLock { _items.append((message, category)) } }
    var items: [(message: String, category: AnthropicWarnings.Category)] { lock.withLock { _items } }
}

func warnIfDeprecatedModel(_ model: String) {
    if let date = DEPRECATED_MODELS[model] {
        AnthropicWarnings.warn(
            "The model '\(model)' is deprecated and will reach end-of-life on \(date).\nPlease migrate to a newer model. Visit https://docs.anthropic.com/en/docs/resources/model-deprecations for more information.",
            .deprecation)
    }
}

func warnIfThinkingEnabledDeprecated<T: Encodable>(_ model: String, thinking: T?) {
    guard MODELS_TO_WARN_WITH_THINKING_ENABLED.contains(model), let thinking,
          let json = try? JSONValue.from(thinking), json["type"] == .string("enabled")
    else { return }
    AnthropicWarnings.warn(
        "Using Claude with \(model) and 'thinking.type=enabled' is deprecated. Use 'thinking.type=adaptive' instead which results in better model performance in our testing: https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking",
        .user)
}

/// Joins list-valued header params, e.g. `betas`, plus any defaults the method always sends
/// (`",".join(chain((str(e) for e in betas), [...]))`). Returns `nil` when the list wasn't given.
public func joinHeaderValues<T: OpenEnum>(_ values: [T]?, extra: [String] = [], separator: String = ",") -> String? {
    guard let values else { return nil }
    return (values.map { $0.rawValue } + extra).joined(separator: separator)
}

public func joinHeaderValues(_ values: [String]?, extra: [String] = [], separator: String = ",") -> String? {
    guard let values else { return nil }
    return (values + extra).joined(separator: separator)
}
