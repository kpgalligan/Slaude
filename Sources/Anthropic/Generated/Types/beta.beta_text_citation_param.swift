// Transformed from `anthropic.types.beta.beta_text_citation_param` (beta_text_citation_param.py).

import Foundation

public indirect enum BetaTextCitationParam: Codable, Hashable, Sendable {
    case charLocation(BetaCitationCharLocationParam)
    case pageLocation(BetaCitationPageLocationParam)
    case contentBlockLocation(BetaCitationContentBlockLocationParam)
    case webSearchResultLocation(BetaCitationWebSearchResultLocationParam)
    case searchResultLocation(BetaCitationSearchResultLocationParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "char_location": self = .charLocation(try BetaCitationCharLocationParam(from: decoder))
        case "page_location": self = .pageLocation(try BetaCitationPageLocationParam(from: decoder))
        case "content_block_location": self = .contentBlockLocation(try BetaCitationContentBlockLocationParam(from: decoder))
        case "web_search_result_location": self = .webSearchResultLocation(try BetaCitationWebSearchResultLocationParam(from: decoder))
        case "search_result_location": self = .searchResultLocation(try BetaCitationSearchResultLocationParam(from: decoder))
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
