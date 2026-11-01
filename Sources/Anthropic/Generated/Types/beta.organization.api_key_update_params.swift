// Transformed from `anthropic.types.beta.organization.api_key_update_params` (api_key_update_params.py).

import Foundation

public struct BetaOrganizationAPIKeyUpdateParams: Codable, Hashable, Sendable {
    /// Name of the API key.
    public var name: String??
    /// Status of the API key.
    public var status: Status??

    public init(name: String?? = nil, status: Status?? = nil) {
        self.name = name
        self.status = status
    }

    enum CodingKeys: String, CodingKey {
        case name
        case status
    }

    public enum Status: OpenEnum, CaseIterable {
        case active
        case archived
        case inactive
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Status] = [.active, .archived, .inactive]

        public init(rawValue: String) {
            switch rawValue {
            case "active": self = .active
            case "archived": self = .archived
            case "inactive": self = .inactive
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .active: return "active"
            case .archived: return "archived"
            case .inactive: return "inactive"
            case .unknown(let value): return value
            }
        }
    }
}
