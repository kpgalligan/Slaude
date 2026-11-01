// Transformed from `anthropic.types.beta.organization.beta_plugin_marketplace_validation_plugin_error` (beta_plugin_marketplace_validation_plugin_error.py).

import Foundation

public struct BetaPluginMarketplaceValidationPluginError: Codable, Hashable, Sendable {
    /// Why the plugin would be skipped by a synchronization.
    public var error: String
    /// A stable identifier for the reason — the value to branch on.
    public var errorCode: String
    /// The plugin's name, as its entry in marketplace.json declares it.
    public var name: String

    public init(error: String, errorCode: String, name: String) {
        self.error = error
        self.errorCode = errorCode
        self.name = name
    }

    enum CodingKeys: String, CodingKey {
        case error
        case errorCode = "error_code"
        case name
    }
}
