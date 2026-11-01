import Foundation

// Port of `_tracing.py`: OpenTelemetry tracing of the client's API calls.
//
// An "API call" is one invocation of an SDK method, with every retry and the reading of the stream it
// returns. Each has one `CLIENT` span, the "call span". An "attempt" is one HTTP request within it. The
// SDK emits no span per attempt, and sends the call span's trace context with each unless `propagation` is off.

// Copied from the OpenTelemetry semantic conventions.
let ERROR_TYPE = "error.type"
let HTTP_REQUEST_METHOD = "http.request.method"
let HTTP_REQUEST_RESEND_COUNT = "http.request.resend_count"
let HTTP_RESPONSE_STATUS_CODE = "http.response.status_code"
let HTTP_ROUTE = "http.route"
let SERVER_ADDRESS = "server.address"
let SERVER_PORT = "server.port"
let URL_FULL = "url.full"
let URL_PATH = "url.path"
let URL_QUERY = "url.query"
let URL_SCHEME = "url.scheme"

let CONVERSATION_ID = "gen_ai.conversation.id"
let SESSION_THREAD_ID = "anthropic.session.thread.id"

/// The attribute of the ID of the object that a method creates, and the field of the response that has it
/// (`span_created_id`: a name, or a `(name, field)` pair).
public struct SpanCreatedID: Sendable, Hashable {
    public var attribute: String
    public var field: String
    public init(_ attribute: String, field: String = "id") {
        self.attribute = attribute
        self.field = field
    }
}

/// Reads the attributes that the span of a call starts with from the call's prepared body and headers
/// (a `span_attributes` callable).
public typealias SpanBodyAttributes = @Sendable (_ client: BaseClient, _ body: JSONValue?, _ headers: Headers?) -> SpanAttributes

/// What a stream that the application reads gives the observer of its call span: the parsed events of
/// a `Stream` (Python's `isinstance(result.data, (Stream, AsyncStream))`).
protocol TracedEventStream {}

/// What an API call returns to the application.
enum ApiCallData: @unchecked Sendable {
    case none
    /// The parsed body, the stream, or a value that a middleware short-circuited the call with.
    case value(Any)
    /// A raw response (`withRawResponse` / `withStreamingResponse`), whose body is read when `http` is closed.
    case response(HTTPResponse)

    var isStream: Bool {
        if case .value(let v) = self { return v is TracedEventStream }
        return false
    }
}

/// The result of an API call, as far as the call got (`ApiCallResult`).
struct ApiCallResult: @unchecked Sendable {
    let options: FinalRequestOptions
    /// When the call started. A span cannot report its own start time.
    let startTime: Date
    var response: HTTPResponse? = nil
    var data: ApiCallData = .none
    var error: Error? = nil
    var castTo: Any.Type? = nil
    /// How many times the SDK sent the call's request again, as a retry or a fallback.
    var resendCount: Int = 0

    /// The response of the call's final attempt, which the error of a failed call carries.
    var finalAttempt: HTTPResponse? {
        if response == nil {
            if let e = error as? APIStatusError { return e.response }
            if let e = error as? APIResponseValidationError { return e.response }
        }
        return response
    }
}

/// An API call that has a call span, while the call runs (`ApiCall`).
final class ApiCall: @unchecked Sendable {
    let span: any Span
    let startTime: Date
    /// Whether the call's span may have content, as the client's content mode says.
    let recordsContent: Bool
    /// Whether the call's requests carry the trace context of its span, as the client's `propagation` says.
    let propagation: Bool
    private let lock = NSLock()
    private var _requestsSent = 0

    init(span: any Span, startTime: Date, recordsContent: Bool, propagation: Bool) {
        self.span = span
        self.startTime = startTime
        self.recordsContent = recordsContent
        self.propagation = propagation
    }

    /// How many requests the SDK has sent for the call: the first, and each retry and fallback.
    var requestsSent: Int { lock.withLock { _requestsSent } }

    /// Counts `request`, which the SDK is about to send, and records the URL of the call's first request.
    func sending(_ request: HTTPRequest, options: FinalRequestOptions) {
        let first: Bool = lock.withLock {
            _requestsSent += 1
            return _requestsSent == 1
        }
        guard first else { return }
        setURLAttributes(span, request.url, queryParams: options.spanQueryParams, contentQueryParams: options.spanContentQueryParams,
                         content: recordsContent)
    }

    /// The result of the call, as far as the call has got.
    func result(_ options: FinalRequestOptions, response: HTTPResponse? = nil, data: ApiCallData = .none, error: Error? = nil,
                castTo: Any.Type? = nil) -> ApiCallResult
    {
        ApiCallResult(options: options, startTime: startTime, response: response, data: data, error: error, castTo: castTo,
                      resendCount: max(requestsSent - 1, 0))
    }
}

/// Starts the call span of the API call that the prepared `options` describe (`start_api_call_span`).
///
/// Returns `nil` for a request that no SDK method made, which has no span name, and for a span that neither records
/// nor propagates a trace context. Without `propagation`, a valid span context counts as propagated: an instrumented
/// HTTP client makes its spans children of the call span. Never throws.
func startApiCallSpan(_ tracer: any Tracer, baseURL: URL, client: BaseClient, options: FinalRequestOptions, attributes: SpanAttributes,
                      propagation: Bool) -> (any Span)?
{
    guard let name = options.spanName, !name.isEmpty else { return nil }
    var methodAttributes = options.spanAttributes ?? [:]
    if let body = options.spanBodyAttributes {
        for (k, v) in body(client, options.jsonData, options.headers) { methodAttributes[k] = v }
    }
    var all = serverAttributes(baseURL)
    for (k, v) in requestAttributes(options) { all[k] = v }
    // Before `attributes`, whose conversation ID is the one that the application set.
    for (k, v) in conversationAttributes(methodAttributes) { all[k] = v }
    for (k, v) in attributes { all[k] = v }
    for (k, v) in methodAttributes { all[k] = v }
    let span = tracer.startSpan(name, kind: .client, attributes: all, context: nil, startTime: nil)
    if !span.isRecording && !(propagation ? !traceHeaders(span).isEmpty : span.context.isValid) { return nil }
    return span
}

/// Writes the trace context of `span` into `headers`, in place of any already there.
func injectTraceHeaders(_ span: any Span, _ headers: inout HTTPHeaders) {
    for (key, value) in traceHeaders(span).sorted(by: { $0.key < $1.key }) { headers[key] = value }
}

/// Removes what `injectTraceHeaders` sets, so that no signature covers a value that is replaced later.
func removeTraceHeaders(_ span: any Span, _ headers: inout HTTPHeaders) {
    for key in traceHeaders(span).keys { headers.remove(key) }
}

/// Ends the call span with the call's `result`. A span that already ended is left alone.
func endApiCallSpan(_ span: any Span, _ result: ApiCallResult) {
    guard span.isRecording else { return }
    setResponseStatusCode(span, result)
    setResendCount(span, result)
    if let error = result.error {
        setErrorStatus(span, error)
    } else {
        span.setStatus(.ok)
    }
    span.end()
}

/// Ends the call span when the application has read, closed or dropped the body of `response`
/// (`end_api_call_span_when_body_ends`).
///
/// A body that was read before the call returned ends the span now, unless the call returns a stream, which has yet
/// to give the application the events in that body. `observer` ends the span of a body that has an end event.
/// Without one, a `StreamedBodyObserver` does.
func endApiCallSpanWhenBodyEnds(_ span: any Span, _ response: HTTPResponse, _ result: ApiCallResult, observer: (any StreamObserver)?) {
    guard span.isRecording else { return }
    if response.isClosed && !result.data.isStream {
        endApiCallSpan(span, result)
        return
    }
    setResponseStatusCode(span, result)
    setResendCount(span, result)
    response.setStreamObserver(FirstEnd(observer ?? StreamedBodyObserver(span)))
}

/// How the reading of a body ended. `closed` includes an application that stopped reading, or dropped the body.
public enum StreamEnd: String, Sendable {
    case read, closed, failed
}

/// Learns how the application reads the body of a response (`StreamObserver`). No method throws.
public protocol StreamObserver: AnyObject, Sendable {
    /// Called when a `Stream` starts to parse the body. Never called when the application reads the bytes itself.
    func begin()
    func item(_ item: Any)
    func end(_ how: StreamEnd, error: Error?)
}

/// Ends the call span of a body that has no end event (`StreamedBodyObserver`).
final class StreamedBodyObserver: StreamObserver, @unchecked Sendable {
    private let span: any Span
    private let lock = NSLock()
    private var events = false

    init(_ span: any Span) { self.span = span }

    func begin() { lock.withLock { events = true } }
    func item(_ item: Any) {}

    func end(_ how: StreamEnd, error: Error?) {
        if let error {
            setErrorStatus(span, error)
        } else if how == .read && !lock.withLock({ events }) {
            // Server-sent events without an end event are never read to the end, so only other bodies get `OK`.
            span.setStatus(.ok)
        }
        span.end()
    }
}

/// Forwards every call to `inner` up to and including the first `end`, and drops the rest (`FirstEnd`).
///
/// Reading a body ends more than once: the stream and the body both report it, a body that was read to the end is
/// closed, and a read can end or fail after another task closed the body.
final class FirstEnd: StreamObserver, @unchecked Sendable {
    let inner: any StreamObserver
    private let lock = NSLock()
    private var ended = false

    init(_ inner: any StreamObserver) { self.inner = inner }

    private var isEnded: Bool { lock.withLock { ended } }

    func begin() { if !isEnded { inner.begin() } }
    func item(_ item: Any) { if !isEnded { inner.item(item) } }

    func end(_ how: StreamEnd, error: Error?) {
        let first: Bool = lock.withLock {
            if ended { return false }
            ended = true
            return true
        }
        if first { inner.end(how, error: error) }
    }
}

func setResponseStatusCode(_ span: any Span, _ result: ApiCallResult) {
    if let response = result.finalAttempt { span.setAttribute(HTTP_RESPONSE_STATUS_CODE, .int(response.statusCode)) }
}

func setResendCount(_ span: any Span, _ result: ApiCallResult) {
    if result.resendCount != 0 { span.setAttribute(HTTP_REQUEST_RESEND_COUNT, .int(result.resendCount)) }
}

/// Sets the `url.*` attributes for a request to `url`. Of its query, they have only the `queryParams`
/// (`set_url_attributes`).
///
/// A query that is content, and the full URL that has it, need `content`. One is content when it has one of the
/// `CONTENT_QUERY_PARAMS` or of the `contentQueryParams`, which are content on the request's endpoint only.
func setURLAttributes(_ span: any Span, _ url: URL, queryParams: [String], contentQueryParams: [String], content: Bool) {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let scheme = components.scheme else { return }
    let path = components.percentEncodedPath
    let query = definedQuery(components.percentEncodedQuery ?? "", queryParams)
    span.setAttribute(URL_SCHEME, .string(scheme))
    span.setAttribute(URL_PATH, .string(path))
    if isContentQuery(query, contentQueryParams) && !content { return }
    if !query.isEmpty { span.setAttribute(URL_QUERY, .string(query)) }
    // The authority has the port only when the URL names one that is not the scheme's default.
    var authority = components.percentEncodedHost ?? ""
    if authority.contains(":") && !authority.hasPrefix("[") { authority = "[\(authority)]" }
    if let user = components.percentEncodedUser {
        authority = user + (components.percentEncodedPassword.map { ":\($0)" } ?? "") + "@" + authority
    }
    if let port = components.port, port != defaultPort(scheme) { authority += ":\(port)" }
    let full = "\(scheme)://\(authority)\(path)"
    span.setAttribute(URL_FULL, .string(query.isEmpty ? full : "\(full)?\(query)"))
}

func defaultPort(_ scheme: String) -> Int? {
    switch scheme.lowercased() {
    case "http": return 80
    case "https": return 443
    default: return nil
    }
}

/// The pairs of `query`, as sent, whose parameter is one of `names`, which an endpoint defines (`defined_query`).
///
/// A name is one of them when, percent-decoded, it is in `names` as it is, as `created_at[gte]` is for some
/// endpoints, or when it ends in `[]`, as an array is sent, and the name before that is in `names`.
public func definedQuery(_ query: String, _ names: [String]) -> String {
    let set = Set(names)
    return query.split(separator: "&", omittingEmptySubsequences: false).filter { pair in
        isOneOf(queryParamName(pair), set)
    }.joined(separator: "&")
}

/// The query parameters whose value is content: it filters like a search, or it comes from stored content.
public let CONTENT_QUERY_PARAMS: Set<String> = ["email", "path_prefix", "expected_content_sha256"]

/// Whether `query`, as `definedQuery` gives it, has one of the `CONTENT_QUERY_PARAMS` or of `contentNames`
/// (`is_content_query`). `contentNames` has the parameters that are content on the request's endpoint only.
public func isContentQuery(_ query: String, _ contentNames: [String], contentQueryParams: Set<String> = CONTENT_QUERY_PARAMS) -> Bool {
    let names = contentQueryParams.union(contentNames)
    return query.split(separator: "&", omittingEmptySubsequences: false).contains { isOneOf(queryParamName($0), names) }
}

/// `unquote(pair.partition("=")[0])`.
private func queryParamName(_ pair: Substring) -> String {
    let name = pair.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? ""
    return pythonUnquote(name)
}

private func isOneOf(_ name: String, _ names: Set<String>) -> Bool {
    names.contains(name) || (name.hasSuffix("[]") && names.contains(String(name.dropLast(2))))
}

/// `urllib.parse.unquote`: percent-decodes UTF-8, leaving what does not decode as it is.
func pythonUnquote(_ s: String) -> String {
    guard s.contains("%") else { return s }
    var bytes: [UInt8] = []
    let utf8 = Array(s.utf8)
    var i = 0
    while i < utf8.count {
        if utf8[i] == 0x25, i + 2 < utf8.count, let b = UInt8(String(decoding: utf8[(i + 1)...(i + 2)], as: UTF8.self), radix: 16) {
            bytes.append(b)
            i += 3
        } else {
            bytes.append(utf8[i])
            i += 1
        }
    }
    return String(decoding: bytes, as: UTF8.self)
}

/// Sets the `ERROR` status and `error.type` (`set_error_status`).
///
/// A cancellation is the application stopping the operation, which leaves the status unset.
func setErrorStatus(_ span: any Span, _ error: Error, type: String? = nil) {
    if error is CancellationError { return }
    span.setStatus(.error)
    span.setAttribute(ERROR_TYPE, .string(type ?? errorType(error)))
}

/// The `error.type` of a failed operation: the type of the API's error envelope, or else the status code (`error_type`).
func errorType(_ error: Error) -> String {
    if error is APITimeoutError || error is TransportTimeoutError { return "client_timeout_error" }
    if let e = error as? URLError {
        return e.code == .timedOut ? "client_timeout_error" : "connection_error"
    }
    if error is APIConnectionError { return "connection_error" }
    if let e = error as? APIStatusError {
        if let type = e.type?.rawValue, !type.isEmpty { return type }
        // An `error` event has the status of the response that opened its stream, which is no error.
        if e.statusCode >= 400 { return String(e.statusCode) }
    }
    return "client_error"
}

/// What every request of the call has in common. The call span starts with these, so that a sampler sees them.
func requestAttributes(_ options: FinalRequestOptions) -> SpanAttributes {
    var attributes: SpanAttributes = [HTTP_REQUEST_METHOD: .string(options.method.uppercased())]
    if let route = options.spanRoute { attributes[HTTP_ROUTE] = .string(route) }
    return attributes
}

/// The ID of the Session thread in the call's path as the conversation's ID: a Session thread is a conversation.
func conversationAttributes(_ methodAttributes: SpanAttributes) -> SpanAttributes {
    guard let threadID = methodAttributes[SESSION_THREAD_ID] else { return [:] }
    return [CONVERSATION_ID: threadID]
}

func serverAttributes(_ baseURL: URL) -> SpanAttributes {
    let scheme = baseURL.scheme?.lowercased()
    return [SERVER_ADDRESS: .string(baseURL.host ?? ""), SERVER_PORT: .int(baseURL.port ?? (scheme == "http" ? 80 : 443))]
}

/// The headers that carry `span`'s trace context, from the registered propagator. Empty when it fails. Never throws.
func traceHeaders(_ span: any Span) -> [String: String] {
    var carrier: [String: String] = [:]
    do {
        try OpenTelemetry.propagator.inject(TracingContext.current.with(span: span), into: &carrier)
    } catch {
        return [:]
    }
    return carrier
}

// MARK: - Attributes (`lib/_tracing/_attributes.py`)

/// The attributes to start a span with: `values` without those that are `nil` (`attributes`).
public func tracingAttributes(_ values: [String: AttributeValue?]) -> SpanAttributes {
    var out: SpanAttributes = [:]
    for (k, v) in values { if let v { out[k] = v } }
    return out
}

/// How many items the list `value` has, and `nil` for anything else, such as a list that the request lacks (`count`).
func tracingCount(_ value: JSONValue?) -> Int? { value?.arrayValue?.count }

/// The response headers that a call span records, by attribute (`RESPONSE_HEADER_ATTRIBUTES`).
let RESPONSE_HEADER_ATTRIBUTES: [(String, String)] = [
    ("anthropic.request.id", "request-id"),
    ("anthropic.organization.id", "anthropic-organization-id"),
    ("anthropic.workspace.id", "anthropic-workspace-id"),
]
