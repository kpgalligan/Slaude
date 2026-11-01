// Transformed from `tests/api_resources/beta/organization/test_service_accounts.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationServiceAccounts {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/service_accounts", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationServiceAccountCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.serviceAccounts.create(name: "ci-deploy-bot", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/service_accounts", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationServiceAccountCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.serviceAccounts.create(name: "ci-deploy-bot", description: "description", organizationRole: "admin", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/service_accounts", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationServiceAccountCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.serviceAccounts.withRawResponse.create(name: "ci-deploy-bot", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/service_accounts", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationServiceAccountCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.serviceAccounts.withStreamingResponse.create(name: "ci-deploy-bot", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/service_accounts/{service_account_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.serviceAccounts.retrieve("service_account_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/service_accounts/{service_account_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.serviceAccounts.retrieve("service_account_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/service_accounts/{service_account_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.serviceAccounts.withRawResponse.retrieve("service_account_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/service_accounts/{service_account_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.serviceAccounts.withStreamingResponse.retrieve("service_account_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `service_account_id` but received ''") { _ = try await client.beta.organization.serviceAccounts.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/service_accounts/{service_account_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationServiceAccountUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.serviceAccounts.update("service_account_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/service_accounts/{service_account_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationServiceAccountUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.serviceAccounts.update("service_account_id", description: "description", organizationRole: "admin", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/service_accounts/{service_account_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationServiceAccountUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.serviceAccounts.withRawResponse.update("service_account_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/service_accounts/{service_account_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationServiceAccountUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.serviceAccounts.withStreamingResponse.update("service_account_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `service_account_id` but received ''") { _ = try await client.beta.organization.serviceAccounts.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/service_accounts", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.serviceAccounts.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/service_accounts", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.serviceAccounts.list(includeArchived: true, limit: 1, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/service_accounts", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.serviceAccounts.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/service_accounts", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.serviceAccounts.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/service_accounts/{service_account_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.serviceAccounts.archive("service_account_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodArchiveWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/service_accounts/{service_account_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.serviceAccounts.archive("service_account_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/service_accounts/{service_account_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.serviceAccounts.withRawResponse.archive("service_account_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/service_accounts/{service_account_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "name": "string", "organization_role": "admin", "type": "service_account", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.serviceAccounts.withStreamingResponse.archive("service_account_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsArchive() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `service_account_id` but received ''") { _ = try await client.beta.organization.serviceAccounts.withRawResponse.archive("") }
    }
}
