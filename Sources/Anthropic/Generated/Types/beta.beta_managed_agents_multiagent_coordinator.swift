// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_coordinator` (beta_managed_agents_multiagent_coordinator.py).

import Foundation

/// Resolved coordinator topology with a concrete agent roster.
public struct BetaManagedAgentsMultiagentCoordinator: Codable, Hashable, Sendable {
    /// Agents the coordinator may spawn as session threads, each resolved to a specific
    /// version.
    public var agents: [BetaManagedAgentsMultiagentCoordinator.Agent]
    public var type: String

    public init(agents: [BetaManagedAgentsMultiagentCoordinator.Agent], type: String = "coordinator") {
        self.agents = agents
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case agents
        case type
    }
}

extension BetaManagedAgentsMultiagentCoordinator {

    public indirect enum Agent: Codable, Hashable, Sendable {
        case agent(BetaManagedAgentsAgentReference)
        case advisor(BetaManagedAgentsAdvisor)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "agent": self = .agent(try BetaManagedAgentsAgentReference(from: decoder))
            case "advisor": self = .advisor(try BetaManagedAgentsAdvisor(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .agent(let v): try v.encode(to: encoder)
            case .advisor(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
