// Transformed from `anthropic.types.organization.gcp_external_key_config_param` (gcp_external_key_config_param.py).

import Foundation

public struct GCPExternalKeyConfigParam: Codable, Hashable, Sendable {
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
