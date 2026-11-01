// Transformed from `tests/api_resources/test_models.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestModels {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/models/{model_id}", json: #"{"id": "string", "capabilities": {"batch": {"supported": true}, "citations": {"supported": true}, "code_execution": {"supported": true}, "context_management": {"supported": true}, "effort": {"high": {"supported": true}, "low": {"supported": true}, "max": {"supported": true}, "medium": {"supported": true}, "supported": true}, "image_input": {"supported": true}, "pdf_input": {"supported": true}, "server_tools": {"code_execution": {"supported": true}, "supported": true, "web_search": {"supported": true}}, "structured_outputs": {"supported": true}, "thinking": {"supported": true, "types": {"adaptive": {"supported": true}, "between_tools": {"supported": true}, "disabled": {"supported": true}, "enabled": {"supported": true}}}}, "created_at": "2024-01-01T00:00:00Z", "deprecated_at": "2024-01-01T00:00:00Z", "display_name": "string", "lifecycle": "active", "line": "haiku", "max_input_tokens": 0, "max_tokens": 0, "retires_at": "2024-01-01T00:00:00Z", "type": "model"}"#)
        let client = try route.client()
        let value = try await client.models.retrieve("model_id")
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/models/{model_id}", json: #"{"id": "string", "capabilities": {"batch": {"supported": true}, "citations": {"supported": true}, "code_execution": {"supported": true}, "context_management": {"supported": true}, "effort": {"high": {"supported": true}, "low": {"supported": true}, "max": {"supported": true}, "medium": {"supported": true}, "supported": true}, "image_input": {"supported": true}, "pdf_input": {"supported": true}, "server_tools": {"code_execution": {"supported": true}, "supported": true, "web_search": {"supported": true}}, "structured_outputs": {"supported": true}, "thinking": {"supported": true, "types": {"adaptive": {"supported": true}, "between_tools": {"supported": true}, "disabled": {"supported": true}, "enabled": {"supported": true}}}}, "created_at": "2024-01-01T00:00:00Z", "deprecated_at": "2024-01-01T00:00:00Z", "display_name": "string", "lifecycle": "active", "line": "haiku", "max_input_tokens": 0, "max_tokens": 0, "retires_at": "2024-01-01T00:00:00Z", "type": "model"}"#)
        let client = try route.client()
        let value = try await client.models.retrieve("model_id", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/models/{model_id}", json: #"{"id": "string", "capabilities": {"batch": {"supported": true}, "citations": {"supported": true}, "code_execution": {"supported": true}, "context_management": {"supported": true}, "effort": {"high": {"supported": true}, "low": {"supported": true}, "max": {"supported": true}, "medium": {"supported": true}, "supported": true}, "image_input": {"supported": true}, "pdf_input": {"supported": true}, "server_tools": {"code_execution": {"supported": true}, "supported": true, "web_search": {"supported": true}}, "structured_outputs": {"supported": true}, "thinking": {"supported": true, "types": {"adaptive": {"supported": true}, "between_tools": {"supported": true}, "disabled": {"supported": true}, "enabled": {"supported": true}}}}, "created_at": "2024-01-01T00:00:00Z", "deprecated_at": "2024-01-01T00:00:00Z", "display_name": "string", "lifecycle": "active", "line": "haiku", "max_input_tokens": 0, "max_tokens": 0, "retires_at": "2024-01-01T00:00:00Z", "type": "model"}"#)
        let client = try route.client()
        let response = try await client.models.withRawResponse.retrieve("model_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/models/{model_id}", json: #"{"id": "string", "capabilities": {"batch": {"supported": true}, "citations": {"supported": true}, "code_execution": {"supported": true}, "context_management": {"supported": true}, "effort": {"high": {"supported": true}, "low": {"supported": true}, "max": {"supported": true}, "medium": {"supported": true}, "supported": true}, "image_input": {"supported": true}, "pdf_input": {"supported": true}, "server_tools": {"code_execution": {"supported": true}, "supported": true, "web_search": {"supported": true}}, "structured_outputs": {"supported": true}, "thinking": {"supported": true, "types": {"adaptive": {"supported": true}, "between_tools": {"supported": true}, "disabled": {"supported": true}, "enabled": {"supported": true}}}}, "created_at": "2024-01-01T00:00:00Z", "deprecated_at": "2024-01-01T00:00:00Z", "display_name": "string", "lifecycle": "active", "line": "haiku", "max_input_tokens": 0, "max_tokens": 0, "retires_at": "2024-01-01T00:00:00Z", "type": "model"}"#)
        let client = try route.client()
        let (response, value) = try await client.models.withStreamingResponse.retrieve("model_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `model_id` but received ''") { _ = try await client.models.withRawResponse.retrieve("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/models", json: #"{"data": [{"id": "string", "capabilities": {"batch": {"supported": true}, "citations": {"supported": true}, "code_execution": {"supported": true}, "context_management": {"supported": true}, "effort": {"high": {"supported": true}, "low": {"supported": true}, "max": {"supported": true}, "medium": {"supported": true}, "supported": true}, "image_input": {"supported": true}, "pdf_input": {"supported": true}, "server_tools": {"code_execution": {"supported": true}, "supported": true, "web_search": {"supported": true}}, "structured_outputs": {"supported": true}, "thinking": {"supported": true, "types": {"adaptive": {"supported": true}, "between_tools": {"supported": true}, "disabled": {"supported": true}, "enabled": {"supported": true}}}}, "created_at": "2024-01-01T00:00:00Z", "deprecated_at": "2024-01-01T00:00:00Z", "display_name": "string", "lifecycle": "active", "line": "haiku", "max_input_tokens": 0, "max_tokens": 0, "retires_at": "2024-01-01T00:00:00Z", "type": "model"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.models.list()
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/models", json: #"{"data": [{"id": "string", "capabilities": {"batch": {"supported": true}, "citations": {"supported": true}, "code_execution": {"supported": true}, "context_management": {"supported": true}, "effort": {"high": {"supported": true}, "low": {"supported": true}, "max": {"supported": true}, "medium": {"supported": true}, "supported": true}, "image_input": {"supported": true}, "pdf_input": {"supported": true}, "server_tools": {"code_execution": {"supported": true}, "supported": true, "web_search": {"supported": true}}, "structured_outputs": {"supported": true}, "thinking": {"supported": true, "types": {"adaptive": {"supported": true}, "between_tools": {"supported": true}, "disabled": {"supported": true}, "enabled": {"supported": true}}}}, "created_at": "2024-01-01T00:00:00Z", "deprecated_at": "2024-01-01T00:00:00Z", "display_name": "string", "lifecycle": "active", "line": "haiku", "max_input_tokens": 0, "max_tokens": 0, "retires_at": "2024-01-01T00:00:00Z", "type": "model"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.models.list(afterID: "after_id", beforeID: "before_id", lifecycle: ["active"], limit: 1, workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/models", json: #"{"data": [{"id": "string", "capabilities": {"batch": {"supported": true}, "citations": {"supported": true}, "code_execution": {"supported": true}, "context_management": {"supported": true}, "effort": {"high": {"supported": true}, "low": {"supported": true}, "max": {"supported": true}, "medium": {"supported": true}, "supported": true}, "image_input": {"supported": true}, "pdf_input": {"supported": true}, "server_tools": {"code_execution": {"supported": true}, "supported": true, "web_search": {"supported": true}}, "structured_outputs": {"supported": true}, "thinking": {"supported": true, "types": {"adaptive": {"supported": true}, "between_tools": {"supported": true}, "disabled": {"supported": true}, "enabled": {"supported": true}}}}, "created_at": "2024-01-01T00:00:00Z", "deprecated_at": "2024-01-01T00:00:00Z", "display_name": "string", "lifecycle": "active", "line": "haiku", "max_input_tokens": 0, "max_tokens": 0, "retires_at": "2024-01-01T00:00:00Z", "type": "model"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.models.withRawResponse.list()
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/models", json: #"{"data": [{"id": "string", "capabilities": {"batch": {"supported": true}, "citations": {"supported": true}, "code_execution": {"supported": true}, "context_management": {"supported": true}, "effort": {"high": {"supported": true}, "low": {"supported": true}, "max": {"supported": true}, "medium": {"supported": true}, "supported": true}, "image_input": {"supported": true}, "pdf_input": {"supported": true}, "server_tools": {"code_execution": {"supported": true}, "supported": true, "web_search": {"supported": true}}, "structured_outputs": {"supported": true}, "thinking": {"supported": true, "types": {"adaptive": {"supported": true}, "between_tools": {"supported": true}, "disabled": {"supported": true}, "enabled": {"supported": true}}}}, "created_at": "2024-01-01T00:00:00Z", "deprecated_at": "2024-01-01T00:00:00Z", "display_name": "string", "lifecycle": "active", "line": "haiku", "max_input_tokens": 0, "max_tokens": 0, "retires_at": "2024-01-01T00:00:00Z", "type": "model"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.models.withStreamingResponse.list(body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }
}
