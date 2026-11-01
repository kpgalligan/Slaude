import Foundation

// Hand port of `messages.batches.results(...)` and `beta.messages.batches.results(...)`
// (`resources/messages/batches.py`, `resources/beta/messages/batches.py`): retrieve the batch, then
// stream its `results_url` as JSON Lines.

extension MessagesBatchesResource {
    /// Streams the results of a Message Batch as a `.jsonl` file.
    ///
    /// Each line in the file is a JSON object containing the result of a single request in the
    /// Message Batch. Results are not guaranteed to be in the same order as requests. Use the
    /// `customID` field to match results to requests.
    public func results(_ messageBatchID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil,
                        extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> JSONLDecoder<MessageBatchIndividualResponse>
    {
        try await _results(messageBatchID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery,
                           extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _results(_ messageBatchID: String, workspaceID: String?, extraHeaders: Headers?, extraQuery: Query?, extraBody: Body?,
                  timeout: Timeout?, _mode: ResponseMode) async throws -> APIResponse<JSONLDecoder<MessageBatchIndividualResponse>>
    {
        try requireNonEmpty(messageBatchID, "message_batch_id")
        let batch = try await retrieve(messageBatchID, workspaceID: workspaceID)
        guard let resultsURL = batch.resultsURL, !resultsURL.isEmpty else {
            throw AnthropicError("No `results_url` for the given batch; Has it finished processing? \(batch.processingStatus.rawValue)")
        }
        let headers = mergeHeaderLayers(stripNotGiven([("anthropic-workspace-id", workspaceID)]), ["Accept": "application/binary"], extraHeaders)
        let options = try client.makeRequestOptions(
            method: "get", url: try pathTemplate(resultsURL, ["message_batch_id": messageBatchID]), headers: headers,
            extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.messages.batches.results",
            spanRoute: "/v1/messages/batches/{message_batch_id}/results", spanAttributes: ["anthropic.message.batch.id": messageBatchID])
        return try await client.requestJSONLResponse(MessageBatchIndividualResponse.self, options)
    }
}

extension MessagesBatchesResource.WithRawResponse {
    public func results(_ messageBatchID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil,
                        extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<JSONLDecoder<MessageBatchIndividualResponse>>
    {
        try await resource._results(messageBatchID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery,
                                    extraBody: extraBody, timeout: timeout, _mode: .raw)
    }
}

extension MessagesBatchesResource.WithStreamingResponse {
    public func results<R: Sendable>(_ messageBatchID: String, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil,
                                     extraBody: Body? = nil, timeout: Timeout? = nil,
                                     body: (APIResponse<JSONLDecoder<MessageBatchIndividualResponse>>) async throws -> R) async throws -> R
    {
        let response = try await resource._results(messageBatchID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery,
                                                   extraBody: extraBody, timeout: timeout, _mode: .stream)
        defer { response.close() }
        return try await body(response)
    }
}

extension BetaMessagesBatchesResource {
    /// Streams the results of a Message Batch as a `.jsonl` file. See `MessagesBatchesResource.results`.
    public func results(_ messageBatchID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil,
                        extraQuery: Query? = nil, extraBody: Body? = nil,
                        timeout: Timeout? = nil) async throws -> JSONLDecoder<BetaMessageBatchIndividualResponse>
    {
        try await _results(messageBatchID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery,
                           extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _results(_ messageBatchID: String, betas: [AnthropicBetaParam]?, workspaceID: String?, extraHeaders: Headers?, extraQuery: Query?,
                  extraBody: Body?, timeout: Timeout?, _mode: ResponseMode) async throws -> APIResponse<JSONLDecoder<BetaMessageBatchIndividualResponse>>
    {
        try requireNonEmpty(messageBatchID, "message_batch_id")
        let batch = try await retrieve(messageBatchID, betas: betas, workspaceID: workspaceID)
        guard let resultsURL = batch.resultsURL, !resultsURL.isEmpty else {
            throw AnthropicError("No `results_url` for the given batch; Has it finished processing? \(batch.processingStatus.rawValue)")
        }
        let headers = mergeHeaderLayers(
            ["anthropic-beta": "message-batches-2024-09-24"],
            stripNotGiven([
                ("anthropic-beta", joinHeaderValues(betas, extra: ["message-batches-2024-09-24"])),
                ("anthropic-workspace-id", workspaceID),
            ]),
            ["Accept": "application/binary"], extraHeaders)
        let options = try client.makeRequestOptions(
            method: "get", url: try pathTemplate(resultsURL, ["message_batch_id": messageBatchID]), headers: headers,
            extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.messages.batches.results",
            spanRoute: "/v1/messages/batches/{message_batch_id}/results", spanAttributes: ["anthropic.message.batch.id": messageBatchID],
            qualifiers: ["beta": "true"])
        return try await client.requestJSONLResponse(BetaMessageBatchIndividualResponse.self, options)
    }
}

extension BetaMessagesBatchesResource.WithRawResponse {
    public func results(_ messageBatchID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil,
                        extraQuery: Query? = nil, extraBody: Body? = nil,
                        timeout: Timeout? = nil) async throws -> APIResponse<JSONLDecoder<BetaMessageBatchIndividualResponse>>
    {
        try await resource._results(messageBatchID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery,
                                    extraBody: extraBody, timeout: timeout, _mode: .raw)
    }
}

extension BetaMessagesBatchesResource.WithStreamingResponse {
    public func results<R: Sendable>(_ messageBatchID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil,
                                     extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil,
                                     body: (APIResponse<JSONLDecoder<BetaMessageBatchIndividualResponse>>) async throws -> R) async throws -> R
    {
        let response = try await resource._results(messageBatchID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders,
                                                   extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
        defer { response.close() }
        return try await body(response)
    }
}
