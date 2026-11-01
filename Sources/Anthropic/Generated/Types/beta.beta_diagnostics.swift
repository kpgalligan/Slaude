// Transformed from `anthropic.types.beta.beta_diagnostics` (beta_diagnostics.py).

import Foundation

/// Request-level diagnostics: why the prompt cache could not fully reuse
/// the prefix of the request named by `diagnostics.previous_message_id`.
public struct BetaDiagnostics: Codable, Hashable, Sendable {
    /// Explains why the prompt cache could not fully reuse the prefix from the request
    /// identified by `diagnostics.previous_message_id`. `null` means diagnosis is still
    /// pending — the response was serialized before the background comparison
    /// completed.
    public var cacheMissReason: BetaCacheMissReason?

    public init(cacheMissReason: BetaCacheMissReason? = nil) {
        self.cacheMissReason = cacheMissReason
    }

    enum CodingKeys: String, CodingKey {
        case cacheMissReason = "cache_miss_reason"
    }
}
