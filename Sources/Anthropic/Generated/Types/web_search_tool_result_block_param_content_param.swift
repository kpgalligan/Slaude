// Transformed from `anthropic.types.web_search_tool_result_block_param_content_param` (web_search_tool_result_block_param_content_param.py).

import Foundation

public indirect enum WebSearchToolResultBlockParamContentParam: Codable, Hashable, Sendable, ExpressibleByArrayLiteral {
    case webSearchResultBlockParams([WebSearchResultBlockParam])
    case webSearchToolRequestErrorParam(WebSearchToolRequestErrorParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(arrayLiteral elements: WebSearchResultBlockParam...) { self = .webSearchResultBlockParams(elements) }

    public init(from decoder: Decoder) throws {
        if let v = try? [WebSearchResultBlockParam](from: decoder) { self = .webSearchResultBlockParams(v); return }
        if let v = try? WebSearchToolRequestErrorParam(from: decoder) { self = .webSearchToolRequestErrorParam(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .webSearchResultBlockParams(let v): try v.encode(to: encoder)
        case .webSearchToolRequestErrorParam(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
