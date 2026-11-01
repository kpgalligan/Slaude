// Transformed from `tests/api_resources/beta/skills/test_versions.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaSkillsVersions {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/skills/{skill_id}/versions", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "name": "string", "skill_id": "string", "type": "skill_version"}"#)
        let client = try route.client()
        let value = try await client.beta.skills.versions.create("skill_id", files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/skills/{skill_id}/versions", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "name": "string", "skill_id": "string", "type": "skill_version"}"#)
        let client = try route.client()
        let value = try await client.beta.skills.versions.create("skill_id", files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/skills/{skill_id}/versions", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "name": "string", "skill_id": "string", "type": "skill_version"}"#)
        let client = try route.client()
        let response = try await client.beta.skills.versions.withRawResponse.create("skill_id", files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/skills/{skill_id}/versions", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "name": "string", "skill_id": "string", "type": "skill_version"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.skills.versions.withStreamingResponse.create("skill_id", files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsCreate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `skill_id` but received ''") { _ = try await client.beta.skills.versions.withRawResponse.create("", files: [FileUpload(data: Data("Example data".utf8), filename: "upload")]) }
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills/{skill_id}/versions/{version}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "name": "string", "skill_id": "string", "type": "skill_version"}"#)
        let client = try route.client()
        let value = try await client.beta.skills.versions.retrieve("version", skillID: "skill_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills/{skill_id}/versions/{version}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "name": "string", "skill_id": "string", "type": "skill_version"}"#)
        let client = try route.client()
        let value = try await client.beta.skills.versions.retrieve("version", skillID: "skill_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills/{skill_id}/versions/{version}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "name": "string", "skill_id": "string", "type": "skill_version"}"#)
        let client = try route.client()
        let response = try await client.beta.skills.versions.withRawResponse.retrieve("version", skillID: "skill_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills/{skill_id}/versions/{version}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "name": "string", "skill_id": "string", "type": "skill_version"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.skills.versions.withStreamingResponse.retrieve("version", skillID: "skill_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `skill_id` but received ''") { _ = try await client.beta.skills.versions.withRawResponse.retrieve("version", skillID: "") }
        try await expectValueError("Expected a non-empty value for `version` but received ''") { _ = try await client.beta.skills.versions.withRawResponse.retrieve("", skillID: "skill_id") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills/{skill_id}/versions", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "name": "string", "skill_id": "string", "type": "skill_version"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.skills.versions.list("skill_id", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills/{skill_id}/versions", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "name": "string", "skill_id": "string", "type": "skill_version"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.skills.versions.list("skill_id", limit: 1, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills/{skill_id}/versions", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "name": "string", "skill_id": "string", "type": "skill_version"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.skills.versions.withRawResponse.list("skill_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills/{skill_id}/versions", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "name": "string", "skill_id": "string", "type": "skill_version"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.skills.versions.withStreamingResponse.list("skill_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `skill_id` but received ''") { _ = try await client.beta.skills.versions.withRawResponse.list("") }
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/skills/{skill_id}/versions/{version}", json: #"{"id": "string", "type": "skill_version_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.skills.versions.delete("version", skillID: "skill_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/skills/{skill_id}/versions/{version}", json: #"{"id": "string", "type": "skill_version_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.skills.versions.delete("version", skillID: "skill_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/skills/{skill_id}/versions/{version}", json: #"{"id": "string", "type": "skill_version_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.skills.versions.withRawResponse.delete("version", skillID: "skill_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/skills/{skill_id}/versions/{version}", json: #"{"id": "string", "type": "skill_version_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.skills.versions.withStreamingResponse.delete("version", skillID: "skill_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `skill_id` but received ''") { _ = try await client.beta.skills.versions.withRawResponse.delete("version", skillID: "") }
        try await expectValueError("Expected a non-empty value for `version` but received ''") { _ = try await client.beta.skills.versions.withRawResponse.delete("", skillID: "skill_id") }
    }
}
