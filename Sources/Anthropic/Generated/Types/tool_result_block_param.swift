// Transformed from `anthropic.types.tool_result_block_param` (tool_result_block_param.py).

import Foundation

public struct ToolResultBlockParam: Codable, Hashable, Sendable {
    public var toolUseId: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??
    public var content: Content_?
    public var isError: Bool?
    /// For a toolset member tool_result, the toolset family of the paired tool_use.
    public var toolsetName: String??

    public init(toolUseId: String, type: String = "tool_result", cacheControl: CacheControlEphemeralParam?? = nil, content: Content_? = nil, isError: Bool? = nil, toolsetName: String?? = nil) {
        self.toolUseId = toolUseId
        self.type = type
        self.cacheControl = cacheControl
        self.content = content
        self.isError = isError
        self.toolsetName = toolsetName
    }

    enum CodingKeys: String, CodingKey {
        case toolUseId = "tool_use_id"
        case type
        case cacheControl = "cache_control"
        case content
        case isError = "is_error"
        case toolsetName = "toolset_name"
    }

    public indirect enum Content_: Codable, Hashable, Sendable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
        case string(String)
        case contents([ToolResultBlockParam.Content])
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(arrayLiteral elements: ToolResultBlockParam.Content...) { self = .contents(elements) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? [ToolResultBlockParam.Content](from: decoder) { self = .contents(v); return }
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

extension ToolResultBlockParam {

    public indirect enum Content: Codable, Hashable, Sendable {
        case text(TextBlockParam)
        case image(ImageBlockParam)
        case searchResult(SearchResultBlockParam)
        case document(DocumentBlockParam)
        case toolReference(ToolReferenceBlockParam)
        case browserState(BrowserStateBlockParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "text": self = .text(try TextBlockParam(from: decoder))
            case "image": self = .image(try ImageBlockParam(from: decoder))
            case "search_result": self = .searchResult(try SearchResultBlockParam(from: decoder))
            case "document": self = .document(try DocumentBlockParam(from: decoder))
            case "tool_reference": self = .toolReference(try ToolReferenceBlockParam(from: decoder))
            case "browser_state": self = .browserState(try BrowserStateBlockParam(from: decoder))
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
