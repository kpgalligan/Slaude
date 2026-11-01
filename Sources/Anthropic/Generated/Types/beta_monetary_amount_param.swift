// Transformed from `anthropic.types.beta_monetary_amount_param` (beta_monetary_amount_param.py).

import Foundation

/// A monetary amount in a specific currency.
public struct BetaMonetaryAmountParam: Codable, Hashable, Sendable {
    /// Amount in minor units of the currency, as an integer decimal string with no
    /// leading zeros: "2500" is $25.00 and "50" is fifty cents. A string rather than a
    /// number so no float rounding is ever applied.
    public var amount: String
    /// Uppercase ISO-4217 currency code.
    ///
    /// `USD` is the only currency currently supported; the accepted set is closed and
    /// grows only when a new currency is priced.
    public var currency: BetaCurrency

    public init(amount: String, currency: BetaCurrency) {
        self.amount = amount
        self.currency = currency
    }

    enum CodingKeys: String, CodingKey {
        case amount
        case currency
    }
}
