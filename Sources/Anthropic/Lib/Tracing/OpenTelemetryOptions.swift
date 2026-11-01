import Foundation

// Port of the `open_telemetry` client option (`_types.OpenTelemetryOptions`) and of its resolution
// (`_tracing.resolve_open_telemetry`, `env_open_telemetry`) and `lib/_tracing/_config.py`.

/// Whether a client's spans have the content of its requests and responses.
public enum OpenTelemetryContentMode: String, Sendable, Hashable {
    case metadataOnly = "metadata_only"
    case content
}

/// The `traces` field of the `openTelemetry` client option: the client's spans.
///
/// `true` and `false` are short for `OpenTelemetryTraces(enabled: true)` and `(enabled: false)`.
public struct OpenTelemetryTraces: Sendable, Hashable, ExpressibleByBooleanLiteral {
    /// Whether the client emits spans. `false` disables them, and then the other fields are not used. Defaults to `true`.
    public var enabled: Bool?
    /// Whether the client's spans have the content of its requests and responses. Defaults to `.metadataOnly`.
    public var contentMode: OpenTelemetryContentMode?
    /// The size in bytes that the content of one span is kept within, in content mode.
    ///
    /// A span with more content has only what fits, and `anthropic.content.truncated`. The SDK measures content by the
    /// bytes of its JSON in UTF-8. At least 1, and a smaller value is 750,000. Defaults to 750,000.
    public var maxContentBytes: Int?

    public init(enabled: Bool? = nil, contentMode: OpenTelemetryContentMode? = nil, maxContentBytes: Int? = nil) {
        self.enabled = enabled
        self.contentMode = contentMode
        self.maxContentBytes = maxContentBytes
    }

    public init(booleanLiteral value: Bool) { self.init(enabled: value) }
}

/// The `openTelemetry` client option.
///
/// A client that is given it, even empty, reads none of the `ANTHROPIC_OPEN_TELEMETRY*` environment variables: a field
/// that it leaves out has its default. A client that is given `nil` makes its option from the variables
/// `ANTHROPIC_OPEN_TELEMETRY`, `ANTHROPIC_OPEN_TELEMETRY_TRACES_CONTENT_MODE`,
/// `ANTHROPIC_OPEN_TELEMETRY_TRACES_MAX_CONTENT_BYTES` and `ANTHROPIC_OPEN_TELEMETRY_PROPAGATION`, when it is
/// constructed. `OpenTelemetryOptions.disabled` (Python's `False`) disables the client's spans.
///
/// `client.openTelemetry` reads back the resolved option, which has `propagation` and every field of `traces`. A copy
/// of the client that changes one field starts from it:
///
/// ```swift
/// var option = client.openTelemetry
/// option.conversationID = "conv_123"
/// let conversation = try client.withOptions(openTelemetry: option)
/// ```
public struct OpenTelemetryOptions: Sendable, Equatable {
    /// The tracer provider that creates the client's spans, in place of the registered one (`OpenTelemetry.tracerProvider`).
    public var tracerProvider: (any TracerProvider)?
    /// Whether the client's requests carry the trace context of their span, in the headers of the registered propagator.
    ///
    /// Set `false` for an application whose HTTP instrumentation already propagates the trace context, so that a request
    /// does not carry it twice. The client's spans are not affected. Defaults to `true`.
    public var propagation: Bool?
    /// The client's spans.
    public var traces: OpenTelemetryTraces?
    /// Links the spans of the client's requests to one conversation, as `gen_ai.conversation.id`. Not sent to the API.
    public var conversationID: String?

    public init(tracerProvider: (any TracerProvider)? = nil, propagation: Bool? = nil, traces: OpenTelemetryTraces? = nil,
                conversationID: String? = nil)
    {
        self.tracerProvider = tracerProvider
        self.propagation = propagation
        self.traces = traces
        self.conversationID = conversationID
    }

    /// Disables the client's spans (Python's `open_telemetry=False`).
    public static var disabled: OpenTelemetryOptions { OpenTelemetryOptions(traces: false) }

    public static func == (a: OpenTelemetryOptions, b: OpenTelemetryOptions) -> Bool {
        a.propagation == b.propagation && a.traces == b.traces && a.conversationID == b.conversationID
            && sameProvider(a.tracerProvider, b.tracerProvider)
    }

    static func sameProvider(_ a: (any TracerProvider)?, _ b: (any TracerProvider)?) -> Bool {
        switch (a, b) {
        case (nil, nil): return true
        case (let x?, let y?):
            if type(of: x) is AnyClass { return (x as AnyObject) === (y as AnyObject) }
            return ObjectIdentifier(type(of: x)) == ObjectIdentifier(type(of: y)) && String(describing: x) == String(describing: y)
        default: return false
        }
    }

    // MARK: Resolution

    /// The default `traces.maxContentBytes`.
    public static let defaultMaxContentBytes = 750_000

    /// `option` with `propagation` and every field of its `traces` (`resolve_open_telemetry`).
    ///
    /// The environment is for a client that is given no option, `nil`. An option that is given is complete, even an
    /// empty one: what it leaves out has the default, whatever the environment says. A `maxContentBytes` below 1 is
    /// not valid: in `option` it is the default, and in the environment it is ignored.
    public static func resolve(_ option: OpenTelemetryOptions?, environment: [String: String] = ProcessInfo.processInfo.environment)
        -> OpenTelemetryOptions
    {
        let options = option ?? fromEnvironment(environment)
        let traces = options.traces ?? OpenTelemetryTraces()
        var resolved = OpenTelemetryOptions(
            tracerProvider: options.tracerProvider,
            propagation: options.propagation ?? true,
            traces: OpenTelemetryTraces(
                enabled: traces.enabled ?? true,
                contentMode: traces.contentMode ?? .metadataOnly,
                maxContentBytes: traces.maxContentBytes.flatMap { $0 < 1 ? nil : $0 } ?? defaultMaxContentBytes),
            conversationID: nil)
        resolved.conversationID = options.conversationID
        return resolved
    }

    /// The option that the environment variables make, for a client that is given none (`env_open_telemetry`).
    /// It has only what a variable changes from the default.
    public static func fromEnvironment(_ environment: [String: String]) -> OpenTelemetryOptions {
        var traces = OpenTelemetryTraces()
        if environment["ANTHROPIC_OPEN_TELEMETRY"]?.lowercased() == "false" { traces.enabled = false }
        if environment["ANTHROPIC_OPEN_TELEMETRY_TRACES_CONTENT_MODE"]?.lowercased() == "content" { traces.contentMode = .content }
        if let bytes = environmentMaxContentBytes(environment["ANTHROPIC_OPEN_TELEMETRY_TRACES_MAX_CONTENT_BYTES"]) {
            traces.maxContentBytes = bytes
        }
        var options = OpenTelemetryOptions(traces: traces)
        if environment["ANTHROPIC_OPEN_TELEMETRY_PROPAGATION"]?.lowercased() == "false" { options.propagation = false }
        return options
    }

    /// The `maxContentBytes` that a variable sets, or `nil` when its value is not valid: ASCII decimal digits, with or
    /// without whitespace around them, that make a number of at least 1 (`env_max_content_bytes`).
    static func environmentMaxContentBytes(_ raw: String?) -> Int? {
        let value = (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, value.utf8.allSatisfy({ $0 >= 0x30 && $0 <= 0x39 }) else { return nil }
        // A number too large for an `Int` is not valid either.
        guard let number = Int(value), number >= 1 else { return nil }
        return number
    }

    var isEnabled: Bool { traces?.enabled ?? true }
    var resolvedPropagation: Bool { propagation ?? true }
    var resolvedContentMode: OpenTelemetryContentMode { traces?.contentMode ?? .metadataOnly }
    var resolvedMaxContentBytes: Int { traces?.maxContentBytes ?? Self.defaultMaxContentBytes }
}

/// The instrumentation scope of the client's tracer.
public let INSTRUMENTATION_SCOPE = "com.anthropic.sdk.swift"

/// What a client's resolved `openTelemetry` option says about its spans (`lib/_tracing/_config.OpenTelemetryConfig`).
public struct OpenTelemetryConfig: Sendable {
    public let providerName: String
    public let conversationID: String?
    public let maxContentBytes: Int
    let contentMode: OpenTelemetryContentMode
    let platform: String?

    init(_ options: OpenTelemetryOptions, providerName: String, platform: String?) {
        self.providerName = providerName
        self.conversationID = options.conversationID
        self.maxContentBytes = options.resolvedMaxContentBytes
        self.contentMode = options.resolvedContentMode
        self.platform = platform
    }

    public var recordsContent: Bool { contentMode == .content }

    /// The scope of the client's tracer: the SDK's name, and for a platform client the platform after it.
    public var instrumentationScope: String {
        guard let platform else { return INSTRUMENTATION_SCOPE }
        return "\(INSTRUMENTATION_SCOPE).\(platform)"
    }

    /// The attributes that the span of every API call starts with, so that a sampler sees them.
    func apiCallStartAttributes() -> SpanAttributes {
        tracingAttributes(["gen_ai.provider.name": .string(providerName), "gen_ai.conversation.id": conversationID.map { .string($0) }])
    }
}

/// The tracer for a client with the resolved `options`, or `nil` when the client has no spans (`get_tracer`).
///
/// A client has none when its spans are disabled, which calls nothing of the tracing API, and when its provider cannot
/// give a tracer. Never throws.
func getTracer(_ options: OpenTelemetryOptions, version: String, scope: String) -> (any Tracer)? {
    guard options.isEnabled else { return nil }
    guard let provider = options.tracerProvider else { return OpenTelemetry.tracer(scope, version: version) }
    return try? provider.tracer(scope, version: version)
}
