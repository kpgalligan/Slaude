// Transformed from `anthropic.types.citations_delta` (citations_delta.py).

import Foundation

public struct CitationsDelta: Codable, Hashable, Sendable {
    public var citation: CitationsDelta.Citation
    public var type: String

    public init(citation: CitationsDelta.Citation, type: String = "citations_delta") {
        self.citation = citation
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case citation
        case type
    }
}

extension CitationsDelta {

    public indirect enum Citation: Codable, Hashable, Sendable {
        case charLocation(CitationCharLocation)
        case pageLocation(CitationPageLocation)
        case contentBlockLocation(CitationContentBlockLocation)
        case webSearchResultLocation(CitationsWebSearchResultLocation)
        case searchResultLocation(CitationsSearchResultLocation)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "char_location": self = .charLocation(try CitationCharLocation(from: decoder))
            case "page_location": self = .pageLocation(try CitationPageLocation(from: decoder))
            case "content_block_location": self = .contentBlockLocation(try CitationContentBlockLocation(from: decoder))
            case "web_search_result_location": self = .webSearchResultLocation(try CitationsWebSearchResultLocation(from: decoder))
            case "search_result_location": self = .searchResultLocation(try CitationsSearchResultLocation(from: decoder))
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
}
