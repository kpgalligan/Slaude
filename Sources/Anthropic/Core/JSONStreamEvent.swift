import Foundation

/// One event of a stream read with its JSON kept (`JSONMessageStream`): the event's `data` as received, beside
/// the event decoded into the SDK's types as far as it decodes.
public struct JSONStreamEvent<Event: LenientStreamEvent>: Sendable, ObservedStreamItem {
    /// The SSE event name (`message_start`, `content_block_delta`, ...).
    public let name: String
    /// The event's `data` as received: keys in document order, every field (including ones this SDK does not model),
    /// explicit `null`s and numbers as written.
    public let json: RawJSON
    /// The event decoded into the SDK's types: the type's `unknown` case holding the JSON for an event type this SDK
    /// version does not know, and for one that does not decode (see `decodingError`). A block or delta type it does not
    /// know is the `unknown` case of that block or delta inside a decoded event.
    public let event: Event
    /// Why `event` is the `unknown` case although its type is one this SDK models (a field drifted from the schema: a
    /// `null` where a number was expected, a required key left out); `nil` when it decoded.
    public let decodingError: (any Error)?

    public init(name: String, json: RawJSON, event: Event, decodingError: (any Error)? = nil) {
        self.name = name
        self.json = json
        self.event = event
        self.decodingError = decodingError
    }

    /// The event's `type`.
    public var type: String? { json["type"]?.stringValue }

    /// The event of a call's span is the typed one.
    var observedItem: Any { event }

    /// Decodes one server-sent event: its JSON in document order, then its typed event leniently.
    init(_ sse: ServerSentEvent, response: HTTPResponse) throws {
        let data = Data(sse.data.utf8)
        do {
            json = try RawJSON.parse(data)
        } catch {
            throw APIResponseValidationError(response: response, body: .string(sse.data), underlying: error)
        }
        name = sse.event ?? ""
        do {
            event = try AnthropicJSON.decoder().decode(Event.self, from: data)
            decodingError = nil
        } catch {
            event = Event.undecodable(json.jsonValue)
            decodingError = error
        }
    }
}

extension BaseClient {
    /// A server-sent-event stream whose events keep their JSON (`JSONStreamEvent`), for the call `options` makes.
    public func requestJSONStreamResponse<E: LenientStreamEvent>(_ type: E.Type, _ options: FinalRequestOptions) async throws
        -> APIResponse<Stream<JSONStreamEvent<E>>>
    {
        try await tracedRequest(options, stream: true, castTo: Stream<JSONStreamEvent<E>>.self, spanCastTo: streamedType(E.self)) { raw in
            APIResponse(raw, client: self) { resp in
                Stream<JSONStreamEvent<E>>(response: resp.http, client: resp.client) { sse, response, _ in
                    try JSONStreamEvent<E>(sse, response: response)
                }
            }
        }
    }
}
