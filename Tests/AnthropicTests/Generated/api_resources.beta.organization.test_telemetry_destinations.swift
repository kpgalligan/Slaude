// Transformed from `tests/api_resources/beta/organization/test_telemetry_destinations.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationTelemetryDestinations {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}"#, validateBody: { try MockRoute.roundTrip(TelemetryDestinationCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.create(endpointURL: "x", workspaces: BetaTelemetryDestinationWorkspacesParams.all(BetaTelemetryDestinationWorkspacesAllParams(type: "all")), extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}"#, validateBody: { try MockRoute.roundTrip(TelemetryDestinationCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.create(endpointURL: "x", workspaces: BetaTelemetryDestinationWorkspacesParams.all(BetaTelemetryDestinationWorkspacesAllParams(type: "all")), displayName: "display_name", headers: ["foo": "string"], traces: BetaTelemetryDestinationTracesParams(contentMode: BetaTelemetryDestinationContentMode(rawValue: "metadata_only"), enabled: true, endpointURL: "endpoint_url", maxContentBytes: 0), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}"#, validateBody: { try MockRoute.roundTrip(TelemetryDestinationCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.telemetryDestinations.withRawResponse.create(endpointURL: "x", workspaces: BetaTelemetryDestinationWorkspacesParams.all(BetaTelemetryDestinationWorkspacesAllParams(type: "all")), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}"#, validateBody: { try MockRoute.roundTrip(TelemetryDestinationCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.telemetryDestinations.withStreamingResponse.create(endpointURL: "x", workspaces: BetaTelemetryDestinationWorkspacesParams.all(BetaTelemetryDestinationWorkspacesAllParams(type: "all")), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/telemetry_destinations/{destination_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}"#)
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.retrieve("destination_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/telemetry_destinations/{destination_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}"#)
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.retrieve("destination_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/telemetry_destinations/{destination_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}"#)
        let client = try route.client()
        let response = try await client.beta.organization.telemetryDestinations.withRawResponse.retrieve("destination_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/telemetry_destinations/{destination_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.telemetryDestinations.withStreamingResponse.retrieve("destination_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `destination_id` but received ''") { _ = try await client.beta.organization.telemetryDestinations.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations/{destination_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}"#, validateBody: { try MockRoute.roundTrip(TelemetryDestinationUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.update("destination_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations/{destination_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}"#, validateBody: { try MockRoute.roundTrip(TelemetryDestinationUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.update("destination_id", displayName: "display_name", endpointURL: "endpoint_url", headers: ["foo": "string"], state: BetaTelemetryDestinationStateParams.enabled(BetaTelemetryDestinationStateEnabledParams(type: "enabled")), traces: BetaTelemetryDestinationTracesParams(contentMode: BetaTelemetryDestinationContentMode(rawValue: "metadata_only"), enabled: true, endpointURL: "endpoint_url", maxContentBytes: 0), workspaces: BetaTelemetryDestinationWorkspacesParams.all(BetaTelemetryDestinationWorkspacesAllParams(type: "all")), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations/{destination_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}"#, validateBody: { try MockRoute.roundTrip(TelemetryDestinationUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.telemetryDestinations.withRawResponse.update("destination_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations/{destination_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}"#, validateBody: { try MockRoute.roundTrip(TelemetryDestinationUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.telemetryDestinations.withStreamingResponse.update("destination_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `destination_id` but received ''") { _ = try await client.beta.organization.telemetryDestinations.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/telemetry_destinations", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/telemetry_destinations", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.list(limit: 0, page: "page", workspaceIDs: ["string"], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/telemetry_destinations", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.telemetryDestinations.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/telemetry_destinations", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "delivery_health": {"last_error": "string", "last_error_at": "2024-01-01T00:00:00Z", "last_success_at": "2024-01-01T00:00:00Z"}, "display_name": "string", "endpoint_url": "string", "header_names": ["string"], "state": {"type": "enabled"}, "traces": {"content_mode": "metadata_only", "enabled": true, "endpoint_url": "string", "max_content_bytes": 0}, "type": "telemetry_destination", "updated_at": "2024-01-01T00:00:00Z", "workspaces": {"type": "all"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.telemetryDestinations.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/telemetry_destinations/{destination_id}", json: #"{"id": "string", "type": "telemetry_destination_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.delete("destination_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/telemetry_destinations/{destination_id}", json: #"{"id": "string", "type": "telemetry_destination_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.delete("destination_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/telemetry_destinations/{destination_id}", json: #"{"id": "string", "type": "telemetry_destination_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.telemetryDestinations.withRawResponse.delete("destination_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/telemetry_destinations/{destination_id}", json: #"{"id": "string", "type": "telemetry_destination_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.telemetryDestinations.withStreamingResponse.delete("destination_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `destination_id` but received ''") { _ = try await client.beta.organization.telemetryDestinations.withRawResponse.delete("") }
    }

    @Test func methodTest() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations/{destination_id}/test", json: #"{"result": {"type": "success"}, "type": "telemetry_destination_test"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.test("destination_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodTestWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations/{destination_id}/test", json: #"{"result": {"type": "success"}, "type": "telemetry_destination_test"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.telemetryDestinations.test("destination_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseTest() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations/{destination_id}/test", json: #"{"result": {"type": "success"}, "type": "telemetry_destination_test"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.telemetryDestinations.withRawResponse.test("destination_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseTest() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/telemetry_destinations/{destination_id}/test", json: #"{"result": {"type": "success"}, "type": "telemetry_destination_test"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.telemetryDestinations.withStreamingResponse.test("destination_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsTest() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `destination_id` but received ''") { _ = try await client.beta.organization.telemetryDestinations.withRawResponse.test("") }
    }
}
