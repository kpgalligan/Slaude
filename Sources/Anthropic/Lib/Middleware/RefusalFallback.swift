import Foundation

// Port of `lib/middleware/_fallbacks.py`.

/// Where `BetaRefusalFallbackMiddleware` reports refusals it surfaces rather than retries, and
/// the requests it resends (Python logs these to the `anthropic.lib.middleware` logger).
public struct MiddlewareLogger: Sendable {
    public enum Level: Int, Sendable, Comparable, CustomStringConvertible {
        case debug, info, warning, error

        public static func < (a: Level, b: Level) -> Bool { a.rawValue < b.rawValue }
        public var description: String { ["DEBUG", "INFO", "WARNING", "ERROR"][rawValue] }
    }

    /// The logger name the Python SDK uses.
    public static let name = "anthropic.lib.middleware"

    let handler: @Sendable (Level, String) -> Void

    public init(_ handler: @escaping @Sendable (Level, String) -> Void) { self.handler = handler }

    /// Writes warnings and errors to standard error (the default, like Python's last-resort handler).
    public static let standardError = MiddlewareLogger { level, message in
        if level >= .warning { FileHandle.standardError.write(Data("\(level) \(MiddlewareLogger.name): \(message)\n".utf8)) }
    }

    /// Discards everything.
    public static let none = MiddlewareLogger { _, _ in }

    public func log(_ level: Level, _ message: String) { handler(level, message) }
}

/// Betas sent by default; override with the `betas` option.
public let DEFAULT_FALLBACK_BETAS: [AnthropicBetaParam] = [AnthropicBetaParam(rawValue: "fallback-credit-2026-07-01")]

let messagesPath = "/v1/messages"
let capacityErrorStatuses: Set<Int> = [429, 529]

/// Tracks which fallback a sequence of requests is pinned to (`BetaFallbackState`).
///
/// Create one and run every request that should share the pin inside it — the turns of one
/// conversation, or any wider scope the stickiness should apply to;
/// `BetaRefusalFallbackMiddleware` updates it when a model refuses.
///
/// ```swift
/// let state = BetaFallbackState()
/// let message = try await state.run { try await client.beta.messages.create(...) }
/// ```
public final class BetaFallbackState: @unchecked Sendable {
    private let lock = NSLock()
    private var _index: Int?

    public init() {}

    /// Index into the fallback chain the requests are pinned to. `nil` (or -1) targets the original
    /// request params; the middleware sets it to the index of the fallback that accepted the request.
    public var index: Int? {
        get { lock.withLock { _index } }
        set { lock.withLock { _index = newValue } }
    }

    /// The state the current task runs in (Python's context variable).
    @TaskLocal public static var current: BetaFallbackState?

    /// Runs `body` with this state active (`with state:`). Nesting restores the outer state.
    public func run<T>(_ body: () async throws -> T) async rethrows -> T {
        try await BetaFallbackState.$current.withValue(self) { try await body() }
    }
}

/// Middleware that retries refused beta `/v1/messages` requests down a fallback chain, reproducing
/// the server-side `fallbacks` wire shape client-side (`BetaRefusalFallbackMiddleware`).
///
/// Only `client.beta.messages` requests are handled — refusals minted by the first-party
/// `client.messages` surface carry no `fallback_credit_token`, so those requests pass through.
///
/// Each `fallbacks` entry is a patch against the ORIGINAL request params: a field set to a value
/// overrides it, a field explicitly `null` (`.some(nil)`) unsets it, an absent field keeps the
/// original value; `output_config` patches its subfields the same way one level deep. Hops never
/// compound. A `between_tools` thinking config is sent to a hop as `disabled` unless the entry sets
/// `thinking` itself.
///
/// Non-streaming: when a response comes back with `stop_reason: "refusal"`, the request is retried
/// with each entry applied — passing along the refusal's `fallback_credit_token` (object form,
/// `mode: "best_effort"`) — until a model accepts or the chain is exhausted. A `fallback` seam
/// block per model boundary is prepended to the served message's content.
///
/// Streaming: when the stream ends in a refusal, a request is issued to the fallback model carrying
/// the refusal's credit token, plus the refused model's partial output as a trailing assistant
/// prefill when the refusal grants one (`fallback_has_prefill_claim`). The fallback's events are
/// spliced onto the still-open stream, so the client sees one continuous message in the server-side
/// `fallbacks` wire shape: a `fallback` content block at each model boundary, monotonic block
/// indices, and per-hop `usage.iterations` on the final `message_delta`. A refusal before any
/// output streamed retries even without a credit token.
///
/// A fallback whose appended prefill the server rejects (HTTP 400) is retried once without it; a
/// fallback whose request fails outright is skipped and its token carries to the next entry. When
/// every remaining entry fails over HTTP, the suppressed refusal is replayed with
/// `recommended_model` stamped from the final failure. A `speed: "fast"` request that falls back to
/// an entry with no `speed` and is rejected there with a 429 or 529 is retried once without `speed`.
///
/// To keep later requests on the model that accepted, run them inside a shared `BetaFallbackState`.
/// `fallback` seam blocks replayed in the request history are stripped from the outgoing request
/// (an assistant turn left empty by the strip is dropped whole).
public final class BetaRefusalFallbackMiddleware: Middleware, @unchecked Sendable {
    let fallbacks: [[String: JSONValue]]
    let betas: [String]
    let logger: MiddlewareLogger
    private let lock = NSLock()
    private var warnedMissingState = false

    /// - Parameters:
    ///   - fallbacks: The fallback chain, tried in order. An empty chain disables the middleware.
    ///   - betas: Betas added to the `anthropic-beta` header of every `/v1/messages` request this
    ///     middleware handles. Defaults to `fallback-credit-2026-07-01`; pass `[]` to send none.
    ///   - logger: Receives the warnings and errors Python logs to `anthropic.lib.middleware`.
    public init(_ fallbacks: [BetaFallbackParam], betas: [AnthropicBetaParam]? = nil, logger: MiddlewareLogger = .standardError) {
        self.fallbacks = fallbacks.map { entry in
            (try? JSONValue.from(entry))?.objectValue ?? ["model": .string(entry.model.rawValue)]
        }
        self.betas = (betas ?? DEFAULT_FALLBACK_BETAS).map(\.rawValue)
        self.logger = logger
    }

    public func handle(_ request: APIRequest, next: @escaping CallNext) async throws -> RawAPIResponse {
        guard var body = try applicableBody(request) else { return try await next(request) }

        let state = BetaFallbackState.current
        let startIndex = try self.startIndex(state)
        let pin = makePin(state)

        // Send the configured betas on this and every hop request derived from it, and tag them
        // with the middleware's helper telemetry.
        let request = withMiddlewareHeaders(request)

        // The seam blocks this middleware splices into streams are client-side markers — the
        // server rejects them — so a history that replays them is rewritten without them.
        body = stripSeamBlocks(body)
        let initialBody = startIndex == -1 ? body : applyHop(body, fallbacks[startIndex])
        let initialRequest = request.copy(body: initialBody)

        let response: RawAPIResponse
        if startIndex == -1 {
            response = try await next(initialRequest)
        } else {
            response = try await sendHop(initialRequest, fallbacks[startIndex], next).0
        }
        if !response.http.isSuccess { return response }

        let initialModel = initialBody["model"]?.stringValue ?? ""
        if request.stream {
            let firstHop = startIndex + 1
            // Splicing needs at least one entry left to hop to; otherwise the stream passes through.
            if firstHop >= fallbacks.count { return response }
            return spliceFallbackStream(request: initialRequest, body: body, initialModel: initialModel, response: response,
                                        next: next, firstHop: firstHop, pin: pin)
        }

        var index = startIndex
        var res = response
        var fromModel = initialModel
        var seams: [JSONValue] = []
        while index < fallbacks.count - 1 && res.http.isSuccess {
            guard let message = try? await res.parse(as: BetaMessage.self), message.stopReason?.rawValue == "refusal" else { break }
            index += 1
            pin(index)
            let token = message.stopDetails?.fallbackCreditToken
            let category: JSONValue = message.stopDetails?.category.map { .string($0.rawValue) } ?? .null
            let entry = fallbacks[index]
            res = try await sendHop(request.copy(body: mergedBody(body, entry, token)), entry, next).0
            if res.http.isSuccess {
                let toModel = entry["model"]?.stringValue ?? ""
                seams.append(seamBlock(fromModel, toModel, category))
                fromModel = toModel
            }
        }

        if !seams.isEmpty && res.http.isSuccess {
            if let served = try? await res.parse(as: BetaMessage.self), served.stopReason?.rawValue != "refusal" {
                // Prepend one `fallback` seam block per model boundary to the serving hop's content.
                return try await prependSeamBlocks(res, seams)
            }
        }
        return res
    }

    /// The request's JSON body when this middleware applies to it, `nil` otherwise.
    func applicableBody(_ request: APIRequest) throws -> [String: JSONValue]? {
        let options = request.options
        let path = URLComponents(string: options.url)?.path ?? options.url
        guard !fallbacks.isEmpty, options.method.lowercased() == "post", path == messagesPath,
              options.qualifiers?["beta"] == "true", var body = options.jsonData?.objectValue
        else { return nil }
        for (k, v) in options.extraJSON ?? [:] { body[k] = v }
        if let f = body["fallbacks"], !f.isNull {
            throw AnthropicError(
                "Sending the `fallbacks:` request param is not supported when using the `BetaRefusalFallbackMiddleware`. You should either remove the middleware and send `fallbacks:` with the `server-side-fallback-2026-07-01` beta header to let the API handle refusal fallbacks, or omit the `fallbacks:` param if you'd like `BetaRefusalFallbackMiddleware` to handle fallbacks on the client side.")
        }
        return body
    }

    /// The chain entry this request starts at (-1 = the original params).
    func startIndex(_ state: BetaFallbackState?) throws -> Int {
        guard let state, let index = state.index else { return -1 }
        guard index >= -1 && index < fallbacks.count else {
            throw AnthropicError(
                "BetaFallbackState.index \(index) is out of bounds for a chain of \(fallbacks.count) fallback(s); was the state shared with a different middleware?")
        }
        return index
    }

    /// Pins requests sharing the state to the entry being tried (or warns that there is none).
    func makePin(_ state: BetaFallbackState?) -> @Sendable (Int) -> Void {
        { [self] index in
            if let state {
                state.index = index
                return
            }
            let shouldWarn: Bool = lock.withLock {
                if warnedMissingState { return false }
                warnedMissingState = true
                return true
            }
            if shouldWarn {
                logger.log(.warning,
                           "anthropic-sdk: BetaRefusalFallbackMiddleware fell back without an active BetaFallbackState; follow-up requests will retry models that already refused. Run them inside a shared `BetaFallbackState().run { ... }` block to pin them to the accepted model.")
            }
        }
    }

    /// A copy of `request` with the betas appended to its `anthropic-beta` header (skipping values
    /// already present) and the middleware's helper-telemetry tag appended to `x-stainless-helper`.
    func withMiddlewareHeaders(_ request: APIRequest) -> APIRequest {
        let layer = request.options.headers ?? [:]
        let current = layer.first(where: { $0.key.lowercased() == "anthropic-beta" })?.value.stringValue ?? ""
        let existing = Set(current.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) })
        var additions: [String] = []
        for beta in betas where !existing.contains(beta) && !additions.contains(beta) { additions.append(beta) }
        var betaHeader: Headers = [:]
        if !current.isEmpty || !additions.isEmpty {
            betaHeader["anthropic-beta"] = .value(([current] + additions).filter { !$0.isEmpty }.joined(separator: ","))
        }
        var r = request
        r.options.headers = mergeHeaders(layer, betaHeader, [stainlessHelperHeader: "fallback-refusal-middleware"])
        return r
    }

    /// Sends a request built from `entry`, resending it once without `speed` when it inherited
    /// `fast` and was rejected with a capacity error. Also returns the entry to build any later
    /// resend of the same hop from.
    func sendHop(_ request: APIRequest, _ entry: [String: JSONValue], _ next: @escaping CallNext) async throws -> (RawAPIResponse, [String: JSONValue]) {
        let response = try await next(request)
        guard let resend = withoutRejectedFastSpeed(request, entry, response.statusCode) else { return (response, entry) }
        response.http.close()
        var e = entry
        e["speed"] = .null
        return (try await next(resend), e)
    }

    /// The hop's request to resend, or `nil` when its result stands. `speed` is dropped, not set to
    /// `standard`: a model without fast mode rejects the parameter.
    func withoutRejectedFastSpeed(_ request: APIRequest, _ entry: [String: JSONValue], _ status: Int) -> APIRequest? {
        guard capacityErrorStatuses.contains(status), entry["speed"] == nil, let body = request.options.jsonData?.objectValue,
              body["speed"] == .string("fast")
        else { return nil }
        logger.log(.warning,
                   "anthropic-sdk: BetaRefusalFallbackMiddleware: fast fallback request to \(entry["model"]?.stringValue ?? "") was rejected (HTTP \(status)); retrying without `speed`")
        return request.copy(body: patch(body, ["speed": .null]))
    }

    func prependSeamBlocks(_ response: RawAPIResponse, _ seams: [JSONValue]) async throws -> RawAPIResponse {
        let data = try await response.http.read()
        // The Message as received, so that its keys keep their order and its numbers their text.
        guard case .object(var message)? = try? RawJSON.parse(data), let content = message["content"]?.arrayValue else { return response }
        message["content"] = .array(seams.map(RawJSON.init) + content)
        let original = response.http
        return RawAPIResponse(
            http: HTTPResponse(statusCode: original.statusCode, headers: withoutEncodingHeaders(original.headers),
                               body: RawJSON.object(message).serialized(), request: original.request, elapsed: original.elapsed),
            options: response.options, retriesTaken: response.retriesTaken, client: response.client)
    }

    /// Wraps the refusable stream in a response whose body passes events through until a retryable
    /// refusal, then splices the fallback chain's events on. Closing the returned response tears
    /// down whichever stream is being read and abandons any in-flight fallback request.
    func spliceFallbackStream(request: APIRequest, body: [String: JSONValue], initialModel: String, response: RawAPIResponse,
                              next: @escaping CallNext, firstHop: Int, pin: @escaping @Sendable (Int) -> Void) -> RawAPIResponse
    {
        let driver = SpliceDriver(middleware: self, request: request, body: body, initialModel: initialModel, response: response.http,
                                  next: next, firstHop: firstHop, pin: pin)
        let original = response.http
        let spliced = HTTPResponse(statusCode: original.statusCode, headers: withoutEncodingHeaders(original.headers),
                                   stream: ByteStream(unfolding: { try await driver.next() }), request: original.request,
                                   elapsed: original.elapsed, onClose: { driver.close() })
        return RawAPIResponse(http: spliced, options: response.options, retriesTaken: response.retriesTaken, client: response.client)
    }
}

extension APIRequest {
    /// A copy with `body` as its JSON body (`APIRequest.copy(body=...)`).
    func copy(body: [String: JSONValue]) -> APIRequest {
        var r = self
        r.options.jsonData = .object(body)
        r.options.extraJSON = nil
        return r
    }
}

func withoutEncodingHeaders(_ headers: HTTPHeaders) -> HTTPHeaders {
    var h = headers
    h.remove("content-encoding")
    h.remove("content-length")
    return h
}

// MARK: - Body patching

/// `overrides` applied flat against `base`: a key set to a value overrides it, a key explicitly
/// `null` unsets it, an absent key keeps the base value.
func patch(_ base: [String: JSONValue], _ overrides: [String: JSONValue]) -> [String: JSONValue] {
    var patched = base
    for (k, v) in overrides {
        if v.isNull { patched.removeValue(forKey: k) } else { patched[k] = v }
    }
    return patched
}

/// `entry` applied as a patch against `body` (`_apply_hop`).
func applyHop(_ body: [String: JSONValue], _ entry: [String: JSONValue]) -> [String: JSONValue] {
    var patched = patch(body, entry)
    if entry["thinking"] == nil, body["thinking"]?["type"] == .string("between_tools") {
        patched["thinking"] = ["type": "disabled"]
    }
    if let outputConfig = entry["output_config"]?.objectValue {
        let merged = patch(body["output_config"]?.objectValue ?? [:], outputConfig)
        if merged.isEmpty { patched.removeValue(forKey: "output_config") } else { patched["output_config"] = .object(merged) }
    }
    return patched
}

func creditTokenParam(_ token: String) -> JSONValue { ["token": .string(token), "mode": "best_effort"] }

/// The non-streaming retry body (`_merged_body`).
func mergedBody(_ body: [String: JSONValue], _ entry: [String: JSONValue], _ token: String?) -> [String: JSONValue] {
    var merged = applyHop(body, entry)
    if let token, !token.isEmpty { merged["fallback_credit_token"] = creditTokenParam(token) }
    return merged
}

/// A copy of `body` with `fallback` seam blocks filtered out of the replayed message history; an
/// assistant turn left empty is dropped whole.
func stripSeamBlocks(_ body: [String: JSONValue]) -> [String: JSONValue] {
    guard let messages = body["messages"]?.arrayValue else { return body }
    var stripped = false
    var out: [JSONValue] = []
    for message in messages {
        guard var dict = message.objectValue, let content = dict["content"]?.arrayValue else {
            out.append(message)
            continue
        }
        let kept = content.filter { $0["type"] != .string("fallback") }
        if kept.count == content.count {
            out.append(message)
            continue
        }
        stripped = true
        if kept.isEmpty && dict["role"] == .string("assistant") { continue }
        dict["content"] = .array(kept)
        out.append(.object(dict))
    }
    if !stripped { return body }
    var b = body
    b["messages"] = .array(out)
    return b
}

/// The synthetic `fallback` content block marking one model boundary.
func seamBlock(_ from: String, _ to: String, _ category: JSONValue) -> JSONValue {
    ["type": "fallback", "from": ["model": .string(from)], "to": ["model": .string(to)], "trigger": ["type": "refusal", "category": category]]
}

// MARK: - SSE helpers

/// `value` as compact JSON, each object's keys sorted, so that the same value is the same text in every process.
func jsonDumps(_ value: JSONValue) -> String {
    RawJSON(value).serializedString
}

/// Serializes an event back to its SSE wire form.
func serializeSSE(event: String?, data: String) -> String {
    var out = ""
    if let event { out += "event: \(event)\n" }
    for line in data.split(separator: "\n", omittingEmptySubsequences: false) { out += "data: \(line)\n" }
    return out + "\n"
}

/// An event's SSE frame. `original` is the event as received, when `payload` is its view with some fields changed (a
/// shifted `index`): the frame keeps its key order and number text, with the changes folded in
/// (`RawJSON.reconciled(with:)`), so that a consumer reading the JSON as it came (`stream(body:)`) gets the hop's
/// events as the server sent them. A synthesized event has its keys sorted.
func emitFrame(_ event: String, _ payload: [String: JSONValue], original: RawJSON? = nil) -> Data {
    let data = original.map { $0.reconciled(with: .object(payload)).serializedString } ?? jsonDumps(.object(payload))
    return Data(serializeSSE(event: event, data: data).utf8)
}

/// An event's `data` as JSON: as received (`raw`), and its view for the splice to read and change (`view`).
func parseEventData(_ data: String) -> (raw: RawJSON, view: [String: JSONValue])? {
    guard let raw = try? RawJSON.parse(data), let view = raw.jsonValue.objectValue else { return nil }
    return (raw, view)
}

/// Forwards a decoded event in its original wire bytes, preserving SSE fields beyond `event:`/`data:`.
func passthroughFrame(_ sse: ServerSentEvent) -> Data {
    if !sse.raw.isEmpty { return Data((sse.raw.joined(separator: "\n") + "\n\n").utf8) }
    return Data(serializeSSE(event: sse.event, data: sse.data).utf8)
}

func toIterationUsage(_ type: String, _ model: String, _ usage: [String: JSONValue]?) -> [String: JSONValue] {
    let u = usage ?? [:]
    func count(_ k: String) -> JSONValue {
        guard let v = u[k], !v.isNull, v != .int(0), v != .double(0) else { return 0 }
        return v
    }
    return [
        "type": .string(type), "model": .string(model), "input_tokens": count("input_tokens"), "output_tokens": count("output_tokens"),
        "cache_read_input_tokens": count("cache_read_input_tokens"), "cache_creation_input_tokens": count("cache_creation_input_tokens"),
        "cache_creation": u["cache_creation"] ?? .null,
    ]
}

/// Fills `null` fields on `primary` from `fallback`.
func backfill(_ primary: [String: JSONValue]?, _ fallback: [String: JSONValue]?) -> [String: JSONValue] {
    let fb = fallback ?? [:]
    var out = fb
    for (k, v) in primary ?? [:] { out[k] = v }
    for (k, v) in out where v.isNull {
        if let f = fb[k], !f.isNull { out[k] = f }
    }
    return out
}

// MARK: - Streaming splice

struct Refusal {
    var token: String?
    var category: JSONValue
    var hasPrefillClaim: Bool
    var usage: [String: JSONValue]
    /// The suppressed refusal `message_delta` event, verbatim.
    var event: [String: JSONValue]
    var suppressedStartMessage: [String: JSONValue]?
}

struct HopOutcome {
    var refused: Refusal?
    var model: String?
    var startEvent: [String: JSONValue]?
    var blocks: [[String: JSONValue]]
    var nextIndex: Int
    var opened: Bool
    var lastFallbackTo: String?
}

struct HopFailure {
    var model: String
    var status: Int?
}

struct SpliceInfo {
    var iterations: [JSONValue]
    var model: String
}

/// Block bookkeeping for one stream of the splice (`_BlockTracker`).
struct BlockTracker {
    let indexBase: Int
    var nextIndex: Int
    private var blocks: [(Int, [String: JSONValue])] = []
    private var open: [Int] = []

    init(indexBase: Int) {
        self.indexBase = indexBase
        self.nextIndex = indexBase
    }

    var contentBlocks: [[String: JSONValue]] { blocks.map(\.1) }

    mutating func start(_ event: inout [String: JSONValue]) {
        guard case .int(let index)? = event["index"] else { return }
        blocks.append((index, event["content_block"]?.objectValue ?? [:]))
        let shifted = index + indexBase
        event["index"] = .int(shifted)
        open.append(shifted)
        nextIndex = max(nextIndex, shifted + 1)
    }

    mutating func delta(_ event: inout [String: JSONValue]) {
        guard case .int(let index)? = event["index"] else { return }
        if let delta = event["delta"]?.objectValue, let i = blocks.firstIndex(where: { $0.0 == index }) {
            var block = blocks[i].1
            func str(_ v: JSONValue?) -> String { v?.stringValue ?? "" }
            switch delta["type"]?.stringValue {
            case "text_delta": block["text"] = .string(str(block["text"]) + str(delta["text"]))
            case "input_json_delta": block["_partial_json"] = .string(str(block["_partial_json"]) + str(delta["partial_json"]))
            case "citations_delta":
                var citations = block["citations"]?.arrayValue ?? []
                citations.append(delta["citation"] ?? .null)
                block["citations"] = .array(citations)
            case "thinking_delta": block["thinking"] = .string(str(block["thinking"]) + str(delta["thinking"]))
            case "signature_delta": block["signature"] = delta["signature"] ?? .null
            default: break
            }
            blocks[i].1 = block
        }
        event["index"] = .int(index + indexBase)
    }

    mutating func stop(_ event: inout [String: JSONValue]) {
        guard case .int(let index)? = event["index"] else { return }
        let shifted = index + indexBase
        event["index"] = .int(shifted)
        open.removeAll(where: { $0 == shifted })
        nextIndex = max(nextIndex, shifted + 1)
    }

    mutating func closeOpenBlocks() -> [Data] {
        let frames = open.map { emitFrame("content_block_stop", ["type": "content_block_stop", "index": .int($0)]) }
        open.removeAll()
        return frames
    }
}

/// Converts a hop's accumulated blocks to the appended assistant turn (`_to_prefill_blocks`).
func toPrefillBlocks(_ blocks: [[String: JSONValue]]) -> [JSONValue] {
    var out: [[String: JSONValue]] = []
    for var block in blocks {
        if block["type"] == .string("fallback") { continue }
        guard case .string(let partial)? = block["_partial_json"] else {
            out.append(block)
            continue
        }
        block.removeValue(forKey: "_partial_json")
        if let parsed = try? JSONValue.parse(partial) { block["input"] = parsed }
        out.append(block)
    }
    while let last = out.last, last["type"] == .string("thinking") || last["type"] == .string("redacted_thinking") { out.removeLast() }
    return out.map { .object($0) }
}

func declinedIterationEntries(_ refusal: Refusal, _ modelLabel: String) -> [JSONValue] {
    if let reported = refusal.usage["iterations"]?.arrayValue, !reported.isEmpty {
        var entries: [[String: JSONValue]] = reported.compactMap { $0.objectValue }.map { var e = $0; e["type"] = "message"; return e }
        if !entries.isEmpty {
            if entries.count == 1, entries[0]["model"]?.stringValue == nil { entries[0]["model"] = .string(modelLabel) }
            return entries.map { .object($0) }
        }
    }
    return [.object(toIterationUsage("message", modelLabel, refusal.usage))]
}

func servingIterationEntry(_ deltaUsage: [String: JSONValue], _ model: String) -> JSONValue {
    if let reported = deltaUsage["iterations"]?.arrayValue, let last = reported.last?.objectValue {
        var e = last
        e["type"] = "fallback_message"
        let m = last["model"]
        e["model"] = (m == nil || m!.isNull || m == .string("") || m == .bool(false)) ? .string(model) : m!
        return .object(e)
    }
    return .object(toIterationUsage("fallback_message", model, deltaUsage))
}

func forwardInputTransformations(_ event: inout [String: JSONValue], _ suppressedStartMessage: [String: JSONValue]?) {
    guard let start = suppressedStartMessage, event["input_transformations"] == nil else { return }
    if let it = start["input_transformations"] { event["input_transformations"] = it }
}

/// Consumes one hop's SSE events, producing the frames to forward while accumulating its blocks
/// (`_HopReader`).
struct HopReader {
    private var tracker: BlockTracker
    let hasNext: Bool
    let splice: SpliceInfo?
    let wireOpen: Bool
    let primaryID: String?
    let seamFrames: [Data]
    let logger: MiddlewareLogger
    private var model: String?
    private var startUsage: [String: JSONValue]?
    private var startEvent: [String: JSONValue]?
    /// `startEvent` as received.
    private var startRaw: RawJSON?
    private var heldStart: ServerSentEvent?
    private var held: [ServerSentEvent] = []
    private(set) var opened = false
    private var lastFallbackTo: String?
    /// Set when a chainable refusal ended the hop early.
    private(set) var outcome: HopOutcome?

    init(indexBase: Int, hasNext: Bool, splice: SpliceInfo?, wireOpen: Bool, primaryID: String?, seamFrames: [Data], logger: MiddlewareLogger) {
        self.tracker = BlockTracker(indexBase: indexBase)
        self.hasNext = hasNext
        self.splice = splice
        self.wireOpen = wireOpen
        self.primaryID = primaryID
        self.seamFrames = seamFrames
        self.logger = logger
    }

    mutating func feed(_ sse: ServerSentEvent) -> [Data] {
        let parsed = parseEventData(sse.data)
        let raw = parsed?.raw
        let eventType = parsed?.view["type"]?.stringValue

        if var event = parsed?.view {
            switch eventType {
            case "message_start":
                if let message = event["message"]?.objectValue {
                    model = message["model"]?.stringValue
                    startUsage = message["usage"]?.objectValue
                }
                startEvent = event
                startRaw = raw
                heldStart = sse
                return []
            case "content_block_start":
                var frames = open()
                if let block = event["content_block"]?.objectValue, block["type"] == .string("fallback"),
                   let to = block["to"]?["model"]?.stringValue
                {
                    lastFallbackTo = to
                }
                tracker.start(&event)
                frames.append(splice != nil ? emitFrame("content_block_start", event, original: raw) : passthroughFrame(sse))
                return frames
            case "content_block_delta":
                var frames = open()
                tracker.delta(&event)
                frames.append(splice != nil ? emitFrame("content_block_delta", event, original: raw) : passthroughFrame(sse))
                return frames
            case "content_block_stop":
                var frames = open()
                tracker.stop(&event)
                frames.append(splice != nil ? emitFrame("content_block_stop", event, original: raw) : passthroughFrame(sse))
                return frames
            case "message_delta":
                let delta = event["delta"]?.objectValue ?? [:]
                let isRefusal = delta["stop_reason"] == .string("refusal")
                if isRefusal {
                    let stopDetails = delta["stop_details"]?.objectValue
                    let details = stopDetails?["type"] == .string("refusal") ? stopDetails : nil
                    var token = details?["fallback_credit_token"]?.stringValue
                    if token?.isEmpty ?? false { token = nil }
                    let preStream = !opened && tracker.contentBlocks.isEmpty
                    // A mid-stream refusal chains only when it minted a credit token; a pre-stream
                    // refusal chains even without one — nothing has streamed, so the retry is invisible.
                    if hasNext && (token != nil || preStream) {
                        let usage = backfill(event["usage"]?.objectValue, startUsage)
                        let frames = tracker.closeOpenBlocks()
                        heldStart = nil
                        held.removeAll()
                        outcome = HopOutcome(
                            refused: Refusal(token: token, category: details?["category"] ?? .null,
                                             hasPrefillClaim: details?["fallback_has_prefill_claim"] == .bool(true), usage: usage, event: event,
                                             suppressedStartMessage: suppressedStartMessage()),
                            model: model, startEvent: startEvent, blocks: tracker.contentBlocks, nextIndex: tracker.nextIndex, opened: opened,
                            lastFallbackTo: lastFallbackTo)
                        return frames
                    }
                    if token == nil {
                        logger.log(.error,
                                   "anthropic-sdk: BetaRefusalFallbackMiddleware: refusal stop_details has no fallback_credit_token; surfacing the refusal")
                    } else {
                        logger.log(.error, "anthropic-sdk: BetaRefusalFallbackMiddleware: refusal but no fallback entries remain; surfacing the refusal")
                    }
                }
                var frames = open()
                if let splice {
                    if isRefusal, var details = delta["stop_details"]?.objectValue {
                        // the terminal refusal's stop_details always carries a recommendation slot
                        if details["recommended_model"] == nil { details["recommended_model"] = .null }
                        var d = delta
                        d["stop_details"] = .object(details)
                        event["delta"] = .object(d)
                    }
                    // Terminal hop: the recorded chain replaces the hop's own iterations self-report.
                    var usage = event["usage"]?.objectValue ?? [:]
                    usage["iterations"] = .array(splice.iterations + [servingIterationEntry(usage, splice.model)])
                    event["usage"] = .object(usage)
                    forwardInputTransformations(&event, suppressedStartMessage())
                    frames.append(emitFrame("message_delta", event, original: raw))
                    return frames
                }
                frames.append(passthroughFrame(sse))
                return frames
            default:
                break
            }
        }

        if !opened {
            // ping, error, unrecognised — held until the wire-open decision
            held.append(sse)
            return []
        }
        return [passthroughFrame(sse)]
    }

    /// `message` from this fallback's `message_start` when it was not re-emitted.
    func suppressedStartMessage() -> [String: JSONValue]? {
        guard splice != nil, wireOpen, let startEvent else { return nil }
        return startEvent["message"]?.objectValue
    }

    /// Opens the wire for this hop: its message_start, the queued seam frames, then anything held.
    mutating func open() -> [Data] {
        if opened { return [] }
        opened = true
        var frames: [Data] = []
        if splice == nil {
            if let heldStart { frames.append(passthroughFrame(heldStart)) }
        } else if !wireOpen, var start = startEvent {
            if var message = start["message"]?.objectValue, let primaryID {
                message["id"] = .string(primaryID)
                start["message"] = .object(message)
            }
            frames.append(emitFrame("message_start", start, original: startRaw))
        }
        frames.append(contentsOf: seamFrames)
        frames.append(contentsOf: held.map(passthroughFrame))
        heldStart = nil
        held.removeAll()
        return frames
    }

    /// Frames still owed when the stream ends without a chainable refusal.
    mutating func finishFrames() -> [Data] {
        if outcome != nil || opened { return [] }
        return open()
    }

    func finish() -> HopOutcome {
        if let outcome { return outcome }
        return HopOutcome(refused: nil, model: model, startEvent: startEvent, blocks: tracker.contentBlocks, nextIndex: tracker.nextIndex,
                          opened: opened, lastFallbackTo: lastFallbackTo)
    }
}

/// Bookkeeping shared across the hops of one spliced stream (`_ChainState`).
struct ChainState {
    let body: [String: JSONValue]
    var nextIndex: Int
    var wireOpen: Bool
    var primaryID: String?
    var primaryModel: String
    var token: String?
    var base: [JSONValue]
    var partial: [JSONValue]
    var fromModel: String
    var lastRefusal: Refusal
    var lastStartEvent: [String: JSONValue]?
    var iterations: [JSONValue]
    private var pendingSeams: [Data] = []

    init(body: [String: JSONValue], initialModel: String, outcome: HopOutcome) {
        let refused = outcome.refused!
        self.body = body
        self.primaryModel = initialModel
        self.nextIndex = outcome.nextIndex
        self.wireOpen = outcome.opened
        self.primaryID = outcome.startEvent?["message"]?["id"]?.stringValue
        self.token = refused.token
        self.base = []
        self.partial = refused.hasPrefillClaim ? toPrefillBlocks(outcome.blocks) : []
        // A server-stitched envelope's last decliner is the model the first client-side seam hands
        // off from; a plain stream hands off from the caller-spelled primary.
        self.fromModel = outcome.lastFallbackTo ?? initialModel
        self.lastRefusal = refused
        self.lastStartEvent = outcome.startEvent
        self.iterations = declinedIterationEntries(refused, initialModel)
    }

    /// Queues the reached hop's `fallback` seam block at the next monotonic index.
    mutating func queueSeam(_ toModel: String) {
        let seamIndex = nextIndex
        nextIndex += 1
        pendingSeams.append(emitFrame("content_block_start", [
            "type": "content_block_start", "index": .int(seamIndex),
            "content_block": seamBlock(fromModel, toModel, lastRefusal.category),
        ]))
        pendingSeams.append(emitFrame("content_block_stop", ["type": "content_block_stop", "index": .int(seamIndex)]))
        fromModel = toModel
    }

    var pendingSeamFrames: [Data] { pendingSeams }

    mutating func markOpened() {
        wireOpen = true
        pendingSeams.removeAll()
    }

    var continuation: [JSONValue] { base + partial }

    /// The hop's request body: the entry applied against the ORIGINAL params, extended by the continuation.
    func hopBody(_ entry: [String: JSONValue], _ continuation: [JSONValue]) -> [String: JSONValue] {
        var b = applyHop(body, entry)
        b.removeValue(forKey: "fallbacks")
        if let token { b["fallback_credit_token"] = creditTokenParam(token) }
        if !continuation.isEmpty {
            let messages = b["messages"]?.arrayValue ?? []
            b["messages"] = .array(messages + [["role": "assistant", "content": .array(continuation)]])
        }
        return b
    }

    /// Folds a refused hop's outcome in, readying the next hop.
    mutating func absorbRefusal(_ outcome: HopOutcome, _ model: String, _ continuation: [JSONValue]) {
        let refused = outcome.refused!
        token = refused.token
        base = continuation
        partial = refused.hasPrefillClaim ? toPrefillBlocks(outcome.blocks) : []
        iterations.append(contentsOf: declinedIterationEntries(refused, model))
        lastRefusal = refused
        if let s = outcome.startEvent { lastStartEvent = s }
        nextIndex = outcome.nextIndex
    }

    /// Degrades to the suppressed refusal when every remaining entry failed over HTTP.
    func terminalFailureFrames(_ failure: HopFailure) -> [Data] {
        var frames: [Data] = []
        if !wireOpen, var start = lastStartEvent {
            if var message = start["message"]?.objectValue, let primaryID {
                message["id"] = .string(primaryID)
                start["message"] = .object(message)
            }
            frames.append(emitFrame("message_start", start))
        }
        frames.append(contentsOf: pendingSeams)
        var event = lastRefusal.event
        if var delta = event["delta"]?.objectValue {
            if var details = delta["stop_details"]?.objectValue {
                details["recommended_model"] = failure.status.map { capacityErrorStatuses.contains($0) } == true ? .string(failure.model) : .null
                delta["stop_details"] = .object(details)
            }
            event["delta"] = .object(delta)
        }
        var usage = event["usage"]?.objectValue ?? [:]
        usage["iterations"] = .array(iterations)
        event["usage"] = .object(usage)
        forwardInputTransformations(&event, lastRefusal.suppressedStartMessage)
        frames.append(emitFrame("message_delta", event))
        frames.append(emitFrame("message_stop", ["type": "message_stop"]))
        return frames
    }
}

/// Produces the spliced stream's frames on demand (the Python generator `_spliced_frames_async`,
/// as a state machine): passes stream A through until a chainable refusal, then requests and
/// splices each fallback hop in turn.
final class SpliceDriver: @unchecked Sendable {
    private enum Phase {
        case passthrough(reader: HopReader)
        case startHop(hop: Int)
        case driveHop(hop: Int, reader: HopReader, model: String, continuation: [JSONValue])
        case done
    }

    let middleware: BetaRefusalFallbackMiddleware
    let request: APIRequest
    let body: [String: JSONValue]
    let initialModel: String
    let next: CallNext
    let firstHop: Int
    let pin: @Sendable (Int) -> Void

    private let lock = NSLock()
    private var current: HTTPResponse?
    private var closed = false
    private var events: AsyncThrowingStream<ServerSentEvent, Error>.AsyncIterator?
    private var phase: Phase
    private var queue: [Data] = []
    private var chain: ChainState?

    init(middleware: BetaRefusalFallbackMiddleware, request: APIRequest, body: [String: JSONValue], initialModel: String, response: HTTPResponse,
         next: @escaping CallNext, firstHop: Int, pin: @escaping @Sendable (Int) -> Void)
    {
        self.middleware = middleware
        self.request = request
        self.body = body
        self.initialModel = initialModel
        self.next = next
        self.firstHop = firstHop
        self.pin = pin
        self.current = response
        self.events = SSEDecoder.events(from: response.bytes()).makeAsyncIterator()
        // the caller guarantees firstHop < fallbacks.count
        self.phase = .passthrough(reader: HopReader(indexBase: 0, hasNext: true, splice: nil, wireOpen: false, primaryID: nil, seamFrames: [],
                                                    logger: middleware.logger))
    }

    var logger: MiddlewareLogger { middleware.logger }

    /// Tears down whichever response is being read.
    func close() {
        let response: HTTPResponse? = lock.withLock {
            closed = true
            let r = current
            current = nil
            return r
        }
        response?.close()
    }

    private var isClosed: Bool { lock.withLock { closed } }

    private func setCurrent(_ response: HTTPResponse?) {
        let previous: HTTPResponse? = lock.withLock {
            let p = current
            current = response
            return p
        }
        if let previous, previous !== response { previous.close() }
        if response != nil && isClosed { response?.close() }
    }

    func next() async throws -> Data? {
        while queue.isEmpty {
            if isClosed { phase = .done }
            if case .done = phase {
                setCurrent(nil)
                return nil
            }
            do {
                try await step()
            } catch {
                phase = .done
                setCurrent(nil)
                throw error
            }
        }
        return queue.removeFirst()
    }

    private func readEvent() async throws -> ServerSentEvent? {
        guard events != nil else { return nil }
        return try await events!.next()
    }

    private func step() async throws {
        switch phase {
        case .done:
            return
        case .passthrough(var reader):
            if let sse = try await readEvent() {
                queue.append(contentsOf: reader.feed(sse))
                if reader.outcome == nil {
                    phase = .passthrough(reader: reader)
                    return
                }
            }
            queue.append(contentsOf: reader.finishFrames())
            let outcome = reader.finish()
            guard outcome.refused != nil else {
                // non-refusal or not retryable: pure pass-through
                phase = .done
                return
            }
            setCurrent(nil)
            events = nil
            chain = ChainState(body: body, initialModel: initialModel, outcome: outcome)
            phase = .startHop(hop: firstHop)
        case .startHop(let hop):
            try await startHop(hop)
        case .driveHop(let hop, var reader, let model, let continuation):
            if let sse = try await readEvent() {
                queue.append(contentsOf: reader.feed(sse))
                if reader.outcome == nil {
                    phase = .driveHop(hop: hop, reader: reader, model: model, continuation: continuation)
                    return
                }
            }
            queue.append(contentsOf: reader.finishFrames())
            let outcome = reader.finish()
            if outcome.opened { chain!.markOpened() }
            guard outcome.refused != nil else {
                phase = .done
                return
            }
            setCurrent(nil)
            events = nil
            // This hop refused too: its emitted partial stays in the client's message, becomes the
            // next partial segment, and the chain continues.
            chain!.absorbRefusal(outcome, model, continuation)
            phase = .startHop(hop: hop + 1)
        }
    }

    private func startHop(_ hop: Int) async throws {
        let fallbacks = middleware.fallbacks
        guard hop < fallbacks.count else {
            phase = .done
            return
        }
        var entry = fallbacks[hop]
        let model = entry["model"]?.stringValue ?? ""
        let hasNext = hop + 1 < fallbacks.count
        pin(hop)

        // First attempt carries the newest partial appended (when its refusal granted a prefill
        // claim); a 400 on that form is taken as the server rejecting the prefill, so the hop is
        // retried once without it.
        var continuation = chain!.continuation
        var served: RawAPIResponse?
        var failure: HopFailure?
        for attempt in 0..<2 {
            if isClosed {
                phase = .done
                return
            }
            let hopRequest = request.copy(body: chain!.hopBody(entry, continuation))
            let res: RawAPIResponse
            do {
                (res, entry) = try await middleware.sendHop(hopRequest, entry, next)
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                logger.log(.error, "anthropic-sdk: BetaRefusalFallbackMiddleware: fallback request to \(model) failed: \(error)")
                failure = HopFailure(model: model, status: nil)
                break
            }
            if res.http.isSuccess {
                served = res
                break
            }
            let errBody = (try? await res.http.read()).flatMap { try? JSONValue.parse($0) } ?? .null
            res.http.close()
            if attempt == 0 && res.statusCode == 400 && !continuation.isEmpty {
                logger.log(.warning,
                           "anthropic-sdk: BetaRefusalFallbackMiddleware: fallback request with the partial output appended was rejected (HTTP 400: \(jsonDumps(errBody))); retrying without it")
                continuation = chain!.base
                continue
            }
            logger.log(.error,
                       "anthropic-sdk: BetaRefusalFallbackMiddleware: fallback request to \(model) failed: HTTP \(res.statusCode): \(jsonDumps(errBody))")
            failure = HopFailure(model: model, status: res.statusCode)
            break
        }

        if let failure {
            // The token was never redeemed — retry it against the next entry.
            if hasNext {
                phase = .startHop(hop: hop + 1)
                return
            }
            // Every remaining entry failed: degrade to the suppressed refusal.
            queue.append(contentsOf: chain!.terminalFailureFrames(failure))
            phase = .done
            return
        }
        guard let served else {
            phase = .done
            return
        }

        setCurrent(served.http)
        events = SSEDecoder.events(from: served.http.bytes()).makeAsyncIterator()
        chain!.queueSeam(model)
        let reader = HopReader(indexBase: chain!.nextIndex, hasNext: hasNext, splice: SpliceInfo(iterations: chain!.iterations, model: model),
                               wireOpen: chain!.wireOpen, primaryID: chain!.primaryID, seamFrames: chain!.pendingSeamFrames, logger: logger)
        phase = .driveHop(hop: hop, reader: reader, model: model, continuation: continuation)
    }
}
