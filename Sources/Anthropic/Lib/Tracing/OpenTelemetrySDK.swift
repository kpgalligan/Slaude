import Foundation

// A recording implementation of the tracing API, mirroring the parts of the OpenTelemetry SDK
// (`opentelemetry.sdk.trace`) that an application or a test uses: a tracer provider with a sampler,
// an ID generator and span processors, and an exporter that keeps the finished spans in memory.

/// The instrumentation scope of a tracer: what made its spans.
public struct InstrumentationScope: Sendable, Hashable {
    public var name: String
    public var version: String?
    public init(name: String, version: String? = nil) {
        self.name = name
        self.version = version
    }
}

/// An event on a span.
public struct SpanEvent: Sendable, Hashable {
    public var name: String
    public var attributes: SpanAttributes
    public var timestamp: Date
}

/// A span as it was when it ended, or as it is (`opentelemetry.sdk.trace.ReadableSpan`).
public struct SpanData: Sendable {
    public var name: String
    public var kind: SpanKind
    public var context: SpanContext
    /// The context of the parent span, if it has one.
    public var parent: SpanContext?
    public var attributes: SpanAttributes
    public var events: [SpanEvent]
    public var status: SpanStatus
    public var startTime: Date
    public var endTime: Date?
    public var instrumentationScope: InstrumentationScope

    public var traceID: TraceID { context.traceID }
    public var spanID: SpanID { context.spanID }
}

/// Whether a sampler keeps a span.
public enum SamplingDecision: Sendable, Hashable {
    /// The span is not recorded, and carries a context that is not sampled.
    case drop
    /// The span is recorded, and not exported.
    case recordOnly
    case recordAndSample
}

/// What a sampler decides for a span: its decision, and attributes to add.
public struct SamplingResult: Sendable {
    public var decision: SamplingDecision
    public var attributes: SpanAttributes
    public init(_ decision: SamplingDecision, attributes: SpanAttributes = [:]) {
        self.decision = decision
        self.attributes = attributes
    }
}

/// Decides, when a span starts, whether it is recorded (`opentelemetry.sdk.trace.sampling.Sampler`).
/// It is given the span's name and the attributes that the span starts with, and nothing that is set later.
public protocol Sampler: Sendable {
    func shouldSample(parent: SpanContext?, traceID: TraceID, name: String, kind: SpanKind, attributes: SpanAttributes) throws -> SamplingResult
}

public struct AlwaysOnSampler: Sampler {
    public init() {}
    public func shouldSample(parent: SpanContext?, traceID: TraceID, name: String, kind: SpanKind, attributes: SpanAttributes) -> SamplingResult {
        SamplingResult(.recordAndSample)
    }
}

public struct AlwaysOffSampler: Sampler {
    public init() {}
    public func shouldSample(parent: SpanContext?, traceID: TraceID, name: String, kind: SpanKind, attributes: SpanAttributes) -> SamplingResult {
        SamplingResult(.drop)
    }
}

/// Follows the decision of the parent span, and of `root` for a span without one.
public struct ParentBasedSampler: Sampler {
    public let root: any Sampler
    public init(root: any Sampler = AlwaysOnSampler()) { self.root = root }
    public func shouldSample(parent: SpanContext?, traceID: TraceID, name: String, kind: SpanKind, attributes: SpanAttributes) throws -> SamplingResult {
        guard let parent, parent.isValid else {
            return try root.shouldSample(parent: nil, traceID: traceID, name: name, kind: kind, attributes: attributes)
        }
        return SamplingResult(parent.traceFlags.isSampled ? .recordAndSample : .drop)
    }
}

/// Makes the IDs of new spans and traces (`opentelemetry.sdk.trace.id_generator.IdGenerator`).
public protocol IDGenerator: Sendable {
    func generateTraceID() -> TraceID
    func generateSpanID() -> SpanID
}

public struct RandomIDGenerator: IDGenerator {
    public init() {}
    public func generateTraceID() -> TraceID {
        var id = TraceID(high: .random(in: 0...UInt64.max), low: .random(in: 0...UInt64.max))
        while !id.isValid { id = TraceID(high: .random(in: 0...UInt64.max), low: .random(in: 0...UInt64.max)) }
        return id
    }

    public func generateSpanID() -> SpanID { SpanID(.random(in: 1...UInt64.max)) }
}

/// Is told when each span starts and ends (`opentelemetry.sdk.trace.SpanProcessor`). A processor that
/// throws is logged and skipped.
public protocol SpanProcessor: Sendable {
    func onStart(_ span: RecordingSpan, parent: TracingContext) throws
    func onEnd(_ span: SpanData) throws
}

extension SpanProcessor {
    public func onStart(_ span: RecordingSpan, parent: TracingContext) throws {}
    public func onEnd(_ span: SpanData) throws {}
}

/// Exports finished spans.
public protocol SpanExporter: Sendable {
    func export(_ spans: [SpanData])
}

/// Exports each sampled span when it ends (`SimpleSpanProcessor`).
public struct SimpleSpanProcessor: SpanProcessor {
    public let exporter: any SpanExporter
    public init(_ exporter: any SpanExporter) { self.exporter = exporter }
    public func onEnd(_ span: SpanData) {
        if span.context.traceFlags.isSampled { exporter.export([span]) }
    }
}

/// Keeps the finished spans in memory (`InMemorySpanExporter`).
public final class InMemorySpanExporter: SpanExporter, @unchecked Sendable {
    private let lock = NSLock()
    private var spans: [SpanData] = []

    public init() {}

    public func export(_ spans: [SpanData]) { lock.withLock { self.spans.append(contentsOf: spans) } }

    /// The spans that have ended, in the order in which they did.
    public var finishedSpans: [SpanData] { lock.withLock { spans } }

    public func clear() { lock.withLock { spans.removeAll() } }
}

/// A tracer provider whose spans record what they are given (`opentelemetry.sdk.trace.TracerProvider`).
public final class SDKTracerProvider: TracerProvider, @unchecked Sendable {
    public let sampler: any Sampler
    public let idGenerator: any IDGenerator
    private let lock = NSLock()
    private var processors: [any SpanProcessor]
    private var warnings: [String] = []

    public init(sampler: any Sampler = ParentBasedSampler(), idGenerator: any IDGenerator = RandomIDGenerator(),
                processors: [any SpanProcessor] = [])
    {
        self.sampler = sampler
        self.idGenerator = idGenerator
        self.processors = processors
    }

    public func addSpanProcessor(_ processor: any SpanProcessor) { lock.withLock { processors.append(processor) } }

    var spanProcessors: [any SpanProcessor] { lock.withLock { processors } }

    public func tracer(_ scope: String, version: String?) -> any Tracer {
        SDKTracer(provider: self, scope: InstrumentationScope(name: scope, version: version))
    }

    /// What the provider logged, as the OpenTelemetry SDK logs a warning: setting an attribute on a
    /// span that has ended, ending a span twice, a processor or a sampler that failed.
    public var loggedWarnings: [String] { lock.withLock { warnings } }

    func warn(_ message: String) { lock.withLock { warnings.append(message) } }
}

struct SDKTracer: Tracer {
    let provider: SDKTracerProvider
    let scope: InstrumentationScope

    func startSpan(_ name: String, kind: SpanKind, attributes: SpanAttributes, context: TracingContext?, startTime: Date?) -> any Span {
        let parentContext = context ?? TracingContext.current
        let parent = parentContext.span?.context
        let validParent = parent?.isValid == true ? parent : nil
        let traceID = validParent?.traceID ?? provider.idGenerator.generateTraceID()
        let result: SamplingResult
        do {
            result = try provider.sampler.shouldSample(parent: validParent, traceID: traceID, name: name, kind: kind, attributes: attributes)
        } catch {
            provider.warn("Sampler failed: \(error)")
            return NonRecordingSpan(.invalid)
        }
        let flags: TraceFlags = result.decision == .recordAndSample ? .sampled : .default
        let spanContext = SpanContext(traceID: traceID, spanID: provider.idGenerator.generateSpanID(), traceFlags: flags,
                                      traceState: validParent?.traceState ?? TraceState())
        if result.decision == .drop { return NonRecordingSpan(spanContext) }
        var all = attributes
        for (k, v) in result.attributes { all[k] = v }
        let span = RecordingSpan(provider: provider, name: name, kind: kind, context: spanContext, parent: validParent, attributes: all,
                                 startTime: startTime ?? Date(), scope: scope)
        for processor in provider.spanProcessors {
            do { try processor.onStart(span, parent: parentContext) } catch { provider.warn("Span processor failed on start: \(error)") }
        }
        return span
    }
}

/// A span of an `SDKTracerProvider` (`opentelemetry.sdk.trace.Span`). Its `data` can be read while it runs.
public final class RecordingSpan: Span, @unchecked Sendable {
    private let lock = NSLock()
    private let provider: SDKTracerProvider
    private var state: SpanData
    private var ended = false

    init(provider: SDKTracerProvider, name: String, kind: SpanKind, context: SpanContext, parent: SpanContext?, attributes: SpanAttributes,
         startTime: Date, scope: InstrumentationScope)
    {
        self.provider = provider
        self.state = SpanData(name: name, kind: kind, context: context, parent: parent, attributes: attributes, events: [], status: .unset,
                              startTime: startTime, endTime: nil, instrumentationScope: scope)
    }

    public var context: SpanContext { state.context }
    public var isRecording: Bool { lock.withLock { !ended } }
    /// What the span has so far.
    public var data: SpanData { lock.withLock { state } }
    public var name: String { data.name }
    public var attributes: SpanAttributes { data.attributes }

    /// Applies `change` unless the span has ended, which the SDK logs.
    private func mutate(_ what: String, _ change: (inout SpanData) -> Void) {
        let applied: Bool = lock.withLock {
            if ended { return false }
            change(&state)
            return true
        }
        if !applied { provider.warn("Tried to \(what) on an ended span: \(state.name)") }
    }

    public func setAttribute(_ key: String, _ value: AttributeValue) { mutate("set attribute \(key)") { $0.attributes[key] = value } }

    public func addEvent(_ name: String, attributes: SpanAttributes, timestamp: Date?) {
        mutate("add event") { $0.events.append(SpanEvent(name: name, attributes: attributes, timestamp: timestamp ?? Date())) }
    }

    public func setStatus(_ status: SpanStatus) {
        mutate("set status") { state in
            // As the SDK does: `OK` is final, and `UNSET` changes nothing.
            if state.status.code == .ok || status.code == .unset { return }
            state.status = status
        }
    }

    public func recordException(_ error: Error, attributes: SpanAttributes) {
        var all: SpanAttributes = ["exception.type": .string(String(describing: type(of: error))), "exception.message": .string("\(error)")]
        for (k, v) in attributes { all[k] = v }
        addEvent("exception", attributes: all, timestamp: nil)
    }

    public func updateName(_ name: String) { mutate("update name") { $0.name = name } }

    public func end(time: Date?) {
        let finished: SpanData? = lock.withLock {
            if ended { return nil }
            ended = true
            state.endTime = time ?? Date()
            return state
        }
        guard let finished else {
            provider.warn("Calling end() on an ended span: \(state.name)")
            return
        }
        for processor in provider.spanProcessors {
            do { try processor.onEnd(finished) } catch { provider.warn("Span processor failed on end: \(error)") }
        }
    }
}
