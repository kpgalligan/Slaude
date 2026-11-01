// Transformed from `anthropic.types.usage` (usage.py).

import Foundation

public struct Usage: Codable, Hashable, Sendable {
    /// Breakdown of cached tokens by TTL
    public var cacheCreation: CacheCreation?
    /// The number of input tokens used to create the cache entry.
    public var cacheCreationInputTokens: Int?
    /// The number of input tokens read from the cache.
    public var cacheReadInputTokens: Int?
    /// The geographic region where inference was performed for this request.
    public var inferenceGeo: String?
    /// The number of input tokens which were used.
    public var inputTokens: Int
    /// The number of output tokens which were used.
    public var outputTokens: Int
    /// Breakdown of output tokens by category.
    ///
    /// `output_tokens` remains the inclusive, authoritative total used for billing.
    /// This object provides a read-only decomposition for observability — for example,
    /// how many of the billed output tokens were spent on internal reasoning that may
    /// have been summarized before being returned to you.
    public var outputTokensDetails: OutputTokensDetails?
    /// The number of server tool requests.
    public var serverToolUse: ServerToolUsage?
    /// If the request used the priority, standard, or batch tier.
    public var serviceTier: ServiceTier?
    /// The inference speed mode used for this request.
    public var speed: Speed?

    public init(cacheCreation: CacheCreation? = nil, cacheCreationInputTokens: Int? = nil, cacheReadInputTokens: Int? = nil, inferenceGeo: String? = nil, inputTokens: Int, outputTokens: Int, outputTokensDetails: OutputTokensDetails? = nil, serverToolUse: ServerToolUsage? = nil, serviceTier: ServiceTier? = nil, speed: Speed? = nil) {
        self.cacheCreation = cacheCreation
        self.cacheCreationInputTokens = cacheCreationInputTokens
        self.cacheReadInputTokens = cacheReadInputTokens
        self.inferenceGeo = inferenceGeo
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.outputTokensDetails = outputTokensDetails
        self.serverToolUse = serverToolUse
        self.serviceTier = serviceTier
        self.speed = speed
    }

    enum CodingKeys: String, CodingKey {
        case cacheCreation = "cache_creation"
        case cacheCreationInputTokens = "cache_creation_input_tokens"
        case cacheReadInputTokens = "cache_read_input_tokens"
        case inferenceGeo = "inference_geo"
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
        case outputTokensDetails = "output_tokens_details"
        case serverToolUse = "server_tool_use"
        case serviceTier = "service_tier"
        case speed
    }

    public enum ServiceTier: OpenEnum, CaseIterable {
        case standard
        case priority
        case batch
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [ServiceTier] = [.standard, .priority, .batch]

        public init(rawValue: String) {
            switch rawValue {
            case "standard": self = .standard
            case "priority": self = .priority
            case "batch": self = .batch
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .standard: return "standard"
            case .priority: return "priority"
            case .batch: return "batch"
            case .unknown(let value): return value
            }
        }
    }

    public enum Speed: OpenEnum, CaseIterable {
        case standard
        case fast
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Speed] = [.standard, .fast]

        public init(rawValue: String) {
            switch rawValue {
            case "standard": self = .standard
            case "fast": self = .fast
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .standard: return "standard"
            case .fast: return "fast"
            case .unknown(let value): return value
            }
        }
    }
}
