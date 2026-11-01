// Transformed from `anthropic.types.beta.organization.beta_plugin_marketplace_validation_plugin_warnings` (beta_plugin_marketplace_validation_plugin_warnings.py).

import Foundation

public struct BetaPluginMarketplaceValidationPluginWarnings: Codable, Hashable, Sendable {
    /// The plugin's name, as its entry in marketplace.json declares it.
    public var name: String
    /// The parts of the plugin a synchronization would leave out.
    public var warnings: [BetaPluginMarketplaceValidationPluginWarning]

    public init(name: String, warnings: [BetaPluginMarketplaceValidationPluginWarning]) {
        self.name = name
        self.warnings = warnings
    }

    enum CodingKeys: String, CodingKey {
        case name
        case warnings
    }
}
