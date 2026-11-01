// Transformed from `anthropic.types.beta.beta_managed_agents_user_location` (beta_managed_agents_user_location.py).

import Foundation

/// Approximate user location for search result localization.
public struct BetaManagedAgentsUserLocation: Codable, Hashable, Sendable {
    /// Location precision. Only "approximate" is supported.
    public var type: String
    /// City name.
    public var city: String?
    /// Two-letter ISO 3166-1 country code, uppercase.
    public var country: String?
    /// Region or state name.
    public var region: String?
    /// IANA timezone identifier, e.g. "America/Los_Angeles".
    public var timezone: String?

    public init(type: String = "approximate", city: String? = nil, country: String? = nil, region: String? = nil, timezone: String? = nil) {
        self.type = type
        self.city = city
        self.country = country
        self.region = region
        self.timezone = timezone
    }

    enum CodingKeys: String, CodingKey {
        case type
        case city
        case country
        case region
        case timezone
    }
}
