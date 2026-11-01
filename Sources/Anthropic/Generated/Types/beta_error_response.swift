// Transformed from `anthropic.types.beta_error_response` (beta_error_response.py).

import Foundation

public struct BetaErrorResponse: Codable, Hashable, Sendable {
    public var error: BetaError
    public var requestId: String?
    public var type: String

    public init(error: BetaError, requestId: String? = nil, type: String = "error") {
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
