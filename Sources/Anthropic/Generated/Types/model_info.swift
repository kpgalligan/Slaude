// Transformed from `anthropic.types.model_info` (model_info.py).

import Foundation

public struct ModelInfo: Codable, Hashable, Sendable {
    /// Unique model identifier.
    public var id: String
    /// Object mapping capability names to their support details.
    ///
    /// Keys are always present for all known capabilities.
    public var capabilities: ModelCapabilities?
    /// RFC 3339 datetime string representing the time at which the model was released.
    ///
    /// May be set to an epoch value if the release date is unknown.
    public var createdAt: Date
    /// RFC 3339 datetime string representing the time of the model's most recent
    /// deprecation. Populated for `deprecated` and `retired` models; `null` while the
    /// model is `active`.
    public var deprecatedAt: Date?
    /// A human-readable name for the model.
    public var displayName: String
    /// The model's current lifecycle stage.
    ///
    /// - `active`: The model is available for use, open to new adopters, and not
    ///   scheduled for retirement.
    /// - `deprecated`: The model remains callable for organizations with existing
    ///   access, but is headed for retirement and closed to new adopters.
    /// - `retired`: The model is no longer available for use; inference requests naming
    ///   it fail. It remains in the catalogue as the historical record of its
    ///   retirement.
    public var lifecycle: Lifecycle
    /// The model line this model belongs to, such as `opus` for both Claude Opus 4.5
    /// and Claude Opus 4.6. More lines may be added. `null` when the model belongs to
    /// no line; do not infer a line from the `id`.
    public var line: ModelLine?
    /// Maximum input context window size in tokens for this model.
    public var maxInputTokens: Int?
    /// Maximum value for the `max_tokens` parameter when using this model.
    public var maxTokens: Int?
    /// RFC 3339 datetime string representing the model's currently scheduled retirement
    /// date. The schedule can be revised until retirement occurs; `null` while the
    /// model is `active` or while no retirement is scheduled. A past date on a
    /// `deprecated` model means retirement is overdue, not that it has occurred:
    /// `lifecycle` is the retirement signal.
    public var retiresAt: Date?
    /// Object type.
    ///
    /// For Models, this is always `"model"`.
    public var type: String

    public init(id: String, capabilities: ModelCapabilities? = nil, createdAt: Date, deprecatedAt: Date? = nil, displayName: String, lifecycle: Lifecycle, line: ModelLine? = nil, maxInputTokens: Int? = nil, maxTokens: Int? = nil, retiresAt: Date? = nil, type: String = "model") {
        self.id = id
        self.capabilities = capabilities
        self.createdAt = createdAt
        self.deprecatedAt = deprecatedAt
        self.displayName = displayName
        self.lifecycle = lifecycle
        self.line = line
        self.maxInputTokens = maxInputTokens
        self.maxTokens = maxTokens
        self.retiresAt = retiresAt
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case capabilities
        case createdAt = "created_at"
        case deprecatedAt = "deprecated_at"
        case displayName = "display_name"
        case lifecycle
        case line
        case maxInputTokens = "max_input_tokens"
        case maxTokens = "max_tokens"
        case retiresAt = "retires_at"
        case type
    }

    public enum Lifecycle: OpenEnum, CaseIterable {
        case active
        case deprecated
        case retired
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Lifecycle] = [.active, .deprecated, .retired]

        public init(rawValue: String) {
            switch rawValue {
            case "active": self = .active
            case "deprecated": self = .deprecated
            case "retired": self = .retired
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .active: return "active"
            case .deprecated: return "deprecated"
            case .retired: return "retired"
            case .unknown(let value): return value
            }
        }
    }
}
