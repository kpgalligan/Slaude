// Transformed from `anthropic.types.organization.workspace_create_params` (workspace_create_params.py).

import Foundation

public struct WorkspaceCreateParams: Codable, Hashable, Sendable {
    /// Name of the Workspace.
    public var name: String
    /// Data residency configuration for the workspace.
    ///
    /// If omitted, defaults to `workspace_geo: "us"`,
    /// `allowed_inference_geos: "unrestricted"`, and `default_inference_geo: "global"`.
    public var dataResidency: DataResidencyCreateConfigParam??
    /// Hex color code representing the Workspace in the Anthropic Console.
    public var displayColor: String??
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
    public var externalKeyID: String??
    /// User-defined tags as string key-value pairs.
    ///
    /// Keys may not begin with `anthropic`.
    public var tags: [String: String]??

    public init(name: String, dataResidency: DataResidencyCreateConfigParam?? = nil, displayColor: String?? = nil, externalKeyID: String?? = nil, tags: [String: String]?? = nil) {
        self.name = name
        self.dataResidency = dataResidency
        self.displayColor = displayColor
        self.externalKeyID = externalKeyID
        self.tags = tags
    }

    enum CodingKeys: String, CodingKey {
        case name
        case dataResidency = "data_residency"
        case displayColor = "display_color"
        case externalKeyID = "external_key_id"
        case tags
    }
}
