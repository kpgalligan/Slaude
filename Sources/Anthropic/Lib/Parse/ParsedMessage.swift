import Foundation

/// A `Message` whose text blocks were parsed into a structured output type
/// (`types/parsed_message.ParsedMessage`).
///
/// Every `Message` property is available directly (`parsed.content`, `parsed.usage`, ...). The
/// parsed values are kept beside the content, keyed by content block index, and are never encoded:
/// encoding a `ParsedMessage` produces the plain message, so its content can be sent back as
/// request params (the API rejects `parsed_output`).
///
/// Streams and messages created without an output format use `ParsedMessage<Never>`.
@dynamicMemberLookup
public struct ParsedMessage<Output: Sendable>: Sendable, Encodable {
    /// The message as the API returned it.
    public var message: Message
    /// The parsed output of each `text` block, keyed by its index in `content`.
    public var parsedOutputs: [Int: Output]

    public init(message: Message, parsedOutputs: [Int: Output] = [:]) {
        self.message = message
        self.parsedOutputs = parsedOutputs
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Message, T>) -> T {
        get { message[keyPath: keyPath] }
        set { message[keyPath: keyPath] = newValue }
    }

    /// The parsed output of the first text block that has one (`ParsedMessage.parsed_output`).
    public var parsedOutput: Output? {
        for (i, block) in message.content.enumerated() {
            if case .text = block, let output = parsedOutputs[i] { return output }
        }
        return nil
    }

    /// The parsed output of the text block at `index` (`content[index].parsed_output`).
    public func parsedOutput(at index: Int) -> Output? { parsedOutputs[index] }

    public func encode(to encoder: Encoder) throws { try message.encode(to: encoder) }
}

extension ParsedMessage: Equatable where Output: Equatable {}
extension ParsedMessage: Hashable where Output: Hashable {}

/// A `BetaMessage` whose text blocks were parsed into a structured output type
/// (`types/beta/parsed_beta_message.ParsedBetaMessage`). See `ParsedMessage`.
@dynamicMemberLookup
public struct ParsedBetaMessage<Output: Sendable>: Sendable, Encodable {
    public var message: BetaMessage
    public var parsedOutputs: [Int: Output]

    public init(message: BetaMessage, parsedOutputs: [Int: Output] = [:]) {
        self.message = message
        self.parsedOutputs = parsedOutputs
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<BetaMessage, T>) -> T {
        get { message[keyPath: keyPath] }
        set { message[keyPath: keyPath] = newValue }
    }

    public var parsedOutput: Output? {
        for (i, block) in message.content.enumerated() {
            if case .text = block, let output = parsedOutputs[i] { return output }
        }
        return nil
    }

    public func parsedOutput(at index: Int) -> Output? { parsedOutputs[index] }

    public func encode(to encoder: Encoder) throws { try message.encode(to: encoder) }
}

extension ParsedBetaMessage: Equatable where Output: Equatable {}
extension ParsedBetaMessage: Hashable where Output: Hashable {}

/// Parses a reply's text into `Output`; `nil` when the call had no output format.
public typealias OutputParser<Output> = @Sendable (String) throws -> Output

/// Port of `lib/_parse/_response.parse_response`.
public func parseResponse<Output>(_ response: Message, parser: OutputParser<Output>?) throws -> ParsedMessage<Output> {
    var outputs: [Int: Output] = [:]
    if let parser {
        for (i, block) in response.content.enumerated() {
            if case .text(let t) = block { outputs[i] = try parser(t.text) }
        }
    }
    return ParsedMessage(message: response, parsedOutputs: outputs)
}

/// Port of `lib/_parse/_response.parse_beta_response`.
public func parseBetaResponse<Output>(_ response: BetaMessage, parser: OutputParser<Output>?) throws -> ParsedBetaMessage<Output> {
    var outputs: [Int: Output] = [:]
    if let parser {
        for (i, block) in response.content.enumerated() {
            if case .text(let t) = block { outputs[i] = try parser(t.text) }
        }
    }
    return ParsedBetaMessage(message: response, parsedOutputs: outputs)
}

func structuredOutputParser<Output: StructuredOutput>(_ type: Output.Type) -> OutputParser<Output> {
    { text in try parseStructuredOutput(text, as: Output.self) }
}
