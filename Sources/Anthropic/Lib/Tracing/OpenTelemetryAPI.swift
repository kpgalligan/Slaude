import Foundation

// A small tracing API mirroring the subset of the OpenTelemetry API (`opentelemetry.trace`,
// `opentelemetry.context`, `opentelemetry.propagate`) that the SDK uses. There is no OpenTelemetry
// package for Swift that builds offline with Foundation only, so the SDK defines these, and an
// application bridges them to the tracing system it uses by implementing `TracerProvider`.
// `OpenTelemetrySDK.swift` has a recording implementation with an in-memory exporter.

// MARK: - Attributes

/// The value of a span attribute (`opentelemetry.util.types.AttributeValue`).
public enum AttributeValue: Sendable, Hashable, CustomStringConvertible, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral,
    ExpressibleByFloatLiteral, ExpressibleByBooleanLiteral
{
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case stringArray([String])
    case boolArray([Bool])
    case intArray([Int])
    case doubleArray([Double])

    public init(stringLiteral value: String) { self = .string(value) }
    public init(integerLiteral value: Int) { self = .int(value) }
    public init(floatLiteral value: Double) { self = .double(value) }
    public init(booleanLiteral value: Bool) { self = .bool(value) }

    public var stringValue: String? { if case .string(let s) = self { return s } else { return nil } }
    public var intValue: Int? { if case .int(let i) = self { return i } else { return nil } }
    public var doubleValue: Double? { if case .double(let d) = self { return d } else { return nil } }
    public var boolValue: Bool? { if case .bool(let b) = self { return b } else { return nil } }
    public var stringArrayValue: [String]? { if case .stringArray(let a) = self { return a } else { return nil } }

    public var description: String {
        switch self {
        case .string(let s): return s
        case .bool(let b): return b ? "true" : "false"
        case .int(let i): return String(i)
        case .double(let d): return String(d)
        case .stringArray(let a): return "\(a)"
        case .boolArray(let a): return "\(a)"
        case .intArray(let a): return "\(a)"
        case .doubleArray(let a): return "\(a)"
        }
    }

    /// The attribute value of a JSON scalar or array of scalars, or `nil` for anything else.
    public init?(json: JSONValue?) {
        switch json {
        case .string(let s)?: self = .string(s)
        case .bool(let b)?: self = .bool(b)
        case .int(let i)?: self = .int(i)
        case .double(let d)?: self = .double(d)
        default: return nil
        }
    }
}

/// Span attributes.
public typealias SpanAttributes = [String: AttributeValue]

// MARK: - Span context

/// A 128-bit trace ID.
public struct TraceID: Sendable, Hashable, CustomStringConvertible {
    public var high: UInt64
    public var low: UInt64

    public init(high: UInt64 = 0, low: UInt64) {
        self.high = high
        self.low = low
    }

    public static let invalid = TraceID(high: 0, low: 0)
    public var isValid: Bool { high != 0 || low != 0 }
    /// 32 lowercase hexadecimal digits.
    public var hex: String { String(format: "%016llx%016llx", high, low) }
    public var description: String { hex }

    public init?(hex: String) {
        guard hex.count == 32, let high = UInt64(hex.prefix(16), radix: 16), let low = UInt64(hex.suffix(16), radix: 16) else {
            return nil
        }
        self.init(high: high, low: low)
    }
}

/// A 64-bit span ID.
public struct SpanID: Sendable, Hashable, CustomStringConvertible {
    public var value: UInt64
    public init(_ value: UInt64) { self.value = value }
    public static let invalid = SpanID(0)
    public var isValid: Bool { value != 0 }
    /// 16 lowercase hexadecimal digits.
    public var hex: String { String(format: "%016llx", value) }
    public var description: String { hex }

    public init?(hex: String) {
        guard hex.count == 16, let value = UInt64(hex, radix: 16) else { return nil }
        self.init(value)
    }
}

/// The W3C trace flags (`opentelemetry.trace.TraceFlags`).
public struct TraceFlags: Sendable, Hashable {
    public var rawValue: UInt8
    public init(rawValue: UInt8) { self.rawValue = rawValue }
    public static let `default` = TraceFlags(rawValue: 0)
    public static let sampled = TraceFlags(rawValue: 1)
    public var isSampled: Bool { rawValue & 1 == 1 }
}

/// The W3C `tracestate` entries, in order (`opentelemetry.trace.TraceState`).
public struct TraceState: Sendable, Hashable {
    public var entries: [(key: String, value: String)]

    public init(_ entries: [(String, String)] = []) { self.entries = entries.map { (key: $0.0, value: $0.1) } }

    public var isEmpty: Bool { entries.isEmpty }
    /// The `tracestate` header value.
    public var header: String { entries.map { "\($0.key)=\($0.value)" }.joined(separator: ",") }

    public static func == (a: TraceState, b: TraceState) -> Bool {
        a.entries.map { [$0.key, $0.value] } == b.entries.map { [$0.key, $0.value] }
    }

    public func hash(into hasher: inout Hasher) {
        for e in entries {
            hasher.combine(e.key)
            hasher.combine(e.value)
        }
    }
}

/// What identifies a span within its trace (`opentelemetry.trace.SpanContext`).
public struct SpanContext: Sendable, Hashable, CustomStringConvertible {
    public var traceID: TraceID
    public var spanID: SpanID
    public var traceFlags: TraceFlags
    public var traceState: TraceState
    public var isRemote: Bool

    public init(traceID: TraceID, spanID: SpanID, traceFlags: TraceFlags = .default, traceState: TraceState = TraceState(),
                isRemote: Bool = false)
    {
        self.traceID = traceID
        self.spanID = spanID
        self.traceFlags = traceFlags
        self.traceState = traceState
        self.isRemote = isRemote
    }

    public static let invalid = SpanContext(traceID: .invalid, spanID: .invalid)
    public var isValid: Bool { traceID.isValid && spanID.isValid }
    public var description: String { "SpanContext(trace_id=\(traceID.hex), span_id=\(spanID.hex), sampled=\(traceFlags.isSampled))" }
}

// MARK: - Spans

/// The kind of a span (`opentelemetry.trace.SpanKind`).
public enum SpanKind: String, Sendable, Hashable {
    case `internal` = "INTERNAL"
    case server = "SERVER"
    case client = "CLIENT"
    case producer = "PRODUCER"
    case consumer = "CONSUMER"
}

/// The status code of a span (`opentelemetry.trace.StatusCode`).
public enum StatusCode: String, Sendable, Hashable {
    case unset = "UNSET"
    case ok = "OK"
    case error = "ERROR"
}

/// The status of a span (`opentelemetry.trace.Status`).
public struct SpanStatus: Sendable, Hashable {
    public var code: StatusCode
    public var description: String?

    public init(_ code: StatusCode, description: String? = nil) {
        self.code = code
        self.description = description
    }

    public static let unset = SpanStatus(.unset)
    public static let ok = SpanStatus(.ok)
    public static let error = SpanStatus(.error)
}

/// A span (`opentelemetry.trace.Span`). Every method is safe to call from any task, and none
/// throws: a span that has ended ignores what it is given.
public protocol Span: AnyObject, Sendable {
    var context: SpanContext { get }
    /// Whether the span records what it is given: `false` once it has ended, and for a span that a
    /// sampler dropped, or that only carries a context.
    var isRecording: Bool { get }
    func setAttribute(_ key: String, _ value: AttributeValue)
    func addEvent(_ name: String, attributes: SpanAttributes, timestamp: Date?)
    func setStatus(_ status: SpanStatus)
    func recordException(_ error: Error, attributes: SpanAttributes)
    func updateName(_ name: String)
    func end(time: Date?)
}

extension Span {
    public func setAttributes(_ attributes: SpanAttributes) {
        for (key, value) in attributes { setAttribute(key, value) }
    }

    public func addEvent(_ name: String, attributes: SpanAttributes = [:]) { addEvent(name, attributes: attributes, timestamp: nil) }
    public func recordException(_ error: Error) { recordException(error, attributes: [:]) }
    public func end() { end(time: nil) }
}

/// A span that only carries a context, and records nothing (`opentelemetry.trace.NonRecordingSpan`).
/// A tracer gives one for a span that its sampler dropped, and an application makes one to continue
/// a trace that it received.
public final class NonRecordingSpan: Span {
    public let context: SpanContext
    public init(_ context: SpanContext) { self.context = context }
    public var isRecording: Bool { false }
    public func setAttribute(_ key: String, _ value: AttributeValue) {}
    public func addEvent(_ name: String, attributes: SpanAttributes, timestamp: Date?) {}
    public func setStatus(_ status: SpanStatus) {}
    public func recordException(_ error: Error, attributes: SpanAttributes) {}
    public func updateName(_ name: String) {}
    public func end(time: Date?) {}

    /// The span that is current when none is: its context is not valid.
    public static let invalid = NonRecordingSpan(.invalid)
}

// MARK: - Context

/// What is current in a task: the span, and the W3C baggage (`opentelemetry.context.Context`).
///
/// It is task-local, so a span made current with `TracingContext.withSpan` is current for the
/// operation and the child tasks that it starts, and for nothing else.
public struct TracingContext: Sendable {
    public var span: (any Span)?
    public var baggage: [(key: String, value: String)]

    public init(span: (any Span)? = nil, baggage: [(String, String)] = []) {
        self.span = span
        self.baggage = baggage.map { (key: $0.0, value: $0.1) }
    }

    @TaskLocal public static var current = TracingContext()

    /// The current span, or `NonRecordingSpan.invalid` when there is none (`trace.get_current_span()`).
    public static var currentSpan: any Span { current.span ?? NonRecordingSpan.invalid }

    /// A copy of this context with `span` current (`trace.set_span_in_context`).
    public func with(span: (any Span)?) -> TracingContext {
        var context = self
        context.span = span
        return context
    }

    /// Runs `operation` with `span` current, without ending it (`trace.use_span(span, end_on_exit=False)`).
    public static func withSpan<R>(_ span: (any Span)?, operation: () async throws -> R) async rethrows -> R {
        try await $current.withValue(current.with(span: span), operation: operation)
    }

    public static func withSpan<R>(_ span: (any Span)?, operation: () throws -> R) rethrows -> R {
        try $current.withValue(current.with(span: span), operation: operation)
    }

    /// Runs `operation` with `context` current (`context.attach` / `context.detach`).
    public static func with<R>(_ context: TracingContext, operation: () async throws -> R) async rethrows -> R {
        try await $current.withValue(context, operation: operation)
    }

    public static func with<R>(_ context: TracingContext, operation: () throws -> R) rethrows -> R {
        try $current.withValue(context, operation: operation)
    }
}

// MARK: - Tracers

/// Starts spans (`opentelemetry.trace.Tracer`).
public protocol Tracer: Sendable {
    /// Starts a span, the child of the span current in `context`, or of the current span when
    /// `context` is `nil`. The span is not made current.
    func startSpan(_ name: String, kind: SpanKind, attributes: SpanAttributes, context: TracingContext?, startTime: Date?) -> any Span
}

extension Tracer {
    public func startSpan(_ name: String, kind: SpanKind = .internal, attributes: SpanAttributes = [:],
                          context: TracingContext? = nil) -> any Span
    {
        startSpan(name, kind: kind, attributes: attributes, context: context, startTime: nil)
    }

    /// Runs `operation` in a new span that is current while it runs, and ends it after
    /// (`Tracer.start_as_current_span`). An error fails the span and is recorded on it.
    public func withActiveSpan<R>(_ name: String, kind: SpanKind = .internal, attributes: SpanAttributes = [:],
                                  operation: (any Span) async throws -> R) async rethrows -> R
    {
        let span = startSpan(name, kind: kind, attributes: attributes)
        defer { span.end() }
        do {
            return try await TracingContext.withSpan(span) { try await operation(span) }
        } catch {
            span.recordException(error)
            span.setStatus(SpanStatus(.error, description: "\(type(of: error)): \(error)"))
            throw error
        }
    }

    public func withActiveSpan<R>(_ name: String, kind: SpanKind = .internal, attributes: SpanAttributes = [:],
                                  operation: (any Span) throws -> R) rethrows -> R
    {
        let span = startSpan(name, kind: kind, attributes: attributes)
        defer { span.end() }
        do {
            return try TracingContext.withSpan(span) { try operation(span) }
        } catch {
            span.recordException(error)
            span.setStatus(SpanStatus(.error, description: "\(type(of: error)): \(error)"))
            throw error
        }
    }
}

/// Gives tracers (`opentelemetry.trace.TracerProvider`).
public protocol TracerProvider: Sendable {
    /// The tracer of the instrumentation `scope`, at `version`. May throw when the provider cannot
    /// give one; a client then has no spans.
    func tracer(_ scope: String, version: String?) throws -> any Tracer
}

/// A tracer whose spans only carry the context of their parent (`opentelemetry.trace.NoOpTracer`).
public struct NoOpTracer: Tracer {
    public init() {}
    public func startSpan(_ name: String, kind: SpanKind, attributes: SpanAttributes, context: TracingContext?, startTime: Date?) -> any Span {
        let parent = (context ?? TracingContext.current).span?.context ?? .invalid
        return NonRecordingSpan(parent)
    }
}

/// The provider that is registered until an application registers one (`opentelemetry.trace.NoOpTracerProvider`).
public struct NoOpTracerProvider: TracerProvider {
    public init() {}
    public func tracer(_ scope: String, version: String?) throws -> any Tracer { NoOpTracer() }
}

// MARK: - Propagation

/// Writes a context into the headers of a request (`opentelemetry.propagators.textmap.TextMapPropagator`).
public protocol TextMapPropagator: Sendable {
    /// Writes what `context` has into `carrier`. May throw; the SDK then sends no trace context.
    func inject(_ context: TracingContext, into carrier: inout [String: String]) throws
    /// The context that `carrier` has, on top of `context`.
    func extract(_ carrier: [String: String], context: TracingContext) -> TracingContext
    /// The headers that `inject` may write.
    var fields: Set<String> { get }
}

extension TextMapPropagator {
    public func extract(_ carrier: [String: String], context: TracingContext) -> TracingContext { context }
}

/// The W3C Trace Context propagator: `traceparent` and `tracestate`.
public struct TraceContextPropagator: TextMapPropagator {
    public init() {}
    public var fields: Set<String> { ["traceparent", "tracestate"] }

    public func inject(_ context: TracingContext, into carrier: inout [String: String]) {
        guard let span = context.span, span.context.isValid else { return }
        let c = span.context
        carrier["traceparent"] = "00-\(c.traceID.hex)-\(c.spanID.hex)-\(String(format: "%02x", c.traceFlags.rawValue))"
        if !c.traceState.isEmpty { carrier["tracestate"] = c.traceState.header }
    }

    public func extract(_ carrier: [String: String], context: TracingContext) -> TracingContext {
        guard let header = carrier.first(where: { $0.key.lowercased() == "traceparent" })?.value else { return context }
        let parts = header.trimmingCharacters(in: .whitespaces).split(separator: "-").map(String.init)
        guard parts.count >= 4, parts[0].count == 2, let traceID = TraceID(hex: parts[1]), let spanID = SpanID(hex: parts[2]),
              let flags = UInt8(parts[3], radix: 16), traceID.isValid, spanID.isValid
        else { return context }
        var state = TraceState()
        if let raw = carrier.first(where: { $0.key.lowercased() == "tracestate" })?.value {
            for member in raw.split(separator: ",") {
                let pair = member.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
                if pair.count == 2 { state.entries.append((key: pair[0], value: pair[1])) }
            }
        }
        let remote = SpanContext(traceID: traceID, spanID: spanID, traceFlags: TraceFlags(rawValue: flags), traceState: state, isRemote: true)
        return context.with(span: NonRecordingSpan(remote))
    }
}

/// The W3C Baggage propagator: `baggage`.
public struct BaggagePropagator: TextMapPropagator {
    public init() {}
    public var fields: Set<String> { ["baggage"] }

    public func inject(_ context: TracingContext, into carrier: inout [String: String]) {
        guard !context.baggage.isEmpty else { return }
        carrier["baggage"] = context.baggage.map { "\(pythonQuote($0.key, safe: ""))=\(pythonQuote($0.value, safe: ""))" }
            .joined(separator: ",")
    }
}

/// Runs several propagators in order (`opentelemetry.propagators.composite.CompositePropagator`).
public struct CompositePropagator: TextMapPropagator {
    public let propagators: [any TextMapPropagator]
    public init(_ propagators: [any TextMapPropagator]) { self.propagators = propagators }
    public var fields: Set<String> { propagators.reduce(into: Set()) { $0.formUnion($1.fields) } }

    public func inject(_ context: TracingContext, into carrier: inout [String: String]) throws {
        for propagator in propagators { try propagator.inject(context, into: &carrier) }
    }

    public func extract(_ carrier: [String: String], context: TracingContext) -> TracingContext {
        propagators.reduce(context) { $1.extract(carrier, context: $0) }
    }
}

// MARK: - Global registry

/// The registered tracer provider and propagator (`opentelemetry.trace.set_tracer_provider`,
/// `opentelemetry.propagate.set_global_textmap`).
///
/// A client that is given no `tracerProvider` starts its spans with the provider that is registered
/// when each span starts. A task can register its own for an operation with `withTracerProvider` /
/// `withPropagator`, which is what tests do: they run in parallel.
public enum OpenTelemetry {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var globalProvider: any TracerProvider = NoOpTracerProvider()
    nonisolated(unsafe) private static var globalPropagator: any TextMapPropagator =
        CompositePropagator([TraceContextPropagator(), BaggagePropagator()])

    @TaskLocal static var taskProvider: (any TracerProvider)? = nil
    @TaskLocal static var taskPropagator: (any TextMapPropagator)? = nil

    /// The tracer provider that is registered for the current task.
    public static var tracerProvider: any TracerProvider {
        taskProvider ?? lock.withLock { globalProvider }
    }

    /// Registers `provider` for the process.
    public static func setTracerProvider(_ provider: any TracerProvider) {
        lock.withLock { globalProvider = provider }
    }

    /// The propagator that writes the trace context into the requests of the current task.
    public static var propagator: any TextMapPropagator {
        taskPropagator ?? lock.withLock { globalPropagator }
    }

    /// Registers `propagator` for the process.
    public static func setPropagator(_ propagator: any TextMapPropagator) {
        lock.withLock { globalPropagator = propagator }
    }

    /// Runs `operation` with `provider` registered for it and the tasks that it starts.
    public static func withTracerProvider<R>(_ provider: any TracerProvider, operation: () async throws -> R) async rethrows -> R {
        try await $taskProvider.withValue(provider, operation: operation)
    }

    /// Runs `operation` with `propagator` registered for it and the tasks that it starts.
    public static func withPropagator<R>(_ propagator: any TextMapPropagator, operation: () async throws -> R) async rethrows -> R {
        try await $taskPropagator.withValue(propagator, operation: operation)
    }

    /// The tracer of the registered provider, which follows the provider that is registered when each span starts
    /// (`opentelemetry.trace.ProxyTracer`).
    public static func tracer(_ scope: String, version: String? = nil) -> any Tracer {
        RegisteredTracer(scope: scope, version: version)
    }

    /// Writes the trace context of `context` into `carrier` with the registered propagator (`propagate.inject`).
    public static func inject(_ context: TracingContext = TracingContext.current, into carrier: inout [String: String]) throws {
        try propagator.inject(context, into: &carrier)
    }
}

/// The tracer that a client without a `tracerProvider` uses: each span comes from the provider that
/// is registered when it starts.
struct RegisteredTracer: Tracer {
    let scope: String
    let version: String?

    func startSpan(_ name: String, kind: SpanKind, attributes: SpanAttributes, context: TracingContext?, startTime: Date?) -> any Span {
        let tracer = (try? OpenTelemetry.tracerProvider.tracer(scope, version: version)) ?? NoOpTracer()
        return tracer.startSpan(name, kind: kind, attributes: attributes, context: context, startTime: startTime)
    }
}
