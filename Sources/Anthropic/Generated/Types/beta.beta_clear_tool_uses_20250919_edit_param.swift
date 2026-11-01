// Transformed from `anthropic.types.beta.beta_clear_tool_uses_20250919_edit_param` (beta_clear_tool_uses_20250919_edit_param.py).

import Foundation

public struct BetaClearToolUses20250919EditParam: Codable, Hashable, Sendable {
    public var type: String
    /// Minimum number of tokens that must be cleared when triggered.
    ///
    /// Context will only be modified if at least this many tokens can be removed.
    public var clearAtLeast: BetaInputTokensClearAtLeastParam??
    /// Whether to clear all tool inputs (bool) or specific tool inputs to clear (list)
    public var clearToolInputs: ClearToolInputs??
    /// Tool names whose uses are preserved from clearing
    public var excludeTools: [String]??
    /// Number of tool uses to retain in the conversation
    public var keep: BetaToolUsesKeepParam?
    /// Condition that triggers the context management strategy
    public var trigger: BetaClearToolUses20250919EditParam.Trigger?

    public init(type: String = "clear_tool_uses_20250919", clearAtLeast: BetaInputTokensClearAtLeastParam?? = nil, clearToolInputs: ClearToolInputs?? = nil, excludeTools: [String]?? = nil, keep: BetaToolUsesKeepParam? = nil, trigger: BetaClearToolUses20250919EditParam.Trigger? = nil) {
        self.type = type
        self.clearAtLeast = clearAtLeast
        self.clearToolInputs = clearToolInputs
        self.excludeTools = excludeTools
        self.keep = keep
        self.trigger = trigger
    }

    enum CodingKeys: String, CodingKey {
        case type
        case clearAtLeast = "clear_at_least"
        case clearToolInputs = "clear_tool_inputs"
        case excludeTools = "exclude_tools"
        case keep
        case trigger
    }

    public indirect enum ClearToolInputs: Codable, Hashable, Sendable, ExpressibleByArrayLiteral {
        case bool(Bool)
        case strings([String])
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(arrayLiteral elements: String...) { self = .strings(elements) }

        public init(from decoder: Decoder) throws {
            if let v = try? Bool(from: decoder) { self = .bool(v); return }
            if let v = try? [String](from: decoder) { self = .strings(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .bool(let v): try v.encode(to: encoder)
            case .strings(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}

extension BetaClearToolUses20250919EditParam {

    public indirect enum Trigger: Codable, Hashable, Sendable {
        case inputTokens(BetaInputTokensTriggerParam)
        case toolUses(BetaToolUsesTriggerParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "input_tokens": self = .inputTokens(try BetaInputTokensTriggerParam(from: decoder))
            case "tool_uses": self = .toolUses(try BetaToolUsesTriggerParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .inputTokens(let v): try v.encode(to: encoder)
            case .toolUses(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
