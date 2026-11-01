// Transformed from `anthropic.types.beta.beta_web_search_result_block_param` (beta_web_search_result_block_param.py).

import Foundation

public struct BetaWebSearchResultBlockParam: Codable, Hashable, Sendable {
    public var encryptedContent: String
    public var title: String
    public var type: String
    public var url: String
    public var pageAge: String??

    public init(encryptedContent: String, title: String, type: String = "web_search_result", url: String, pageAge: String?? = nil) {
        self.encryptedContent = encryptedContent
        self.title = title
        self.type = type
        self.url = url
        self.pageAge = pageAge
    }

    enum CodingKeys: String, CodingKey {
        case encryptedContent = "encrypted_content"
        case title
        case type
        case url
        case pageAge = "page_age"
    }
}
