// Transformed from `anthropic.types.beta.organization.plugins.beta_plugin_version` (beta_plugin_version.py).

import Foundation

public struct BetaPluginVersion: Codable, Hashable, Sendable {
    /// The version's ID.
    public var id: String
    /// What the version contains; null when not enumerated.
    public var components: [BetaPluginComponent]?
    /// This version's content scan; null when it has not been scanned.
    public var contentScan: BetaPluginContentScan?
    /// RFC 3339.
    public var createdAt: Date
    /// Who uploaded this version; null when not recorded.
    public var createdBy: BetaPluginVersion.CreatedBy??
    /// The manifest's description; null when it declares none.
    public var description: String?
    /// The manifest's display name; null when it declares none.
    public var displayName: String?
    /// The manifest's `version`, normalized for display: one leading `v` or `V` is
    /// dropped, and the result is returned only if it is 1 to 64 characters, starts
    /// with a digit, and uses only ASCII letters, digits, `.`, `+`, and `-`; otherwise
    /// `null`. For example, `"v1.4.0"` is returned as `"1.4.0"`, and `"latest"` as
    /// `null`. For a synchronized plugin, the `version` of its `marketplace.json` entry
    /// can take the place of the manifest's `version`. It is also `null` for a version
    /// stored before claude.ai began recording this field (August 2026).
    public var manifestVersion: String?
    /// The Plugin's ID.
    public var pluginId: String
    /// How far the version reaches: `remote`, `privileged`, `contained`, or `null`, as
    /// defined on the Plugin's `reach`.
    public var reach: Reach?
    /// As supplied with the upload; null when none were supplied.
    public var releaseNotes: String?
    /// Always `plugin_version`.
    public var type: String

    public init(id: String, components: [BetaPluginComponent]? = nil, contentScan: BetaPluginContentScan? = nil, createdAt: Date, createdBy: BetaPluginVersion.CreatedBy?? = nil, description: String? = nil, displayName: String? = nil, manifestVersion: String? = nil, pluginId: String, reach: Reach? = nil, releaseNotes: String? = nil, type: String = "plugin_version") {
        self.id = id
        self.components = components
        self.contentScan = contentScan
        self.createdAt = createdAt
        self.createdBy = createdBy
        self.description = description
        self.displayName = displayName
        self.manifestVersion = manifestVersion
        self.pluginId = pluginId
        self.reach = reach
        self.releaseNotes = releaseNotes
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case components
        case contentScan = "content_scan"
        case createdAt = "created_at"
        case createdBy = "created_by"
        case description
        case displayName = "display_name"
        case manifestVersion = "manifest_version"
        case pluginId = "plugin_id"
        case reach
        case releaseNotes = "release_notes"
        case type
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

extension BetaPluginVersion {

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
}
