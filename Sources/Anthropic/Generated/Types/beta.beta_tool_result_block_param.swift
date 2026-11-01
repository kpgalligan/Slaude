// Transformed from `anthropic.types.beta.beta_tool_result_block_param` (beta_tool_result_block_param.py).

import Foundation

public struct BetaToolResultBlockParam: Codable, Hashable, Sendable {
    public var toolUseID: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??
    public var content: Content_?
    public var isError: Bool?
    /// For a toolset member tool_result, the toolset family of the paired tool_use.
    public var toolsetName: String??

    public init(toolUseID: String, type: String = "tool_result", cacheControl: BetaCacheControlEphemeralParam?? = nil, content: Content_? = nil, isError: Bool? = nil, toolsetName: String?? = nil) {
        self.toolUseID = toolUseID
        self.type = type
        self.cacheControl = cacheControl
        self.content = content
        self.isError = isError
        self.toolsetName = toolsetName
    }

    enum CodingKeys: String, CodingKey {
        case toolUseID = "tool_use_id"
        case type
        case cacheControl = "cache_control"
        case content
        case isError = "is_error"
        case toolsetName = "toolset_name"
    }

    public indirect enum Content_: Codable, Hashable, Sendable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
        case string(String)
        case contents([BetaToolResultBlockParam.Content])
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(arrayLiteral elements: BetaToolResultBlockParam.Content...) { self = .contents(elements) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? [BetaToolResultBlockParam.Content](from: decoder) { self = .contents(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .contents(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}

extension BetaToolResultBlockParam {

    public indirect enum Content: Codable, Hashable, Sendable {
        case text(BetaTextBlockParam)
        case image(BetaImageBlockParam)
        case searchResult(BetaSearchResultBlockParam)
        case document(BetaRequestDocumentBlockParam)
        case toolReference(BetaToolReferenceBlockParam)
        case browserState(BetaBrowserStateBlockParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "text": self = .text(try BetaTextBlockParam(from: decoder))
            case "image": self = .image(try BetaImageBlockParam(from: decoder))
            case "search_result": self = .searchResult(try BetaSearchResultBlockParam(from: decoder))
            case "document": self = .document(try BetaRequestDocumentBlockParam(from: decoder))
            case "tool_reference": self = .toolReference(try BetaToolReferenceBlockParam(from: decoder))
            case "browser_state": self = .browserState(try BetaBrowserStateBlockParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .text(let v): try v.encode(to: encoder)
            case .image(let v): try v.encode(to: encoder)
            case .searchResult(let v): try v.encode(to: encoder)
            case .document(let v): try v.encode(to: encoder)
            case .toolReference(let v): try v.encode(to: encoder)
            case .browserState(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
