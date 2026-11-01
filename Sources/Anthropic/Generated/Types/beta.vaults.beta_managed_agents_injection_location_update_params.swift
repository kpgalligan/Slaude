// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_injection_location_update_params` (beta_managed_agents_injection_location_update_params.py).

import Foundation

/// Changes which parts of an outbound request the secret is substituted into.
///
/// A location you leave out keeps its current setting.
///
/// After the change, at least one location must be enabled.
///
/// See [Authenticate with vaults](https://platform.claude.com/docs/en/managed-agents/vaults#add-a-credential) to learn more about injection locations.
public struct BetaManagedAgentsInjectionLocationUpdateParams: Codable, Hashable, Sendable {
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
