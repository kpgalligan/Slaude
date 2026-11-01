// Transformed from `anthropic.types.organization.api_key_created_by` (api_key_created_by.py).

import Foundation

public struct APIKeyCreatedBy: Codable, Hashable, Sendable {
    /// ID of the actor that created the object.
    public var id: String
    /// Type of the actor that created the object.
    public var type: TypeValue

    public init(id: String, type: TypeValue) {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }

    public enum TypeValue: OpenEnum, CaseIterable {
        case serviceAccount
        case user
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [TypeValue] = [.serviceAccount, .user]

        public init(rawValue: String) {
            switch rawValue {
            case "service_account": self = .serviceAccount
            case "user": self = .user
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .serviceAccount: return "service_account"
            case .user: return "user"
            case .unknown(let value): return value
            }
        }
    }
}
