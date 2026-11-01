// Transformed from `anthropic.types.beta.beta_clear_thinking_20251015_edit_param` (beta_clear_thinking_20251015_edit_param.py).

import Foundation

public struct BetaClearThinking20251015EditParam: Codable, Hashable, Sendable {
    public var type: String
    /// Number of most recent assistant turns to keep thinking blocks for.
    ///
    /// Older turns will have their thinking blocks removed.
    public var keep: BetaClearThinking20251015EditParam.Keep?

    public init(type: String = "clear_thinking_20251015", keep: BetaClearThinking20251015EditParam.Keep? = nil) {
        self.type = type
        self.keep = keep
    }

    enum CodingKeys: String, CodingKey {
        case type
        case keep
    }
}

extension BetaClearThinking20251015EditParam {

    public indirect enum Keep: Codable, Hashable, Sendable {
        case betaThinkingTurnsParam(BetaThinkingTurnsParam)
        case betaAllThinkingTurnsParam(BetaAllThinkingTurnsParam)
        case all(String)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            if _Coding.constantsMatch(decoder, ["type": "thinking_turns"]), let v = try? BetaThinkingTurnsParam(from: decoder) { self = .betaThinkingTurnsParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "all"]), let v = try? BetaAllThinkingTurnsParam(from: decoder) { self = .betaAllThinkingTurnsParam(v); return }
            if let v = try? String(from: decoder) { self = .all(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .betaThinkingTurnsParam(let v): try v.encode(to: encoder)
            case .betaAllThinkingTurnsParam(let v): try v.encode(to: encoder)
            case .all(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
