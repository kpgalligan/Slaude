import Foundation

// Port of `lib/_tracing/_streaming.py`: a streamed Message, recorded on the span of its API call as the
// application reads it.

/// Records a streamed Message on the span of its API call as the application reads it, and ends the span
/// (`StreamedMessage`).
///
/// The stream helper that reads the stream shares the Message it accumulates (`shareMessageSnapshot`): it gives each
/// snapshot that it makes to `updateSnapshot`, since a reader of the helper's own would keep the helper alive. In content
/// mode the output content comes from there: the whole Message, or what the helper had accumulated of it when the
/// stream ended before `message_stop`. A stream read without a helper gets only its `message_start`,
/// `content_block_start` and `message_delta` events accumulated here, which carry everything but the content, so its
/// span has no output content.
final class StreamedMessage: StreamObserver, @unchecked Sendable {
    private let span: any Span
    private let body: JSONValue?
    private let requestHeaders: HTTPHeaders
    private let content: Bool
    private let maxContentBytes: Int
    private let startTime: Date
    private let lock = NSLock()
    private var parsed = false
    /// Whether a stream helper shares its snapshot, and the last that it gave.
    private var shared = false
    private var sharedSnapshot: (any Encodable & Sendable)?
    private var snapshotWithheld = false
    private var firstDelta = true
    private var snapshot: JSONValue?
    private var beta = false
    private var stopped = false
    private var hasMessageDelta = false

    init(_ span: any Span, body: JSONValue?, requestHeaders: HTTPHeaders, content: Bool, maxContentBytes: Int, startTime: Date) {
        self.span = span
        self.body = body
        self.requestHeaders = requestHeaders
        self.content = content
        self.maxContentBytes = maxContentBytes
        self.startTime = startTime
    }

    func begin() { lock.withLock { parsed = true } }

    func item(_ item: Any) {
        let isBeta = item is BetaRawMessageStreamEvent
        guard isBeta || item is RawMessageStreamEvent, let encodable = item as? any Encodable,
              let event = try? JSONValue.from(encodable)
        else { return }
        let eventType = event["type"]?.stringValue
        lock.withLock {
            if eventType == "content_block_delta" && firstDelta {
                firstDelta = false
                setTimeToFirstChunk(span, startTime: startTime)
            }
            if eventType == "message_stop" { stopped = true }
            if eventType == "message_start" { beta = isBeta }
            // A helper shares its snapshot before it reads the first event, and then this accumulates nothing.
            var accumulated = true
            if !shared, eventType == "message_start" || eventType == "content_block_start" || eventType == "message_delta" {
                let next = accumulate(event, snapshot, beta: beta)
                if let next { snapshot = next }
                accumulated = next != nil
            }
            // After the accumulation, which can fail and leave the snapshot without what the event has.
            if eventType == "message_delta" && accumulated { hasMessageDelta = true }
        }
    }

    func end(_ how: StreamEnd, error: Error?) {
        let (shared, sharedSnapshot, withheld, own, complete, stopped, parsed, beta) = lock.withLock {
            (self.shared, self.sharedSnapshot, snapshotWithheld, snapshot, hasMessageDelta, self.stopped, self.parsed, self.beta)
        }
        let message = shared ? sharedSnapshot.flatMap { try? JSONValue.from($0) } : own
        if let message {
            // `message_delta` has the last of what `setResponse` reads, so a stream that ends after it lacks nothing.
            setResponse(span, message, complete: complete && !withheld, beta: beta)
        }
        if content {
            // Before `message_stop` the snapshot is partial: a `tool_use` block has the input parsed so far.
            let output = message != nil && shared && !withheld ? tracingGet(message, "content") : nil
            setMessageContent(span, body: body, output: output, limit: maxContentBytes)
        }

        if let error {
            setErrorStatus(span, error)
        } else if how == .read && (stopped || !parsed) {
            // An application that reads the bytes of the body itself leaves the events unknown.
            span.setStatus(.ok)
        } else if how == .read {
            // The server cut the stream short. The application sees no error, so only the span fails.
            setErrorStatus(span, AnthropicError("The stream ended before its end event."), type: "api_error")
        }
        span.end()
    }

    func shareSnapshot() { lock.withLock { shared = true } }
    func updateSnapshot(_ snapshot: (any Encodable & Sendable)?) { lock.withLock { sharedSnapshot = snapshot } }
    func withholdSnapshot() { lock.withLock { snapshotWithheld = true } }
}

/// `snapshot` with what `event` has of a Message other than its content's deltas: the `message_start`,
/// `content_block_start` and `message_delta` events (`accumulate_event`, for those). `nil` when there is nothing
/// to accumulate, or the event cannot be: the snapshot then lacks it.
func accumulate(_ event: JSONValue, _ snapshot: JSONValue?, beta: Bool) -> JSONValue? {
    switch event["type"]?.stringValue {
    case "message_start":
        guard snapshot == nil, let message = event["message"], message.objectValue != nil else { return nil }
        return message
    case "content_block_start":
        guard var message = snapshot, let block = event["content_block"] else { return nil }
        var content = message["content"]?.arrayValue ?? []
        content.append(block)
        message["content"] = .array(content)
        if beta, block["type"]?.stringValue == "fallback", let model = block["to"]?["model"] {
            // The final hop's fallback block names the model that served the response.
            message["model"] = model
        }
        return message
    case "message_delta":
        guard var message = snapshot, let delta = event["delta"]?.objectValue, var usage = message["usage"]?.objectValue,
              let eventUsage = event["usage"]?.objectValue, let outputTokens = eventUsage["output_tokens"]
        else { return nil }
        message["stop_reason"] = delta["stop_reason"] ?? .null
        message["stop_sequence"] = delta["stop_sequence"] ?? .null
        usage["output_tokens"] = outputTokens
        // Usage counts on a `message_delta` are cumulative totals, and the ones that are left out keep their value.
        var keys = ["input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens", "server_tool_use", "output_tokens_details"]
        if beta { keys += ["iterations", "fallback_credit"] }
        for key in keys {
            if let value = eventUsage[key], !value.isNull { usage[key] = value }
        }
        message["usage"] = .object(usage)
        return message
    default:
        return nil
    }
}

/// Lets the span of the API call that returned `stream` take its output content from the snapshots of a stream
/// helper (`share_message_snapshot`). Returns what the helper gives each snapshot to, or `nil` when the call has no span.
func shareMessageSnapshot<E>(_ stream: Stream<E>) -> StreamedMessage? {
    let message = streamedMessage(stream.response)
    message?.shareSnapshot()
    return message
}

/// Keeps the snapshot shared for `stream` out of the output content of the span of its API call
/// (`withhold_message_snapshot`): the stream helper could not accumulate an event, so its snapshot is not the
/// Message that the events make.
func withholdMessageSnapshot<E>(_ stream: Stream<E>) {
    streamedMessage(stream.response)?.withholdSnapshot()
}

/// What records the stream over `response` on the span of its API call, or `nil` when the call has no span.
func streamedMessage(_ response: HTTPResponse) -> StreamedMessage? {
    (response.streamObserver as? FirstEnd)?.inner as? StreamedMessage
}
