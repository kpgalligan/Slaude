// Transformed from `anthropic.types.url_pdf_source_param` (url_pdf_source_param.py).

import Foundation

public struct URLPDFSourceParam: Codable, Hashable, Sendable {
    public var type: String
    public var url: String

    public init(type: String = "url", url: String) {
        self.type = type
        self.url = url
    }

    enum CodingKeys: String, CodingKey {
        case type
        case url
    }
}
