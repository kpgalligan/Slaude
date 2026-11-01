// Transformed from `anthropic.types.beta.organization.beta_plugin_marketplace` (beta_plugin_marketplace.py).

import Foundation

public struct BetaPluginMarketplace: Codable, Hashable, Sendable {
    /// The plugin marketplace's ID, prefixed `marketplace_`.
    public var id: String
    /// RFC 3339.
    public var createdAt: Date
    /// Organization plugin marketplace: the organization-wide setting every Plugin in
    /// it with no setting of its own gets. Null for a member's personal plugin
    /// marketplace. One of `required`, `auto_install`, `available`, `not_available`; a
    /// value this API does not yet name is returned as stored.
    public var defaultInstallationPreference: DefaultInstallationPreference?
    /// RFC 3339.
    ///
    /// When the most recent synchronization attempt to finish did so, whatever its
    /// outcome; for a repository plugin marketplace no synchronization has run on yet,
    /// when it was created. Null for a plugin marketplace that is not synchronized from
    /// a repository.
    public var lastSyncEndedAt: Date?
    /// The commit the last synchronization attempt that reached the repository read,
    /// whether or not its content was then accepted (see `sync_status`); an attempt
    /// that ends `failed_auth` or `failed_transient` leaves it unchanged. Null until an
    /// attempt has first read the repository, and for a plugin marketplace that is not
    /// synchronized from a repository.
    public var lastSyncReadSha: String?
    /// Fixed for the plugin marketplace's lifetime.
    public var name: String
    /// The organization, or the member whose personal plugin marketplace it is.
    public var owner: BetaPluginMarketplace.Owner
    /// Where the plugin marketplace's Plugins come from: `manual` when they are
    /// uploaded; `github`, `gitlab` or `public_git` when they are synchronized from the
    /// Git repository the owner connected, into which nothing can be uploaded;
    /// `directory` is Anthropic's own catalog, which this API does not list. A value
    /// this API does not yet name is returned as stored.
    public var source: Source
    /// Outcome of the plugin marketplace's most recent synchronization: one of
    /// `success`, `in_progress`, `failed_content`, `failed_transient`, `failed_auth`,
    /// `failed_limits`; a value this API does not yet name is returned as stored. Null
    /// until a synchronization is first attempted — so always for a `manual` plugin
    /// marketplace.
    public var syncStatus: SyncStatus?
    /// Always `plugin_marketplace`.
    public var type: String

    public init(id: String, createdAt: Date, defaultInstallationPreference: DefaultInstallationPreference? = nil, lastSyncEndedAt: Date? = nil, lastSyncReadSha: String? = nil, name: String, owner: BetaPluginMarketplace.Owner, source: Source, syncStatus: SyncStatus? = nil, type: String = "plugin_marketplace") {
        self.id = id
        self.createdAt = createdAt
        self.defaultInstallationPreference = defaultInstallationPreference
        self.lastSyncEndedAt = lastSyncEndedAt
        self.lastSyncReadSha = lastSyncReadSha
        self.name = name
        self.owner = owner
        self.source = source
        self.syncStatus = syncStatus
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case defaultInstallationPreference = "default_installation_preference"
        case lastSyncEndedAt = "last_sync_ended_at"
        case lastSyncReadSha = "last_sync_read_sha"
        case name
        case owner
        case source
        case syncStatus = "sync_status"
        case type
    }

    public enum DefaultInstallationPreference: OpenEnum, CaseIterable {
        case autoInstall
        case available
        case notAvailable
        case required
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [DefaultInstallationPreference] = [.autoInstall, .available, .notAvailable, .required]

        public init(rawValue: String) {
            switch rawValue {
            case "auto_install": self = .autoInstall
            case "available": self = .available
            case "not_available": self = .notAvailable
            case "required": self = .required
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .autoInstall: return "auto_install"
            case .available: return "available"
            case .notAvailable: return "not_available"
            case .required: return "required"
            case .unknown(let value): return value
            }
        }
    }

    public enum Source: OpenEnum, CaseIterable {
        case directory
        case github
        case gitlab
        case manual
        case publicGit
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Source] = [.directory, .github, .gitlab, .manual, .publicGit]

        public init(rawValue: String) {
            switch rawValue {
            case "directory": self = .directory
            case "github": self = .github
            case "gitlab": self = .gitlab
            case "manual": self = .manual
            case "public_git": self = .publicGit
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .directory: return "directory"
            case .github: return "github"
            case .gitlab: return "gitlab"
            case .manual: return "manual"
            case .publicGit: return "public_git"
            case .unknown(let value): return value
            }
        }
    }

    public enum SyncStatus: OpenEnum, CaseIterable {
        case failedAuth
        case failedContent
        case failedLimits
        case failedTransient
        case inProgress
        case success
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [SyncStatus] = [.failedAuth, .failedContent, .failedLimits, .failedTransient, .inProgress, .success]

        public init(rawValue: String) {
            switch rawValue {
            case "failed_auth": self = .failedAuth
            case "failed_content": self = .failedContent
            case "failed_limits": self = .failedLimits
            case "failed_transient": self = .failedTransient
            case "in_progress": self = .inProgress
            case "success": self = .success
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .failedAuth: return "failed_auth"
            case .failedContent: return "failed_content"
            case .failedLimits: return "failed_limits"
            case .failedTransient: return "failed_transient"
            case .inProgress: return "in_progress"
            case .success: return "success"
            case .unknown(let value): return value
            }
        }
    }
}

extension BetaPluginMarketplace {

    public indirect enum Owner: Codable, Hashable, Sendable {
        case organization(BetaPluginOwnerOrganization)
        case user(BetaPluginOwnerUser)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "organization": self = .organization(try BetaPluginOwnerOrganization(from: decoder))
            case "user": self = .user(try BetaPluginOwnerUser(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .organization(let v): try v.encode(to: encoder)
            case .user(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
