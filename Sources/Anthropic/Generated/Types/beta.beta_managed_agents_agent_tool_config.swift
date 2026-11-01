// Transformed from `anthropic.types.beta.beta_managed_agents_agent_tool_config` (beta_managed_agents_agent_tool_config.py).

import Foundation

public indirect enum BetaManagedAgentsAgentToolConfig: Codable, Hashable, Sendable {
    case bash(BetaManagedAgentsBashToolConfig)
    case edit(BetaManagedAgentsEditToolConfig)
    case read(BetaManagedAgentsReadToolConfig)
    case write(BetaManagedAgentsWriteToolConfig)
    case glob(BetaManagedAgentsGlobToolConfig)
    case grep(BetaManagedAgentsGrepToolConfig)
    case webFetch(BetaManagedAgentsWebFetchToolConfig)
    case webSearch(BetaManagedAgentsWebSearchToolConfig)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "bash": self = .bash(try BetaManagedAgentsBashToolConfig(from: decoder))
        case "edit": self = .edit(try BetaManagedAgentsEditToolConfig(from: decoder))
        case "read": self = .read(try BetaManagedAgentsReadToolConfig(from: decoder))
        case "write": self = .write(try BetaManagedAgentsWriteToolConfig(from: decoder))
        case "glob": self = .glob(try BetaManagedAgentsGlobToolConfig(from: decoder))
        case "grep": self = .grep(try BetaManagedAgentsGrepToolConfig(from: decoder))
        case "web_fetch": self = .webFetch(try BetaManagedAgentsWebFetchToolConfig(from: decoder))
        case "web_search": self = .webSearch(try BetaManagedAgentsWebSearchToolConfig(from: decoder))
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
