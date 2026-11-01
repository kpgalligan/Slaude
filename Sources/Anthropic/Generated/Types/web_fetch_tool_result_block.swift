// Transformed from `anthropic.types.web_fetch_tool_result_block` (web_fetch_tool_result_block.py).

import Foundation

public struct WebFetchToolResultBlock: Codable, Hashable, Sendable {
    public var caller: WebFetchToolResultBlock.Caller?
    public var content: WebFetchToolResultBlock.Content
    public var toolUseId: String
    public var type: String

    public init(caller: WebFetchToolResultBlock.Caller? = nil, content: WebFetchToolResultBlock.Content, toolUseId: String, type: String = "web_fetch_tool_result") {
        self.caller = caller
        self.content = content
        self.toolUseId = toolUseId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case caller
        case content
        case toolUseId = "tool_use_id"
        case type
    }
}

extension WebFetchToolResultBlock {

    public indirect enum Caller: Codable, Hashable, Sendable {
        case direct(DirectCaller)
        case codeExecution20250825(ServerToolCaller)
        case codeExecution20260120(ServerToolCaller20260120)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "direct": self = .direct(try DirectCaller(from: decoder))
            case "code_execution_20250825": self = .codeExecution20250825(try ServerToolCaller(from: decoder))
            case "code_execution_20260120": self = .codeExecution20260120(try ServerToolCaller20260120(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .direct(let v): try v.encode(to: encoder)
            case .codeExecution20250825(let v): try v.encode(to: encoder)
            case .codeExecution20260120(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

    public indirect enum Content: Codable, Hashable, Sendable {
        case webFetchToolResultError(WebFetchToolResultErrorBlock)
        case webFetchResult(WebFetchBlock)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "web_fetch_tool_result_error": self = .webFetchToolResultError(try WebFetchToolResultErrorBlock(from: decoder))
            case "web_fetch_result": self = .webFetchResult(try WebFetchBlock(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .webFetchToolResultError(let v): try v.encode(to: encoder)
            case .webFetchResult(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
