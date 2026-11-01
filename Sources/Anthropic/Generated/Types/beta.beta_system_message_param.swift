// Transformed from `anthropic.types.beta.beta_system_message_param` (beta_system_message_param.py).

import Foundation

public struct BetaSystemMessageParam: Codable, Hashable, Sendable {
    public var role: String
    /// How long this system message's text stays in front of the model.
    ///
    /// `"never"` (the default) renders it on every request that includes it.
    /// `"next_user_message"` renders it only for the user turn it follows: once a later
    /// `role: "user"` message exists in `messages` the message stays in the array (send
    /// it unchanged) but is no longer shown to the model. Only permitted on
    /// `role: "system"` messages.
    public var clearAt: ClearAt??
    public var content: Content?
    /// Per-message output configuration on a role:"system" input message.
    ///
    /// Fields here apply per-turn; `format` remains top-level only. An empty `{}` is
    /// accepted on a message that carries content; a message with neither content nor
    /// output_config fields is rejected.
    public var outputConfig: BetaSystemMessageOutputConfigParam??

    public init(role: String = "system", clearAt: ClearAt?? = nil, content: Content? = nil, outputConfig: BetaSystemMessageOutputConfigParam?? = nil) {
        self.role = role
        self.clearAt = clearAt
        self.content = content
        self.outputConfig = outputConfig
    }

    enum CodingKeys: String, CodingKey {
        case role
        case clearAt = "clear_at"
        case content
        case outputConfig = "output_config"
    }

    public enum ClearAt: OpenEnum, CaseIterable {
        case nextUserMessage
        case never
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [ClearAt] = [.nextUserMessage, .never]

        public init(rawValue: String) {
            switch rawValue {
            case "next_user_message": self = .nextUserMessage
            case "never": self = .never
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .nextUserMessage: return "next_user_message"
            case .never: return "never"
            case .unknown(let value): return value
            }
        }
    }

    public indirect enum Content: Codable, Hashable, Sendable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
        case string(String)
        case contentBlocks([BetaSystemMessageParam.ContentBlock])
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(arrayLiteral elements: BetaSystemMessageParam.ContentBlock...) { self = .contentBlocks(elements) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? [BetaSystemMessageParam.ContentBlock](from: decoder) { self = .contentBlocks(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .contentBlocks(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}

extension BetaSystemMessageParam {

    public indirect enum ContentBlock: Codable, Hashable, Sendable {
        case text(BetaTextBlockParam)
        case toolAddition(BetaRequestToolAdditionBlockParam)
        case toolRemoval(BetaRequestToolRemovalBlockParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "text": self = .text(try BetaTextBlockParam(from: decoder))
            case "tool_addition": self = .toolAddition(try BetaRequestToolAdditionBlockParam(from: decoder))
            case "tool_removal": self = .toolRemoval(try BetaRequestToolRemovalBlockParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .text(let v): try v.encode(to: encoder)
            case .toolAddition(let v): try v.encode(to: encoder)
            case .toolRemoval(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
