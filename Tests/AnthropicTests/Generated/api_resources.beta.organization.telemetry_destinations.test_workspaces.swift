// Transformed from `tests/api_resources/beta/organization/telemetry_destinations/test_workspaces.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationTelemetryDestinationsWorkspaces {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/telemetry_destinations/{destination_id}/workspaces", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "telemetry_destination_id": "string", "type": "telemetry_destination_workspace", "workspace_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.workspaces.list("destination_id", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/telemetry_destinations/{destination_id}/workspaces", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "telemetry_destination_id": "string", "type": "telemetry_destination_workspace", "workspace_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.workspaces.list("destination_id", limit: 0, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/telemetry_destinations/{destination_id}/workspaces", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "telemetry_destination_id": "string", "type": "telemetry_destination_workspace", "workspace_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.telemetryDestinations.workspaces.withRawResponse.list("destination_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/telemetry_destinations/{destination_id}/workspaces", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "telemetry_destination_id": "string", "type": "telemetry_destination_workspace", "workspace_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.telemetryDestinations.workspaces.withStreamingResponse.list("destination_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `destination_id` but received ''") { _ = try await client.beta.organization.telemetryDestinations.workspaces.withRawResponse.list("") }
    }

    @Test func methodAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations/{destination_id}/workspaces/{workspace_id}", json: #"{"created_at": "2024-01-01T00:00:00Z", "telemetry_destination_id": "string", "type": "telemetry_destination_workspace", "workspace_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.workspaces.add("workspace_id", destinationID: "destination_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodAddWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations/{destination_id}/workspaces/{workspace_id}", json: #"{"created_at": "2024-01-01T00:00:00Z", "telemetry_destination_id": "string", "type": "telemetry_destination_workspace", "workspace_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.workspaces.add("workspace_id", destinationID: "destination_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations/{destination_id}/workspaces/{workspace_id}", json: #"{"created_at": "2024-01-01T00:00:00Z", "telemetry_destination_id": "string", "type": "telemetry_destination_workspace", "workspace_id": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.telemetryDestinations.workspaces.withRawResponse.add("workspace_id", destinationID: "destination_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations/{destination_id}/workspaces/{workspace_id}", json: #"{"created_at": "2024-01-01T00:00:00Z", "telemetry_destination_id": "string", "type": "telemetry_destination_workspace", "workspace_id": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.telemetryDestinations.workspaces.withStreamingResponse.add("workspace_id", destinationID: "destination_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsAdd() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `destination_id` but received ''") { _ = try await client.beta.organization.telemetryDestinations.workspaces.withRawResponse.add("workspace_id", destinationID: "") }
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.beta.organization.telemetryDestinations.workspaces.withRawResponse.add("", destinationID: "destination_id") }
    }

    @Test func methodRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/telemetry_destinations/{destination_id}/workspaces/{workspace_id}", json: #"{"telemetry_destination_id": "string", "type": "telemetry_destination_workspace_deleted", "workspace_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.workspaces.remove("workspace_id", destinationID: "destination_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRemoveWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/telemetry_destinations/{destination_id}/workspaces/{workspace_id}", json: #"{"telemetry_destination_id": "string", "type": "telemetry_destination_workspace_deleted", "workspace_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.workspaces.remove("workspace_id", destinationID: "destination_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/telemetry_destinations/{destination_id}/workspaces/{workspace_id}", json: #"{"telemetry_destination_id": "string", "type": "telemetry_destination_workspace_deleted", "workspace_id": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.telemetryDestinations.workspaces.withRawResponse.remove("workspace_id", destinationID: "destination_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/telemetry_destinations/{destination_id}/workspaces/{workspace_id}", json: #"{"telemetry_destination_id": "string", "type": "telemetry_destination_workspace_deleted", "workspace_id": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.telemetryDestinations.workspaces.withStreamingResponse.remove("workspace_id", destinationID: "destination_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRemove() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `destination_id` but received ''") { _ = try await client.beta.organization.telemetryDestinations.workspaces.withRawResponse.remove("workspace_id", destinationID: "") }
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.beta.organization.telemetryDestinations.workspaces.withRawResponse.remove("", destinationID: "destination_id") }
    }
}
