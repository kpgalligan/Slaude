// Transformed from `anthropic.types.message_create_params_container_param` (message_create_params_container_param.py).

import Foundation

public indirect enum MessageCreateParamsContainerParam: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
    case containerParams(ContainerParams)
    case string(String)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(stringLiteral value: String) { self = .string(value) }

    public init(from decoder: Decoder) throws {
        if let v = try? ContainerParams(from: decoder) { self = .containerParams(v); return }
        if let v = try? String(from: decoder) { self = .string(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .containerParams(let v): try v.encode(to: encoder)
        case .string(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
