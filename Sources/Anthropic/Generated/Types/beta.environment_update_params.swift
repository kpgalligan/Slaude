// Transformed from `anthropic.types.beta.environment_update_params` (environment_update_params.py).

import Foundation

public struct EnvironmentUpdateParams: Codable, Hashable, Sendable {
    /// Updated environment configuration
    public var config: EnvironmentUpdateParams.Config??
    /// Updated description of the environment.
    ///
    /// Omit to preserve; null clears to null; an empty string is stored as an empty
    /// string.
    public var description: String??
    /// User-provided metadata key-value pairs.
    ///
    /// Set a value to null or empty string to delete the key.
    public var metadata: [String: String?]?
    /// Updated name for the environment
    public var name: String??
    /// The visibility scope for this environment.
    ///
    /// 'organization' makes the environment visible to all accounts. 'account'
    /// restricts visibility to the owning account only.
    public var scope: Scope??
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(config: EnvironmentUpdateParams.Config?? = nil, description: String?? = nil, metadata: [String: String?]? = nil, name: String?? = nil, scope: Scope?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.config = config
        self.description = description
        self.metadata = metadata
        self.name = name
        self.scope = scope
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case config
        case description
        case metadata
        case name
        case scope
        case betas
        case workspaceID = "workspace_id"
    }

    public enum Scope: OpenEnum, CaseIterable {
        case organization
        case account
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Scope] = [.organization, .account]

        public init(rawValue: String) {
            switch rawValue {
            case "organization": self = .organization
            case "account": self = .account
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .organization: return "organization"
            case .account: return "account"
            case .unknown(let value): return value
            }
        }
    }
}

extension EnvironmentUpdateParams {

    public indirect enum Config: Codable, Hashable, Sendable {
        case cloud(BetaCloudConfigParams)
        case selfHosted(BetaSelfHostedConfigParams)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "cloud": self = .cloud(try BetaCloudConfigParams(from: decoder))
            case "self_hosted": self = .selfHosted(try BetaSelfHostedConfigParams(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .cloud(let v): try v.encode(to: encoder)
            case .selfHosted(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
