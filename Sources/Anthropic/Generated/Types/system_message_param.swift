// Transformed from `anthropic.types.system_message_param` (system_message_param.py).

import Foundation

public struct SystemMessageParam: Codable, Hashable, Sendable {
    public var content: Content
    public var role: String

    public init(content: Content, role: String = "system") {
        self.content = content
        self.role = role
    }

    enum CodingKeys: String, CodingKey {
        case content
        case role
    }

    public indirect enum Content: Codable, Hashable, Sendable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
        case string(String)
        case textBlockParams([TextBlockParam])
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(arrayLiteral elements: TextBlockParam...) { self = .textBlockParams(elements) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? [TextBlockParam](from: decoder) { self = .textBlockParams(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .textBlockParams(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
