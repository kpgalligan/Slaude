// Port of tests/lib/sessions/test_accumulate.py.
//
// Swift values are copied, so the upstream identity checks (`is not`) become checks that the inputs keep their
// values after a fold.

import Foundation
import Testing
@testable import Anthropic

private func accumStart(_ eventID: String) -> BetaManagedAgentsStreamSessionEvents {
    .eventStart(BetaManagedAgentsStartEvent(event: .agentMessage(BetaManagedAgentsAgentMessagePreview(id: eventID))))
}

private func accumSeed(_ eventID: String) throws -> BetaManagedAgentsAgentMessageEvent {
    try #require(try accumulateManagedAgentsEvent(nil, accumStart(eventID)), "expected agent.message seed")
}

private func accumDelta(_ eventID: String, _ text: String, _ index: Int? = nil, type: String = "text") -> BetaManagedAgentsDeltaEvent {
    BetaManagedAgentsDeltaEvent(
        delta: BetaManagedAgentsDeltaContent(content: BetaManagedAgentsTextBlock(text: text, type: type), index: index), eventID: eventID)
}

private func accumFold(_ message: BetaManagedAgentsAgentMessageEvent, _ event: BetaManagedAgentsDeltaEvent) throws
    -> BetaManagedAgentsAgentMessageEvent
{
    try #require(try accumulateManagedAgentsEvent(message, .eventDelta(event)), "expected snapshot after delta")
}

private func accumText(_ text: String) -> BetaManagedAgentsAgentMessageEvent.Content {
    .text(BetaManagedAgentsTextBlock(text: text))
}

private func accumFinal() -> BetaManagedAgentsAgentMessageEvent {
    BetaManagedAgentsAgentMessageEvent(
        id: "evt_1", content: [accumText("complete")], processedAt: Date(timeIntervalSince1970: 1_704_067_200))
}

@Suite struct AccumulateManagedAgentsEventTests {
    @Test func eventStartReturnsAFreshEmptySnapshotFromNil() throws {
        let message = try #require(try accumulateManagedAgentsEvent(nil, accumStart("evt_1")))
        #expect(message.id == "evt_1")
        #expect(message.type == "agent.message")
        #expect(message.content.isEmpty)
        #expect(message.processedAt == Date(timeIntervalSince1970: 0))
    }

    @Test func eventStartForANonAgentMessagePreviewReturnsNil() throws {
        let event = BetaManagedAgentsStreamSessionEvents.eventStart(
            BetaManagedAgentsStartEvent(event: .agentThinking(BetaManagedAgentsAgentThinkingPreview(id: "evt_1"))))
        #expect(try accumulateManagedAgentsEvent(nil, event) == nil)
    }

    @Test func newIndexInsertsTheFragmentAsAFreshBlock() throws {
        let next = try accumFold(try accumSeed("evt_1"), accumDelta("evt_1", "Hello", 0))
        #expect(next.content == [accumText("Hello")])
    }

    @Test func existingTextIndexAppends() throws {
        var message = try accumSeed("evt_1")
        message = try accumFold(message, accumDelta("evt_1", "Hel", 0))
        message = try accumFold(message, accumDelta("evt_1", "lo", 0))
        message = try accumFold(message, accumDelta("evt_1", "World", 1))
        #expect(message.content == [accumText("Hello"), accumText("World")])
    }

    @Test func defaultsIndexTo0() throws {
        var message = try accumSeed("evt_1")
        message = try accumFold(message, accumDelta("evt_1", "a"))
        message = try accumFold(message, accumDelta("evt_1", "b"))
        #expect(message.content == [accumText("ab")])
    }

    @Test func throwsOnAnIndexGap() throws {
        let message = try accumSeed("evt_1")
        #expect(throws: AnthropicError.self) { try accumulateManagedAgentsEvent(message, .eventDelta(accumDelta("evt_1", "x", 2))) }
        do {
            _ = try accumulateManagedAgentsEvent(message, accumDelta("evt_1", "x", 2))
        } catch let error as AnthropicError {
            #expect(error.message == "event_delta index 2 is beyond the end of content (length 0)")
        }
    }

    @Test func throwsOnEventDeltaWithNoPriorSnapshot() {
        do {
            _ = try accumulateManagedAgentsEvent(nil, .eventDelta(accumDelta("evt_1", "x", 0)))
            Issue.record("expected an error")
        } catch let error as AnthropicError {
            #expect(error.message == "event_delta for evt_1 received before its event_start")
        } catch {
            Issue.record("unexpected \(error)")
        }
    }

    @Test func nextSequentialIndexInserts() throws {
        var message = try accumSeed("evt_1")
        message = try accumFold(message, accumDelta("evt_1", "a", 0))
        message = try accumFold(message, accumDelta("evt_1", "b", 1))
        #expect(message.content == [accumText("a"), accumText("b")])
    }

    @Test func returnsANewSnapshotAndDoesNotMutateTheInput() throws {
        let message = try accumSeed("evt_1")
        let next = try accumFold(message, accumDelta("evt_1", "x", 0))
        #expect(message.content.isEmpty)
        let after = try accumFold(next, accumDelta("evt_1", "y", 0))
        #expect(after.content == [accumText("xy")])
        #expect(next.content == [accumText("x")])
    }

    @Test func doesNotMutateTheWireDeltaWhenInsertingAtANewIndex() throws {
        let delta = accumDelta("evt_1", "x", 0)
        var message = try accumSeed("evt_1")
        message = try accumFold(message, delta)
        message = try accumFold(message, accumDelta("evt_1", "y", 0))
        #expect(delta.delta.content.text == "x")
        #expect(message.content == [accumText("xy")])
    }

    @Test func agentMessageReplacesThePreviewWithTheFinalEvent() throws {
        var message = try accumSeed("evt_1")
        message = try accumFold(message, accumDelta("evt_1", "partial", 0))
        let final = accumFinal()
        #expect(try accumulateManagedAgentsEvent(message, .agentMessage(final)) == final)
        #expect(accumulateManagedAgentsEvent(message, final) == final)
    }

    @Test func agentMessageAcceptsNilSnapshot() throws {
        #expect(try accumulateManagedAgentsEvent(nil, .agentMessage(accumFinal())) == accumFinal())
    }

    @Test func unknownBlockTypePairIsANoopForwardCompat() throws {
        var message = try accumSeed("evt_1")
        // An existing block of a future, non-text type.
        let future: JSONValue = ["type": "tool_use", "id": "t", "name": "n", "input": [:]]
        message.content.append(.unknown(future))
        let next = try accumFold(message, accumDelta("evt_1", "ignored", 0))
        #expect(next.content == [.unknown(future)])
    }

    @Test func unknownEventTypePassesTheSnapshotThroughForwardCompat() throws {
        var message = try accumSeed("evt_1")
        message = try accumFold(message, accumDelta("evt_1", "x", 0))
        // An event of a future type this SDK version does not know about.
        let future: BetaManagedAgentsStreamSessionEvents = try JSONValue.object(["type": "agent.future_event", "id": "evt_2"]).decode()
        guard case .unknown = future else {
            Issue.record("expected an unknown event")
            return
        }
        #expect(try accumulateManagedAgentsEvent(message, future) == message)
        #expect(try accumulateManagedAgentsEvent(nil, future) == nil)
    }

    @Test func unknownFragmentTypeOnAnExistingIndexIsANoopForwardCompat() throws {
        var message = try accumSeed("evt_1")
        message = try accumFold(message, accumDelta("evt_1", "x", 0))
        // A delta fragment of a future, non-text type.
        let next = try accumFold(message, accumDelta("evt_1", "", 0, type: "citation"))
        #expect(next.content == [accumText("x")])
    }
}
