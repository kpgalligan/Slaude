import Foundation
import Testing
@testable import Anthropic

// Port of tests/api_resources/beta/test_webhooks.py (`test_method_unwrap`), plus Standard Webhooks
// vectors. The tests use `StandardWebhook.sign` the way the upstream test uses `standardwebhooks.Webhook.sign`.

private let payload = #"{"id":"whe_0f1e2d3c4b5a69788796a5b4c3d2e1f0","created_at":"2026-03-15T10:00:00Z","data":{"id":"sesn_011CZkZAtmR3yMPDzynEDxu7","organization_id":"org_011CZkZZAe0sMna4vkBdtrfx","type":"session.status_idled","workspace_id":"wrkspc_011CZkZaBF1tNoB5wlCeusgy"},"type":"event"}"#

@Suite struct WebhooksTests {
    @Test(arguments: [
        ("whsec_c2VjcmV0Cg==", nil), ("wrong", .data(Data("secret\n".utf8))), ("wrong", .string("whsec_c2VjcmV0Cg==")),
        (nil, .data(Data("secret\n".utf8))), (nil, .string("whsec_c2VjcmV0Cg==")),
    ] as [(String?, BetaWebhooksResource.UnwrapKey?)])
    func methodUnwrap(clientOpt: String?, methodOpt: BetaWebhooksResource.UnwrapKey?) throws {
        let hook = try StandardWebhook(secret: Data("secret\n".utf8))
        let client = try mockClient().copy(webhookKey: clientOpt)
        let msgID = "1"
        let timestamp = Date()
        let sig = hook.sign(msgID: msgID, timestamp: timestamp, payload: payload)
        let headers = ["webhook-id": msgID, "webhook-timestamp": String(Int(timestamp.timeIntervalSince1970)), "webhook-signature": sig]

        let event = try client.beta.webhooks.unwrap(payload, headers: headers, key: methodOpt)
        #expect(event.id == "whe_0f1e2d3c4b5a69788796a5b4c3d2e1f0")

        var badHeaders = [headers, headers, headers]
        badHeaders[0]["webhook-signature"] = hook.sign(msgID: msgID, timestamp: timestamp, payload: "xxx")
        badHeaders[1]["webhook-id"] = "bad"
        badHeaders[2]["webhook-timestamp"] = "0"
        for bad in badHeaders {
            #expect(throws: WebhookVerificationError.self) { _ = try client.beta.webhooks.unwrap(payload, headers: bad, key: methodOpt) }
        }
    }

    @Test func unwrapWithoutKeyRaises() throws {
        let client = try mockClient()
        #expect(throws: ValueError.self) { _ = try client.beta.webhooks.unwrap(payload, headers: [:]) }
    }

    @Test func webhookKeyFromEnvironment() throws {
        let client = try Anthropic(apiKey: testAPIKey, environment: ["ANTHROPIC_WEBHOOK_SIGNING_KEY": "whsec_c2VjcmV0Cg=="])
        let hook = try StandardWebhook(secret: "whsec_c2VjcmV0Cg==")
        let now = Date()
        let headers: HTTPHeaders = ["Webhook-Id": "msg", "Webhook-Timestamp": String(Int(now.timeIntervalSince1970)),
                                    "Webhook-Signature": hook.sign(msgID: "msg", timestamp: now, payload: payload)]
        _ = try client.beta.webhooks.unwrap(payload, headers: headers)
    }

    @Test func parseUnverified() throws {
        let event = try mockClient().beta.webhooks.parseUnverified(payload)
        #expect(event.id == "whe_0f1e2d3c4b5a69788796a5b4c3d2e1f0")
        #expect(throws: (any Error).self) { _ = try mockClient().beta.webhooks.parseUnverified("not json") }
    }

    /// A signature computed with Python's `hmac` / `base64` (the Standard Webhooks spec example payload).
    @Test func standardWebhooksVector() throws {
        let hook = try StandardWebhook(secret: "whsec_c2VjcmV0Cg==")
        let ts = Date(timeIntervalSince1970: 1_614_265_330)
        #expect(hook.sign(msgID: "msg_p5jXN8AQM9LWM0D4loKWxJek", timestamp: ts, payload: #"{"test": 2432232314}"#)
            == "v1,7xqoRzulWWuJSToUd+L3AIcdAPlohInp5HkUw5Csz0k=")
        let headers = ["webhook-id": "msg_p5jXN8AQM9LWM0D4loKWxJek", "webhook-timestamp": "1614265330",
                       "webhook-signature": "v0,bad v1,7xqoRzulWWuJSToUd+L3AIcdAPlohInp5HkUw5Csz0k="]
        try hook.verify(payload: #"{"test": 2432232314}"#, headers: headers, now: ts.addingTimeInterval(60))
    }

    @Test func timestampTolerance() throws {
        let hook = try StandardWebhook(secret: "whsec_c2VjcmV0Cg==")
        let ts = Date(timeIntervalSince1970: 1_700_000_000)
        let headers = ["webhook-id": "m", "webhook-timestamp": "1700000000", "webhook-signature": hook.sign(msgID: "m", timestamp: ts, payload: "p")]
        try hook.verify(payload: "p", headers: headers, now: ts.addingTimeInterval(299))
        #expect(throws: WebhookVerificationError("Message timestamp too old")) {
            try hook.verify(payload: "p", headers: headers, now: ts.addingTimeInterval(301))
        }
        #expect(throws: WebhookVerificationError("Message timestamp too new")) {
            try hook.verify(payload: "p", headers: headers, now: ts.addingTimeInterval(-301))
        }
        #expect(throws: WebhookVerificationError("Missing required headers")) { try hook.verify(payload: "p", headers: [:], now: ts) }
        #expect(throws: WebhookVerificationError("Invalid Signature Headers")) {
            try hook.verify(payload: "p", headers: ["webhook-id": "m", "webhook-timestamp": "x", "webhook-signature": "v1,AA=="], now: ts)
        }
    }
}
