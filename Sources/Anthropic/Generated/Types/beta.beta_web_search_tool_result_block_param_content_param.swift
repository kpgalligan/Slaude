// Transformed from `anthropic.types.beta.beta_web_search_tool_result_block_param_content_param` (beta_web_search_tool_result_block_param_content_param.py).

import Foundation

public indirect enum BetaWebSearchToolResultBlockParamContentParam: Codable, Hashable, Sendable, ExpressibleByArrayLiteral {
    case betaWebSearchResultBlockParams([BetaWebSearchResultBlockParam])
    case betaWebSearchToolRequestErrorParam(BetaWebSearchToolRequestErrorParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(arrayLiteral elements: BetaWebSearchResultBlockParam...) { self = .betaWebSearchResultBlockParams(elements) }

    public init(from decoder: Decoder) throws {
        if let v = try? [BetaWebSearchResultBlockParam](from: decoder) { self = .betaWebSearchResultBlockParams(v); return }
        if _Coding.constantsMatch(decoder, ["type": "web_search_tool_result_error"]), let v = try? BetaWebSearchToolRequestErrorParam(from: decoder) { self = .betaWebSearchToolRequestErrorParam(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .betaWebSearchResultBlockParams(let v): try v.encode(to: encoder)
        case .betaWebSearchToolRequestErrorParam(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
