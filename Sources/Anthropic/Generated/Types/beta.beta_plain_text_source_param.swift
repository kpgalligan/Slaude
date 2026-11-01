// Transformed from `anthropic.types.beta.beta_plain_text_source_param` (beta_plain_text_source_param.py).

import Foundation

public struct BetaPlainTextSourceParam: Codable, Hashable, Sendable {
    public var data: String
    public var mediaType: String
    public var type: String

    public init(data: String, mediaType: String = "text/plain", type: String = "text") {
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
