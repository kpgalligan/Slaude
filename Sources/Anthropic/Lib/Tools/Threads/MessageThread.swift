// Port of the sending half of `anthropic/lib/threads/_beta_threads.py` (`BetaAsyncMessageThread`) that the tool
// runners use: one turn at a time, re-sent while the thread state recovers from a rejection.

import Foundation

/// A client that cannot use server-side message threads (`_supports_message_threads = False`). Platform clients
/// conform to it; a first-party `Anthropic` client supports them.
public protocol MessageThreadsUnsupported {}

func supportsMessageThreads(_ client: BaseClient) -> Bool {
    client is Anthropic && !(client is MessageThreadsUnsupported)
}

/// A conversation the tool runner sends turn by turn (`BetaAsyncMessageThread`).
/// Only ever used from the actor that owns it (a tool runner), hence `@unchecked Sendable`.
final class MessageThread: @unchecked Sendable {
    let client: BaseClient
    let state: ThreadState

    init(client: BaseClient, state: ThreadState) {
        self.client = client
        self.state = state
    }

    /// The thread of a tool runner made from the params of its requests (`_for_tool_runner`).
    static func forToolRunner(client: BaseClient, fields: [String: JSONValue], messages: [JSONValue],
                              tools: [any BetaToolLike], threading: Bool, outputFormat: [String: JSONValue]? = nil) throws
        -> MessageThread
    {
        let state = try ThreadState(
            fields: fields, messages: messages, tools: tools, options: ToolRunnerRequestOptions(),
            threading: threading && supportsMessageThreads(client), unsupportedRequestBehavior: "continue_unthreaded")
        state.outputFormat = outputFormat
        return MessageThread(client: client, state: state)
    }

    var messages: [JSONValue] { state.messages }

    func fork() -> MessageThread { MessageThread(client: client, state: state.fork()) }

    /// Send the staged messages as one turn and return the reply (`send()` / `parse()`).
    func send(_ messages: [ThreadMessage] = [], overrides: TurnOverrides) async throws -> BetaMessage {
        try state.startTurn(messages)
        defer { state.endTurn() }
        let message = try await createWithRecovery(overrides)
        try state.recordReply(message)
        return message
    }

    /// Open the turn's stream. The turn stays in flight until `finishStream` is called.
    func openStream(_ messages: [ThreadMessage] = [], overrides: TurnOverrides) async throws -> Stream<BetaRawMessageStreamEvent> {
        try state.startTurn(messages)
        do {
            while true {
                let arguments = try state.createArguments(overrides, stream: true)
                do {
                    return try await sendCreateStreaming(client, arguments)
                } catch let error as APIStatusError {
                    if !state.recoversFrom(error) { throw error }
                }
            }
        } catch {
            state.endTurn()
            throw error
        }
    }

    private func createWithRecovery(_ overrides: TurnOverrides) async throws -> BetaMessage {
        while true {
            let arguments = try state.createArguments(overrides, stream: false)
            do {
                return try await sendCreate(client, arguments)
            } catch let error as APIStatusError {
                if !state.recoversFrom(error) { throw error }
            }
        }
    }
}

/// Splits a turn's `create()` arguments into the request body and the header params, as the generated
/// `beta.messages.create` does.
private func requestParts(_ arguments: CreateArguments, stream: Bool) -> (body: ParamsBuilder, headers: Headers, model: String, maxTokens: Int) {
    var body = ParamsBuilder()
    var betas: [String]?
    var userProfileID: String?
    var workspaceID: String?
    for (key, value) in arguments.fields.sorted(by: { $0.key < $1.key }) {
        switch key {
        case "betas": betas = value.arrayValue?.compactMap(\.stringValue)
        case "user_profile_id": userProfileID = value.stringValue
        case "workspace_id": workspaceID = value.stringValue
        default: body.put(key, value)
        }
    }
    if stream { body.put("stream", true) }
    let headers = mergeHeaders(
        stripNotGiven([
            ("anthropic-beta", joinHeaderValues(betas, extra: [], separator: ",")), ("anthropic-user-profile-id", userProfileID),
            ("anthropic-workspace-id", workspaceID),
        ]), arguments.options.extraHeaders)
    let model = arguments.fields["model"]?.stringValue ?? ""
    let maxTokens = arguments.fields["max_tokens"]?.intValue ?? 0
    return (body, headers, model, maxTokens)
}

/// `client.beta.messages.create(**arguments)`.
func sendCreate(_ client: BaseClient, _ arguments: CreateArguments) async throws -> BetaMessage {
    let (body, headers, model, maxTokens) = requestParts(arguments, stream: false)
    warnIfDeprecatedModel(model)
    warnIfThinkingEnabledDeprecated(model, thinking: arguments.fields["thinking"])
    var timeout = arguments.options.timeout
    if timeout == nil && client.timeout == DEFAULT_TIMEOUT && !client.timeoutOverridden {
        timeout = try client.calculateNonstreamingTimeout(maxTokens: maxTokens, maxNonstreamingTokens: MODEL_NONSTREAMING_TOKENS[model])
    }
    let options = try client.makeRequestOptions(
        method: "post", url: "/v1/messages", body: body, headers: headers, extraQuery: arguments.options.extraQuery,
        extraBody: arguments.options.extraBody, timeout: timeout, mode: .parsed, spanName: "anthropic.messages.create")
    return try await client.requestResponse(BetaMessage.self, options).parse()
}

/// `client.beta.messages.create(**arguments, stream=True)`.
func sendCreateStreaming(_ client: BaseClient, _ arguments: CreateArguments) async throws -> Stream<BetaRawMessageStreamEvent> {
    let (body, headers, model, _) = requestParts(arguments, stream: true)
    warnIfDeprecatedModel(model)
    warnIfThinkingEnabledDeprecated(model, thinking: arguments.fields["thinking"])
    let options = try client.makeRequestOptions(
        method: "post", url: "/v1/messages", body: body, headers: headers, extraQuery: arguments.options.extraQuery,
        extraBody: arguments.options.extraBody, timeout: arguments.options.timeout, mode: .parsed,
        spanName: "anthropic.messages.create")
    return try await client.requestStreamResponse(BetaRawMessageStreamEvent.self, options).parse()
}
