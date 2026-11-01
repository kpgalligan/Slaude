// Transformed from `tests/api_resources/beta/organization/test_webhooks.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationWebhooks {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/webhooks", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "signing_secret": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}"#, validateBody: { try MockRoute.roundTrip(WebhookCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.webhooks.create(enabledEvents: ["user_profile.enforcement_action_opened"], url: "x", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/webhooks", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "signing_secret": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}"#, validateBody: { try MockRoute.roundTrip(WebhookCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.webhooks.create(enabledEvents: ["user_profile.enforcement_action_opened"], url: "x", description: "description", name: "name", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/webhooks", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "signing_secret": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}"#, validateBody: { try MockRoute.roundTrip(WebhookCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.webhooks.withRawResponse.create(enabledEvents: ["user_profile.enforcement_action_opened"], url: "x", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/webhooks", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "signing_secret": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}"#, validateBody: { try MockRoute.roundTrip(WebhookCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.webhooks.withStreamingResponse.create(enabledEvents: ["user_profile.enforcement_action_opened"], url: "x", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/webhooks/{webhook_endpoint_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.webhooks.retrieve("webhook_endpoint_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/webhooks/{webhook_endpoint_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.webhooks.retrieve("webhook_endpoint_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/webhooks/{webhook_endpoint_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.webhooks.withRawResponse.retrieve("webhook_endpoint_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/webhooks/{webhook_endpoint_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.webhooks.withStreamingResponse.retrieve("webhook_endpoint_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `webhook_endpoint_id` but received ''") { _ = try await client.beta.organization.webhooks.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/webhooks/{webhook_endpoint_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}"#, validateBody: { try MockRoute.roundTrip(WebhookUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.webhooks.update("webhook_endpoint_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/webhooks/{webhook_endpoint_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}"#, validateBody: { try MockRoute.roundTrip(WebhookUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.webhooks.update("webhook_endpoint_id", description: "description", enabledEvents: ["user_profile.enforcement_action_opened"], name: "name", state: "disabled", url: "x", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/webhooks/{webhook_endpoint_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}"#, validateBody: { try MockRoute.roundTrip(WebhookUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.webhooks.withRawResponse.update("webhook_endpoint_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/webhooks/{webhook_endpoint_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}"#, validateBody: { try MockRoute.roundTrip(WebhookUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.webhooks.withStreamingResponse.update("webhook_endpoint_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `webhook_endpoint_id` but received ''") { _ = try await client.beta.organization.webhooks.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/webhooks", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.webhooks.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/webhooks", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.webhooks.list(afterID: "after_id", beforeID: "before_id", limit: 0, order: "asc", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/webhooks", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.webhooks.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/webhooks", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "disabled_reason": "string", "enabled_events": ["user_profile.enforcement_action_opened"], "name": "string", "state": "disabled", "updated_at": "2024-01-01T00:00:00Z", "url": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.webhooks.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/webhooks/{webhook_endpoint_id}", json: #"{"id": "string", "type": "webhook_endpoint_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.webhooks.delete("webhook_endpoint_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/webhooks/{webhook_endpoint_id}", json: #"{"id": "string", "type": "webhook_endpoint_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.webhooks.delete("webhook_endpoint_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/webhooks/{webhook_endpoint_id}", json: #"{"id": "string", "type": "webhook_endpoint_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.webhooks.withRawResponse.delete("webhook_endpoint_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/webhooks/{webhook_endpoint_id}", json: #"{"id": "string", "type": "webhook_endpoint_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.webhooks.withStreamingResponse.delete("webhook_endpoint_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `webhook_endpoint_id` but received ''") { _ = try await client.beta.organization.webhooks.withRawResponse.delete("") }
    }

    @Test func methodRegenerateSigningSecret() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/webhooks/{webhook_endpoint_id}/regenerate_signing_secret", json: #"{"signing_secret": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.webhooks.regenerateSigningSecret("webhook_endpoint_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRegenerateSigningSecretWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/webhooks/{webhook_endpoint_id}/regenerate_signing_secret", json: #"{"signing_secret": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.webhooks.regenerateSigningSecret("webhook_endpoint_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRegenerateSigningSecret() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/webhooks/{webhook_endpoint_id}/regenerate_signing_secret", json: #"{"signing_secret": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.webhooks.withRawResponse.regenerateSigningSecret("webhook_endpoint_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRegenerateSigningSecret() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/webhooks/{webhook_endpoint_id}/regenerate_signing_secret", json: #"{"signing_secret": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.webhooks.withStreamingResponse.regenerateSigningSecret("webhook_endpoint_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRegenerateSigningSecret() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `webhook_endpoint_id` but received ''") { _ = try await client.beta.organization.webhooks.withRawResponse.regenerateSigningSecret("") }
    }
}
