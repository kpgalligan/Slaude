// Transformed from `anthropic.types.beta.beta_managed_agents_github_repository_resource_params` (beta_managed_agents_github_repository_resource_params.py).

import Foundation

/// Mount a GitHub repository into the session's container.
public struct BetaManagedAgentsGitHubRepositoryResourceParams: Codable, Hashable, Sendable {
    public var type: String
    /// Github URL of the repository
    public var url: String
    /// GitHub authorization token used to clone the repository.
    ///
    /// Required for private repositories; optional for public ones.
    public var authorizationToken: String?
    /// Branch or commit to check out. Defaults to the repository's default branch.
    public var checkout: BetaManagedAgentsGitHubRepositoryResourceParams.Checkout??
    /// Mount path in the container. Defaults to `/workspace/<repo-name>`.
    public var mountPath: String??

    public init(type: String = "github_repository", url: String, authorizationToken: String? = nil, checkout: BetaManagedAgentsGitHubRepositoryResourceParams.Checkout?? = nil, mountPath: String?? = nil) {
        self.type = type
        self.url = url
        self.authorizationToken = authorizationToken
        self.checkout = checkout
        self.mountPath = mountPath
    }

    enum CodingKeys: String, CodingKey {
        case type
        case url
        case authorizationToken = "authorization_token"
        case checkout
        case mountPath = "mount_path"
    }
}

extension BetaManagedAgentsGitHubRepositoryResourceParams {

    public indirect enum Checkout: Codable, Hashable, Sendable {
        case branch(BetaManagedAgentsBranchCheckoutParam)
        case commit(BetaManagedAgentsCommitCheckoutParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "branch": self = .branch(try BetaManagedAgentsBranchCheckoutParam(from: decoder))
            case "commit": self = .commit(try BetaManagedAgentsCommitCheckoutParam(from: decoder))
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
