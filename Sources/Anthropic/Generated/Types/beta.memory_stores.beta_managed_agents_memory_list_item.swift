// Transformed from `anthropic.types.beta.memory_stores.beta_managed_agents_memory_list_item` (beta_managed_agents_memory_list_item.py).

import Foundation

public indirect enum BetaManagedAgentsMemoryListItem: Codable, Hashable, Sendable {
    case memory(BetaManagedAgentsMemory)
    case memoryPrefix(BetaManagedAgentsMemoryPrefix)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "memory": self = .memory(try BetaManagedAgentsMemory(from: decoder))
        case "memory_prefix": self = .memoryPrefix(try BetaManagedAgentsMemoryPrefix(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .memory(let v): try v.encode(to: encoder)
        case .memoryPrefix(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
