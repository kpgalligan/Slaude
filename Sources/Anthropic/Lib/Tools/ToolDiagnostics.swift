import Foundation

/// The log records and warnings the tool helpers emit (Python's `logging` and `warnings` calls in `lib/tools`).
///
/// By default warnings go to `AnthropicWarnings` and log records at `warning` and above go to standard error.
/// Install a handler with `setLogHandler(_:)`, or capture both for the duration of a task with
/// `ToolDiagnostics.capture { ... }` (task-local, so concurrent captures don't see each other's records).
public enum ToolDiagnostics {
    public enum Level: Int, Sendable, Comparable, CustomStringConvertible {
        case debug = 10, info = 20, warning = 30, error = 40

        public static func < (a: Level, b: Level) -> Bool { a.rawValue < b.rawValue }

        public var description: String {
            switch self {
            case .debug: return "DEBUG"
            case .info: return "INFO"
            case .warning: return "WARNING"
            case .error: return "ERROR"
            }
        }
    }

    /// One log record: the upstream logger name (e.g. `anthropic.lib.tools._beta_runner`), level and message.
    public struct Record: Sendable, Hashable, CustomStringConvertible {
        public let logger: String
        public let level: Level
        public let message: String
        public let error: String?

        public var description: String { "\(level) \(logger): \(message)" }
    }

    /// Records and warnings captured by `capture(_:)`.
    public final class Capture: @unchecked Sendable {
        private let lock = NSLock()
        private var _records: [Record] = []
        private var _warnings: [String] = []

        public init() {}

        public var records: [Record] { lock.withLock { _records } }
        public var warnings: [String] { lock.withLock { _warnings } }

        func add(_ r: Record) { lock.withLock { _records.append(r) } }
        func warn(_ w: String) { lock.withLock { _warnings.append(w) } }
    }

    @TaskLocal static var current: Capture?

    nonisolated(unsafe) private static var handler: (@Sendable (Record) -> Void) = { record in
        if record.level >= .warning {
            FileHandle.standardError.write(Data("\(record)\n".utf8))
        }
    }
    private static let lock = NSLock()

    /// Replaces the log handler.
    public static func setLogHandler(_ h: @escaping @Sendable (Record) -> Void) {
        lock.withLock { handler = h }
    }

    /// Runs `body`, capturing the tool helpers' log records and warnings emitted from this task and its children.
    public static func capture<T>(_ body: () async throws -> T) async rethrows -> (T, Capture) {
        let c = Capture()
        let value = try await $current.withValue(c) { try await body() }
        return (value, c)
    }

    static func log(_ logger: String, _ level: Level, _ message: String, error: Error? = nil) {
        let record = Record(logger: logger, level: level, message: message, error: error.map { pythonExceptionRepr($0) })
        if let c = current {
            c.add(record)
            return
        }
        let h = lock.withLock { handler }
        h(record)
    }

    static func warn(_ message: String) {
        if let c = current {
            c.warn(message)
            return
        }
        AnthropicWarnings.warn(message, .user)
    }
}

/// A logger bound to an upstream module name (`logging.getLogger(__name__)`).
struct ToolLogger: Sendable {
    let name: String

    func debug(_ message: @autoclosure () -> String) {
        if ToolDiagnostics.current != nil { ToolDiagnostics.log(name, .debug, message()) }
    }
    func info(_ message: String) { ToolDiagnostics.log(name, .info, message) }
    func warning(_ message: String) { ToolDiagnostics.log(name, .warning, message) }
    func error(_ message: String, error: Error? = nil) { ToolDiagnostics.log(name, .error, message, error: error) }
    /// `log.exception(...)`: an error record carrying the error.
    func exception(_ message: String, _ error: Error) { ToolDiagnostics.log(name, .error, message, error: error) }
}
