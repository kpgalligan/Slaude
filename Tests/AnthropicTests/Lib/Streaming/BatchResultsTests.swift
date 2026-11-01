import Foundation
import Testing
@testable import Anthropic

// Port of the `results` tests of tests/api_resources/messages/test_batches.py and
// tests/api_resources/beta/messages/test_batches.py (respx-mocked, so not transpiled).

func batchJSON(resultsURL: JSONValue) -> JSONValue {
    [
        "id": "message_batch_id", "archived_at": nil, "cancel_initiated_at": nil, "created_at": "2024-01-01T00:00:00Z", "ended_at": nil,
        "expires_at": "2024-01-02T00:00:00Z", "processing_status": "ended",
        "request_counts": ["canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 1], "results_url": resultsURL,
        "type": "message_batch",
    ]
}

let resultLine1: JSONValue = ["custom_id": "my-custom-id-1", "result": ["type": "canceled"]]
let resultLine2: JSONValue = ["custom_id": "my-custom-id-2", "result": ["type": "expired"]]

/// `mock_results`: the batch, then its JSONL results.
func batchResultsServer(lines: [JSONValue] = [resultLine1, resultLine2]) -> MockServer {
    MockServer([
        .json(batchJSON(resultsURL: "/v1/messages/batches/message_batch_id/results")),
        .text(lines.map(jsonDumps).joined(separator: "\n"), headers: ["content-type": "application/binary"]),
    ])
}

@Suite struct BatchResultsTests {
    @Test func methodResults() async throws {
        let server = batchResultsServer()
        let results = try await server.client().messages.batches.results("message_batch_id")
        #expect(!results.httpResponse.isStreamConsumed)
        let items = try await collect(results)
        #expect(try items.map { try JSONValue.from($0) } == [resultLine1, resultLine2])
        #expect(server.requests.map(\.url.path) == ["/v1/messages/batches/message_batch_id", "/v1/messages/batches/message_batch_id/results"])
        #expect(server.requests[1].headers["Accept"] == "application/binary")
    }

    @Test func rawResponseResults() async throws {
        let server = batchResultsServer()
        let response = try await server.client().messages.batches.withRawResponse.results("message_batch_id")
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let items = try await collect(try await response.parse())
        #expect(items.map(\.customID) == ["my-custom-id-1", "my-custom-id-2"])
    }

    @Test func streamingResponseResults() async throws {
        let server = batchResultsServer()
        let http = try await server.client().messages.batches.withStreamingResponse.results("message_batch_id") { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            let items = try await collect(try await response.parse())
            #expect(items.count == 2)
            return response.http
        }
        #expect(http.isClosed)
    }

    @Test func pathParamsResults() async throws {
        try await expectValueError("Expected a non-empty value for `message_batch_id` but received ''") {
            _ = try await mockClient().messages.batches.withRawResponse.results("")
        }
    }

    @Test func resultsWithoutResultsURL() async throws {
        let server = MockServer([.json(batchJSON(resultsURL: nil))])
        do {
            _ = try await server.client().messages.batches.results("message_batch_id")
            Issue.record("expected an error")
        } catch let e as AnthropicError {
            #expect(e.message == "No `results_url` for the given batch; Has it finished processing? ended")
        }
    }

    @Test func betaMethodResults() async throws {
        let server = batchResultsServer()
        let results = try await server.client().beta.messages.batches.results("message_batch_id", betas: ["files-api-2025-04-14"])
        let items = try await collect(results)
        #expect(try items.map { try JSONValue.from($0) } == [resultLine1, resultLine2])
        #expect(server.requests[1].headers["anthropic-beta"] == "files-api-2025-04-14,message-batches-2024-09-24")
        #expect(server.requests[1].headers["Accept"] == "application/binary")
    }

    @Test func betaDefaultBetaHeader() async throws {
        let server = batchResultsServer()
        _ = try await collect(try await server.client().beta.messages.batches.results("message_batch_id"))
        #expect(server.requests[1].headers["anthropic-beta"] == "message-batches-2024-09-24")
    }

    @Test func betaRawAndStreamingResponseResults() async throws {
        let server = batchResultsServer()
        let response = try await server.client().beta.messages.batches.withRawResponse.results("message_batch_id")
        #expect(try await collect(try await response.parse()).count == 2)

        let server2 = batchResultsServer()
        let count = try await server2.client().beta.messages.batches.withStreamingResponse.results("message_batch_id") { response in
            try await collect(try await response.parse()).count
        }
        #expect(count == 2)
    }

    @Test func betaPathParamsResults() async throws {
        try await expectValueError("Expected a non-empty value for `message_batch_id` but received ''") {
            _ = try await mockClient().beta.messages.batches.withRawResponse.results("")
        }
    }
}
