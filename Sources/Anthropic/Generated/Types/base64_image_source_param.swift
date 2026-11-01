// Transformed from `anthropic.types.base64_image_source_param` (base64_image_source_param.py).

import Foundation

public struct Base64ImageSourceParam: Codable, Hashable, Sendable {
    public var data: Data
    public var mediaType: MediaType
    public var type: String

    public init(data: Data, mediaType: MediaType, type: String = "base64") {
        self.data = data
        self.mediaType = mediaType
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case data
        case mediaType = "media_type"
        case type
    }

    public indirect enum Data: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case file(Base64FileInput)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? Base64FileInput(from: decoder) { self = .file(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .file(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

    public enum MediaType: OpenEnum, CaseIterable {
        case imageJpeg
        case imagePng
        case imageGif
        case imageWebp
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [MediaType] = [.imageJpeg, .imagePng, .imageGif, .imageWebp]

        public init(rawValue: String) {
            switch rawValue {
            case "image/jpeg": self = .imageJpeg
            case "image/png": self = .imagePng
            case "image/gif": self = .imageGif
            case "image/webp": self = .imageWebp
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .imageJpeg: return "image/jpeg"
            case .imagePng: return "image/png"
            case .imageGif: return "image/gif"
            case .imageWebp: return "image/webp"
            case .unknown(let value): return value
            }
        }
    }
}
