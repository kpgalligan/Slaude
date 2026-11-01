// Transformed from `anthropic.types.beta.organization.beta_gcp_external_key_config` (beta_gcp_external_key_config.py).

import Foundation

public struct BetaGCPExternalKeyConfig: Codable, Hashable, Sendable {
    /// Full resource name of the Cloud KMS key.
    public var keyName: String
    public var type: String

    public init(keyName: String, type: String = "gcp") {
        self.keyName = keyName
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case keyName = "key_name"
        case type
    }
}
