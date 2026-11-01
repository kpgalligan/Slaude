// Transformed from `anthropic.types.beta.beta_fallback_param` (beta_fallback_param.py).

import Foundation

/// One entry in the `fallbacks` chain on a `/v1/messages` request.
///
/// `model` is required. The override fields (`max_tokens`, `thinking`,
/// `output_config`, and `speed`) set the corresponding parameter for this
/// attempt only and are validated as if the request were made to `model`.
/// Any other key is rejected at parse time.
public struct BetaFallbackParam: Codable, Hashable, Sendable {
    /// The model that will complete your prompt.
    ///
    /// See [models](https://docs.anthropic.com/en/docs/models-overview) for additional
    /// details and options.
    public var model: ModelParam
    /// The `max_tokens` for the fallback attempt that uses this `fallbacks` entry's
    /// `model`, in place of the request's `max_tokens`. If you leave it out or set it
    /// to `null`, the attempt uses the request's `max_tokens`.
    ///
    /// See the
    /// [refusals and fallback guide](https://platform.claude.com/docs/en/build-with-claude/refusals-and-fallback#naming-your-own-fallback-models)
    /// to learn more about fallback entries.
    public var maxTokens: Int??
    /// Output parameters for the fallback attempt that uses this `fallbacks` entry's
    /// `model`, combined with the request's `output_config` one field at a time.
    ///
    /// - `format`: If you leave it out, the attempt uses the request's `format`. If you
    ///   set it to `null`, the attempt runs without a format.
    /// - `effort`: If you leave it out, the attempt uses the request's `effort` when
    ///   `model` supports that level with the attempt's `thinking`. If the request
    ///   doesn't set `effort`, if `model` doesn't support the level, or if you set
    ///   `effort` to `null`, the attempt runs at the default effort of `model`.
    /// - `task_budget`: If you leave it out, the attempt uses the request's
    ///   `task_budget` when `model` accepts a task budget of that size. If the request
    ///   doesn't set `task_budget`, if `model` doesn't accept it, or if you set
    ///   `task_budget` to `null`, the attempt runs without a task budget.
    ///
    /// Set `output_config` to `null` to run the attempt without a format or a task
    /// budget, at the default effort of `model`.
    ///
    /// These rules apply with the `server-side-fallback-2026-07-01` beta header.
    public var outputConfig: BetaOutputConfigParam??
    /// The inference speed mode for the fallback attempt that uses this `fallbacks`
    /// entry's `model`. If you leave it out, the attempt runs at `fast` speed only when
    /// the request sets `speed` to `fast` and your organization can use fast mode on
    /// `model`.
    ///
    /// Otherwise, or when you set this field to `null`, the attempt runs at `standard`
    /// speed.
    ///
    /// These rules apply with the `server-side-fallback-2026-07-01` beta header.
    public var speed: Speed??
    /// The thinking configuration for the fallback attempt that uses this `fallbacks`
    /// entry's `model`. If you leave it out, the attempt uses the request's `thinking`
    /// when `model` supports that thinking `type`.
    ///
    /// If you leave it out and the request's thinking `type` is `between_tools` but
    /// `model` doesn't support `between_tools`, the attempt uses `disabled` if `model`
    /// supports it. Otherwise, if `model` doesn't support the request's thinking
    /// `type`, if the request doesn't set `thinking`, or if you set this field to
    /// `null`, the attempt uses the thinking `type` that `model` uses when a request
    /// leaves out `thinking`. The request's `thinking.display` still applies where
    /// `model` allows it.
    ///
    /// These rules apply with the `server-side-fallback-2026-07-01` beta header.
    public var thinking: BetaFallbackParam.Thinking??

    public init(model: ModelParam, maxTokens: Int?? = nil, outputConfig: BetaOutputConfigParam?? = nil, speed: Speed?? = nil, thinking: BetaFallbackParam.Thinking?? = nil) {
        self.model = model
        self.maxTokens = maxTokens
        self.outputConfig = outputConfig
        self.speed = speed
        self.thinking = thinking
    }

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case outputConfig = "output_config"
        case speed
        case thinking
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

extension BetaFallbackParam {

    public indirect enum Thinking: Codable, Hashable, Sendable {
        case enabled(BetaThinkingConfigEnabledParam)
        case disabled(BetaThinkingConfigDisabledParam)
        case betweenTools(BetaThinkingConfigBetweenToolsParam)
        case adaptive(BetaThinkingConfigAdaptiveParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "enabled": self = .enabled(try BetaThinkingConfigEnabledParam(from: decoder))
            case "disabled": self = .disabled(try BetaThinkingConfigDisabledParam(from: decoder))
            case "between_tools": self = .betweenTools(try BetaThinkingConfigBetweenToolsParam(from: decoder))
            case "adaptive": self = .adaptive(try BetaThinkingConfigAdaptiveParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .enabled(let v): try v.encode(to: encoder)
            case .disabled(let v): try v.encode(to: encoder)
            case .betweenTools(let v): try v.encode(to: encoder)
            case .adaptive(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
