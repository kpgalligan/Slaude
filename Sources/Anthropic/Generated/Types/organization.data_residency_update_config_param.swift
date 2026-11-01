// Transformed from `anthropic.types.organization.data_residency_update_config_param` (data_residency_update_config_param.py).

import Foundation

public struct DataResidencyUpdateConfigParam: Codable, Hashable, Sendable {
    /// Permitted inference geo values.
    ///
    /// Use 'unrestricted' to allow all geos, or a list of specific geos.
    public var allowedInferenceGeos: AllowedInferenceGeos??
    /// Default inference geo applied when requests omit the parameter.
    ///
    /// Must be a member of `allowed_inference_geos` unless `allowed_inference_geos` is
    /// `"unrestricted"`.
    public var defaultInferenceGeo: DefaultInferenceGeo??

    public init(allowedInferenceGeos: AllowedInferenceGeos?? = nil, defaultInferenceGeo: DefaultInferenceGeo?? = nil) {
        self.allowedInferenceGeos = allowedInferenceGeos
        self.defaultInferenceGeo = defaultInferenceGeo
    }

    enum CodingKeys: String, CodingKey {
        case allowedInferenceGeos = "allowed_inference_geos"
        case defaultInferenceGeo = "default_inference_geo"
    }

    public indirect enum AllowedInferenceGeos: Codable, Hashable, Sendable, ExpressibleByArrayLiteral {
        case allowedInferenceGeos([AllowedInferenceGeo])
        case unrestricted(String)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(arrayLiteral elements: AllowedInferenceGeo...) { self = .allowedInferenceGeos(elements) }

        public init(from decoder: Decoder) throws {
            if let v = try? [AllowedInferenceGeo](from: decoder) { self = .allowedInferenceGeos(v); return }
            if let v = try? String(from: decoder) { self = .unrestricted(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .allowedInferenceGeos(let v): try v.encode(to: encoder)
            case .unrestricted(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

    public enum DefaultInferenceGeo: OpenEnum, CaseIterable {
        case global
        case us
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [DefaultInferenceGeo] = [.global, .us]

        public init(rawValue: String) {
            switch rawValue {
            case "global": self = .global
            case "us": self = .us
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .global: return "global"
            case .us: return "us"
            case .unknown(let value): return value
            }
        }
    }
}
