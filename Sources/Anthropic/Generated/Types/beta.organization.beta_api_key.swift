// Transformed from `anthropic.types.beta.organization.beta_api_key` (beta_api_key.py).

import Foundation

public struct BetaAPIKey: Codable, Hashable, Sendable {
    /// ID of the API key.
    public var id: String
    /// RFC 3339 datetime string indicating when the API Key was created.
    public var createdAt: Date
    /// The ID and type of the actor that created the API key, or `null` when the
    /// creator is not recorded (legacy, workload-identity-federated, or system-created
    /// keys).
    public var createdBy: BetaAPIKeyCreatedBy?
    /// RFC 3339 datetime string indicating when the API Key expires, or `null` if it
    /// never expires.
    public var expiresAt: Date?
    /// Name of the API key.
    public var name: String
    /// Partially redacted hint for the API key.
    public var partialKeyHint: String?
    /// The principal the API key acts as (a User or a Service Account), or `null` if
    /// the API key is not bound to a principal.
    public var principal: BetaAPIKey.Principal??
    /// Where the API key belongs: its Workspace
    /// (`{"type": "workspace", "workspace_id": "wrkspc_..."}`, with the Workspace's
    /// real ID even when it is the organization's default Workspace), or the
    /// organization (`{"type": "organization"}`) for a principal-bound API key that has
    /// no Workspace.
    public var scope: BetaAPIKey.Scope
    /// Status of the API key.
    public var status: Status
    /// Object type.
    ///
    /// For API Keys, this is always `"api_key"`.
    public var type: String

    public init(id: String, createdAt: Date, createdBy: BetaAPIKeyCreatedBy? = nil, expiresAt: Date? = nil, name: String, partialKeyHint: String? = nil, principal: BetaAPIKey.Principal?? = nil, scope: BetaAPIKey.Scope, status: Status, type: String = "api_key") {
        self.id = id
        self.createdAt = createdAt
        self.createdBy = createdBy
        self.expiresAt = expiresAt
        self.name = name
        self.partialKeyHint = partialKeyHint
        self.principal = principal
        self.scope = scope
        self.status = status
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case createdBy = "created_by"
        case expiresAt = "expires_at"
        case name
        case partialKeyHint = "partial_key_hint"
        case principal
        case scope
        case status
        case type
    }

    public enum Status: OpenEnum, CaseIterable {
        case active
        case archived
        case expired
        case inactive
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Status] = [.active, .archived, .expired, .inactive]

        public init(rawValue: String) {
            switch rawValue {
            case "active": self = .active
            case "archived": self = .archived
            case "expired": self = .expired
            case "inactive": self = .inactive
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .active: return "active"
            case .archived: return "archived"
            case .expired: return "expired"
            case .inactive: return "inactive"
            case .unknown(let value): return value
            }
        }
    }
}

extension BetaAPIKey {

    public indirect enum Principal: Codable, Hashable, Sendable {
        case userActor(BetaAPIKeyUserActor)
        case serviceAccountActor(BetaAPIKeyServiceAccountActor)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "user_actor": self = .userActor(try BetaAPIKeyUserActor(from: decoder))
            case "service_account_actor": self = .serviceAccountActor(try BetaAPIKeyServiceAccountActor(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .userActor(let v): try v.encode(to: encoder)
            case .serviceAccountActor(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

    public indirect enum Scope: Codable, Hashable, Sendable {
        case organization(BetaAPIKeyOrganizationScope)
        case workspace(BetaAPIKeyWorkspaceScope)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "organization": self = .organization(try BetaAPIKeyOrganizationScope(from: decoder))
            case "workspace": self = .workspace(try BetaAPIKeyWorkspaceScope(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .organization(let v): try v.encode(to: encoder)
            case .workspace(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
