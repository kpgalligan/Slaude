// Cancelling a request or a stream, and a stream the server ends early, over a real `URLSession` to a server on
// 127.0.0.1 (`LoopbackHTTPServer`). No upstream test covers these: httpx and asyncio cancel differently.

#if canImport(Darwin)
    import Foundation
    import Testing
    @testable import Anthropic

    private func sseEvent(_ name: String, _ data: String) -> String { "event: \(name)\ndata: \(data)\n\n" }

    private let messageStart = sseEvent("message_start",
                                        #"{"type":"message_start","message":{"id":"msg_1","type":"message","role":"assistant","model":"claude-opus-5-5","content":[],"stop_reason":null,"stop_sequence":null,"usage":{"input_tokens":5,"output_tokens":1}}}"#)
    private let textStart = sseEvent("content_block_start", #"{"type":"content_block_start","index":0,"content_block":{"type":"text","text":""}}"#)
    private func textDelta(_ text: String) -> String {
        sseEvent("content_block_delta", #"{"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"\#(text)"}}"#)
    }

    private let messageEnd = [
        sseEvent("content_block_stop", #"{"type":"content_block_stop","index":0}"#),
        sseEvent("message_delta", #"{"type":"message_delta","delta":{"stop_reason":"end_turn","stop_sequence":null},"usage":{"output_tokens":3}}"#),
        sseEvent("message_stop", #"{"type":"message_stop"}"#),
    ]

    /// The first events of a reply, after which the server does what the test says.
    private let replyStart = [messageStart, textStart, textDelta("Hel"), textDelta("lo")]

    private let loopbackBody: RawJSON = ["model": "claude-opus-5-5", "max_tokens": 64, "messages": [["role": "user", "content": "Hi"]]]

    /// A real `URLSession` transport that connects to 127.0.0.1 directly.
    private func loopbackTransport() -> URLSessionTransport {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.connectionProxyDictionary = [:]
        return URLSessionTransport(configuration: configuration)
    }

    /// A client of `server` that would retry twice, at once: a retry the SDK made would reach the server.
    private func loopbackClient(_ server: LoopbackHTTPServer, _ transport: URLSessionTransport) throws -> Anthropic {
        let client = try Anthropic(apiKey: "test-key", baseURL: server.baseURL, maxRetries: 2, transport: transport, environment: [:])
        client.sleeper = { _ in }
        return client
    }

    /// Whether `condition` holds within `timeout` seconds.
    private func whenSoon(_ timeout: TimeInterval = 10, _ condition: () -> Bool) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return true }
            try? await Task.sleep(nanoseconds: 5_000_000)
        }
        return condition()
    }

    /// Long enough for a retry made at once to have reached the server.
    private func settle() async { try? await Task.sleep(nanoseconds: 300_000_000) }

    private final class LoopbackCounter: @unchecked Sendable {
        private let lock = NSLock()
        private var count = 0
        func increment() { lock.withLock { count += 1 } }
        var value: Int { lock.withLock { count } }
    }

    @Suite struct StreamCancellationTests {
        enum Stop: String, CaseIterable, Sendable { case cancelTheTask, closeTheStream }

        @Test(arguments: Stop.allCases)
        func stoppingAJSONStreamMidMessageThrowsCancellationAndClosesTheConnection(stop: Stop) async throws {
            let server = try LoopbackHTTPServer([.sse(replyStart, then: .stall)])
            defer { server.stop() }
            let transport = loopbackTransport()
            let client = try loopbackClient(server, transport)
            let stream = try await client.beta.messages.createStreaming(body: loopbackBody)
            let events = LoopbackCounter()
            let reader = Task {
                for try await _ in stream { events.increment() }
            }
            // Every event the server sent has been read, and the stream is waiting for more.
            #expect(await whenSoon { events.value == replyStart.count })
            switch stop {
            case .cancelTheTask: reader.cancel()
            case .closeTheStream: stream.close()
            }

            let result = await reader.result
            guard case .failure(let error) = result, error is CancellationError else {
                Issue.record("expected CancellationError, got \(result)")
                return
            }
            // The URLSession task is cancelled at once: the connection closes and the transport holds no task.
            #expect(await whenSoon { server.closedByClient == 1 })
            #expect(await whenSoon { transport.activeTaskCount == 0 })
            #expect(!stream.isComplete)
            #expect(stream.message?["content"]?[0]?["text"] == "Hello")
            // Nothing reads the partial Message as the whole one.
            await #expect(throws: CancellationError.self) { _ = try await stream.getFinalMessage() }
            await #expect(throws: CancellationError.self) {
                var events = stream.events.makeAsyncIterator()
                _ = try await events.next()
            }
            await settle()
            #expect(server.requests == ["POST /v1/messages HTTP/1.1"])
            await client.close()
        }

        @Test(arguments: Stop.allCases)
        func stoppingATypedStreamMidMessageThrowsCancellationAndClosesTheConnection(stop: Stop) async throws {
            let server = try LoopbackHTTPServer([.sse(replyStart, then: .stall)])
            defer { server.stop() }
            let transport = loopbackTransport()
            let client = try loopbackClient(server, transport)
            let stream = try await client.messages.stream(maxTokens: 64, messages: [userMessage("Hi")], model: "claude-opus-5-5")
            let texts = LoopbackCounter()
            let reader = Task {
                for try await _ in stream.textStream { texts.increment() }
            }
            #expect(await whenSoon { texts.value == 2 })
            switch stop {
            case .cancelTheTask: reader.cancel()
            case .closeTheStream: stream.close()
            }

            let result = await reader.result
            guard case .failure(let error) = result, error is CancellationError else {
                Issue.record("expected CancellationError, got \(result)")
                return
            }
            #expect(await whenSoon { server.closedByClient == 1 })
            #expect(await whenSoon { transport.activeTaskCount == 0 })
            #expect(!stream.messageComplete)
            await #expect(throws: CancellationError.self) { _ = try await stream.getFinalMessage() }
            await #expect(throws: CancellationError.self) { _ = try await stream.getFinalText() }
            await settle()
            #expect(server.requests.count == 1)
            await client.close()
        }

        @Test(arguments: [true, false])
        func aCancelWhileWaitingForTheResponseIsNotAConnectionErrorAndIsNotRetried(streamed: Bool) async throws {
            let server = try LoopbackHTTPServer([.stallBeforeHeaders])
            defer { server.stop() }
            let transport = loopbackTransport()
            let client = try loopbackClient(server, transport)
            let request = Task {
                if streamed {
                    _ = try await client.beta.messages.createStreaming(body: loopbackBody)
                } else {
                    _ = try await client.messages.create(maxTokens: 64, messages: [userMessage("Hi")], model: "claude-opus-5-5")
                }
            }
            #expect(await whenSoon { server.requests.count == 1 })
            request.cancel()

            let result = await request.result
            guard case .failure(let error) = result, error is CancellationError else {
                Issue.record("expected CancellationError, got \(result)")
                return
            }
            #expect(await whenSoon { server.closedByClient == 1 })
            #expect(await whenSoon { transport.activeTaskCount == 0 })
            await settle()
            #expect(server.requests.count == 1)
            await client.close()
        }

        @Test func aRequestOfATaskCancelledAlreadyIsNeverSent() async throws {
            let server = try LoopbackHTTPServer([.stallBeforeHeaders])
            defer { server.stop() }
            let transport = loopbackTransport()
            let client = try loopbackClient(server, transport)
            let request = Task {
                withUnsafeCurrentTask { $0?.cancel() }
                _ = try await client.beta.messages.createStreaming(body: loopbackBody)
            }

            let result = await request.result
            guard case .failure(let error) = result, error is CancellationError else {
                Issue.record("expected CancellationError, got \(result)")
                return
            }
            #expect(transport.activeTaskCount == 0)
            await settle()
            #expect(server.requests.isEmpty)
            await client.close()
        }

        @Test(arguments: [LoopbackHTTPServer.Ending.closeConnection, .endBody])
        func aStreamTheServerEndsBeforeMessageStopThrowsStreamEndedEarly(ending: LoopbackHTTPServer.Ending) async throws {
            let server = try LoopbackHTTPServer([.sse(replyStart, then: ending)])
            defer { server.stop() }
            let transport = loopbackTransport()
            let client = try loopbackClient(server, transport)
            let stream = try await client.beta.messages.createStreaming(body: loopbackBody)
            let events = LoopbackCounter()

            let error = await #expect(throws: StreamEndedEarlyError.self) {
                for try await _ in stream { events.increment() }
            }
            #expect(events.value == replyStart.count)
            switch ending {
            case .closeConnection:
                // The chunked body was cut off without its last chunk. URLSession (macOS 26) ends such a task without an
                // error, as if the body were whole, so only the missing `message_stop` tells; a transport that does
                // report it has its error under the stream's.
                #expect(error?.underlying == nil || error?.underlying is URLError)
            default:
                #expect(error?.underlying == nil)
            }
            #expect(error?.requestID == "req_loopback")
            // Every later read throws it again; the partial Message stays readable as such.
            await #expect(throws: StreamEndedEarlyError.self) { _ = try await stream.getFinalMessage() }
            #expect(!stream.isComplete)
            #expect(stream.message?["content"]?[0]?["text"] == "Hello")
            #expect(await whenSoon { transport.activeTaskCount == 0 })
            await settle()
            #expect(server.requests.count == 1)
            await client.close()
        }

        @Test func aWholeStreamEndsNormally() async throws {
            let server = try LoopbackHTTPServer([.sse(replyStart + messageEnd, then: .endBody)])
            defer { server.stop() }
            let transport = loopbackTransport()
            let client = try loopbackClient(server, transport)
            let stream = try await client.beta.messages.createStreaming(body: loopbackBody)

            let message = try await stream.getFinalMessage()
            #expect(stream.isComplete)
            #expect(message["content"]?[0]?["text"] == "Hello")
            #expect(message["stop_reason"] == "end_turn")
            // A stream read to its end reads as ended, not cancelled, even when closed afterwards.
            stream.close()
            var events = stream.events.makeAsyncIterator()
            #expect(try await events.next() == nil)
            #expect(await whenSoon { transport.activeTaskCount == 0 })
            await client.close()
        }
    }
#endif
