// Transformed from `anthropic.types.beta.beta_user_location` (beta_user_location.py).

import Foundation

public struct BetaUserLocation: Codable, Hashable, Sendable {
    public var type: String
    /// The city of the user.
    public var city: String?
    /// The two letter
    /// [ISO country code](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) of the
    /// user.
    public var country: String?
    /// The region of the user.
    public var region: String?
    /// The [IANA timezone](https://nodatime.org/TimeZones) of the user.
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
