// Transformed from `tests/api_resources/beta/test_skills.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaSkills {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/skills", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "latest_version_id": "string", "source": {"type": "custom"}, "type": "skill", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.skills.create(files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/skills", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "latest_version_id": "string", "source": {"type": "custom"}, "type": "skill", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.skills.create(files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], displayName: "display_name", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/skills", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "latest_version_id": "string", "source": {"type": "custom"}, "type": "skill", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.beta.skills.withRawResponse.create(files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/skills", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "latest_version_id": "string", "source": {"type": "custom"}, "type": "skill", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.skills.withStreamingResponse.create(files: [FileUpload(data: Data("Example data".utf8), filename: "upload")], extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills/{skill_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "latest_version_id": "string", "source": {"type": "custom"}, "type": "skill", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.skills.retrieve("skill_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills/{skill_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "latest_version_id": "string", "source": {"type": "custom"}, "type": "skill", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.skills.retrieve("skill_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills/{skill_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "latest_version_id": "string", "source": {"type": "custom"}, "type": "skill", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.beta.skills.withRawResponse.retrieve("skill_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills/{skill_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "latest_version_id": "string", "source": {"type": "custom"}, "type": "skill", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.skills.withStreamingResponse.retrieve("skill_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `skill_id` but received ''") { _ = try await client.beta.skills.withRawResponse.retrieve("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "latest_version_id": "string", "source": {"type": "custom"}, "type": "skill", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.skills.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "latest_version_id": "string", "source": {"type": "custom"}, "type": "skill", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.skills.list(limit: 1, page: "page", source: "source", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "latest_version_id": "string", "source": {"type": "custom"}, "type": "skill", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.skills.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/skills", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "latest_version_id": "string", "source": {"type": "custom"}, "type": "skill", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.skills.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/skills/{skill_id}", json: #"{"id": "string", "type": "skill_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.skills.delete("skill_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/skills/{skill_id}", json: #"{"id": "string", "type": "skill_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.skills.delete("skill_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/skills/{skill_id}", json: #"{"id": "string", "type": "skill_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.skills.withRawResponse.delete("skill_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/skills/{skill_id}", json: #"{"id": "string", "type": "skill_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.skills.withStreamingResponse.delete("skill_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `skill_id` but received ''") { _ = try await client.beta.skills.withRawResponse.delete("") }
    }
}
