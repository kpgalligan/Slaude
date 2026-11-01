// Transformed from `anthropic.types.text_citation_param` (text_citation_param.py).

import Foundation

public indirect enum TextCitationParam: Codable, Hashable, Sendable {
    case charLocation(CitationCharLocationParam)
    case pageLocation(CitationPageLocationParam)
    case contentBlockLocation(CitationContentBlockLocationParam)
    case webSearchResultLocation(CitationWebSearchResultLocationParam)
    case searchResultLocation(CitationSearchResultLocationParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "char_location": self = .charLocation(try CitationCharLocationParam(from: decoder))
        case "page_location": self = .pageLocation(try CitationPageLocationParam(from: decoder))
        case "content_block_location": self = .contentBlockLocation(try CitationContentBlockLocationParam(from: decoder))
        case "web_search_result_location": self = .webSearchResultLocation(try CitationWebSearchResultLocationParam(from: decoder))
        case "search_result_location": self = .searchResultLocation(try CitationSearchResultLocationParam(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .charLocation(let v): try v.encode(to: encoder)
        case .pageLocation(let v): try v.encode(to: encoder)
        case .contentBlockLocation(let v): try v.encode(to: encoder)
        case .webSearchResultLocation(let v): try v.encode(to: encoder)
        case .searchResultLocation(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
