// Transformed from `anthropic.types.beta.beta_web_search_tool_result_block` (beta_web_search_tool_result_block.py).

import Foundation

public struct BetaWebSearchToolResultBlock: Codable, Hashable, Sendable {
    public var content: BetaWebSearchToolResultBlockContent
    public var toolUseId: String
    public var type: String
    public var caller: BetaWebSearchToolResultBlock.Caller?

    public init(content: BetaWebSearchToolResultBlockContent, toolUseId: String, type: String = "web_search_tool_result", caller: BetaWebSearchToolResultBlock.Caller? = nil) {
        self.content = content
        self.toolUseId = toolUseId
        self.type = type
        self.caller = caller
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseId = "tool_use_id"
        case type
        case caller
    }
}

extension BetaWebSearchToolResultBlock {

    public indirect enum Caller: Codable, Hashable, Sendable {
        case direct(BetaDirectCaller)
        case codeExecution20250825(BetaServerToolCaller)
        case codeExecution20260120(BetaServerToolCaller20260120)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "direct": self = .direct(try BetaDirectCaller(from: decoder))
            case "code_execution_20250825": self = .codeExecution20250825(try BetaServerToolCaller(from: decoder))
            case "code_execution_20260120": self = .codeExecution20260120(try BetaServerToolCaller20260120(from: decoder))
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
