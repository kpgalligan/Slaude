// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_environment_variable_update_params` (beta_managed_agents_environment_variable_update_params.py).

import Foundation

/// Parameters for updating an environment variable credential.
///
/// `secret_name` is immutable.
public struct BetaManagedAgentsEnvironmentVariableUpdateParams: Codable, Hashable, Sendable {
    public var type: String
    /// Updated injection location.
    public var injectionLocation: BetaManagedAgentsInjectionLocationUpdateParams?
    /// The new networking scope, which replaces the stored one as a whole.
    public var networking: BetaManagedAgentsCredentialNetworkingParams??
    /// The new secret value to replace the stored one.
    public var secretValue: String??

    public init(type: String = "environment_variable", injectionLocation: BetaManagedAgentsInjectionLocationUpdateParams? = nil, networking: BetaManagedAgentsCredentialNetworkingParams?? = nil, secretValue: String?? = nil) {
        self.type = type
        self.injectionLocation = injectionLocation
        self.networking = networking
        self.secretValue = secretValue
    }

    enum CodingKeys: String, CodingKey {
        case type
        case injectionLocation = "injection_location"
        case networking
        case secretValue = "secret_value"
    }
}
