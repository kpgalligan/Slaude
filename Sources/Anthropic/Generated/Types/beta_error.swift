// Transformed from `anthropic.types.beta_error` (beta_error.py).

import Foundation

public indirect enum BetaError: Codable, Hashable, Sendable {
    case invalidRequestError(BetaInvalidRequestError)
    case authenticationError(BetaAuthenticationError)
    case billingError(BetaBillingError)
    case permissionError(BetaPermissionError)
    case notFoundError(BetaNotFoundError)
    case rateLimitError(BetaRateLimitError)
    case timeoutError(BetaGatewayTimeoutError)
    case apiError(BetaAPIError)
    case overloadedError(BetaOverloadedError)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "invalid_request_error": self = .invalidRequestError(try BetaInvalidRequestError(from: decoder))
        case "authentication_error": self = .authenticationError(try BetaAuthenticationError(from: decoder))
        case "billing_error": self = .billingError(try BetaBillingError(from: decoder))
        case "permission_error": self = .permissionError(try BetaPermissionError(from: decoder))
        case "not_found_error": self = .notFoundError(try BetaNotFoundError(from: decoder))
        case "rate_limit_error": self = .rateLimitError(try BetaRateLimitError(from: decoder))
        case "timeout_error": self = .timeoutError(try BetaGatewayTimeoutError(from: decoder))
        case "api_error": self = .apiError(try BetaAPIError(from: decoder))
        case "overloaded_error": self = .overloadedError(try BetaOverloadedError(from: decoder))
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
