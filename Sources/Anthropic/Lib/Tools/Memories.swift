// Port of `anthropic/lib/tools/_memories.py`: session-level memory-store download and sync.
//
// A session may have several memory stores attached. This resolves where each store's folder goes on disk, opens a
// `FileStore` there, and reconciles each folder with its remote store — the merge rules live on
// `SessionMemoryStores`.

import Foundation

/// Whether a locally deleted file may delete its server memory — `.logOnly` is the dry run.
public enum MemoryDeleteMode: String, Sendable, CaseIterable {
    case enabled
    case logOnly = "log_only"
    case disabled
}

/// How often (seconds) the worker syncs the session's memory stores back while the session runs. Checked after each
/// dispatched tool call.
public let DEFAULT_MEMORY_SYNC_INTERVAL: TimeInterval = 15

/// Smallest sync interval (seconds). Anything below it is rejected — each sync lists every attached store, so
/// sub-second cadences would hammer the memory endpoints.
public let MIN_MEMORY_SYNC_INTERVAL: TimeInterval = 5

/// Bound (seconds) the worker puts on each shielded teardown pass — the final sync, then the flush — so a slow server
/// cannot stall teardown.
public let MEMORY_FLUSH_TIMEOUT: TimeInterval = 30

/// Reserved marker at every store root — two lines: `version <n>` and the store's `memory_store_id`; a sync trusts the
/// folder only when both match. Never itself synced.
public let MARKER_PATH = ".anthropic-memory-store"

let MARKER_VERSION = 1

/// How long (seconds) a file must stay missing before its server delete goes out.
public let DELETE_CORROBORATION_SECONDS: TimeInterval = 30

/// Page sizes for memory listings — the API's maximum per view: `basic` pages carry up to 100 items, `full` pages are
/// capped by the server.
let MEMORY_LIST_PAGE_SIZE = 100
let MEMORY_FULL_LIST_PAGE_SIZE = 20

/// How many single-memory content fetches may be in flight at once during one store's pull pass.
let MEMORY_FETCH_CONCURRENCY = 16

/// How many uploads one store's flush keeps in flight.
let MEMORY_UPLOAD_CONCURRENCY = 32

/// Bounds of the per-sync delete cap — the floor keeps small stores' legitimate deletions from crawling.
let MEMORY_DELETE_CAP_FLOOR = 8
let MEMORY_DELETE_CAP_CEILING = 50

let memoryLog = ToolLogger(name: "anthropic.lib.tools.agent_toolset")

func checkSyncInterval(_ interval: TimeInterval) throws {
    // Phrased so NaN fails: `NaN < floor` is false, so the inverse test would wave NaN through.
    if !(interval >= MIN_MEMORY_SYNC_INTERVAL) {
        throw ValueError("sync interval must be at least \(pythonFloat(MIN_MEMORY_SYNC_INTERVAL)) seconds, got \(pythonFloat(interval))")
    }
}

/// Python's `str(float)` for the values the messages print.
private func pythonFloat(_ value: Double) -> String {
    if value.isNaN { return "nan" }
    if value.isInfinite { return value > 0 ? "inf" : "-inf" }
    if value == value.rounded() && abs(value) < 1e16 { return String(format: "%.1f", value) }
    return "\(value)"
}

func markerSHA(_ memoryStoreID: String) -> String {
    ToolsSHA256.hex(Data("version \(MARKER_VERSION)\n\(memoryStoreID)".utf8))
}

/// A memory store could not be materialised on disk (`SessionMemoryError`). Raised by
/// `SessionMemoryStores.download`; the worker lets it fail the work item.
public struct SessionMemoryError: Error, CustomStringConvertible, Sendable {
    public let message: String
    public init(_ message: String) { self.message = message }
    public var description: String { message }
}

/// One memory as the sync sees it (the fields of `BetaManagedAgentsMemory` it reads, or a `memory_prefix` rollup).
struct SessionMemoryItem: Sendable, Hashable {
    var type: String
    var id: String
    var path: String
    var content: String?
    var contentSHA256: String
}

/// The memory endpoints the sync calls (`client.beta.memory_stores.memories`): the generated resource, or a fake.
protocol SessionMemoriesAPI: Sendable {
    func list(_ memoryStoreID: String, view: String, limit: Int) async throws -> AsyncThrowingStream<SessionMemoryItem, Error>
    func retrieve(_ memoryID: String, memoryStoreID: String, view: String) async throws -> SessionMemoryItem
    func create(_ memoryStoreID: String, path: String, content: String) async throws -> SessionMemoryItem
    func update(_ memoryID: String, memoryStoreID: String, content: String, preconditionSHA256: String) async throws -> SessionMemoryItem
    func delete(_ memoryID: String, memoryStoreID: String, expectedContentSHA256: String?) async throws
}

extension SessionMemoryItem {
    init(_ memory: BetaManagedAgentsMemory) {
        self.init(type: memory.type, id: memory.id, path: memory.path, content: memory.content, contentSHA256: memory.contentSha256)
    }
}

extension BetaMemoryStoresMemoriesResource: SessionMemoriesAPI {
    func list(_ memoryStoreID: String, view: String, limit: Int) async throws -> AsyncThrowingStream<SessionMemoryItem, Error> {
        let page = try await list(memoryStoreID, limit: limit, view: BetaManagedAgentsMemoryView(rawValue: view))
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await item in page {
                        switch item {
                        case .memory(let memory): continuation.yield(SessionMemoryItem(memory))
                        case .memoryPrefix(let prefix):
                            continuation.yield(SessionMemoryItem(type: prefix.type, id: "", path: prefix.path, content: nil, contentSHA256: ""))
                        case .unknown(let value):
                            continuation.yield(SessionMemoryItem(type: value["type"]?.stringValue ?? "", id: "", path: "", content: nil,
                                                                 contentSHA256: ""))
                        }
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
        SessionMemoryItem(try await retrieve(memoryID, memoryStoreID: memoryStoreID, view: BetaManagedAgentsMemoryView(rawValue: view)))
    }

    func create(_ memoryStoreID: String, path: String, content: String) async throws -> SessionMemoryItem {
        SessionMemoryItem(try await create(memoryStoreID, content: content, path: path))
    }

    func update(_ memoryID: String, memoryStoreID: String, content: String, preconditionSHA256: String) async throws -> SessionMemoryItem {
        SessionMemoryItem(try await update(
            memoryID, memoryStoreID: memoryStoreID, content: .some(content),
            precondition: BetaManagedAgentsPreconditionParam(type: "content_sha256", contentSha256: preconditionSHA256)))
    }

    func delete(_ memoryID: String, memoryStoreID: String, expectedContentSHA256: String?) async throws {
        _ = try await delete(memoryID, memoryStoreID: memoryStoreID, expectedContentSha256: expectedContentSHA256)
    }
}

/// Test hooks around the file store and the listings (Python's tests patch `LocalFileStore` and `_list_memories`).
struct SessionMemoryHooks: Sendable {
    /// Called before each `put`, `hashFile` and `remove`; throwing fails the operation.
    var beforePut: (@Sendable (String) throws -> Void)?
    var beforeHashFile: (@Sendable (String) throws -> Void)?
    var beforeRemove: (@Sendable (String) throws -> Void)?
    /// Called once the consumer of a listing has handled `count` items, and with `nil` once the listing ran out.
    var listing: (@Sendable (_ count: Int?) async -> Void)?
}

/// One attached store: its `FileStore` on disk plus the sync baseline. Only used from its `SessionMemoryStores`.
final class AttachedMemoryStore: @unchecked Sendable {
    let memoryStoreID: String
    let files: FileStore
    let root: FileStoreRoot
    let readOnly: Bool
    /// `[relPath: content sha]` as of the last download or successful sync.
    var baseline: [String: String] = [:]
    /// `[relPath: sha]` the server refused; retried only after the file changes.
    var refusedSHAs: [String: String] = [:]
    /// `[relPath: monotonic time first seen missing]`; the server delete waits for a later sync.
    var pendingDeletes: [String: TimeInterval] = [:]
    /// `[relPath: sha]` of content sent whose outcome is unknown — recorded before the request, dropped after a
    /// successful response, else settled by the next listing.
    var sentSHAs: [String: String] = [:]

    init(memoryStoreID: String, files: FileStore, root: FileStoreRoot, readOnly: Bool) {
        self.memoryStoreID = memoryStoreID
        self.files = files
        self.root = root
        self.readOnly = readOnly
    }
}

/// One sync's server-delete discipline: the mode, the cap, and what was held back.
private final class DeletePass {
    let mode: MemoryDeleteMode
    let cap: Int
    /// Skip the waiting window — no later sync is coming to confirm.
    let waiveWindow: Bool
    var attempted = 0
    var capped = 0
    var suppressed = 0

    init(mode: MemoryDeleteMode, cap: Int, waiveWindow: Bool) {
        self.mode = mode
        self.cap = cap
        self.waiveWindow = waiveWindow
    }

    func takeSlot() -> Bool {
        if attempted >= cap {
            capped += 1
            return false
        }
        attempted += 1
        return true
    }
}

private struct MarkerScan {
    var files: [String: String]
    /// The scan found a marker naming this store — the only state that may drive uploads or deletes.
    var markerOK: Bool
    /// Why the marker check failed; `nil` when it passed.
    var distrustReason: String?
}

/// The memory stores attached to one session, materialised on disk (`SessionMemoryStores`).
///
/// `download` opens a `FileStore` at each attached store's directory (its `mount_path`, or a workdir fallback), pulls
/// its memories, and records each one's `content_sha256` as the sync baseline. Each sync (`syncIfDue` on the worker's
/// cadence, `finish` once at the end) reconciles disk against server, per store and per path:
///
/// - a memory changed only remotely is written to disk;
/// - a file changed only locally is uploaded — an update with a `content_sha256` precondition, or a create for a new
///   file;
/// - a file changed on both sides logs a warning and takes the server version;
/// - a file the server refuses (too large, invalid content) is skipped — warned once and retried only after the file
///   changes; other files keep syncing;
/// - an upload whose response never arrives may still have been saved, so the sha of the bytes sent is remembered
///   until the next sync has listed the server: a memory holding exactly that sha is this sync's own upload, not a
///   remote edit, and a newer local edit goes out over it;
/// - a file deleted locally is deleted on the server, guarded by an `expected_content_sha256` precondition — a
///   concurrent server-side edit wins and the file is restored instead. The delete never goes out on the first sync
///   that sees the file missing: it waits `DELETE_CORROBORATION_SECONDS`, re-checks the file and the marker, and each
///   sync sends a bounded number — the rest wait. `syncDeletions: .logOnly` runs the same checks and only logs;
///   `.disabled` turns server deletes off;
/// - a memory deleted on the server is deleted on disk — unless the file holds an un-pushed edit, making it the only
///   copy: a writable store re-creates the memory, a read-only store keeps the file unsynced;
/// - a store attached read-only pulls but never pushes.
///
/// `download` stamps `MARKER_PATH` into the folder, and every sync checks it in the same directory scan it syncs
/// from: the folder or marker gone with no files left, or every one of two-or-more files gone at once, re-downloads
/// the store; the marker gone or naming another store while files remain makes the sync do nothing.
///
/// `download` throws `SessionMemoryError` on the first store it cannot materialise. The syncs never throw:
/// mid-session, one bad store or one bad file is logged and the rest continue.
public actor SessionMemoryStores {
    private let memories: any SessionMemoriesAPI
    private let workdir: String
    private let syncInterval: TimeInterval
    private let syncDeletions: MemoryDeleteMode
    private let monotonic: @Sendable () -> TimeInterval
    var hooks = SessionMemoryHooks()
    var uploadConcurrency = MEMORY_UPLOAD_CONCURRENCY
    private var lastSync: TimeInterval
    private var finished = false
    private(set) var stores: [AttachedMemoryStore] = []

    /// - Parameters:
    ///   - client: The worker's token-scoped client (the memory endpoints reject the environment key).
    ///   - workdir: Where a store without a `mount_path` lands (`<workdir>/memory/<name>`).
    ///   - syncInterval: How often `syncIfDue` syncs, at least `MIN_MEMORY_SYNC_INTERVAL`.
    ///   - syncDeletions: Whether a locally deleted file deletes its server memory.
    public init(_ client: Anthropic, workdir: String, syncInterval: TimeInterval = DEFAULT_MEMORY_SYNC_INTERVAL,
                syncDeletions: MemoryDeleteMode = .enabled) throws
    {
        try self.init(memories: client.beta.memoryStores.memories, workdir: workdir, syncInterval: syncInterval,
                      syncDeletions: syncDeletions)
    }

    init(memories: any SessionMemoriesAPI, workdir: String, syncInterval: TimeInterval = DEFAULT_MEMORY_SYNC_INTERVAL,
         syncDeletions: MemoryDeleteMode = .enabled,
         monotonic: @escaping @Sendable () -> TimeInterval = { ProcessInfo.processInfo.systemUptime }) throws
    {
        try checkSyncInterval(syncInterval)
        self.memories = memories
        self.workdir = workdir
        self.syncInterval = syncInterval
        self.syncDeletions = syncDeletions
        self.monotonic = monotonic
        self.lastSync = monotonic()
    }

    func setHooks(_ hooks: SessionMemoryHooks) { self.hooks = hooks }
    func setUploadConcurrency(_ n: Int) { uploadConcurrency = n }

    /// Every attached store's folder on disk. The worker adds these to the file tools' allowed roots, so a store
    /// mounted outside the working directory stays reachable.
    public var roots: [String] { stores.map(\.root.path) }

    /// Root directories of stores attached read-only. The file tools consult this to refuse writes into them.
    public var readOnlyRoots: [String] { stores.filter(\.readOnly).map(\.root.path) }

    /// Where one store's files land on disk: its `mount_path`, which the agent's system prompt names. A `mount_path`
    /// that cannot be used verbatim is refused rather than quietly relocated.
    private func storeRoot(_ resource: BetaManagedAgentsMemoryStoreResource) throws -> String {
        if let mountPath = resource.mountPath, !mountPath.isEmpty {
            if !FileStore.isPathLegal(mountPath) {
                throw SessionMemoryError(
                    "memory store mount_path is not a clean absolute path: \(pythonStringRepr(mountPath)) "
                        + "(memory_store_id=\(resource.memoryStoreID))")
            }
            return mountPath
        }
        // No mount_path at all: nothing points the agent anywhere, so the workdir is as good a home as any.
        let name = resource.name.flatMap { $0.isEmpty ? nil : $0 } ?? resource.memoryStoreID
        return (workdir as NSString).appendingPathComponent("memory/\(name)")
    }

    /// Download every attached store's memories to disk. `session` arrives already fetched — one snapshot shared
    /// with the skills download.
    public func download(_ session: BetaManagedAgentsSession) async throws {
        try await download(resources: session.resources.compactMap { if case .memoryStore(let r) = $0 { return r } else { return nil } })
    }

    func download(resources: [BetaManagedAgentsMemoryStoreResource]) async throws {
        var plan: [(BetaManagedAgentsMemoryStoreResource, String)] = []
        for resource in resources { plan.append((resource, try storeRoot(resource))) }
        for (resource, root) in plan {
            var store: AttachedMemoryStore?
            do {
                // utf8Only: a binary file is refused at put/get, not mid-sync.
                let files = try await FileStore.open(root, utf8Only: true)
                let attached = AttachedMemoryStore(memoryStoreID: resource.memoryStoreID, files: files, root: await files.root,
                                                   readOnly: resource.access == .readOnly)
                store = attached
                // A root `open` did not create is a dead run's leftovers; the first sync would upload them into the
                // customer's store.
                if !attached.root.removedOnDispose {
                    throw SessionMemoryError(
                        "something already exists at the memory store's path: \(root) (memory_store_id=\(resource.memoryStoreID)); "
                            + "it must not exist when the session starts")
                }
                do {
                    try await files.createRoot()
                } catch {
                    // An unmountable root fails the item, not just one file.
                    throw SessionMemoryError(
                        "cannot create the memory store's folder: \(root) (memory_store_id=\(resource.memoryStoreID)): \(error); "
                            + "the worker host must make this mount path writable")
                }
                try await stampAndPull(attached)
                memoryLog.info(
                    "downloaded \(attached.baseline.count) memories memory_store_id=\(attached.memoryStoreID) -> \(attached.root.path)")
                stores.append(attached)
            } catch {
                // A half-downloaded folder self-destructs; `dispose` leaves a refused pre-existing directory as found.
                if let store { try? await store.files.dispose() }
                // Every store must land: a session missing a folder its system prompt names runs with amnesia.
                if error is SessionMemoryError { throw error }
                throw SessionMemoryError("failed to download memory store memory_store_id=\(resource.memoryStoreID): \(error)")
            }
        }
        lastSync = monotonic()
    }

    /// The session's last sync — once, at a clean end. Same reconciliation as the cadence syncs, but server deletes
    /// skip the waiting window (the cap still applies). Throws on a second call.
    public func finish() async throws {
        if finished {
            throw AnthropicError("finish() was already called: it is the session's last sync and runs once")
        }
        finished = true
        await syncAll(final: true)
    }

    func syncAll(final: Bool) async {
        await withTaskGroup(of: Void.self) { group in
            for store in stores { group.addTask { await self.syncStore(store, final: final) } }
        }
        lastSync = monotonic()
    }

    /// Run one sync when `syncInterval` has elapsed since the last. Stores sync in parallel; a store's own paths
    /// reconcile in a deterministic order. Never throws.
    public func syncIfDue() async {
        if monotonic() - lastSync < syncInterval { return }
        await syncAll(final: false)
    }

    private func scanMarker(_ store: AttachedMemoryStore) async throws -> MarkerScan {
        var local = try await store.files.hashtree()
        let marker = local.removeValue(forKey: MARKER_PATH)
        if marker == markerSHA(store.memoryStoreID) {
            return MarkerScan(files: local, markerOK: true, distrustReason: nil)
        }
        return MarkerScan(files: local, markerOK: false,
                          distrustReason: marker != nil ? "the marker file does not match this store" : "the marker file is gone")
    }

    private func syncStore(_ store: AttachedMemoryStore, final: Bool) async {
        do {
            let scan = try await scanMarker(store)
            let local = scan.files
            if !scan.markerOK {
                if !local.isEmpty {
                    memoryLog.warning(
                        "\(scan.distrustReason ?? ""); leaving the memory store folder as found and not syncing "
                            + "root=\(store.root.path) memory_store_id=\(store.memoryStoreID)")
                    return
                }
                try await recover(store, "the folder or its marker is gone")
                return
            }
            var remote: [String: SessionMemoryItem] = [:]
            try await forEachMemory(store.memoryStoreID) { remote[stripLeadingSlashes($0.path)] = $0 }
            settleSent(store, remote)
            // One file gone is a delete; every file gone at once is a wipe — counted after settling, so an upload
            // that landed unheard counts.
            if local.isEmpty && store.baseline.count > 1 {
                try await recover(store, "every memory file is gone at once")
                return
            }

            let deletes = DeletePass(
                mode: syncDeletions,
                cap: max(MEMORY_DELETE_CAP_FLOOR, min(MEMORY_DELETE_CAP_CEILING, store.baseline.count / 4)),
                waiveWindow: final)
            var pulls: [(String, SessionMemoryItem)] = []
            var baseline: [String: String] = [:]
            for rel in Set(remote.keys).union(local.keys).union(store.baseline.keys).sorted() {
                let remoteItem = remote[rel]
                let localSHA = local[rel]
                let baseSHA = store.baseline[rel]
                let sha: String?
                // Server-delete candidates branch off so the delete discipline stays out of the merge rules.
                if localSHA == nil, let baseSHA, let remoteItem, remoteItem.contentSHA256 == baseSHA, !store.readOnly {
                    sha = await corroboratedDelete(store, rel, remoteItem, baseSHA, deletes)
                } else {
                    sha = try await syncPath(store, rel, remoteItem, localSHA, &pulls)
                }
                if let sha { baseline[rel] = sha }
            }
            store.baseline = baseline
            // The content pass: everything above moved only shas.
            await pullAll(store, pulls)
            if deletes.suppressed > 0 {
                memoryLog.debug(
                    "server deletes are disabled; \(deletes.suppressed) locally deleted memories stay on the server "
                        + "memory_store_id=\(store.memoryStoreID)")
            }
            if deletes.capped > 0 {
                memoryLog.warning(
                    "delete cap reached: \(deletes.mode == .logOnly ? "would send" : "sent") \(deletes.attempted) deletes, held "
                        + "\(deletes.capped) for later syncs memory_store_id=\(store.memoryStoreID)")
            }
        } catch {
            memoryLog.warning("memory sync failed memory_store_id=\(store.memoryStoreID): \(error)")
        }
    }

    /// Upload new and changed files; send no deletes and pull nothing (`flush_writes`).
    ///
    /// The push-only rescue pass for a session ending on an error or cancel — best-effort, bounded by the caller.
    /// Each store uploads a bounded number of files at a time; a store cut off part-way logs how many changed files
    /// it had not uploaded. Skips read-only stores, refused files, files the server already holds, and folders that
    /// fail the marker check. Never throws.
    public func flushWrites() async {
        await withTaskGroup(of: Void.self) { group in
            for store in stores { group.addTask { await self.flushStore(store) } }
        }
    }

    private func flushStore(_ store: AttachedMemoryStore) async {
        if store.readOnly { return }
        var dirty: [String: String] = [:]
        let unsent = MemoryFlushProgress()
        do {
            let scan = try await scanMarker(store)
            if !scan.markerOK {
                memoryLog.warning(
                    "\(scan.distrustReason ?? ""); not uploading anything from the memory store folder root=\(store.root.path) "
                        + "memory_store_id=\(store.memoryStoreID)")
                return
            }
            // A path with an unsettled send counts even at its baseline sha: the send may have landed, leaving the
            // server ahead of the file.
            dirty = scan.files.filter { rel, sha in
                (sha != store.baseline[rel] || store.sentSHAs[rel] != nil) && store.refusedSHAs[rel] != sha
            }
            if dirty.isEmpty { return }
            unsent.paths = Set(dirty.keys)
            var remote: [String: SessionMemoryItem] = [:]
            try await forEachMemory(store.memoryStoreID) { remote[stripLeadingSlashes($0.path)] = $0 }
            settleSent(store, remote)

            var uploads: [(String, String, SessionMemoryItem?)] = []
            for rel in dirty.keys.sorted() {
                let localSHA = dirty[rel]!
                let baseSHA = store.baseline[rel]
                let existing = remote[rel]
                if localSHA == baseSHA {
                    // Listed only for its unsettled send, which never landed: the file holds nothing the server lacks.
                    unsent.paths.remove(rel)
                    continue
                }
                if let existing, existing.contentSHA256 == localSHA {
                    store.baseline[rel] = localSHA
                    unsent.paths.remove(rel)
                    continue
                }
                if let existing, existing.contentSHA256 != baseSHA {
                    // A push-only pass cannot pull the winner over the file.
                    memoryLog.warning(
                        "memory changed both locally and remotely; the flush leaves the remote version path=\(rel) "
                            + "memory_store_id=\(store.memoryStoreID)")
                    unsent.paths.remove(rel)
                    continue
                }
                uploads.append((rel, localSHA, existing))
            }
            await forEachConcurrently(uploads, limit: uploadConcurrency) { rel, localSHA, existing in
                // An upload cut off by cancellation stays unsent.
                guard let sha = try? await self.upload(store, rel, localSHA, existing: existing) else {
                    if !Task.isCancelled { await self.noteFlushed(store, rel, nil, unsent) }
                    return
                }
                await self.noteFlushed(store, rel, sha, unsent)
            }
            if Task.isCancelled { throw CancellationError() }
        } catch is CancellationError {
            if !unsent.paths.isEmpty {
                memoryLog.warning(
                    "memory flush cut off part-way; \(unsent.paths.count) of \(dirty.count) changed files had not finished uploading "
                        + "memory_store_id=\(store.memoryStoreID)")
            }
        } catch {
            memoryLog.warning("memory flush failed memory_store_id=\(store.memoryStoreID): \(error)")
        }
    }

    private func noteFlushed(_ store: AttachedMemoryStore, _ rel: String, _ sha: String?, _ unsent: MemoryFlushProgress) {
        unsent.paths.remove(rel)
        if let sha { store.baseline[rel] = sha }
    }

    /// Remove every store directory that `download` created. Pre-existing directories are left alone, and so is a
    /// folder that holds files but fails the marker check — sync promised to leave it as found.
    public func dispose() async {
        for store in stores {
            // The caller is tearing down and will not retry.
            do {
                let scan = try await scanMarker(store)
                if !scan.markerOK && !scan.files.isEmpty {
                    memoryLog.warning(
                        "\(scan.distrustReason ?? ""); leaving the memory store folder on disk root=\(store.root.path) "
                            + "memory_store_id=\(store.memoryStoreID)")
                    continue
                }
                try await store.files.dispose()
            } catch {
                memoryLog.warning(
                    "failed to remove the memory store folder root=\(store.root.path) memory_store_id=\(store.memoryStoreID): \(error)")
                continue
            }
            if store.root.removedOnDispose {
                memoryLog.info("removed memory store dir \(store.root.path) memory_store_id=\(store.memoryStoreID)")
            }
        }
    }

    /// Rebuild a destroyed folder from the server; sends no deletes, no uploads.
    private func recover(_ store: AttachedMemoryStore, _ reason: String) async throws {
        memoryLog.warning(
            "\(reason); re-downloading the memory store folder instead of syncing root=\(store.root.path) "
                + "memory_store_id=\(store.memoryStoreID)")
        try await store.files.createRoot()
        try await stampAndPull(store)
    }

    /// Resolve the uploads whose response never arrived, against a fresh listing. A memory holding exactly the sha
    /// that was sent is that upload, saved after all. Every record is then dropped.
    private func settleSent(_ store: AttachedMemoryStore, _ remote: [String: SessionMemoryItem]) {
        for (rel, sha) in store.sentSHAs {
            if let listed = remote[rel], listed.contentSHA256 == sha { store.baseline[rel] = sha }
        }
        store.sentSHAs.removeAll()
    }

    /// Write the trust marker, then pull every remote memory; pushes nothing. The baseline is rebuilt from
    /// successful writes only.
    private func stampAndPull(_ store: AttachedMemoryStore) async throws {
        store.baseline = [:]
        store.sentSHAs.removeAll()
        // The disk was just rebuilt, so earlier absence observations mean nothing.
        store.pendingDeletes.removeAll()
        try await put(store, MARKER_PATH, "version \(MARKER_VERSION)\n\(store.memoryStoreID)")
        try await forEachMemory(store.memoryStoreID, view: "full") { item in
            let rel = stripLeadingSlashes(item.path)
            if await self.write(store, rel, item.content ?? "") { store.baseline[rel] = item.contentSHA256 }
        }
    }

    private func syncPath(_ store: AttachedMemoryStore, _ rel: String, _ remote: SessionMemoryItem?, _ localSHA: String?,
                          _ pulls: inout [(String, SessionMemoryItem)]) async throws -> String?
    {
        var localSHA = localSHA
        let baseSHA = store.baseline[rel]
        if localSHA != nil { store.pendingDeletes[rel] = nil }

        guard let remote else {
            guard let local = localSHA else {
                store.pendingDeletes[rel] = nil
                return nil
            }
            if let baseSHA {
                if local == baseSHA {
                    guard let fresh = await removeLocal(store, rel, baseSHA) else { return nil }
                    if fresh == baseSHA { return baseSHA }
                    localSHA = fresh
                }
                // An un-pushed edit exists only in this file, so the remote delete loses: re-create it (writable)
                // or keep it on disk unsynced (read-only).
                if store.readOnly {
                    memoryLog.warning(
                        "memory deleted remotely but edited locally; keeping the file, which a read-only store cannot push "
                            + "path=\(rel) memory_store_id=\(store.memoryStoreID)")
                } else if store.refusedSHAs[rel] != localSHA {
                    memoryLog.info(
                        "memory deleted remotely but edited locally; re-creating it from the file path=\(rel) "
                            + "memory_store_id=\(store.memoryStoreID)")
                }
            }
            if store.readOnly { return nil }
            if store.refusedSHAs[rel] == localSHA { return nil }
            return try await upload(store, rel, localSHA, existing: nil)
        }

        let remoteSHA = remote.contentSHA256
        let remoteChanged = remoteSHA != baseSHA
        let locallyEdited = localSHA != nil && localSHA != baseSHA && localSHA != remoteSHA
        // Read-only stores never push, so their local edits don't count.
        let localChanged = !store.readOnly && locallyEdited

        if localSHA == nil, let baseSHA {
            // Only successful writes enter the baseline, so this file was verifiably on disk and is now gone: a real
            // local deletion.
            if remoteChanged {
                memoryLog.warning(
                    "memory deleted locally but changed remotely; restoring the remote version path=\(rel) "
                        + "memory_store_id=\(store.memoryStoreID)")
                store.pendingDeletes[rel] = nil
                pulls.append((rel, remote))
            }
            return baseSHA
        }

        if remoteChanged {
            // The file already holds the remote bytes — adopt without a fetch.
            if localSHA == remoteSHA { return remoteSHA }
            // Read-only edits never push, but overwriting one still logs.
            if locallyEdited {
                memoryLog.warning(
                    "memory changed both locally and remotely; keeping the remote version path=\(rel) "
                        + "memory_store_id=\(store.memoryStoreID)")
            }
            pulls.append((rel, remote))
            return baseSHA
        }
        if localChanged {
            if store.refusedSHAs[rel] == localSHA { return remoteSHA }
            return try await upload(store, rel, localSHA, existing: remote) ?? remoteSHA
        }
        return remoteSHA
    }

    /// Remove the file for a memory the server no longer has, if it still holds `expectSHA`. Returns `nil` when the
    /// file is gone from disk, `expectSHA` when it must stay in the baseline (I/O error, remove failed), or the
    /// file's fresh sha when it was edited since the scan.
    private func removeLocal(_ store: AttachedMemoryStore, _ rel: String, _ expectSHA: String) async -> String? {
        let fresh: String?
        do {
            fresh = try await hashFile(store, rel)
        } catch {
            return expectSHA
        }
        guard let fresh else { return nil }
        if fresh != expectSHA { return fresh }
        do {
            try hooks.beforeRemove?(rel)
            try await store.files.remove(rel)
        } catch {
            memoryLog.warning("failed to remove memory deleted remotely path=\(rel) memory_store_id=\(store.memoryStoreID): \(error)")
            return expectSHA
        }
        return nil
    }

    /// Write a memory's content to disk; `false` (and a warning) on failure. A `..` component in the wire path
    /// reaches here as `FileStoreError` — that is the escape guard.
    private func write(_ store: AttachedMemoryStore, _ rel: String, _ content: String) async -> Bool {
        do {
            try await put(store, rel, content)
        } catch {
            memoryLog.warning("failed to write memory path=\(rel) memory_store_id=\(store.memoryStoreID): \(error)")
            return false
        }
        return true
    }

    private func put(_ store: AttachedMemoryStore, _ rel: String, _ content: String) async throws {
        try hooks.beforePut?(rel)
        try await store.files.put(rel, content)
    }

    private func hashFile(_ store: AttachedMemoryStore, _ rel: String) async throws -> String? {
        try hooks.beforeHashFile?(rel)
        return try await store.files.hashFile(rel)
    }

    /// Fetch and write the given memories, `MEMORY_FETCH_CONCURRENCY` at a time. On success the path's baseline
    /// advances; on a failed fetch or write the old entry stays and the next sync retries. A 404 means the memory was
    /// deleted after the listing — the next sync reconciles it.
    private func pullAll(_ store: AttachedMemoryStore, _ pulls: [(String, SessionMemoryItem)]) async {
        if pulls.isEmpty { return }
        await forEachConcurrently(pulls, limit: MEMORY_FETCH_CONCURRENCY) { rel, listed in
            await self.pullOne(store, rel, listed)
        }
    }

    private func pullOne(_ store: AttachedMemoryStore, _ rel: String, _ listed: SessionMemoryItem) async {
        let item: SessionMemoryItem
        do {
            item = try await memories.retrieve(listed.id, memoryStoreID: store.memoryStoreID, view: "full")
        } catch {
            if (error as? APIStatusError)?.statusCode == 404 { return }
            memoryLog.warning("failed to fetch memory content path=\(rel) memory_store_id=\(store.memoryStoreID): \(error)")
            return
        }
        if await write(store, rel, item.content ?? "") { store.baseline[rel] = item.contentSHA256 }
    }

    /// Calls `body` with the store's memories — `basic` view (shas, no content) unless the caller needs `full`
    /// pages. `memory_prefix` rollups and the reserved marker path are skipped.
    private func forEachMemory(_ memoryStoreID: String, view: String = "basic",
                               _ body: (SessionMemoryItem) async throws -> Void) async throws
    {
        let limit = view == "basic" ? MEMORY_LIST_PAGE_SIZE : MEMORY_FULL_LIST_PAGE_SIZE
        var consumed = 0
        for try await item in try await memories.list(memoryStoreID, view: view, limit: limit) {
            if item.type != "memory" { continue }
            if stripLeadingSlashes(item.path) == MARKER_PATH {
                memoryLog.warning(
                    "the server listed the reserved marker path; skipping path=\(item.path) memory_store_id=\(memoryStoreID)")
                continue
            }
            try await body(item)
            consumed += 1
            await hooks.listing?(consumed)
        }
        await hooks.listing?(nil)
    }

    /// Push one local file; `nil` keeps the old baseline so the next pass retries. A refusal the server would repeat
    /// (400/413, the utf-8 gate) enters `refusedSHAs`: warned once, retried only after the file changes.
    private func upload(_ store: AttachedMemoryStore, _ rel: String, _ localSHA: String?, existing: SessionMemoryItem?) async throws
        -> String?
    {
        let item: SessionMemoryItem
        do {
            guard let data = try await store.files.get(rel) else { return nil }
            store.sentSHAs[rel] = ToolsSHA256.hex(data)
            guard let content = String(data: data, encoding: .utf8) else { throw FileStoreError(FileStoreError.NOT_UTF8, rel) }
            if let existing {
                item = try await memories.update(existing.id, memoryStoreID: store.memoryStoreID, content: content,
                                                 preconditionSHA256: existing.contentSHA256)
            } else {
                item = try await memories.create(store.memoryStoreID, path: "/" + rel, content: content)
            }
        } catch {
            // Cancellation is not a refusal: it ends the pass (a flush cut off by its caller logs what stayed unsent).
            if error is CancellationError { throw CancellationError() }
            let status = (error as? APIStatusError)?.statusCode
            if existing != nil && status == 404 {
                // Deleted remotely since the listing, so this file is now the only copy.
                return try await upload(store, rel, localSHA, existing: nil)
            }
            let permanent = error is FileStoreError || status == 400 || status == 413
            if existing != nil && status == 409 {
                // The precondition lost a race: the remote moved under us, so the push is dropped. The sent sha
                // stays for the next listing to tell a saved client retry apart.
                memoryLog.warning(
                    "memory changed both locally and remotely; the upload was refused and the local edit loses path=\(rel) "
                        + "memory_store_id=\(store.memoryStoreID)")
            } else if permanent, let localSHA {
                store.refusedSHAs[rel] = localSHA
                memoryLog.warning(
                    "the server rejected this memory file, so it stays un-synced until its content changes path=\(rel) "
                        + "memory_store_id=\(store.memoryStoreID) rejection=\(error)")
            } else {
                memoryLog.warning("failed to upload memory path=\(rel) memory_store_id=\(store.memoryStoreID): \(error)")
            }
            return nil
        }
        store.refusedSHAs[rel] = nil
        store.sentSHAs[rel] = nil
        return item.contentSHA256
    }

    /// Send the server delete only after the file's absence is confirmed: the miss is recorded on the first sync,
    /// and the delete goes out on a later one after the window, a fresh re-check, and the per-pass cap.
    private func corroboratedDelete(_ store: AttachedMemoryStore, _ rel: String, _ remote: SessionMemoryItem, _ baseSHA: String,
                                    _ deletes: DeletePass) async -> String?
    {
        if deletes.mode == .disabled {
            deletes.suppressed += 1
            return baseSHA
        }
        let firstAbsent: TimeInterval
        if let seen = store.pendingDeletes[rel] {
            firstAbsent = seen
        } else {
            firstAbsent = monotonic()
            store.pendingDeletes[rel] = firstAbsent
        }
        if !deletes.waiveWindow && monotonic() - firstAbsent < DELETE_CORROBORATION_SECONDS { return baseSHA }
        var markerOK = false
        var stillAbsent = false
        do {
            // Re-check now — the folder may have been destroyed mid-sync.
            markerOK = try await hashFile(store, MARKER_PATH) == markerSHA(store.memoryStoreID)
            stillAbsent = try await hashFile(store, rel) == nil
        } catch {
            markerOK = false
            stillAbsent = false
        }
        if !markerOK { return baseSHA }
        if !stillAbsent {
            store.pendingDeletes[rel] = nil
            return baseSHA
        }
        if !deletes.takeSlot() { return baseSHA }
        if deletes.mode == .logOnly {
            // Repeats every sync — the dry run mirrors what `.enabled` would keep trying.
            memoryLog.info("log-only: sync would delete this memory on the server path=\(rel) memory_store_id=\(store.memoryStoreID)")
            return baseSHA
        }
        let sha = await deleteRemote(store, rel, remote, baseSHA)
        if sha == nil { store.pendingDeletes[rel] = nil }
        return sha
    }

    private func deleteRemote(_ store: AttachedMemoryStore, _ rel: String, _ remote: SessionMemoryItem, _ baseSHA: String) async -> String? {
        do {
            try await memories.delete(remote.id, memoryStoreID: store.memoryStoreID, expectedContentSHA256: baseSHA)
        } catch {
            let status = (error as? APIStatusError)?.statusCode
            if status == 404 { return nil }  // already gone remotely too
            if status == 409 || status == 412 {
                memoryLog.warning(
                    "memory deleted locally but changed remotely; keeping the remote version path=\(rel) "
                        + "memory_store_id=\(store.memoryStoreID)")
            } else {
                memoryLog.warning("failed to delete memory path=\(rel) memory_store_id=\(store.memoryStoreID): \(error)")
            }
            return baseSHA
        }
        memoryLog.info("propagated local deletion path=\(rel) memory_store_id=\(store.memoryStoreID)")
        return nil
    }
}

/// The changed files of a flush that have not finished uploading.
private final class MemoryFlushProgress: @unchecked Sendable {
    var paths = Set<String>()
}

private func stripLeadingSlashes(_ path: String) -> String {
    var p = Substring(path)
    while p.hasPrefix("/") { p = p.dropFirst() }
    return String(p)
}

/// Runs `body` over `items` with at most `limit` in flight (`anyio.CapacityLimiter`).
private func forEachConcurrently<T: Sendable>(_ items: [T], limit: Int, _ body: @escaping @Sendable (T) async -> Void) async {
    await withTaskGroup(of: Void.self) { group in
        var next = 0
        for _ in 0..<min(max(1, limit), items.count) {
            let item = items[next]
            next += 1
            group.addTask { await body(item) }
        }
        while await group.next() != nil {
            if next < items.count {
                let item = items[next]
                next += 1
                group.addTask { await body(item) }
            }
        }
    }
}
