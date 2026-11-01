// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_resource` (beta_managed_agents_session_resource.py).

import Foundation

public indirect enum BetaManagedAgentsSessionResource: Codable, Hashable, Sendable {
    case githubRepository(BetaManagedAgentsGitHubRepositoryResource)
    case file(BetaManagedAgentsFileResource)
    case memoryStore(BetaManagedAgentsMemoryStoreResource)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "github_repository": self = .githubRepository(try BetaManagedAgentsGitHubRepositoryResource(from: decoder))
        case "file": self = .file(try BetaManagedAgentsFileResource(from: decoder))
        case "memory_store": self = .memoryStore(try BetaManagedAgentsMemoryStoreResource(from: decoder))
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
