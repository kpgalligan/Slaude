// Transformed from `anthropic.types.beta.organization.plugin_marketplace_update_params` (plugin_marketplace_update_params.py).

import Foundation

public struct PluginMarketplaceUpdateParams: Codable, Hashable, Sendable {
    /// The organization-wide installation setting every Plugin in the marketplace
    /// without one of its own gets: one of `required`, `auto_install`, `available`,
    /// `not_available`. Once set it can be changed but not removed.
    public var defaultInstallationPreference: DefaultInstallationPreference
    /// This endpoint is in beta: requests must send `ce-plugins-2026-09-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?

    public init(defaultInstallationPreference: DefaultInstallationPreference, betas: [AnthropicBetaParam]? = nil) {
        self.defaultInstallationPreference = defaultInstallationPreference
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case defaultInstallationPreference = "default_installation_preference"
        case betas
    }

    public enum DefaultInstallationPreference: OpenEnum, CaseIterable {
        case autoInstall
        case available
        case notAvailable
        case required
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [DefaultInstallationPreference] = [.autoInstall, .available, .notAvailable, .required]

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
