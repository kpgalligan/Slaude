// Transformed from `anthropic.types.beta.beta_tunnel_token` (beta_tunnel_token.py).

import Foundation

/// A tunnel's connector token.
public struct BetaTunnelToken: Codable, Hashable, Sendable {
    /// Stable identifier for the current token value.
    ///
    /// Changes when the token is rotated.
    public var id: String
    /// The connector token used to run the tunnel. Treat as a credential.
    public var tunnelToken: String
    public var type: String

    public init(id: String, tunnelToken: String, type: String = "tunnel_token") {
        self.id = id
        self.tunnelToken = tunnelToken
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case tunnelToken = "tunnel_token"
        case type
    }
}
