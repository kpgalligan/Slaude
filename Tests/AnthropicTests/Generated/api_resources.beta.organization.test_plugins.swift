// Transformed from `tests/api_resources/beta/organization/test_plugins.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationPlugins {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.create(files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.create(files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], marketplaceID: "marketplace_id", releaseNotes: "release_notes", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.plugins.withRawResponse.create(files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.plugins.withStreamingResponse.create(files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.retrieve("plugin_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.retrieve("plugin_id", organizationID: "organization_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.plugins.withRawResponse.retrieve("plugin_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.plugins.withStreamingResponse.retrieve("plugin_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `plugin_id` but received ''") { _ = try await client.beta.organization.plugins.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins/{plugin_id}", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(PluginUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.plugins.update("plugin_id", servedVersionID: "pluginver_01KaZmQpRsTuVwXyZ2b4c6d8", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins/{plugin_id}", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(PluginUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.plugins.update("plugin_id", servedVersionID: "pluginver_01KaZmQpRsTuVwXyZ2b4c6d8", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins/{plugin_id}", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(PluginUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.plugins.withRawResponse.update("plugin_id", servedVersionID: "pluginver_01KaZmQpRsTuVwXyZ2b4c6d8", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins/{plugin_id}", json: #"{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(PluginUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.plugins.withStreamingResponse.update("plugin_id", servedVersionID: "pluginver_01KaZmQpRsTuVwXyZ2b4c6d8", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `plugin_id` but received ''") { _ = try await client.beta.organization.plugins.withRawResponse.update("", servedVersionID: "pluginver_01KaZmQpRsTuVwXyZ2b4c6d8") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins", json: #"{"data": [{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins", json: #"{"data": [{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.list(createdAtGt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), createdAtGte: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), createdAtLt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), createdAtLte: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), limit: 1, marketplaceID: "marketplace_id", organizationID: "organization_id", ownerType: "organization", ownerUserID: "owner_user_id", page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins", json: #"{"data": [{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.plugins.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins", json: #"{"data": [{"id": "string", "components": [{"name": "string", "type": "agent"}], "content_scan": {"assessment": "fail", "reason": "string", "status": "completed"}, "created_at": "2024-01-01T00:00:00Z", "created_by": {"email_address": "string", "type": "user_actor", "user_id": "string"}, "description": "string", "display_name": "string", "latest_version_id": "string", "manifest_version": "string", "marketplace_id": "string", "name": "string", "organization_installation_preference": "auto_install", "organization_installation_preference_inherited": true, "owner": {"type": "organization"}, "reach": "contained", "served_version_id": "string", "served_version_pinned": true, "type": "plugin", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.plugins.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/plugins/{plugin_id}", json: #"{"id": "string", "type": "plugin_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.delete("plugin_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/plugins/{plugin_id}", json: #"{"id": "string", "type": "plugin_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.delete("plugin_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/plugins/{plugin_id}", json: #"{"id": "string", "type": "plugin_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.plugins.withRawResponse.delete("plugin_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/plugins/{plugin_id}", json: #"{"id": "string", "type": "plugin_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.plugins.withStreamingResponse.delete("plugin_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `plugin_id` but received ''") { _ = try await client.beta.organization.plugins.withRawResponse.delete("") }
    }
}
