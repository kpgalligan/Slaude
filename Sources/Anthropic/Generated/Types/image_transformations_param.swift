// Transformed from `anthropic.types.image_transformations_param` (image_transformations_param.py).

import Foundation

/// Configures the transformations the server applies to this image before the model observes it. Each key names a condition the server transforms images for; its value selects the transformation applied. Omitted keys keep their default behavior, and an empty object is equivalent to omitting the field.
public struct ImageTransformationsParam: Codable, Hashable, Sendable {
    /// What the server does when this image exceeds the model's maximum image size.
    ///
    /// `"downsize"` (the default) scales the image down to fit, which changes the
    /// dimensions the model observes without telling you. `"error"` instead rejects the
    /// request with a 400 error naming the image's dimensions and the largest
    /// dimensions that fit, so you can scale the image deliberately — your image is
    /// never silently scaled down.
    public var oversizedImage: OversizedImage?

    public init(oversizedImage: OversizedImage? = nil) {
        self.oversizedImage = oversizedImage
    }

    enum CodingKeys: String, CodingKey {
        case oversizedImage = "oversized_image"
    }

    public enum OversizedImage: OpenEnum, CaseIterable {
        case downsize
        case error
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [OversizedImage] = [.downsize, .error]

        public init(rawValue: String) {
            switch rawValue {
            case "downsize": self = .downsize
            case "error": self = .error
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .downsize: return "downsize"
            case .error: return "error"
            case .unknown(let value): return value
            }
        }
    }
}
