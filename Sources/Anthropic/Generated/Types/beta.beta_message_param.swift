// Transformed from `anthropic.types.beta.beta_message_param` (beta_message_param.py).

import Foundation

public indirect enum BetaMessageParam: Codable, Hashable, Sendable {
    case betaUserMessageParam(BetaUserMessageParam)
    case betaAssistantMessageParam(BetaAssistantMessageParam)
    case betaSystemMessageParam(BetaSystemMessageParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        if let v = try? BetaUserMessageParam(from: decoder) { self = .betaUserMessageParam(v); return }
        if let v = try? BetaAssistantMessageParam(from: decoder) { self = .betaAssistantMessageParam(v); return }
        if let v = try? BetaSystemMessageParam(from: decoder) { self = .betaSystemMessageParam(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .betaUserMessageParam(let v): try v.encode(to: encoder)
        case .betaAssistantMessageParam(let v): try v.encode(to: encoder)
        case .betaSystemMessageParam(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
