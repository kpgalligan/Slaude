// Transformed from `anthropic.types.beta.organization.beta_plugin_marketplace_validation_report` (beta_plugin_marketplace_validation_report.py).

import Foundation

/// The outcome of validating plugin marketplace content: a report, not a
/// stored object, so nothing in it can be retrieved afterwards.
public struct BetaPluginMarketplaceValidationReport: Codable, Hashable, Sendable {
    /// The full SHA of the commit that was validated: for a repository, the commit that
    /// was read; for an uploaded archive, the commit recorded in the archive's comment
    /// (as a Git host's download writes it; not verified), else null.
    public var commitSha: String?
    /// Set when nothing could be validated: the repository or archive could not be
    /// read, or marketplace.json is missing, malformed or over a limit. Null otherwise.
    public var manifestError: String?
    /// A stable identifier for `manifest_error`; null when that is.
    public var manifestErrorCode: String?
    /// One entry per plugin a synchronization would skip entirely, keyed by the
    /// plugin's name in marketplace.json.
    public var pluginErrors: [BetaPluginMarketplaceValidationPluginError]
    /// One entry per plugin that would synchronize with some of its contents left out,
    /// keyed by the plugin's name in marketplace.json.
    public var pluginWarnings: [BetaPluginMarketplaceValidationPluginWarnings]
    /// For a repository, the branch that was read by name: the one requested, or else
    /// the branch a synchronization of this repository is set to read. Null when no
    /// branch is named or set and the repository's default branch was read, for a
    /// request by commit SHA, and for an uploaded archive.
    public var ref: String?
    /// How many plugins marketplace.json declares; 0 when it could not be read.
    public var totalPluginCount: Int
    /// Always `plugin_marketplace_validation_report`.
    public var type: String
    /// True when marketplace.json is well-formed and no plugin would be skipped;
    /// warnings never make it false.
    public var valid: Bool

    public init(commitSha: String? = nil, manifestError: String? = nil, manifestErrorCode: String? = nil, pluginErrors: [BetaPluginMarketplaceValidationPluginError], pluginWarnings: [BetaPluginMarketplaceValidationPluginWarnings], ref: String? = nil, totalPluginCount: Int, type: String = "plugin_marketplace_validation_report", valid: Bool) {
        self.commitSha = commitSha
        self.manifestError = manifestError
        self.manifestErrorCode = manifestErrorCode
        self.pluginErrors = pluginErrors
        self.pluginWarnings = pluginWarnings
        self.ref = ref
        self.totalPluginCount = totalPluginCount
        self.type = type
        self.valid = valid
    }

    enum CodingKeys: String, CodingKey {
        case commitSha = "commit_sha"
        case manifestError = "manifest_error"
        case manifestErrorCode = "manifest_error_code"
        case pluginErrors = "plugin_errors"
        case pluginWarnings = "plugin_warnings"
        case ref
        case totalPluginCount = "total_plugin_count"
        case type
        case valid
    }
}
