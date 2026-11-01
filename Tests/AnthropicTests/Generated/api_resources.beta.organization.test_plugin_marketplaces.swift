// Transformed from `tests/api_resources/beta/organization/test_plugin_marketplaces.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationPluginMarketplaces {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugin_marketplaces/{marketplace_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "default_installation_preference": "auto_install", "last_sync_ended_at": "2024-01-01T00:00:00Z", "last_sync_read_sha": "string", "name": "string", "owner": {"type": "organization"}, "source": "directory", "sync_status": "failed_auth", "type": "plugin_marketplace"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.pluginMarketplaces.retrieve("marketplace_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugin_marketplaces/{marketplace_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "default_installation_preference": "auto_install", "last_sync_ended_at": "2024-01-01T00:00:00Z", "last_sync_read_sha": "string", "name": "string", "owner": {"type": "organization"}, "source": "directory", "sync_status": "failed_auth", "type": "plugin_marketplace"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.pluginMarketplaces.retrieve("marketplace_id", organizationID: "organization_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugin_marketplaces/{marketplace_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "default_installation_preference": "auto_install", "last_sync_ended_at": "2024-01-01T00:00:00Z", "last_sync_read_sha": "string", "name": "string", "owner": {"type": "organization"}, "source": "directory", "sync_status": "failed_auth", "type": "plugin_marketplace"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.pluginMarketplaces.withRawResponse.retrieve("marketplace_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugin_marketplaces/{marketplace_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "default_installation_preference": "auto_install", "last_sync_ended_at": "2024-01-01T00:00:00Z", "last_sync_read_sha": "string", "name": "string", "owner": {"type": "organization"}, "source": "directory", "sync_status": "failed_auth", "type": "plugin_marketplace"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.pluginMarketplaces.withStreamingResponse.retrieve("marketplace_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `marketplace_id` but received ''") { _ = try await client.beta.organization.pluginMarketplaces.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugin_marketplaces/{marketplace_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "default_installation_preference": "auto_install", "last_sync_ended_at": "2024-01-01T00:00:00Z", "last_sync_read_sha": "string", "name": "string", "owner": {"type": "organization"}, "source": "directory", "sync_status": "failed_auth", "type": "plugin_marketplace"}"#, validateBody: { try MockRoute.roundTrip(PluginMarketplaceUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.pluginMarketplaces.update("marketplace_id", defaultInstallationPreference: "available", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugin_marketplaces/{marketplace_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "default_installation_preference": "auto_install", "last_sync_ended_at": "2024-01-01T00:00:00Z", "last_sync_read_sha": "string", "name": "string", "owner": {"type": "organization"}, "source": "directory", "sync_status": "failed_auth", "type": "plugin_marketplace"}"#, validateBody: { try MockRoute.roundTrip(PluginMarketplaceUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.pluginMarketplaces.update("marketplace_id", defaultInstallationPreference: "available", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugin_marketplaces/{marketplace_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "default_installation_preference": "auto_install", "last_sync_ended_at": "2024-01-01T00:00:00Z", "last_sync_read_sha": "string", "name": "string", "owner": {"type": "organization"}, "source": "directory", "sync_status": "failed_auth", "type": "plugin_marketplace"}"#, validateBody: { try MockRoute.roundTrip(PluginMarketplaceUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.pluginMarketplaces.withRawResponse.update("marketplace_id", defaultInstallationPreference: "available", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugin_marketplaces/{marketplace_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "default_installation_preference": "auto_install", "last_sync_ended_at": "2024-01-01T00:00:00Z", "last_sync_read_sha": "string", "name": "string", "owner": {"type": "organization"}, "source": "directory", "sync_status": "failed_auth", "type": "plugin_marketplace"}"#, validateBody: { try MockRoute.roundTrip(PluginMarketplaceUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.pluginMarketplaces.withStreamingResponse.update("marketplace_id", defaultInstallationPreference: "available", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `marketplace_id` but received ''") { _ = try await client.beta.organization.pluginMarketplaces.withRawResponse.update("", defaultInstallationPreference: "available") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugin_marketplaces", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "default_installation_preference": "auto_install", "last_sync_ended_at": "2024-01-01T00:00:00Z", "last_sync_read_sha": "string", "name": "string", "owner": {"type": "organization"}, "source": "directory", "sync_status": "failed_auth", "type": "plugin_marketplace"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.pluginMarketplaces.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugin_marketplaces", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "default_installation_preference": "auto_install", "last_sync_ended_at": "2024-01-01T00:00:00Z", "last_sync_read_sha": "string", "name": "string", "owner": {"type": "organization"}, "source": "directory", "sync_status": "failed_auth", "type": "plugin_marketplace"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.pluginMarketplaces.list(limit: 1, organizationID: "organization_id", ownerType: "organization", page: "page", source: "directory", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugin_marketplaces", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "default_installation_preference": "auto_install", "last_sync_ended_at": "2024-01-01T00:00:00Z", "last_sync_read_sha": "string", "name": "string", "owner": {"type": "organization"}, "source": "directory", "sync_status": "failed_auth", "type": "plugin_marketplace"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.pluginMarketplaces.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugin_marketplaces", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "default_installation_preference": "auto_install", "last_sync_ended_at": "2024-01-01T00:00:00Z", "last_sync_read_sha": "string", "name": "string", "owner": {"type": "organization"}, "source": "directory", "sync_status": "failed_auth", "type": "plugin_marketplace"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.pluginMarketplaces.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodValidateArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugin_marketplaces/validate_archive", json: #"{"commit_sha": "string", "manifest_error": "string", "manifest_error_code": "string", "plugin_errors": [{"error": "string", "error_code": "string", "name": "string"}], "plugin_warnings": [{"name": "string", "warnings": [{"error_code": "string", "message": "string"}]}], "ref": "string", "total_plugin_count": 0, "type": "plugin_marketplace_validation_report", "valid": true}"#)
        let client = try route.client()
        let value = try await client.beta.organization.pluginMarketplaces.validateArchive(archive: FileUpload(data: Data("Example data".utf8), filename: "upload"), extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodValidateArchiveWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugin_marketplaces/validate_archive", json: #"{"commit_sha": "string", "manifest_error": "string", "manifest_error_code": "string", "plugin_errors": [{"error": "string", "error_code": "string", "name": "string"}], "plugin_warnings": [{"name": "string", "warnings": [{"error_code": "string", "message": "string"}]}], "ref": "string", "total_plugin_count": 0, "type": "plugin_marketplace_validation_report", "valid": true}"#)
        let client = try route.client()
        let value = try await client.beta.organization.pluginMarketplaces.validateArchive(archive: FileUpload(data: Data("Example data".utf8), filename: "upload"), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseValidateArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugin_marketplaces/validate_archive", json: #"{"commit_sha": "string", "manifest_error": "string", "manifest_error_code": "string", "plugin_errors": [{"error": "string", "error_code": "string", "name": "string"}], "plugin_warnings": [{"name": "string", "warnings": [{"error_code": "string", "message": "string"}]}], "ref": "string", "total_plugin_count": 0, "type": "plugin_marketplace_validation_report", "valid": true}"#)
        let client = try route.client()
        let response = try await client.beta.organization.pluginMarketplaces.withRawResponse.validateArchive(archive: FileUpload(data: Data("Example data".utf8), filename: "upload"), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseValidateArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugin_marketplaces/validate_archive", json: #"{"commit_sha": "string", "manifest_error": "string", "manifest_error_code": "string", "plugin_errors": [{"error": "string", "error_code": "string", "name": "string"}], "plugin_warnings": [{"name": "string", "warnings": [{"error_code": "string", "message": "string"}]}], "ref": "string", "total_plugin_count": 0, "type": "plugin_marketplace_validation_report", "valid": true}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.pluginMarketplaces.withStreamingResponse.validateArchive(archive: FileUpload(data: Data("Example data".utf8), filename: "upload"), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodValidateRepository() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugin_marketplaces/validate_repository", json: #"{"commit_sha": "string", "manifest_error": "string", "manifest_error_code": "string", "plugin_errors": [{"error": "string", "error_code": "string", "name": "string"}], "plugin_warnings": [{"name": "string", "warnings": [{"error_code": "string", "message": "string"}]}], "ref": "string", "total_plugin_count": 0, "type": "plugin_marketplace_validation_report", "valid": true}"#, validateBody: { try MockRoute.roundTrip(PluginMarketplaceValidateRepositoryParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.pluginMarketplaces.validateRepository(repositoryURL: "https://github.com/example-org/example-marketplace", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodValidateRepositoryWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugin_marketplaces/validate_repository", json: #"{"commit_sha": "string", "manifest_error": "string", "manifest_error_code": "string", "plugin_errors": [{"error": "string", "error_code": "string", "name": "string"}], "plugin_warnings": [{"name": "string", "warnings": [{"error_code": "string", "message": "string"}]}], "ref": "string", "total_plugin_count": 0, "type": "plugin_marketplace_validation_report", "valid": true}"#, validateBody: { try MockRoute.roundTrip(PluginMarketplaceValidateRepositoryParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.pluginMarketplaces.validateRepository(repositoryURL: "https://github.com/example-org/example-marketplace", ref: "main", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseValidateRepository() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugin_marketplaces/validate_repository", json: #"{"commit_sha": "string", "manifest_error": "string", "manifest_error_code": "string", "plugin_errors": [{"error": "string", "error_code": "string", "name": "string"}], "plugin_warnings": [{"name": "string", "warnings": [{"error_code": "string", "message": "string"}]}], "ref": "string", "total_plugin_count": 0, "type": "plugin_marketplace_validation_report", "valid": true}"#, validateBody: { try MockRoute.roundTrip(PluginMarketplaceValidateRepositoryParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.pluginMarketplaces.withRawResponse.validateRepository(repositoryURL: "https://github.com/example-org/example-marketplace", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseValidateRepository() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/plugin_marketplaces/validate_repository", json: #"{"commit_sha": "string", "manifest_error": "string", "manifest_error_code": "string", "plugin_errors": [{"error": "string", "error_code": "string", "name": "string"}], "plugin_warnings": [{"name": "string", "warnings": [{"error_code": "string", "message": "string"}]}], "ref": "string", "total_plugin_count": 0, "type": "plugin_marketplace_validation_report", "valid": true}"#, validateBody: { try MockRoute.roundTrip(PluginMarketplaceValidateRepositoryParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.pluginMarketplaces.withStreamingResponse.validateRepository(repositoryURL: "https://github.com/example-org/example-marketplace", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }
}
