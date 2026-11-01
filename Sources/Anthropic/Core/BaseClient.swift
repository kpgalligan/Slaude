import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public let ANTHROPIC_API_VERSION = "2026-10-21"
public let DEFAULT_MAX_RETRIES = 2
/// The default timeout is 10 minutes, with 5 seconds to connect.
public let DEFAULT_TIMEOUT = Timeout(600, connect: 5.0)
public let INITIAL_RETRY_DELAY: Double = 0.5
public let MAX_RETRY_DELAY: Double = 8.0
public let MODEL_NONSTREAMING_TOKENS: [String: Int] = [
    "claude-opus-4-20250514": 8_192,
    "claude-opus-4-0": 8_192,
    "claude-4-opus-20250514": 8_192,
    "anthropic.claude-opus-4-20250514-v1:0": 8_192,
    "claude-opus-4@20250514": 8_192,
    "anthropic.claude-opus-4-1-20250805-v1:0": 8192,
    "claude-opus-4-1@20250805": 8192,
]

/// One HTTP attempt as seen by middleware (`_request.APIRequest`).
public struct APIRequest: Sendable {
    public var options: FinalRequestOptions
    public var stream: Bool
    public var retriesTaken: Int
}

/// A response flowing back through the middleware chain: the HTTP response plus the options it
/// was sent with. Call `parse(as:)` to decode it.
public struct RawAPIResponse: Sendable {
    public let http: HTTPResponse
    public let options: FinalRequestOptions
    public let retriesTaken: Int
    let client: BaseClient

    public var statusCode: Int { http.statusCode }
    public var headers: HTTPHeaders { http.headers }

    public func parse<T: Decodable & Sendable>(as type: T.Type) async throws -> T {
        try await client.decodeBody(T.self, from: http)
    }
}

/// Invokes the rest of the middleware chain and, ultimately, a single HTTP attempt.
public typealias CallNext = @Sendable (APIRequest) async throws -> RawAPIResponse

/// Client-level middleware (`_middleware.Middleware`). The chain runs inside the retry loop,
/// once per attempt, and sees every HTTP response including 4xx/5xx ones.
public protocol Middleware: Sendable {
    func handle(_ request: APIRequest, next: CallNext) async throws -> RawAPIResponse
}

/// A middleware built from a closure.
public struct MiddlewareFunction: Middleware {
    public let name: String
    let body: @Sendable (APIRequest, CallNext) async throws -> RawAPIResponse
    public init(name: String = "middleware", _ body: @escaping @Sendable (APIRequest, CallNext) async throws -> RawAPIResponse) {
        self.name = name
        self.body = body
    }
    public func handle(_ request: APIRequest, next: CallNext) async throws -> RawAPIResponse {
        try await body(request, next)
    }
}

/// The operating system reported in `X-Stainless-OS`.
func currentPlatform() -> String {
    #if os(iOS)
        return "iOS"
    #elseif os(macOS)
        return "MacOS"
    #elseif os(Linux)
        return "Linux"
    #elseif os(Windows)
        return "Windows"
    #elseif os(Android)
        return "Android"
    #elseif os(FreeBSD)
        return "FreeBSD"
    #elseif os(OpenBSD)
        return "OpenBSD"
    #elseif os(tvOS)
        return "Other:tvos"
    #elseif os(watchOS)
        return "Other:watchos"
    #else
        return "Unknown"
    #endif
}

func currentArchitecture() -> String {
    #if arch(arm64)
        return "arm64"
    #elseif arch(arm)
        return "arm"
    #elseif arch(x86_64)
        return "x64"
    #elseif arch(i386)
        return "x32"
    #else
        return "unknown"
    #endif
}

func swiftVersion() -> String {
    #if swift(>=6.3)
        return "6.3"
    #elseif swift(>=6.2)
        return "6.2"
    #elseif swift(>=6.1)
        return "6.1"
    #elseif swift(>=6.0)
        return "6.0"
    #else
        return "5"
    #endif
}

/// The request pipeline shared by `Anthropic` and the platform clients (`_base_client.AsyncAPIClient`).
///
/// Subclasses customise behaviour by overriding the hooks (`defaultHeaders`, `authHeaders`,
/// `prepareOptions`, `prepareRequest`, `validateHeaders`, `shouldRetry`, `makeStatusError`, ...),
/// just like the Python platform clients override the `_`-prefixed methods.
open class BaseClient: @unchecked Sendable {
    public let version: String
    public let baseURL: URL
    public let maxRetries: Int
    public let timeout: Timeout
    public internal(set) var timeoutOverridden: Bool
    public let customHeaders: Headers
    public let customQuery: Query
    public let transport: HTTPTransport
    public let middleware: [Middleware]
    /// The header that carries the idempotency key, if the API supports one.
    open var idempotencyHeader: String? { nil }

    /// Overridable sleep, so tests can observe retry delays without waiting.
    public var sleeper: @Sendable (TimeInterval) async throws -> Void = { seconds in
        if seconds > 0 { try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000)) }
    }

    public init(version: String, baseURL: URL, maxRetries: Int = DEFAULT_MAX_RETRIES, timeout: Timeout? = nil,
                customHeaders: Headers? = nil, customQuery: Query? = nil, transport: HTTPTransport? = nil,
                middleware: [Middleware]? = nil)
    {
        self.version = version
        self.baseURL = BaseClient.enforceTrailingSlash(baseURL)
        self.maxRetries = maxRetries
        self.timeoutOverridden = timeout != nil
        self.timeout = timeout ?? DEFAULT_TIMEOUT
        self.customHeaders = customHeaders ?? [:]
        self.customQuery = customQuery ?? [:]
        self.transport = transport ?? URLSessionTransport()
        self.middleware = middleware ?? []
    }

    static func enforceTrailingSlash(_ url: URL) -> URL {
        let s = url.absoluteString
        if s.hasSuffix("/") { return url }
        return URL(string: s + "/") ?? url
    }

    // MARK: - Hooks

    open var authHeaders: Headers { [:] }

    open var userAgent: String { "\(String(describing: type(of: self)))/Swift \(version)" }

    open var platformHeaders: Headers {
        [
            "X-Stainless-Lang": "swift",
            "X-Stainless-Package-Version": .value(version),
            "X-Stainless-OS": .value(currentPlatform()),
            "X-Stainless-Arch": .value(currentArchitecture()),
            "X-Stainless-Runtime": "swift",
            "X-Stainless-Runtime-Version": .value(swiftVersion()),
        ]
    }

    open var defaultHeaders: Headers {
        mergeHeaderLayers(
            ["Accept": "application/json", "Content-Type": "application/json", "User-Agent": .value(userAgent)],
            platformHeaders, authHeaders, customHeaders)
    }

    open var defaultQuery: Query { customQuery }

    open var querystring: Querystring { Querystring() }

    /// Validates the headers a request is about to be sent with. `omitted` holds the lowercase
    /// names a layer explicitly removed with `.omit`.
    open func validateHeaders(_ headers: HTTPHeaders, omitted: Set<String>) throws {}

    /// Hook for mutating the options before a request is built.
    open func prepareOptions(_ options: FinalRequestOptions) async throws -> FinalRequestOptions { options }

    /// Hook for mutating the built request (e.g. signing it) before it is sent.
    open func prepareRequest(_ request: inout HTTPRequest) async throws {}

    /// Hook for adding auth to the request right before sending (Python's `custom_auth`).
    open func authenticate(_ request: inout HTTPRequest) async throws {}

    /// Builds the typed status error for a failed response.
    open func makeStatusError(_ message: String, body: JSONValue?, response: HTTPResponse) -> APIStatusError {
        Anthropic_makeStatusError(message, body: body, response: response)
    }

    /// Turns a response body into Server-Sent Events (Bedrock overrides this for its event stream).
    open func makeSSEEvents(_ bytes: ByteStream) -> AsyncThrowingStream<ServerSentEvent, Error> {
        SSEDecoder.events(from: bytes)
    }

    open func shouldRetry(_ response: HTTPResponse) -> Bool {
        let header = response.headers["x-should-retry"]
        if header == "true" { return true }
        if header == "false" { return false }
        if response.statusCode == 408 { return true }
        if response.statusCode == 409 { return true }
        if response.statusCode == 429 { return true }
        if response.statusCode >= 500 { return true }
        return false
    }

    open func idempotencyKey() -> String { "stainless-swift-retry-\(UUID().uuidString.lowercased())" }

    /// Closes the underlying transport.
    open func close() async { await transport.close() }

    // MARK: - Request building

    func buildHeaders(_ options: FinalRequestOptions, retriesTaken: Int) throws -> HTTPHeaders {
        let timeout = options.timeout ?? self.timeout
        var base: Headers = [:]
        // Python renders `str(options.timeout)` here, which is "NOT_GIVEN" when unset.
        if let t = options.timeout {
            base["x-stainless-timeout"] = .value(t.read.map(pythonFloatString) ?? "None")
        } else {
            base["x-stainless-timeout"] = "NOT_GIVEN"
        }
        base["x-stainless-retry-count"] = .value(String(retriesTaken))
        if let read = timeout.read { base["x-stainless-read-timeout"] = .value(pythonFloatString(read)) }
        if let header = idempotencyHeader, let key = options.idempotencyKey { base[header] = .value(key) }
        let (headers, omitted) = buildHeaderLayers([base, defaultHeaders, customHeaders, options.headers ?? [:]])
        try validateHeaders(headers, omitted: omitted)
        return headers
    }

    /// Merges a URL argument with the client's base URL (`_prepare_url`).
    open func prepareURL(_ url: String) -> URL {
        if let u = URL(string: url), u.scheme != nil { return u }
        var path = url
        while path.hasPrefix("/") { path.removeFirst() }
        return URL(string: baseURL.absoluteString + path) ?? baseURL
    }

    open func buildRequest(_ options: FinalRequestOptions, retriesTaken: Int = 0) throws -> HTTPRequest {
        var jsonData = options.jsonData
        if let extra = options.extraJSON {
            if jsonData == nil {
                jsonData = .object(extra)
            } else if case .object(var o)? = jsonData {
                for (k, v) in extra { o[k] = v }
                jsonData = .object(o)
            } else {
                throw AnthropicError("Unexpected JSON data type, cannot merge with `extra_body`")
            }
        }

        var headers = try buildHeaders(options, retriesTaken: retriesTaken)
        var params: [(String, JSONValue)] = defaultQuery.sorted(by: { $0.key < $1.key }).map { ($0.key, $0.value) }
        for (k, v) in options.params {
            if let i = params.firstIndex(where: { $0.0 == k }) { params[i].1 = v } else { params.append((k, v)) }
        }

        var url = prepareURL(options.url)
        // Preserve hard-coded query params from the url.
        if var comps = URLComponents(url: url, resolvingAgainstBaseURL: false), let existing = comps.queryItems, !existing.isEmpty {
            if !params.isEmpty {
                var merged: [(String, JSONValue)] = existing.map { ($0.name, .string($0.value ?? "")) }
                for (k, v) in params {
                    if let i = merged.firstIndex(where: { $0.0 == k }) { merged[i].1 = v } else { merged.append((k, v)) }
                }
                params = merged
                comps.query = nil
                url = comps.url ?? url
            }
        }

        if !params.isEmpty {
            let qs = querystring.stringify(params)
            if !qs.isEmpty, var comps = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                comps.percentEncodedQuery = qs.replacingOccurrences(of: "+", with: "%20")
                url = comps.url ?? url
            }
        }

        var body: Data? = nil
        let isBodyAllowed = options.method.lowercased() != "get"
        let contentType = headers["Content-Type"]
        let isMultipart = contentType?.lowercased().hasPrefix("multipart/form-data") ?? false
        if isBodyAllowed {
            if options.content != nil && jsonData != nil {
                throw ArgumentTypeError("Passing both `content` and `json_data` is not supported")
            }
            if options.content != nil && options.files != nil {
                throw ArgumentTypeError("Passing both `content` and `files` is not supported")
            }
            if let content = options.content {
                body = content
            } else if isMultipart || options.files != nil {
                var fields: [(String, String)] = []
                if let jsonData {
                    guard case .object(let o) = jsonData else {
                        throw ArgumentTypeError("Expected query input to be a dictionary for multipart requests")
                    }
                    fields = querystring.stringifyItems(o, arrayFormat: .brackets)
                }
                let boundary: String
                if let ct = contentType, let range = ct.range(of: "boundary=") {
                    boundary = String(ct[range.upperBound...])
                } else {
                    boundary = "----slaude-boundary-\(UUID().uuidString.lowercased())"
                    headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
                }
                body = Multipart.encode(fields: fields, files: options.files ?? [], boundary: boundary)
            } else if let jsonData {
                body = try JSONValue.serialize(jsonData)
            }
        } else {
            headers.remove("Content-Type")
        }

        return HTTPRequest(method: options.method.uppercased(), url: url, headers: headers, body: body, timeout: options.timeout ?? timeout)
    }

    // MARK: - Sending

    /// Sends one attempt and returns the response whatever its status (`_attempt_request`).
    func attemptRequest(_ options: FinalRequestOptions, stream: Bool, retriesTaken: Int) async throws -> (HTTPResponse, FinalRequestOptions) {
        let options = try await prepareOptions(options)
        var request = try buildRequest(options, retriesTaken: retriesTaken)
        try await prepareRequest(&request)
        try await authenticate(&request)
        let wantsStream = stream || request.headers[rawResponseHeader] == "stream"
        do {
            let response = try await transport.send(request, stream: wantsStream)
            if !wantsStream { _ = try await response.read() }
            return (response, options)
        } catch let e as AnthropicError {
            throw e
        } catch is TransportTimeoutError {
            throw APITimeoutError(request: request)
        } catch let e as URLError where e.code == .timedOut {
            throw APITimeoutError(request: request)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw APIConnectionError(request: request, underlying: error)
        }
    }

    func shouldRetryError(_ error: Error) -> (Bool, HTTPResponse?) {
        if error is RetryableError { return (true, nil) }
        if let e = error as? APIStatusError { return (shouldRetry(e.response), e.response) }
        if error is APIConnectionError { return (true, nil) }
        return (false, nil)
    }

    /// Runs the retry loop and returns the successful response (`_request`).
    public func sendRequest(_ inputOptions: FinalRequestOptions, stream: Bool) async throws -> RawAPIResponse {
        var input = inputOptions
        if input.idempotencyKey == nil && input.method.lowercased() != "get" {
            input.idempotencyKey = idempotencyKey()
        }
        let maxRetries = input.getMaxRetries(self.maxRetries)
        var retriesTaken = 0
        while true {
            let remaining = maxRetries - retriesTaken
            var response: HTTPResponse
            var prepared: FinalRequestOptions
            do {
                if middleware.isEmpty {
                    (response, prepared) = try await attemptRequest(input, stream: stream, retriesTaken: retriesTaken)
                } else {
                    let raw = try await runMiddleware(APIRequest(options: input, stream: stream, retriesTaken: retriesTaken))
                    response = raw.http
                    prepared = raw.options
                }
            } catch {
                let (retry, failed) = shouldRetryError(error)
                if remaining <= 0 || !retry { throw error }
                failed?.close()
                try await sleepForRetry(retriesTaken: retriesTaken, maxRetries: maxRetries, options: input, response: failed)
                retriesTaken += 1
                continue
            }
            if response.isSuccess {
                return RawAPIResponse(http: response, options: prepared, retriesTaken: retriesTaken, client: self)
            }
            if remaining > 0 && shouldRetry(response) {
                response.close()
                try await sleepForRetry(retriesTaken: retriesTaken, maxRetries: maxRetries, options: input, response: response)
                retriesTaken += 1
                continue
            }
            throw await makeStatusErrorFromResponse(response)
        }
    }

    func runMiddleware(_ request: APIRequest) async throws -> RawAPIResponse {
        var chain: CallNext = { [self] req in
            var options = req.options
            if options.headers?[rawResponseHeader] == nil {
                var h = options.headers ?? [:]
                h[rawResponseHeader] = "raw"
                options.headers = h
            }
            let (response, prepared) = try await self.attemptRequest(options, stream: req.stream, retriesTaken: req.retriesTaken)
            return RawAPIResponse(http: response, options: prepared, retriesTaken: req.retriesTaken, client: self)
        }
        for m in middleware.reversed() {
            let next = chain
            chain = { req in try await m.handle(req, next: next) }
        }
        return try await chain(request)
    }

    func makeStatusErrorFromResponse(_ response: HTTPResponse) async -> APIStatusError {
        let text = ((try? await response.text()) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        var body: JSONValue? = .string(text)
        var message: String
        if let parsed = try? JSONValue.parse(text) {
            body = parsed
            message = "Error code: \(response.statusCode) - \(pythonRepr(parsed))"
        } else {
            message = text.isEmpty ? "Error code: \(response.statusCode)" : text
        }
        return makeStatusError(message, body: body, response: response)
    }

    func sleepForRetry(retriesTaken: Int, maxRetries: Int, options: FinalRequestOptions, response: HTTPResponse?) async throws {
        let remaining = maxRetries - retriesTaken
        let t = calculateRetryTimeout(remainingRetries: remaining, options: options, responseHeaders: response?.headers)
        try await sleeper(t)
    }

    /// Seconds to wait before retrying, honouring `retry-after-ms` / `retry-after`.
    public func calculateRetryTimeout(remainingRetries: Int, options: FinalRequestOptions, responseHeaders: HTTPHeaders?) -> TimeInterval {
        let maxRetries = options.getMaxRetries(self.maxRetries)
        if let retryAfter = BaseClient.parseRetryAfterHeader(responseHeaders), retryAfter > 0 {
            return min(retryAfter, 4_294_967.0)
        }
        let nbRetries = min(maxRetries - remainingRetries, 1000)
        let sleepSeconds = min(INITIAL_RETRY_DELAY * pow(2.0, Double(nbRetries)), MAX_RETRY_DELAY)
        let jitter = 1 - 0.25 * Double.random(in: 0..<1)
        let timeout = sleepSeconds * jitter
        return timeout >= 0 ? timeout : 0
    }

    /// Seconds (not milliseconds) to wait, or `nil` when unspecified (`_parse_retry_after_header`).
    public static func parseRetryAfterHeader(_ headers: HTTPHeaders?) -> TimeInterval? {
        guard let headers else { return nil }
        if let ms = headers["retry-after-ms"], let v = Double(ms.trimmingCharacters(in: .whitespaces)) { return v / 1000 }
        guard let header = headers["retry-after"] else { return nil }
        if let v = Double(header.trimmingCharacters(in: .whitespaces)) { return v }
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "GMT")
        for fmt in ["EEE, dd MMM yyyy HH:mm:ss zzz", "EEE, dd MMM yyyy HH:mm:ss Z", "EEEE, dd-MMM-yy HH:mm:ss zzz", "EEE MMM d HH:mm:ss yyyy"] {
            f.dateFormat = fmt
            if let d = f.date(from: header) { return d.timeIntervalSinceNow }
        }
        return nil
    }

    /// The timeout to use for a non-streaming Messages request (`_calculate_nonstreaming_timeout`).
    public func calculateNonstreamingTimeout(maxTokens: Int, maxNonstreamingTokens: Int?) throws -> Timeout {
        let maximumTime = 60.0 * 60
        let defaultTime = 60.0 * 10
        let expectedTime = maximumTime * Double(maxTokens) / 128_000
        if expectedTime > defaultTime || (maxNonstreamingTokens.map { $0 > 0 && maxTokens > $0 } ?? false) {
            throw ValueError(
                "Streaming is required for operations that may take longer than 10 minutes. See https://platform.claude.com/docs/en/cli-sdks-libraries/sdks/python#long-requests for more details"
            )
        }
        return Timeout(defaultTime, connect: 5.0)
    }

    // MARK: - Decoding

    func decodeData<T: Decodable>(_ type: T.Type, _ data: Data, response: HTTPResponse) throws -> T {
        if T.self == EmptyResponse.self { return EmptyResponse() as! T }
        if T.self == JSONValue.self, data.isEmpty { return JSONValue.null as! T }
        do {
            return try AnthropicJSON.decoder().decode(T.self, from: data)
        } catch {
            throw APIResponseValidationError(response: response, body: try? JSONValue.parse(data), underlying: error)
        }
    }

    func decodeBody<T: Decodable>(_ type: T.Type, from response: HTTPResponse) async throws -> T {
        let data = try await response.read()
        if T.self == String.self, (try? JSONValue.parse(data))?.stringValue == nil {
            return String(decoding: data, as: UTF8.self) as! T
        }
        return try decodeData(T.self, data, response: response)
    }

    // MARK: - Typed request entry points used by generated resources

    /// A JSON response.
    public func requestResponse<T: Decodable & Sendable>(_ type: T.Type, _ options: FinalRequestOptions, stream: Bool = false,
                                                         postParser: (@Sendable (T) throws -> T)? = nil) async throws -> APIResponse<T>
    {
        let raw = try await sendRequest(options, stream: stream)
        return APIResponse(http: raw.http, options: raw.options, retriesTaken: raw.retriesTaken, client: self) { resp in
            let value = try await resp.client.decodeBody(T.self, from: resp.http)
            return try postParser?(value) ?? value
        }
    }

    /// A paginated response.
    public func requestPageResponse<P: AsyncPage>(_ type: P.Type, _ options: FinalRequestOptions, stream: Bool = false) async throws -> APIResponse<P> {
        let raw = try await sendRequest(options, stream: stream)
        let prepared = options
        return APIResponse(http: raw.http, options: raw.options, retriesTaken: raw.retriesTaken, client: self) { resp in
            var page = try await resp.client.decodeBody(P.self, from: resp.http)
            page.context = PageContext(client: resp.client, options: prepared)
            return page
        }
    }

    func requestPage<P: AsyncPage>(_ type: P.Type, _ options: FinalRequestOptions) async throws -> P {
        try await requestPageResponse(P.self, options).parse()
    }

    /// A server-sent-event stream.
    public func requestStreamResponse<E: Decodable & Sendable>(_ type: E.Type, _ options: FinalRequestOptions) async throws -> APIResponse<Stream<E>> {
        let raw = try await sendRequest(options, stream: true)
        return APIResponse(http: raw.http, options: raw.options, retriesTaken: raw.retriesTaken, client: self) { resp in
            Stream<E>(response: resp.http, client: resp.client)
        }
    }

    /// A binary response.
    public func requestBinaryResponse(_ options: FinalRequestOptions, stream: Bool = false) async throws -> APIResponse<BinaryResponse> {
        let raw = try await sendRequest(options, stream: stream)
        return APIResponse(http: raw.http, options: raw.options, retriesTaken: raw.retriesTaken, client: self) { resp in
            BinaryResponse(response: resp.http)
        }
    }

    /// Makes an arbitrary request to the API (`client.get` / `client.post` / ...).
    public func request<T: Decodable & Sendable>(_ type: T.Type = T.self, method: String, path: String, body: JSONValue? = nil,
                                                 query: Query? = nil, options: RequestOptions = RequestOptions()) async throws -> T
    {
        var o = FinalRequestOptions(method: method, url: path, jsonData: body)
        apply(options, to: &o, query: query.map { $0.sorted(by: { $0.key < $1.key }).map { ($0.key, $0.value) } })
        return try await requestResponse(T.self, o).parse()
    }

    public func get<T: Decodable & Sendable>(_ path: String, as type: T.Type = T.self, query: Query? = nil, options: RequestOptions = RequestOptions()) async throws -> T {
        try await request(T.self, method: "get", path: path, query: query, options: options)
    }

    public func post<T: Decodable & Sendable>(_ path: String, body: JSONValue? = nil, as type: T.Type = T.self, query: Query? = nil, options: RequestOptions = RequestOptions()) async throws -> T {
        try await request(T.self, method: "post", path: path, body: body, query: query, options: options)
    }

    public func patch<T: Decodable & Sendable>(_ path: String, body: JSONValue? = nil, as type: T.Type = T.self, options: RequestOptions = RequestOptions()) async throws -> T {
        try await request(T.self, method: "patch", path: path, body: body, options: options)
    }

    public func put<T: Decodable & Sendable>(_ path: String, body: JSONValue? = nil, as type: T.Type = T.self, options: RequestOptions = RequestOptions()) async throws -> T {
        try await request(T.self, method: "put", path: path, body: body, options: options)
    }

    public func delete<T: Decodable & Sendable>(_ path: String, body: JSONValue? = nil, as type: T.Type = T.self, options: RequestOptions = RequestOptions()) async throws -> T {
        try await request(T.self, method: "delete", path: path, body: body, options: options)
    }

    /// Applies per-call options (`make_request_options`).
    public func apply(_ options: RequestOptions, to o: inout FinalRequestOptions, query: [(String, JSONValue)]? = nil) {
        if let h = options.extraHeaders { o.headers = mergeHeaderLayers(o.headers, h) }
        if let b = options.extraBody { o.extraJSON = b }
        if let query { o.params = query }
        if let q = options.extraQuery {
            for (k, v) in q.sorted(by: { $0.key < $1.key }) { o.setParam(k, v) }
        }
        if let t = options.timeout { o.timeout = t }
        if let r = options.maxRetries { o.maxRetries = r }
    }
}

// Indirection so subclasses that override `makeStatusError` can still reach the default mapping.
func Anthropic_makeStatusError(_ message: String, body: JSONValue?, response: HTTPResponse) -> APIStatusError {
    makeStatusError(message, body: body, response: response)
}

/// `multipart/form-data` encoding.
enum Multipart {
    static func encode(fields: [(String, String)], files: [(String, FileUpload)], boundary: String) -> Data {
        var body = Data()
        func line(_ s: String) { body.append(Data((s + "\r\n").utf8)) }
        for (name, value) in fields {
            line("--\(boundary)")
            line("Content-Disposition: form-data; name=\"\(escape(name))\"")
            line("")
            line(value)
        }
        for (name, file) in files {
            line("--\(boundary)")
            let filename = file.filename ?? "upload"
            line("Content-Disposition: form-data; name=\"\(escape(name))\"; filename=\"\(escape(filename))\"")
            line("Content-Type: \(file.contentType ?? guessContentType(filename))")
            for (k, v) in file.headers.sorted(by: { $0.key < $1.key }) { line("\(k): \(v)") }
            line("")
            body.append(file.data)
            line("")
        }
        line("--\(boundary)--")
        return body
    }

    static func escape(_ s: String) -> String {
        s.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "%22")
            .replacingOccurrences(of: "\n", with: "%0A").replacingOccurrences(of: "\r", with: "%0D")
    }

    static func guessContentType(_ filename: String) -> String {
        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        case "txt": return "text/plain"
        case "json": return "application/json"
        case "pdf": return "application/pdf"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif": return "image/gif"
        case "webp": return "image/webp"
        case "md": return "text/markdown"
        case "csv": return "text/csv"
        case "html", "htm": return "text/html"
        case "zip": return "application/zip"
        case "py": return "text/x-python"
        default: return "application/octet-stream"
        }
    }
}
