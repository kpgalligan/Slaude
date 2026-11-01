// Port of `TestResourceIds`, `TestMalformedResponses`, `TestMalformedCountsAndBatches`, `TestTracingFailures` and the
// tripwires of tests/test_open_telemetry.py. See docs/porting/tracing.md for what is skipped.
//
// Python runs these calls without strict response validation, with bodies that have only the fields that the span
// reads. A Swift response always decodes into its type, so the calls whose span reads the response's body are made
// with `withRawResponse`, whose body is read and not decoded: the span reads the body all the same.

import Foundation
import Testing
@testable import Anthropic

/// `resource_ids`: the attributes of `span` that hold the ID of an API object.
func tracingResourceIDs(_ span: SpanData) -> SpanAttributes {
    let common: Set<String> = ["anthropic.request.id", "anthropic.organization.id", "anthropic.workspace.id"]
    return span.attributes.filter { $0.key.hasSuffix(".id") && !common.contains($0.key) }
}

/// `assert_http_attributes` of `TestResourceIds`: the span is of a `method` request to `path`, and its route is `path`
/// with a placeholder for each ID.
func tracingExpectRoute(_ span: SpanData, _ method: String, _ path: String, sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(span["http.request.method"] == .string(method), sourceLocation: sourceLocation)
    #expect(span["url.path"] == .string(path), sourceLocation: sourceLocation)
    let route = span["http.route"]?.stringValue ?? ""
    let marked = route.replacingOccurrences(of: "\\{[a-z_]+\\}", with: "\u{0}", options: .regularExpression)
    let pattern = "^" + NSRegularExpression.escapedPattern(for: marked).replacingOccurrences(of: "\u{0}", with: "[^/]+") + "$"
    #expect(path.range(of: pattern, options: .regularExpression) != nil, "\(route)", sourceLocation: sourceLocation)
    let routeParts = Set(route.split(separator: "/"))
    #expect(route.filter { $0 == "{" }.count == path.split(separator: "/").filter { !routeParts.contains($0) }.count, sourceLocation: sourceLocation)
}

func tracingEnum<T: Decodable>(_ value: String) -> T { try! JSONValue.string(value).decode() }

let tracingSession: JSONValue = [
    "id": "sesn_1", "type": "session", "environment_id": "env_1",
    "agent": ["type": "agent", "id": "agent_1", "version": 2, "name": "Researcher", "model": ["id": "claude-test"]],
]

/// `RESOURCE_CALLS`: one method of each resource, called for its raw response: the request it makes, the body of its
/// response, and its span's name and IDs.
struct TracingResourceCall: Sendable {
    let method: String
    let path: String
    let body: JSONValue
    let name: String
    let ids: SpanAttributes
    let invoke: TracingInvoke

    static let file = FileUpload(data: Data("Hello".utf8), filename: "notes.txt")
    static let skillFile = FileUpload(data: Data("Hello".utf8), filename: "skill/SKILL.md")

    static let all: [TracingResourceCall] = [
        .init(method: "GET", path: "/v1/messages/batches/msgbatch_1", body: ["id": "msgbatch_1"], name: "anthropic.messages.batches.retrieve",
              ids: ["anthropic.message.batch.id": "msgbatch_1"]) { _ = try await $0.messages.batches.withRawResponse.retrieve("msgbatch_1") },
        .init(method: "POST", path: "/v1/messages/batches/msgbatch_1/cancel", body: ["id": "msgbatch_1"], name: "anthropic.messages.batches.cancel",
              ids: ["anthropic.message.batch.id": "msgbatch_1"]) { _ = try await $0.beta.messages.batches.withRawResponse.cancel("msgbatch_1") },
        // The value is the one in the path, which can be an alias.
        .init(method: "GET", path: "/v1/models/claude-latest", body: ["id": "claude-1"], name: "anthropic.models.retrieve",
              ids: ["anthropic.model.id": "claude-latest"]) { _ = try await $0.models.withRawResponse.retrieve("claude-latest") },
        .init(method: "POST", path: "/v1/files", body: ["id": "file_1"], name: "anthropic.files.upload", ids: ["anthropic.file.id": "file_1"]) {
            _ = try await $0.beta.files.withRawResponse.upload(file: file)
        },
        .init(method: "DELETE", path: "/v1/files/file_1", body: ["id": "file_1"], name: "anthropic.files.delete", ids: ["anthropic.file.id": "file_1"]) {
            _ = try await $0.files.withRawResponse.delete("file_1")
        },
        .init(method: "POST", path: "/v1/skills", body: ["id": "skill_1"], name: "anthropic.skills.create", ids: ["anthropic.skill.id": "skill_1"]) {
            _ = try await $0.beta.skills.withRawResponse.create(files: [skillFile])
        },
        // A path parameter that is not an ID has an attribute too, with the value in the path.
        .init(method: "GET", path: "/v1/skills/skill_1/versions/latest", body: ["id": "skillver_1", "version": "1759178010641129"],
              name: "anthropic.skills.versions.retrieve", ids: ["anthropic.skill.id": "skill_1", "anthropic.skill.version.id": "latest"]) {
            _ = try await $0.skills.versions.withRawResponse.retrieve("latest", skillID: "skill_1")
        },
        .init(method: "POST", path: "/v1/skills/skill_1/versions", body: ["id": "skillver_1", "version": "1759178010641129"],
              name: "anthropic.skills.versions.create", ids: ["anthropic.skill.id": "skill_1", "anthropic.skill.version.id": "skillver_1"]) {
            _ = try await $0.beta.skills.versions.withRawResponse.create("skill_1", files: [skillFile])
        },
        .init(method: "GET", path: "/v1/deployments/depl_1", body: ["id": "depl_1"], name: "anthropic.deployments.retrieve",
              ids: ["anthropic.deployment.id": "depl_1"]) { _ = try await $0.beta.deployments.withRawResponse.retrieve("depl_1") },
        // A Run's methods are at another path, so the method that starts one has no ID for it.
        .init(method: "POST", path: "/v1/deployments/depl_1/run", body: ["id": "drun_1"], name: "anthropic.deployments.run",
              ids: ["anthropic.deployment.id": "depl_1"]) { _ = try await $0.beta.deployments.withRawResponse.run("depl_1") },
        .init(method: "GET", path: "/v1/deployment_runs/drun_1", body: ["id": "drun_1"], name: "anthropic.deployment_runs.retrieve",
              ids: ["anthropic.deployment_run.id": "drun_1"]) { _ = try await $0.beta.deploymentRuns.withRawResponse.retrieve("drun_1") },
        .init(method: "GET", path: "/v1/dreams/dream_1", body: ["id": "dream_1"], name: "anthropic.dreams.retrieve",
              ids: ["anthropic.dream.id": "dream_1"]) { _ = try await $0.beta.dreams.withRawResponse.retrieve("dream_1") },
        .init(method: "POST", path: "/v1/environments", body: ["id": "env_1"], name: "anthropic.environments.create",
              ids: ["anthropic.environment.id": "env_1"]) { _ = try await $0.beta.environments.withRawResponse.create(name: "Sandbox") },
        .init(method: "GET", path: "/v1/environments/env_1/work/work_1", body: ["id": "work_1"], name: "anthropic.environments.work.retrieve",
              ids: ["anthropic.environment.id": "env_1", "anthropic.environment.work.id": "work_1"]) {
            _ = try await $0.beta.environments.work.withRawResponse.retrieve("work_1", environmentID: "env_1")
        },
        // A Memory Store and a Memory have `gen_ai.*` attributes.
        .init(method: "GET", path: "/v1/memory_stores/memstore_1", body: ["id": "memstore_1"], name: "anthropic.memory_stores.retrieve",
              ids: ["gen_ai.memory.store.id": "memstore_1"]) { _ = try await $0.beta.memoryStores.withRawResponse.retrieve("memstore_1") },
        .init(method: "POST", path: "/v1/memory_stores/memstore_1/memories", body: ["id": "mem_1"], name: "anthropic.memory_stores.memories.create",
              ids: ["gen_ai.memory.store.id": "memstore_1", "gen_ai.memory.record.id": "mem_1"]) {
            _ = try await $0.beta.memoryStores.memories.withRawResponse.create("memstore_1", content: "Hello", path: "/notes.md")
        },
        .init(method: "GET", path: "/v1/memory_stores/memstore_1/memories/mem_1", body: ["id": "mem_1"], name: "anthropic.memory_stores.memories.retrieve",
              ids: ["gen_ai.memory.store.id": "memstore_1", "gen_ai.memory.record.id": "mem_1"]) {
            _ = try await $0.beta.memoryStores.memories.withRawResponse.retrieve("mem_1", memoryStoreID: "memstore_1")
        },
        .init(method: "GET", path: "/v1/memory_stores/memstore_1/memory_versions/memver_1", body: ["id": "memver_1"],
              name: "anthropic.memory_stores.memory_versions.retrieve",
              ids: ["gen_ai.memory.store.id": "memstore_1", "anthropic.memory_store.memory_version.id": "memver_1"]) {
            _ = try await $0.beta.memoryStores.memoryVersions.withRawResponse.retrieve("memver_1", memoryStoreID: "memstore_1")
        },
        .init(method: "POST", path: "/v1/sessions/sesn_1/resources", body: ["id": "sesrsc_1", "file_id": "file_1"], name: "anthropic.sessions.resources.add",
              ids: ["anthropic.session.id": "sesn_1", "anthropic.session.resource.id": "sesrsc_1"]) {
            _ = try await $0.beta.sessions.resources.withRawResponse.add("sesn_1", fileID: "file_1", type: "file")
        },
        .init(method: "POST", path: "/v1/tunnels/tunnel_1/certificates", body: ["id": "cert_1"], name: "anthropic.tunnels.certificates.create",
              ids: ["anthropic.tunnel.id": "tunnel_1", "anthropic.tunnel.certificate.id": "cert_1"]) {
            _ = try await $0.beta.tunnels.certificates.withRawResponse.create("tunnel_1", caCertificatePem: "pem")
        },
        .init(method: "GET", path: "/v1/user_profiles/uprof_1", body: ["id": "uprof_1"], name: "anthropic.user_profiles.retrieve",
              ids: ["anthropic.user_profile.id": "uprof_1"]) { _ = try await $0.beta.userProfiles.withRawResponse.retrieve("uprof_1") },
        .init(method: "GET", path: "/v1/vaults/vault_1/credentials/cred_1", body: ["id": "cred_1"], name: "anthropic.vaults.credentials.retrieve",
              ids: ["anthropic.vault.id": "vault_1", "anthropic.vault.credential.id": "cred_1"]) {
            _ = try await $0.beta.vaults.credentials.withRawResponse.retrieve("cred_1", vaultID: "vault_1")
        },
        .init(method: "GET", path: "/v1/organizations/api_keys/apikey_1", body: ["id": "apikey_1"], name: "anthropic.organization.api_keys.retrieve",
              ids: ["anthropic.organization.api_key.id": "apikey_1"]) { _ = try await $0.beta.organization.apiKeys.withRawResponse.retrieve("apikey_1") },
        .init(method: "GET", path: "/v1/organizations/external_keys/extkey_1", body: ["id": "extkey_1"],
              name: "anthropic.organization.external_keys.retrieve", ids: ["anthropic.organization.external_key.id": "extkey_1"]) {
            _ = try await $0.beta.organization.externalKeys.withRawResponse.retrieve("extkey_1")
        },
        .init(method: "POST", path: "/v1/organizations/invites", body: ["id": "invite_1"], name: "anthropic.organization.invites.create",
              ids: ["anthropic.organization.invite.id": "invite_1"]) {
            _ = try await $0.beta.organization.invites.withRawResponse.create(email: "user@example.com", role: tracingEnum("user"))
        },
        .init(method: "GET", path: "/v1/organizations/users/user_1", body: ["id": "user_1"], name: "anthropic.organization.users.retrieve",
              ids: ["anthropic.organization.user.id": "user_1"]) { _ = try await $0.beta.organization.users.withRawResponse.retrieve("user_1") },
        .init(method: "GET", path: "/v1/organizations/service_accounts/svcacct_1", body: ["id": "svcacct_1"],
              name: "anthropic.organization.service_accounts.retrieve", ids: ["anthropic.organization.service_account.id": "svcacct_1"]) {
            _ = try await $0.beta.organization.serviceAccounts.withRawResponse.retrieve("svcacct_1")
        },
        // Named after the path, which keeps a Workspace in a path or a response apart from `anthropic.workspace.id`, the
        // workspace that the client makes its requests for.
        .init(method: "POST", path: "/v1/organizations/workspaces", body: ["id": "wrkspc_1"], name: "anthropic.organization.workspaces.create",
              ids: ["anthropic.organization.workspace.id": "wrkspc_1"]) { _ = try await $0.beta.organization.workspaces.withRawResponse.create(name: "Research") },
        .init(method: "GET", path: "/v1/organizations/workspaces/wrkspc_1", body: ["id": "wrkspc_1"], name: "anthropic.organization.workspaces.retrieve",
              ids: ["anthropic.organization.workspace.id": "wrkspc_1"]) { _ = try await $0.beta.organization.workspaces.withRawResponse.retrieve("wrkspc_1") },
        .init(method: "GET", path: "/v1/organizations/federation_issuers/fdis_1", body: ["id": "fdis_1"],
              name: "anthropic.organization.federation.issuers.retrieve", ids: ["anthropic.organization.federation_issuer.id": "fdis_1"]) {
            _ = try await $0.beta.organization.federation.issuers.withRawResponse.retrieve("fdis_1")
        },
        .init(method: "GET", path: "/v1/organizations/federation_rules/fdrl_1", body: ["id": "fdrl_1"],
              name: "anthropic.organization.federation.rules.retrieve", ids: ["anthropic.organization.federation_rule.id": "fdrl_1"]) {
            _ = try await $0.beta.organization.federation.rules.withRawResponse.retrieve("fdrl_1")
        },
        // A membership has no `id`. The ID of what the method added is in the field that the path's parameter names.
        .init(method: "POST", path: "/v1/organizations/workspaces/wrkspc_1/members",
              body: ["type": "workspace_member", "user_id": "user_1", "workspace_id": "wrkspc_1"], name: "anthropic.organization.workspaces.members.add",
              ids: ["anthropic.organization.workspace.id": "wrkspc_1", "anthropic.organization.workspace.member.id": "user_1"]) {
            _ = try await $0.beta.organization.workspaces.members.withRawResponse.add("wrkspc_1", userID: "user_1", workspaceRole: tracingEnum("workspace_user"))
        },
        .init(method: "POST", path: "/v1/organizations/workspaces/wrkspc_1/service_accounts", body: ["service_account_id": "svcacct_1", "workspace_id": "wrkspc_1"],
              name: "anthropic.organization.workspaces.service_accounts.add",
              ids: ["anthropic.organization.workspace.id": "wrkspc_1", "anthropic.organization.workspace.service_account.id": "svcacct_1"]) {
            _ = try await $0.beta.organization.workspaces.serviceAccounts.withRawResponse.add("wrkspc_1", serviceAccountID: "svcacct_1",
                                                                                              workspaceRole: tracingEnum("workspace_user"))
        },
        .init(method: "POST", path: "/v1/organizations/service_accounts/svcacct_1/workspaces", body: ["service_account_id": "svcacct_1", "workspace_id": "wrkspc_1"],
              name: "anthropic.organization.service_accounts.workspaces.add",
              ids: ["anthropic.organization.service_account.id": "svcacct_1", "anthropic.organization.service_account.workspace.id": "wrkspc_1"]) {
            _ = try await $0.beta.organization.serviceAccounts.workspaces.withRawResponse.add("svcacct_1", workspaceID: "wrkspc_1",
                                                                                              workspaceRole: tracingEnum("workspace_user"))
        },
        .init(method: "POST", path: "/v1/organizations/federation_rules/fdrl_1/workspaces", body: ["federation_rule_id": "fdrl_1", "workspace_id": "wrkspc_1"],
              name: "anthropic.organization.federation.rules.workspaces.add",
              ids: ["anthropic.organization.federation_rule.id": "fdrl_1", "anthropic.organization.federation_rule.workspace.id": "wrkspc_1"]) {
            _ = try await $0.beta.organization.federation.rules.workspaces.withRawResponse.add("fdrl_1", workspaceID: "wrkspc_1")
        },
    ]
}

@Suite struct OpenTelemetryResourceIDTests {
    static let thread: JSONValue = ["id": "sthr_1", "type": "session_thread"]
    static let threadIDs: SpanAttributes = ["anthropic.session.id": "sesn_1", "anthropic.session.thread.id": "sthr_1", "gen_ai.conversation.id": "sthr_1"]

    @Test func idsInThePath() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/v1/sessions/sesn_1/threads/sthr_1", .json(Self.thread))
        router.route("POST", "/v1/sessions/sesn_1/threads/sthr_1/archive", .json(Self.thread))
        router.route("GET", "/v1/sessions/sesn_1", .json(["id": "sesn_1"]))
        router.route("POST", "/v1/sessions", .json(["id": "sesn_2"]))
        let client = try tracingClient(spans, router)

        _ = try await client.beta.sessions.threads.withRawResponse.retrieve("sthr_1", sessionID: "sesn_1")
        _ = try await client.beta.sessions.threads.withRawResponse.archive("sthr_1", sessionID: "sesn_1")
        _ = try await client.beta.sessions.withRawResponse.retrieve("sesn_1")
        _ = try await client.beta.sessions.withRawResponse.create(agent: "agent_1", environmentID: "env_1")

        // One attribute for each ID in the path, named after the resources down to the one it identifies.
        // The thread's ID is the conversation's ID too.
        #expect(tracingResourceIDs(try spans.one("anthropic.sessions.threads.retrieve")) == Self.threadIDs)
        #expect(tracingResourceIDs(try spans.one("anthropic.sessions.threads.archive")) == Self.threadIDs)
        #expect(tracingResourceIDs(try spans.one("anthropic.sessions.retrieve")) == ["anthropic.session.id": "sesn_1"])
        #expect(tracingResourceIDs(try spans.one("anthropic.sessions.create")) == [
            "anthropic.session.id": "sesn_2", "gen_ai.agent.id": "agent_1", "anthropic.session.environment.id": "env_1",
        ])
    }

    @Test func aValueInThePathThatIsNoIDIsRecordedAsItIs() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/v1/skills/skill_1/versions/latest", .json(["id": "skillver_1", "version": "1759178010641129"]))

        _ = try await tracingClient(spans, router).beta.skills.versions.withRawResponse.retrieve("latest", skillID: "skill_1")

        // The attribute has what the path has, not the ID of the version that the API resolved it to.
        let span = try spans.one("anthropic.skills.versions.retrieve")
        #expect(tracingResourceIDs(span) == ["anthropic.skill.id": "skill_1", "anthropic.skill.version.id": "latest"])
        #expect(span["url.path"] == "/v1/skills/skill_1/versions/latest")
    }

    @Test func aFailedRequestForAMalformedIDHasTheIDAndThePath() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/v1/files/not%20an%20id", .json(["type": "error", "error": ["type": "not_found_error", "message": "Not found"]], status: 404))

        await #expect(throws: APIStatusError.self) { _ = try await tracingClient(spans, router).beta.files.retrieveMetadata("not an id") }

        let span = try spans.one("anthropic.files.retrieve_metadata")
        #expect(span.statusCode == .error)
        #expect(span["error.type"] == "not_found_error")
        #expect(tracingResourceIDs(span) == ["anthropic.file.id": "not an id"])
        #expect(span["http.route"] == "/v1/files/{file_id}")
        #expect(span.urlAttributes == [
            "url.scheme": "http", "url.path": "/v1/files/not%20an%20id", "url.full": .string("\(tracingBaseURL)/v1/files/not%20an%20id"),
        ])
    }

    @Test(arguments: [true, false])
    func sessionCreateSendsAnAgentWithoutAnIDForTheAPIToReject(traces: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "/v1/sessions", .json(["id": "sesn_1"]))
        let agents: [JSONValue] = [["type": "agent", "version": 1], ["type": "agent", "id": "agent_2"], 7]
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: OpenTelemetryTraces(enabled: traces)))

        for agent in agents {
            _ = try await client.beta.sessions.withRawResponse.create(agent: "agent", environmentID: "env_1", extraBody: ["agent": agent])
        }

        // The SDK sends what it is given, and reads the span's attributes from it only when there is a span.
        #expect(route.requests.map { $0.jsonBody?["agent"] } == agents)
        #expect(spans.named("anthropic.sessions.create").map { $0["gen_ai.agent.id"] } == (traces ? [nil, "agent_2", nil] : []))
    }

    @Test(arguments: [JSONValue.object([:]), ["id": nil], ["id": 7]])
    func createWithoutAnIDInItsResponse(body: JSONValue) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/sessions", .json(body))

        _ = try await tracingClient(spans, router).beta.sessions.withRawResponse.create(agent: "agent_1", environmentID: "env_1")

        let span = try spans.one("anthropic.sessions.create")
        #expect(span.statusCode == .ok)
        #expect(span["anthropic.session.id"] == nil)
    }

    @Test func failedCreateHasNoID() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/sessions", .json(["type": "error", "error": ["type": "invalid_request_error", "message": "no", "id": "err_1"], "id": "x"],
                                                  status: 400))

        await #expect(throws: APIStatusError.self) {
            _ = try await tracingClient(spans, router).beta.sessions.create(agent: "agent_1", environmentID: "env_1")
        }

        let span = try spans.one("anthropic.sessions.create")
        #expect(span.statusCode == .error)
        // The Agent and the environment are in the request, so a failed call has them too.
        #expect(tracingResourceIDs(span) == ["gen_ai.agent.id": "agent_1", "anthropic.session.environment.id": "env_1"])
        #expect(span["gen_ai.agent.name"] == nil)
        #expect(span["gen_ai.request.model"] == nil)
    }

    @Test(arguments: [JSONValue.string("agent_1"), ["type": "agent", "id": "agent_1", "version": 2],
                      ["type": "agent_with_overrides", "id": "agent_1", "model": ["id": "claude-override"]]], [false, true])
    func sessionCreateHasItsAgentModelAndEnvironment(agent: JSONValue, raw: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/sessions", .json(tracingSession))
        let client = try tracingClient(spans, router)

        if raw {
            _ = try await client.beta.sessions.withRawResponse.create(agent: "agent", environmentID: "env_1", extraBody: ["agent": agent])
        } else {
            _ = try? await client.beta.sessions.create(agent: "agent", environmentID: "env_1", extraBody: ["agent": agent])
        }

        let created = try spans.one("anthropic.sessions.create")
        #expect(created["gen_ai.agent.id"] == "agent_1")
        #expect(created["anthropic.session.environment.id"] == "env_1")
        if raw {
            // The name and the model are those the Session resolved, not the request's overrides.
            #expect(created["gen_ai.agent.name"] == "Researcher")
            #expect(created["gen_ai.request.model"] == "claude-test")
        }
    }

    @Test func sessionCreateStartsItsSpanWithTheAgentAndEnvironment() async throws {
        let sampler = TracingStartAttributes()
        let router = TracingRouter()
        router.route("POST", "/v1/sessions", .json(tracingSession))
        let client = try tracingClient(nil, router, openTelemetry: OpenTelemetryOptions(tracerProvider: SDKTracerProvider(sampler: sampler)))

        _ = try await client.beta.sessions.withRawResponse.create(agent: "agent", environmentID: "env_1", extraBody: ["agent": ["type": "agent", "id": "agent_1"]])

        #expect(sampler.started.map(\.0) == ["anthropic.sessions.create"])
        #expect(sampler.started.first?.1 == [
            "server.address": "127.0.0.1", "server.port": 4010, "http.request.method": "POST", "http.route": "/v1/sessions",
            "gen_ai.provider.name": "anthropic", "gen_ai.agent.id": "agent_1", "anthropic.session.environment.id": "env_1",
        ])
    }

    @Test func otherSessionsMethodsDoNotHaveTheAgentModelOrEnvironment() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/v1/sessions/sesn_1", .json(tracingSession))
        router.route("POST", "/v1/sessions/sesn_1", .json(tracingSession))
        router.route("GET", "/v1/sessions", .json(["data": [tracingSession]]))
        let client = try tracingClient(spans, router)

        _ = try await client.beta.sessions.withRawResponse.retrieve("sesn_1")
        _ = try await client.beta.sessions.withRawResponse.update("sesn_1", title: "Research")
        _ = try await client.beta.sessions.withRawResponse.list()

        for name in ["anthropic.sessions.retrieve", "anthropic.sessions.update", "anthropic.sessions.list"] {
            let span = try spans.one(name)
            for key in ["gen_ai.agent.id", "gen_ai.agent.name", "gen_ai.request.model", "anthropic.session.environment.id"] { #expect(span[key] == nil) }
        }
    }

    @Test func deleteHasTheIDOfWhatItDeletes() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("DELETE", "/v1/sessions/sesn_1", .json(["id": "sesn_1"]))
        router.route("DELETE", "/v1/sessions/sesn_2", .json([:], status: 404))
        let client = try tracingClient(spans, router)

        _ = try await client.beta.sessions.withRawResponse.delete("sesn_1")
        await #expect(throws: APIStatusError.self) { _ = try await client.beta.sessions.delete("sesn_2") }

        let calls = spans.named("anthropic.sessions.delete")
        try #require(calls.count == 2)
        #expect(tracingResourceIDs(calls[0]) == ["anthropic.session.id": "sesn_1"])
        // The ID is in the path, so a failed call has it too.
        #expect(calls[1].statusCode == .error)
        #expect(tracingResourceIDs(calls[1]) == ["anthropic.session.id": "sesn_2"])
    }

    @Test func methodThatCreatesSeveralObjectsHasOnlyTheIDsInItsPath() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/sessions/sesn_1/events", .json(["data": [["id": "sevt_1", "type": "user.message"], ["id": "sevt_2", "type": "user.message"]]]))

        _ = try await tracingClient(spans, router).beta.sessions.events.withRawResponse.send("sesn_1", events: [
            try JSONValue.object(["type": "user.message", "content": [["type": "text", "text": "Hello"]]]).decode(),
        ])

        #expect(tracingResourceIDs(try spans.one("anthropic.sessions.events.send")) == ["anthropic.session.id": "sesn_1"])
    }

    @Test func listHasOnlyTheIDsInItsPath() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let thread = { (id: String) -> JSONValue in
            ["id": .string(id), "type": "session_thread", "session_id": "sesn_1", "status": "idle", "created_at": "2026-01-01T00:00:00Z",
             "updated_at": "2026-01-01T00:00:00Z", "archived_at": nil, "agent_name": "a", "parent_thread_id": nil, "stats": nil, "usage": nil]
        }
        router.route("GET", "/v1/sessions/sesn_1/threads", .json(["data": [thread("sthr_1")], "next_page": "page_2"]),
                     .json(["data": [thread("sthr_2")], "next_page": nil]))
        router.route("GET", "/v1/sessions", .json(["data": [], "next_page": nil]))
        router.route("GET", "/v1/models", .json(["data": [], "has_more": false, "first_id": nil, "last_id": nil]))
        let client = try tracingClient(spans, router)

        do {
            var ids: [String] = []
            for try await thread in try await client.beta.sessions.threads.list("sesn_1") { ids.append(thread.id) }
            #expect(ids == ["sthr_1", "sthr_2"])
        } catch {
            // A thread without every field that its type has does not decode; the requests were made all the same.
        }
        _ = try await client.beta.sessions.list()
        _ = try await client.models.list()

        // The request for a later page has its own span, with the same IDs.
        let pages = spans.named("anthropic.sessions.threads.list")
        #expect(pages.allSatisfy { tracingResourceIDs($0) == ["anthropic.session.id": "sesn_1"] })
        // No ID in the path, and none for the objects listed.
        #expect(tracingResourceIDs(try spans.one("anthropic.sessions.list")) == [:])
        #expect(tracingResourceIDs(try spans.one("anthropic.models.list")) == [:])
    }

    @Test func eventStreamHasTheIDsInItsPath() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/v1/sessions/sesn_1/threads/sthr_1/stream", .bytes(tracingSSE([OpenTelemetryCallSpanTests.sessionEvent]),
                                                                                headers: ["content-type": "text/event-stream"]))

        let stream = try await tracingClient(spans, router).beta.sessions.threads.events.stream("sthr_1", sessionID: "sesn_1")
        #expect(await tracingDrain(stream).types == ["session.status_running"])
        stream.close()

        #expect(tracingResourceIDs(try spans.one("anthropic.sessions.threads.events.stream")) == Self.threadIDs)
    }

    @Test func agentIDIsTheConventionsAttribute() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/agents", .json(["id": "agent_1"]))
        router.route("GET", "/v1/agents/agent_1", .json(["id": "agent_1"]))
        router.route("GET", "/v1/agents/agent_1/versions", .json(["data": [], "next_page": nil]))
        let client = try tracingClient(spans, router)

        _ = try await client.beta.agents.withRawResponse.create(model: try JSONValue.string("claude-test").decode(), name: "Helper")
        _ = try await client.beta.agents.withRawResponse.retrieve("agent_1")
        _ = try await client.beta.agents.versions.withRawResponse.list("agent_1")

        // An Agent's ID has a `gen_ai.*` attribute, which replaces `anthropic.agent.id`.
        for name in ["anthropic.agents.create", "anthropic.agents.retrieve", "anthropic.agents.versions.list"] {
            #expect(tracingResourceIDs(try spans.one(name)) == ["gen_ai.agent.id": "agent_1"])
        }
    }

    @Test(arguments: 0..<TracingResourceCall.all.count)
    func eachResource(index: Int) async throws {
        let call = TracingResourceCall.all[index]
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route(call.method, call.path, .json(call.body))

        try await call.invoke(try tracingClient(spans, router))

        let span = try spans.one(call.name)
        #expect(tracingResourceIDs(span) == call.ids)
        tracingExpectRoute(span, call.method, call.path)
    }

    @Test(arguments: 0..<TracingResourceCall.all.count)
    func eachResourceFailed(index: Int) async throws {
        let call = TracingResourceCall.all[index]
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route(call.method, call.path, .json(call.body, status: 404))

        await #expect(throws: APIStatusError.self) { try await call.invoke(try tracingClient(spans, router)) }

        // A failed call has the IDs in its path, which the method sent, and not the ID of an object it would have created.
        let inPath = call.ids.filter { call.path.contains("/\($0.value.stringValue ?? "")") }
        let span = try spans.one(call.name)
        #expect(tracingResourceIDs(span) == inPath)
        tracingExpectRoute(span, call.method, call.path)
    }

    static func member(_ id: String) -> JSONValue {
        ["type": "workspace_member", "user_id": .string(id), "workspace_id": "wrkspc_1", "workspace_role": "workspace_user"]
    }
    static func skillVersion(_ id: String) -> JSONValue {
        ["id": .string(id), "type": "skill_version", "created_at": "2026-01-01T00:00:00Z", "description": "d", "name": "n", "skill_id": "skill_1",
         "version": "1"]
    }

    /// `RESOURCE_LISTS`: a list method of each kind of page, its two pages, its span's name and IDs, and the `url.query` of
    /// the request for the second page, which is none where the cursor is content.
    static let resourceLists: [(String, [JSONValue], String, SpanAttributes, String?, @Sendable (Anthropic) async throws -> Int)] = [
        ("/v1/organizations/workspaces/wrkspc_1/members",
         [["data": [member("user_1")], "has_more": true, "first_id": "user_1", "last_id": "user_1"],
          ["data": [member("user_2")], "has_more": false, "first_id": "user_2", "last_id": "user_2"]],
         "anthropic.organization.workspaces.members.list", ["anthropic.organization.workspace.id": "wrkspc_1"], "after_id=user_1",
         { var n = 0; for try await _ in try await $0.beta.organization.workspaces.members.list("wrkspc_1") { n += 1 }; return n }),
        ("/v1/skills/skill_1/versions",
         [["data": [skillVersion("skillver_1")], "next_page": "page_2"], ["data": [skillVersion("skillver_2")], "next_page": nil]],
         "anthropic.skills.versions.list", ["anthropic.skill.id": "skill_1"], "page=page_2",
         { var n = 0; for try await _ in try await $0.beta.skills.versions.list("skill_1") { n += 1 }; return n }),
        ("/v1/memory_stores/memstore_1/memories",
         [["data": [["id": "mem_1"]], "next_page": "page_2"], ["data": [["id": "mem_2"]], "next_page": nil]],
         "anthropic.memory_stores.memories.list", ["gen_ai.memory.store.id": "memstore_1"], nil,
         { var n = 0; for try await _ in try await $0.beta.memoryStores.memories.list("memstore_1") { n += 1 }; return n }),
    ]

    @Test(arguments: 0..<3)
    func eachKindOfPage(index: Int) async throws {
        let (path, pages, name, ids, laterQuery, invoke) = Self.resourceLists[index]
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", path, replies: pages.map { .json($0) })

        #expect(try await invoke(try tracingClient(spans, router)) == 2)

        // The request for a later page has the IDs in the path too, and none for the objects listed.
        let calls = spans.named(name)
        try #require(calls.count == 2)
        #expect(calls.map(tracingResourceIDs) == [ids, ids])
        tracingExpectRoute(calls[1], "GET", path)
        // The cursor of a later page is a parameter that the endpoint defines, and the span has it unless it is content.
        #expect(calls[0]["url.query"] == nil)
        #expect(calls[1]["url.query"]?.stringValue == laterQuery)
    }

    @Test(arguments: [JSONValue.object([:]), ["user_id": nil], ["id": "member_1"]])
    func addWithoutTheNamedFieldInItsResponse(body: JSONValue) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/organizations/workspaces/wrkspc_1/members", .json(body))

        _ = try await tracingClient(spans, router).beta.organization.workspaces.members.withRawResponse.add(
            "wrkspc_1", userID: "user_1", workspaceRole: tracingEnum("workspace_user"))

        // The user's ID in the request's body is not in its path, so only the response gives it.
        let span = try spans.one("anthropic.organization.workspaces.members.add")
        #expect(span.statusCode == .ok)
        #expect(tracingResourceIDs(span) == ["anthropic.organization.workspace.id": "wrkspc_1"])
    }
}

/// `MALFORMED_MESSAGES`: Message bodies that do not match the declared types, as a gateway or a compatible endpoint can
/// return them.
let tracingMalformedMessages: [JSONValue] = [
    tracingMessage.without("usage"),
    tracingMessage.with("usage", nil),
    tracingMessage.with("usage", tracingMessage["usage"]!.with("input_tokens", "12")),
    tracingMessage.with("usage", tracingMessage["usage"]!.with("output_tokens_details", [:])),
    tracingMessage.without("id", "model"),
]

@Suite struct OpenTelemetryMalformedResponseTests {
    /// `ended`: the span ended, with what could be read.
    func ended(_ spans: TracingSpans, _ contentMode: OpenTelemetryContentMode, output: Bool = true) throws -> SpanData {
        let span = try spans.one("anthropic.messages.create")
        #expect(span.endTime != nil)
        #expect(span.statusCode != .error)
        #expect(span["gen_ai.request.model"] == "claude-test")
        // What the span cannot read of the response does not cost it the content.
        #expect((span[INPUT_KEY] != nil) == (contentMode == .content))
        #expect((span[OUTPUT_KEY] != nil) == (contentMode == .content && output))
        return span
    }

    /// `test_raw_response`: the body of a raw response is not decoded, so its call succeeds however malformed it is.
    @Test(arguments: 0..<5, [OpenTelemetryContentMode.metadataOnly, .content])
    func rawResponse(index: Int, contentMode: OpenTelemetryContentMode) async throws {
        let message = tracingMalformedMessages[index]
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(message))
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: OpenTelemetryTraces(contentMode: contentMode)))

        let raw = try await client.messages.withRawResponse.create(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test")

        #expect(try await raw.json()["content"]?[0]?["text"] == "Hi there")
        let span = try ended(spans, contentMode)
        // The span keeps what it could read before the field that it could not.
        #expect(span["gen_ai.response.id"] == message["id"].flatMap { AttributeValue(json: $0) })
        #expect(span["anthropic.message.stop_reason"] == "end_turn")
    }

    /// What `set_response` makes of a malformed Message, as `test_create` checks: it stops at the first field that it
    /// cannot read, and keeps what it read before.
    @Test(arguments: 0..<5)
    func setResponseReadsWhatItCan(index: Int) throws {
        let message = tracingMalformedMessages[index]
        let span = try TracingSpans().provider.tracer("test", version: nil).startSpan("anthropic.messages.create") as! RecordingSpan

        setResponse(span, message, complete: true, beta: false)

        #expect(span.attributes["gen_ai.response.id"] == message["id"].flatMap { AttributeValue(json: $0) })
        #expect(span.attributes["anthropic.message.stop_reason"] == "end_turn")
        #expect(index == 3 ? span.attributes["gen_ai.usage.output_tokens"] == 5 : true)
    }

    @Test(arguments: [JSONValue.object([:]), ["input_tokens": nil], ["input_tokens": "12"]])
    func countTokensRaw(body: JSONValue) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages/count_tokens", .json(body))

        _ = try await tracingClient(spans, router).messages.withRawResponse.countTokens(messages: tracingMessages(tracingHello), model: "claude-test")

        let span = try spans.one("anthropic.messages.count_tokens")
        #expect(span.endTime != nil)
        #expect(span.statusCode != .error)
    }

    @Test(arguments: [JSONValue.object([:]), ["id": nil], ["id": 7]])
    func batchCreateRaw(body: JSONValue) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages/batches", .json(body))

        _ = try await tracingClient(spans, router).messages.batches.withRawResponse.create(requests: [])

        let span = try spans.one("anthropic.messages.batches.create")
        #expect(span.endTime != nil)
        #expect(span.statusCode != .error)
    }
}

/// A span processor that throws when a span starts, or else when one ends (`FailingProcessor`).
struct TracingFailingProcessor: SpanProcessor {
    let failure: String
    func onStart(_ span: RecordingSpan, parent: TracingContext) throws {
        if failure == "on_start" { throw TracingTestError("cannot start a span") }
    }
    func onEnd(_ span: SpanData) throws {
        if failure == "on_end" { throw TracingTestError("cannot end a span") }
    }
}

struct TracingFailingSampler: Sampler {
    func shouldSample(parent: SpanContext?, traceID: TraceID, name: String, kind: SpanKind, attributes: SpanAttributes) throws -> SamplingResult {
        throw TracingTestError("cannot sample a span")
    }
}

struct TracingFailingPropagator: TextMapPropagator {
    var fields: Set<String> { [] }
    func inject(_ context: TracingContext, into carrier: inout [String: String]) throws { throw TracingTestError("cannot inject a trace context") }
}

/// `failing_tracing`: an option whose tracer provider fails every span at `failure`.
func tracingFailingOption(_ failure: String) -> OpenTelemetryOptions {
    if failure == "sampler" { return OpenTelemetryOptions(tracerProvider: SDKTracerProvider(sampler: TracingFailingSampler())) }
    return OpenTelemetryOptions(tracerProvider: SDKTracerProvider(processors: [TracingFailingProcessor(failure: failure)]))
}

/// Tracing that fails leaves an API call as it is without tracing: its result, its error and its requests.
@Suite struct OpenTelemetryTracingFailureTests {
    @Test(arguments: ["sampler", "on_start", "on_end"])
    func theCallReturnsItsResultFromOneRequest(failure: String) async throws {
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages", .json(tracingMessage))

        let message = try await tracingCreate(try tracingClient(nil, router, openTelemetry: tracingFailingOption(failure), maxRetries: 2))

        #expect(message.id == "msg_1")
        #expect(route.requests.count == 1)
    }

    @Test(arguments: ["sampler", "on_start", "on_end"])
    func theCallRaisesTheErrorOfTheAPIAfterItsRetries(failure: String) async throws {
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages", .json(["type": "error", "error": ["type": "api_error", "message": "Internal server error"]], status: 500))

        await #expect(throws: InternalServerError.self) {
            try await tracingCreate(try tracingClient(nil, router, openTelemetry: tracingFailingOption(failure), maxRetries: 2))
        }

        #expect(route.requests.count == 3)
    }

    @Test(arguments: ["sampler", "on_start", "on_end"])
    func aStreamGivesEveryEvent(failure: String) async throws {
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()))
        let client = try tracingClient(nil, router, openTelemetry: tracingFailingOption(failure))

        #expect(await tracingDrain(try await tracingCreateStream(client)).types == tracingStreamEvents().map { $0["type"]!.stringValue! })
        #expect(try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test").getFinalText() == "Hi there")

        // An application that stops reading closes the stream, which ends the span too.
        let stream = try await tracingCreateStream(client)
        var iterator = stream.makeAsyncIterator()
        guard case .messageStart? = try await iterator.next() else { Issue.record("expected message_start"); return }
        stream.close()
    }

    @Test func aFailingPropagatorSendsTheRequestWithoutATraceContext() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages", .json(tracingMessage))

        let message = try await OpenTelemetry.withPropagator(TracingFailingPropagator()) { try await tracingCreate(try tracingClient(spans, router)) }

        #expect(message.id == "msg_1")
        #expect(route.requests.first?.headers["traceparent"] == nil)
        #expect(try spans.one("anthropic.messages.create").statusCode == .ok)
    }

    @Test(arguments: [false, true])
    func batchCreateWithoutRequestsReachesTheAPI(beta: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages/batches", .json(["type": "error", "error": ["type": "invalid_request_error",
                                                                                                  "message": "requests: Field required"]], status: 400))
        let client = try tracingClient(spans, router)

        await #expect(throws: BadRequestError.self) {
            if beta { _ = try await client.beta.messages.batches.create(requests: [], extraBody: ["requests": nil]) } else {
                _ = try await client.messages.batches.create(requests: [], extraBody: ["requests": nil])
            }
        }

        #expect(route.requests.first?.jsonBody == ["requests": nil])
        let span = try spans.one("anthropic.messages.batches.create")
        #expect(span["anthropic.message.batch.request_count"] == nil)
        #expect(span["error.type"] == "invalid_request_error")
    }

    @Test func registeredTracerProviderThatCannotGiveATracerLeavesTheClientWithoutSpans() async throws {
        struct Unloadable: TracerProvider {
            func tracer(_ scope: String, version: String?) throws -> any Tracer { throw TracingTestError("not installed") }
        }
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("*", "*", .json(tracingMessage))

        try await OpenTelemetry.withTracerProvider(Unloadable()) {
            let client = try tracingClient(nil, router, openTelemetry: .some(nil))
            let enabled = try client.withOptions(openTelemetry: OpenTelemetryOptions(traces: true))
            for called in [client, try client.withOptions(maxRetries: 0), try client.copy(), enabled, try enabled.copy()] {
                #expect(called.openTelemetry.traces?.enabled == true)
                #expect(try await tracingCreate(called).id == "msg_1")
            }
            for (platform, client) in try TracingPlatform.clients(nil, router: router) {
                for called in [client, try platform.copy(client, nil)] { #expect(try await tracingCreate(called).id == "msg_1") }
            }

            // A provider that the client is given is used whatever the registered one does.
            try await tracingCreate(try client.withOptions(openTelemetry: spans.option()))
        }

        #expect(route.requests.count == 5 + 2 * TracingPlatform.all.count + 1)
        #expect(route.requests.dropLast().allSatisfy { $0.headers["traceparent"] == nil })
        #expect(spans.named("anthropic.messages.create").count == 1)
    }

    @Test func tracerProviderThatGivesNoTracerLeavesTheClientWithoutSpans() async throws {
        struct NoTracers: TracerProvider {
            func tracer(_ scope: String, version: String?) throws -> any Tracer { throw TracingTestError("no tracer") }
        }
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages", .json(tracingMessage))
        let option = OpenTelemetryOptions(tracerProvider: NoTracers())
        let client = try tracingClient(nil, router, openTelemetry: option)

        for called in [client, try client.withOptions(maxRetries: 0), try client.copy(openTelemetry: option)] {
            #expect(try await tracingCreate(called).id == "msg_1")
        }

        #expect(route.requests.allSatisfy { $0.headers["traceparent"] == nil })
    }

    @Test(arguments: ["option", "variable"])
    func disabledSpansCallNothingOfTheTracingAPI(how: String) async throws {
        /// A provider that fails the test if a client asks it for anything.
        struct Refusing: TracerProvider {
            func tracer(_ scope: String, version: String?) throws -> any Tracer {
                Issue.record("the tracer provider was asked for a tracer")
                return NoOpTracer()
            }
        }
        struct RefusingPropagator: TextMapPropagator {
            var fields: Set<String> { [] }
            func inject(_ context: TracingContext, into carrier: inout [String: String]) throws { Issue.record("the propagator was asked to inject") }
        }
        let router = TracingRouter()
        let route = router.route("*", "*", .json(tracingMessage))
        let option: OpenTelemetryOptions? = how == "option" ? .disabled : nil
        let env = ["ANTHROPIC_OPEN_TELEMETRY": how == "option" ? "true" : "false"]

        try await OpenTelemetry.withTracerProvider(Refusing()) {
            try await OpenTelemetry.withPropagator(RefusingPropagator()) {
                var clients: [(TracingPlatform?, any TracingMessagesClient)] = [(nil, try tracingClient(nil, router, openTelemetry: .some(option), environment: env))]
                clients += try TracingPlatform.clients(option, environment: env, router: router).map { ($0.0, $0.1) }
                for (platform, client) in clients {
                    var copies: [any TracingMessagesClient] = [client]
                    if let platform {
                        copies.append(try platform.copy(client, nil))
                    } else {
                        copies += [try (client as! Anthropic).withOptions(maxRetries: 0), try (client as! Anthropic).copy()]
                    }
                    for called in copies {
                        #expect(called.openTelemetry.traces?.enabled == false)
                        #expect(try await tracingCreate(called).id == "msg_1")
                    }
                }
            }
        }

        #expect(route.requests.count == 3 + 2 * TracingPlatform.all.count)
    }
}

/// The tripwires of tests/test_open_telemetry.py that compare a list the tracing code was written from with a
/// generated type: here, the stored properties of a decoded value.
@Suite struct OpenTelemetryTripwireTests {
    func fields<T: Decodable>(_ type: T.Type, _ json: JSONValue) throws -> Set<String> {
        Set(Mirror(reflecting: try json.decode(as: T.self)).children.compactMap(\.label))
    }

    static let usageRecorded: Set<String> = ["cacheCreation", "cacheCreationInputTokens", "cacheReadInputTokens", "inputTokens", "outputTokens",
                                             "outputTokensDetails", "serviceTier"]
    static let usageWithoutAnAttribute: Set<String> = ["inferenceGeo", "serverToolUse", "speed"]

    @Test func usageFieldsAreAllRecordedOrLeftOut() throws {
        let usage: JSONValue = ["input_tokens": 0, "output_tokens": 0]
        let message = "If the spans have an attribute for the new field, record it in `setResponse` (Sources/Anthropic/Lib/Tracing/ApiCallSpan.swift). Then list it in this test."
        #expect(try fields(Usage.self, usage) == Self.usageRecorded.union(Self.usageWithoutAnAttribute), "`Usage` has changed. \(message)")
        #expect(try fields(BetaUsage.self, usage) == Self.usageRecorded.union(["iterations"]).union(Self.usageWithoutAnAttribute).union(["fallbackCredit"]),
                "`BetaUsage` has changed. \(message)")
        let cache: JSONValue = ["ephemeral_1h_input_tokens": 0, "ephemeral_5m_input_tokens": 0]
        #expect(try fields(CacheCreation.self, cache) == ["ephemeral1hInputTokens", "ephemeral5mInputTokens"], "`CacheCreation` has changed. \(message)")
        #expect(try fields(BetaCacheCreation.self, cache) == ["ephemeral1hInputTokens", "ephemeral5mInputTokens"], "`BetaCacheCreation` has changed. \(message)")
        #expect(try fields(OutputTokensDetails.self, ["thinking_tokens": 0]) == ["thinkingTokens"], "`OutputTokensDetails` has changed. \(message)")
        #expect(try fields(BetaOutputTokensDetails.self, ["thinking_tokens": 0]) == ["thinkingTokens"], "`BetaOutputTokensDetails` has changed. \(message)")
    }
}
