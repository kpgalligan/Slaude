// The fixtures of tests/lib/tools/memory_sync (`_fake_anthropic.py`, `conftest.py`).
//
// A memory store is a folder: path → content. `MemorySyncServer` is that dict plus a log of the writes the code under
// test sent it. Paths are bare (`"push.md"`); the leading `/` the wire uses is added and stripped internally so tests
// use one path vocabulary throughout.

import Foundation
import Testing
@testable import Anthropic

func memorySyncSHA(_ content: String) -> String { ToolsSHA256.hex(Data(content.utf8)) }

func memorySyncStatusError(_ code: Int) -> APIStatusError {
    let request = HTTPRequest(method: "POST", url: URL(string: "https://api.example/v1/memory")!)
    return APIStatusError("status \(code)", response: HTTPResponse(statusCode: code, body: Data(), request: request), body: nil)
}

/// A request recorded on `MemorySyncServer.received`, in domain terms: paths and content. `sha` is the sha of the
/// pre-image the request's precondition guards on.
struct MemorySyncCall: Equatable, Sendable, CustomStringConvertible {
    var kind: String
    var path: String
    var content: String?
    var sha: String?

    var description: String { "(\(kind), \(path), \(content ?? "nil"), \(sha ?? "nil"))" }
}

func memorySyncCreated(_ path: String, _ content: String) -> MemorySyncCall {
    MemorySyncCall(kind: "create", path: path, content: content, sha: nil)
}

func memorySyncUpdated(_ path: String, _ content: String, was: String) -> MemorySyncCall {
    MemorySyncCall(kind: "update", path: path, content: content, sha: memorySyncSHA(was))
}

func memorySyncDeleted(_ path: String, was: String) -> MemorySyncCall {
    MemorySyncCall(kind: "delete", path: path, content: nil, sha: memorySyncSHA(was))
}

/// A Python-style `RuntimeError` for fakes to raise.
struct MemorySyncRuntimeError: Error, CustomStringConvertible {
    let message: String
    init(_ message: String) { self.message = message }
    var description: String { message }
}

/// The test's view of one remote memory store (`MemoryServer`).
///
/// `files` is its current state (path → content, `nil` content being a memory with null content); `received` is
/// every write the code under test sent it. Arranging via `write` / `delete` changes `files` without touching
/// `received`.
final class MemorySyncServer: @unchecked Sendable {
    private let lock = NSLock()
    private var _files: [String: String?]
    private var _received: [MemorySyncCall] = []
    private var _contentFetches: [String] = []
    /// Reject create/update content larger than this with a 400, like the real server's per-memory cap.
    var maxContentBytes: Int? {
        get { lock.withLock { _maxContentBytes } }
        set { lock.withLock { _maxContentBytes = newValue } }
    }
    private var _maxContentBytes: Int?
    /// Called with the path as each content fetch arrives — throw to break the fetch, or delete the path to race it.
    var fetchHook: (@Sendable (String) throws -> Void)? {
        get { lock.withLock { _fetchHook } }
        set { lock.withLock { _fetchHook = newValue } }
    }
    private var _fetchHook: (@Sendable (String) throws -> Void)?
    /// Awaited with the path as each create/update arrives, before the request is recorded.
    var uploadHook: (@Sendable (String) async throws -> Void)? {
        get { lock.withLock { _uploadHook } }
        set { lock.withLock { _uploadHook = newValue } }
    }
    private var _uploadHook: (@Sendable (String) async throws -> Void)?

    init(_ initial: [String: String?]) { _files = initial }
    convenience init(_ initial: [String: String]) { self.init(initial.mapValues { Optional($0) }) }

    /// The current contents, null content read as `nil`.
    var files: [String: String?] { lock.withLock { _files } }
    /// The current contents as text (null content reads as "").
    var texts: [String: String] { files.mapValues { $0 ?? "" } }
    var received: [MemorySyncCall] { lock.withLock { _received } }
    var contentFetches: [String] { lock.withLock { _contentFetches } }

    func write(_ path: String, _ content: String?) { lock.withLock { _files[path] = .some(content) } }
    func delete(_ path: String) { lock.withLock { _files[path] = nil } }
    func has(_ path: String) -> Bool { lock.withLock { _files[path] != nil } }

    func record(_ call: MemorySyncCall) { lock.withLock { _received.append(call) } }
    func noteFetch(_ path: String) { lock.withLock { _contentFetches.append(path) } }
    func clearFetches() { lock.withLock { _contentFetches = [] } }
    func content(_ path: String) -> String?? { lock.withLock { _files[path] } }
    func paths() -> [String] { lock.withLock { Array(_files.keys) } }
}

/// The SDK-shaped resource `SessionMemoryStores` calls, over a `MemorySyncServer` (`_Resource`). Items are built
/// on the fly from `server.files`; ids are derived from paths. Each call can be wrapped by a test.
final class MemorySyncFakeMemories: SessionMemoriesAPI, @unchecked Sendable {
    typealias Real = @Sendable () async throws -> SessionMemoryItem
    let server: MemorySyncServer
    let noise: Bool
    private let lock = NSLock()
    private var _wrapUpdate: (@Sendable (String, Real) async throws -> SessionMemoryItem)?
    private var _wrapCreate: (@Sendable (String, Real) async throws -> SessionMemoryItem)?
    private var _wrapRetrieve: (@Sendable (String, Real) async throws -> SessionMemoryItem)?
    private var _wrapList: (@Sendable (String) async throws -> Void)?

    init(_ server: MemorySyncServer, noise: Bool = false) {
        self.server = server
        self.noise = noise
    }

    /// Wraps `update` (by memory path): call the real update, or not.
    var wrapUpdate: (@Sendable (String, Real) async throws -> SessionMemoryItem)? {
        get { lock.withLock { _wrapUpdate } }
        set { lock.withLock { _wrapUpdate = newValue } }
    }
    var wrapCreate: (@Sendable (String, Real) async throws -> SessionMemoryItem)? {
        get { lock.withLock { _wrapCreate } }
        set { lock.withLock { _wrapCreate = newValue } }
    }
    var wrapRetrieve: (@Sendable (String, Real) async throws -> SessionMemoryItem)? {
        get { lock.withLock { _wrapRetrieve } }
        set { lock.withLock { _wrapRetrieve = newValue } }
    }
    /// Awaited before a listing yields anything (by store id).
    var wrapList: (@Sendable (String) async throws -> Void)? {
        get { lock.withLock { _wrapList } }
        set { lock.withLock { _wrapList = newValue } }
    }

    private func item(_ path: String, view: String = "full") throws -> SessionMemoryItem {
        guard let content = server.content(path) else { throw memorySyncStatusError(404) }
        return SessionMemoryItem(type: "memory", id: "mem:\(path)", path: "/" + path, content: view == "full" ? content : nil,
                                 contentSHA256: memorySyncSHA(content ?? ""))
    }

    func list(_ memoryStoreID: String, view: String, limit: Int) async throws -> AsyncThrowingStream<SessionMemoryItem, Error> {
        let wrap = wrapList
        let server = self.server
        let noise = self.noise
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try await wrap?(memoryStoreID)
                    if noise {
                        // Depth-limited listings roll directories up as prefixes; only `memory` items carry content.
                        continuation.yield(SessionMemoryItem(type: "memory_prefix", id: "", path: "/projects/", content: nil, contentSHA256: ""))
                    }
                    if memoryStoreID == "memstore_broken" {
                        // One memory is listed, then the pager explodes.
                        continuation.yield(SessionMemoryItem(type: "memory", id: "mem:half", path: "/half.md",
                                                             content: view == "full" ? "partial" : nil, contentSHA256: memorySyncSHA("partial")))
                        throw MemorySyncRuntimeError("list exploded")
                    }
                    for path in server.paths().sorted() {
                        if let item = try? self.item(path, view: view) { continuation.yield(item) }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func retrieve(_ memoryID: String, memoryStoreID: String, view: String) async throws -> SessionMemoryItem {
        let path = String(memoryID.dropFirst("mem:".count))
        let real: Real = { [self] in
            server.noteFetch(path)
            try server.fetchHook?(path)
            return try item(path, view: view)
        }
        if let wrap = wrapRetrieve { return try await wrap(path, real) }
        return try await real()
    }

    private func checkSize(_ content: String) throws {
        if let cap = server.maxContentBytes, content.utf8.count > cap { throw memorySyncStatusError(400) }
    }

    func create(_ memoryStoreID: String, path: String, content: String) async throws -> SessionMemoryItem {
        var bare = Substring(path)
        while bare.hasPrefix("/") { bare = bare.dropFirst() }
        let rel = String(bare)
        let real: Real = { [self] in
            try await server.uploadHook?(rel)
            server.record(memorySyncCreated(rel, content))
            try checkSize(content)
            server.write(rel, content)
            return try item(rel)
        }
        if let wrap = wrapCreate { return try await wrap(rel, real) }
        return try await real()
    }

    func update(_ memoryID: String, memoryStoreID: String, content: String, preconditionSHA256: String) async throws -> SessionMemoryItem {
        let path = String(memoryID.dropFirst("mem:".count))
        let real: Real = { [self] in
            try await server.uploadHook?(path)
            server.record(MemorySyncCall(kind: "update", path: path, content: content, sha: preconditionSHA256))
            try checkSize(content)
            guard let current = server.content(path) else { throw memorySyncStatusError(404) }
            if memorySyncSHA(current ?? "") != preconditionSHA256 { throw memorySyncStatusError(409) }
            server.write(path, content)
            return try item(path)
        }
        if let wrap = wrapUpdate { return try await wrap(path, real) }
        return try await real()
    }

    func delete(_ memoryID: String, memoryStoreID: String, expectedContentSHA256: String?) async throws {
        let path = String(memoryID.dropFirst("mem:".count))
        server.record(MemorySyncCall(kind: "delete", path: path, content: nil, sha: expectedContentSHA256))
        guard let current = server.content(path) else { throw memorySyncStatusError(404) }
        if let expected = expectedContentSHA256, memorySyncSHA(current ?? "") != expected { throw memorySyncStatusError(409) }
        server.delete(path)
    }
}

/// A settable stand-in for the module's `monotonic` (`Clock`).
final class MemorySyncClock: @unchecked Sendable {
    private let lock = NSLock()
    private var _now: TimeInterval = 0
    var now: TimeInterval {
        get { lock.withLock { _now } }
        set { lock.withLock { _now = newValue } }
    }
    var function: @Sendable () -> TimeInterval { { [self] in now } }
}

/// One memory store named `notes` (`fake_anthropic`), landing at `{workdir}/memory/notes` without a `mount_path`.
/// `broken` attaches a second store, ahead of `notes`, whose listing explodes after one memory; `brokenLast` puts
/// it after.
struct MemorySyncFake {
    let server: MemorySyncServer
    let memories: MemorySyncFakeMemories
    let resources: [BetaManagedAgentsMemoryStoreResource]

    init(_ initial: [String: String?], access: BetaManagedAgentsMemoryStoreResource.Access? = nil, broken: Bool = false,
         brokenLast: Bool = false, noStores: Bool = false, mountPath: String? = nil, noise: Bool = false)
    {
        server = MemorySyncServer(initial)
        memories = MemorySyncFakeMemories(server, noise: noise)
        var resources: [BetaManagedAgentsMemoryStoreResource] = noStores ? [] : [
            BetaManagedAgentsMemoryStoreResource(memoryStoreID: "memstore_notes", access: access, mountPath: mountPath, name: "notes"),
        ]
        let brokenStore = BetaManagedAgentsMemoryStoreResource(memoryStoreID: "memstore_broken", name: "broken")
        if brokenLast {
            resources.append(brokenStore)
        } else if broken {
            resources.insert(brokenStore, at: 0)
        }
        self.resources = resources
    }

    init(_ initial: [String: String], access: BetaManagedAgentsMemoryStoreResource.Access? = nil, broken: Bool = false,
         brokenLast: Bool = false, noStores: Bool = false, mountPath: String? = nil, noise: Bool = false)
    {
        self.init(initial.mapValues { Optional($0) }, access: access, broken: broken, brokenLast: brokenLast, noStores: noStores,
                  mountPath: mountPath, noise: noise)
    }

    func stores(workdir: String, clock: MemorySyncClock? = nil, syncInterval: TimeInterval = DEFAULT_MEMORY_SYNC_INTERVAL,
                syncDeletions: MemoryDeleteMode = .enabled) throws -> SessionMemoryStores
    {
        var monotonic: @Sendable () -> TimeInterval = { 0 }
        if let clock { monotonic = clock.function }
        let api: any SessionMemoriesAPI = memories
        let stores: SessionMemoryStores = try SessionMemoryStores(
            memories: api, workdir: workdir, syncInterval: syncInterval, syncDeletions: syncDeletions, monotonic: monotonic)
        return stores
    }
}

/// A fresh temporary directory (`tmp_path`).
func memorySyncTempDir() throws -> String {
    let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("memsync-\(UUID().uuidString)")
    try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
    return FileOps.resolve(path)
}

/// `_downloaded`: a `SessionMemoryStores` with one store already downloaded to disk.
func memorySyncDownloaded(_ initial: [String: String], access: BetaManagedAgentsMemoryStoreResource.Access? = nil,
                          clock: MemorySyncClock? = nil, syncDeletions: MemoryDeleteMode = .enabled) async throws
    -> (local: MemorySyncFolder, fake: MemorySyncFake, stores: SessionMemoryStores, tmp: String)
{
    let tmp = try memorySyncTempDir()
    let fake = MemorySyncFake(initial, access: access)
    let stores = try fake.stores(workdir: tmp, clock: clock, syncDeletions: syncDeletions)
    try await stores.download(resources: fake.resources)
    return (MemorySyncFolder(tmp + "/memory/notes"), fake, stores, tmp)
}

/// `run_sync`: one reconcile pass without clock bookkeeping.
func memorySyncRun(_ stores: SessionMemoryStores) async {
    await stores.syncAll(final: false)
}

/// The text of the captured log records (`caplog.text`).
func memorySyncLogText(_ capture: ToolDiagnostics.Capture, atLeast level: ToolDiagnostics.Level = .debug) -> String {
    capture.records.filter { $0.level >= level }.map { "\($0.level) \($0.logger): \($0.message)" }.joined(separator: "\n")
}

/// A folder on disk, as the tests read and write it (`pathlib.Path`).
struct MemorySyncFolder: Sendable, CustomStringConvertible {
    let path: String
    init(_ path: String) { self.path = path }

    var description: String { path }

    func file(_ rel: String) -> String { (path as NSString).appendingPathComponent(rel) }

    func read(_ rel: String) -> String? { FileManager.default.contents(atPath: file(rel)).map { String(decoding: $0, as: UTF8.self) } }

    func write(_ rel: String, _ text: String) throws { try writeBytes(rel, Data(text.utf8)) }

    func writeBytes(_ rel: String, _ data: Data) throws {
        let full = file(rel)
        try FileManager.default.createDirectory(atPath: (full as NSString).deletingLastPathComponent, withIntermediateDirectories: true)
        // Remove first so a rewrite gets a fresh inode and ctime, as `write_text` over an unlinked file would.
        try data.write(to: URL(fileURLWithPath: full))
    }

    func exists(_ rel: String = "") -> Bool {
        FileManager.default.fileExists(atPath: rel.isEmpty ? path : file(rel))
    }

    func unlink(_ rel: String) throws { try FileManager.default.removeItem(atPath: file(rel)) }

    func removeTree() throws { try FileManager.default.removeItem(atPath: path) }

    /// The relative paths of every file below the folder.
    func files() -> [String] {
        guard let e = FileManager.default.enumerator(atPath: path) else { return [] }
        var out: [String] = []
        while let rel = e.nextObject() as? String {
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: file(rel), isDirectory: &isDir), !isDir.boolValue { out.append(rel) }
        }
        return out.sorted()
    }
}
