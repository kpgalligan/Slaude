// Transformed from `anthropic.types.beta.beta_thinking_mismatch_allowed_input_transformation` (beta_thinking_mismatch_allowed_input_transformation.py).

import Foundation

public struct BetaThinkingMismatchAllowedInputTransformation: Codable, Hashable, Sendable {
    /// Where the block is in your request, as `messages.{i}.content.{j}`: `i` indexes
    /// the `messages` array you sent and `j` that message's `content` array — the same
    /// form error messages use.
    public var path: String
    /// Which binding check the block failed; the block was shown to the model all the
    /// same. Always `prefix_binding_mismatch` today — the conversation before the block
    /// differs from the conversation it was created in, or the block carries no record
    /// of one on a model that requires it. Were the check enforced for this request,
    /// the block would have been removed or the request rejected
    /// (`thinking.block_binding.prefix_mismatch_behavior`). A removal also takes the
    /// rest of that turn's consecutive thinking blocks, whereas here each block is
    /// checked on its own, so `thinking_mismatch_allowed` entries are a lower bound on
    /// what enforcement would remove.
    public var reason: Reason
    /// Always `thinking_mismatch_allowed` for this entry type.
    public var type: String

    public init(path: String, reason: Reason, type: String = "thinking_mismatch_allowed") {
        self.path = path
        self.reason = reason
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case path
        case reason
        case type
    }

    public enum Reason: OpenEnum, CaseIterable {
        case modelBindingMismatch
        case prefixBindingMismatch
        case organizationBindingMismatch
        case endUserBindingMismatch
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Reason] = [.modelBindingMismatch, .prefixBindingMismatch, .organizationBindingMismatch, .endUserBindingMismatch]

        public init(rawValue: String) {
            switch rawValue {
            case "model_binding_mismatch": self = .modelBindingMismatch
            case "prefix_binding_mismatch": self = .prefixBindingMismatch
            case "organization_binding_mismatch": self = .organizationBindingMismatch
            case "end_user_binding_mismatch": self = .endUserBindingMismatch
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .modelBindingMismatch: return "model_binding_mismatch"
            case .prefixBindingMismatch: return "prefix_binding_mismatch"
            case .organizationBindingMismatch: return "organization_binding_mismatch"
            case .endUserBindingMismatch: return "end_user_binding_mismatch"
            case .unknown(let value): return value
            }
        }
    }
}
