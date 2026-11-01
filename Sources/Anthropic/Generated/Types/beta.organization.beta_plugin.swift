// Transformed from `anthropic.types.beta.organization.beta_plugin` (beta_plugin.py).

import Foundation

public struct BetaPlugin: Codable, Hashable, Sendable {
    /// The Plugin's ID.
    public var id: String
    /// What the served version contains; null when not enumerated.
    public var components: [BetaPluginComponent]?
    /// The served version's content scan; null when it has not been scanned.
    public var contentScan: BetaPluginContentScan?
    /// RFC 3339.
    public var createdAt: Date
    /// Who created the Plugin; null when no creator is recorded.
    public var createdBy: BetaPlugin.CreatedBy??
    /// The served version's description.
    public var description: String?
    /// The served version's display name.
    public var displayName: String?
    /// The newest version.
    public var latestVersionId: String
    /// The served version's manifest `version`, normalized for display, or `null` (the
    /// Plugin Version's `manifest_version` says how and when).
    public var manifestVersion: String?
    /// The ID of the plugin marketplace the Plugin lives in.
    public var marketplaceId: String
    /// Lowercase identifier, unique within its plugin marketplace.
    ///
    /// Fixed for an organization-owned Plugin's lifetime; a member-owned Plugin's
    /// changes when its owner renames it in claude.ai, while its `id` stays the same.
    public var name: String
    /// Organization-owned Plugin: the organization-wide installation setting every
    /// member gets unless an RBAC Group they belong to holds its own — the Plugin's own
    /// setting, or its plugin marketplace's default. Null for a member-owned Plugin,
    /// which has shares instead. One of `required`, `auto_install`, `available`,
    /// `not_available`; a value this API does not yet name is returned as stored.
    public var organizationInstallationPreference: OrganizationInstallationPreference?
    /// Organization-owned Plugin: true while it has no organization-wide setting of its
    /// own and `organization_installation_preference` is its plugin marketplace's
    /// default. Null for a member-owned Plugin.
    public var organizationInstallationPreferenceInherited: Bool?
    /// Who owns the Plugin: the organization, or the member whose personal plugin
    /// marketplace it lives in.
    public var owner: BetaPlugin.Owner
    /// How far the served version reaches, or `null` if it is not classified.
    ///
    /// `remote` means it declares an MCP server or a CLI. `privileged` means it
    /// declares no MCP server or CLI, but declares a hook, monitor, language server, or
    /// settings, or has a skill, command, or other Markdown file whose frontmatter
    /// pre-approves tools (`allowed-tools` with any value other than an empty one or
    /// one that names only `AskUserQuestion`, `TodoWrite`, and `ToolSearch`). Otherwise
    /// it is `contained`.
    ///
    /// If the frontmatter of a skill, command, or other Markdown file that could change
    /// the value could not be read, or was past a size limit, the version is `null` or
    /// `privileged` (or `remote`, if it declares an MCP server or a CLI), not
    /// `contained`. The value is normally worked out when a version is stored, under
    /// the rules of that time, so an older version can be `null`, or `contained` where
    /// the same files stored today would be `privileged` or `null`.
    public var reach: Reach?
    /// The version claude.ai serves to members.
    public var servedVersionId: String
    /// True once the served version has been pinned, through Update Plugin or in
    /// claude.ai. While false, a new version normally becomes the served version when
    /// it is stored. While the newest version is not the served version, as when a
    /// version saved in claude.ai is waiting for its content scan, `served_version_id`
    /// differs from `latest_version_id`.
    public var servedVersionPinned: Bool
    /// Always `plugin`.
    public var type: String
    /// RFC 3339.
    ///
    /// Moves on a served-version change (including pinning an unpinned Plugin to the
    /// version it already serves) and, normally, on a new version. A version saved in
    /// claude.ai that waits for its content scan moves it when it becomes the served
    /// version, and not necessarily when it is stored. A change to the Plugin's
    /// installation settings or shares does not move it.
    public var updatedAt: Date

    public init(id: String, components: [BetaPluginComponent]? = nil, contentScan: BetaPluginContentScan? = nil, createdAt: Date, createdBy: BetaPlugin.CreatedBy?? = nil, description: String? = nil, displayName: String? = nil, latestVersionId: String, manifestVersion: String? = nil, marketplaceId: String, name: String, organizationInstallationPreference: OrganizationInstallationPreference? = nil, organizationInstallationPreferenceInherited: Bool? = nil, owner: BetaPlugin.Owner, reach: Reach? = nil, servedVersionId: String, servedVersionPinned: Bool, type: String = "plugin", updatedAt: Date) {
        self.id = id
        self.components = components
        self.contentScan = contentScan
        self.createdAt = createdAt
        self.createdBy = createdBy
        self.description = description
        self.displayName = displayName
        self.latestVersionId = latestVersionId
        self.manifestVersion = manifestVersion
        self.marketplaceId = marketplaceId
        self.name = name
        self.organizationInstallationPreference = organizationInstallationPreference
        self.organizationInstallationPreferenceInherited = organizationInstallationPreferenceInherited
        self.owner = owner
        self.reach = reach
        self.servedVersionId = servedVersionId
        self.servedVersionPinned = servedVersionPinned
        self.type = type
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case components
        case contentScan = "content_scan"
        case createdAt = "created_at"
        case createdBy = "created_by"
        case description
        case displayName = "display_name"
        case latestVersionId = "latest_version_id"
        case manifestVersion = "manifest_version"
        case marketplaceId = "marketplace_id"
        case name
        case organizationInstallationPreference = "organization_installation_preference"
        case organizationInstallationPreferenceInherited = "organization_installation_preference_inherited"
        case owner
        case reach
        case servedVersionId = "served_version_id"
        case servedVersionPinned = "served_version_pinned"
        case type
        case updatedAt = "updated_at"
    }

    public enum OrganizationInstallationPreference: OpenEnum, CaseIterable {
        case autoInstall
        case available
        case notAvailable
        case required
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [OrganizationInstallationPreference] = [.autoInstall, .available, .notAvailable, .required]

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

    public enum Reach: OpenEnum, CaseIterable {
        case contained
        case privileged
        case remote
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Reach] = [.contained, .privileged, .remote]

        public init(rawValue: String) {
            switch rawValue {
            case "contained": self = .contained
            case "privileged": self = .privileged
            case "remote": self = .remote
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .contained: return "contained"
            case .privileged: return "privileged"
            case .remote: return "remote"
            case .unknown(let value): return value
            }
        }
    }
}

extension BetaPlugin {

    public indirect enum CreatedBy: Codable, Hashable, Sendable {
        case userActor(BetaPluginUserActor)
        case apiActor(BetaPluginAPIActor)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "user_actor": self = .userActor(try BetaPluginUserActor(from: decoder))
            case "api_actor": self = .apiActor(try BetaPluginAPIActor(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .userActor(let v): try v.encode(to: encoder)
            case .apiActor(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

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
