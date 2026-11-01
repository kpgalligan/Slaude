// Transformed from `anthropic.types.beta.beta_text_citation` (beta_text_citation.py).

import Foundation

public indirect enum BetaTextCitation: Codable, Hashable, Sendable {
    case charLocation(BetaCitationCharLocation)
    case pageLocation(BetaCitationPageLocation)
    case contentBlockLocation(BetaCitationContentBlockLocation)
    case webSearchResultLocation(BetaCitationsWebSearchResultLocation)
    case searchResultLocation(BetaCitationSearchResultLocation)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "char_location": self = .charLocation(try BetaCitationCharLocation(from: decoder))
        case "page_location": self = .pageLocation(try BetaCitationPageLocation(from: decoder))
        case "content_block_location": self = .contentBlockLocation(try BetaCitationContentBlockLocation(from: decoder))
        case "web_search_result_location": self = .webSearchResultLocation(try BetaCitationsWebSearchResultLocation(from: decoder))
        case "search_result_location": self = .searchResultLocation(try BetaCitationSearchResultLocation(from: decoder))
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
