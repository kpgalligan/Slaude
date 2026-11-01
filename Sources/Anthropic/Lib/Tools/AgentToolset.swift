// Port of `anthropic/lib/tools/agent_toolset.py` (and `_deprecations.py`): reference implementations of the
// `agent_toolset_20260401` tools — `bash`, `read`, `write`, `edit`, `glob`, `grep` — plus the workdir/skills
// `AgentToolContext`.
//
// The result of `betaAgentToolset20260401` is a plain `[BetaFunctionTool]`, for the session tool runner
// (`client.beta.sessions.events.toolRunner(...)`), which closes the tools when it ends. `bash` is stateful: it owns a
// persistent `/bin/bash` process that only its close hook tears down, and the Messages tool runner does not call it,
// so drop `bash` before handing the toolset to `client.beta.messages.toolRunner(...)`.
//
// Trust model: the file tools confine to `workdir` plus any `allowedRoots` (symlink-aware) and are safe without a
// sandbox; `bash` is unrestricted and should run inside one. See `AgentToolContext`.

import Foundation
#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

public let BASH_OUTPUT_LIMIT = 100 * 1024
public let BASH_DEFAULT_TIMEOUT: TimeInterval = 120
public let DEFAULT_MAX_FILE_BYTES = 256 * 1024
/// The API's per-image limit is on the encoded (base64) form.
public let DEFAULT_MAX_IMAGE_BASE64_BYTES = 5 * 1024 * 1024
public let DEFAULT_MAX_PDF_BYTES = 20 * 1024 * 1024
/// Extension → media type for files `read` returns as base64 content blocks rather than text.
let BINARY_MEDIA_TYPES: [String: String] = [
    ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".gif": "image/gif", ".webp": "image/webp",
    ".pdf": "application/pdf",
]
let GREP_OUTPUT_LIMIT = 100 * 1024
let GREP_MAX_LINE_LENGTH = 2000
let GLOB_RESULT_LIMIT = 200
let WALK_MAX_ENTRIES = 50_000
let MAX_SYMLINK_HOPS = 40

/// What `unrestrictedPaths` gets when it is passed at all (`UNRESTRICTED_PATHS_DEPRECATION`).
public let UNRESTRICTED_PATHS_DEPRECATION =
    "unrestricted_paths is no longer supported. The file tools are now always confined to the "
    + "working directory plus any allowed_roots (the environment worker adds the session's memory "
    + "folders there itself), which is neither of the behaviors this flag used to choose between. "
    + "Remove the unrestricted_paths argument; to let the file tools reach another directory, add it "
    + "to AgentToolContext.allowed_roots."

private let agentLog = ToolLogger(name: "anthropic.lib.tools.agent_toolset")

/// The environment for the bash process, with the runner's own `ANTHROPIC_*` credentials scrubbed.
func defaultBashEnvironment() -> [String: String] {
    ProcessInfo.processInfo.environment.filter { !$0.key.hasPrefix("ANTHROPIC_") }
}

/// A filesystem `errno` as a consistent, runtime-independent phrase (`_fs_reason`): the model never sees the runner's
/// absolute paths.
func fsReason(_ code: Int32) -> String {
    switch code {
    case ENOENT: return "no such file or directory"
    case ENOTDIR: return "not a directory"
    case EISDIR: return "is a directory"
    case EACCES, EPERM: return "permission denied"
    case EEXIST: return "file already exists"
    case ELOOP: return "too many levels of symbolic links"
    default:
        let message = String(cString: strerror(code))
        return message.isEmpty ? "i/o error" : message.lowercased()
    }
}

private func fsError(_ op: String, _ filePath: String, _ code: Int32) -> ToolError {
    ToolError("\(op): \(filePath): \(fsReason(code))")
}

/// A POSIX error a file operation met.
struct AgentFileError: Error {
    let code: Int32
}

// MARK: - The context

/// Workdir and path policy for the agent toolset (`AgentToolContext`).
///
/// Two trust tiers:
///
/// - The file tools (`read`, `write`, `edit`, `glob`, `grep`) resolve paths against `workdir` and reject anything
///   outside `workdir` and `allowedRoots`. `resolvePath` follows every symlink (including the leaf, even a dangling
///   one) before the check and returns that canonical path for the operation, so a symlink inside the workdir that
///   points outside it can neither pass the check nor be followed afterwards.
/// - `bash` runs an unrestricted `/bin/bash` regardless of the path policy. Confinement for it must come from the OS.
public final class AgentToolContext: @unchecked Sendable {
    /// Base directory for resolving relative tool paths; the working directory when the context was built.
    public let workdir: String
    /// Directories outside `workdir` that the file tools may also reach. Does not constrain `bash`.
    public let allowedRoots: [String]
    /// Directories the write and edit tools refuse to modify.
    public let readOnlyRoots: [String]
    /// When set together with `session` (or `sessionID`), `setupSkills()` downloads the session agent's skills.
    public let client: Anthropic?
    public let session: BetaManagedAgentsSession?
    /// Deprecated: `setupSkills()` fetches the session itself, one extra round trip. Prefer `session`.
    public let sessionID: String?
    /// The bash environment. When set it fully replaces the default (the process environment without
    /// `ANTHROPIC_*`); nothing is merged in.
    public let env: [String: String]?
    /// Size cap for a whole-file `read` and for `edit`. `nil` uses the built-in 256 KiB; `.some(nil)` disables it.
    public let maxFileBytes: Int??
    /// Cap on the base64-encoded size of an image `read` returns. `nil` uses 5 MiB; `.some(nil)` disables it.
    public let maxImageBase64Bytes: Int??
    /// Cap on the raw size of a PDF `read` returns. `nil` uses 20 MiB; `.some(nil)` disables it.
    public let maxPDFBytes: Int??

    private let lock = NSLock()
    private var _bash: BashSession?
    private var skillDirs: [String] = []

    /// - Parameter unrestrictedPaths: Deprecated and no longer accepted: passing it at all throws.
    public init(workdir: String = FileManager.default.currentDirectoryPath, unrestrictedPaths: Bool? = nil,
                allowedRoots: [String] = [], client: Anthropic? = nil, session: BetaManagedAgentsSession? = nil,
                sessionID: String? = nil, env: [String: String]? = nil, maxFileBytes: Int?? = nil,
                maxImageBase64Bytes: Int?? = nil, maxPDFBytes: Int?? = nil, readOnlyRoots: [String] = []) throws
    {
        if unrestrictedPaths != nil { throw ArgumentTypeError(UNRESTRICTED_PATHS_DEPRECATION) }
        self.workdir = workdir
        self.allowedRoots = allowedRoots
        self.client = client
        self.session = session
        self.sessionID = sessionID
        self.env = env
        self.maxFileBytes = maxFileBytes
        self.maxImageBase64Bytes = maxImageBase64Bytes
        self.maxPDFBytes = maxPDFBytes
        self.readOnlyRoots = readOnlyRoots
    }

    /// The context's own bash session, started on first use.
    public func bash() async throws -> BashSession {
        if let existing = lock.withLock({ _bash }) { return existing }
        let started = try await BashSession.start(workdir: workdir, env: env)
        return lock.withLock {
            if let existing = _bash { return existing }
            _bash = started
            return started
        }
    }

    public func close() async {
        let bash: BashSession? = lock.withLock {
            defer { _bash = nil }
            return _bash
        }
        await bash?.close()
    }

    /// Download the session agent's skills into `{workdir}/skills/<name>/`. A no-op unless `client` is set
    /// together with `session` (or the deprecated `sessionID`).
    public func setupSkills() async throws {
        guard let client else { return }
        var session = self.session
        if session == nil, let sessionID { session = try await client.beta.sessions.retrieve(sessionID) }
        guard let session else { return }
        let dirs = try await downloadSessionSkills(client, workdir: workdir, session: session)
        lock.withLock { skillDirs = dirs }
    }

    /// Remove the skill directories `setupSkills()` downloaded; a pre-existing `{workdir}/skills` tree is left alone.
    func cleanupSkills() {
        let dirs: [String] = lock.withLock {
            defer { skillDirs = [] }
            return skillDirs
        }
        for dir in dirs {
            do {
                try FileManager.default.removeItem(atPath: dir)
            } catch {
                agentLog.warning("failed to remove downloaded skill dir \(dir): \(error)")
            }
        }
    }

    /// Runs `body` with the skills set up, then closes the bash session and removes the downloaded skills (Python's
    /// `async with AgentToolContext(...)`).
    public func use<T>(_ body: (AgentToolContext) async throws -> T) async throws -> T {
        try await setupSkills()
        let result: Result<T, Error>
        do {
            result = .success(try await body(self))
        } catch {
            result = .failure(error)
        }
        await close()
        cleanupSkills()
        return try result.get()
    }
}

// MARK: - Path resolution

/// The resolved path of an existing path, every symlink followed (`Path.resolve(strict=True)`), or its `errno`.
private func strictRealpath(_ path: String) -> Result<String, AgentFileError> {
    guard let resolved = realpath(path, nil) else { return .failure(AgentFileError(code: errno)) }
    defer { free(resolved) }
    return .success(String(cString: resolved))
}

/// `path` with `.`/`..` collapsed lexically and every symlink followed, or throws (`_canonicalize`). Trailing
/// components that do not exist yet are kept as spelled; a dangling symlink met on the way is followed by hand, and
/// more than `MAX_SYMLINK_HOPS` such hops count as a loop.
func canonicalize(_ path: String) throws -> String {
    var prefix = posixNormpath(path)
    var missingTail: [String] = []
    var hops = 0
    while true {
        let unresolved: AgentFileError
        switch strictRealpath(prefix) {
        case .success(let resolved):
            return missingTail.reversed().reduce(resolved) { posixJoin($0, $1) }
        case .failure(let error):
            if error.code != ENOENT && error.code != ENOTDIR { throw error }
            unresolved = error
        }
        var st = stat()
        if lstat(prefix, &st) != 0 {
            let code = errno
            let (parent, name) = splitPath(prefix)
            if (code != ENOENT && code != ENOTDIR) || parent == prefix { throw AgentFileError(code: code) }
            missingTail.append(name)
            prefix = parent
            continue
        }
        if (st.st_mode & S_IFMT) != S_IFLNK { throw unresolved }
        hops += 1
        if hops > MAX_SYMLINK_HOPS { throw AgentFileError(code: ELOOP) }
        guard let target = FileOps.readLink(prefix) else { throw AgentFileError(code: errno) }
        prefix = posixNormpath(posixJoin(splitPath(prefix).0, target))
    }
}

/// `(parent, name)` of an absolute path, as `Path.parent` / `Path.name` give them.
private func splitPath(_ path: String) -> (String, String) {
    guard let slash = path.lastIndex(of: "/") else { return (".", path) }
    let name = String(path[path.index(after: slash)...])
    var parent = String(path[..<slash])
    if parent.isEmpty { parent = "/" }
    return (parent, name)
}

/// Resolve `p` against the workdir and reject results outside the permitted roots (`resolve_path`).
///
/// The permitted roots are `workdir` plus each of `allowedRoots`. Absolute and relative inputs go through the same
/// canonicalise-then-contain check. A symlink loop or an unreadable component rejects the path outright.
public func resolvePath(_ ctx: AgentToolContext, _ p: String) throws -> String {
    let root = FileOps.resolve(ctx.workdir)
    let full: String
    do {
        full = try canonicalize(p.hasPrefix("/") ? p : posixJoin(root, p))
    } catch let error as AgentFileError {
        throw ValueError("path \(pythonStringRepr(p)): \(fsReason(error.code))")
    }
    if isWithin(full, root) || ctx.allowedRoots.contains(where: { isWithin(full, FileOps.resolve($0)) }) { return full }
    if !ctx.allowedRoots.isEmpty {
        throw ValueError("path \(pythonStringRepr(p)) is outside the session's working directory and its other permitted directories")
    }
    throw ValueError("path \(pythonStringRepr(p)) is outside the session's working directory")
}

/// Throws `ToolError` when `target` falls under a read-only root, resolved at check time like `allowedRoots`
/// (`_reject_read_only`).
func rejectReadOnly(_ ctx: AgentToolContext, _ target: String, op: String, filePath: String) throws {
    for root in ctx.readOnlyRoots where isWithin(target, FileOps.resolve(root)) {
        throw ToolError("\(op): \(filePath) is inside read-only directory \(root)")
    }
}

// MARK: - Bash

/// What `BashSession.exec` returns: the combined output and the exit code (`BashResult`).
public struct BashResult: Sendable, Hashable {
    /// The command's combined stdout and stderr (ANSI escapes stripped, possibly truncated to the last
    /// `BASH_OUTPUT_LIMIT` bytes).
    public var output: String
    /// The exit status, or `-1` when it could not be read from the shell's sentinel.
    public var exitCode: Int
}

/// A command that ran past its timeout (`TimeoutError`).
public struct BashTimeoutError: Error, CustomStringConvertible, Sendable {
    public let timeout: TimeInterval
    public var description: String { "bash command timed out after \(pythonFloatString(timeout))s" }
}

/// `exec` on a session whose process has exited (`RuntimeError`).
public struct BashSessionTerminatedError: Error, CustomStringConvertible, Sendable {
    public var description: String { "bash session terminated; restart required" }
}

/// The bytes the shell wrote, collected off its pipe.
private final class BashOutput: @unchecked Sendable {
    private let lock = NSLock()
    private var buffer = Data()
    private var truncated = false
    private var eof = false
    /// When the last bytes (or the end of the pipe) arrived. The pipe is read off the cooperative pool, so this is
    /// when the shell wrote them, however late `exec`'s polling task gets to look.
    private var arrived = Date()

    func append(_ data: Data) {
        lock.withLock {
            arrived = Date()
            if data.isEmpty {
                eof = true
                return
            }
            buffer.append(data)
            if buffer.count > BASH_OUTPUT_LIMIT {
                // Keep only the tail so the sentinel remains detectable and the buffer cannot grow without bound.
                buffer = buffer.suffix(BASH_OUTPUT_LIMIT)
                truncated = true
            }
        }
    }

    func reset() { lock.withLock { buffer = Data(); truncated = false } }

    var snapshot: (Data, Bool, Bool) { lock.withLock { (buffer, truncated, eof) } }

    var lastArrival: Date { lock.withLock { arrived } }
}

private let ansiEscape = try! NSRegularExpression(pattern: "\u{1b}\\[[0-9;?]*[ -/]*[@-~]")

/// A persistent `/bin/bash` process; cwd, env and jobs survive across calls (`BashSession`).
///
/// Stateful and not safe to share between concurrent callers: interleaved `exec` calls would race for the same
/// pipes. Each `AgentToolContext` (and each `bash` tool) creates its own.
public final class BashSession: @unchecked Sendable {
    private let process: Process
    private let stdin: FileHandle
    private let stdout: FileHandle
    private let output = BashOutput()
    private let lock = NSLock()
    private var torndown = false

    private init(process: Process, stdin: FileHandle, stdout: FileHandle) {
        self.process = process
        self.stdin = stdin
        self.stdout = stdout
    }

    /// Starts `/bin/bash` in `workdir`. `env` replaces the default environment (the process's own without
    /// `ANTHROPIC_*`).
    public static func start(workdir: String, env: [String: String]? = nil) async throws -> BashSession {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["--noprofile", "--norc"]
        process.currentDirectoryURL = URL(fileURLWithPath: workdir)
        var environment = env ?? defaultBashEnvironment()
        environment["PS1"] = ""
        environment["PS2"] = ""
        environment["TERM"] = "dumb"
        process.environment = environment
        let input = Pipe()
        let combined = Pipe()
        process.standardInput = input
        process.standardOutput = combined
        process.standardError = combined
        let session = BashSession(process: process, stdin: input.fileHandleForWriting, stdout: combined.fileHandleForReading)
        let output = session.output
        combined.fileHandleForReading.readabilityHandler = { handle in output.append(handle.availableData) }
        try process.run()
        return session
    }

    /// Whether the bash process has exited or been torn down.
    public var closed: Bool { lock.withLock { torndown } || !process.isRunning }

    /// Runs `cmd` and returns its output and exit code. A command that runs past `timeout` tears the session down
    /// and throws `BashTimeoutError`; a cancelled task tears it down too, so the next call cannot read the
    /// abandoned command's output.
    public func exec(_ cmd: String, timeout: TimeInterval = BASH_DEFAULT_TIMEOUT) async throws -> BashResult {
        if closed { throw BashSessionTerminatedError() }
        // Per-call nonce so a command that prints a fixed marker can't spoof the exit-code framing. The `''` split
        // keeps the literal out of what is written to stdin; only the shell's printf reassembles it.
        let sentinel = "__ANT_CMD_\(UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased())_DONE__"
        let split = String(sentinel.prefix(8)) + "''" + String(sentinel.dropFirst(8))
        // </dev/null: a stdin-reading command gets EOF instead of blocking on the shared pipe until the timeout.
        let wrapped = "{ \(cmd)\n} </dev/null 2>&1; printf '\\n\(split)%d\\n' $?\n"
        output.reset()
        do {
            try stdin.write(contentsOf: Data(wrapped.utf8))
        } catch {
            await close()
            throw BashSessionTerminatedError()
        }

        let marker = Data(sentinel.utf8)
        let deadline = Date().addingTimeInterval(timeout)
        var data = Data()
        var truncated = false
        do {
            while true {
                let (buffer, cut, eof) = output.snapshot
                let finished = buffer.range(of: marker).map { buffer[$0.upperBound...].contains(0x0A) || eof } ?? eof
                if finished && output.lastArrival > deadline {
                    // The command finished after its deadline; a busy executor only let this poll see it late.
                    await close()
                    throw BashTimeoutError(timeout: timeout)
                }
                if let range = buffer.range(of: marker), buffer[range.upperBound...].contains(0x0A) || eof {
                    (data, truncated) = (buffer, cut)
                    break
                }
                if eof {
                    (data, truncated) = (buffer, cut)
                    break
                }
                if Date() >= deadline {
                    // This call's own deadline fired: tear the process down so the command can't bleed into the next.
                    await close()
                    throw BashTimeoutError(timeout: timeout)
                }
                try await Task.sleep(nanoseconds: 5_000_000)
            }
        } catch is CancellationError {
            await close()
            throw CancellationError()
        }

        let decoded = String(decoding: data, as: UTF8.self)
        let text = ansiEscape.stringByReplacingMatches(in: decoded, range: NSRange(decoded.startIndex..., in: decoded), withTemplate: "")
        guard let markerRange = text.range(of: sentinel, options: .backwards) else {
            return BashResult(output: pythonStrip(text), exitCode: -1)
        }
        var out = String(text[..<markerRange.lowerBound])
        while out.hasSuffix("\n") { out.removeLast() }
        let tail = pythonStrip(String(text[markerRange.upperBound...]))
        let code = tail.split(separator: "\n", omittingEmptySubsequences: false).first.flatMap { Int($0) } ?? -1
        if truncated { out = "[output truncated]\n" + out }
        return BashResult(output: out, exitCode: code)
    }

    /// Closes stdin, kills the process and waits briefly for it to exit.
    public func close() async {
        let first: Bool = lock.withLock {
            defer { torndown = true }
            return !torndown
        }
        guard first else { return }
        try? stdin.close()
        if process.isRunning { kill(process.processIdentifier, SIGKILL) }
        let deadline = Date().addingTimeInterval(2)
        while process.isRunning && Date() < deadline { try? await Task.sleep(nanoseconds: 5_000_000) }
        stdout.readabilityHandler = nil
        try? stdout.close()
    }
}

// MARK: - The tools

private func objectSchema(_ properties: [String: JSONValue], required: [String]) -> [String: JSONValue] {
    ["type": "object", "properties": .object(properties), "required": .array(required.map { .string($0) })]
}

private func stringProperty(_ description: String) -> JSONValue { ["type": "string", "description": .string(description)] }

let BASH_INPUT_SCHEMA = objectSchema([
    "command": stringProperty("Shell command to execute. Omit only when `restart` is true."),
    "restart": ["type": "boolean", "description": "When true, restart the persistent bash session instead of running a command."],
    "timeout_ms": ["type": "integer", "description": "Per-call timeout in milliseconds."],
], required: [])
let READ_INPUT_SCHEMA = objectSchema([
    "file_path": stringProperty("Path of the file to read."),
    "view_range": ["type": "array", "items": ["type": "integer"],
                   "description": "Optional `[start_line, end_line]` 1-indexed inclusive range."],
], required: ["file_path"])
let WRITE_INPUT_SCHEMA = objectSchema([
    "content": stringProperty("Full file contents to write."), "file_path": stringProperty("Path of the file to write."),
], required: ["content", "file_path"])
let EDIT_INPUT_SCHEMA = objectSchema([
    "file_path": stringProperty("Path of the file to edit."), "new_string": stringProperty("Replacement text."),
    "old_string": stringProperty("Substring to find and replace."),
    "replace_all": ["type": "boolean", "description": "When true, replace every occurrence of `old_string`."],
], required: ["file_path", "new_string", "old_string"])
let GLOB_INPUT_SCHEMA = objectSchema([
    "pattern": stringProperty("Doublestar glob pattern (e.g. `**/*.go`)."),
    "path": stringProperty("Optional directory root to search under. Defaults to the runner's working directory."),
], required: ["pattern"])
let GREP_INPUT_SCHEMA = objectSchema([
    "pattern": stringProperty("Regular expression to search for."),
    "path": stringProperty("Optional directory root to search under. Defaults to the runner's working directory."),
], required: ["pattern"])

/// The `bash` tool: a persistent bash session of its own, started on the first call and closed by the tool's close
/// hook (`beta_bash_tool`).
public func betaBashTool(_ ctx: AgentToolContext) -> BetaFunctionTool {
    BetaFunctionTool(name: "bash", description: "Run a command in a persistent bash shell.", inputSchema: BASH_INPUT_SCHEMA, enter: {
        let holder = BashHolder(ctx)
        let run: BetaFunctionTool.Function = { raw in
            let input: BetaManagedAgentsAgentToolset20260401BashInput
            do {
                input = try JSONValue.object(raw).decode()
            } catch {
                throw ValueError("Invalid arguments for function bash")
            }
            return .string(try await holder.run(input))
        }
        return (run, { await holder.close() })
    })
}

/// The bash tool's own session.
private final class BashHolder: @unchecked Sendable {
    let ctx: AgentToolContext
    private let lock = NSLock()
    private var session: BashSession?

    init(_ ctx: AgentToolContext) { self.ctx = ctx }

    private func current() async throws -> BashSession {
        if let s = lock.withLock({ session }) { return s }
        let started = try await BashSession.start(workdir: ctx.workdir, env: ctx.env)
        lock.withLock { session = started }
        return started
    }

    func close() async {
        let s: BashSession? = lock.withLock {
            defer { session = nil }
            return session
        }
        await s?.close()
    }

    func run(_ input: BetaManagedAgentsAgentToolset20260401BashInput) async throws -> String {
        if input.restart == true {
            await close()
            _ = try await current()
            return "bash session restarted"
        }
        guard let command = input.command, !command.isEmpty else { throw ToolError("bash: command is required") }
        let timeout = (input.timeoutMs ?? 0) != 0 ? Double(input.timeoutMs!) / 1000 : BASH_DEFAULT_TIMEOUT
        let result: BashResult
        do {
            result = try await current().exec(command, timeout: timeout)
        } catch let error as BashTimeoutError {
            throw ToolError(.string("bash: \(error)"), cause: error)
        } catch let error as BashSessionTerminatedError {
            throw ToolError(.string("bash: \(error)"), cause: error)
        }
        if result.exitCode != 0 { throw ToolError(result.output) }
        return result.output
    }
}

/// A configured cap: `nil` (not given) selects `defaultValue`, `.some(nil)` disables it (`_resolve_max_bytes`).
private func resolveMaxBytes(_ configured: Int??, _ defaultValue: Int = DEFAULT_MAX_FILE_BYTES) -> Int? {
    switch configured {
    case .none: return defaultValue
    case .some(let value): return value
    }
}

private func fileSuffix(_ path: String) -> String {
    let name = (path as NSString).lastPathComponent
    let ext = (name as NSString).pathExtension
    return ext.isEmpty ? "" : "." + ext.lowercased()
}

private func statFile(_ path: String) throws -> stat {
    var st = stat()
    if stat(path, &st) != 0 { throw AgentFileError(code: errno) }
    return st
}

/// An image or PDF as a base64 `image` / `document` block (`_read_binary_block`). The media caps govern, tightened
/// by an explicitly configured `maxFileBytes`.
private func readBinaryBlock(_ target: String, _ filePath: String, _ size: Int, _ mediaType: String, _ ctx: AgentToolContext) throws
    -> JSONValue
{
    var limit: Int?
    if mediaType == "application/pdf" {
        limit = resolveMaxBytes(ctx.maxPDFBytes, DEFAULT_MAX_PDF_BYTES)
    } else {
        // The image cap is on the encoded form: n raw bytes -> 4*ceil(n/3) base64.
        limit = resolveMaxBytes(ctx.maxImageBase64Bytes, DEFAULT_MAX_IMAGE_BASE64_BYTES).map { ($0 / 4) * 3 }
    }
    if case .some(.some(let explicit)) = ctx.maxFileBytes { limit = limit.map { min($0, explicit) } ?? explicit }
    if let limit, size > limit {
        throw ToolError("read: \(filePath) is \(size) bytes, exceeds \(limit)-byte limit for image/PDF files.")
    }
    let data = try FileOps.readBytes(target).base64EncodedString()
    if mediaType == "application/pdf" {
        return ["type": "document", "source": ["type": "base64", "media_type": "application/pdf", "data": .string(data)]]
    }
    return ["type": "image", "source": ["type": "base64", "media_type": .string(mediaType), "data": .string(data)]]
}

private func toolPathError(_ op: String, _ error: Error) -> Error {
    if let e = error as? ValueError { return ToolError(.string("\(op): \(e.message)"), cause: e) }
    return error
}

/// The `read` tool: a file under the working directory (`beta_read_tool`). Images and PDFs come back as base64
/// content blocks.
public func betaReadTool(_ ctx: AgentToolContext) -> BetaFunctionTool {
    BetaFunctionTool(name: "read", description: "Read a file rooted at the working directory.", inputSchema: READ_INPUT_SCHEMA) {
        (input: BetaManagedAgentsAgentToolset20260401ReadInput) in
        let filePath = input.filePath
        let target: String
        do { target = try resolvePath(ctx, filePath) } catch { throw toolPathError("read", error) }
        let viewRange = input.viewRange ?? []
        if !viewRange.isEmpty && viewRange.count != 2 { throw ToolError("read: view_range must be [start_line, end_line]") }
        let text: String
        do {
            // stat() before any open(): the size cap stops a multi-GB file from exhausting memory, and a FIFO, device
            // or directory is refused without opening it.
            let st = try statFile(target)
            if (st.st_mode & S_IFMT) != S_IFREG { throw ToolError("read: \(filePath): not a regular file") }
            if let mediaType = BINARY_MEDIA_TYPES[fileSuffix(target)] {
                if !viewRange.isEmpty { throw ToolError("read: view_range is not supported for image/PDF files") }
                return .contents([try readBinaryBlock(target, filePath, Int(st.st_size), mediaType, ctx).decode()])
            }
            if let limit = resolveMaxBytes(ctx.maxFileBytes), Int(st.st_size) > limit {
                if viewRange.isEmpty {
                    throw ToolError(
                        "read: \(filePath) is \(st.st_size) bytes, exceeds \(limit)-byte limit. "
                            + "Use the view_range parameter to read specific line ranges, e.g. view_range: [1, 500].")
                }
                return .string(try readLineRange(target, filePath: filePath, startLine: viewRange[0], endLine: viewRange[1], limit: limit))
            }
            text = try FileOps.readTextExact(target)
        } catch let error as ToolError {
            throw error
        } catch is ValueError {
            throw ToolError("read: \(filePath): not valid UTF-8 text (binary files are only supported for image/PDF extensions)")
        } catch let error as AgentFileError {
            throw fsError("read", filePath, error.code)
        } catch let error as ToolFileSystemError {
            throw fsError("read", filePath, error.code)
        }
        if viewRange.isEmpty { return .string(text) }
        let lines = CodePoints(text).split("\n")
        let start = max(0, viewRange[0] - 1)
        let end = viewRange[1] > 0 ? viewRange[1] : lines.count
        let lo = min(start, lines.count)
        let hi = min(max(end, lo), lines.count)
        return .string(lines[lo..<hi].joined(separator: "\n"))
    }
}

/// UTF-8 bytes to `path`, created or truncated, without newline translation (`write_text_exact`).
private func writeTextExact(_ path: String, _ text: String) throws {
    let fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0o644)
    if fd < 0 { throw AgentFileError(code: errno) }
    defer { _ = close(fd) }
    let data = Array(text.utf8)
    var offset = 0
    while offset < data.count {
        let n = data[offset...].withUnsafeBytes { write(fd, $0.baseAddress, $0.count) }
        if n < 0 { throw AgentFileError(code: errno) }
        offset += n
    }
}

private func makeParents(_ path: String) throws {
    let parent = splitPath(path).0
    do {
        try FileManager.default.createDirectory(atPath: parent, withIntermediateDirectories: true)
    } catch {
        var st = stat()
        if stat(parent, &st) == 0 && (st.st_mode & S_IFMT) == S_IFDIR { return }
        throw AgentFileError(code: (error as NSError).code == NSFileWriteNoPermissionError ? EACCES : ENOTDIR)
    }
}

/// The `write` tool: writes a file, creating parent directories as needed (`beta_write_tool`).
public func betaWriteTool(_ ctx: AgentToolContext) -> BetaFunctionTool {
    BetaFunctionTool(name: "write", description: "Write a file, creating parent directories as needed.",
                     inputSchema: WRITE_INPUT_SCHEMA) { (input: BetaManagedAgentsAgentToolset20260401WriteInput) in
        let target: String
        do { target = try resolvePath(ctx, input.filePath) } catch { throw toolPathError("write", error) }
        try rejectReadOnly(ctx, target, op: "write", filePath: input.filePath)
        do {
            try makeParents(target)
            try writeTextExact(target, input.content)
        } catch let error as AgentFileError {
            throw fsError("write", input.filePath, error.code)
        }
        return .string("wrote \(input.content.unicodeScalars.count) bytes to \(input.filePath)")
    }
}

/// The `edit` tool: an exact string replacement in a file (`beta_edit_tool`).
public func betaEditTool(_ ctx: AgentToolContext) -> BetaFunctionTool {
    BetaFunctionTool(name: "edit", description: "Replace text in a file by exact string match.", inputSchema: EDIT_INPUT_SCHEMA) {
        (input: BetaManagedAgentsAgentToolset20260401EditInput) in
        let filePath = input.filePath
        let target: String
        do { target = try resolvePath(ctx, filePath) } catch { throw toolPathError("edit", error) }
        try rejectReadOnly(ctx, target, op: "edit", filePath: filePath)
        let text: String
        do {
            let st = try statFile(target)
            if (st.st_mode & S_IFMT) != S_IFREG { throw ToolError("edit: \(filePath): not a regular file") }
            if let limit = resolveMaxBytes(ctx.maxFileBytes), Int(st.st_size) > limit {
                throw ToolError(
                    "edit: \(filePath) is \(st.st_size) bytes, exceeds \(limit)-byte limit. "
                        + "The edit tool loads the whole file and cannot modify a file this large.")
            }
            text = try FileOps.readTextExact(target)
        } catch let error as ToolError {
            throw error
        } catch is ValueError {
            throw ToolError("edit: \(filePath): not valid UTF-8 text (cannot edit binary files)")
        } catch let error as AgentFileError {
            throw fsError("edit", filePath, error.code)
        } catch let error as ToolFileSystemError {
            throw fsError("edit", filePath, error.code)
        }
        let source = CodePoints(text)
        let old = CodePoints(input.oldString)
        let count = source.occurrences(old)
        if count == 0 { throw ToolError("edit: old_string not found in \(filePath)") }
        let replaceAll = input.replaceAll == true
        if !replaceAll && count > 1 { throw ToolError("edit: old_string appears \(count) times in \(filePath) (must be unique)") }
        let updated: String
        if replaceAll {
            updated = source.replacing(old, with: CodePoints(input.newString)).string
        } else {
            let at = source.find(old)!
            updated = CodePoints(Array(source.scalars[..<at]) + Array(input.newString.unicodeScalars)
                + Array(source.scalars[(at + old.count)...])).string
        }
        do {
            try writeTextExact(target, updated)
        } catch let error as AgentFileError {
            throw fsError("edit", filePath, error.code)
        }
        return .string("edited \(filePath) (\(replaceAll ? count : 1) replacement(s))")
    }
}

// MARK: - glob

/// `fnmatch`'s translation of one glob segment into an anchored regular expression.
private func segmentRegex(_ segment: String) -> NSRegularExpression? {
    var pattern = "^"
    var chars = Array(segment)
    var i = 0
    while i < chars.count {
        let c = chars[i]
        switch c {
        case "*": pattern += ".*"
        case "?": pattern += "."
        case "[":
            var j = i + 1
            if j < chars.count && chars[j] == "!" { j += 1 }
            if j < chars.count && chars[j] == "]" { j += 1 }
            while j < chars.count && chars[j] != "]" { j += 1 }
            if j >= chars.count {
                pattern += "\\["
            } else {
                var body = String(chars[(i + 1)..<j]).replacingOccurrences(of: "\\", with: "\\\\")
                if body.hasPrefix("!") { body = "^" + body.dropFirst() } else if body.hasPrefix("^") { body = "\\" + body }
                pattern += "[\(body)]"
                i = j
            }
        default: pattern += NSRegularExpression.escapedPattern(for: String(c))
        }
        i += 1
    }
    chars = []
    return try? NSRegularExpression(pattern: pattern + "$", options: [.dotMatchesLineSeparators])
}

private func matches(_ regex: NSRegularExpression, _ name: String) -> Bool {
    regex.firstMatch(in: name, range: NSRange(name.startIndex..., in: name)) != nil
}

private func listDirectory(_ path: String) -> [String] {
    ((try? FileManager.default.contentsOfDirectory(atPath: path)) ?? []).sorted()
}

private func isDirectoryFollowing(_ path: String) -> Bool { FileOps.isDirectory(path) }

/// `Path(root).glob(pattern)`, capped at `limit` matches: `*`, `?` and `[...]` within a segment, `**` for any
/// depth of directories (not descending through symlinked directories).
func globMatches(_ root: String, _ pattern: String, limit: Int = WALK_MAX_ENTRIES) -> [String] {
    let segments = pattern.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
    var results: [String] = []
    var seen = Set<String>()

    func walk(_ dir: String, _ index: Int) {
        if results.count >= limit { return }
        if index == segments.count {
            if seen.insert(dir).inserted { results.append(dir) }
            return
        }
        let segment = segments[index]
        let last = index == segments.count - 1
        if segment == "**" {
            // zero directories, then each directory below, recursively
            if last {
                // `**` alone matches the directories under `dir`, itself included
                walk(dir, index + 1)
            } else {
                walk(dir, index + 1)
            }
            for name in listDirectory(dir) {
                let child = posixJoin(dir, name)
                if FileOps.isDirectory(child) && !FileOps.isSymlink(child) { walk(child, index) }
                if results.count >= limit { return }
            }
            return
        }
        if segment == "." {
            walk(dir, index + 1)
            return
        }
        guard let regex = segmentRegex(segment) else { return }
        for name in listDirectory(dir) where matches(regex, name) {
            let child = posixJoin(dir, name)
            if last {
                if seen.insert(child).inserted { results.append(child) }
            } else if isDirectoryFollowing(child) {
                walk(child, index + 1)
            }
            if results.count >= limit { return }
        }
    }

    walk(root, 0)
    return results
}

private func mtime(_ path: String) -> Double {
    let date = (try? FileManager.default.attributesOfItem(atPath: path))?[.modificationDate] as? Date
    return date?.timeIntervalSince1970 ?? 0
}

/// The `glob` tool: files matching a glob pattern, newest first (`beta_glob_tool`).
public func betaGlobTool(_ ctx: AgentToolContext) -> BetaFunctionTool {
    BetaFunctionTool(name: "glob", description: "List files matching a glob pattern, newest first.", inputSchema: GLOB_INPUT_SCHEMA) {
        (input: BetaManagedAgentsAgentToolset20260401GlobInput) in
        if input.pattern.hasPrefix("/") {
            throw ToolError("glob: absolute pattern not permitted; pass a relative pattern (and optionally path)")
        }
        // A literal `..` segment would escape the workdir before resolvePath is ever consulted.
        if input.pattern.split(separator: "/").contains("..") { throw ToolError("glob: '..' is not permitted in the pattern") }
        let root: String
        if let path = input.path, !path.isEmpty {
            do { root = try resolvePath(ctx, path) } catch { throw toolPathError("glob", error) }
        } else {
            root = FileOps.resolve(ctx.workdir)
        }
        // Post-filter: a symlink traversed mid-pattern must not let a result escape the search root, and a match
        // that cannot be canonicalised (a loop, an unreadable component) is dropped.
        let confined = globMatches(root, input.pattern).filter { match in
            guard let canonical = try? canonicalize(match) else { return false }
            return isWithin(canonical, root)
        }
        if confined.isEmpty { return .string("no matches") }
        let sorted = confined.map { ($0, mtime($0)) }.sorted { $0.1 > $1.1 }.map(\.0)
        return .string(sorted.prefix(GLOB_RESULT_LIMIT).joined(separator: "\n"))
    }
}

// MARK: - grep

enum AgentToolset {
    /// Finds `rg` on `PATH` (`shutil.which("rg")`); task-local so a test can take ripgrep away.
    @TaskLocal static var findRipgrep: @Sendable () -> String? = {
        for dir in (ProcessInfo.processInfo.environment["PATH"] ?? "").split(separator: ":") {
            let candidate = posixJoin(String(dir), "rg")
            if access(candidate, X_OK) == 0 { return candidate }
        }
        return nil
    }
}

/// A process handed to the threads that wait on it.
private final class AgentProcessBox: @unchecked Sendable {
    let process = Process()
    let out = Pipe()
    let err = Pipe()
    var stderr = Data()
}

/// Runs a process to completion, collecting its output.
private func runProcess(_ executable: String, _ arguments: [String]) async throws -> (Int32, Data, Data) {
    let box = AgentProcessBox()
    box.process.executableURL = URL(fileURLWithPath: executable)
    box.process.arguments = arguments
    box.process.standardOutput = box.out
    box.process.standardError = box.err
    box.process.standardInput = FileHandle.nullDevice
    try box.process.run()
    return await withCheckedContinuation { (continuation: CheckedContinuation<(Int32, Data, Data), Never>) in
        DispatchQueue.global().async {
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.global().async {
                box.stderr = box.err.fileHandleForReading.readDataToEndOfFile()
                group.leave()
            }
            let stdout = box.out.fileHandleForReading.readDataToEndOfFile()
            group.wait()
            box.process.waitUntilExit()
            continuation.resume(returning: (box.process.terminationStatus, stdout, box.stderr))
        }
    }
}

/// The `grep` tool: file contents matching a regular expression, with `rg` when it is installed and a walker
/// otherwise (`beta_grep_tool`).
public func betaGrepTool(_ ctx: AgentToolContext) -> BetaFunctionTool {
    BetaFunctionTool(name: "grep", description: "Search file contents for a regular expression.", inputSchema: GREP_INPUT_SCHEMA) {
        (input: BetaManagedAgentsAgentToolset20260401GrepInput) in
        let search: String
        if let path = input.path, !path.isEmpty {
            do { search = try resolvePath(ctx, path) } catch { throw toolPathError("grep", error) }
        } else {
            search = FileOps.resolve(ctx.workdir)
        }
        if let rg = AgentToolset.findRipgrep() {
            let (status, stdout, stderr) = try await runProcess(rg, ["-n", "--no-heading", "-e", input.pattern, "--", search])
            // ripgrep exits 1 on "no matches", which isn't an error here
            if status == 1 { return .string("no matches") }
            if status != 0 { throw ToolError("grep: rg failed: \(String(decoding: stderr, as: UTF8.self))") }
            var out = String(decoding: stdout, as: UTF8.self)
            if out.unicodeScalars.count > GREP_OUTPUT_LIMIT {
                out = prefixCodePoints(out, GREP_OUTPUT_LIMIT) + "\n[output truncated at \(GREP_OUTPUT_LIMIT) bytes]"
            }
            return .string(out)
        }
        let regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: input.pattern)
        } catch {
            throw ToolError("grep: invalid regex: \(error.localizedDescription)")
        }
        return .string(walkGrep(regex, search))
    }
}

private func walkGrep(_ regex: NSRegularExpression, _ search: String) -> String {
    var hits: [String] = []
    var budget = GREP_OUTPUT_LIMIT

    func push(_ line: String) -> Bool {
        budget -= line.unicodeScalars.count + 1
        if budget < 0 {
            hits.append("[output truncated at \(GREP_OUTPUT_LIMIT) bytes]")
            return false
        }
        hits.append(line)
        return true
    }

    func scan(_ full: String) -> Bool {
        guard let data = try? FileOps.readBytes(full) else { return true }
        if data.prefix(512).contains(0) { return true }  // binary
        var lineNumber = 0
        var start = data.startIndex
        while start < data.endIndex {
            let newline = data[start...].firstIndex(of: 0x0A)
            let end = newline.map { $0 + 1 } ?? data.endIndex
            lineNumber += 1
            let raw = data[start..<end]
            start = end
            // Cap line length: `pattern` is model-supplied, so a pathological one against a very long line is a ReDoS.
            if raw.count > GREP_MAX_LINE_LENGTH { continue }
            var line = String(decoding: raw, as: UTF8.self)
            while line.hasSuffix("\n") || line.hasSuffix("\r") || line.hasSuffix("\r\n") { line.removeLast() }
            if regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) != nil && !push("\(full):\(lineNumber):\(line)") {
                return false
            }
        }
        return true
    }

    if FileOps.isFile(search) {
        _ = scan(search)
    } else {
        var seen = 0
        var stack = [search]
        while let dir = stack.popLast() {
            var subdirs: [String] = []
            for name in listDirectory(dir) {
                let full = posixJoin(dir, name)
                // Never descend into a symlinked directory, and never read through a symlinked file.
                if FileOps.isSymlink(full) { continue }
                if FileOps.isDirectory(full) {
                    if name != ".git" && name != "node_modules" { subdirs.append(full) }
                    continue
                }
                seen += 1
                if seen > WALK_MAX_ENTRIES || !scan(full) { return hits.isEmpty ? "no matches" : hits.joined(separator: "\n") }
            }
            stack.append(contentsOf: subdirs.reversed())
        }
    }
    return hits.isEmpty ? "no matches" : hits.joined(separator: "\n")
}

/// The `agent_toolset_20260401` implementations bound to `ctx`, as a plain list callers can filter or extend
/// (`beta_agent_toolset_20260401`).
public func betaAgentToolset20260401(_ ctx: AgentToolContext) -> [BetaFunctionTool] {
    [betaBashTool(ctx), betaReadTool(ctx), betaWriteTool(ctx), betaEditTool(ctx), betaGlobTool(ctx), betaGrepTool(ctx)]
}
