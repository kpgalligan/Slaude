// Transformed from `anthropic.types.message_param` (message_param.py).

import Foundation

public indirect enum MessageParam: Codable, Hashable, Sendable {
    case userMessageParam(UserMessageParam)
    case assistantMessageParam(AssistantMessageParam)
    case systemMessageParam(SystemMessageParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        if let v = try? UserMessageParam(from: decoder) { self = .userMessageParam(v); return }
        if let v = try? AssistantMessageParam(from: decoder) { self = .assistantMessageParam(v); return }
        if let v = try? SystemMessageParam(from: decoder) { self = .systemMessageParam(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .userMessageParam(let v): try v.encode(to: encoder)
        case .assistantMessageParam(let v): try v.encode(to: encoder)
        case .systemMessageParam(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
