// Transformed from `anthropic.types.base64_pdf_source` (base64_pdf_source.py).

import Foundation

public struct Base64PDFSource: Codable, Hashable, Sendable {
    public var data: String
    public var mediaType: String
    public var type: String

    public init(data: String, mediaType: String = "application/pdf", type: String = "base64") {
        self.data = data
        self.mediaType = mediaType
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case data
        case mediaType = "media_type"
        case type
    }
}
