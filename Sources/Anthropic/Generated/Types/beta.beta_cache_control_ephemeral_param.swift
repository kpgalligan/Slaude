// Transformed from `anthropic.types.beta.beta_cache_control_ephemeral_param` (beta_cache_control_ephemeral_param.py).

import Foundation

public struct BetaCacheControlEphemeralParam: Codable, Hashable, Sendable {
    public var type: String
    /// The time-to-live for the cache control breakpoint.
    ///
    /// This may be one the following values:
    ///
    /// - `5m`: 5 minutes
    /// - `1h`: 1 hour
    ///
    /// Defaults to `5m`. See
    /// [prompt caching pricing](https://platform.claude.com/docs/en/build-with-claude/prompt-caching)
    /// for details.
    public var ttl: Ttl?

    public init(type: String = "ephemeral", ttl: Ttl? = nil) {
        self.type = type
        self.ttl = ttl
    }

    enum CodingKeys: String, CodingKey {
        case type
        case ttl
    }

    public enum Ttl: OpenEnum, CaseIterable {
        case _5m
        case _1h
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Ttl] = [._5m, ._1h]

        public init(rawValue: String) {
            switch rawValue {
            case "5m": self = ._5m
            case "1h": self = ._1h
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case ._5m: return "5m"
            case ._1h: return "1h"
            case .unknown(let value): return value
            }
        }
    }
}
