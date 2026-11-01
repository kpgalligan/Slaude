// Transformed from `anthropic.types.beta.organization.beta_organization_webhook_endpoint_signing_secret` (beta_organization_webhook_endpoint_signing_secret.py).

import Foundation

/// An organization webhook endpoint's new signing secret.
public struct BetaOrganizationWebhookEndpointSigningSecret: Codable, Hashable, Sendable {
    /// The new signing secret.
    ///
    /// Deliveries are signed with it from now on, and no other response returns it.
    public var signingSecret: String

    public init(signingSecret: String) {
        self.signingSecret = signingSecret
    }

    enum CodingKeys: String, CodingKey {
        case signingSecret = "signing_secret"
    }
}
