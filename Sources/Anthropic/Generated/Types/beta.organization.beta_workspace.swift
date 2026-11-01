// Transformed from `anthropic.types.beta.organization.beta_workspace` (beta_workspace.py).

import Foundation

public struct BetaWorkspace: Codable, Hashable, Sendable {
    /// ID of the Workspace.
    public var id: String
    /// RFC 3339 datetime string indicating when the Workspace was archived, or `null`
    /// if the Workspace is not archived.
    public var archivedAt: Date?
    /// Identifier for this Workspace's encryption compartment.
    ///
    /// When you configure a customer-managed encryption key (CMEK) on AWS, reference
    /// this value in your KMS key-policy condition so the key is scoped to this
    /// compartment. On GCP and Azure, Anthropic enforces the compartment binding
    /// automatically; you do not need to reference this value in your key
    /// configuration. See the CMEK integration guide for the required key
    /// configuration; unless your organization is on Claude Platform on AWS, it
    /// includes a separate value used during key validation. On Claude Platform on AWS
    /// there is no separate validation value: the key is validated against this
    /// Workspace's own value when it is attached, so if your key policy uses the
    /// compartment condition, add this value to it before attaching the key.
    public var compartmentID: String
    /// RFC 3339 datetime string indicating when the Workspace was created.
    public var createdAt: Date
    /// Data residency configuration.
    public var dataResidency: BetaDataResidency
    /// Hex color code representing the Workspace in the Anthropic Console.
    public var displayColor: String
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
    public var externalKeyID: String?
    /// Name of the Workspace.
    public var name: String
    /// User-defined tags as string key-value pairs.
    ///
    /// Keys may not begin with `anthropic`.
    public var tags: [String: String]
    /// Object type.
    ///
    /// For Workspaces, this is always `"workspace"`.
    public var type: String

    public init(id: String, archivedAt: Date? = nil, compartmentID: String, createdAt: Date, dataResidency: BetaDataResidency, displayColor: String, externalKeyID: String? = nil, name: String, tags: [String: String], type: String = "workspace") {
        self.id = id
        self.archivedAt = archivedAt
        self.compartmentID = compartmentID
        self.createdAt = createdAt
        self.dataResidency = dataResidency
        self.displayColor = displayColor
        self.externalKeyID = externalKeyID
        self.name = name
        self.tags = tags
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case archivedAt = "archived_at"
        case compartmentID = "compartment_id"
        case createdAt = "created_at"
        case dataResidency = "data_residency"
        case displayColor = "display_color"
        case externalKeyID = "external_key_id"
        case name
        case tags
        case type
    }
}
