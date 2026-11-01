// Transformed from `anthropic.types.beta.organization.plugin_marketplace_retrieve_params` (plugin_marketplace_retrieve_params.py).

import Foundation

public struct PluginMarketplaceRetrieveParams: Codable, Hashable, Sendable {
    /// For a `read:org_audit` or `read:compliance_org_data` key created for all of a
    /// parent organization's linked organizations: a child organization of that parent
    /// to read instead of the organization the key was created in, given as the
    /// organization's UUID or its `org_`-prefixed ID. A value that is neither returns a
    /// 400; an organization that is not a child of the key's parent, or where the
    /// Plugins API is not available, returns a 404. Any other key may pass only its own
    /// organization's ID here; another organization returns a 404.
    public var organizationId: String??
    /// This endpoint is in beta: requests must send `ce-plugins-2026-09-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?

    public init(organizationId: String?? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.organizationId = organizationId
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case organizationId = "organization_id"
        case betas
    }
}
