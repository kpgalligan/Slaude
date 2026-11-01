// Transformed from `anthropic.types.web_search_tool_result_block_content` (web_search_tool_result_block_content.py).

import Foundation

public indirect enum WebSearchToolResultBlockContent: Codable, Hashable, Sendable, ExpressibleByArrayLiteral {
    case webSearchToolResultError(WebSearchToolResultError)
    case webSearchResultBlocks([WebSearchResultBlock])
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(arrayLiteral elements: WebSearchResultBlock...) { self = .webSearchResultBlocks(elements) }

    public init(from decoder: Decoder) throws {
        if let v = try? WebSearchToolResultError(from: decoder) { self = .webSearchToolResultError(v); return }
        if let v = try? [WebSearchResultBlock](from: decoder) { self = .webSearchResultBlocks(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .webSearchToolResultError(let v): try v.encode(to: encoder)
        case .webSearchResultBlocks(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
