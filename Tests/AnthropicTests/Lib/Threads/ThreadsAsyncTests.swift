// Port of the async-only tests of tests/lib/threads/test_async_beta_threads.py (the others are twins of the
// test_beta_threads.py tests, ported once).

import Foundation
import Testing
@testable import Anthropic

@Suite struct ThreadsAsyncTests {
    @Test func sendCreatesAThreadThenContinuesIt() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)

        try await thread.send(thUser("Hello"))
        let second = try await thread.send(thUser("Again"))

        #expect(mock.bodies[0]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[0]["messages"] == [thUser("Hello")])
        #expect(mock.bodies[1]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[1]["messages"] == [thUser("Again")])
        #expect(mock.betas == [[THREADS_BETA], [THREADS_BETA]])
        #expect(thread.previousMessageID == second.id)
        #expect(second.id == "msg_b")
    }

    @Test func everyRequestNamesTheThreadAfterTheCallersHelperTag() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), THREADS_NOT_FOUND, thMessageResponse("msg_c"),
                               thUnsupportedResponse("inference_hooks"), thMessageResponse("msg_e"))
        let thread = try thMakeThread(mock, behavior: .continueUnthreaded, extraHeaders: ["x-stainless-helper": "mine"])

        for text in ["One", "Two", "Three"] { try await thread.send(thUser(text)) }

        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a"), THREADS_CREATE, thContinueFrom("msg_c"), nil])
        #expect(mock.helperTags == Array(repeating: "mine, message-thread", count: 5))
    }

    @Test func laterRequestOptionsReplaceTheThreadsAsAWhole() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock, extraHeaders: ["X-Thread": "thread"], extraBody: ["top_k": 5])

        try await thread.send(thUser("Hello"), extraHeaders: ["X-Turn": "turn"])
        try await thread.send(thUser("Again"))
        try thread.update(extraHeaders: ["X-Update": "update"])
        try await thread.send(thUser("Once more"))

        #expect(mock.requests.map { r in ["X-Thread", "X-Turn", "X-Update"].map { r.headers[$0] } } == [
            [nil, "turn", nil], ["thread", nil, nil], [nil, nil, "update"],
        ])
        #expect(mock.bodies.map { $0["top_k"] } == [5, 5, 5])
    }

    @Test func runnerOverATypedThreadParsesTheFinalMessage() async throws {
        // Non-streaming case. The Swift runner yields `BetaMessage`; the final message is parsed with the thread's
        // output format, which every turn of the runner sends.
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", #"{"forecast": "Sunny"}"#))
        let thread = try mock.client().beta.messages.thread(
            maxTokens: THREADS_MAX_TOKENS, model: ModelParam(rawValue: THREADS_MODEL), tools: [thWeatherTool()], outputFormat: ThreadsForecast.self)
        try thread.append(THREADS_WEATHER_QUESTION)

        let final = try await thread.toolRunner().untilDone()

        #expect(try parseBetaResponse(final, parser: thread.parser).parsedOutput == ThreadsForecast(forecast: "Sunny"))
        #expect(mock.bodies.allSatisfy { $0["output_config"]?["format"]?["type"] == "json_schema" })
        #expect(thread.previousMessageID == final.id)
        #expect(final.id == "msg_b")
    }
}
