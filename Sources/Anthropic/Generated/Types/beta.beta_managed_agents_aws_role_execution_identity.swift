// Transformed from `anthropic.types.beta.beta_managed_agents_aws_role_execution_identity` (beta_managed_agents_aws_role_execution_identity.py).

import Foundation

/// An AWS IAM role principal as returned in API responses.
public struct BetaManagedAgentsAWSRoleExecutionIdentity: Codable, Hashable, Sendable {
    /// The IAM role's ARN.
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
