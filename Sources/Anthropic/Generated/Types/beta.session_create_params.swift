// Transformed from `anthropic.types.beta.session_create_params` (session_create_params.py).

import Foundation

public struct SessionCreateParams: Codable, Hashable, Sendable {
    /// Agent identifier.
    ///
    /// Accepts the `agent` ID string, which pins the latest version for the session, or
    /// an `agent` object with both id and version specified.
    public var agent: SessionCreateParams.Agent
    /// ID of the `environment` defining the container configuration for this session.
    public var environmentID: String
    /// Enforced spend ceiling for the session.
    ///
    /// Omit to create an uncapped session. Every model the session can run — the
    /// agent's model and each callable agent's model — must have a public list price,
    /// or the request is rejected with reason `model_not_budgetable`.
    public var budget: BetaManagedAgentsBudgetLimitParam?
    /// Initial events to send to the `session` at creation, processed in order.
    ///
    /// Supports `user.message` and `user.define_outcome` events. Maximum 50 events.
    public var initialEvents: [SessionCreateParams.InitialEvent]?
    /// Arbitrary key-value metadata attached to the session.
    ///
    /// Maximum 16 pairs, keys up to 64 chars, values up to 512 chars.
    public var metadata: [String: String]?
    /// Resources (e.g. repositories, files) to mount into the session's container.
    public var resources: [SessionCreateParams.Resource]?
    /// Human-readable session title.
    public var title: String??
    /// Vault IDs for stored credentials the agent can use during the session.
    public var vaultIDs: [String]?
    /// This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(agent: SessionCreateParams.Agent, environmentID: String, budget: BetaManagedAgentsBudgetLimitParam? = nil, initialEvents: [SessionCreateParams.InitialEvent]? = nil, metadata: [String: String]? = nil, resources: [SessionCreateParams.Resource]? = nil, title: String?? = nil, vaultIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.agent = agent
        self.environmentID = environmentID
        self.budget = budget
        self.initialEvents = initialEvents
        self.metadata = metadata
        self.resources = resources
        self.title = title
        self.vaultIDs = vaultIDs
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case agent
        case environmentID = "environment_id"
        case budget
        case initialEvents = "initial_events"
        case metadata
        case resources
        case title
        case vaultIDs = "vault_ids"
        case betas
        case workspaceID = "workspace_id"
    }
}

extension SessionCreateParams {

    public indirect enum Agent: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case betaManagedAgentsAgentParams(BetaManagedAgentsAgentParams)
        case betaManagedAgentsAgentWithOverridesParams(BetaManagedAgentsAgentWithOverridesParams)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if _Coding.constantsMatch(decoder, ["type": "agent"]), let v = try? BetaManagedAgentsAgentParams(from: decoder) { self = .betaManagedAgentsAgentParams(v); return }
            if _Coding.constantsMatch(decoder, ["type": "agent_with_overrides"]), let v = try? BetaManagedAgentsAgentWithOverridesParams(from: decoder) { self = .betaManagedAgentsAgentWithOverridesParams(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .betaManagedAgentsAgentParams(let v): try v.encode(to: encoder)
            case .betaManagedAgentsAgentWithOverridesParams(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

    public indirect enum InitialEvent: Codable, Hashable, Sendable {
        case userMessage(BetaManagedAgentsUserMessageEventParams)
        case userDefineOutcome(BetaManagedAgentsUserDefineOutcomeEventParams)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "user.message": self = .userMessage(try BetaManagedAgentsUserMessageEventParams(from: decoder))
            case "user.define_outcome": self = .userDefineOutcome(try BetaManagedAgentsUserDefineOutcomeEventParams(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .userMessage(let v): try v.encode(to: encoder)
            case .userDefineOutcome(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

    public indirect enum Resource: Codable, Hashable, Sendable {
        case githubRepository(BetaManagedAgentsGitHubRepositoryResourceParams)
        case file(BetaManagedAgentsFileResourceParams)
        case memoryStore(BetaManagedAgentsMemoryStoreResourceParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "github_repository": self = .githubRepository(try BetaManagedAgentsGitHubRepositoryResourceParams(from: decoder))
            case "file": self = .file(try BetaManagedAgentsFileResourceParams(from: decoder))
            case "memory_store": self = .memoryStore(try BetaManagedAgentsMemoryStoreResourceParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .githubRepository(let v): try v.encode(to: encoder)
            case .file(let v): try v.encode(to: encoder)
            case .memoryStore(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
