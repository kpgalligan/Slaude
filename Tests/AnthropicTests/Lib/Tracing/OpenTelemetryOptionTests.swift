// Port of tests/test_tracing.py, and of `TestTracesOption`, `TestPropagationOption` and `TestConversationId` in
// tests/test_open_telemetry.py. See docs/porting/tracing.md for what is skipped.
//
// Python sets the environment variables with `update_env`; a Swift client reads the `environment:` it is given.

import Foundation
import Testing
@testable import Anthropic

extension AnthropicBedrockMantle: TracingMessagesClient {}

let tracingTraceparent = "00-00000000000000000000000000000001-0000000000000001-01"

/// `RecordingSpan` of tests/test_tracing.py: a span with a valid context, which records unless a sampler dropped it.
final class TracingStubSpan: Span, @unchecked Sendable {
    let context: SpanContext
    let sampled: Bool
    private let lock = NSLock()
    private var _attributes: SpanAttributes
    private var _ended = false

    init(_ attributes: SpanAttributes, sampled: Bool) {
        self.context = SpanContext(traceID: TraceID(low: 1), spanID: SpanID(1), traceFlags: sampled ? .sampled : .default)
        self._attributes = attributes
        self.sampled = sampled
    }

    var attributes: SpanAttributes { lock.withLock { _attributes } }
    var ended: Bool { lock.withLock { _ended } }
    var isRecording: Bool { sampled && !ended }
    func setAttribute(_ key: String, _ value: AttributeValue) { lock.withLock { _attributes[key] = value } }
    func addEvent(_ name: String, attributes: SpanAttributes, timestamp: Date?) {}
    func setStatus(_ status: SpanStatus) {}
    func recordException(_ error: Error, attributes: SpanAttributes) {}
    func updateName(_ name: String) {}
    func end(time: Date?) { lock.withLock { _ended = true } }
}

/// `RecordingProvider` of tests/test_tracing.py.
final class TracingStubProvider: TracerProvider, @unchecked Sendable {
    let sampled: Bool
    private let lock = NSLock()
    private var _spans: [TracingStubSpan] = []
    private var _tracers = 0

    init(sampled: Bool = true) { self.sampled = sampled }

    var spans: [TracingStubSpan] { lock.withLock { _spans } }
    var tracers: Int { lock.withLock { _tracers } }

    struct StubTracer: Tracer {
        let provider: TracingStubProvider
        func startSpan(_ name: String, kind: SpanKind, attributes: SpanAttributes, context: TracingContext?, startTime: Date?) -> any Span {
            let span = TracingStubSpan(attributes, sampled: provider.sampled)
            provider.lock.withLock { provider._spans.append(span) }
            return span
        }
    }

    func tracer(_ scope: String, version: String?) -> any Tracer {
        lock.withLock { _tracers += 1 }
        return StubTracer(provider: self)
    }
}

/// `CountingPropagator`: the propagator that the application registered, counting what it is asked to inject.
final class TracingCountingPropagator: TextMapPropagator, @unchecked Sendable {
    let inner: (any TextMapPropagator)?
    private let lock = NSLock()
    private var _injections = 0

    /// Without `inner`, it writes `tracingTraceparent`, as the one of tests/test_tracing.py does.
    init(_ inner: (any TextMapPropagator)? = nil) { self.inner = inner }

    var injections: Int { lock.withLock { _injections } }
    var fields: Set<String> { inner?.fields ?? ["traceparent"] }

    func inject(_ context: TracingContext, into carrier: inout [String: String]) throws {
        lock.withLock { _injections += 1 }
        if let inner { try inner.inject(context, into: &carrier) } else { carrier["traceparent"] = tracingTraceparent }
    }
}

/// `KeptSpanIds`: keeps the ID of each span that its provider starts, which a span that the sampler drops shows nowhere else.
final class TracingKeptSpanIDs: IDGenerator, @unchecked Sendable {
    private let lock = NSLock()
    private var ids: [SpanID] = []
    var spanIDs: [SpanID] { lock.withLock { ids } }
    func generateTraceID() -> TraceID { RandomIDGenerator().generateTraceID() }
    func generateSpanID() -> SpanID {
        let id = RandomIDGenerator().generateSpanID()
        lock.withLock { ids.append(id) }
        return id
    }
}

/// `application_trace_context`: runs with a sampled span and a baggage entry current, as an instrumented application
/// calls the SDK, and the registered propagator counted.
func tracingApplicationContext<R>(_ body: (TracingCountingPropagator) async throws -> R) async rethrows -> R {
    let parent = NonRecordingSpan(SpanContext(traceID: TraceID(low: 0x1234), spanID: SpanID(0x5678), traceFlags: .sampled,
                                              traceState: TraceState([("vendor", "value")]), isRemote: true))
    let counting = TracingCountingPropagator(OpenTelemetry.propagator)
    return try await OpenTelemetry.withPropagator(counting) {
        try await TracingContext.with(TracingContext(span: parent, baggage: [("tenant", "acme")])) { try await body(counting) }
    }
}

/// `call` of tests/test_tracing.py: a request made the way an SDK method makes one, which names its span.
func tracingTestCall(_ client: BaseClient, extraHeaders: Headers? = nil, query: [(String, JSONValue)] = [],
                     contentQueryParams: [String] = []) async throws
{
    var options = FinalRequestOptions(method: "get", url: "/foo", params: query, headers: extraHeaders)
    options.spanName = "test"
    options.spanQueryParams = query.map(\.0)
    options.spanContentQueryParams = contentQueryParams
    _ = try await client.requestHTTPResponse(options).parse()
}

/// `Server` of tests/test_tracing.py: answers a call, after one retry if `retried`.
func tracingServer(retried: Bool = false) -> (TracingRouter, TracingRoute) {
    let router = TracingRouter()
    let route = router.route("*", "*", replies: retried
        ? [.json([:], status: 500, headers: ["retry-after-ms": "1"]), .json([:])]
        : [.json([:])])
    return (router, route)
}

func tracingNewClient(_ router: TracingRouter, openTelemetry: OpenTelemetryOptions?, environment: [String: String] = [:]) throws -> Anthropic {
    try tracingClient(nil, router, openTelemetry: .some(openTelemetry), maxRetries: 1, environment: environment)
}

let tracingDefaultTraces = OpenTelemetryTraces(enabled: true, contentMode: .metadataOnly, maxContentBytes: CONTENT_LIMIT)
let tracingDefaults = OpenTelemetryOptions(propagation: true, traces: tracingDefaultTraces)

/// Every variable, set to something other than the default (`every_env`).
let tracingEveryEnv = [
    "ANTHROPIC_OPEN_TELEMETRY": "false", "ANTHROPIC_OPEN_TELEMETRY_PROPAGATION": "false",
    "ANTHROPIC_OPEN_TELEMETRY_TRACES_CONTENT_MODE": "content", "ANTHROPIC_OPEN_TELEMETRY_TRACES_MAX_CONTENT_BYTES": "300",
]

/// One client of each platform class (`platform_clients`).
struct TracingPlatform: Sendable {
    let platform: String
    let make: @Sendable (OpenTelemetryOptions?, [String: String], TracingRouter) throws -> any TracingMessagesClient
    let copy: @Sendable (any TracingMessagesClient, OpenTelemetryOptions?) throws -> any TracingMessagesClient

    static let all: [TracingPlatform] = [
        TracingPlatform(platform: "bedrock", make: {
            try AnthropicBedrock(awsSecretKey: "secret", awsAccessKey: "access", awsRegion: "us-east-1", transport: $2.transport,
                                 openTelemetry: $0, environment: $1)
        }, copy: { try ($0 as! AnthropicBedrock).copy(openTelemetry: $1) }),
        TracingPlatform(platform: "bedrock", make: {
            try AnthropicBedrockMantle(awsRegion: "us-east-1", apiKey: "key", transport: $2.transport, openTelemetry: $0, environment: $1)
        }, copy: { try ($0 as! AnthropicBedrockMantle).copy(openTelemetry: $1) }),
        TracingPlatform(platform: "vertex", make: {
            try AnthropicVertex(region: "us-east5", projectID: "project", accessToken: "token", transport: $2.transport, openTelemetry: $0,
                                environment: $1)
        }, copy: { try ($0 as! AnthropicVertex).copy(openTelemetry: $1) }),
        TracingPlatform(platform: "foundry", make: {
            try AnthropicFoundry(resource: "resource", apiKey: "key", transport: $2.transport, openTelemetry: $0, environment: $1)
        }, copy: { try ($0 as! AnthropicFoundry).copy(openTelemetry: $1) }),
        TracingPlatform(platform: "aws", make: {
            try AnthropicAWS(skipAuth: true, baseURL: tracingBaseURL, transport: $2.transport, openTelemetry: $0, environment: $1)
        }, copy: { try ($0 as! AnthropicAWS).withOptions(openTelemetry: $1) }),
        TracingPlatform(platform: "google_cloud", make: {
            try AnthropicGoogleCloud(workspaceID: "wrkspc_1", tokenProvider: { "token" }, baseURL: tracingBaseURL, transport: $2.transport,
                                     openTelemetry: $0, environment: $1)
        }, copy: { try ($0 as! AnthropicGoogleCloud).withOptions(openTelemetry: $1) }),
    ]

    static func clients(_ option: OpenTelemetryOptions?, environment: [String: String] = [:], router: TracingRouter = TracingRouter()) throws
        -> [(TracingPlatform, any TracingMessagesClient)]
    {
        try all.map { ($0, try $0.make(option, environment, router)) }
    }
}

let tracingOldAndNew: [JSONValue] = [["role": "user", "content": .string("old " + String(repeating: "x", count: 200))],
                                     ["role": "user", "content": "new"]]

@Suite struct TracingModuleTests {
    @Test(arguments: [
        (OpenTelemetryContentMode.content, [String](), ("email", "a@example.com"), "email=a%40example.com"),
        (.metadataOnly, [], ("email", "a@example.com"), nil),
        (.content, ["filter"], ("filter", "open"), "filter=open"),
        (.metadataOnly, ["filter"], ("filter", "open"), nil),
        (.metadataOnly, [], ("filter", "open"), "filter=open"),
    ] as [(OpenTelemetryContentMode, [String], (String, String), String?)])
    func contentModeDecidesWhetherAContentQueryIsRecorded(contentMode: OpenTelemetryContentMode, endpointContentParams: [String],
                                                          query: (String, String), recorded: String?) async throws
    {
        let provider = TracingStubProvider()
        let (router, _) = tracingServer()
        let client = try tracingNewClient(router, openTelemetry: OpenTelemetryOptions(tracerProvider: provider,
                                                                                      traces: OpenTelemetryTraces(contentMode: contentMode)))

        try await tracingTestCall(client, query: [(query.0, .string(query.1))], contentQueryParams: endpointContentParams)

        try #require(provider.spans.count == 1)
        #expect(provider.spans[0].ended)
        #expect(provider.spans[0].attributes["url.query"]?.stringValue == recorded)
    }

    @Test func eachRequestCarriesTheTraceContext() async throws {
        let propagator = TracingCountingPropagator()
        try await OpenTelemetry.withPropagator(propagator) {
            let (router, route) = tracingServer(retried: true)
            let client = try tracingNewClient(router, openTelemetry: OpenTelemetryOptions(tracerProvider: TracingStubProvider()))

            try await tracingTestCall(client)

            #expect(client.openTelemetry.propagation == true)
            #expect(route.traceparents == [tracingTraceparent, tracingTraceparent])
            #expect(propagator.injections > 0)
        }
    }

    @Test func propagationOffChangesOnlyTheHeaders() async throws {
        let propagator = TracingCountingPropagator()
        try await OpenTelemetry.withPropagator(propagator) {
            let (router, route) = tracingServer(retried: true)
            let provider = TracingStubProvider()
            let client = try tracingNewClient(router, openTelemetry: OpenTelemetryOptions(tracerProvider: provider, propagation: false))

            try await tracingTestCall(client, extraHeaders: ["traceparent": "own"])

            #expect(client.openTelemetry.propagation == false)
            #expect(route.traceparents == ["own", "own"])
            #expect(propagator.injections == 0)
            #expect(provider.spans.count == 1 && provider.spans[0].ended)
        }
    }

    /// A span that a sampler dropped stays the parent of the spans of an instrumented HTTP client.
    @Test func propagationOffKeepsADroppedSpanCurrent() async throws {
        let propagator = TracingCountingPropagator()
        try await OpenTelemetry.withPropagator(propagator) {
            let (router, route) = tracingServer(retried: true)
            let provider = TracingStubProvider(sampled: false)
            let client = try tracingNewClient(router, openTelemetry: OpenTelemetryOptions(tracerProvider: provider, propagation: false))

            try await tracingTestCall(client)

            #expect(route.traceparents == [nil, nil])
            #expect(propagator.injections == 0)
            try #require(provider.spans.count == 1)
            let context = provider.spans[0].context
            #expect(context.isValid && !context.traceFlags.isSampled)
            #expect(route.currentSpans == [context, context])
        }
    }

    /// Such a span is only there to be propagated.
    @Test func propagationOffDropsASpanWithoutAValidContext() async throws {
        let propagator = TracingCountingPropagator()
        try await OpenTelemetry.withPropagator(propagator) {
            let (router, route) = tracingServer(retried: true)
            let client = try tracingNewClient(router, openTelemetry: OpenTelemetryOptions(propagation: false))

            try await tracingTestCall(client)

            #expect(route.traceparents == [nil, nil])
            #expect(propagator.injections == 0)
            #expect(route.currentSpans.map(\.isValid) == [false, false])
        }
    }

    @Test(arguments: [
        ("FALSE", nil, false),
        ("0", nil, true),
        ("false", OpenTelemetryOptions(propagation: true), true),
        ("false", OpenTelemetryOptions(), true),
    ] as [(String, OpenTelemetryOptions?, Bool)])
    func propagationEnv(env: String, option: OpenTelemetryOptions?, propagation: Bool) async throws {
        let propagator = TracingCountingPropagator()
        try await OpenTelemetry.withPropagator(propagator) {
            let (router, route) = tracingServer(retried: true)
            // A provider is registered whose spans propagate whatever their tracer provider records.
            let client = try tracingNewClient(router, openTelemetry: option, environment: ["ANTHROPIC_OPEN_TELEMETRY_PROPAGATION": env])

            try await OpenTelemetry.withTracerProvider(TracingStubProvider()) { try await tracingTestCall(client) }

            #expect(client.openTelemetry.propagation == propagation)
            #expect(route.traceparents == (propagation ? [tracingTraceparent, tracingTraceparent] : [nil, nil]))
            #expect((propagator.injections > 0) == propagation)
        }
    }

    @Test func copyKeepsPropagation() throws {
        let client = try tracingNewClient(TracingRouter(), openTelemetry: OpenTelemetryOptions(propagation: false))
        #expect(try client.withOptions(maxRetries: 0).openTelemetry.propagation == false)
    }

    @Test func clientWithoutAnOptionReadsEveryEnv() throws {
        let client = try tracingNewClient(TracingRouter(), openTelemetry: nil, environment: tracingEveryEnv)
        let fromEnv = OpenTelemetryOptions(propagation: false, traces: OpenTelemetryTraces(enabled: false, contentMode: .content, maxContentBytes: 300))

        #expect(client.openTelemetry == fromEnv)
        #expect(try client.withOptions(maxRetries: 0).openTelemetry == fromEnv)
        #expect(try client.withOptions(openTelemetry: nil).openTelemetry == fromEnv)
        #expect(try client.copy().openTelemetry == fromEnv)
    }

    @Test(arguments: [
        (OpenTelemetryOptions(), tracingDefaults),
        (.disabled, OpenTelemetryOptions(propagation: true, traces: OpenTelemetryTraces(enabled: false, contentMode: .metadataOnly,
                                                                                         maxContentBytes: CONTENT_LIMIT))),
        (OpenTelemetryOptions(traces: true), tracingDefaults),
        (OpenTelemetryOptions(traces: OpenTelemetryTraces(contentMode: .metadataOnly)), tracingDefaults),
    ])
    func clientWithAnOptionReadsNoEnv(option: OpenTelemetryOptions, resolved: OpenTelemetryOptions) throws {
        #expect(try tracingNewClient(TracingRouter(), openTelemetry: option, environment: tracingEveryEnv).openTelemetry == resolved)
        #expect(try tracingNewClient(TracingRouter(), openTelemetry: nil, environment: tracingEveryEnv).withOptions(openTelemetry: option)
            .openTelemetry == resolved)
    }

    /// Python's provider that is not installed raises each time it is asked for a tracer: the client then has no spans.
    @Test func tracerProviderThatCannotGiveATracerLeavesAClientWithoutSpans() async throws {
        struct Unloadable: TracerProvider {
            func tracer(_ scope: String, version: String?) throws -> any Tracer { throw TracingTestError("not installed") }
        }
        try await OpenTelemetry.withTracerProvider(Unloadable()) {
            let (router, route) = tracingServer()
            let client = try tracingNewClient(router, openTelemetry: nil)

            for called in [client, try client.withOptions(maxRetries: 0), try client.copy()] {
                #expect(called.openTelemetry.traces?.enabled == true)
                try await tracingTestCall(called)
            }

            #expect(route.traceparents == [nil, nil, nil])
        }
    }

    @Test func givenTracerProviderIsAskedAtTheFirstCall() async throws {
        let provider = TracingStubProvider()
        let (router, _) = tracingServer()
        let client = try tracingNewClient(router, openTelemetry: nil).withOptions(openTelemetry: OpenTelemetryOptions(tracerProvider: provider))
        #expect(provider.tracers == 0)

        try await tracingTestCall(client)

        #expect(provider.tracers == 1)
    }

    /// `test_the_option_read_from_a_client_type_checks_as_an_option_of_a_copy`: what a client reads back is an option.
    @Test func theOptionReadFromAClientIsAnOptionOfACopy() throws {
        let client = try tracingNewClient(TracingRouter(), openTelemetry: OpenTelemetryOptions(traces: OpenTelemetryTraces(maxContentBytes: 4096)))
        let resolved = client.openTelemetry
        #expect(resolved.traces?.enabled == true && resolved.traces?.maxContentBytes == 4096)

        var option = resolved
        option.conversationID = "conv_1"
        let copy = try client.withOptions(openTelemetry: option)
        let rebuilt = try tracingNewClient(TracingRouter(), openTelemetry: resolved)

        #expect(copy.openTelemetry == option)
        #expect(rebuilt.openTelemetry == resolved)
    }
}

@Suite struct OpenTelemetryTracesOptionTests {
    @Test(arguments: [OpenTelemetryTraces(enabled: false), false, OpenTelemetryTraces(enabled: false, contentMode: .content, maxContentBytes: 100)])
    func disabledTracesHaveNoSpans(traces: OpenTelemetryTraces) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages", .json(tracingMessage))

        // The variable does not enable what the option disables.
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: traces), environment: ["ANTHROPIC_OPEN_TELEMETRY": "true"])
        try await tracingCreate(client)

        #expect(spans.finished.isEmpty)
        #expect(route.requests[0].headers["traceparent"] == nil)
        #expect(client.openTelemetry.traces?.enabled == false)
    }

    @Test(arguments: [true, OpenTelemetryTraces(enabled: true)] as [OpenTelemetryTraces])
    func enabledTracesHaveSpans(traces: OpenTelemetryTraces) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))

        // The variable is for a client that is given no option.
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: traces), environment: ["ANTHROPIC_OPEN_TELEMETRY": "false"])
        try await tracingCreate(client)

        #expect(spans.named("anthropic.messages.create").count == 1)
        #expect(client.openTelemetry.traces == tracingDefaultTraces)
    }

    @Test(arguments: [
        (OpenTelemetryOptions(), OpenTelemetryTraces()),
        (OpenTelemetryOptions(conversationID: "c"), OpenTelemetryTraces()),
        (OpenTelemetryOptions(traces: OpenTelemetryTraces()), OpenTelemetryTraces()),
        (OpenTelemetryOptions(traces: true), OpenTelemetryTraces()),
        (OpenTelemetryOptions(traces: OpenTelemetryTraces(maxContentBytes: 4096)), OpenTelemetryTraces(maxContentBytes: 4096)),
    ])
    func theVariablesDoNotReachAClientThatIsGivenTheOption(option: OpenTelemetryOptions, given: OpenTelemetryTraces) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        var withProvider = option
        withProvider.tracerProvider = spans.provider

        let client = try tracingClient(spans, router, openTelemetry: withProvider, environment: tracingEveryEnv)
        try await tracingCreate(client)

        // What the option leaves out has the default.
        #expect(client.openTelemetry.traces == OpenTelemetryTraces(enabled: true, contentMode: .metadataOnly,
                                                                   maxContentBytes: given.maxContentBytes ?? CONTENT_LIMIT))
        #expect(client.openTelemetry.propagation == true)
        #expect(try spans.one("anthropic.messages.create")["gen_ai.input.messages"] == nil)
    }

    @Test func theVariablesDoNotReachAClientThatIsGivenFalse() throws {
        let env = tracingEveryEnv.merging(["ANTHROPIC_OPEN_TELEMETRY": "true"]) { $1 }
        let client = try tracingNewClient(TracingRouter(), openTelemetry: .disabled, environment: env)
        var traces = tracingDefaultTraces
        traces.enabled = false
        #expect(client.openTelemetry == OpenTelemetryOptions(propagation: true, traces: traces))
    }

    @Test func theVariablesDoNotReachAPlatformClientThatIsGivenTheOption() throws {
        let spans = TracingSpans()
        let options: [(OpenTelemetryOptions, OpenTelemetryTraces)] = [
            (OpenTelemetryOptions(), OpenTelemetryTraces()), (spans.option(), OpenTelemetryTraces()),
            (OpenTelemetryOptions(traces: OpenTelemetryTraces(maxContentBytes: 4096)), OpenTelemetryTraces(maxContentBytes: 4096)),
        ]
        for (option, given) in options {
            for (platform, client) in try TracingPlatform.clients(option, environment: tracingEveryEnv) {
                // A copy that is given its own option is resolved as a new client is.
                for resolved in [client.openTelemetry, try platform.copy(client, option).openTelemetry] {
                    #expect(resolved.propagation == true)
                    #expect(resolved.traces == OpenTelemetryTraces(enabled: true, contentMode: .metadataOnly,
                                                                   maxContentBytes: given.maxContentBytes ?? CONTENT_LIMIT))
                }
            }
        }
        var off = tracingDefaultTraces
        off.enabled = false
        for (_, client) in try TracingPlatform.clients(.disabled, environment: tracingEveryEnv) {
            #expect(client.openTelemetry == OpenTelemetryOptions(propagation: true, traces: off))
        }
    }

    @Test(arguments: ["option", "variable"])
    func maxContentBytesIsTheSizeBound(source: String) async throws {
        let registered = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        try await OpenTelemetry.withTracerProvider(registered.provider) {
            let bounded = source == "option"
                ? try tracingClient(nil, router, openTelemetry: OpenTelemetryOptions(traces: OpenTelemetryTraces(contentMode: .content, maxContentBytes: 300)),
                                    environment: ["ANTHROPIC_OPEN_TELEMETRY_TRACES_MAX_CONTENT_BYTES": "100000"])
                : try tracingClient(nil, router, openTelemetry: .some(nil), environment: [
                    "ANTHROPIC_OPEN_TELEMETRY_TRACES_CONTENT_MODE": "content", "ANTHROPIC_OPEN_TELEMETRY_TRACES_MAX_CONTENT_BYTES": "300",
                ])
            #expect(bounded.openTelemetry.traces?.maxContentBytes == 300)

            try await tracingCreate(bounded, messages: tracingOldAndNew)
            try await tracingCreate(try tracingClient(nil, router, openTelemetry: OpenTelemetryOptions(traces: OpenTelemetryTraces(contentMode: .content))),
                                    messages: tracingOldAndNew)
        }

        let calls = registered.named("anthropic.messages.create")
        try #require(calls.count == 2)
        let (cut, whole) = (calls[0], calls[1])
        // The oldest part goes, as it does over the default bound.
        #expect(cut.json("gen_ai.input.messages")?.arrayValue?.map { $0["parts"]! } == [[], [tracingTextPart("new")]])
        #expect(cut["anthropic.content.truncated"] == true)
        #expect(cut.contentSize <= 300)
        #expect(whole.json("gen_ai.input.messages")?.arrayValue?.map { $0["parts"]!.arrayValue!.count } == [1, 1])
        #expect(whole["anthropic.content.truncated"] == nil)
    }

    @Test(arguments: [false, true])
    func maxContentBytesBoundsAStreamedMessageToo(beta: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()))
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: OpenTelemetryTraces(contentMode: .content, maxContentBytes: 300)))

        if beta {
            try await client.beta.messages.stream(maxTokens: 1024, messages: tracingBetaMessages(tracingOldAndNew), model: "claude-test").untilDone()
        } else {
            try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingOldAndNew), model: "claude-test").untilDone()
        }

        let span = try spans.one("anthropic.messages.create")
        #expect(span.json("gen_ai.input.messages")?.arrayValue?.map { $0["parts"]! } == [[], [tracingTextPart("new")]])
        #expect(span.json("gen_ai.output.messages")?[0]?["parts"] == [tracingTextPart("Hi there")])
        #expect(span["anthropic.content.truncated"] == true)
        #expect(span.contentSize <= 300)
    }

    @Test(arguments: ["", " ", "0", "-5", "+5", "1.5", "many", "1e3", "1_000", "3 00", "\u{0663}\u{0660}\u{0660}", String(repeating: "9", count: 5000)])
    func aMaxContentBytesVariableThatIsNotValidIsIgnored(value: String) async throws {
        let registered = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let client = try tracingClient(nil, router, openTelemetry: .some(nil), environment: [
            "ANTHROPIC_OPEN_TELEMETRY_TRACES_CONTENT_MODE": "content", "ANTHROPIC_OPEN_TELEMETRY_TRACES_MAX_CONTENT_BYTES": value,
        ])
        try await OpenTelemetry.withTracerProvider(registered.provider) { try await tracingCreate(client, messages: tracingOldAndNew) }

        #expect(client.openTelemetry.traces?.maxContentBytes == CONTENT_LIMIT)
        #expect(try registered.one("anthropic.messages.create")["anthropic.content.truncated"] == nil)
    }

    @Test(arguments: ["300", " 300 ", "\t300\n", "0300"])
    func aMaxContentBytesVariableIsDecimalDigitsWithOrWithoutWhitespaceAroundThem(value: String) throws {
        let client = try tracingNewClient(TracingRouter(), openTelemetry: nil, environment: ["ANTHROPIC_OPEN_TELEMETRY_TRACES_MAX_CONTENT_BYTES": value])
        #expect(client.openTelemetry.traces?.maxContentBytes == 300)
    }

    @Test(arguments: [(0, CONTENT_LIMIT), (-1, CONTENT_LIMIT), (1, 1)])
    func aMaxContentBytesOptionBelow1IsTheDefault(given: Int, resolved: Int) throws {
        // The variable is for a client that is given no option, so it does not stand in for the option.
        let client = try tracingNewClient(TracingRouter(), openTelemetry: OpenTelemetryOptions(traces: OpenTelemetryTraces(maxContentBytes: given)),
                                          environment: ["ANTHROPIC_OPEN_TELEMETRY_TRACES_MAX_CONTENT_BYTES": "4096"])
        #expect(client.openTelemetry.traces?.maxContentBytes == resolved)
    }

    @Test func theVariablesAreReadUnderTheirTracesNamesOnly() throws {
        let router = TracingRouter()
        let former = ["ANTHROPIC_OPEN_TELEMETRY_CONTENT_MODE": "content", "ANTHROPIC_OPEN_TELEMETRY_MAX_CONTENT_BYTES": "300"]
        #expect(try tracingNewClient(router, openTelemetry: nil, environment: former).openTelemetry == tracingDefaults)

        let env = ["ANTHROPIC_OPEN_TELEMETRY_TRACES_CONTENT_MODE": "content", "ANTHROPIC_OPEN_TELEMETRY_TRACES_MAX_CONTENT_BYTES": "300"]
        #expect(try tracingNewClient(router, openTelemetry: nil, environment: env).openTelemetry
            == OpenTelemetryOptions(propagation: true, traces: OpenTelemetryTraces(enabled: true, contentMode: .content, maxContentBytes: 300)))
        // An empty option is an option.
        #expect(try tracingNewClient(router, openTelemetry: OpenTelemetryOptions(), environment: env).openTelemetry == tracingDefaults)
    }
}

let tracingTraceContextHeaders = ["traceparent", "tracestate", "baggage"]

@Suite struct OpenTelemetryPropagationOptionTests {
    @Test(arguments: ["recording", "no_op"])
    func requestsCarryTheTraceContextByDefault(provider: String) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages", .json(tracingMessage))
        let option = provider == "recording" ? spans.option() : OpenTelemetryOptions(tracerProvider: NoOpTracerProvider())
        let client = try tracingClient(spans, router, openTelemetry: option)

        try await tracingApplicationContext { _ in try await tracingCreate(client) }

        let request = try #require(route.requests.first)
        #expect(client.openTelemetry.propagation == true)
        #expect(request.headers["baggage"] == "tenant=acme")
        #expect(request.headers["tracestate"] == "vendor=value")
        if provider == "recording" {
            let call = try spans.one("anthropic.messages.create")
            #expect(request.headers["traceparent"] == "00-\(TraceID(low: 0x1234).hex)-\(call.spanID.hex)-01")
        } else {
            #expect(request.headers["traceparent"] == "00-\(TraceID(low: 0x1234).hex)-\(SpanID(0x5678).hex)-01")
        }
    }

    @Test(arguments: ["recording", "no_op"])
    func falseSendsNoTraceContextAndKeepsTheSpan(provider: String) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages", .json([:], status: 500), .json(tracingMessage))
        var option = provider == "recording" ? spans.option() : OpenTelemetryOptions(tracerProvider: NoOpTracerProvider())
        option.propagation = false
        let client = try tracingClient(spans, router, openTelemetry: option, maxRetries: 1)

        let propagator = try await tracingApplicationContext { propagator in
            try await tracingCreate(client)
            return propagator
        }

        // The retry carries none either, and the SDK does not ask the propagator for anything.
        #expect(route.requests.count == 2)
        for request in route.requests { #expect(tracingTraceContextHeaders.filter { request.headers[$0] != nil } == []) }
        #expect(propagator.injections == 0)
        #expect(client.openTelemetry.propagation == false)
        if provider == "recording" {
            let call = try spans.one("anthropic.messages.create")
            #expect(call.statusCode == .ok)
            #expect(call.endTime != nil)
            #expect(call.traceID == TraceID(low: 0x1234))
            #expect(call["http.request.resend_count"] == 1)
        }
    }

    @Test func falseKeepsASpanThatTheSamplerDroppedCurrentForTheRequests() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages", .json([:], status: 500), .json(tracingMessage))
        let ids = TracingKeptSpanIDs()
        let dropping = SDKTracerProvider(sampler: AlwaysOffSampler(), idGenerator: ids)
        let client = try tracingClient(spans, router, openTelemetry: OpenTelemetryOptions(tracerProvider: dropping, propagation: false), maxRetries: 1)

        let propagator = try await tracingApplicationContext { propagator in
            try await tracingCreate(client)
            return propagator
        }

        // Both requests ran under the call span, which carries the sampler's decision and is not the application's span.
        try #require(ids.spanIDs.count == 1)
        let callSpanID = ids.spanIDs[0]
        #expect(callSpanID != SpanID(0x5678))
        let expected = SpanContext(traceID: TraceID(low: 0x1234), spanID: callSpanID, traceFlags: .default,
                                   traceState: TraceState([("vendor", "value")]))
        #expect(route.currentSpans.map { [$0.traceID == expected.traceID, $0.spanID == expected.spanID, $0.traceFlags == .default, $0.isValid] }
            == [[true, true, true, true], [true, true, true, true]])
        // The SDK still writes nothing itself, and does not ask the propagator for anything.
        for request in route.requests { #expect(tracingTraceContextHeaders.filter { request.headers[$0] != nil } == []) }
        #expect(propagator.injections == 0)

        // With no tracer provider and no span of the application, the call span has no valid context and is not current.
        try await tracingCreate(try tracingClient(spans, router, openTelemetry: OpenTelemetryOptions(tracerProvider: NoOpTracerProvider(),
                                                                                                    propagation: false)))
        #expect(route.currentSpans.last?.isValid == false)
    }

    @Test(arguments: [
        ("false", nil, false), ("FALSE", nil, false), ("true", nil, true), ("0", nil, true), ("", nil, true),
        // The variable is for a client that is given no option.
        ("false", OpenTelemetryOptions(), true), ("false", OpenTelemetryOptions(traces: true), true),
        ("false", OpenTelemetryOptions(propagation: true), true), ("true", OpenTelemetryOptions(propagation: false), false),
    ] as [(String, OpenTelemetryOptions?, Bool)])
    func theVariableSetsPropagationForAClientThatIsGivenNoOption(variable: String, option: OpenTelemetryOptions?, propagates: Bool) async throws {
        let registered = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages", .json(tracingMessage))
        let client = try tracingClient(nil, router, openTelemetry: .some(option), environment: ["ANTHROPIC_OPEN_TELEMETRY_PROPAGATION": variable])

        try await OpenTelemetry.withTracerProvider(registered.provider) {
            try await tracingApplicationContext { _ in
                try await tracingCreate(client)
                try await tracingCreate(try client.copy())
            }
        }

        #expect(client.openTelemetry.propagation == propagates)
        for request in route.requests { #expect(tracingTraceContextHeaders.map { request.headers[$0] != nil } == [propagates, propagates, propagates]) }
        #expect(registered.named("anthropic.messages.create").count == 2)
    }

    @Test func disabledOpenTelemetrySendsNoTraceContext() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages", .json(tracingMessage))

        let propagator = try await tracingApplicationContext { propagator in
            try await tracingCreate(try tracingClient(spans, router, openTelemetry: .disabled))
            try await tracingCreate(try tracingClient(spans, router, openTelemetry: spans.option(propagation: true, traces: false)))
            return propagator
        }

        for request in route.requests { #expect(tracingTraceContextHeaders.filter { request.headers[$0] != nil } == []) }
        #expect(propagator.injections == 0)
        #expect(spans.finished.isEmpty)
    }

    @Test func withOptionsReplacesPropagationWithTheRestOfTheOption() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages", .json(tracingMessage))
        let client = try tracingClient(spans, router, openTelemetry: spans.option(propagation: false))
        var option = client.openTelemetry
        option.conversationID = "conv_1"
        let spread = try client.withOptions(openTelemetry: option)
        let replaced = try client.withOptions(openTelemetry: spans.option())

        try await tracingApplicationContext { _ in
            for called in [client, try client.copy(), spread, replaced] { try await tracingCreate(called) }
        }

        #expect(route.requests.map { [$0.headers["baggage"] != nil, $0.headers["traceparent"] != nil] }
            == [[false, false], [false, false], [false, false], [true, true]])
        #expect([spread.openTelemetry.propagation, replaced.openTelemetry.propagation] == [false, true])
        #expect(spans.named("anthropic.messages.create")[2]["gen_ai.conversation.id"] == "conv_1")
    }

    @Test func platformClientsHaveTheOption() throws {
        let spans = TracingSpans()
        let fromVariable = try TracingPlatform.clients(nil, environment: ["ANTHROPIC_OPEN_TELEMETRY_PROPAGATION": "false"])
        let fromOption = try TracingPlatform.clients(spans.option(propagation: false))

        for (platform, client) in fromVariable + fromOption {
            #expect(client.openTelemetry.propagation == false)
            #expect(try platform.copy(client, nil).openTelemetry.propagation == false)
        }
        #expect(try TracingPlatform.clients(spans.option()).allSatisfy { $0.1.openTelemetry.propagation == true })
    }

    @Test func signedRequestWithoutPropagationKeepsTheApplicationsHeader() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "*", .json(tracingMessage))
        // The SDK leaves the header of the application alone, so it is signed and sent as it was given.
        let traceparent = "00-\(TraceID(low: 0xABCD).hex)-\(SpanID(0xEF).hex)-01"

        try await tracingApplicationContext { _ in
            try await tracingCreate(try tracingBedrock(router, spans.option(propagation: false)), extraHeaders: ["traceparent": .value(traceparent)])
        }

        let request = try #require(route.requests.first)
        #expect(request.headers["traceparent"] == traceparent)
        #expect(request.headers["baggage"] == nil && request.headers["tracestate"] == nil)
        let authorization = try #require(request.headers["Authorization"])
        #expect(authorization.components(separatedBy: "SignedHeaders=")[1].split(separator: ",")[0].split(separator: ";").contains("traceparent"))
        #expect(try spans.one("anthropic.messages.create").statusCode == .ok)
    }
}

@Suite struct OpenTelemetryConversationIDTests {
    @Test func clientOption() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        router.route("GET", "/v1/models", .json(["data": [], "has_more": false, "first_id": nil, "last_id": nil]))
        let client = try tracingClient(spans, router, openTelemetry: spans.option(conversationID: "conv_1"))

        try await tracingCreate(client)
        _ = try await client.models.list()

        #expect(try spans.one("anthropic.messages.create")["gen_ai.conversation.id"] == "conv_1")
        #expect(try spans.one("anthropic.models.list")["gen_ai.conversation.id"] == "conv_1")
    }

    /// `THREAD_CALLS`: each method whose path has a Session thread's ID, and its span's name.
    static let threadCalls: [(String, TracingInvoke)] = [
        ("anthropic.sessions.threads.retrieve", { _ = try await $0.beta.sessions.threads.retrieve("sthr_1", sessionID: "sesn_1") }),
        ("anthropic.sessions.threads.archive", { _ = try await $0.beta.sessions.threads.archive("sthr_1", sessionID: "sesn_1") }),
        ("anthropic.sessions.threads.events.list", { _ = try await $0.beta.sessions.threads.events.list("sthr_1", sessionID: "sesn_1") }),
        ("anthropic.sessions.threads.events.stream", { try await $0.beta.sessions.threads.events.stream("sthr_1", sessionID: "sesn_1").close() }),
    ]

    /// `mock_session_routes`.
    static func sessionRouter() -> TracingRouter {
        let router = TracingRouter()
        let thread: JSONValue = ["id": "sthr_1", "type": "session_thread"]
        let page: JSONValue = ["data": [], "next_page": nil]
        router.route("GET", "/v1/sessions/sesn_1", .json(["id": "sesn_1"]))
        router.route("GET", "/v1/sessions/sesn_1/threads", .json(page))
        router.route("GET", "/v1/sessions/sesn_1/threads/sthr_1", .json(thread))
        router.route("POST", "/v1/sessions/sesn_1/threads/sthr_1/archive", .json(thread))
        router.route("GET", "/v1/sessions/sesn_1/threads/sthr_1/events", .json(page))
        router.route("GET", "/v1/sessions/sesn_1/threads/sthr_1/stream", .bytes(tracingSSE([]), headers: ["content-type": "text/event-stream"]))
        return router
    }

    @Test(arguments: 0..<4)
    func aSessionThreadsSpanStartsWithTheThreadsIDAsTheConversations(call: Int) async throws {
        let (name, invoke) = Self.threadCalls[call]
        let sampler = TracingStartAttributes()
        let client = try tracingClient(nil, Self.sessionRouter(), openTelemetry: OpenTelemetryOptions(tracerProvider: SDKTracerProvider(sampler: sampler)))

        _ = try? await invoke(client)

        // Both are there when the span starts, so a sampler sees them.
        try #require(sampler.started.count == 1)
        #expect(sampler.started[0].0 == name)
        #expect(sampler.started[0].1["anthropic.session.thread.id"] == "sthr_1")
        #expect(sampler.started[0].1["gen_ai.conversation.id"] == "sthr_1")
    }

    @Test(arguments: 0..<4)
    func theApplicationsConversationIDGoesBeforeASessionThreads(call: Int) async throws {
        let (name, invoke) = Self.threadCalls[call]
        let spans = TracingSpans()
        let client = try tracingClient(spans, Self.sessionRouter(), openTelemetry: spans.option(conversationID: "conv_1"))

        _ = try? await invoke(client)

        let span = try spans.one(name)
        #expect(span["gen_ai.conversation.id"] == "conv_1")
        #expect(span["anthropic.session.thread.id"] == "sthr_1")
    }

    @Test func aSpanWithoutASessionThreadInItsPathHasNoConversationIDOfItsOwn() async throws {
        let spans = TracingSpans()
        let client = try tracingClient(spans, Self.sessionRouter())

        _ = try? await client.beta.sessions.retrieve("sesn_1")
        _ = try? await client.beta.sessions.threads.list("sesn_1")

        for name in ["anthropic.sessions.retrieve", "anthropic.sessions.threads.list"] {
            #expect(try spans.one(name)["anthropic.session.id"] == "sesn_1")
            #expect(try spans.one(name)["gen_ai.conversation.id"] == nil)
        }
    }

    @Test func withOptionsReplacesTheClientsWholeOption() async throws {
        let spans = TracingSpans()
        let other = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: OpenTelemetryTraces(contentMode: .content), conversationID: "conv_1"))

        // A copy has what it is given and nothing of the client's: no content mode, no conversation ID, no provider.
        try await tracingCreate(try client.withOptions(openTelemetry: spans.option()))
        try await tracingCreate(try client.copy(openTelemetry: spans.option(conversationID: "conv_2")))
        try await tracingCreate(try client.withOptions(openTelemetry: other.option()))
        try await tracingCreate(client)

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 3)
        let (bare, renamed, own) = (calls[0], calls[1], calls[2])
        #expect(bare["gen_ai.conversation.id"] == nil)
        #expect(renamed["gen_ai.conversation.id"] == "conv_2")
        for span in [bare, renamed, try other.one("anthropic.messages.create")] { #expect(span["gen_ai.input.messages"] == nil) }
        // The client keeps its own option.
        #expect(own["gen_ai.conversation.id"] == "conv_1")
        #expect(own["gen_ai.input.messages"] != nil)
    }

    @Test func withOptionsReplacesTracesWholeToo() throws {
        let spans = TracingSpans()
        let client = try tracingClient(spans, TracingRouter(), openTelemetry: spans.option(traces: OpenTelemetryTraces(contentMode: .content, maxContentBytes: 100)))

        let copy = try client.withOptions(openTelemetry: OpenTelemetryOptions(traces: OpenTelemetryTraces(maxContentBytes: 200)))

        #expect(copy.openTelemetry == OpenTelemetryOptions(propagation: true, traces: OpenTelemetryTraces(enabled: true, contentMode: .metadataOnly,
                                                                                                          maxContentBytes: 200)))
        #expect(client.openTelemetry == spans.option(propagation: true, traces: OpenTelemetryTraces(enabled: true, contentMode: .content,
                                                                                                     maxContentBytes: 100)))
    }

    @Test func aCopyThatIsNotGivenTheOptionHasTheClients() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: OpenTelemetryTraces(contentMode: .content), conversationID: "conv_1"))

        for copy in [try client.copy(), try client.withOptions(timeout: 5), try client.copy().withOptions(maxRetries: 1)] {
            #expect(copy.openTelemetry == client.openTelemetry)
            try await tracingCreate(copy)
        }

        let created = spans.named("anthropic.messages.create")
        #expect(created.map { $0["gen_ai.conversation.id"] } == ["conv_1", "conv_1", "conv_1"])
        #expect(created.allSatisfy { $0["gen_ai.input.messages"] != nil })
    }

    @Test func aCopyThatChangesOneFieldStartsFromTheOptionReadFromTheClient() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: OpenTelemetryTraces(contentMode: .content, maxContentBytes: 4096)))
        #expect(client.openTelemetry == spans.option(propagation: true, traces: OpenTelemetryTraces(enabled: true, contentMode: .content,
                                                                                                     maxContentBytes: 4096)))

        var option = client.openTelemetry
        option.conversationID = "conv_1"
        let copy = try client.withOptions(openTelemetry: option)
        #expect(copy.openTelemetry == option)
        try await tracingCreate(copy)
        try await tracingCreate(client)

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        #expect(calls[0]["gen_ai.conversation.id"] == "conv_1")
        #expect(calls[1]["gen_ai.conversation.id"] == nil)
        for span in calls { #expect(span.json("gen_ai.output.messages")?[0]?["parts"] == [["type": "text", "content": "Hi there"]]) }
    }

    @Test func theOptionReadFromAClientIsACopy() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: true))
        let before = client.openTelemetry

        var read = client.openTelemetry
        read.conversationID = "conv_1"
        read.traces?.enabled = false
        read.traces?.contentMode = .content
        try await tracingCreate(client)
        try await tracingCreate(try client.copy())

        #expect(client.openTelemetry == before)
        for span in spans.named("anthropic.messages.create") {
            #expect(span["gen_ai.conversation.id"] == nil)
            #expect(span["gen_ai.input.messages"] == nil)
        }
        #expect(spans.finished.count == 2)
    }

    @Test(arguments: [
        (nil, OpenTelemetryTraces(enabled: true, contentMode: .metadataOnly, maxContentBytes: CONTENT_LIMIT)),
        (OpenTelemetryOptions(), OpenTelemetryTraces(enabled: true, contentMode: .metadataOnly, maxContentBytes: CONTENT_LIMIT)),
        (.disabled, OpenTelemetryTraces(enabled: false, contentMode: .metadataOnly, maxContentBytes: CONTENT_LIMIT)),
        (OpenTelemetryOptions(traces: true), OpenTelemetryTraces(enabled: true, contentMode: .metadataOnly, maxContentBytes: CONTENT_LIMIT)),
        (OpenTelemetryOptions(traces: OpenTelemetryTraces(contentMode: .content)),
         OpenTelemetryTraces(enabled: true, contentMode: .content, maxContentBytes: CONTENT_LIMIT)),
        (OpenTelemetryOptions(traces: OpenTelemetryTraces(enabled: false, maxContentBytes: 10)),
         OpenTelemetryTraces(enabled: false, contentMode: .metadataOnly, maxContentBytes: 10)),
    ] as [(OpenTelemetryOptions?, OpenTelemetryTraces)])
    func theOptionReadFromAClientHasEveryFieldOfTraces(given: OpenTelemetryOptions?, traces: OpenTelemetryTraces) throws {
        let client = try tracingNewClient(TracingRouter(), openTelemetry: given)
        let resolved = OpenTelemetryOptions(propagation: true, traces: traces)
        #expect(client.openTelemetry == resolved)
        // It is an option like another: a client that is given it reads back the same.
        #expect(try client.withOptions(openTelemetry: client.openTelemetry).openTelemetry == resolved)
    }

    @Test func streamAndParseHelpersHaveTheClients() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()), .sse(tracingStreamEvents()), .json(tracingMessage))
        let client = try tracingClient(spans, router).withOptions(openTelemetry: spans.option(conversationID: "conv_1"))

        try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test").untilDone()
        try await client.beta.messages.stream(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test").untilDone()
        _ = try await client.beta.messages.parse(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test")

        let calls = spans.named("anthropic.messages.create")
        #expect(calls.count == 3)
        for span in calls { #expect(span["gen_ai.conversation.id"] == "conv_1") }
    }

    @Test func aClientWithoutSpansReadsBackAnOptionWithoutThem() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let quiet = try tracingClient(spans, router, openTelemetry: .disabled)

        // So a copy that starts from that option stays without spans, whatever else it sets.
        var own = quiet.openTelemetry
        own.conversationID = "conv_1"
        try await tracingCreate(try quiet.withOptions(openTelemetry: own))
        var withProvider = quiet.openTelemetry
        withProvider.tracerProvider = spans.provider
        try await tracingCreate(try quiet.copy(openTelemetry: withProvider))
        #expect(spans.finished.isEmpty)

        // A copy that is given another option has that one alone.
        try await tracingCreate(try quiet.withOptions(openTelemetry: spans.option(conversationID: "conv_1")))
        #expect(spans.named("anthropic.messages.create").count == 1)
    }

    @Test func withOptionsFalseAndEmptyReplaceTheClientsOption() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let client = try tracingClient(spans, router, openTelemetry: spans.option(conversationID: "conv_1"))

        try await tracingCreate(try client.withOptions(openTelemetry: .disabled))
        #expect(try client.withOptions(openTelemetry: .disabled).openTelemetry.traces?.enabled == false)

        // This copy has no tracer provider of its own left, so its spans go to the registered one.
        let copy = try client.withOptions(openTelemetry: OpenTelemetryOptions())
        #expect(copy.openTelemetry.tracerProvider == nil)
        #expect(copy.openTelemetry.conversationID == nil)
        try await tracingCreate(copy)
        #expect(spans.finished.isEmpty)

        try await tracingCreate(try client.withOptions(timeout: 5))
        #expect(try spans.one("anthropic.messages.create")["gen_ai.conversation.id"] == "conv_1")
    }

    @Test func platformClientsReplaceTheWholeOptionToo() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "*", .json(tracingMessage))
        let option = spans.option(traces: OpenTelemetryTraces(contentMode: .content), conversationID: "conv_0")

        for (platform, client) in try TracingPlatform.clients(option, router: router) {
            let replaced = try platform.copy(client, spans.option(conversationID: "conv_1"))
            var spreadOption = client.openTelemetry
            spreadOption.conversationID = "conv_1"
            let spread = try platform.copy(client, spreadOption)
            #expect(type(of: replaced) == type(of: client) && type(of: spread) == type(of: client))

            spans.exporter.clear()
            for called in [client, replaced, spread, try platform.copy(spread, nil), try platform.copy(spread, .disabled)] {
                try await tracingCreate(called)
            }

            let calls = spans.named("anthropic.messages.create")
            try #require(calls.count == 4)
            let (own, bare, kept, copied) = (calls[0], calls[1], calls[2], calls[3])
            #expect(own["gen_ai.conversation.id"] == "conv_0")
            #expect(own["gen_ai.input.messages"] != nil)
            #expect(bare["gen_ai.conversation.id"] == "conv_1")
            #expect(bare["gen_ai.input.messages"] == nil)
            for span in [kept, copied] {
                #expect(span["gen_ai.conversation.id"] == "conv_1")
                #expect(span["gen_ai.input.messages"] != nil)
            }
            for span in [bare, kept, copied] { #expect(span["gen_ai.provider.name"] == own["gen_ai.provider.name"]) }
        }
    }

    @Test func platformClientsWithoutSpansReadBackAnOptionWithoutThem() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "*", .json(tracingMessage))
        let clients = try TracingPlatform.clients(spans.option(traces: false), router: router)

        for (platform, client) in clients {
            var option = client.openTelemetry
            option.conversationID = "conv_1"
            try await tracingCreate(try platform.copy(client, option))
        }
        #expect(spans.finished.isEmpty)

        for (platform, client) in clients { try await tracingCreate(try platform.copy(client, spans.option(traces: true))) }
        #expect(spans.named("anthropic.messages.create").count == clients.count)
    }

    @Test func environmentIsReadWhenTheClientIsConstructed() async throws {
        let registered = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let verbose = try tracingClient(nil, router, openTelemetry: .some(nil), environment: [
            "ANTHROPIC_OPEN_TELEMETRY_TRACES_CONTENT_MODE": "content", "ANTHROPIC_OPEN_TELEMETRY_TRACES_MAX_CONTENT_BYTES": "4096",
        ])
        let quiet = try tracingClient(nil, router, openTelemetry: .some(nil), environment: ["ANTHROPIC_OPEN_TELEMETRY": "false"])
        #expect(verbose.openTelemetry.traces == OpenTelemetryTraces(enabled: true, contentMode: .content, maxContentBytes: 4096))
        #expect(quiet.openTelemetry.traces?.enabled == false)

        try await OpenTelemetry.withTracerProvider(registered.provider) {
            // Neither the clients, nor their copies that are given no option, nor those that start from the client's own read it again.
            var quietOption = quiet.openTelemetry
            quietOption.conversationID = "c"
            for client in [quiet, try quiet.withOptions(timeout: 5), try quiet.copy(openTelemetry: quietOption)] { try await tracingCreate(client) }
            #expect(registered.finished.isEmpty)

            var verboseOption = verbose.openTelemetry
            verboseOption.conversationID = "c"
            for client in [verbose, try verbose.withOptions(timeout: 5), try verbose.copy(openTelemetry: verboseOption)] {
                #expect(client.openTelemetry.traces == verbose.openTelemetry.traces)
                try await tracingCreate(client)
            }
            let created = registered.named("anthropic.messages.create")
            #expect(created.count == 3)
            #expect(created.allSatisfy { $0["gen_ai.input.messages"] != nil })

            // A copy that is given another option is resolved as a new client is, and does not read the environment.
            try await tracingCreate(try verbose.withOptions(openTelemetry: OpenTelemetryOptions()))
            #expect(registered.named("anthropic.messages.create")[3]["gen_ai.input.messages"] == nil)
            // `nil` is no option, so the copy has the client's own.
            try await tracingCreate(try verbose.withOptions(openTelemetry: nil))
            #expect(registered.named("anthropic.messages.create")[4]["gen_ai.input.messages"] != nil)
        }
    }

    @Test func aCopyThatIsGivenNoneKeepsTheClientsOption() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))

        let quiet = try tracingClient(spans, router, openTelemetry: .disabled)
        for copy in [try quiet.withOptions(openTelemetry: nil), try quiet.copy(openTelemetry: nil)] {
            #expect(copy.openTelemetry == quiet.openTelemetry)
            try await tracingCreate(copy)
        }
        #expect(spans.finished.isEmpty)

        let verbose = try tracingClient(spans, router, openTelemetry: spans.option(traces: OpenTelemetryTraces(contentMode: .content), conversationID: "c"))
        #expect(try verbose.withOptions(openTelemetry: nil).openTelemetry == verbose.openTelemetry)
    }

    @Test func aCopyOfAPlatformClientThatIsGivenNoneKeepsTheClientsOption() throws {
        let spans = TracingSpans()
        let option = spans.option(propagation: false, traces: OpenTelemetryTraces(contentMode: .content), conversationID: "c")
        let fromVariable = try TracingPlatform.clients(nil, environment: ["ANTHROPIC_OPEN_TELEMETRY_TRACES_MAX_CONTENT_BYTES": "300"])

        for (platform, client) in try TracingPlatform.clients(.disabled) + TracingPlatform.clients(option) + fromVariable {
            let copy = try platform.copy(client, nil)
            #expect(type(of: copy) == type(of: client))
            #expect(copy.openTelemetry == client.openTelemetry)
        }
        #expect(fromVariable.allSatisfy { $0.1.openTelemetry.traces?.maxContentBytes == 300 })
    }

    @Test func platformClientsReadTheEnvironmentWhenTheyAreConstructed() async throws {
        let registered = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "*", .json(tracingMessage))
        let verbose = try TracingPlatform.clients(nil, environment: ["ANTHROPIC_OPEN_TELEMETRY_TRACES_CONTENT_MODE": "content"], router: router)
        let quiet = try TracingPlatform.clients(nil, environment: ["ANTHROPIC_OPEN_TELEMETRY": "false"], router: router)

        try await OpenTelemetry.withTracerProvider(registered.provider) {
            for (platform, client) in quiet {
                var option = client.openTelemetry
                option.conversationID = "conv_1"
                for copy in [try platform.copy(client, nil), try platform.copy(client, option)] { try await tracingCreate(copy) }
            }
            #expect(registered.finished.isEmpty)

            for (platform, client) in verbose {
                var option = client.openTelemetry
                option.conversationID = "conv_1"
                for copy in [try platform.copy(client, nil), try platform.copy(client, option)] { try await tracingCreate(copy) }
            }
            let created = registered.named("anthropic.messages.create")
            #expect(created.count == 2 * verbose.count)
            #expect(created.allSatisfy { $0["gen_ai.input.messages"] != nil })
        }
    }

    @Test(arguments: 0..<6)
    func platformClientSpansHaveThePlatformInTheirScope(index: Int) async throws {
        let platform = TracingPlatform.all[index]
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "*", .json(tracingMessage))
        let client = try platform.make(spans.option(traces: OpenTelemetryTraces(contentMode: .content)), [:], router)

        // A copy keeps its client's resolved option, and its tracer has the scope of the platform too.
        var option = client.openTelemetry
        option.conversationID = "conv_1"
        for called in [client, try platform.copy(client, nil), try platform.copy(client, option)] { try await tracingCreate(called) }
        try await tracingCreate(try platform.make(.disabled, [:], router))

        let created = spans.named("anthropic.messages.create")
        #expect(created.map(\.instrumentationScope) == Array(repeating: InstrumentationScope(name: "com.anthropic.sdk.swift.\(platform.platform)",
                                                                                              version: client.version), count: 3))
        #expect(created.allSatisfy { $0["gen_ai.input.messages"] != nil })
        #expect(created.map { $0["gen_ai.conversation.id"] != nil } == [false, false, true])
    }

    @Test func platformClientSpan() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "*", .json(tracingMessage))
        let vertex = try tracingVertex(router, spans.option())
        var option = vertex.openTelemetry
        option.conversationID = "conv_1"

        try await tracingCreate(try vertex.withOptions(openTelemetry: option))

        let span = try spans.one("anthropic.messages.create")
        #expect(span["gen_ai.conversation.id"] == "conv_1")
        #expect(span["gen_ai.provider.name"] == "gcp.vertex_ai")
    }
}
