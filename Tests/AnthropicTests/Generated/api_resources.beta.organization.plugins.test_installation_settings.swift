// Transformed from `tests/api_resources/beta/organization/plugins/test_installation_settings.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationPluginsInstallationSettings {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/installation_settings", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "installation_preference": "auto_install", "plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_installation_setting", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.installationSettings.list("plugin_id", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/installation_settings", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "installation_preference": "auto_install", "plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_installation_setting", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.installationSettings.list("plugin_id", limit: 1, organizationID: "organization_id", page: "page", targetType: "organization", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/installation_settings", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "installation_preference": "auto_install", "plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_installation_setting", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.plugins.installationSettings.withRawResponse.list("plugin_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/installation_settings", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "installation_preference": "auto_install", "plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_installation_setting", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.plugins.installationSettings.withStreamingResponse.list("plugin_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `plugin_id` but received ''") { _ = try await client.beta.organization.plugins.installationSettings.withRawResponse.list("") }
    }

    @Test func methodRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/plugins/{plugin_id}/installation_settings/{target}", json: #"{"plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_installation_setting_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.installationSettings.remove("target", pluginID: "plugin_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRemoveWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/plugins/{plugin_id}/installation_settings/{target}", json: #"{"plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_installation_setting_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.installationSettings.remove("target", pluginID: "plugin_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/plugins/{plugin_id}/installation_settings/{target}", json: #"{"plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_installation_setting_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.plugins.installationSettings.withRawResponse.remove("target", pluginID: "plugin_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/plugins/{plugin_id}/installation_settings/{target}", json: #"{"plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_installation_setting_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.plugins.installationSettings.withStreamingResponse.remove("target", pluginID: "plugin_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRemove() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `plugin_id` but received ''") { _ = try await client.beta.organization.plugins.installationSettings.withRawResponse.remove("target", pluginID: "") }
        try await expectValueError("Expected a non-empty value for `target` but received ''") { _ = try await client.beta.organization.plugins.installationSettings.withRawResponse.remove("", pluginID: "plugin_id") }
    }

    @Test func methodSet() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins/{plugin_id}/installation_settings/{target}", json: #"{"created_at": "2024-01-01T00:00:00Z", "installation_preference": "auto_install", "plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_installation_setting", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.installationSettings.set("target", pluginID: "plugin_id", installationPreference: "required", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodSetWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins/{plugin_id}/installation_settings/{target}", json: #"{"created_at": "2024-01-01T00:00:00Z", "installation_preference": "auto_install", "plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_installation_setting", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.installationSettings.set("target", pluginID: "plugin_id", installationPreference: "required", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseSet() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins/{plugin_id}/installation_settings/{target}", json: #"{"created_at": "2024-01-01T00:00:00Z", "installation_preference": "auto_install", "plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_installation_setting", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.plugins.installationSettings.withRawResponse.set("target", pluginID: "plugin_id", installationPreference: "required", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseSet() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugins/{plugin_id}/installation_settings/{target}", json: #"{"created_at": "2024-01-01T00:00:00Z", "installation_preference": "auto_install", "plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_installation_setting", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.plugins.installationSettings.withStreamingResponse.set("target", pluginID: "plugin_id", installationPreference: "required", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsSet() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `plugin_id` but received ''") { _ = try await client.beta.organization.plugins.installationSettings.withRawResponse.set("target", pluginID: "", installationPreference: "required") }
        try await expectValueError("Expected a non-empty value for `target` but received ''") { _ = try await client.beta.organization.plugins.installationSettings.withRawResponse.set("", pluginID: "plugin_id", installationPreference: "required") }
    }
}
