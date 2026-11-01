// Transformed from `anthropic.types.beta.organization.plugins.beta_plugin_installation_setting` (beta_plugin_installation_setting.py).

import Foundation

/// The installation setting an organization-owned Plugin holds for one
/// target.
///
/// It has no ID of its own: it is addressed by the Plugin's ID and the
/// target.
public struct BetaPluginInstallationSetting: Codable, Hashable, Sendable {
    /// When the target was first given a setting for this Plugin.
    public var createdAt: Date
    /// The setting the target holds for this Plugin.
    ///
    /// One of `required`, `auto_install`, `available`, `not_available`; a value this
    /// API does not yet name is returned as stored.
    public var installationPreference: InstallationPreference
    /// The Plugin's ID.
    public var pluginID: String
    /// Whose setting this is: `organization` (the Plugin's own organization-wide
    /// setting) or `rbac_group` (one RBAC Group's own setting); `organization_member`
    /// does not occur here.
    public var target: BetaPluginInstallationSetting.Target
    /// Always `plugin_installation_setting`.
    public var type: String
    /// When its setting last changed.
    public var updatedAt: Date

    public init(createdAt: Date, installationPreference: InstallationPreference, pluginID: String, target: BetaPluginInstallationSetting.Target, type: String = "plugin_installation_setting", updatedAt: Date) {
        self.createdAt = createdAt
        self.installationPreference = installationPreference
        self.pluginID = pluginID
        self.target = target
        self.type = type
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case installationPreference = "installation_preference"
        case pluginID = "plugin_id"
        case target
        case type
        case updatedAt = "updated_at"
    }

    public enum InstallationPreference: OpenEnum, CaseIterable {
        case autoInstall
        case available
        case notAvailable
        case required
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [InstallationPreference] = [.autoInstall, .available, .notAvailable, .required]

        public init(rawValue: String) {
            switch rawValue {
            case "auto_install": self = .autoInstall
            case "available": self = .available
            case "not_available": self = .notAvailable
            case "required": self = .required
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .autoInstall: return "auto_install"
            case .available: return "available"
            case .notAvailable: return "not_available"
            case .required: return "required"
            case .unknown(let value): return value
            }
        }
    }
}

extension BetaPluginInstallationSetting {

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
