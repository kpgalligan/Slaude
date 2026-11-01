// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_refresh_object` (beta_managed_agents_refresh_object.py).

import Foundation

/// Outcome of a refresh-token exchange attempted during credential validation.
public struct BetaManagedAgentsRefreshObject: Codable, Hashable, Sendable {
    /// The captured HTTP error response from the token endpoint.
    ///
    /// Populated only when `status` is `failed`.
    public var httpResponse: BetaManagedAgentsRefreshHTTPResponse?
    /// Outcome of the refresh attempt.
    ///
    /// - `succeeded` - The token endpoint returned a new access token.
    /// - `failed` - The token endpoint returned an error response. See `http_response`
    ///   for detail.
    /// - `connect_error` - The token endpoint could not be reached (DNS, TLS, or
    ///   connection error).
    /// - `no_refresh_token` - No refresh token is stored for the credential, so no
    ///   exchange was attempted.
    public var status: Status

    public init(httpResponse: BetaManagedAgentsRefreshHTTPResponse? = nil, status: Status) {
        self.httpResponse = httpResponse
        self.status = status
    }

    enum CodingKeys: String, CodingKey {
        case httpResponse = "http_response"
        case status
    }

    public enum Status: OpenEnum, CaseIterable {
        case succeeded
        case failed
        case connectError
        case noRefreshToken
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Status] = [.succeeded, .failed, .connectError, .noRefreshToken]

        public init(rawValue: String) {
            switch rawValue {
            case "succeeded": self = .succeeded
            case "failed": self = .failed
            case "connect_error": self = .connectError
            case "no_refresh_token": self = .noRefreshToken
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .succeeded: return "succeeded"
            case .failed: return "failed"
            case .connectError: return "connect_error"
            case .noRefreshToken: return "no_refresh_token"
            case .unknown(let value): return value
            }
        }
    }
}
