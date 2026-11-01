import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// Case-insensitive, order-preserving HTTP headers (the subset of `httpx2.Headers` the SDK uses).
public struct HTTPHeaders: Sendable, Hashable, Sequence, ExpressibleByDictionaryLiteral, CustomStringConvertible {
    public private(set) var entries: [(name: String, value: String)] = []

    public init() {}
    public init(_ pairs: [(String, String)]) { for (k, v) in pairs { add(k, v) } }
    public init(_ dict: [String: String]) { for (k, v) in dict.sorted(by: { $0.key < $1.key }) { self[k] = v } }
    public init(dictionaryLiteral elements: (String, String)...) { for (k, v) in elements { self[k] = v } }

    /// The first value for `name`, or sets (replacing every existing value) when assigned.
    public subscript(name: String) -> String? {
        get {
            let lower = name.lowercased()
            return entries.first(where: { $0.name.lowercased() == lower })?.value
        }
        set {
            let lower = name.lowercased()
            if let newValue {
                if let idx = entries.firstIndex(where: { $0.name.lowercased() == lower }) {
                    // Like `httpx.Headers.__setitem__`, the name keeps the casing it was last set with.
                    entries[idx] = (name, newValue)
                    var i = entries.count - 1
                    while i > idx {
                        if entries[i].name.lowercased() == lower { entries.remove(at: i) }
                        i -= 1
                    }
                } else {
                    entries.append((name, newValue))
                }
            } else {
                entries.removeAll(where: { $0.name.lowercased() == lower })
            }
        }
    }

    public func get(_ name: String) -> String? { self[name] }

    /// All values for a header name.
    public func values(_ name: String) -> [String] {
        let lower = name.lowercased()
        return entries.filter { $0.name.lowercased() == lower }.map(\.value)
    }

    public mutating func add(_ name: String, _ value: String) { entries.append((name, value)) }

    @discardableResult
    public mutating func remove(_ name: String) -> String? {
        let v = self[name]
        self[name] = nil
        return v
    }

    public func contains(_ name: String) -> Bool { self[name] != nil }

    public var names: [String] { entries.map(\.name) }
    public var count: Int { entries.count }

    /// A plain dictionary with lowercased names (later values win).
    public var dictionary: [String: String] {
        var d: [String: String] = [:]
        for e in entries { d[e.name.lowercased()] = e.value }
        return d
    }

    public func makeIterator() -> IndexingIterator<[(name: String, value: String)]> { entries.makeIterator() }

    public static func == (a: HTTPHeaders, b: HTTPHeaders) -> Bool {
        a.entries.map { [$0.name.lowercased(), $0.value] } == b.entries.map { [$0.name.lowercased(), $0.value] }
    }

    public func hash(into hasher: inout Hasher) {
        for e in entries {
            hasher.combine(e.name.lowercased())
            hasher.combine(e.value)
        }
    }

    public var description: String { "HTTPHeaders(\(entries.map { "\($0.name): \($0.value)" }.joined(separator: ", ")))" }
}

/// Request timeouts, mirroring `httpx2.Timeout`.
///
/// `Timeout.none` (all `nil`) disables timeouts. Integer and float literals create a timeout
/// that applies to every phase, as passing a float to the Python SDK does.
public struct Timeout: Sendable, Hashable, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, CustomStringConvertible {
    public var connect: TimeInterval?
    public var read: TimeInterval?
    public var write: TimeInterval?
    public var pool: TimeInterval?

    public init(_ timeout: TimeInterval?, connect: TimeInterval?? = nil, read: TimeInterval?? = nil,
                write: TimeInterval?? = nil, pool: TimeInterval?? = nil)
    {
        self.connect = connect ?? timeout
        self.read = read ?? timeout
        self.write = write ?? timeout
        self.pool = pool ?? timeout
    }

    public init(connect: TimeInterval?, read: TimeInterval?, write: TimeInterval?, pool: TimeInterval?) {
        self.connect = connect
        self.read = read
        self.write = write
        self.pool = pool
    }

    public init(floatLiteral value: Double) { self.init(value) }
    public init(integerLiteral value: Int) { self.init(TimeInterval(value)) }

    /// No timeout at all (Python's `timeout=None`).
    public static let none = Timeout(nil)

    /// The largest of the phase timeouts, used as the overall request deadline.
    public var overall: TimeInterval? {
        let values = [connect, read, write, pool].compactMap { $0 }
        return values.max()
    }

    /// Python's `str(timeout)` for a plain float timeout renders as e.g. `600.0`.
    public var description: String {
        func fmt(_ v: TimeInterval?) -> String {
            guard let v else { return "None" }
            return pythonFloatString(v)
        }
        if connect == read && read == write && write == pool { return "Timeout(timeout=\(fmt(read)))" }
        return "Timeout(connect=\(fmt(connect)), read=\(fmt(read)), write=\(fmt(write)), pool=\(fmt(pool)))"
    }
}

/// Renders a Double the way Python's `str(float)` does (`600.0`, `0.5`, `1e-05`).
func pythonFloatString(_ v: Double) -> String {
    if v.rounded() == v && abs(v) < 1e16 { return String(format: "%.1f", v) }
    return String(v)
}

/// A request about to be sent.
public struct HTTPRequest: Sendable {
    public var method: String
    public var url: URL
    public var headers: HTTPHeaders
    public var body: Data?
    public var timeout: Timeout

    public init(method: String, url: URL, headers: HTTPHeaders = HTTPHeaders(), body: Data? = nil, timeout: Timeout = .none) {
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
        self.timeout = timeout
    }

    /// The decoded JSON body, when the request has one.
    public var jsonBody: JSONValue? { body.flatMap { try? JSONValue.parse($0) } }

    /// The query items of the request URL, in order.
    public var queryItems: [URLQueryItem] { URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? [] }

    /// The value of the first query parameter named `name`.
    public func query(_ name: String) -> String? { queryItems.first(where: { $0.name == name })?.value }
}

/// A stream of response body chunks.
public typealias ByteStream = AsyncThrowingStream<Data, Error>

/// A response received from a transport. The body is a stream so that SSE responses can be
/// consumed incrementally; `HTTPResponse.read()` collects it.
public final class HTTPResponse: @unchecked Sendable {
    public let statusCode: Int
    public let headers: HTTPHeaders
    public let request: HTTPRequest
    public let reasonPhrase: String
    private let lock = NSLock()
    private var stream: ByteStream?
    private var buffered: Data?
    private var _isClosed = false
    private let onClose: (@Sendable () -> Void)?
    public let elapsed: TimeInterval

    public init(statusCode: Int, headers: HTTPHeaders = HTTPHeaders(), body: Data, request: HTTPRequest, elapsed: TimeInterval = 0) {
        self.statusCode = statusCode
        self.headers = headers
        self.request = request
        self.buffered = body
        self.stream = nil
        self.onClose = nil
        self.reasonPhrase = HTTPResponse.reason(for: statusCode)
        self.elapsed = elapsed
    }

    public init(statusCode: Int, headers: HTTPHeaders = HTTPHeaders(), stream: ByteStream, request: HTTPRequest,
                elapsed: TimeInterval = 0, onClose: (@Sendable () -> Void)? = nil)
    {
        self.statusCode = statusCode
        self.headers = headers
        self.request = request
        self.stream = stream
        self.buffered = nil
        self.onClose = onClose
        self.reasonPhrase = HTTPResponse.reason(for: statusCode)
        self.elapsed = elapsed
    }

    public var isSuccess: Bool { (200..<300).contains(statusCode) }
    public var isClosed: Bool { lock.withLock { _isClosed } }
    public var isStreamConsumed: Bool { lock.withLock { stream == nil } }

    /// Reads the whole body (once; subsequent calls return the buffered bytes).
    public func read() async throws -> Data {
        if let b = lock.withLock({ buffered }) {
            close()
            return b
        }
        let s: ByteStream? = lock.withLock {
            let s = stream
            stream = nil
            return s
        }
        var data = Data()
        if let s {
            for try await chunk in s { data.append(chunk) }
        }
        lock.withLock { buffered = data }
        close()
        return data
    }

    /// The response text (UTF-8).
    public func text() async throws -> String { String(decoding: try await read(), as: UTF8.self) }

    /// Iterates over the body's chunks. If the body was already read, yields the buffer once.
    public func bytes() -> ByteStream {
        if let b = lock.withLock({ buffered }) {
            return ByteStream { c in
                if !b.isEmpty { c.yield(b) }
                c.finish()
            }
        }
        let s: ByteStream? = lock.withLock {
            let s = stream
            stream = nil
            return s
        }
        guard let s else { return ByteStream { $0.finish() } }
        return s
    }

    public func close() {
        let shouldNotify: Bool = lock.withLock {
            if _isClosed { return false }
            _isClosed = true
            return true
        }
        if shouldNotify { onClose?() }
    }

    static func reason(for status: Int) -> String {
        switch status {
        case 200: return "OK"
        case 201: return "Created"
        case 202: return "Accepted"
        case 204: return "No Content"
        case 400: return "Bad Request"
        case 401: return "Unauthorized"
        case 403: return "Forbidden"
        case 404: return "Not Found"
        case 408: return "Request Timeout"
        case 409: return "Conflict"
        case 413: return "Payload Too Large"
        case 422: return "Unprocessable Entity"
        case 429: return "Too Many Requests"
        case 500: return "Internal Server Error"
        case 502: return "Bad Gateway"
        case 503: return "Service Unavailable"
        case 504: return "Gateway Timeout"
        case 529: return "Overloaded"
        default: return HTTPURLResponse.localizedString(forStatusCode: status)
        }
    }
}

/// An error raised by a transport when the request timed out.
public struct TransportTimeoutError: Error, Sendable {
    public init() {}
}

/// Sends HTTP requests. The default is `URLSessionTransport`; tests use `MockTransport`.
///
/// This is the Swift counterpart of the `http_client=` argument (an `httpx2.AsyncClient`).
public protocol HTTPTransport: Sendable {
    /// Sends the request. When `stream` is false the transport may buffer the body.
    func send(_ request: HTTPRequest, stream: Bool) async throws -> HTTPResponse
    /// Releases any resources the transport holds.
    func close() async
}

extension HTTPTransport {
    public func close() async {}
}

/// A transport that answers requests with a handler, like `httpx2.MockTransport`.
public struct MockTransport: HTTPTransport {
    public typealias Handler = @Sendable (HTTPRequest) async throws -> HTTPResponse
    let handler: Handler

    public init(_ handler: @escaping Handler) { self.handler = handler }

    public func send(_ request: HTTPRequest, stream: Bool) async throws -> HTTPResponse {
        try await handler(request)
    }
}

extension HTTPResponse {
    /// Convenience for building mock JSON responses.
    public static func json(_ value: JSONValue, status: Int = 200, headers: HTTPHeaders = HTTPHeaders(), for request: HTTPRequest) -> HTTPResponse {
        var h = headers
        if h["content-type"] == nil { h["content-type"] = "application/json" }
        return HTTPResponse(statusCode: status, headers: h, body: (try? JSONValue.serialize(value)) ?? Data(), request: request)
    }

    /// Convenience for building mock text responses.
    public static func text(_ text: String, status: Int = 200, headers: HTTPHeaders = HTTPHeaders(), for request: HTTPRequest) -> HTTPResponse {
        HTTPResponse(statusCode: status, headers: headers, body: Data(text.utf8), request: request)
    }
}

/// The default transport, built on `URLSession` with incremental body delivery.
public final class URLSessionTransport: NSObject, HTTPTransport, URLSessionDataDelegate, @unchecked Sendable {
    private var session: URLSession!
    private let lock = NSLock()
    private var tasks: [Int: TaskState] = [:]

    private final class TaskState {
        var responseContinuation: CheckedContinuation<HTTPResponse, Error>?
        var bodyContinuation: ByteStream.Continuation?
        var request: HTTPRequest
        var start: Date
        init(request: HTTPRequest, continuation: CheckedContinuation<HTTPResponse, Error>) {
            self.request = request
            self.responseContinuation = continuation
            self.start = Date()
        }
    }

    public init(configuration: URLSessionConfiguration = .default) {
        super.init()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
    }

    public func send(_ request: HTTPRequest, stream: Bool) async throws -> HTTPResponse {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method
        for (name, value) in request.headers { urlRequest.addValue(value, forHTTPHeaderField: name) }
        urlRequest.httpBody = request.body
        if let t = request.timeout.read ?? request.timeout.overall { urlRequest.timeoutInterval = t } else {
            urlRequest.timeoutInterval = .greatestFiniteMagnitude
        }
        let task = session.dataTask(with: urlRequest)
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<HTTPResponse, Error>) in
                lock.withLock { tasks[task.taskIdentifier] = TaskState(request: request, continuation: cont) }
                task.resume()
            }
        } onCancel: {
            task.cancel()
        }
    }

    public func close() async { session.invalidateAndCancel() }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                           completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    {
        let id = dataTask.taskIdentifier
        guard let state = lock.withLock({ tasks[id] }), let http = response as? HTTPURLResponse else {
            completionHandler(.cancel)
            return
        }
        var headers = HTTPHeaders()
        for (k, v) in http.allHeaderFields {
            if let k = k as? String, let v = v as? String { headers.add(k, v) }
        }
        var continuation: ByteStream.Continuation!
        let body = ByteStream { continuation = $0 }
        continuation.onTermination = { @Sendable term in
            if case .cancelled = term { dataTask.cancel() }
        }
        let cont: CheckedContinuation<HTTPResponse, Error>? = lock.withLock {
            state.bodyContinuation = continuation
            let c = state.responseContinuation
            state.responseContinuation = nil
            return c
        }
        let resp = HTTPResponse(
            statusCode: http.statusCode, headers: headers, stream: body, request: state.request,
            elapsed: Date().timeIntervalSince(state.start),
            onClose: { dataTask.cancel() }
        )
        cont?.resume(returning: resp)
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let id = dataTask.taskIdentifier
        lock.withLock { tasks[id] }?.bodyContinuation?.yield(data)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        let id = task.taskIdentifier
        guard let state = lock.withLock({ tasks.removeValue(forKey: id) }) else { return }
        var mapped: Error? = error
        if let e = error as? URLError, e.code == .timedOut { mapped = TransportTimeoutError() }
        if let cont = state.responseContinuation {
            cont.resume(throwing: mapped ?? URLError(.badServerResponse))
        }
        if let b = state.bodyContinuation {
            if let mapped, (error as? URLError)?.code != .cancelled { b.finish(throwing: mapped) } else { b.finish() }
        }
    }
}
