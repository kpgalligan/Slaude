import Foundation

/// A webhook failed [Standard Webhooks](https://www.standardwebhooks.com) verification
/// (`standardwebhooks.WebhookVerificationError`).
public struct WebhookVerificationError: Error, CustomStringConvertible, LocalizedError, Sendable, Equatable {
    public let message: String
    public init(_ message: String) { self.message = message }
    public var description: String { message }
    public var errorDescription: String? { message }
}

/// Standard Webhooks signing and verification (port of the `standardwebhooks` package's `Webhook`).
///
/// Signatures are `v1,<base64 HMAC-SHA256>` over `"{id}.{timestamp}.{payload}"`; timestamps more than
/// five minutes away from now are rejected.
public struct StandardWebhook: Sendable {
    static let secretPrefix = "whsec_"
    static let tolerance: TimeInterval = 5 * 60

    let secret: [UInt8]

    /// A secret given as a string is `whsec_`-prefixed (optional) base64; raw bytes are used as is.
    public init(secret: String) throws {
        if secret.isEmpty { throw ValueError("Secret can't be empty.") }
        var s = secret
        if s.hasPrefix(StandardWebhook.secretPrefix) { s.removeFirst(StandardWebhook.secretPrefix.count) }
        guard let data = Data(base64Encoded: s) else {
            throw WebhookVerificationError("Invalid webhook secret: expected base64")
        }
        self.secret = [UInt8](data)
    }

    public init(secret: Data) throws {
        if secret.isEmpty { throw ValueError("Secret can't be empty.") }
        self.secret = [UInt8](secret)
    }

    /// The `webhook-signature` value for a message.
    public func sign(msgID: String, timestamp: Date, payload: String) -> String {
        let ts = String(Int64(floor(timestamp.timeIntervalSince1970)))
        return "v1," + Data(signature(msgID: msgID, timestamp: ts, payload: payload)).base64EncodedString()
    }

    func signature(msgID: String, timestamp: String, payload: String) -> [UInt8] {
        HMACSHA256.authenticationCode(key: secret, string: "\(msgID).\(timestamp).\(payload)")
    }

    /// Verifies the `webhook-id`, `webhook-timestamp` and `webhook-signature` headers (names are
    /// case-insensitive) against `payload`.
    public func verify(payload: String, headers: [String: String], now: Date = Date()) throws {
        var lower: [String: String] = [:]
        for (k, v) in headers { lower[k.lowercased()] = v }
        guard let msgID = lower["webhook-id"], !msgID.isEmpty,
              let timestampHeader = lower["webhook-timestamp"], !timestampHeader.isEmpty,
              let signatureHeader = lower["webhook-signature"], !signatureHeader.isEmpty
        else { throw WebhookVerificationError("Missing required headers") }
        guard let seconds = Double(timestampHeader.trimmingCharacters(in: .whitespaces)) else {
            throw WebhookVerificationError("Invalid Signature Headers")
        }
        if seconds < now.timeIntervalSince1970 - StandardWebhook.tolerance { throw WebhookVerificationError("Message timestamp too old") }
        if seconds > now.timeIntervalSince1970 + StandardWebhook.tolerance { throw WebhookVerificationError("Message timestamp too new") }
        let expected = signature(msgID: msgID, timestamp: String(Int64(floor(seconds))), payload: payload)
        for versioned in signatureHeader.split(separator: " ") {
            let parts = versioned.split(separator: ",", maxSplits: 1)
            guard parts.count == 2, parts[0] == "v1" else { continue }
            guard let sig = Data(base64Encoded: String(parts[1])) else { continue }
            if constantTimeEquals(expected, [UInt8](sig)) { return }
        }
        throw WebhookVerificationError("No matching signature found")
    }
}

extension BetaWebhooksResource {
    /// Parses a webhook payload into an event without verifying its signature.
    ///
    /// Prefer `unwrap(_:headers:key:)` unless you have already verified the signature yourself.
    public func parseUnverified(_ payload: String) throws -> BetaWebhookEvent {
        try AnthropicJSON.decoder().decode(BetaWebhookEvent.self, from: Data(payload.utf8))
    }

    /// Verifies the webhook signature from the `webhook-id`, `webhook-timestamp` and
    /// `webhook-signature` headers using your webhook signing key, then parses the payload into an
    /// event. Throws `WebhookVerificationError` if the signature is missing or invalid.
    ///
    /// - Parameter key: The signing key; defaults to the client's `webhookKey`
    ///   (`ANTHROPIC_WEBHOOK_SIGNING_KEY`).
    public func unwrap(_ payload: String, headers: [String: String], key: UnwrapKey? = nil) throws -> BetaWebhookEvent {
        let webhook: StandardWebhook
        switch key {
        case .string(let s)?: webhook = try StandardWebhook(secret: s)
        case .data(let d)?: webhook = try StandardWebhook(secret: d)
        case .unknown?: throw ArgumentTypeError("Expected the webhook key to be a string or bytes")
        case nil:
            guard let k = (client as? Anthropic)?.webhookKey else {
                throw ValueError("Cannot verify a webhook without a key on either the client's webhook_key or passed in as an argument")
            }
            webhook = try StandardWebhook(secret: k)
        }
        try webhook.verify(payload: payload, headers: headers)
        return try parseUnverified(payload)
    }

    public func unwrap(_ payload: String, headers: HTTPHeaders, key: UnwrapKey? = nil) throws -> BetaWebhookEvent {
        try unwrap(payload, headers: headers.dictionary, key: key)
    }
}
