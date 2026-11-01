// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_environment_variable_auth_response` (beta_managed_agents_environment_variable_auth_response.py).

import Foundation

/// Environment variable credential details. The secret value is never returned.
public struct BetaManagedAgentsEnvironmentVariableAuthResponse: Codable, Hashable, Sendable {
    /// Where in the outbound request the secret value is substituted.
    public var injectionLocation: BetaManagedAgentsInjectionLocationResponse
    /// Outbound hosts the secret value is substituted on.
    public var networking: BetaManagedAgentsEnvironmentVariableAuthResponse.Networking
    /// Name of the environment variable.
    public var secretName: String
    public var type: String

    public init(injectionLocation: BetaManagedAgentsInjectionLocationResponse, networking: BetaManagedAgentsEnvironmentVariableAuthResponse.Networking, secretName: String, type: String = "environment_variable") {
        self.injectionLocation = injectionLocation
        self.networking = networking
        self.secretName = secretName
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case injectionLocation = "injection_location"
        case networking
        case secretName = "secret_name"
        case type
    }
}

extension BetaManagedAgentsEnvironmentVariableAuthResponse {

    public indirect enum Networking: Codable, Hashable, Sendable {
        case unrestricted(BetaManagedAgentsUnrestrictedCredentialNetworkingResponse)
        case limited(BetaManagedAgentsLimitedCredentialNetworkingResponse)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "unrestricted": self = .unrestricted(try BetaManagedAgentsUnrestrictedCredentialNetworkingResponse(from: decoder))
            case "limited": self = .limited(try BetaManagedAgentsLimitedCredentialNetworkingResponse(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .unrestricted(let v): try v.encode(to: encoder)
            case .limited(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
