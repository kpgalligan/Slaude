// Transformed from `tests/api_resources/beta/organization/test_workspaces.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationWorkspaces {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationWorkspaceCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.workspaces.create(name: "x", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationWorkspaceCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.workspaces.create(name: "x", dataResidency: BetaDataResidencyCreateConfigParam(allowedInferenceGeos: .unrestricted("unrestricted"), defaultInferenceGeo: "global", workspaceGeo: "us"), displayColor: "#6C5BB9", externalKeyID: "ekey_01SDCCSbTxrXDpWc1phhtcfK", tags: ["env": "prod", "team": "platform"], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationWorkspaceCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.workspaces.withRawResponse.create(name: "x", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationWorkspaceCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.workspaces.withStreamingResponse.create(name: "x", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.workspaces.retrieve("workspace_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.workspaces.withRawResponse.retrieve("workspace_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.workspaces.withStreamingResponse.retrieve("workspace_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.beta.organization.workspaces.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationWorkspaceUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.workspaces.update("workspace_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationWorkspaceUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.workspaces.update("workspace_id", dataResidency: BetaDataResidencyUpdateConfigParam(allowedInferenceGeos: .unrestricted("unrestricted"), defaultInferenceGeo: "global"), displayColor: "#6C5BB9", externalKeyID: "ekey_01SDCCSbTxrXDpWc1phhtcfK", name: "x", tags: ["env": "prod", "team": "platform"], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationWorkspaceUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.workspaces.withRawResponse.update("workspace_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationWorkspaceUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.workspaces.withStreamingResponse.update("workspace_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.beta.organization.workspaces.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.workspaces.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.workspaces.list(afterID: "after_id", beforeID: "before_id", includeArchived: true, includeDefault: true, limit: 1, extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.workspaces.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.workspaces.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.workspaces.archive("workspace_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.workspaces.withRawResponse.archive("workspace_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "compartment_id": "string", "created_at": "2024-01-01T00:00:00Z", "data_residency": {"allowed_inference_geos": ["global"], "default_inference_geo": "global", "workspace_geo": "us"}, "display_color": "string", "external_key_id": "string", "name": "string", "tags": {"key": "string"}, "type": "workspace"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.workspaces.withStreamingResponse.archive("workspace_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsArchive() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.beta.organization.workspaces.withRawResponse.archive("") }
    }
}
