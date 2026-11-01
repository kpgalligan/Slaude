// Transformed from `anthropic.types.beta.environment_create_params` (environment_create_params.py).

import Foundation

public struct EnvironmentCreateParams: Codable, Hashable, Sendable {
    /// Human-readable name for the environment
    public var name: String
    /// Environment configuration
    public var config: EnvironmentCreateParams.Config??
    /// Optional description of the environment
    public var description: String??
    /// User-provided metadata key-value pairs
    public var metadata: [String: String]?
    /// The visibility scope for this environment.
    ///
    /// 'organization' makes the environment visible to all accounts. 'account'
    /// restricts visibility to the owning account only. API organizations support only
    /// 'organization'; 'account' is rejected. If not specified, defaults based on
    /// organization type.
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
    public var workspaceId: String?

    public init(name: String, config: EnvironmentCreateParams.Config?? = nil, description: String?? = nil, metadata: [String: String]? = nil, scope: Scope?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.name = name
        self.config = config
        self.description = description
        self.metadata = metadata
        self.scope = scope
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case name
        case config
        case description
        case metadata
        case scope
        case betas
        case workspaceId = "workspace_id"
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

extension EnvironmentCreateParams {

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
