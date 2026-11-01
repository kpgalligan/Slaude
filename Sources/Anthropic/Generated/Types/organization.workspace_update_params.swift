// Transformed from `anthropic.types.organization.workspace_update_params` (workspace_update_params.py).

import Foundation

public struct WorkspaceUpdateParams: Codable, Hashable, Sendable {
    /// Data residency configuration for the workspace.
    public var dataResidency: DataResidencyUpdateConfigParam??
    /// Hex color code representing the Workspace in the Anthropic Console.
    public var displayColor: String?
    /// ID of the customer-managed encryption key (CMEK) configuration to use for this
    /// Workspace. Setting this field requires CMEK to be enabled for your organization.
    /// When set, data stored for this Workspace is encrypted with the referenced key.
    /// Create key configurations with the External Keys API. On Claude Platform on AWS
    /// the value is the AWS KMS key ARN, and the key must be a single-Region key in the
    /// same AWS account and Region as the Workspace. On that platform the key is
    /// validated against this Workspace when it is attached, so a key-policy problem is
    /// reported as an error on this request. This field is write-once: once a key is
    /// attached to a Workspace it cannot be detached or replaced. To rotate key
    /// material, rotate the underlying key on your cloud KMS; the `external_key_id`
    /// stays the same.
    public var externalKeyId: String?
    /// Name of the Workspace.
    public var name: String?
    /// User-defined tags as string key-value pairs.
    ///
    /// Keys may not begin with `anthropic`.
    public var tags: [String: String?]??

    public init(dataResidency: DataResidencyUpdateConfigParam?? = nil, displayColor: String? = nil, externalKeyId: String? = nil, name: String? = nil, tags: [String: String?]?? = nil) {
        self.dataResidency = dataResidency
        self.displayColor = displayColor
        self.externalKeyId = externalKeyId
        self.name = name
        self.tags = tags
    }

    enum CodingKeys: String, CodingKey {
        case dataResidency = "data_residency"
        case displayColor = "display_color"
        case externalKeyId = "external_key_id"
        case name
        case tags
    }
}
