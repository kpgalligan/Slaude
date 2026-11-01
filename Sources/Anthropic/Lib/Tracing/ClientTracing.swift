import Foundation

// The call span of each API call (`AsyncAPIClient.request`, with `_request` recording the attempts).

extension BaseClient {
    /// Runs an API call in its call span, and ends the span with the call's result (`AsyncAPIClient.request`).
    ///
    /// `make` builds the response that the method returns. A parsed call is parsed here, as Python's `_process_response`
    /// does in the call, so that the span has the response. `spanCastTo` is the type that the method says the call
    /// returns, when the type that it parses is another, as the `Message` of a stream of its events is.
    func tracedRequest<T: Sendable>(_ options: FinalRequestOptions, stream: Bool, castTo: Any.Type, spanCastTo: Any.Type? = nil,
                                    make: (RawAPIResponse) -> APIResponse<T>) async throws -> APIResponse<T>
    {
        guard let tracer else { return make(try await sendRequest(options, stream: stream, castTo: castTo, call: nil)) }
        // The data is prepared before the span starts, which reads the body.
        let prepared = copyAndPrepare(options)
        let startTime = Date()
        let propagation = openTelemetry.resolvedPropagation
        let otel = self.otel
        guard let span = startApiCallSpan(tracer, baseURL: baseURL, client: self, options: prepared,
                                          attributes: otel.apiCallStartAttributes(), propagation: propagation)
        else { return make(try await sendRequest(prepared, stream: stream, castTo: castTo, call: nil)) }
        let call = ApiCall(span: span, startTime: startTime, recordsContent: otel.recordsContent, propagation: propagation)
        let returns = spanCastTo ?? castTo
        do {
            let raw = try await TracingContext.withSpan(span) {
                try await sendRequest(prepared, stream: stream, castTo: castTo, call: call)
            }
            let response = make(raw)
            let data: ApiCallData
            switch prepared.headers?[rawResponseHeader]?.stringValue {
            case "raw", "stream":
                // `withRawResponse` and `withStreamingResponse` return the response itself.
                data = .response(raw.http)
            default:
                data = .value(try await response.parse())
            }
            finishApiCallSpan(self, span, call.result(prepared, response: raw.isShortCircuit ? nil : raw.http, data: data, castTo: returns))
            return response
        } catch {
            finishApiCallSpan(self, span, call.result(prepared, error: error, castTo: returns))
            throw error
        }
    }
}

/// The type that a method whose call returns a stream of `E` says the call returns: a Messages create call that
/// streams returns a `Message`.
func streamedType<E>(_ event: E.Type) -> Any.Type? {
    if E.self == RawMessageStreamEvent.self { return Message.self }
    if E.self == BetaRawMessageStreamEvent.self { return BetaMessage.self }
    return nil
}
