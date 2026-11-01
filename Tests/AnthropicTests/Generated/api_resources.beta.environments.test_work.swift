// Transformed from `tests/api_resources/beta/environments/test_work.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaEnvironmentsWork {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work/{work_id}", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.work.retrieve("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work/{work_id}", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.work.retrieve("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work/{work_id}", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let response = try await client.beta.environments.work.withRawResponse.retrieve("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work/{work_id}", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.environments.work.withStreamingResponse.retrieve("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `environment_id` but received ''") { _ = try await client.beta.environments.work.withRawResponse.retrieve("work_id", environmentID: "") }
        try await expectValueError("Expected a non-empty value for `work_id` but received ''") { _ = try await client.beta.environments.work.withRawResponse.retrieve("", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#, validateBody: { try MockRoute.roundTrip(AgentUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.environments.work.update("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", metadata: ["foo": "string"], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#, validateBody: { try MockRoute.roundTrip(AgentUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.environments.work.update("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", metadata: ["foo": "string"], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#, validateBody: { try MockRoute.roundTrip(AgentUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.environments.work.withRawResponse.update("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", metadata: ["foo": "string"], extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#, validateBody: { try MockRoute.roundTrip(AgentUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.environments.work.withStreamingResponse.update("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", metadata: ["foo": "string"], extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `environment_id` but received ''") { _ = try await client.beta.environments.work.withRawResponse.update("work_id", environmentID: "", metadata: ["foo": "string"]) }
        try await expectValueError("Expected a non-empty value for `work_id` but received ''") { _ = try await client.beta.environments.work.withRawResponse.update("", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", metadata: ["foo": "string"]) }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work", json: #"{"data": [{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.environments.work.list("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work", json: #"{"data": [{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.environments.work.list("env_011CZkZ9X2dpNyB7HsEFoRfW", limit: 1, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work", json: #"{"data": [{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.environments.work.withRawResponse.list("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work", json: #"{"data": [{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.environments.work.withStreamingResponse.list("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `environment_id` but received ''") { _ = try await client.beta.environments.work.withRawResponse.list("") }
    }

    @Test func methodAck() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}/ack", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.work.ack("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodAckWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}/ack", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.work.ack("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseAck() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}/ack", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let response = try await client.beta.environments.work.withRawResponse.ack("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseAck() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}/ack", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.environments.work.withStreamingResponse.ack("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsAck() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `environment_id` but received ''") { _ = try await client.beta.environments.work.withRawResponse.ack("work_id", environmentID: "") }
        try await expectValueError("Expected a non-empty value for `work_id` but received ''") { _ = try await client.beta.environments.work.withRawResponse.ack("", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW") }
    }

    @Test func methodHeartbeat() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}/heartbeat", json: #"{"last_heartbeat": "string", "lease_extended": true, "state": "queued", "ttl_seconds": 0, "type": "work_heartbeat"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.work.heartbeat("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodHeartbeatWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}/heartbeat", json: #"{"last_heartbeat": "string", "lease_extended": true, "state": "queued", "ttl_seconds": 0, "type": "work_heartbeat"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.work.heartbeat("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", desiredTtlSeconds: 0, expectedLastHeartbeat: "expected_last_heartbeat", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseHeartbeat() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}/heartbeat", json: #"{"last_heartbeat": "string", "lease_extended": true, "state": "queued", "ttl_seconds": 0, "type": "work_heartbeat"}"#)
        let client = try route.client()
        let response = try await client.beta.environments.work.withRawResponse.heartbeat("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseHeartbeat() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}/heartbeat", json: #"{"last_heartbeat": "string", "lease_extended": true, "state": "queued", "ttl_seconds": 0, "type": "work_heartbeat"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.environments.work.withStreamingResponse.heartbeat("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsHeartbeat() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `environment_id` but received ''") { _ = try await client.beta.environments.work.withRawResponse.heartbeat("work_id", environmentID: "") }
        try await expectValueError("Expected a non-empty value for `work_id` but received ''") { _ = try await client.beta.environments.work.withRawResponse.heartbeat("", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW") }
    }

    @Test func methodPoll() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work/poll", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.work.poll("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodPollWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work/poll", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.work.poll("env_011CZkZ9X2dpNyB7HsEFoRfW", blockMs: 1, reclaimOlderThanMs: 1, betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], anthropicWorkerID: "Anthropic-Worker-ID", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponsePoll() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work/poll", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let response = try await client.beta.environments.work.withRawResponse.poll("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponsePoll() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work/poll", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.environments.work.withStreamingResponse.poll("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsPoll() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `environment_id` but received ''") { _ = try await client.beta.environments.work.withRawResponse.poll("") }
    }

    @Test func methodStats() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work/stats", json: #"{"depth": 0, "oldest_queued_at": "string", "pending": 0, "type": "work_queue_stats", "workers_polling": 0}"#)
        let client = try route.client()
        let value = try await client.beta.environments.work.stats("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodStatsWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work/stats", json: #"{"depth": 0, "oldest_queued_at": "string", "pending": 0, "type": "work_queue_stats", "workers_polling": 0}"#)
        let client = try route.client()
        let value = try await client.beta.environments.work.stats("env_011CZkZ9X2dpNyB7HsEFoRfW", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseStats() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work/stats", json: #"{"depth": 0, "oldest_queued_at": "string", "pending": 0, "type": "work_queue_stats", "workers_polling": 0}"#)
        let client = try route.client()
        let response = try await client.beta.environments.work.withRawResponse.stats("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseStats() async throws {
        let route = MockRoute(method: "GET", path: "/v1/environments/{environment_id}/work/stats", json: #"{"depth": 0, "oldest_queued_at": "string", "pending": 0, "type": "work_queue_stats", "workers_polling": 0}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.environments.work.withStreamingResponse.stats("env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsStats() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `environment_id` but received ''") { _ = try await client.beta.environments.work.withRawResponse.stats("") }
    }

    @Test func methodStop() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}/stop", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.work.stop("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodStopWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}/stop", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let value = try await client.beta.environments.work.stop("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", force: true, betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseStop() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}/stop", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let response = try await client.beta.environments.work.withRawResponse.stop("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseStop() async throws {
        let route = MockRoute(method: "POST", path: "/v1/environments/{environment_id}/work/{work_id}/stop", json: #"{"id": "string", "acknowledged_at": "string", "created_at": "string", "data": {"id": "string", "type": "session"}, "environment_id": "string", "latest_heartbeat_at": "string", "metadata": {"key": "string"}, "secret": "string", "started_at": "string", "state": "queued", "stop_requested_at": "string", "stopped_at": "string", "type": "work"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.environments.work.withStreamingResponse.stop("work_id", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsStop() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `environment_id` but received ''") { _ = try await client.beta.environments.work.withRawResponse.stop("work_id", environmentID: "") }
        try await expectValueError("Expected a non-empty value for `work_id` but received ''") { _ = try await client.beta.environments.work.withRawResponse.stop("", environmentID: "env_011CZkZ9X2dpNyB7HsEFoRfW") }
    }
}
