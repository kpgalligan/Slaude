// Transformed from `tests/api_resources/beta/test_deployments.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaDeployments {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#, validateBody: { try MockRoute.roundTrip(DeploymentCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.deployments.create(agent: DeploymentCreateParams.Agent.string("string"), environmentID: "x", initialEvents: [BetaManagedAgentsDeploymentInitialEventParams.userMessage(BetaManagedAgentsUserMessageEventParams(content: [BetaManagedAgentsUserMessageEventParams.Content.text(BetaManagedAgentsTextBlockParam(text: "Where is my order #1234?", type: "text"))], type: "user.message"))], name: "x", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#, validateBody: { try MockRoute.roundTrip(DeploymentCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.deployments.create(agent: DeploymentCreateParams.Agent.string("string"), environmentID: "x", initialEvents: [BetaManagedAgentsDeploymentInitialEventParams.userMessage(BetaManagedAgentsUserMessageEventParams(content: [BetaManagedAgentsUserMessageEventParams.Content.text(BetaManagedAgentsTextBlockParam(text: "Where is my order #1234?", type: "text"))], type: "user.message"))], name: "x", budget: BetaManagedAgentsBudgetLimitParam(maxListCost: BetaMonetaryAmountParam(amount: "2500", currency: BetaCurrency(rawValue: "USD")), type: "limit"), description: "description", metadata: ["foo": "string"], resources: [DeploymentCreateParams.Resource.file(BetaManagedAgentsFileResourceParams(fileID: "file_011CNha8iCJcU1wXNR6q4V8w", type: "file", mountPath: "/uploads/receipt.pdf"))], schedule: BetaManagedAgentsScheduleParams(expression: "0 9 * * 1-5", timezone: "America/Los_Angeles", type: "cron"), vaultIDs: ["string"], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#, validateBody: { try MockRoute.roundTrip(DeploymentCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.deployments.withRawResponse.create(agent: DeploymentCreateParams.Agent.string("string"), environmentID: "x", initialEvents: [BetaManagedAgentsDeploymentInitialEventParams.userMessage(BetaManagedAgentsUserMessageEventParams(content: [BetaManagedAgentsUserMessageEventParams.Content.text(BetaManagedAgentsTextBlockParam(text: "Where is my order #1234?", type: "text"))], type: "user.message"))], name: "x", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#, validateBody: { try MockRoute.roundTrip(DeploymentCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.deployments.withStreamingResponse.create(agent: DeploymentCreateParams.Agent.string("string"), environmentID: "x", initialEvents: [BetaManagedAgentsDeploymentInitialEventParams.userMessage(BetaManagedAgentsUserMessageEventParams(content: [BetaManagedAgentsUserMessageEventParams.Content.text(BetaManagedAgentsTextBlockParam(text: "Where is my order #1234?", type: "text"))], type: "user.message"))], name: "x", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployments/{deployment_id}", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let value = try await client.beta.deployments.retrieve("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployments/{deployment_id}", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let value = try await client.beta.deployments.retrieve("depl_011CZkZcDH3vPqd7xnEfwTai", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployments/{deployment_id}", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let response = try await client.beta.deployments.withRawResponse.retrieve("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployments/{deployment_id}", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.deployments.withStreamingResponse.retrieve("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `deployment_id` but received ''") { _ = try await client.beta.deployments.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#, validateBody: { try MockRoute.roundTrip(DeploymentUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.deployments.update("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#, validateBody: { try MockRoute.roundTrip(DeploymentUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.deployments.update("depl_011CZkZcDH3vPqd7xnEfwTai", agent: DeploymentUpdateParams.Agent.string("string"), budget: BetaManagedAgentsBudgetLimitParam(maxListCost: BetaMonetaryAmountParam(amount: "2500", currency: BetaCurrency(rawValue: "USD")), type: "limit"), description: "description", environmentID: "environment_id", initialEvents: [BetaManagedAgentsDeploymentInitialEventParams.userMessage(BetaManagedAgentsUserMessageEventParams(content: [BetaManagedAgentsUserMessageEventParams.Content.text(BetaManagedAgentsTextBlockParam(text: "Where is my order #1234?", type: "text"))], type: "user.message"))], metadata: ["foo": "string"], name: "name", resources: [DeploymentUpdateParams.Resource.file(BetaManagedAgentsFileResourceParams(fileID: "file_011CNha8iCJcU1wXNR6q4V8w", type: "file", mountPath: "/uploads/receipt.pdf"))], schedule: BetaManagedAgentsScheduleParams(expression: "0 9 * * 1-5", timezone: "America/Los_Angeles", type: "cron"), vaultIDs: ["string"], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#, validateBody: { try MockRoute.roundTrip(DeploymentUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.deployments.withRawResponse.update("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#, validateBody: { try MockRoute.roundTrip(DeploymentUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.deployments.withStreamingResponse.update("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `deployment_id` but received ''") { _ = try await client.beta.deployments.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployments", json: #"{"data": [{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.deployments.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployments", json: #"{"data": [{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.deployments.list(agentID: "agent_id", createdAtGte: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), createdAtLte: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), includeArchived: true, limit: 0, page: "page", status: BetaManagedAgentsDeploymentStatus(rawValue: "active"), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployments", json: #"{"data": [{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.deployments.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployments", json: #"{"data": [{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.deployments.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/archive", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let value = try await client.beta.deployments.archive("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodArchiveWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/archive", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let value = try await client.beta.deployments.archive("depl_011CZkZcDH3vPqd7xnEfwTai", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/archive", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let response = try await client.beta.deployments.withRawResponse.archive("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/archive", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.deployments.withStreamingResponse.archive("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsArchive() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `deployment_id` but received ''") { _ = try await client.beta.deployments.withRawResponse.archive("") }
    }

    @Test func methodPause() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/pause", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let value = try await client.beta.deployments.pause("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodPauseWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/pause", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let value = try await client.beta.deployments.pause("depl_011CZkZcDH3vPqd7xnEfwTai", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponsePause() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/pause", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let response = try await client.beta.deployments.withRawResponse.pause("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponsePause() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/pause", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.deployments.withStreamingResponse.pause("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsPause() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `deployment_id` but received ''") { _ = try await client.beta.deployments.withRawResponse.pause("") }
    }

    @Test func methodRun() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/run", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "created_at": "2024-01-01T00:00:00Z", "deployment_id": "string", "error": {"message": "string", "type": "environment_archived_error"}, "session_id": "string", "trigger_context": {"scheduled_at": "2024-01-01T00:00:00Z", "type": "schedule"}, "type": "deployment_run"}"#)
        let client = try route.client()
        let value = try await client.beta.deployments.run("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRunWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/run", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "created_at": "2024-01-01T00:00:00Z", "deployment_id": "string", "error": {"message": "string", "type": "environment_archived_error"}, "session_id": "string", "trigger_context": {"scheduled_at": "2024-01-01T00:00:00Z", "type": "schedule"}, "type": "deployment_run"}"#)
        let client = try route.client()
        let value = try await client.beta.deployments.run("depl_011CZkZcDH3vPqd7xnEfwTai", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRun() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/run", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "created_at": "2024-01-01T00:00:00Z", "deployment_id": "string", "error": {"message": "string", "type": "environment_archived_error"}, "session_id": "string", "trigger_context": {"scheduled_at": "2024-01-01T00:00:00Z", "type": "schedule"}, "type": "deployment_run"}"#)
        let client = try route.client()
        let response = try await client.beta.deployments.withRawResponse.run("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRun() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/run", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "created_at": "2024-01-01T00:00:00Z", "deployment_id": "string", "error": {"message": "string", "type": "environment_archived_error"}, "session_id": "string", "trigger_context": {"scheduled_at": "2024-01-01T00:00:00Z", "type": "schedule"}, "type": "deployment_run"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.deployments.withStreamingResponse.run("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRun() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `deployment_id` but received ''") { _ = try await client.beta.deployments.withRawResponse.run("") }
    }

    @Test func methodUnpause() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/unpause", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let value = try await client.beta.deployments.unpause("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUnpauseWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/unpause", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let value = try await client.beta.deployments.unpause("depl_011CZkZcDH3vPqd7xnEfwTai", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUnpause() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/unpause", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let response = try await client.beta.deployments.withRawResponse.unpause("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUnpause() async throws {
        let route = MockRoute(method: "POST", path: "/v1/deployments/{deployment_id}/unpause", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "environment_id": "string", "initial_events": [{"content": [{"text": "string", "type": "text"}], "type": "user.message"}], "metadata": {"key": "string"}, "name": "string", "paused_reason": {"type": "manual"}, "resources": [{"type": "github_repository", "url": "string"}], "schedule": {"expression": "string", "timezone": "string", "type": "cron", "last_run_at": "2024-01-01T00:00:00Z", "upcoming_runs_at": ["2024-01-01T00:00:00Z"]}, "status": "active", "type": "deployment", "updated_at": "2024-01-01T00:00:00Z", "vault_ids": ["string"], "budget": {"max_list_cost": {"amount": "string", "currency": "USD"}, "type": "limit"}}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.deployments.withStreamingResponse.unpause("depl_011CZkZcDH3vPqd7xnEfwTai", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUnpause() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `deployment_id` but received ''") { _ = try await client.beta.deployments.withRawResponse.unpause("") }
    }
}
