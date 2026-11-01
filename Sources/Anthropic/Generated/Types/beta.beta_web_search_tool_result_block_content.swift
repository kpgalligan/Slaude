// Transformed from `anthropic.types.beta.beta_web_search_tool_result_block_content` (beta_web_search_tool_result_block_content.py).

import Foundation

public indirect enum BetaWebSearchToolResultBlockContent: Codable, Hashable, Sendable, ExpressibleByArrayLiteral {
    case betaWebSearchToolResultError(BetaWebSearchToolResultError)
    case betaWebSearchResultBlocks([BetaWebSearchResultBlock])
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(arrayLiteral elements: BetaWebSearchResultBlock...) { self = .betaWebSearchResultBlocks(elements) }

    public init(from decoder: Decoder) throws {
        if let v = try? BetaWebSearchToolResultError(from: decoder) { self = .betaWebSearchToolResultError(v); return }
        if let v = try? [BetaWebSearchResultBlock](from: decoder) { self = .betaWebSearchResultBlocks(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .betaWebSearchToolResultError(let v): try v.encode(to: encoder)
        case .betaWebSearchResultBlocks(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
