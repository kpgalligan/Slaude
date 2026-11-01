// Port of `TestHttpAttributes` in tests/test_open_telemetry.py. See docs/porting/tracing.md for what is skipped.
//
// Python runs the list calls without strict response validation; a Swift response always decodes into its type, so a
// call whose canned page does not decode fails after its request was sent, which leaves the URL attributes as they are.

import Foundation
import Testing
@testable import Anthropic

typealias TracingInvoke = @Sendable (Anthropic) async throws -> Void

let tracingEmptyPage: JSONValue = ["data": [], "has_more": false, "first_id": nil, "last_id": nil, "next_page": nil]

/// Runs `invoke` with a client of `spans`, and ignores how the call ends.
func tracingCall(_ spans: TracingSpans, _ router: TracingRouter, openTelemetry: OpenTelemetryOptions? = nil, baseURL: String = tracingBaseURL,
                 maxRetries: Int = 2, middleware: [Middleware]? = nil, _ invoke: TracingInvoke) async throws
{
    let client = try tracingClient(spans, router, openTelemetry: openTelemetry ?? spans.option(), maxRetries: maxRetries, baseURL: baseURL,
                                   middleware: middleware)
    _ = try? await invoke(client)
}

/// `assert_http_attributes`.
func tracingExpectHTTPAttributes(_ span: SpanData, _ method: String, _ path: String, sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(span["http.request.method"] == .string(method), sourceLocation: sourceLocation)
    #expect(span["url.path"] == .string(path), sourceLocation: sourceLocation)
    #expect(span["server.address"] == "127.0.0.1", sourceLocation: sourceLocation)
    #expect(span["server.port"] == 4010, sourceLocation: sourceLocation)
}

@Suite struct OpenTelemetryHTTPAttributeTests {
    @Test func methodAndRouteAreOnTheSpanFromItsStart() async throws {
        let sampler = TracingStartAttributes()
        let router = TracingRouter()
        router.route("GET", "/v1/messages/batches/msgbatch_1", .json(tracingBatch()))
        router.route("DELETE", "/v1/files/file_1", .json(["id": "file_1", "type": "file_deleted"]))
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let client = try tracingClient(nil, router, openTelemetry: OpenTelemetryOptions(tracerProvider: SDKTracerProvider(sampler: sampler)))

        _ = try await client.messages.batches.retrieve("msgbatch_1")
        _ = try await client.beta.messages.batches.retrieve("msgbatch_1")
        _ = try await client.beta.files.delete("file_1")
        try await tracingCreate(client)

        #expect(sampler.started.map { "\($0.0) \($0.1["http.request.method"]!) \($0.1["http.route"]!)" } == [
            "anthropic.messages.batches.retrieve GET /v1/messages/batches/{message_batch_id}",
            "anthropic.messages.batches.retrieve GET /v1/messages/batches/{message_batch_id}",
            "anthropic.files.delete DELETE /v1/files/{file_id}",
            "anthropic.messages.create POST /v1/messages",
        ])
        // The URL is known only once the first request is built, which is after the span started.
        #expect(sampler.started.flatMap { $0.1.keys }.filter { $0.hasPrefix("url.") }.isEmpty)
    }

    @Test(arguments: [false, true])
    func streamAndParseHelpersHaveTheRoute(beta: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()), .json(tracingMessage))
        let client = try tracingClient(spans, router)

        if beta {
            try await client.beta.messages.stream(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test").untilDone()
            _ = try await client.beta.messages.parse(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test")
        } else {
            try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test").untilDone()
            _ = try await client.messages.parse(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test")
        }

        let calls = spans.named("anthropic.messages.create")
        #expect(calls.count == 2)
        for span in calls {
            #expect(span["http.request.method"] == "POST")
            #expect(span["http.route"] == "/v1/messages")
            #expect(span["url.full"] == .string("\(tracingBaseURL)/v1/messages"))
        }
    }

    @Test func urlAttributesAreThePartsOfTheURLThatTheRequestGoesTo() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/proxy/v1/files/a%2Fb", .json(["id": "a/b"]))

        try await tracingCall(spans, router, baseURL: "https://api.example.com:8443/proxy") { _ = try await $0.beta.files.retrieveMetadata("a/b") }

        let span = try spans.one("anthropic.files.retrieve_metadata")
        #expect(span["http.route"] == "/v1/files/{file_id}")
        #expect(span["server.address"] == "api.example.com")
        #expect(span["server.port"] == 8443)
        #expect(span.urlAttributes == [
            "url.scheme": "https", "url.path": "/proxy/v1/files/a%2Fb", "url.full": "https://api.example.com:8443/proxy/v1/files/a%2Fb",
        ])
    }

    @Test func urlFullHasAPortOnlyWhenTheURLHasOne() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "https://api.example.com/v1/messages", .json(tracingMessage))
        router.route("POST", "http://[::1]:4010/v1/messages", .json(tracingMessage))

        try await tracingCreate(try tracingClient(spans, router, baseURL: "https://api.example.com"))
        try await tracingCreate(try tracingClient(spans, router, baseURL: "http://[::1]:4010"))

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        #expect(calls[0]["server.port"] == 443)
        #expect(calls[0]["url.full"] == "https://api.example.com/v1/messages")
        #expect(calls[1]["server.address"] == "::1")
        #expect(calls[1]["url.full"] == "http://[::1]:4010/v1/messages")
    }

    @Test(arguments: [("https://api.example.com", 443), ("http://api.example.com", 80), ("https://api.example.com:443", 443),
                      ("http://api.example.com:8080/proxy", 8080)])
    func serverPortIsTheBaseURLsOrElseTheOneOfItsScheme(baseURL: String, port: Int) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "*", .json(tracingMessage))

        try await tracingCreate(try tracingClient(spans, router, baseURL: baseURL))

        let span = try spans.one("anthropic.messages.create")
        #expect(span["server.address"] == "api.example.com")
        #expect(span["server.port"] == .int(port))
        // The full URL has a port only when the request's URL names one, which a scheme's own port is not.
        let scheme = baseURL.components(separatedBy: "://")[0]
        let inURL = port == 8080 ? ":8080" : ""
        #expect(span["url.full"]?.stringValue?.hasPrefix("\(scheme)://api.example.com\(inURL)/") == true)
    }

    /// `CONTENT_QUERY_CALLS`: a call whose query has a parameter that is content on every endpoint.
    static let contentQueryCalls: [(String, String, String, String)] = [
        ("GET", "/v1/organizations/users", "email=a%40example.com&limit=5", "anthropic.organization.users.list"),
        ("GET", "/v1/memory_stores/memstore_1/memories", "path_prefix=%2Fnotes", "anthropic.memory_stores.memories.list"),
        ("DELETE", "/v1/memory_stores/memstore_1/memories/mem_1", "expected_content_sha256=" + String(repeating: "0", count: 64),
         "anthropic.memory_stores.memories.delete"),
    ]

    static func contentQueryInvoke(_ index: Int) -> TracingInvoke {
        switch index {
        case 0: return { _ = try await $0.beta.organization.users.list(email: "a@example.com", limit: 5) }
        case 1: return { _ = try await $0.beta.memoryStores.memories.list("memstore_1", pathPrefix: "/notes") }
        default: return {
            _ = try await $0.beta.memoryStores.memories.delete("mem_1", memoryStoreID: "memstore_1",
                                                               expectedContentSha256: String(repeating: "0", count: 64))
        }
        }
    }

    @Test(arguments: [OpenTelemetryContentMode.metadataOnly, .content], 0..<3)
    func aQueryThatIsContentNeedsContentModeAndSoDoesTheFullURL(contentMode: OpenTelemetryContentMode, call: Int) async throws {
        let (method, path, query, name) = Self.contentQueryCalls[call]
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route(method, path, .json(tracingEmptyPage))

        try await tracingCall(spans, router, openTelemetry: spans.option(traces: OpenTelemetryTraces(contentMode: contentMode)),
                              Self.contentQueryInvoke(call))

        let request = try #require(route.requests.first)
        #expect(request.url.query(percentEncoded: true) == query)
        let span = try spans.one(name)
        if contentMode == .content {
            #expect(span["url.query"] == .string(query))
            #expect(span["url.full"] == .string("\(tracingBaseURL)\(path)?\(query)"))
        } else {
            #expect(span["url.query"] == nil)
            #expect(span["url.full"] == nil)
        }
        // Whatever the mode, the span has every other attribute of the request.
        #expect(span["url.scheme"] == "http")
        tracingExpectHTTPAttributes(span, method, path)
    }

    @Test(arguments: [OpenTelemetryContentMode.metadataOnly, .content])
    func anOrganizationMethodHasASpanAndItsEmailQueryNeedsContentMode(contentMode: OpenTelemetryContentMode) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("GET", "/v1/organizations/users", .json(tracingEmptyPage))

        try await tracingCall(spans, router, openTelemetry: spans.option(traces: OpenTelemetryTraces(contentMode: contentMode))) {
            _ = try await $0.organization.users.list(email: "a@example.com", limit: 5)
        }

        #expect(route.requests.first?.url.query(percentEncoded: true) == "email=a%40example.com&limit=5")
        let span = try spans.one("anthropic.organization.users.list")
        #expect(span["http.request.method"] == "GET")
        #expect(span["http.route"] == "/v1/organizations/users")
        #expect(span["url.path"] == "/v1/organizations/users")
        if contentMode == .content {
            #expect(span["url.query"] == "email=a%40example.com&limit=5")
            #expect(span["url.full"] == .string("\(tracingBaseURL)/v1/organizations/users?email=a%40example.com&limit=5"))
        } else {
            #expect(span["url.query"] == nil)
            #expect(span["url.full"] == nil)
        }
    }

    /// `SCOPED_CONTENT_CALLS`: a parameter that is content only where its value is, which is for the method to say.
    static let scopedContentCalls: [(String, String, String, String, Bool)] = [
        ("filter", "/v1/organizations/analytics/skills", "/v1/organizations/analytics/skills", "anthropic.organization.analytics.skills.list", true),
        ("filter", "/v1/organizations/analytics/plugins", "/v1/organizations/analytics/plugins", "anthropic.organization.analytics.plugins.list",
         true),
        ("filter", "/v1/organizations/analytics/connectors", "/v1/organizations/analytics/connectors",
         "anthropic.organization.analytics.connectors.list", true),
        ("filter", "/v1/organizations/analytics/users", "/v1/organizations/analytics/users", "anthropic.organization.analytics.users.list", false),
        ("filter", "/v1/organizations/analytics/artifacts", "/v1/organizations/analytics/artifacts",
         "anthropic.organization.analytics.artifacts.list", false),
        ("filter", "/v1/organizations/analytics/apps/chat/projects", "/v1/organizations/analytics/apps/chat/projects",
         "anthropic.organization.analytics.apps.chat.projects.list", false),
        ("filter", "/v1/organizations/analytics/summaries", "/v1/organizations/analytics/summaries",
         "anthropic.organization.analytics.summaries.list", false),
        // A `page` cursor has a value of the row it ends at in it: an email address here, and a memory's path below.
        ("page", "/v1/organizations/analytics/users", "/v1/organizations/analytics/users", "anthropic.organization.analytics.users.list", true),
        ("page", "/v1/memory_stores/memstore_1/memories", "/v1/memory_stores/{memory_store_id}/memories", "anthropic.memory_stores.memories.list",
         true),
        ("page", "/v1/organizations/analytics/skills", "/v1/organizations/analytics/skills", "anthropic.organization.analytics.skills.list", false),
    ]

    static func scopedContentInvoke(_ index: Int, filter: [String], page: String) -> TracingInvoke {
        switch index {
        case 0: return { _ = try await $0.beta.organization.analytics.skills.list(filter: filter) }
        case 1: return { _ = try await $0.beta.organization.analytics.plugins.list(filter: filter) }
        case 2: return { _ = try await $0.beta.organization.analytics.connectors.list(filter: filter) }
        case 3: return { _ = try await $0.beta.organization.analytics.users.list(filter: filter) }
        case 4: return { _ = try await $0.beta.organization.analytics.artifacts.list(date: try JSONValue.string("2026-01-01").decode(), filter: filter) }
        case 5: return { _ = try await $0.beta.organization.analytics.apps.chat.projects.list(filter: filter) }
        case 6: return {
            _ = try await $0.beta.organization.analytics.summaries.list(startingDate: try JSONValue.string("2026-01-01").decode(), filter: filter)
        }
        case 7: return { _ = try await $0.beta.organization.analytics.users.list(page: page) }
        case 8: return { _ = try await $0.beta.memoryStores.memories.list("memstore_1", page: page) }
        default: return { _ = try await $0.beta.organization.analytics.skills.list(page: page) }
        }
    }

    @Test(arguments: [OpenTelemetryContentMode.metadataOnly, .content], 0..<10)
    func aParameterIsContentOnlyOnTheEndpointsWhereItsValueIs(contentMode: OpenTelemetryContentMode, call: Int) async throws {
        let (parameter, path, httpRoute, name, isContent) = Self.scopedContentCalls[call]
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("GET", path, .json(["data": [], "next_page": nil]))
        // A name where the endpoint matches names, and an ID on the others.
        let value = isContent ? "skill_name:Quarterly" : "user_id:user_1"
        let query = parameter == "filter" ? "filter%5B%5D=" + value.replacingOccurrences(of: ":", with: "%3A") : "page=page_abc"

        try await tracingCall(spans, router, openTelemetry: spans.option(traces: OpenTelemetryTraces(contentMode: contentMode)),
                              Self.scopedContentInvoke(call, filter: [value], page: "page_abc"))

        let request = try #require(route.requests.first)
        #expect(request.url.query(percentEncoded: true)?.split(separator: "&").contains(Substring(query)) == true)
        let span = try spans.one(name)
        #expect(span["http.route"] == .string(httpRoute))
        #expect(span["url.path"] == .string(path))
        if isContent && contentMode == .metadataOnly {
            #expect(span["url.query"] == nil)
            #expect(span["url.full"] == nil)
        } else {
            let spanQuery = try #require(span["url.query"]?.stringValue)
            #expect(spanQuery.split(separator: "&").contains(Substring(query)))
            #expect(span["url.full"] == .string("\(tracingBaseURL)\(path)?\(spanQuery)"))
        }
    }

    @Test(arguments: [OpenTelemetryContentMode.metadataOnly, .content])
    func aQueryThatIsNoContentIsThereInBothModes(contentMode: OpenTelemetryContentMode) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/v1/files", .json(tracingEmptyPage))

        // This endpoint defines no `email`, so the query that the span has is without the caller's.
        try await tracingCall(spans, router, openTelemetry: spans.option(traces: OpenTelemetryTraces(contentMode: contentMode))) {
            _ = try await $0.beta.files.list(limit: 5, extraQuery: ["email": "a@example.com"])
        }

        let span = try spans.one("anthropic.files.list")
        #expect(span["url.query"] == "limit=5")
        #expect(span["url.full"] == .string("\(tracingBaseURL)/v1/files?limit=5"))
    }

    @Test func aNameThatOnlyStartsWithAContentParameterIsLeftOut() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let path = "/v1/organizations/analytics/skills"
        let route = router.route("GET", path, .json(["data": [], "next_page": nil]))

        try await tracingCall(spans, router) {
            _ = try await $0.beta.organization.analytics.skills.list(limit: 5, extraQuery: ["filter[a]": "skill_name:Quarterly"])
        }

        #expect(route.requests.first?.url.query(percentEncoded: true)?.split(separator: "&").contains("filter%5Ba%5D=skill_name%3AQuarterly") == true)
        let span = try spans.one("anthropic.organization.analytics.skills.list")
        #expect(span["url.query"] == "limit=5")
        #expect(span["url.full"] == .string("\(tracingBaseURL)\(path)?limit=5"))
    }

    @Test(arguments: [
        // A name of `CONTENT_QUERY_PARAMS` is content whether or not the method names it.
        ("email=a%40example.com", [String](), true),
        ("limit=5&path_prefix=%2Fnotes", [], true),
        ("expected_content_sha256=abc", ["filter"], true),
        ("filter%5B%5D=skill_name%3AQuarterly&limit=5", ["filter"], true),
        ("filter[]=skill_name%3AQuarterly", ["filter"], true),
        ("%66ilter%5B%5D=skill_name%3AQuarterly", ["filter"], true),
        ("filter=skill_name%3AQuarterly", ["filter"], true),
        // Only the whole name, or the array of it, is the parameter.
        ("filter[a]=x", ["filter"], false),
        ("filter%5Ba%5D%5B%5D=x&email[x]=a%40example.com", ["filter"], false),
        ("created_at%5Bgte%5D=1", ["created_at[gte]"], true),
        ("filter%5B%5D=user_id%3Auser_1&limit=5", [], false),
        ("limit=5&after_id=user_1", ["filter"], false),
        ("email_domain=example.com", [], false),
        ("", ["filter"], false),
    ])
    func isContentQueryCases(query: String, contentNames: [String], content: Bool) {
        #expect(isContentQuery(query, contentNames) == content)
    }

    @Test func urlQueryHasOnlyTheParametersThatTheEndpointDefines() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("GET", "/v1/files", .json(tracingEmptyPage))
        let client = try Anthropic(apiKey: "key", baseURL: tracingBaseURL, defaultQuery: ["tenant": "t1"], transport: router.transport,
                                   openTelemetry: spans.option(), environment: [:])

        _ = try? await client.beta.files.list(ids: ["file 1", "file_2"], limit: 5, extraQuery: ["trace": "on", "scope_id": "a&b", "limit[x]": "1"])

        let sent = try #require(route.requests.first?.url.query(percentEncoded: true))
        let span = try spans.one("anthropic.files.list")
        // What is left is as it was sent, in the order it was sent. A defined parameter stays however the caller set it.
        // `limit[x]` is no parameter of the endpoint, though `limit` is.
        let kept = sent.split(separator: "&").filter { ["ids%5B%5D", "limit", "scope_id"].contains($0.split(separator: "=")[0]) }
        #expect(span["url.query"] == .string(kept.joined(separator: "&")))
        #expect(kept.count == 4)
        #expect(span["url.query"]?.stringValue?.contains("scope_id=a%26b") == true)
        #expect(span["url.full"] == .string("\(tracingBaseURL)/v1/files?" + (span["url.query"]?.stringValue ?? "")))
    }

    @Test func urlQueryKeepsAParameterWhoseNameHasBracketsOfItsOwn() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/v1/sessions", .json(["data": [], "next_page": nil]))

        try await tracingCall(spans, router) {
            _ = try await $0.beta.sessions.list(createdAtGte: try JSONValue.string("2024-01-01T00:00:00Z").decode(),
                                                extraQuery: ["created_at[before]": "x"])
        }

        // `created_at[gte]` is a parameter of the endpoint, and `created_at` is not, so `created_at[before]` is none.
        let query = try #require(try spans.one("anthropic.sessions.list")["url.query"]?.stringValue)
        #expect(query.hasPrefix("created_at%5Bgte%5D=2024-01-01T00"))
        #expect(!query.contains("before"))
    }

    static let declaredQueryCalls: [(String, String, String)] = [
        ("/v1/models", "lifecycle%5B%5D=active&lifecycle%5B%5D=retired", "anthropic.models.list"),
        ("/v1/models", "lifecycle%5B%5D=active", "anthropic.models.list"),
        ("/v1/organizations/workspaces", "include_default=true", "anthropic.organization.workspaces.list"),
        ("/v1/organizations/workspaces", "include_default=true", "anthropic.organization.workspaces.list"),
        ("/v1/sessions/sesn_1/threads", "statuses%5B%5D=running&statuses%5B%5D=idle", "anthropic.sessions.threads.list"),
    ]

    static func declaredQueryInvoke(_ index: Int) -> TracingInvoke {
        switch index {
        case 0: return { _ = try await $0.models.list(lifecycle: [.active, .retired]) }
        case 1: return { _ = try await $0.beta.models.list(lifecycle: [.active]) }
        case 2: return { _ = try await $0.organization.workspaces.list(includeDefault: true) }
        case 3: return { _ = try await $0.beta.organization.workspaces.list(includeDefault: true) }
        default: return { _ = try await $0.beta.sessions.threads.list("sesn_1", statuses: [.running, .idle]) }
        }
    }

    @Test(arguments: 0..<5)
    func urlQueryHasEachParameterThatTheMethodDeclares(call: Int) async throws {
        let (path, query, name) = Self.declaredQueryCalls[call]
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", path, .json(tracingEmptyPage))

        try await tracingCall(spans, router, Self.declaredQueryInvoke(call))

        let span = try spans.one(name)
        #expect(span["url.query"] == .string(query))
        #expect(span["url.full"] == .string("\(tracingBaseURL)\(path)?\(query)"))
    }

    @Test(arguments: [false, true])
    func noURLQueryWhenNoDefinedParameterIsSent(beta: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/v1/messages/batches", .json(tracingEmptyPage))
        let client = try tracingClient(spans, router)

        if beta {
            _ = try await client.beta.messages.batches.list(extraQuery: ["trace": "on"])
        } else {
            _ = try await client.messages.batches.list(extraQuery: ["trace": "on"])
        }

        let span = try spans.one("anthropic.messages.batches.list")
        #expect(span["url.query"] == nil)
        #expect(span["url.full"] == .string("\(tracingBaseURL)/v1/messages/batches"))
    }

    @Test(arguments: [
        ("limit=1&beta=true", ["limit"], "limit=1"),
        ("ids[]=a&ids%5B%5D=b&ids%5b%5d=c", ["ids"], "ids[]=a&ids%5B%5D=b&ids%5b%5d=c"),
        ("%6Cimit=1&l%69mit=2&limits=3", ["limit"], "%6Cimit=1&l%69mit=2"),
        ("created_at%5Bgte%5D=1&created_at%5Blt%5D=2", ["created_at[gte]"], "created_at%5Bgte%5D=1"),
        // A name is whole: one that only starts with a defined name is not that parameter.
        ("filter[a][b]=1&filterx[a]=2", ["filter"], ""),
        ("limit%5Bx%5D=1&limit=5&ids%5B%5D=a", ["limit", "ids"], "limit=5&ids%5B%5D=a"),
        ("ids[][]=a&ids[0]=b&[]=c", ["ids"], ""),
        ("page=a%3Db&page&flag", ["page", "flag"], "page=a%3Db&page&flag"),
        ("b=2&a=1&b=3", ["a", "b"], "b=2&a=1&b=3"),
        ("beta=true", ["limit"], ""),
        ("limit=1", [], ""),
        ("", ["limit"], ""),
    ])
    func definedQueryCases(query: String, names: [String], kept: String) {
        #expect(definedQuery(query, names) == kept)
    }

    @Test func aRetriedCallHasTheURLOfItsFirstRequestAndCountsTheOthers() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("GET", "/v1/messages/batches", .json(tracingOverloaded, status: 529), .json(tracingOverloaded, status: 529),
                                 .json(tracingEmptyPage))
        let renumber = MiddlewareFunction { request, next in try await next(request.copy(params: ["limit": .int(request.retriesTaken + 1)])) }

        try await tracingCall(spans, router, middleware: [renumber]) { _ = try await $0.messages.batches.list() }

        #expect(route.requests.map { $0.url.query } == ["limit=1", "limit=2", "limit=3"])
        let span = try spans.one("anthropic.messages.batches.list")
        #expect(span["url.query"] == "limit=1")
        #expect(span["url.full"] == .string("\(tracingBaseURL)/v1/messages/batches?limit=1"))
        #expect(span["http.request.resend_count"] == 2)
        #expect(span["http.response.status_code"] == 200)
    }

    @Test func aCallThatIsSentOnceHasNoResendCount() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage), .json([:], status: 400))
        let client = try tracingClient(spans, router)

        try await tracingCreate(client)
        await #expect(throws: APIStatusError.self) { try await tracingCreate(client) }

        let calls = spans.named("anthropic.messages.create")
        #expect(calls.count == 2)
        for span in calls { #expect(span["http.request.resend_count"] == nil) }
    }

    @Test func aCallWhoseRetriesAllFailCountsThem() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .fail(URLError(.cannotConnectToHost)))

        await #expect(throws: APIConnectionError.self) { try await tracingCreate(try tracingClient(spans, router, maxRetries: 1)) }

        let span = try spans.one("anthropic.messages.create")
        #expect(span["http.request.resend_count"] == 1)
        #expect(span["url.full"] == .string("\(tracingBaseURL)/v1/messages"))
    }

    @Test func aFallbackRequestIsAResendAndKeepsTheFirstURL() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("GET", "/v1/messages/batches", .json(tracingEmptyPage))
        let sendTwice = MiddlewareFunction { request, next in
            try await next(request.copy(params: ["limit": 1])).http.close()
            return try await next(request.copy(params: ["limit": 2]))
        }

        try await tracingCall(spans, router, middleware: [sendTwice]) { _ = try await $0.messages.batches.list() }

        #expect(route.requests.count == 2)
        let span = try spans.one("anthropic.messages.batches.list")
        #expect(span["url.query"] == "limit=1")
        #expect(span["http.request.resend_count"] == 1)
    }

    @Test func aCallThatFailsBeforeItSendsARequestHasNoURL() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages", .json(tracingMessage))
        let refuse = MiddlewareFunction { _, _ in throw ValueError("refused") }

        await #expect(throws: ValueError.self) { try await tracingCreate(try tracingClient(spans, router, middleware: [refuse])) }

        #expect(route.requests.isEmpty)
        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .error)
        #expect(span["http.request.method"] == "POST")
        #expect(span["http.route"] == "/v1/messages")
        #expect(span.urlAttributes == [:])
        #expect(span["http.request.resend_count"] == nil)
    }

    @Test func aStreamedCallThatWasRetriedHasTheResendCount() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingOverloaded, status: 529), .sse(tracingStreamEvents()))

        await tracingDrain(try await tracingCreateStream(try tracingClient(spans, router, maxRetries: 1)))

        #expect(try spans.one("anthropic.messages.create")["http.request.resend_count"] == 1)
    }

    @Test func aRawResponseThatWasRetriedHasTheResendCount() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingOverloaded, status: 529), .json(tracingMessage))

        _ = try await tracingClient(spans, router, maxRetries: 1).messages.withRawResponse.create(maxTokens: 1024, messages: tracingMessages(tracingHello),
                                                                                              model: "claude-test")

        #expect(try spans.one("anthropic.messages.create")["http.request.resend_count"] == 1)
    }

    @Test(arguments: [false, true])
    func batchResultsHasTheRouteWhateverURLTheBatchNames(beta: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let batch = tracingBatch(resultsURL: .string("\(tracingBaseURL)/v1/messages/batches/msgbatch_1/results?token=abc"))
        router.route("GET", "/v1/messages/batches/msgbatch_1", .json(batch))
        router.route("GET", "/v1/messages/batches/msgbatch_1/results", .text(""))
        let client = try tracingClient(spans, router)

        if beta {
            try await client.beta.messages.batches.results("msgbatch_1").close()
        } else {
            try await client.messages.batches.results("msgbatch_1").close()
        }

        let span = try spans.one("anthropic.messages.batches.results")
        #expect(span["http.request.method"] == "GET")
        #expect(span["http.route"] == "/v1/messages/batches/{message_batch_id}/results")
        // `token` is not a parameter that the endpoint defines.
        #expect(span.urlAttributes == [
            "url.scheme": "http", "url.path": "/v1/messages/batches/msgbatch_1/results",
            "url.full": .string("\(tracingBaseURL)/v1/messages/batches/msgbatch_1/results"),
        ])
    }

    @Test func batchResultsOnAnotherHostHasThatHostInItsURL() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/v1/messages/batches/msgbatch_1", .json(tracingBatch(resultsURL: "https://files.example.com/download/abc")))
        router.route("GET", "https://files.example.com/download/abc", .text(""))

        try await tracingClient(spans, router).messages.batches.results("msgbatch_1").close()

        let span = try spans.one("anthropic.messages.batches.results")
        // `server.address` is the host of the client, and the URL is the one that the request went to.
        #expect(span["server.address"] == "127.0.0.1")
        #expect(span["http.route"] == "/v1/messages/batches/{message_batch_id}/results")
        #expect(span.urlAttributes == [
            "url.scheme": "https", "url.path": "/download/abc", "url.full": "https://files.example.com/download/abc",
        ])
    }
}
