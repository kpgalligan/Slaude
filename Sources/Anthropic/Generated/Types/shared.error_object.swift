// Transformed from `anthropic.types.shared.error_object` (error_object.py).

import Foundation

public indirect enum ErrorObject: Codable, Hashable, Sendable {
    case invalidRequestError(InvalidRequestError)
    case authenticationError(SharedAuthenticationError)
    case billingError(BillingError)
    case permissionError(PermissionError)
    case notFoundError(SharedNotFoundError)
    case rateLimitError(SharedRateLimitError)
    case timeoutError(GatewayTimeoutError)
    case apiError(APIErrorObject)
    case overloadedError(SharedOverloadedError)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "invalid_request_error": self = .invalidRequestError(try InvalidRequestError(from: decoder))
        case "authentication_error": self = .authenticationError(try SharedAuthenticationError(from: decoder))
        case "billing_error": self = .billingError(try BillingError(from: decoder))
        case "permission_error": self = .permissionError(try PermissionError(from: decoder))
        case "not_found_error": self = .notFoundError(try SharedNotFoundError(from: decoder))
        case "rate_limit_error": self = .rateLimitError(try SharedRateLimitError(from: decoder))
        case "timeout_error": self = .timeoutError(try GatewayTimeoutError(from: decoder))
        case "api_error": self = .apiError(try APIErrorObject(from: decoder))
        case "overloaded_error": self = .overloadedError(try SharedOverloadedError(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .invalidRequestError(let v): try v.encode(to: encoder)
        case .authenticationError(let v): try v.encode(to: encoder)
        case .billingError(let v): try v.encode(to: encoder)
        case .permissionError(let v): try v.encode(to: encoder)
        case .notFoundError(let v): try v.encode(to: encoder)
        case .rateLimitError(let v): try v.encode(to: encoder)
        case .timeoutError(let v): try v.encode(to: encoder)
        case .apiError(let v): try v.encode(to: encoder)
        case .overloadedError(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
