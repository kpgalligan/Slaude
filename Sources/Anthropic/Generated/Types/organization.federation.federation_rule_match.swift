// Transformed from `anthropic.types.organization.federation.federation_rule_match` (federation_rule_match.py).

import Foundation

/// Does the incoming JWT qualify?
///
/// All populated fields must pass; omitted fields are skipped. At least one
/// of `subject_prefix` (other than a wildcard-only value like `*`), `claims`,
/// or `condition` is required; `audience` alone is not sufficient.
public struct FederationRuleMatch: Codable, Hashable, Sendable {
    /// Exact match against the `aud` claim (any element if array).
    ///
    /// When omitted, the JWT's `aud` must still equal Anthropic's expected audience for
    /// the issuer; setting this field overrides that default.
    public var audience: String?
    /// Exact-match `{claim: value}` pairs against top-level claims.
    ///
    /// Only string-valued claims can be matched; use `condition` for non-string claims.
    public var claims: [String: String]?
    /// CEL expression over claims for logic the structural fields can't express.
    ///
    /// Must evaluate to a boolean and may reference only the `claims` variable; a
    /// constant-true expression (such as `true`) is rejected with 400.
    public var condition: String?
    /// Match the verified JWT `sub` claim.
    ///
    /// Exact match unless the value ends with `*`, in which case it is a prefix match.
    /// Example: `repo:my-org/my-repo:ref:refs/heads/main`.
    public var subjectPrefix: String?

    public init(audience: String? = nil, claims: [String: String]? = nil, condition: String? = nil, subjectPrefix: String? = nil) {
        self.audience = audience
        self.claims = claims
        self.condition = condition
        self.subjectPrefix = subjectPrefix
    }

    enum CodingKeys: String, CodingKey {
        case audience
        case claims
        case condition
        case subjectPrefix = "subject_prefix"
    }
}
