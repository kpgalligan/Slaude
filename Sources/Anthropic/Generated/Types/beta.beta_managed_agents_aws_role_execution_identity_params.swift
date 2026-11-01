// Transformed from `anthropic.types.beta.beta_managed_agents_aws_role_execution_identity_params` (beta_managed_agents_aws_role_execution_identity_params.py).

import Foundation

/// An AWS IAM role principal.
public struct BetaManagedAgentsAWSRoleExecutionIdentityParams: Codable, Hashable, Sendable {
    /// The IAM role's ARN, e.g.
    ///
    /// "arn:aws:iam::123456789012:role/my-agent-runner". Maximum 2048 characters.
    public var roleArn: String
    public var type: String

    public init(roleArn: String, type: String = "aws_role") {
        self.roleArn = roleArn
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case roleArn = "role_arn"
        case type
    }
}
