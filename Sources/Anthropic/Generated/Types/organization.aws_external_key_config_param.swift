// Transformed from `anthropic.types.organization.aws_external_key_config_param` (aws_external_key_config_param.py).

import Foundation

public struct AWSExternalKeyConfigParam: Codable, Hashable, Sendable {
    /// Full ARN of the AWS KMS key.
    ///
    /// On Claude Platform on AWS the key must be a single-Region key in your
    /// organization's own AWS account; cross-account keys, multi-Region keys, and alias
    /// ARNs are rejected.
    public var kmsArn: String
    public var type: String
    /// AWS region. Derived from `kms_arn` if omitted.
    public var region: String??

    public init(kmsArn: String, type: String = "aws", region: String?? = nil) {
        self.kmsArn = kmsArn
        self.type = type
        self.region = region
    }

    enum CodingKeys: String, CodingKey {
        case kmsArn = "kms_arn"
        case type
        case region
    }
}
