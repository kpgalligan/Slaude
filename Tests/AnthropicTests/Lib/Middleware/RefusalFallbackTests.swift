import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/test_refusal_fallback.py. The sync and async classes test the same behaviour;
// both run here as Swift async tests (deduplicated where they were twins).

func fbMessageJSON(_ model: String, _ overrides: [String: JSONValue] = [:]) -> JSONValue {
    var o: [String: JSONValue] = [
        "id": "msg_1", "type": "message", "role": "assistant", "model": .string(model), "content": [], "stop_reason": "end_turn",
        "stop_sequence": nil, "usage": ["input_tokens": 1, "output_tokens": 1],
    ]
    for (k, v) in overrides { o[k] = v }
    return .object(o)
}

func fbMessage(_ model: String, _ overrides: [String: JSONValue] = [:]) -> MockReply { .json(fbMessageJSON(model, overrides)) }

func fbRefusal(_ model: String, _ token: String? = nil) -> MockReply {
    fbMessage(model, [
        "stop_reason": "refusal",
        "stop_details": ["type": "refusal", "category": nil, "explanation": nil, "fallback_credit_token": token.map { .string($0) } ?? .null],
    ])
}

func fbError(_ status: Int) -> MockReply {
    .json(["type": "error", "error": ["type": "api_error", "message": "nope"]], status: status)
}

func fallback(_ model: String) -> BetaFallbackParam { BetaFallbackParam(model: ModelParam(rawValue: model)) }

func seam(_ from: String, _ to: String) -> JSONValue {
    ["type": "fallback", "from": ["model": .string(from)], "to": ["model": .string(to)], "trigger": ["type": "refusal"]]
}

func fbCreate(_ client: Anthropic, betas: [AnthropicBetaParam]? = nil, fallbacks: BetaFallbacksParam?? = nil, outputConfig: JSONValue? = nil,
              speed: BetaMessageCreateParamsBase.Speed?? = nil, thinking: JSONValue? = nil, extraHeaders: Headers? = nil) async throws -> BetaMessage
{
    try await client.beta.messages.create(maxTokens: 1024, messages: [betaUserMessage("hi")], model: "primary-model", fallbacks: fallbacks,
                                          outputConfig: try outputConfig?.decode(), speed: speed, thinking: try thinking?.decode(), betas: betas,
                                          extraHeaders: extraHeaders)
}

func fbMiddleware(_ fallbacks: [BetaFallbackParam], betas: [AnthropicBetaParam]? = nil, logs: LogRecorder = LogRecorder()) -> BetaRefusalFallbackMiddleware {
    BetaRefusalFallbackMiddleware(fallbacks, betas: betas, logger: logs.logger)
}

@Suite struct RefusalFallbackTests {
    @Test func retriesARefusalWithTheFallbackParamsAndCreditToken() async throws {
        let server = LibMockServer([fbRefusal("primary-model", "credit-token"), fbMessage("fallback-model")])
        let result = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")])]))
        #expect(result.model.rawValue == "fallback-model")
        #expect(result.stopReason?.rawValue == "end_turn")
        // a `fallback` seam block is prepended at the model boundary
        #expect(try result.content.map { try jsonExcludingNone($0) } == [seam("primary-model", "fallback-model")])
        #expect(server.bodies.map { $0["model"] } == ["primary-model", "fallback-model"])
        #expect(server.bodies[1]["fallback_credit_token"] == ["token": "credit-token", "mode": "best_effort"])
    }

    @Test func pinsTheConversationToTheAcceptedFallbackViaState() async throws {
        let server = LibMockServer([fbRefusal("primary-model"), fbMessage("fallback-model"), fbMessage("fallback-model")])
        let logs = LogRecorder()
        let client = try server.client(middleware: [fbMiddleware([fallback("fallback-model")], logs: logs)])
        let state = BetaFallbackState()
        _ = try await state.run { try await fbCreate(client) }
        #expect(state.index == 0)
        // the follow-up goes straight to the pinned fallback in a single request
        _ = try await state.run { try await fbCreate(client) }
        #expect(server.bodies.map { $0["model"] } == ["primary-model", "fallback-model", "fallback-model"])
        #expect(logs.all.isEmpty)
    }

    @Test func raisesIfStateIndexIsOutOfBoundsForTheChain() async throws {
        let server = LibMockServer([fbMessage("fallback-model")])
        let client = try server.client(middleware: [fbMiddleware([fallback("fallback-model")])])
        let state = BetaFallbackState()
        state.index = 1
        do {
            _ = try await state.run { try await fbCreate(client) }
            Issue.record("expected an error")
        } catch let e as AnthropicError {
            #expect(e.message.contains("BetaFallbackState.index 1 is out of bounds for a chain of 1 fallback(s)"))
        }
        #expect(server.callCount == 0)
    }

    @Test func warnsOnceWhenFallingBackWithoutAState() async throws {
        let server = LibMockServer([fbRefusal("primary-model"), fbMessage("fallback-model"), fbRefusal("primary-model"), fbMessage("fallback-model")])
        let logs = LogRecorder()
        let client = try server.client(middleware: [fbMiddleware([fallback("fallback-model")], logs: logs)])
        _ = try await fbCreate(client)
        _ = try await fbCreate(client)
        #expect(logs.all.count == 1)
        #expect(logs.warnings.first?.contains("BetaFallbackState") == true)
    }

    @Test func aSeparateConversationIsUnaffectedByAnotherState() async throws {
        let server = LibMockServer([fbRefusal("primary-model"), fbMessage("fallback-model"), fbMessage("primary-model")])
        let client = try server.client(middleware: [fbMiddleware([fallback("fallback-model")])])
        _ = try await BetaFallbackState().run { try await fbCreate(client) }
        _ = try await BetaFallbackState().run { try await fbCreate(client) }
        #expect(server.bodies.map { $0["model"] } == ["primary-model", "fallback-model", "primary-model"])
    }

    @Test func leavesAcceptedRequestsAndTheResponseUntouched() async throws {
        let server = LibMockServer([fbMessage("primary-model")])
        let client = try server.client(middleware: [fbMiddleware([fallback("fallback-model")])])
        let state = BetaFallbackState()
        let result = try await state.run { try await fbCreate(client) }
        #expect(result.model.rawValue == "primary-model")
        #expect(server.callCount == 1)
        #expect(server.bodies[0]["fallback_credit_token"] == nil)
        #expect(state.index == nil)
    }

    @Test func walksEachHopThroughTheChainUntilAModelAccepts() async throws {
        let server = LibMockServer([
            fbRefusal("primary-model"), fbRefusal("mid-model"), fbMessage("last-model", ["content": [["type": "text", "text": "ok"]]]),
        ])
        let client = try server.client(middleware: [fbMiddleware([fallback("mid-model"), fallback("last-model")])])
        let state = BetaFallbackState()
        let result = try await state.run { try await fbCreate(client) }
        #expect(result.model.rawValue == "last-model")
        #expect(state.index == 1)
        // one seam per model boundary, in hop order, ahead of the served content
        #expect(try result.content.map { try jsonExcludingNone($0) } == [
            seam("primary-model", "mid-model"), seam("mid-model", "last-model"), ["type": "text", "text": "ok"],
        ])
        #expect(server.bodies.map { $0["model"] } == ["primary-model", "mid-model", "last-model"])
    }

    @Test func aPinnedContinuationSeamsFromThePinnedModel() async throws {
        let server = LibMockServer([fbRefusal("mid-model"), fbMessage("last-model", ["content": [["type": "text", "text": "ok"]]])])
        let client = try server.client(middleware: [fbMiddleware([fallback("mid-model"), fallback("last-model")])])
        let state = BetaFallbackState()
        state.index = 0
        let result = try await state.run { try await fbCreate(client) }
        #expect(result.model.rawValue == "last-model")
        #expect(try result.content.map { try jsonExcludingNone($0) } == [seam("mid-model", "last-model"), ["type": "text", "text": "ok"]])
        #expect(server.bodies.map { $0["model"] } == ["mid-model", "last-model"])
    }

    @Test func returnsTheFinalRefusalOnceTheChainIsExhausted() async throws {
        let server = LibMockServer([fbRefusal("primary-model"), fbRefusal("fallback-model")])
        let result = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")])]))
        #expect(result.model.rawValue == "fallback-model")
        #expect(result.stopReason?.rawValue == "refusal")
        // terminal refusal is surfaced verbatim — no seam blocks prepended
        #expect(result.content.isEmpty)
        #expect(server.callCount == 2)
    }

    @Test func entryOverridesAreMergedWholeOverTheBody() async throws {
        let server = LibMockServer([fbRefusal("primary-model"), fbMessage("fallback-model")])
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([BetaFallbackParam(model: "fallback-model", maxTokens: 32)])]))
        #expect(server.bodies[0]["max_tokens"] == 1024)
        #expect(server.bodies[1]["max_tokens"] == 32)
    }

    @Test func anExplicitNullEntryFieldUnsetsItOnTheRetry() async throws {
        let server = LibMockServer([fbRefusal("primary-model"), fbMessage("fallback-model")])
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([BetaFallbackParam(model: "fallback-model", maxTokens: .some(nil))])]))
        #expect(server.bodies[0]["max_tokens"] == 1024)
        // explicit null unsets: absent from the retried request, not sent as null
        #expect(server.bodies[1]["max_tokens"] == nil)
    }

    @Test func betweenToolsThinkingDegradesToDisabledOnTheHop() async throws {
        let server = LibMockServer([fbRefusal("primary-model", "tok"), fbMessage("fallback-model")])
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")])]), thinking: ["type": "between_tools"])
        #expect(server.bodies[0]["thinking"] == ["type": "between_tools"])
        #expect(server.bodies[1]["thinking"] == ["type": "disabled"])
    }

    @Test func anEntryThatSetsThinkingOverridesBetweenTools() async throws {
        let server = LibMockServer([fbRefusal("primary-model", "tok"), fbMessage("fallback-model")])
        let entry = BetaFallbackParam(model: "fallback-model", thinking: try JSONValue.object(["type": "between_tools"]).decode())
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([entry])]), thinking: ["type": "between_tools"])
        #expect(server.bodies[1]["thinking"] == ["type": "between_tools"])
    }

    @Test func eachHopPatchesTheOriginalParamsNotThePreviousHop() async throws {
        let server = LibMockServer([fbRefusal("primary-model"), fbRefusal("mid-model"), fbMessage("last-model")])
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([BetaFallbackParam(model: "mid-model", maxTokens: 32), fallback("last-model")])]))
        #expect(server.bodies[0]["max_tokens"] == 1024)
        #expect(server.bodies[1]["max_tokens"] == 32)
        // hop 2 patches the ORIGINAL request — hop 1's override does not leak
        #expect(server.bodies[2]["max_tokens"] == 1024)
        #expect(server.bodies[2]["model"] == "last-model")
    }

    @Test func outputConfigSubfieldsPatchOneLevelDeep() async throws {
        let server = LibMockServer([fbRefusal("primary-model"), fbMessage("fallback-model")])
        let entry = BetaFallbackParam(model: "fallback-model", outputConfig: BetaOutputConfigParam(effort: "high", format: .some(nil)))
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([entry])]), outputConfig: [
            "effort": "low", "format": ["type": "json_schema", "schema": ["type": "object"]], "task_budget": ["type": "tokens", "total": 500],
        ])
        // `effort` set overrides, `format: null` unsets only `format`, the absent `task_budget` keeps its value
        #expect(server.bodies[1]["output_config"] == ["effort": "high", "task_budget": ["type": "tokens", "total": 500]])
    }

    @Test func anExplicitNullOutputConfigUnsetsItWhole() async throws {
        let server = LibMockServer([fbRefusal("primary-model"), fbMessage("fallback-model")])
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([BetaFallbackParam(model: "fallback-model", outputConfig: .some(nil))])]),
                               outputConfig: ["effort": "low"])
        #expect(server.bodies[0]["output_config"] == ["effort": "low"])
        #expect(server.bodies[1]["output_config"] == nil)
    }

    @Test func anAbsentOutputConfigKeepsTheOriginal() async throws {
        let server = LibMockServer([fbRefusal("primary-model"), fbMessage("fallback-model")])
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")])]), outputConfig: ["effort": "low"])
        #expect(server.bodies[1]["output_config"] == ["effort": "low"])
    }

    @Test func outputConfigSubfieldsSeedAMissingOriginal() async throws {
        let server = LibMockServer([fbRefusal("primary-model"), fbMessage("fallback-model")])
        let entry = BetaFallbackParam(model: "fallback-model", outputConfig: BetaOutputConfigParam(effort: "high", format: .some(nil)))
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([entry])]))
        #expect(server.bodies[0]["output_config"] == nil)
        #expect(server.bodies[1]["output_config"] == ["effort": "high"])
    }

    @Test func unsettingEveryOutputConfigSubfieldDropsTheKey() async throws {
        let server = LibMockServer([fbRefusal("primary-model"), fbMessage("fallback-model")])
        let entry = BetaFallbackParam(model: "fallback-model", outputConfig: BetaOutputConfigParam(effort: .some(nil), format: .some(nil)))
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([entry])]),
                               outputConfig: ["effort": "low", "format": ["type": "json_schema", "schema": ["type": "object"]]])
        #expect(server.bodies[0]["output_config"] != nil)
        // nothing left after the unsets — the key is dropped, never sent as `{}`
        #expect(server.bodies[1]["output_config"] == nil)
    }

    @Test func allNullOutputConfigSubfieldsOnAMissingOriginalAddNothing() async throws {
        let server = LibMockServer([fbRefusal("primary-model"), fbMessage("fallback-model")])
        let entry = BetaFallbackParam(model: "fallback-model", outputConfig: BetaOutputConfigParam(effort: .some(nil)))
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([entry])]))
        #expect(server.bodies[0]["output_config"] == nil)
        #expect(server.bodies[1]["output_config"] == nil)
    }

    @Test func outputConfigSubfieldsDoNotLeakIntoTheNextHop() async throws {
        let server = LibMockServer([fbRefusal("primary-model"), fbRefusal("mid-model"), fbMessage("last-model")])
        let entries = [BetaFallbackParam(model: "mid-model", outputConfig: BetaOutputConfigParam(effort: "high")), fallback("last-model")]
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware(entries)]), outputConfig: ["effort": "low"])
        #expect(server.bodies[1]["output_config"] == ["effort": "high"])
        #expect(server.bodies[2]["output_config"] == ["effort": "low"])
    }

    @Test func aHopHTTPErrorSurfacesToTheApp() async throws {
        let server = LibMockServer([
            fbRefusal("primary-model", "credit-token"),
            .json(["type": "error", "error": ["type": "invalid_request_error", "message": "nope"]], status: 400),
        ])
        await #expect(throws: BadRequestError.self) {
            _ = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")])]))
        }
        #expect(server.callCount == 2)
    }

    @Test func serverSideFallbacksRaiseAnError() async throws {
        let server = LibMockServer([fbRefusal("primary-model", "credit-token")])
        do {
            _ = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")])]),
                                   fallbacks: try JSONValue.array([["model": "server-fallback"]]).decode(as: BetaFallbacksParam.self))
            Issue.record("expected an error")
        } catch let e as AnthropicError {
            #expect(e.message ==
                "Sending the `fallbacks:` request param is not supported when using the `BetaRefusalFallbackMiddleware`. You should either remove the middleware and send `fallbacks:` with the `server-side-fallback-2026-07-01` beta header to let the API handle refusal fallbacks, or omit the `fallbacks:` param if you'd like `BetaRefusalFallbackMiddleware` to handle fallbacks on the client side.")
        }
        // the error is raised before any request is sent
        #expect(server.callCount == 0)
    }

    @Test func anEmptyChainDisablesTheMiddleware() async throws {
        let server = LibMockServer([fbRefusal("primary-model", "credit-token")])
        let result = try await fbCreate(try server.client(middleware: [fbMiddleware([])]))
        #expect(result.stopReason?.rawValue == "refusal")
        #expect(server.callCount == 1)
        #expect(server.header("anthropic-beta") == [nil])
    }

    @Test func theNonBetaMessagesSurfacePassesThrough() async throws {
        let server = LibMockServer([fbMessage("primary-model", [
            "stop_reason": "refusal", "stop_details": ["type": "refusal", "category": nil, "explanation": nil],
        ])])
        let client = try server.client(middleware: [fbMiddleware([fallback("fallback-model")])])
        let result = try await client.messages.create(maxTokens: 1024, messages: [userMessage("hi")], model: "primary-model")
        #expect(result.stopReason?.rawValue == "refusal")
        #expect(server.callCount == 1)
        #expect(server.header("anthropic-beta") == [nil])
    }

    @Test(arguments: [("/v1/messages", true), ("/v1/messages?beta=true", false)])
    func onlyTheQualifierMarksARequestAsBeta(_ path: String, _ qualified: Bool) async throws {
        let server = LibMockServer([fbRefusal("primary-model", "credit-token"), fbMessage("fallback-model")])
        let client = try server.client(middleware: [fbMiddleware([fallback("fallback-model")])])
        var options = FinalRequestOptions(method: "post", url: path,
                                          jsonData: ["model": "primary-model", "max_tokens": 1024, "messages": [["role": "user", "content": "hi"]]])
        if qualified { options.qualifiers = ["beta": "true"] }
        _ = try await client.requestResponse(BetaMessage.self, options).parse()
        #expect(server.bodies.map { $0["model"] } == (qualified ? ["primary-model", "fallback-model"] : ["primary-model"]))
    }

    @Test func parseGetsTheFallback() async throws {
        let server = LibMockServer([fbRefusal("primary-model", "credit-token"), fbMessage("fallback-model")])
        let client = try server.client(middleware: [fbMiddleware([fallback("fallback-model")])])
        _ = try await client.beta.messages.parse(maxTokens: 1024, messages: [betaUserMessage("hi")], model: "primary-model")
        #expect(server.bodies.map { $0["model"] } == ["primary-model", "fallback-model"])
    }

    @Test func nothingIsLoggedForNonStreamingRetries() async throws {
        let server = LibMockServer([fbRefusal("primary-model", "credit-token"), fbMessage("fallback-model")])
        let logs = LogRecorder()
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")], logs: logs)]))
        #expect(logs.errors.isEmpty)
    }
}

@Suite struct RefusalFallbackBetaHeaderTests {
    @Test func sendsTheFallbackCreditBetaOnTheOriginalAndFallbackRequests() async throws {
        let server = LibMockServer([fbRefusal("primary-model", "credit-token"), fbMessage("fallback-model")])
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")])]))
        #expect(server.header("anthropic-beta") == ["fallback-credit-2026-07-01", "fallback-credit-2026-07-01"])
    }

    @Test func theBetasOptionReplacesTheDefault() async throws {
        let server = LibMockServer([fbMessage("primary-model")])
        _ = try await fbCreate(try server.client(middleware: [
            fbMiddleware([fallback("fallback-model")], betas: ["fallback-credit-2027-01-01", "interleaved-thinking-2025-05-14"]),
        ]))
        #expect(server.header("anthropic-beta") == ["fallback-credit-2027-01-01,interleaved-thinking-2025-05-14"])
    }

    @Test func emptyBetasSendsNoBetaHeader() async throws {
        let server = LibMockServer([fbMessage("primary-model")])
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")], betas: [])]))
        #expect(server.header("anthropic-beta") == [nil])
    }

    @Test func doesNotDuplicateABetaAlreadyOnTheRequest() async throws {
        let server = LibMockServer([fbMessage("primary-model")])
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")])]), betas: ["fallback-credit-2026-07-01"])
        #expect(server.header("anthropic-beta") == ["fallback-credit-2026-07-01"])
    }

    @Test func appendsToBetasAlreadyOnTheRequest() async throws {
        let server = LibMockServer([fbMessage("primary-model")])
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")])]), betas: ["interleaved-thinking-2025-05-14"])
        #expect(server.header("anthropic-beta") == ["interleaved-thinking-2025-05-14,fallback-credit-2026-07-01"])
    }
}

@Suite struct RefusalFallbackHelperTelemetryTests {
    func helperHeaders(_ server: LibMockServer) -> [[String]] { server.requests.map { $0.headers.values("x-stainless-helper") } }

    @Test func tagsTheOriginalAndFallbackRequests() async throws {
        let server = LibMockServer([fbRefusal("primary-model", "credit-token"), fbMessage("fallback-model")])
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")])]))
        #expect(helperHeaders(server) == [["fallback-refusal-middleware"], ["fallback-refusal-middleware"]])
    }

    @Test func appendsToAHelperTagAlreadyOnTheRequest() async throws {
        let server = LibMockServer([fbMessage("primary-model")])
        _ = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")])]),
                               extraHeaders: ["X-Stainless-Helper": "BetaToolRunner"])
        #expect(helperHeaders(server) == [["BetaToolRunner, fallback-refusal-middleware"]])
    }

    @Test func doesNotTagRequestsItPassesThrough() async throws {
        let server = LibMockServer([fbMessage("primary-model")])
        let client = try server.client(middleware: [fbMiddleware([fallback("fallback-model")])])
        _ = try await client.messages.create(maxTokens: 1024, messages: [userMessage("hi")], model: "primary-model")
        #expect(helperHeaders(server) == [[]])
    }
}

let failedHopsThatAreNotResent: [(BetaFallbackParam, BetaMessageCreateParamsBase.Speed?, Int)] = [
    (BetaFallbackParam(model: "fallback-model", speed: "fast"), .fast, 429),  // the entry sets fast
    (fallback("fallback-model"), nil, 429),  // no speed
    (fallback("fallback-model"), .standard, 429),  // standard speed
    (fallback("fallback-model"), .fast, 400),  // http 400
    (fallback("fallback-model"), .fast, 500),  // http 500
]

@Suite struct RefusalFallbackRateLimitedFastHopTests {
    @Test(arguments: [429, 529])
    func isResentOnceWithoutSpeed(_ status: Int) async throws {
        let server = LibMockServer([fbRefusal("primary-model", "credit-token"), fbError(status), fbMessage("fallback-model")])
        let logs = LogRecorder()
        let result = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")], logs: logs)]), speed: .fast)
        #expect(result.model.rawValue == "fallback-model")
        #expect(result.stopReason?.rawValue == "end_turn")
        #expect(try result.content.map { try JSONValue.from($0)["type"] } == ["fallback"])
        let bodies = server.bodies
        #expect(bodies.map { [$0["model"], $0["speed"]] } == [["primary-model", "fast"], ["fallback-model", "fast"], ["fallback-model", nil]])
        #expect(bodies[2]["fallback_credit_token"] == ["token": "credit-token", "mode": "best_effort"])
        var withoutSpeed = bodies[1]
        withoutSpeed["speed"] = nil
        #expect(bodies[2] == withoutSpeed)
        #expect(logs.resendWarnings.count == 1)
    }

    @Test(arguments: failedHopsThatAreNotResent.indices)
    func anyOtherFailedHopIsNotResent(_ i: Int) async throws {
        let (entry, speed, status) = failedHopsThatAreNotResent[i]
        // the last response is a spare: an unwanted resend would be served and counted
        let server = LibMockServer([fbRefusal("primary-model", "credit-token"), fbError(status), fbMessage("fallback-model")])
        do {
            _ = try await fbCreate(try server.client(middleware: [fbMiddleware([entry])]), speed: speed.map { .some($0) })
            Issue.record("expected an error")
        } catch let e as APIStatusError {
            #expect(e.statusCode == status)
        }
        #expect(server.callCount == 2)
    }

    @Test func aResendThatIsRateLimitedTooSurfacesToTheApp() async throws {
        let server = LibMockServer([fbRefusal("primary-model", "credit-token"), fbError(429), fbError(429), fbMessage("fallback-model")])
        do {
            _ = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")])]), speed: .fast)
            Issue.record("expected an error")
        } catch let e as APIStatusError {
            #expect(e.statusCode == 429)
        }
        #expect(server.bodies.map { $0["speed"] } == ["fast", "fast", nil])
    }

    @Test func aRequestThatStartsOnThePinnedEntryIsResentWithoutSpeed() async throws {
        let server = LibMockServer([fbError(429), fbMessage("fallback-model"), fbError(429), fbMessage("fallback-model")])
        let client = try server.client(middleware: [fbMiddleware([fallback("fallback-model")])])
        let state = BetaFallbackState()
        state.index = 0
        let result = try await state.run { () async throws -> BetaMessage in
            let r = try await fbCreate(client, speed: .fast)
            _ = try await fbCreate(client, speed: .fast)
            return r
        }
        #expect(result.model.rawValue == "fallback-model")
        #expect(state.index == 0)
        // the second request starts fast again: the dropped `speed` is not remembered
        let bodies = server.bodies
        #expect(bodies.map { [$0["model"], $0["speed"]] } == [
            ["fallback-model", "fast"], ["fallback-model", nil], ["fallback-model", "fast"], ["fallback-model", nil],
        ])
        var withoutSpeed = bodies[0]
        withoutSpeed["speed"] = nil
        #expect(bodies[1] == withoutSpeed)
    }

    @Test func theOriginalRequestIsNotResent() async throws {
        let server = LibMockServer([fbError(429), fbMessage("primary-model")])
        await #expect(throws: APIStatusError.self) {
            _ = try await fbCreate(try server.client(middleware: [fbMiddleware([fallback("fallback-model")])]), speed: .fast)
        }
        #expect(server.callCount == 1)
    }
}

@Suite struct BetaFallbackStateTests {
    @Test func reenteringTheSameStateNests() async {
        let state = BetaFallbackState()
        await state.run {
            await state.run { #expect(BetaFallbackState.current === state) }
            #expect(BetaFallbackState.current === state)
        }
        #expect(BetaFallbackState.current == nil)
    }

    @Test func nestingDifferentStatesRestoresTheOuterPin() async {
        let outer = BetaFallbackState()
        let inner = BetaFallbackState()
        await outer.run {
            await inner.run { #expect(BetaFallbackState.current === inner) }
            #expect(BetaFallbackState.current === outer)
        }
        #expect(BetaFallbackState.current == nil)
    }

    /// `test_one_state_shared_across_threads`: each task enters and exits the shared state in its own context.
    @Test func oneStateSharedAcrossTasks() async {
        let state = BetaFallbackState()
        await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<2 {
                group.addTask {
                    let inside = await state.run { () async -> Bool in
                        await Task.yield()
                        return BetaFallbackState.current === state
                    }
                    return inside && BetaFallbackState.current == nil
                }
            }
            for await ok in group { #expect(ok) }
        }
    }
}
