// Transformed from `tests/api_resources/beta/organization/plugins/test_versions.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationPluginsVersions {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins/{plugin_id}/versions", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "manifest_version": "string", "plugin_id": "string", "reach": "contained", "release_notes": "string", "type": "plugin_version"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.versions.create("plugin_id", files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins/{plugin_id}/versions", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "manifest_version": "string", "plugin_id": "string", "reach": "contained", "release_notes": "string", "type": "plugin_version"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.versions.create("plugin_id", files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], releaseNotes: "release_notes", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins/{plugin_id}/versions", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "manifest_version": "string", "plugin_id": "string", "reach": "contained", "release_notes": "string", "type": "plugin_version"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.plugins.versions.withRawResponse.create("plugin_id", files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins/{plugin_id}/versions", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "manifest_version": "string", "plugin_id": "string", "reach": "contained", "release_notes": "string", "type": "plugin_version"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.plugins.versions.withStreamingResponse.create("plugin_id", files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsCreate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `plugin_id` but received ''") { _ = try await client.beta.organization.plugins.versions.withRawResponse.create("", files: [FileUpload(data: Data("Example data".utf8), filename: "upload")]) }
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/versions/{version}", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "manifest_version": "string", "plugin_id": "string", "reach": "contained", "release_notes": "string", "type": "plugin_version"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.versions.retrieve("version", pluginID: "plugin_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/versions/{version}", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "manifest_version": "string", "plugin_id": "string", "reach": "contained", "release_notes": "string", "type": "plugin_version"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.versions.retrieve("version", pluginID: "plugin_id", organizationID: "organization_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/versions/{version}", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "manifest_version": "string", "plugin_id": "string", "reach": "contained", "release_notes": "string", "type": "plugin_version"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.plugins.versions.withRawResponse.retrieve("version", pluginID: "plugin_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/versions/{version}", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "manifest_version": "string", "plugin_id": "string", "reach": "contained", "release_notes": "string", "type": "plugin_version"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.plugins.versions.withStreamingResponse.retrieve("version", pluginID: "plugin_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `plugin_id` but received ''") { _ = try await client.beta.organization.plugins.versions.withRawResponse.retrieve("version", pluginID: "") }
        try await expectValueError("Expected a non-empty value for `version` but received ''") { _ = try await client.beta.organization.plugins.versions.withRawResponse.retrieve("", pluginID: "plugin_id") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/versions", json: #"{"data": [{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "manifest_version": "string", "plugin_id": "string", "reach": "contained", "release_notes": "string", "type": "plugin_version"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.versions.list("plugin_id", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/versions", json: #"{"data": [{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "manifest_version": "string", "plugin_id": "string", "reach": "contained", "release_notes": "string", "type": "plugin_version"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.versions.list("plugin_id", limit: 1, organizationID: "organization_id", page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/versions", json: #"{"data": [{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "manifest_version": "string", "plugin_id": "string", "reach": "contained", "release_notes": "string", "type": "plugin_version"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.plugins.versions.withRawResponse.list("plugin_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/versions", json: #"{"data": [{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "manifest_version": "string", "plugin_id": "string", "reach": "contained", "release_notes": "string", "type": "plugin_version"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.plugins.versions.withStreamingResponse.list("plugin_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `plugin_id` but received ''") { _ = try await client.beta.organization.plugins.versions.withRawResponse.list("") }
    }
}
