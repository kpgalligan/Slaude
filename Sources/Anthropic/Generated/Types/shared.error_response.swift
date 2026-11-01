// Transformed from `anthropic.types.shared.error_response` (error_response.py).

import Foundation

public struct ErrorResponse: Codable, Hashable, Sendable {
    public var error: ErrorObject
    public var requestID: String?
    public var type: String

    public init(error: ErrorObject, requestID: String? = nil, type: String = "error") {
        self.error = error
        self.requestID = requestID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case error
        case requestID = "request_id"
        case type
    }
}
