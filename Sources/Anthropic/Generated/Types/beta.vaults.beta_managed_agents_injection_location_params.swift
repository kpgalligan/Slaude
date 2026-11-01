// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_injection_location_params` (beta_managed_agents_injection_location_params.py).

import Foundation

/// Where in the outbound request the secret value may be substituted.
public struct BetaManagedAgentsInjectionLocationParams: Codable, Hashable, Sendable {
    /// Substitute when the placeholder appears in the request body.
    public var body: Bool?
    /// Substitute when the placeholder appears in a request header value.
    public var header: Bool?

    public init(body: Bool? = nil, header: Bool? = nil) {
        self.body = body
        self.header = header
    }

    enum CodingKeys: String, CodingKey {
        case body
        case header
    }
}
