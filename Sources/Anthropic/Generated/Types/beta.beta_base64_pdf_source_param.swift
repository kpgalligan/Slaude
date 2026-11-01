// Transformed from `anthropic.types.beta.beta_base64_pdf_source_param` (beta_base64_pdf_source_param.py).

import Foundation

public struct BetaBase64PDFSourceParam: Codable, Hashable, Sendable {
    public var data: Data
    public var mediaType: String
    public var type: String

    public init(data: Data, mediaType: String = "application/pdf", type: String = "base64") {
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
}
