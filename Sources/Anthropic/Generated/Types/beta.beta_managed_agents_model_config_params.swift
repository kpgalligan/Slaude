// Transformed from `anthropic.types.beta.beta_managed_agents_model_config_params` (beta_managed_agents_model_config_params.py).

import Foundation

/// An object that defines additional configuration control over model use
public struct BetaManagedAgentsModelConfigParams: Codable, Hashable, Sendable {
    /// The model that will power your agent.
    ///
    /// See [models](https://docs.anthropic.com/en/docs/models-overview) for additional
    /// details and options.
    public var id: BetaManagedAgentsModelParam
    /// How hard Claude works on each inference call.
    ///
    /// Accepts a bare level string (`"high"`) or `{"type": "high"}`. On create,
    /// omitting it resolves the per-model default; on update, omitting it leaves the
    /// stored value unchanged.
    public var effort: BetaManagedAgentsModelConfigParams.Effort??
    /// Geographic region for model inference.
    ///
    /// When unset, requests fall through to the workspace's default_inference_geo. On
    /// update, `model` is whole-object replacement — omitting inference_geo clears it.
    public var inferenceGeo: String??
    /// Inference speed mode. Defaults to `standard`.
    public var speed: Speed??

    public init(id: BetaManagedAgentsModelParam, effort: BetaManagedAgentsModelConfigParams.Effort?? = nil, inferenceGeo: String?? = nil, speed: Speed?? = nil) {
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

extension BetaManagedAgentsModelConfigParams {

    public indirect enum Effort: Codable, Hashable, Sendable {
        case literal(Literal)
        case betaManagedAgentsEffortLowParam(BetaManagedAgentsEffortLowParam)
        case betaManagedAgentsEffortMediumParam(BetaManagedAgentsEffortMediumParam)
        case betaManagedAgentsEffortHighParam(BetaManagedAgentsEffortHighParam)
        case betaManagedAgentsEffortXhighParam(BetaManagedAgentsEffortXhighParam)
        case betaManagedAgentsEffortMaxParam(BetaManagedAgentsEffortMaxParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            if let v = try? Literal(from: decoder) { self = .literal(v); return }
            if _Coding.constantsMatch(decoder, ["type": "low"]), let v = try? BetaManagedAgentsEffortLowParam(from: decoder) { self = .betaManagedAgentsEffortLowParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "medium"]), let v = try? BetaManagedAgentsEffortMediumParam(from: decoder) { self = .betaManagedAgentsEffortMediumParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "high"]), let v = try? BetaManagedAgentsEffortHighParam(from: decoder) { self = .betaManagedAgentsEffortHighParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "xhigh"]), let v = try? BetaManagedAgentsEffortXhighParam(from: decoder) { self = .betaManagedAgentsEffortXhighParam(v); return }
            if _Coding.constantsMatch(decoder, ["type": "max"]), let v = try? BetaManagedAgentsEffortMaxParam(from: decoder) { self = .betaManagedAgentsEffortMaxParam(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .literal(let v): try v.encode(to: encoder)
            case .betaManagedAgentsEffortLowParam(let v): try v.encode(to: encoder)
            case .betaManagedAgentsEffortMediumParam(let v): try v.encode(to: encoder)
            case .betaManagedAgentsEffortHighParam(let v): try v.encode(to: encoder)
            case .betaManagedAgentsEffortXhighParam(let v): try v.encode(to: encoder)
            case .betaManagedAgentsEffortMaxParam(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }

        public enum Literal: OpenEnum, CaseIterable {
            case low
            case medium
            case high
            case xhigh
            case max
            /// A value this version of the SDK doesn't know about.
            case unknown(String)

            public static let allCases: [Literal] = [.low, .medium, .high, .xhigh, .max]

            public init(rawValue: String) {
                switch rawValue {
                case "low": self = .low
                case "medium": self = .medium
                case "high": self = .high
                case "xhigh": self = .xhigh
                case "max": self = .max
                default: self = .unknown(rawValue)
                }
            }

            public var rawValue: String {
                switch self {
                case .low: return "low"
                case .medium: return "medium"
                case .high: return "high"
                case .xhigh: return "xhigh"
                case .max: return "max"
                case .unknown(let value): return value
                }
            }
        }
    }
}
