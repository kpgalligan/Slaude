import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/test_google_cloud.py (async variants). `_load_adc_credentials` monkeypatches
// become the `credentialsLoader:` argument; every client gets an isolated environment (the
// `_isolate_environment` fixture).

private let derivedBaseURL = "https://claude.googleapis.com/v1/projects/my-project/locations/us-central1/workspaces/wrkspc_x/invoke/"
private let globalDerivedBaseURL = "https://claude.googleapis.com/v1/projects/my-project/locations/global/workspaces/wrkspc_x/invoke/"
private let organizationBaseURL = "https://claude.googleapis.com/v1/projects/my-project/locations/us-central1/claudeOrganization/invoke"
private let adcDerivedBaseURL = "https://claude.googleapis.com/v1/projects/adc-project/locations/us-central1/workspaces/wrkspc_x/invoke/"
private let workspaceList = #"{"data": [], "has_more": false, "first_id": null, "last_id": null}"#

/// A loader that fails the test if ADC discovery runs.
private let noADC: GoogleCredentialsLoader = {
    Issue.record("ADC discovery must not run when an explicit credential source is set")
    throw AnthropicError("ADC must not run")
}

/// Counts ADC loads.
final class LoadCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var n = 0
    var count: Int { lock.withLock { n } }
    func loader(token: String = "adc-token", project: String? = "adc-project", delay: UInt64 = 0) -> GoogleCredentialsLoader {
        { [self] in
            lock.withLock { n += 1 }
            if delay > 0 { try await Task.sleep(nanoseconds: delay) }
            return (FakeGoogleCredentials(token: token), project)
        }
    }
}

private func gc(_ recorder: RequestRecorder? = nil, project: String? = nil, location: String? = nil, workspaceID: String? = nil,
                tokenProvider: GoogleTokenProvider? = nil, credentials: GoogleCredentials? = nil, skipAuth: Bool = false,
                baseURL: String? = nil, headers: Headers? = nil, loader: GoogleCredentialsLoader? = nil,
                env: [String: String] = [:]) throws -> AnthropicGoogleCloud
{
    try AnthropicGoogleCloud(project: project, location: location, workspaceID: workspaceID, tokenProvider: tokenProvider,
                             credentials: credentials, skipAuth: skipAuth, baseURL: baseURL, defaultHeaders: headers,
                             transport: (recorder ?? RequestRecorder()).transport, credentialsLoader: loader ?? noADC,
                             environment: isolatedEnv(env))
}

private func tok(_ value: String) -> GoogleTokenProvider { { value } }

private func send(_ client: Anthropic, extraHeaders: Headers? = nil, userProfileID: String? = nil, workspaceID: String? = nil) async throws {
    _ = try await client.messages.create(maxTokens: 16, messages: userMessages("hi"), model: "claude-haiku-4-5", userProfileID: userProfileID,
                                         workspaceID: workspaceID, extraHeaders: extraHeaders)
}

@Suite struct GoogleCloudInitTests {
    @Test func initWithTokenProviderAndBaseURL() throws {
        let client = try gc(workspaceID: "wrkspc_x", tokenProvider: tok("tok"), baseURL: "https://example.test/")
        #expect(client.baseURL.absoluteString == "https://example.test/")
        #expect(client.workspaceID == "wrkspc_x")
    }

    @Test func explicitBaseURLNeedsNoLocation() throws {
        #expect(try gc(workspaceID: "wrkspc_x", baseURL: "https://example.test/").baseURL.absoluteString == "https://example.test/")
    }

    @Test func baseURLDerivedFromProjectAndLocation() throws {
        let client = try gc(project: "my-project", location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"))
        #expect(client.baseURL.absoluteString == derivedBaseURL)
    }

    @Test func locationDefaultsToGlobal() throws {
        #expect(try gc(project: "my-project", workspaceID: "wrkspc_x", tokenProvider: tok("tok")).baseURL.absoluteString == globalDerivedBaseURL)
    }

    @Test func missingProjectDefersWithoutConstructError() throws {
        _ = try gc(location: "us-central1", workspaceID: "wrkspc_x")
    }

    @Test func skipAuthDerivingBaseURLRequiresProject() async {
        await expectThrows(ValueError.self, matching: "project") { _ = try gc(location: "us-central1", workspaceID: "wrkspc_x", skipAuth: true) }
    }

    @Test func derivedURLWithoutWorkspaceConstructs() throws {
        _ = try gc(project: "my-project", tokenProvider: tok("tok"))
        _ = try gc(project: "my-project", skipAuth: true)
    }

    @Test func skipAuthDerivesURLWithWorkspace() throws {
        #expect(try gc(project: "my-project", workspaceID: "wrkspc_x", skipAuth: true).baseURL.absoluteString == globalDerivedBaseURL)
    }

    @Test func envResolution() throws {
        let client = try gc(tokenProvider: tok("tok"), env: ["ANTHROPIC_GOOGLE_CLOUD_BASE_URL": "https://env.test/",
                                                             "ANTHROPIC_GOOGLE_CLOUD_WORKSPACE_ID": "wrkspc_env"])
        #expect(client.baseURL.absoluteString == "https://env.test/")
        #expect(client.workspaceID == "wrkspc_env")
    }

    @Test func explicitProjectArgBeatsEnv() throws {
        let client = try gc(project: "arg-project", location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"),
                            env: ["ANTHROPIC_GOOGLE_CLOUD_PROJECT": "env-project"])
        #expect(client.baseURL.absoluteString.contains("/projects/arg-project/"))
        #expect(!client.baseURL.absoluteString.contains("env-project"))
    }

    @Test func locationFromEnv() throws {
        let client = try gc(project: "my-project", workspaceID: "wrkspc_x", tokenProvider: tok("tok"),
                            env: ["ANTHROPIC_GOOGLE_CLOUD_LOCATION": "europe-west4"])
        #expect(client.baseURL.absoluteString.hasPrefix("https://claude.googleapis.com/"))
        #expect(client.baseURL.absoluteString.contains("/locations/europe-west4/"))
    }

    @Test func explicitLocationArgBeatsEnv() throws {
        let client = try gc(project: "my-project", location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"),
                            env: ["ANTHROPIC_GOOGLE_CLOUD_LOCATION": "env-location"])
        #expect(client.baseURL.absoluteString == derivedBaseURL)
    }

    @Test func projectFallsBackToGoogleCloudProjectEnv() throws {
        let client = try gc(location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"), env: ["GOOGLE_CLOUD_PROJECT": "gcp-env-project"])
        #expect(client.baseURL.absoluteString.contains("/projects/gcp-env-project/"))
    }

    @Test func anthropicProjectEnvBeatsGoogleCloudProject() throws {
        let client = try gc(location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"),
                            env: ["ANTHROPIC_GOOGLE_CLOUD_PROJECT": "anthropic-env-project", "GOOGLE_CLOUD_PROJECT": "gcp-env-project"])
        #expect(client.baseURL.absoluteString.contains("/projects/anthropic-env-project/"))
        #expect(!client.baseURL.absoluteString.contains("gcp-env-project"))
    }

    @Test func explicitBaseURLNeedsNoWorkspace() throws {
        #expect(try gc(tokenProvider: tok("tok"), baseURL: "https://example.test/").workspaceID == nil)
    }

    @Test func skipAuthMutuallyExclusiveWithCredentials() async {
        await expectThrows(ValueError.self, matching: "mutually exclusive") {
            _ = try gc(tokenProvider: tok("tok"), skipAuth: true, baseURL: "https://example.test/")
        }
        await expectThrows(ValueError.self, matching: "mutually exclusive") {
            _ = try gc(credentials: FakeGoogleCredentials(token: "tok"), skipAuth: true, baseURL: "https://example.test/")
        }
    }

    @Test func projectBackfilledFromExplicitCredentials() throws {
        let client = try gc(location: "us-central1", workspaceID: "wrkspc_x", credentials: FakeGoogleCredentials(token: "tok", projectID: "creds-project"))
        #expect(client.baseURL.absoluteString.contains("/projects/creds-project/"))
    }

    @Test func googleCredentialsExposed() throws {
        let creds = FakeGoogleCredentials(token: "tok")
        let client = try gc(workspaceID: "wrkspc_x", credentials: creds, baseURL: "https://example.test/")
        #expect(client.googleCredentials === creds)
    }

    @Test func fullSurfacePresent() throws {
        let client = try gc(workspaceID: "wrkspc_x", tokenProvider: tok("tok"), baseURL: "https://example.test/")
        _ = client.messages
        _ = client.models
        _ = client.beta
        _ = client.messages.batches
    }
}

@Suite struct GoogleCloudAuthTests {
    @Test func tokenProviderAttachesBearer() async throws {
        let recorder = RequestRecorder()
        try await send(try gc(recorder, workspaceID: "wrkspc_x", tokenProvider: tok("provided-token"), baseURL: "https://example.test/"))
        #expect(recorder.count == 1)
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer provided-token")
        // The workspace id travels in the URL path only — never as a header.
        #expect(recorder.requests[0].headers["anthropic-workspace-id"] == nil)
    }

    @Test func asyncTokenProviderAttachesBearer() async throws {
        let recorder = RequestRecorder()
        let provider: GoogleTokenProvider = {
            try await Task.sleep(nanoseconds: 1_000)
            return "async-token"
        }
        try await send(try gc(recorder, workspaceID: "wrkspc_x", tokenProvider: provider, baseURL: "https://example.test/"))
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer async-token")
    }

    @Test func credentialsObjectAttachesBearer() async throws {
        let recorder = RequestRecorder()
        let creds = FakeGoogleCredentials(token: "cred-token")
        try await send(try gc(recorder, workspaceID: "wrkspc_x", credentials: creds, baseURL: "https://example.test/"))
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer cred-token")
        #expect(creds.refreshCalls == 0)  // fresh creds aren't refreshed
    }

    @Test func expiredCredentialsRefreshed() async throws {
        let recorder = RequestRecorder()
        let creds = FakeGoogleCredentials(token: "stale", expired: true)
        try await send(try gc(recorder, workspaceID: "wrkspc_x", credentials: creds, baseURL: "https://example.test/"))
        #expect(creds.refreshCalls == 1)
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer refreshed-token")
    }

    @Test func adcPath() async throws {
        let recorder = RequestRecorder()
        let counter = LoadCounter()
        try await send(try gc(recorder, workspaceID: "wrkspc_x", baseURL: "https://example.test/", loader: counter.loader(project: nil)))
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer adc-token")
    }

    @Test(arguments: ["token_provider", "credentials"])
    func explicitCredentialSuppressesADC(kind: String) async throws {
        let recorder = RequestRecorder()
        let client = kind == "token_provider"
            ? try gc(recorder, workspaceID: "wrkspc_x", tokenProvider: tok("tok"), baseURL: "https://example.test/")
            : try gc(recorder, workspaceID: "wrkspc_x", credentials: FakeGoogleCredentials(token: "tok"), baseURL: "https://example.test/")
        try await send(client)
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer tok")
    }

    @Test func concurrentFirstTokenResolutionLoadsADCOnce() async throws {
        let counter = LoadCounter()
        let client = try gc(workspaceID: "wrkspc_x", baseURL: "https://example.test/", loader: counter.loader(project: nil, delay: 50_000_000))
        let tokens = try await withThrowingTaskGroup(of: String.self) { group in
            for _ in 0..<4 { group.addTask { try await client.getToken() } }
            return try await group.reduce(into: []) { $0.append($1) }
        }
        #expect(tokens == Array(repeating: "adc-token", count: 4))
        #expect(counter.count == 1)  // the lazy load is serialized, not raced
    }

    @Test func lowercaseAuthorizationHeaderRespected() async throws {
        let recorder = RequestRecorder()
        try await send(try gc(recorder, workspaceID: "wrkspc_x", tokenProvider: tok("gcp-token"), baseURL: "https://example.test/"),
                       extraHeaders: ["authorization": "Bearer caller-token"])
        #expect(recorder.requests[0].headers.values("authorization") == ["Bearer caller-token"])
    }

    @Test func clientIdentityHeadersAreKept() async throws {
        let recorder = RequestRecorder()
        let client = try gc(recorder, workspaceID: "wrkspc_x", tokenProvider: tok("gcp-token"), baseURL: "https://example.test/",
                            headers: ["anthropic-user-profile-id": "uprof_client", "anthropic-workspace-id": "wrkspc_client"])
        try await send(client)
        try await send(client, userProfileID: "uprof_request", workspaceID: "wrkspc_request")
        #expect(recorder.requests[0].headers["anthropic-user-profile-id"] == "uprof_client")
        #expect(recorder.requests[0].headers["anthropic-workspace-id"] == "wrkspc_client")
        #expect(recorder.requests[1].headers["anthropic-user-profile-id"] == "uprof_request")
        #expect(recorder.requests[1].headers["anthropic-workspace-id"] == "wrkspc_request")
    }

    @Test func customHeadersEnvFlowsThrough() async throws {
        let recorder = RequestRecorder()
        try await send(try gc(recorder, workspaceID: "wrkspc_x", tokenProvider: tok("gcp-token"), baseURL: "https://example.test/",
                              env: ["ANTHROPIC_CUSTOM_HEADERS": "x-custom-header: hello"]))
        #expect(recorder.requests[0].headers["x-custom-header"] == "hello")
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer gcp-token")
    }

    @Test func customHeadersEnvAuthorizationNeverConflicts() async throws {
        let recorder = RequestRecorder()
        try await send(try gc(recorder, workspaceID: "wrkspc_x", tokenProvider: tok("gcp-token"), baseURL: "https://example.test/",
                              env: ["ANTHROPIC_CUSTOM_HEADERS": "Authorization: Bearer env-token"]))
        #expect(recorder.requests[0].headers.values("authorization") == ["Bearer env-token"])
    }
}

@Suite struct GoogleCloudBackfillTests {
    @Test func projectBackfilledFromADCOnFirstRequest() async throws {
        let recorder = RequestRecorder()
        let counter = LoadCounter()
        let client = try gc(recorder, location: "us-central1", workspaceID: "wrkspc_x", loader: counter.loader())
        try await send(client)
        try await send(client)
        #expect(recorder.count == 2)
        for request in recorder.requests {
            #expect(request.url.absoluteString.hasPrefix(String(adcDerivedBaseURL.dropLast())))
            #expect(request.headers["Authorization"] == "Bearer adc-token")
            #expect(request.headers["anthropic-workspace-id"] == nil)
        }
        #expect(client.baseURL.absoluteString == adcDerivedBaseURL)
        #expect(counter.count == 1)
    }

    @Test func backfillHappensEvenWithCallerAuthorization() async throws {
        let recorder = RequestRecorder()
        let client = try gc(recorder, location: "us-central1", workspaceID: "wrkspc_x", loader: LoadCounter().loader())
        try await send(client, extraHeaders: ["Authorization": "Bearer caller-token"])
        #expect(recorder.urls[0].hasPrefix(String(adcDerivedBaseURL.dropLast())))
        #expect(recorder.requests[0].headers.values("authorization") == ["Bearer caller-token"])
    }

    @Test func adcWithoutProjectRaisesOnFirstRequest() async throws {
        let client = try gc(location: "us-central1", workspaceID: "wrkspc_x", loader: LoadCounter().loader(project: nil))
        await expectThrows(AnthropicError.self, matching: "ANTHROPIC_GOOGLE_CLOUD_PROJECT") { try await send(client) }
    }

    @Test func tokenProviderWithoutProjectRaisesOnFirstRequest() async throws {
        let client = try gc(location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"))
        await expectThrows(AnthropicError.self, matching: "project") { try await send(client) }
    }

    @Test func postConstructionBaseURLAssignmentWins() async throws {
        let recorder = RequestRecorder()
        let client = try gc(recorder, location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"))
        client.baseURL = URL(string: "https://my-gateway.test/")!
        try await send(client)
        #expect(recorder.requests[0].url.host == "my-gateway.test")
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer tok")
    }

    @Test func copyOfDeferredClientStillBackfillsAndSharesADC() async throws {
        let recorder = RequestRecorder()
        let counter = LoadCounter()
        let client = try gc(recorder, location: "us-central1", workspaceID: "wrkspc_x", loader: counter.loader())
        let clone = try client.withOptions(timeout: 10)
        try await send(clone)
        try await send(client)
        #expect(recorder.count == 2)
        for url in recorder.urls { #expect(url.hasPrefix(String(adcDerivedBaseURL.dropLast()))) }
        #expect(counter.count == 1)  // clones share the lazily-loaded ADC credentials
    }
}

@Suite struct GoogleCloudCopyTests {
    @Test func copyProjectRederivesBaseURL() throws {
        let client = try gc(project: "my-project", location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"))
        #expect(try client.copy(project: "other-project").baseURL.absoluteString.contains("/projects/other-project/"))
    }

    @Test func copyLocationRederivesBaseURL() throws {
        let client = try gc(project: "my-project", location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"))
        let clone = try client.copy(location: "europe-west4")
        #expect(clone.baseURL.absoluteString.hasPrefix("https://claude.googleapis.com/"))
        #expect(clone.baseURL.absoluteString.contains("/locations/europe-west4/"))
    }

    @Test func copyKeepsUserSuppliedBaseURL() throws {
        let client = try gc(workspaceID: "wrkspc_x", tokenProvider: tok("tok"), baseURL: "https://example.test/")
        #expect(try client.copy(project: "other-project").baseURL.absoluteString == "https://example.test/")
    }

    @Test func copyPlainRoundtripKeepsDerivedBaseURL() throws {
        let client = try gc(project: "my-project", location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"))
        let clone: AnthropicGoogleCloud = try client.copy()
        #expect(clone.baseURL.absoluteString == derivedBaseURL)
        // Through the base class's `copy`, the copy is still the platform client.
        let base = try (client as Anthropic).copy()
        #expect(base is AnthropicGoogleCloud)
    }

    @Test func copyLowerTierCredentialTakesEffect() async throws {
        let recorder = RequestRecorder()
        let provider: GoogleTokenProvider = {
            Issue.record("inherited token_provider must not be used after copy(credentials=...)")
            return "bad"
        }
        let client = try gc(recorder, workspaceID: "wrkspc_x", tokenProvider: provider, baseURL: "https://example.test/")
        try await send(try client.copy(credentials: FakeGoogleCredentials(token: "cred-token")))
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer cred-token")
    }

    @Test func copyTokenProviderReplacesCredentials() async throws {
        let recorder = RequestRecorder()
        let client = try gc(recorder, workspaceID: "wrkspc_x", credentials: FakeGoogleCredentials(token: "stale"), baseURL: "https://example.test/")
        try await send(try client.copy(tokenProvider: tok("fresh-token")))
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer fresh-token")
    }

    @Test func copySkipAuthClearsWorkspaceAndCredentials() async throws {
        let recorder = RequestRecorder()
        let client = try gc(recorder, workspaceID: "wrkspc_x", tokenProvider: tok("tok"), baseURL: "https://example.test/")
        let proxy = try client.copy(baseURL: "https://proxy.test/", workspaceID: .some(nil), skipAuth: true)
        try await send(proxy)
        #expect(recorder.requests[0].url.host == "proxy.test")
        #expect(recorder.requests[0].headers["Authorization"] == nil)
        #expect(recorder.requests[0].headers["anthropic-workspace-id"] == nil)
    }

    @Test func copyClearsWorkspaceWithoutSkipAuth() throws {
        let client = try gc(workspaceID: "wrkspc_x", tokenProvider: tok("tok"), baseURL: "https://example.test/")
        #expect(try client.copy(workspaceID: .some(nil)).workspaceID == nil)
    }

    @Test func copyRejectsFirstPartyKwargs() async throws {
        let client = try gc(workspaceID: "wrkspc_x", tokenProvider: tok("tok"), baseURL: "https://example.test/")
        await expectThrows(ArgumentTypeError.self, matching: "auth_token") { _ = try client.copy(authToken: "environment-key") }
        await expectThrows(ArgumentTypeError.self, matching: "api_key") { _ = try client.copy(apiKey: "sk-ant-x") }
    }

    @Test func skipAuthSendsNeitherHeader() async throws {
        let recorder = RequestRecorder()
        let client = try gc(recorder, skipAuth: true, baseURL: "https://example.test/")
        #expect(client.workspaceID == nil)
        try await send(client)
        #expect(recorder.requests[0].headers["Authorization"] == nil)
        #expect(recorder.requests[0].headers["anthropic-workspace-id"] == nil)
    }
}

@Suite struct GoogleCloudIsolationTests {
    @Test func noAPIKeyLeak() async throws {
        let recorder = RequestRecorder()
        let client = try gc(recorder, workspaceID: "wrkspc_x", tokenProvider: tok("tok"), baseURL: "https://example.test/",
                            env: ["ANTHROPIC_API_KEY": "sk-leak"])
        #expect(client.apiKey == nil)
        #expect(client.authHeaders.isEmpty)
        try await send(client)
        #expect(!recorder.requests[0].headers.names.map { $0.lowercased() }.contains("x-api-key"))
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer tok")
    }

    @Test func noAuthTokenLeak() async throws {
        let recorder = RequestRecorder()
        let client = try gc(recorder, workspaceID: "wrkspc_x", tokenProvider: tok("gcp-token"), baseURL: "https://example.test/",
                            env: ["ANTHROPIC_AUTH_TOKEN": "first-party-leak"])
        #expect(client.authToken == nil)
        try await send(client)
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer gcp-token")
    }

    @Test func envBaseURLDoesNotOverrideDerivedURL() async throws {
        let recorder = RequestRecorder()
        let client = try gc(recorder, project: "my-project", location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"),
                            env: ["ANTHROPIC_BASE_URL": "https://first-party.test/"])
        #expect(client.baseURL.absoluteString == derivedBaseURL)
        try await send(client)
        #expect(recorder.urls[0].hasPrefix(String(derivedBaseURL.dropLast())))
    }
}

@Suite struct GoogleCloudOrganizationRoutingTests {
    @Test func organizationRouteUsesOrganizationBase() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(workspaceList)(req) }
        let client = try gc(recorder, project: "my-project", location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"))
        _ = try await client.beta.organization.workspaces.list()
        #expect(recorder.urls == ["\(organizationBaseURL)/v1/organizations/workspaces"])
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer tok")
    }

    @Test func workspaceRouteKeepsWorkspaceBase() async throws {
        let recorder = RequestRecorder()
        try await send(try gc(recorder, project: "my-project", location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok")))
        #expect(recorder.urls == ["\(derivedBaseURL)v1/messages"])
    }

    @Test func organizationRouteNeedsNoWorkspace() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(workspaceList)(req) }
        _ = try await gc(recorder, project: "my-project", location: "us-central1", tokenProvider: tok("tok")).beta.organization.workspaces.list()
        #expect(recorder.urls == ["\(organizationBaseURL)/v1/organizations/workspaces"])
    }

    @Test func userProfilesRoutesUseOrganizationBase() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(#"{"id": "uprof_x", "type": "user_profile"}"#)(req) }
        let client = try gc(recorder, project: "my-project", location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"))
        _ = try await client.userProfiles.withRawResponse.create()
        _ = try await client.userProfiles.withRawResponse.retrieve("uprof_x")
        _ = try await client.beta.userProfiles.withRawResponse.list()
        _ = try await client.beta.userProfiles.withRawResponse.retrieve("uprof_x")
        #expect(recorder.urls.map { $0.components(separatedBy: "?")[0] } == [
            "\(organizationBaseURL)/v1/user_profiles", "\(organizationBaseURL)/v1/user_profiles/uprof_x",
            "\(organizationBaseURL)/v1/user_profiles", "\(organizationBaseURL)/v1/user_profiles/uprof_x",
        ])
    }

    @Test func userProfilesRoutesNeedNoWorkspace() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON("{}")(req) }
        let client = try gc(recorder, project: "my-project", location: "us-central1", tokenProvider: tok("tok"))
        _ = try await client.beta.userProfiles.withRawResponse.list()
        _ = try await client.beta.userProfiles.withRawResponse.retrieve("uprof_x")
        #expect(recorder.urls.map { $0.components(separatedBy: "?")[0] } == [
            "\(organizationBaseURL)/v1/user_profiles", "\(organizationBaseURL)/v1/user_profiles/uprof_x",
        ])
    }

    @Test func pathSharingUserProfilesPrefixKeepsWorkspaceBase() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON("{}")(req) }
        let client = try gc(recorder, project: "my-project", location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"))
        let _: JSONValue = try await client.get("/v1/user_profilesX")
        #expect(recorder.urls == ["\(derivedBaseURL)v1/user_profilesX"])
    }

    @Test func workspaceRouteWithoutWorkspaceRaises() async throws {
        let client = try gc(project: "my-project", location: "us-central1", tokenProvider: tok("tok"))
        await expectThrows(AnthropicError.self, matching: "(?s)workspace_id.*ANTHROPIC_GOOGLE_CLOUD_WORKSPACE_ID") { try await send(client) }
    }

    @Test func explicitBaseURLTakesEveryRoute() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(workspaceList)(req) }
        let client = try gc(recorder, workspaceID: "wrkspc_x", tokenProvider: tok("tok"), baseURL: "https://example.test/")
        _ = try await client.beta.organization.workspaces.list()
        _ = try await client.beta.userProfiles.withRawResponse.list()
        #expect(recorder.urls.map { $0.components(separatedBy: "?")[0] } == [
            "https://example.test/v1/organizations/workspaces", "https://example.test/v1/user_profiles",
        ])
    }

    @Test func assignedBaseURLTakesEveryRoute() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(workspaceList)(req) }
        let client = try gc(recorder, project: "my-project", location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"))
        client.baseURL = URL(string: "https://example.test/")!
        _ = try await client.beta.organization.workspaces.list()
        let copied: AnthropicGoogleCloud = try client.copy()
        _ = try await copied.beta.organization.workspaces.list()
        #expect(recorder.urls == Array(repeating: "https://example.test/v1/organizations/workspaces", count: 2))
    }

    @Test func copyOfWorkspacelessClientKeepsAssignedBaseURL() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(workspaceList)(req) }
        let client = try gc(recorder, project: "my-project", tokenProvider: tok("tok"))
        client.baseURL = URL(string: "https://example.test/")!
        _ = try await client.withOptions(timeout: 30).beta.organization.workspaces.list()
        #expect(recorder.urls == ["https://example.test/v1/organizations/workspaces"])
    }

    @Test func projectBackfilledFromADCForOrganizationRoute() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(workspaceList)(req) }
        let client = try gc(recorder, location: "us-central1", loader: LoadCounter().loader(project: "my-project"))
        _ = try await client.beta.organization.workspaces.list()
        #expect(recorder.urls == ["\(organizationBaseURL)/v1/organizations/workspaces"])
    }

    @Test func copyKeepsRouting() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(workspaceList)(req) }
        let client = try gc(recorder, project: "my-project", location: "us-central1", workspaceID: "wrkspc_x", tokenProvider: tok("tok"))
        _ = try await client.copy(location: "europe-west4").beta.organization.workspaces.list()
        #expect(recorder.urls == ["https://claude.googleapis.com/v1/projects/my-project/locations/europe-west4/claudeOrganization/invoke/v1/organizations/workspaces"])
    }
}

/// Application Default Credentials discovery (what `google.auth.default` provides).
@Suite struct GoogleADCTests {
    let serviceAccountJSON = """
        {"type": "service_account", "project_id": "sa-project", "private_key_id": "kid-1", "client_email": "sa@sa-project.iam.gserviceaccount.com",
         "token_uri": "https://oauth2.example.test/token", "private_key": \(try! String(decoding: JSONValue.serialize(.string(RSATestVectors.privateKeyPKCS8)), as: UTF8.self))}
        """

    @Test func serviceAccountFileMintsAnRS256JWTBearerToken() async throws {
        let path = writeTempFile(serviceAccountJSON)
        let recorder = RequestRecorder { req, _ in platformJSON(#"{"access_token": "sa-token", "expires_in": 3599, "token_type": "Bearer"}"#)(req) }
        let (creds, project) = try await GoogleAuth.loadDefaultCredentials(environment: isolatedEnv(["GOOGLE_APPLICATION_CREDENTIALS": path]),
                                                                            transport: recorder.transport)
        #expect(project == "sa-project")
        #expect(creds.token == "sa-token")
        #expect(!creds.expired)
        let request = recorder.requests[0]
        #expect(request.url.absoluteString == "https://oauth2.example.test/token")
        #expect(request.headers["Content-Type"] == "application/x-www-form-urlencoded")
        let form = Dictionary(uniqueKeysWithValues: String(decoding: request.body!, as: UTF8.self).split(separator: "&").map { pair in
            let kv = pair.split(separator: "=", maxSplits: 1).map { String($0).removingPercentEncoding! }
            return (kv[0], kv[1])
        })
        #expect(form["grant_type"] == "urn:ietf:params:oauth:grant-type:jwt-bearer")
        let jwt = try #require(form["assertion"]).split(separator: ".").map(String.init)
        #expect(jwt.count == 3)
        let header = try JSONValue.parse(Data(base64URLEncoded: jwt[0])!)
        #expect(header == ["alg": "RS256", "typ": "JWT", "kid": "kid-1"])
        let claims = try JSONValue.parse(Data(base64URLEncoded: jwt[1])!)
        #expect(claims["iss"] == "sa@sa-project.iam.gserviceaccount.com")
        #expect(claims["aud"] == "https://oauth2.example.test/token")
        #expect(claims["scope"] == .string(GOOGLE_CLOUD_PLATFORM_SCOPE))
        #expect(claims["exp"]?.intValue == claims["iat"]!.intValue! + 3600)
        let pub = try RSAPublicKey(pem: RSATestVectors.publicKey)
        #expect(pub.isValidSignature([UInt8](Data(base64URLEncoded: jwt[2])!), for: Array("\(jwt[0]).\(jwt[1])".utf8)))
    }

    @Test func explicitProjectEnvOverridesFileProject() async throws {
        let path = writeTempFile(serviceAccountJSON)
        let recorder = RequestRecorder { req, _ in platformJSON(#"{"access_token": "sa-token", "expires_in": 3599}"#)(req) }
        let (_, project) = try await GoogleAuth.loadDefaultCredentials(
            environment: isolatedEnv(["GOOGLE_APPLICATION_CREDENTIALS": path, "GOOGLE_CLOUD_PROJECT": "env-project"]), transport: recorder.transport)
        #expect(project == "env-project")
    }

    @Test func gcloudAuthorizedUserFile() async throws {
        let dir = (writeTempFile("x") as NSString).deletingLastPathComponent
        try #"{"type": "authorized_user", "client_id": "cid", "client_secret": "csecret", "refresh_token": "rtok", "quota_project_id": "quota"}"#
            .write(toFile: dir + "/application_default_credentials.json", atomically: true, encoding: .utf8)
        let recorder = RequestRecorder { req, _ in platformJSON(#"{"access_token": "user-token", "expires_in": 10}"#)(req) }
        let (creds, project) = try await GoogleAuth.loadDefaultCredentials(environment: isolatedEnv(["CLOUDSDK_CONFIG": dir]), transport: recorder.transport)
        #expect(project == nil)
        #expect(creds.projectID == "quota")
        #expect(creds.token == "user-token")
        #expect(creds.expired)  // 10s is inside google-auth's refresh window
        #expect(recorder.urls == ["https://oauth2.googleapis.com/token"])
        #expect(String(decoding: recorder.requests[0].body!, as: UTF8.self)
            == "grant_type=refresh_token&client_id=cid&client_secret=csecret&refresh_token=rtok")
    }

    @Test func metadataServer() async throws {
        let recorder = RequestRecorder { req, _ in
            #expect(req.headers["Metadata-Flavor"] == "Google")
            if req.url.path == "/computeMetadata/v1/project/project-id" {
                return HTTPResponse.text("gce-project", headers: ["Metadata-Flavor": "Google"], for: req)
            }
            #expect(req.url.path == "/computeMetadata/v1/instance/service-accounts/default/token")
            return platformJSON(#"{"access_token": "gce-token", "expires_in": 3599, "token_type": "Bearer"}"#)(req)
        }
        let (creds, project) = try await GoogleAuth.loadDefaultCredentials(environment: isolatedEnv(), transport: recorder.transport)
        #expect(project == "gce-project")
        #expect(creds.token == "gce-token")
        #expect(recorder.urls[0] == "http://metadata.google.internal/computeMetadata/v1/project/project-id")
    }

    @Test func noCredentialsFound() async {
        let recorder = RequestRecorder { req, _ in HTTPResponse.text("nope", status: 404, for: req) }
        await expectThrows(GoogleDefaultCredentialsError.self, matching: "default credentials were not found") {
            _ = try await GoogleAuth.loadDefaultCredentials(environment: isolatedEnv(), transport: recorder.transport)
        }
    }

    @Test func unsupportedCredentialFileType() async {
        let path = writeTempFile(#"{"type": "external_account"}"#)
        await expectThrows(GoogleDefaultCredentialsError.self, matching: "external_account") {
            _ = try await GoogleAuth.loadDefaultCredentials(environment: isolatedEnv(["GOOGLE_APPLICATION_CREDENTIALS": path]),
                                                            transport: RequestRecorder().transport)
        }
    }

    @Test func googleCloudClientUsesADCServiceAccountEndToEnd() async throws {
        let path = writeTempFile(serviceAccountJSON)
        let recorder = RequestRecorder { req, _ in
            req.url.host == "oauth2.example.test" ? platformJSON(#"{"access_token": "sa-token", "expires_in": 3599}"#)(req) : platformMessageResponse(req)
        }
        let env = isolatedEnv(["GOOGLE_APPLICATION_CREDENTIALS": path])
        let client = try AnthropicGoogleCloud(location: "us-central1", workspaceID: "wrkspc_x", transport: recorder.transport,
                                              credentialsLoader: { try await GoogleAuth.loadDefaultCredentials(environment: env, transport: recorder.transport) },
                                              environment: env)
        try await send(client)
        #expect(recorder.urls.last == "https://claude.googleapis.com/v1/projects/sa-project/locations/us-central1/workspaces/wrkspc_x/invoke/v1/messages")
        #expect(recorder.requests.last?.headers["Authorization"] == "Bearer sa-token")
    }
}
