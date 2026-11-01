// Transformed from `tests/api_resources/beta/test_environments.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaEnvironments {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#, validateBody: { try MockRoute.roundTrip(EnvironmentCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.environments.create(name: "python-data-analysis", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#, validateBody: { try MockRoute.roundTrip(EnvironmentCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.environments.create(name: "python-data-analysis", config: EnvironmentCreateParams.Config.cloud(BetaCloudConfigParams(type: "cloud", networking: BetaCloudConfigParams.Networking.limited(BetaLimitedNetworkParams(type: "limited", allowMCPServers: true, allowPackageManagers: true, allowedHosts: ["api.example.com"])), packages: BetaPackagesParams(apt: ["string"], cargo: ["string"], gem: ["string"], go: ["string"], npm: ["string"], pip: ["pandas", "numpy"], type: "packages"))), description: "Python environment with data-analysis packages.", metadata: ["foo": "string"], scope: "organization", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#, validateBody: { try MockRoute.roundTrip(EnvironmentCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.environments.withRawResponse.create(name: "python-data-analysis", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#, validateBody: { try MockRoute.roundTrip(EnvironmentCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.environments.withStreamingResponse.create(name: "python-data-analysis", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.retrieve("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.retrieve("env_011CZkZ9X2dpNyB7HsEFoRfW", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#)
        let client = try route.client()
        let response = try await client.beta.environments.withRawResponse.retrieve("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.environments.withStreamingResponse.retrieve("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `environment_id` but received ''") { _ = try await client.beta.environments.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#, validateBody: { try MockRoute.roundTrip(EnvironmentUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.environments.update("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#, validateBody: { try MockRoute.roundTrip(EnvironmentUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.environments.update("env_011CZkZ9X2dpNyB7HsEFoRfW", config: EnvironmentUpdateParams.Config.cloud(BetaCloudConfigParams(type: "cloud", networking: BetaCloudConfigParams.Networking.limited(BetaLimitedNetworkParams(type: "limited", allowMCPServers: true, allowPackageManagers: true, allowedHosts: ["api.example.com"])), packages: BetaPackagesParams(apt: ["string"], cargo: ["string"], gem: ["string"], go: ["string"], npm: ["string"], pip: ["pandas", "numpy"], type: "packages"))), description: "Python environment with data-analysis packages.", metadata: ["foo": "string"], name: "x", scope: "organization", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#, validateBody: { try MockRoute.roundTrip(EnvironmentUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.environments.withRawResponse.update("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#, validateBody: { try MockRoute.roundTrip(EnvironmentUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.environments.withStreamingResponse.update("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `environment_id` but received ''") { _ = try await client.beta.environments.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments", json: #"{"data": [{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.environments.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments", json: #"{"data": [{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.environments.list(includeArchived: true, limit: 1, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments", json: #"{"data": [{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.environments.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments", json: #"{"data": [{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.environments.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/environments/{environment_id}", json: #"{"id": "string", "type": "environment_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.delete("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/environments/{environment_id}", json: #"{"id": "string", "type": "environment_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.delete("env_011CZkZ9X2dpNyB7HsEFoRfW", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/environments/{environment_id}", json: #"{"id": "string", "type": "environment_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.environments.withRawResponse.delete("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/environments/{environment_id}", json: #"{"id": "string", "type": "environment_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.environments.withStreamingResponse.delete("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `environment_id` but received ''") { _ = try await client.beta.environments.withRawResponse.delete("") }
    }

    @Test func methodArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/archive", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.archive("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodArchiveWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/archive", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.archive("env_011CZkZ9X2dpNyB7HsEFoRfW", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/archive", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#)
        let client = try route.client()
        let response = try await client.beta.environments.withRawResponse.archive("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/archive", json: #"{"id": "string", "archived_at": "string", "config": {"networking": {"type": "unrestricted"}, "packages": {"apt": ["string"], "cargo": ["string"], "gem": ["string"], "go": ["string"], "npm": ["string"], "pip": ["string"]}, "type": "cloud"}, "created_at": "string", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "environment", "updated_at": "string", "scope": "organization"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.environments.withStreamingResponse.archive("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsArchive() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `environment_id` but received ''") { _ = try await client.beta.environments.withRawResponse.archive("") }
    }
}
