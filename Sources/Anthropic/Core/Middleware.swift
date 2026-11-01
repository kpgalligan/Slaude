import Foundation

// Port of `_request.py` and `_middleware.py`.

/// Wraps a metatype so `APIRequest` can stay `Sendable`.
struct _Metatype: @unchecked Sendable {
    let type: Any.Type
}

/// A view over the request that the client is about to execute (`_request.APIRequest`).
///
/// It is a value: derive a modified request with `copy(...)` (or mutate a `var` copy) and pass that
/// to `next`; neither the original request nor later attempts are affected.
public struct APIRequest: Sendable {
    public var options: FinalRequestOptions
    let _castTo: _Metatype
    /// Whether the caller asked for a server-sent-event stream.
    public var stream: Bool
    /// The number of retries the SDK has already taken for this call: `0` on the first attempt
    /// (the middleware chain is invoked once per HTTP attempt).
    public var retriesTaken: Int
    /// The client running the request (unset for requests built by hand).
    let client: BaseClient?

    public init(options: FinalRequestOptions, castTo: Any.Type = JSONValue.self, stream: Bool = false, retriesTaken: Int = 0) {
        self.init(options: options, castTo: castTo, stream: stream, retriesTaken: retriesTaken, client: nil)
    }

    init(options: FinalRequestOptions, castTo: Any.Type, stream: Bool, retriesTaken: Int, client: BaseClient?) {
        self.options = options
        self._castTo = _Metatype(type: castTo)
        self.stream = stream
        self.retriesTaken = retriesTaken
        self.client = client
    }

    /// The type the caller's response is parsed into (Python's `cast_to`).
    public var castTo: Any.Type { _castTo.type }
    public var method: String { options.method }
    public var url: String { options.url }
    /// The per-request headers (empty when none were given).
    public var headers: Headers { options.headers ?? [:] }
    /// The query parameters (Python's `query_params`).
    public var queryParams: Query {
        var q: Query = [:]
        for (k, v) in options.params { q[k] = v }
        return q
    }
    /// The JSON body, with `extra_body` already merged in.
    public var json: JSONValue? { options.jsonData }
    /// `nil` when not given (the client's timeout applies).
    public var timeout: Timeout? { options.timeout }
    public var maxRetries: Int? { options.maxRetries }

    /// A copy of this request with the given parts replaced. `body: .some(nil)` / `timeout: .some(nil)`
    /// clear the body / per-request timeout; leaving an argument out keeps the current value.
    public func copy(method: String? = nil, url: String? = nil, headers: Headers? = nil, params: Query? = nil,
                     body: JSONValue?? = nil, timeout: Timeout?? = nil) -> APIRequest
    {
        var r = self
        if let method { r.options.method = method }
        if let url { r.options.url = url }
        if let headers { r.options.headers = headers }
        if let params { r.options.params = params.sorted(by: { $0.key < $1.key }).map { ($0.key, $0.value) } }
        if let body { r.options.jsonData = body }
        if let timeout { r.options.timeout = timeout }
        return r
    }
}

extension APIRequest: CustomStringConvertible {
    public var description: String { "<APIRequest method='\(method)' url='\(url)' stream=\(stream ? "True" : "False")>" }
}

/// Values parsed from one response, so that parsing it again (e.g. once in middleware and once
/// for the caller) gives the same value and never reads a streamed body twice.
final class ParseCache: @unchecked Sendable {
    private let lock = NSLock()
    private var values: [ObjectIdentifier: any Sendable] = [:]
    /// The type name of the value a middleware short-circuited with, if it did.
    let shortCircuitType: String?

    init(shortCircuitType: String? = nil) { self.shortCircuitType = shortCircuitType }

    func get<T>(_ type: T.Type) -> T? { lock.withLock { values[ObjectIdentifier(T.self)] as? T } }
    func set<T: Sendable>(_ value: T) { lock.withLock { values[ObjectIdentifier(T.self)] = value } }

    /// Returns the cached value, or computes and caches it.
    func value<T: Sendable>(_ type: T.Type, _ compute: () async throws -> T) async throws -> T {
        if let v = get(T.self) { return v }
        if let s = shortCircuitType {
            throw ArgumentTypeError("The middleware chain short-circuited with a value of type \(s), not \(T.self)")
        }
        let v = try await compute()
        set(v)
        return v
    }
}

/// A response flowing back through the middleware chain (what `AsyncAPIResponse` is to Python
/// middleware): the HTTP response of one attempt, whatever its status, plus the options it was sent
/// with. Call `parse(as:)` to decode it; the value is cached and the caller receives that same value.
public final class RawAPIResponse: @unchecked Sendable {
    public let http: HTTPResponse
    public let options: FinalRequestOptions
    public let retriesTaken: Int
    let client: BaseClient?
    let cache: ParseCache

    init(http: HTTPResponse, options: FinalRequestOptions, retriesTaken: Int, client: BaseClient?, cache: ParseCache = ParseCache()) {
        self.http = http
        self.options = options
        self.retriesTaken = retriesTaken
        self.client = client
        self.cache = cache
    }

    /// A response a middleware produced itself (e.g. replayed from a recording), answering `request`.
    public convenience init(_ http: HTTPResponse, for request: APIRequest) {
        self.init(http: http, options: request.options, retriesTaken: request.retriesTaken, client: request.client)
    }

    /// Short-circuits the chain with an already materialised value (e.g. a cached `Message`): no HTTP
    /// request is made and the caller receives `value` as the call's result. The response carries a
    /// synthetic `200` with an empty body.
    public static func shortCircuit<V: Sendable>(_ value: V, for request: APIRequest) -> RawAPIResponse {
        let url = request.client?.prepareURL(request.url) ?? URL(string: request.url) ?? URL(string: "about:blank")!
        let http = HTTPResponse(statusCode: 200, body: Data(), request: HTTPRequest(method: request.method.uppercased(), url: url))
        let cache = ParseCache(shortCircuitType: String(describing: V.self))
        cache.set(value)
        return RawAPIResponse(http: http, options: request.options, retriesTaken: request.retriesTaken, client: request.client, cache: cache)
    }

    /// Whether this response was produced by `shortCircuit(_:for:)`.
    public var isShortCircuit: Bool { cache.shortCircuitType != nil }
    public var statusCode: Int { http.statusCode }
    public var headers: HTTPHeaders { http.headers }
    public var requestID: String? { http.headers["request-id"] }
    public var httpRequest: HTTPRequest { http.request }

    /// Parses the body (once per type; later calls, and the caller, get the cached value).
    public func parse<T: Decodable & Sendable>(as type: T.Type = T.self) async throws -> T {
        try await cache.value(T.self) {
            guard let client else { throw ArgumentTypeError("This response has no client to parse it with") }
            return try await client.decodeBody(T.self, from: http)
        }
    }

    /// The value a previous `parse` produced (or a short-circuit holds), if any.
    public func cachedValue<T>(as type: T.Type = T.self) -> T? { cache.get(T.self) }

    public func read() async throws -> Data { try await http.read() }
    public func text() async throws -> String { try await http.text() }
    public func json() async throws -> JSONValue { try JSONValue.parse(try await http.read()) }
}

/// Invokes the rest of the middleware chain and, ultimately, a single HTTP attempt
/// (`_middleware.AsyncCallNext`).
///
/// The chain runs inside the SDK's retry loop, once per attempt, and returns the response for every
/// HTTP response, including 4xx/5xx: inspect `statusCode` to react to API errors; the SDK throws its
/// typed errors for the original caller after the chain. Connection failures have no response to
/// return, so they throw (`APITimeoutError`, `APIConnectionError`).
public typealias CallNext = @Sendable (APIRequest) async throws -> RawAPIResponse

/// Client-level middleware (`_middleware.Middleware`). The chain runs inside the retry loop,
/// once per attempt, and sees every HTTP response including 4xx/5xx ones. The first middleware
/// given to the client is the outermost.
///
/// Errors a middleware throws propagate to the caller as-is, except those that opt into the retry
/// policy by type: `APIStatusError` (subject to the usual status policy), `APIConnectionError` and
/// `RetryableError` — also when found on an error's `ChainedError.cause` chain.
public protocol Middleware: Sendable {
    func handle(_ request: APIRequest, next: @escaping CallNext) async throws -> RawAPIResponse
}

extension Middleware {
    /// The default passes the request straight on to the rest of the chain.
    public func handle(_ request: APIRequest, next: @escaping CallNext) async throws -> RawAPIResponse {
        try await next(request)
    }
}

/// A middleware built from a closure (Python's middleware functions).
public struct MiddlewareFunction: Middleware {
    public let name: String
    let body: @Sendable (APIRequest, CallNext) async throws -> RawAPIResponse
    public init(name: String = "middleware", _ body: @escaping @Sendable (APIRequest, CallNext) async throws -> RawAPIResponse) {
        self.name = name
        self.body = body
    }
    public func handle(_ request: APIRequest, next: @escaping CallNext) async throws -> RawAPIResponse {
        try await body(request, next)
    }
}

extension BaseClient {
    /// Builds the middleware chain (`_build_middleware_chain`). It only depends on the immutable
    /// `middleware` list, so it is built once, when the client is created.
    func buildMiddlewareChain() -> CallNext? {
        if middleware.isEmpty { return nil }
        var chain: CallNext = { [unowned self] req in
            // The chain always operates on a response wrapper: plain calls are upgraded to "raw" so
            // the body is read; "stream" (`withStreamingResponse`) is left as is.
            var options = req.options
            var headers = options.headers ?? [:]
            let mode = headers[rawResponseHeader]?.stringValue
            if mode != "raw" && mode != "stream" {
                headers[rawResponseHeader] = "raw"
            }
            options.headers = headers
            let (response, prepared) = try await self.attemptRequest(options, stream: req.stream, retriesTaken: req.retriesTaken)
            return RawAPIResponse(http: response, options: prepared, retriesTaken: req.retriesTaken, client: self)
        }
        for m in middleware.reversed() {
            let next = chain
            chain = { req in try await m.handle(req, next: next) }
        }
        return chain
    }
}
