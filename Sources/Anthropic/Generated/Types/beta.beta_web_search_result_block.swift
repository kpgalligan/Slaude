// Transformed from `anthropic.types.beta.beta_web_search_result_block` (beta_web_search_result_block.py).

import Foundation

public struct BetaWebSearchResultBlock: Codable, Hashable, Sendable {
    public var encryptedContent: String
    public var pageAge: String?
    public var title: String
    public var type: String
    public var url: String

    public init(encryptedContent: String, pageAge: String? = nil, title: String, type: String = "web_search_result", url: String) {
        self.encryptedContent = encryptedContent
        self.pageAge = pageAge
        self.title = title
        self.type = type
        self.url = url
    }

    enum CodingKeys: String, CodingKey {
        case encryptedContent = "encrypted_content"
        case pageAge = "page_age"
        case title
        case type
        case url
    }
}
