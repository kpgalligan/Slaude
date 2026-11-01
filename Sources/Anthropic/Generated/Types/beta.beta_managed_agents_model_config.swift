// Transformed from `anthropic.types.beta.beta_managed_agents_model_config` (beta_managed_agents_model_config.py).

import Foundation

/// Model identifier and configuration.
public struct BetaManagedAgentsModelConfig: Codable, Hashable, Sendable {
    /// The model that will power your agent.
    ///
    /// See [models](https://docs.anthropic.com/en/docs/models-overview) for additional
    /// details and options.
    public var id: BetaManagedAgentsModel
    /// How hard Claude works on each inference call.
    ///
    /// One of `low`, `medium`, `high`, `xhigh`, `max`. Always present; resolved to the
    /// per-model default at save time when not supplied.
    public var effort: BetaManagedAgentsModelConfig.Effort?
    /// Geographic region for model inference.
    ///
    /// When unset, requests fall through to the workspace's default_inference_geo.
    public var inferenceGeo: String?
    /// Inference speed mode.
    ///
    /// `fast` provides significantly faster output token generation at premium pricing.
    /// Defaults to `standard`. Not all models support `fast`; invalid combinations are
    /// rejected at create time.
    public var speed: Speed?

    public init(id: BetaManagedAgentsModel, effort: BetaManagedAgentsModelConfig.Effort? = nil, inferenceGeo: String? = nil, speed: Speed? = nil) {
        self.id = id
        self.effort = effort
        self.inferenceGeo = inferenceGeo
        self.speed = speed
    }

    enum CodingKeys: String, CodingKey {
        case id
        case effort
        case inferenceGeo = "inference_geo"
        case speed
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

extension BetaManagedAgentsModelConfig {

    public indirect enum Effort: Codable, Hashable, Sendable {
        case low(BetaManagedAgentsEffortLow)
        case medium(BetaManagedAgentsEffortMedium)
        case high(BetaManagedAgentsEffortHigh)
        case xhigh(BetaManagedAgentsEffortXhigh)
        case max(BetaManagedAgentsEffortMax)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "low": self = .low(try BetaManagedAgentsEffortLow(from: decoder))
            case "medium": self = .medium(try BetaManagedAgentsEffortMedium(from: decoder))
            case "high": self = .high(try BetaManagedAgentsEffortHigh(from: decoder))
            case "xhigh": self = .xhigh(try BetaManagedAgentsEffortXhigh(from: decoder))
            case "max": self = .max(try BetaManagedAgentsEffortMax(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .low(let v): try v.encode(to: encoder)
            case .medium(let v): try v.encode(to: encoder)
            case .high(let v): try v.encode(to: encoder)
            case .xhigh(let v): try v.encode(to: encoder)
            case .max(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
