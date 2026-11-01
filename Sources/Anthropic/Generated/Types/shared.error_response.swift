// Transformed from `anthropic.types.shared.error_response` (error_response.py).

import Foundation

public struct ErrorResponse: Codable, Hashable, Sendable {
    public var error: ErrorObject
    public var requestId: String?
    public var type: String

    public init(error: ErrorObject, requestId: String? = nil, type: String = "error") {
        self.error = error
        self.requestId = requestId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case error
        case requestId = "request_id"
        case type
    }
}
