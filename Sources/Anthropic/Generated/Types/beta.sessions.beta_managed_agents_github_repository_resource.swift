// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_github_repository_resource` (beta_managed_agents_github_repository_resource.py).

import Foundation

public struct BetaManagedAgentsGitHubRepositoryResource: Codable, Hashable, Sendable {
    public var id: String
    /// A timestamp in RFC 3339 format
    public var createdAt: Date
    public var mountPath: String
    public var type: String
    /// A timestamp in RFC 3339 format
    public var updatedAt: Date
    public var url: String
    public var checkout: BetaManagedAgentsGitHubRepositoryResource.Checkout?

    public init(id: String, createdAt: Date, mountPath: String, type: String = "github_repository", updatedAt: Date, url: String, checkout: BetaManagedAgentsGitHubRepositoryResource.Checkout? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.mountPath = mountPath
        self.type = type
        self.updatedAt = updatedAt
        self.url = url
        self.checkout = checkout
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case mountPath = "mount_path"
        case type
        case updatedAt = "updated_at"
        case url
        case checkout
    }
}

extension BetaManagedAgentsGitHubRepositoryResource {

    public indirect enum Checkout: Codable, Hashable, Sendable {
        case branch(BetaManagedAgentsBranchCheckout)
        case commit(BetaManagedAgentsCommitCheckout)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "branch": self = .branch(try BetaManagedAgentsBranchCheckout(from: decoder))
            case "commit": self = .commit(try BetaManagedAgentsCommitCheckout(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .branch(let v): try v.encode(to: encoder)
            case .commit(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
