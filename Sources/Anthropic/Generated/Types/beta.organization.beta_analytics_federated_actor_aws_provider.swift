// Transformed from `anthropic.types.beta.organization.beta_analytics_federated_actor_aws_provider` (beta_analytics_federated_actor_aws_provider.py).

import Foundation

public struct BetaAnalyticsFederatedActorAWSProvider: Codable, Hashable, Sendable {
    /// The AWS account the organization is bound to.
    public var accountID: String
    /// The AWS-signed ARN of the IAM principal that made the requests.
    public var signedPrincipal: String
    public var type: String

    public init(accountID: String, signedPrincipal: String, type: String = "aws") {
        self.accountID = accountID
        self.signedPrincipal = signedPrincipal
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case accountID = "account_id"
        case signedPrincipal = "signed_principal"
        case type
    }
}
