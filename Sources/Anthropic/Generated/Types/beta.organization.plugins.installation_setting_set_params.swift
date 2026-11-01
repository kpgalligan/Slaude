// Transformed from `anthropic.types.beta.organization.plugins.installation_setting_set_params` (installation_setting_set_params.py).

import Foundation

public struct InstallationSettingSetParams: Codable, Hashable, Sendable {
    /// ID of the Plugin (prefixed `plugin_`).
    public var pluginId: String
    /// The installation setting the target is to hold for this Plugin: one of
    /// `required`, `auto_install`, `available`, `not_available`.
    public var installationPreference: InstallationPreference
    /// This endpoint is in beta: requests must send `ce-plugins-2026-09-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?

    public init(pluginId: String, installationPreference: InstallationPreference, betas: [AnthropicBetaParam]? = nil) {
        self.pluginId = pluginId
        self.installationPreference = installationPreference
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case pluginId = "plugin_id"
        case installationPreference = "installation_preference"
        case betas
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
