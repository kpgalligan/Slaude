// Transformed from `anthropic.types.beta.beta_mcp_tool_result_block` (beta_mcp_tool_result_block.py).

import Foundation

public struct BetaMCPToolResultBlock: Codable, Hashable, Sendable {
    public var content: Content
    public var isError: Bool
    public var toolUseID: String
    public var type: String

    public init(content: Content, isError: Bool, toolUseID: String, type: String = "mcp_tool_result") {
        self.content = content
        self.isError = isError
        self.toolUseID = toolUseID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case isError = "is_error"
        case toolUseID = "tool_use_id"
        case type
    }

    public indirect enum Content: Codable, Hashable, Sendable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
        case string(String)
        case betaTextBlocks([BetaTextBlock])
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(arrayLiteral elements: BetaTextBlock...) { self = .betaTextBlocks(elements) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? [BetaTextBlock](from: decoder) { self = .betaTextBlocks(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .betaTextBlocks(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
