// Transformed from `anthropic.types.web_search_tool_result_block` (web_search_tool_result_block.py).

import Foundation

public struct WebSearchToolResultBlock: Codable, Hashable, Sendable {
    public var caller: WebSearchToolResultBlock.Caller?
    public var content: WebSearchToolResultBlockContent
    public var toolUseID: String
    public var type: String

    public init(caller: WebSearchToolResultBlock.Caller? = nil, content: WebSearchToolResultBlockContent, toolUseID: String, type: String = "web_search_tool_result") {
        self.caller = caller
        self.content = content
        self.toolUseID = toolUseID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case caller
        case content
        case toolUseID = "tool_use_id"
        case type
    }
}

extension WebSearchToolResultBlock {

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
}
