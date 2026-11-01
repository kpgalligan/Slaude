// Transformed from `anthropic.types.beta.organization.beta_plugin_marketplace_validation_plugin_warning` (beta_plugin_marketplace_validation_plugin_warning.py).

import Foundation

public struct BetaPluginMarketplaceValidationPluginWarning: Codable, Hashable, Sendable {
    /// A stable identifier for the kind of warning.
    public var errorCode: String
    /// What would be left out, and why.
    public var message: String

    public init(errorCode: String, message: String) {
        self.errorCode = errorCode
        self.message = message
    }

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case message
    }
}
