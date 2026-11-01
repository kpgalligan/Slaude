// Transformed from `anthropic.types.beta.organization.plugin_marketplace_validate_repository_params` (plugin_marketplace_validate_repository_params.py).

import Foundation

public struct PluginMarketplaceValidateRepositoryParams: Codable, Hashable, Sendable {
    /// The `https://` URL of a public repository on github.com that holds the
    /// marketplace. A URL longer than 2,048 characters, on any other host or scheme,
    /// with a port other than 443 or 80, with credentials in it, or that does not name
    /// exactly `owner/repo` (a trailing `.git` or `/` is accepted) is a 400. A private
    /// or missing repository is reported in the response, not refused.
    public var repositoryURL: String
    /// The branch to validate the tip of, or the full 40-character SHA of the commit to
    /// validate. When omitted, the branch a synchronization would read (usually the
    /// repository's default branch); if that is not the default branch, the report's
    /// `ref` says which branch was read. An empty string, a value longer than 255
    /// characters, or one that contains `..` or a character other than ASCII letters,
    /// digits, `.`, `_`, `-`, `+`, and `/`, is a 400. Any other value that is not a
    /// 40-character SHA is read as a branch name; if the repository has no such branch,
    /// the response is a report with `valid: false`, not a 400.
    public var ref: String??
    /// This endpoint is in beta: requests must send `ce-plugins-2026-09-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?

    public init(repositoryURL: String, ref: String?? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.repositoryURL = repositoryURL
        self.ref = ref
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case repositoryURL = "repository_url"
        case ref
        case betas
    }
}
