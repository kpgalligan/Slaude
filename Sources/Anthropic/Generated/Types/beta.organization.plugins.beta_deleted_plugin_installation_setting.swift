// Transformed from `anthropic.types.beta.organization.plugins.beta_deleted_plugin_installation_setting` (beta_deleted_plugin_installation_setting.py).

import Foundation

/// Confirmation that one target's installation setting was removed, naming
/// the Plugin and the target in place of an ID.
public struct BetaDeletedPluginInstallationSetting: Codable, Hashable, Sendable {
    /// The Plugin's ID.
    public var pluginId: String
    /// Whose setting was removed.
    public var target: BetaDeletedPluginInstallationSetting.Target
    /// Always `plugin_installation_setting_deleted`.
    public var type: String

    public init(pluginId: String, target: BetaDeletedPluginInstallationSetting.Target, type: String = "plugin_installation_setting_deleted") {
        self.pluginId = pluginId
        self.target = target
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case pluginId = "plugin_id"
        case target
        case type
    }
}

extension BetaDeletedPluginInstallationSetting {

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
