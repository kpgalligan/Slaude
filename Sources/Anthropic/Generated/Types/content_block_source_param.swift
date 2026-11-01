// Transformed from `anthropic.types.content_block_source_param` (content_block_source_param.py).

import Foundation

public struct ContentBlockSourceParam: Codable, Hashable, Sendable {
    public var content: Content
    public var type: String

    public init(content: Content, type: String = "content") {
        self.content = content
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case type
    }

    public indirect enum Content: Codable, Hashable, Sendable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
        case string(String)
        case contentBlockSourceContentParams([ContentBlockSourceContentParam])
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(arrayLiteral elements: ContentBlockSourceContentParam...) { self = .contentBlockSourceContentParams(elements) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? [ContentBlockSourceContentParam](from: decoder) { self = .contentBlockSourceContentParams(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .contentBlockSourceContentParams(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
