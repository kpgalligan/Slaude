// Transformed from `anthropic.types.beta.organization.plugins.beta_plugin_share` (beta_plugin_share.py).

import Foundation

/// One share the owner of a member-owned Plugin has given.
///
/// Shares are
/// read-only in this API and have no ID of their own; who gave a share is
/// recorded on the Compliance API activity feed, not here.
public struct BetaPluginShare: Codable, Hashable, Sendable {
    /// When the share was given; a share whose role is later changed in claude.ai is
    /// re-granted and carries the time of that change.
    public var grantedAt: Date
    /// The Plugin's ID.
    public var pluginID: String
    /// Who the Plugin is shared with: `organization` (every member), `rbac_group` (one
    /// RBAC Group), or `organization_member` (one member).
    public var target: BetaPluginShare.Target
    /// Always `plugin_share`.
    public var type: String

    public init(grantedAt: Date, pluginID: String, target: BetaPluginShare.Target, type: String = "plugin_share") {
        self.grantedAt = grantedAt
        self.pluginID = pluginID
        self.target = target
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case grantedAt = "granted_at"
        case pluginID = "plugin_id"
        case target
        case type
    }
}

extension BetaPluginShare {

    public indirect enum Target: Codable, Hashable, Sendable {
        case organization(BetaPluginTargetOrganization)
        case rbacGroup(BetaPluginTargetRBACGroup)
        case organizationMember(BetaPluginTargetOrganizationMember)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "organization": self = .organization(try BetaPluginTargetOrganization(from: decoder))
            case "rbac_group": self = .rbacGroup(try BetaPluginTargetRBACGroup(from: decoder))
            case "organization_member": self = .organizationMember(try BetaPluginTargetOrganizationMember(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .organization(let v): try v.encode(to: encoder)
            case .rbacGroup(let v): try v.encode(to: encoder)
            case .organizationMember(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
