// Transformed from `anthropic.types.beta.organization.beta_aws_external_key_config` (beta_aws_external_key_config.py).

import Foundation

public struct BetaAWSExternalKeyConfig: Codable, Hashable, Sendable {
    /// Full ARN of the AWS KMS key.
    ///
    /// On Claude Platform on AWS the key must be a single-Region key in your
    /// organization's own AWS account; cross-account keys, multi-Region keys, and alias
    /// ARNs are rejected.
    public var kmsArn: String
    public var type: String
    /// AWS region. Derived from `kms_arn` if omitted.
    public var region: String?
    /// IAM role ARN.
    ///
    /// Deprecated — Anthropic reaches the KMS key through its own intermediate role
    /// (or, on Claude Platform on AWS, with credentials AWS issues for the Workspace);
    /// this field is ignored.
    public var roleArn: String?

    public init(kmsArn: String, type: String = "aws", region: String? = nil, roleArn: String? = nil) {
        self.kmsArn = kmsArn
        self.type = type
        self.region = region
        self.roleArn = roleArn
    }

    enum CodingKeys: String, CodingKey {
        case kmsArn = "kms_arn"
        case type
        case region
        case roleArn = "role_arn"
    }
}
