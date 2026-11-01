// Transformed from `anthropic.types.beta.beta_managed_agents_session_resource_config` (beta_managed_agents_session_resource_config.py).

import Foundation

public indirect enum BetaManagedAgentsSessionResourceConfig: Codable, Hashable, Sendable {
    case githubRepository(BetaManagedAgentsGitHubRepositoryResourceConfig)
    case file(BetaManagedAgentsFileResourceConfig)
    case memoryStore(BetaManagedAgentsMemoryStoreResourceConfig)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "github_repository": self = .githubRepository(try BetaManagedAgentsGitHubRepositoryResourceConfig(from: decoder))
        case "file": self = .file(try BetaManagedAgentsFileResourceConfig(from: decoder))
        case "memory_store": self = .memoryStore(try BetaManagedAgentsMemoryStoreResourceConfig(from: decoder))
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
