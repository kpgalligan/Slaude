// Transformed from `anthropic.types.beta.beta_thinking_dropped_input_transformation` (beta_thinking_dropped_input_transformation.py).

import Foundation

public struct BetaThinkingDroppedInputTransformation: Codable, Hashable, Sendable {
    /// Where the removed block was in your request, as `messages.{i}.content.{j}`: `i`
    /// indexes the `messages` array you sent and `j` that message's `content` array —
    /// the same form error messages use.
    public var path: String
    /// Which binding check removed the block: `model_binding_mismatch` — it was created
    /// by a model whose reasoning the requested model may not read;
    /// `prefix_binding_mismatch` — the conversation before it differs from the
    /// conversation it was created in (the rest of that turn's consecutive thinking
    /// blocks are removed with it, each with this reason);
    /// `organization_binding_mismatch` — it was created under a different organization
    /// (an Anthropic organization, AWS account or Google Cloud project) and this
    /// organization is not one of its additional organizations;
    /// `end_user_binding_mismatch` — it was created for a different end user, or was
    /// removed by the consumer-organization binding. A block that would fail several
    /// checks reports one reason, in this order of precedence:
    /// `organization_binding_mismatch`, `end_user_binding_mismatch`,
    /// `model_binding_mismatch`, `prefix_binding_mismatch`.
    public var reason: Reason
    /// Always `thinking_dropped` for this entry type.
    public var type: String

    public init(path: String, reason: Reason, type: String = "thinking_dropped") {
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
