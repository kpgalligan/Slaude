// Transformed from `anthropic.types.beta.beta_managed_agents_github_repository_resource_config` (beta_managed_agents_github_repository_resource_config.py).

import Foundation

/// A GitHub repository mounted into each session's container.
///
/// The authorization token is write-only and never returned.
public struct BetaManagedAgentsGitHubRepositoryResourceConfig: Codable, Hashable, Sendable {
    public var type: String
    /// Github URL of the repository
    public var url: String
    /// Branch or commit to check out. Defaults to the repository's default branch.
    public var checkout: BetaManagedAgentsGitHubRepositoryResourceConfig.Checkout??
    /// Mount path in the container. Defaults to `/workspace/<repo-name>`.
    public var mountPath: String?

    public init(type: String = "github_repository", url: String, checkout: BetaManagedAgentsGitHubRepositoryResourceConfig.Checkout?? = nil, mountPath: String? = nil) {
        self.type = type
        self.url = url
        self.checkout = checkout
        self.mountPath = mountPath
    }

    enum CodingKeys: String, CodingKey {
        case type
        case url
        case checkout
        case mountPath = "mount_path"
    }
}

extension BetaManagedAgentsGitHubRepositoryResourceConfig {

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
