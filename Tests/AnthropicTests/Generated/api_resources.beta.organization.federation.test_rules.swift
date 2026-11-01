// Transformed from `tests/api_resources/beta/organization/federation/test_rules.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationFederationRules {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_rules", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationRuleCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.federation.rules.create(issuerID: "issuer_id", match: BetaFederationRuleMatchParam(), name: "x", oauthScope: "x", target: BetaServiceAccountTargetParam(serviceAccountID: "svac_01SDCCSbTxrXDpWc1phhtcfK", type: "service_account"), extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_rules", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationRuleCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.federation.rules.create(issuerID: "issuer_id", match: BetaFederationRuleMatchParam(audience: "audience", claims: ["foo": "string"], condition: "condition", subjectPrefix: "subject_prefix"), name: "x", oauthScope: "x", target: BetaServiceAccountTargetParam(serviceAccountID: "svac_01SDCCSbTxrXDpWc1phhtcfK", type: "service_account", serviceAccountName: "service_account_name"), appliesToAllWorkspaces: true, attributes: ["foo": "string"], description: "description", tokenLifetimeSeconds: 60, workspaceID: "workspace_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_rules", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationRuleCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.federation.rules.withRawResponse.create(issuerID: "issuer_id", match: BetaFederationRuleMatchParam(), name: "x", oauthScope: "x", target: BetaServiceAccountTargetParam(serviceAccountID: "svac_01SDCCSbTxrXDpWc1phhtcfK", type: "service_account"), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_rules", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationRuleCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.federation.rules.withStreamingResponse.create(issuerID: "issuer_id", match: BetaFederationRuleMatchParam(), name: "x", oauthScope: "x", target: BetaServiceAccountTargetParam(serviceAccountID: "svac_01SDCCSbTxrXDpWc1phhtcfK", type: "service_account"), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_rules/{federation_rule_id}", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#)
        let client = try route.client()
        let value = try await client.beta.organization.federation.rules.retrieve("federation_rule_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_rules/{federation_rule_id}", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#)
        let client = try route.client()
        let value = try await client.beta.organization.federation.rules.retrieve("federation_rule_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_rules/{federation_rule_id}", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#)
        let client = try route.client()
        let response = try await client.beta.organization.federation.rules.withRawResponse.retrieve("federation_rule_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_rules/{federation_rule_id}", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.federation.rules.withStreamingResponse.retrieve("federation_rule_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `federation_rule_id` but received ''") { _ = try await client.beta.organization.federation.rules.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_rules/{federation_rule_id}", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationRuleUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.federation.rules.update("federation_rule_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_rules/{federation_rule_id}", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationRuleUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.federation.rules.update("federation_rule_id", appliesToAllWorkspaces: true, attributes: ["foo": "string"], description: "description", match: BetaFederationRuleMatchParam(audience: "audience", claims: ["foo": "string"], condition: "condition", subjectPrefix: "subject_prefix"), name: "x", oauthScope: "x", target: BetaServiceAccountTargetParam(serviceAccountID: "svac_01SDCCSbTxrXDpWc1phhtcfK", type: "service_account", serviceAccountName: "service_account_name"), tokenLifetimeSeconds: 60, workspaceID: "workspace_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_rules/{federation_rule_id}", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationRuleUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.federation.rules.withRawResponse.update("federation_rule_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_rules/{federation_rule_id}", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationRuleUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.federation.rules.withStreamingResponse.update("federation_rule_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `federation_rule_id` but received ''") { _ = try await client.beta.organization.federation.rules.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_rules", json: #"{"data": [{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.federation.rules.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_rules", json: #"{"data": [{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.federation.rules.list(includeArchived: true, issuerID: "issuer_id", limit: 1, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_rules", json: #"{"data": [{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.federation.rules.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_rules", json: #"{"data": [{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.federation.rules.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_rules/{federation_rule_id}/archive", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#)
        let client = try route.client()
        let value = try await client.beta.organization.federation.rules.archive("federation_rule_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodArchiveWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_rules/{federation_rule_id}/archive", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#)
        let client = try route.client()
        let value = try await client.beta.organization.federation.rules.archive("federation_rule_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_rules/{federation_rule_id}/archive", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#)
        let client = try route.client()
        let response = try await client.beta.organization.federation.rules.withRawResponse.archive("federation_rule_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_rules/{federation_rule_id}/archive", json: #"{"id": "string", "applies_to_all_workspaces": true, "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "attributes": {"key": "string"}, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "description": "string", "issuer_id": "string", "issuer_name": "string", "match": {"audience": "string", "claims": {"key": "string"}, "condition": "string", "subject_prefix": "string"}, "name": "string", "oauth_scope": "string", "target": {"service_account_id": "string", "type": "service_account", "service_account_name": "string"}, "token_lifetime_seconds": 0, "type": "federation_rule", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string", "workspace_id": "string", "workspace_ids": ["string"]}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.federation.rules.withStreamingResponse.archive("federation_rule_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsArchive() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `federation_rule_id` but received ''") { _ = try await client.beta.organization.federation.rules.withRawResponse.archive("") }
    }
}
