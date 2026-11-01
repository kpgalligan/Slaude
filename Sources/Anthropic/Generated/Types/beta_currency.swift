// Transformed from `anthropic.types.beta_currency` (beta_currency.py).

import Foundation

public enum BetaCurrency: OpenEnum, CaseIterable {
    case usd
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaCurrency] = [.usd]

    public init(rawValue: String) {
        switch rawValue {
        case "USD": self = .usd
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .usd: return "USD"
        case .unknown(let value): return value
        }
    }
}
