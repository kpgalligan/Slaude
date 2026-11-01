// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_injection_location_response` (beta_managed_agents_injection_location_response.py).

import Foundation

/// Where in the outbound request the secret value is substituted.
public struct BetaManagedAgentsInjectionLocationResponse: Codable, Hashable, Sendable {
    /// Whether the placeholder is substituted in the request body.
    public var body: Bool
    /// Whether the placeholder is substituted in request header values.
    public var header: Bool

    public init(body: Bool, header: Bool) {
        self.body = body
        self.header = header
    }

    enum CodingKeys: String, CodingKey {
        case body
        case header
    }
}
