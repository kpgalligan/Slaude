// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_environment_variable_create_params` (beta_managed_agents_environment_variable_create_params.py).

import Foundation

/// Parameters for creating an environment variable credential.
public struct BetaManagedAgentsEnvironmentVariableCreateParams: Codable, Hashable, Sendable {
    /// Outbound hosts the secret value is substituted on.
    public var networking: BetaManagedAgentsCredentialNetworkingParams
    /// Name of the environment variable. Immutable after create.
    public var secretName: String
    /// The secret to substitute into the agent's outbound requests.
    ///
    /// It's write-only and never returned in responses.
    public var secretValue: String
    public var type: String
    /// Where in the outbound request the secret value may be substituted.
    public var injectionLocation: BetaManagedAgentsInjectionLocationParams?

    public init(networking: BetaManagedAgentsCredentialNetworkingParams, secretName: String, secretValue: String, type: String = "environment_variable", injectionLocation: BetaManagedAgentsInjectionLocationParams? = nil) {
        self.networking = networking
        self.secretName = secretName
        self.secretValue = secretValue
        self.type = type
        self.injectionLocation = injectionLocation
    }

    enum CodingKeys: String, CodingKey {
        case networking
        case secretName = "secret_name"
        case secretValue = "secret_value"
        case type
        case injectionLocation = "injection_location"
    }
}
