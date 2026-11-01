// Transformed from `anthropic.types.beta.beta_managed_agents_execution_identity_params` (beta_managed_agents_execution_identity_params.py).

import Foundation

public indirect enum BetaManagedAgentsExecutionIdentityParams: Codable, Hashable, Sendable {
    case awsRole(BetaManagedAgentsAWSRoleExecutionIdentityParams)
    case serviceAccount(BetaManagedAgentsServiceAccountExecutionIdentityParams)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "aws_role": self = .awsRole(try BetaManagedAgentsAWSRoleExecutionIdentityParams(from: decoder))
        case "service_account": self = .serviceAccount(try BetaManagedAgentsServiceAccountExecutionIdentityParams(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .awsRole(let v): try v.encode(to: encoder)
        case .serviceAccount(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
