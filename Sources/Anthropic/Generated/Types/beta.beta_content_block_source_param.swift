// Transformed from `anthropic.types.beta.beta_content_block_source_param` (beta_content_block_source_param.py).

import Foundation

public struct BetaContentBlockSourceParam: Codable, Hashable, Sendable {
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
        case betaContentBlockSourceContentParams([BetaContentBlockSourceContentParam])
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(arrayLiteral elements: BetaContentBlockSourceContentParam...) { self = .betaContentBlockSourceContentParams(elements) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? [BetaContentBlockSourceContentParam](from: decoder) { self = .betaContentBlockSourceContentParams(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .betaContentBlockSourceContentParams(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
