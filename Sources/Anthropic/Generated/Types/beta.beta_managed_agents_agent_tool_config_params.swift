// Transformed from `anthropic.types.beta.beta_managed_agents_agent_tool_config_params` (beta_managed_agents_agent_tool_config_params.py).

import Foundation

public indirect enum BetaManagedAgentsAgentToolConfigParams: Codable, Hashable, Sendable {
    case bash(BetaManagedAgentsBashToolConfigParams)
    case edit(BetaManagedAgentsEditToolConfigParams)
    case read(BetaManagedAgentsReadToolConfigParams)
    case write(BetaManagedAgentsWriteToolConfigParams)
    case glob(BetaManagedAgentsGlobToolConfigParams)
    case grep(BetaManagedAgentsGrepToolConfigParams)
    case webFetch(BetaManagedAgentsWebFetchToolConfigParams)
    case webSearch(BetaManagedAgentsWebSearchToolConfigParams)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "bash": self = .bash(try BetaManagedAgentsBashToolConfigParams(from: decoder))
        case "edit": self = .edit(try BetaManagedAgentsEditToolConfigParams(from: decoder))
        case "read": self = .read(try BetaManagedAgentsReadToolConfigParams(from: decoder))
        case "write": self = .write(try BetaManagedAgentsWriteToolConfigParams(from: decoder))
        case "glob": self = .glob(try BetaManagedAgentsGlobToolConfigParams(from: decoder))
        case "grep": self = .grep(try BetaManagedAgentsGrepToolConfigParams(from: decoder))
        case "web_fetch": self = .webFetch(try BetaManagedAgentsWebFetchToolConfigParams(from: decoder))
        case "web_search": self = .webSearch(try BetaManagedAgentsWebSearchToolConfigParams(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .bash(let v): try v.encode(to: encoder)
        case .edit(let v): try v.encode(to: encoder)
        case .read(let v): try v.encode(to: encoder)
        case .write(let v): try v.encode(to: encoder)
        case .glob(let v): try v.encode(to: encoder)
        case .grep(let v): try v.encode(to: encoder)
        case .webFetch(let v): try v.encode(to: encoder)
        case .webSearch(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
