// Port of tests/lib/tools/memory_sync/test_memory_sync.py: the memory-store sync contract.
//
// An agent keeps a folder of notes on disk. The same folder lives on the server. Each sync makes the two agree: each
// side gets the other's changes, and when both changed the same file the server wins. `local` is the agent's folder
// on disk, `server` is the remote copy; `server.received` holds only what the sync sent.

import Foundation
import Testing
@testable import Anthropic

private let LOGGER = "anthropic.lib.tools.agent_toolset"
private let created = memorySyncCreated
private func updated(_ path: String, _ content: String, was: String) -> MemorySyncCall { memorySyncUpdated(path, content, was: was) }
private func deleted(_ path: String, was: String) -> MemorySyncCall { memorySyncDeleted(path, was: was) }

private struct InjectedIOError: Error, CustomStringConvertible {
    var description: String { "[Errno 5] I/O error" }
}

@Suite struct MemorySyncTests {
    @Test func editsFlowBothWaysAndTheServerWinsConflicts() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["push.md": "v1", "pull.md": "v1", "both.md": "v1", "gone.md": "v1"])
        let server = fake.server

        try local.write("push.md", "v2 from agent")
        try local.write("new.md", "new from agent")
        server.write("pull.md", "v2 from server")
        try local.write("both.md", "v2 from agent")
        server.write("both.md", "v2 from server")
        server.delete("gone.md")

        let (_, capture) = await ToolDiagnostics.capture { await memorySyncRun(stores) }

        // Each side has the other's change; the server won the conflict; the server's deletion took the local copy.
        #expect(server.texts["push.md"] == "v2 from agent")
        #expect(server.texts["new.md"] == "new from agent")
        #expect(local.read("pull.md") == "v2 from server")
        #expect(local.read("both.md") == "v2 from server")
        #expect(!local.exists("gone.md"))
        #expect(!server.has("gone.md"))
        #expect(memorySyncLogText(capture, atLeast: .warning).contains("changed both locally and remotely"))

        // The push was guarded: overwrite only if the server still had v1.
        let sent = [created("new.md", "new from agent"), updated("push.md", "v2 from agent", was: "v1")]
        #expect(server.received == sent)

        // Settled: a second sync sends nothing more.
        await memorySyncRun(stores)
        #expect(server.received == sent)
    }

    @Test func localDeletionsReachTheServerUnlessItChanged() async throws {
        let clock = MemorySyncClock()
        let tmp = try memorySyncTempDir()
        // keep.md survives on disk so the pass is not an all-files-gone wipe.
        let fake = MemorySyncFake(["drop.md": "v1", "raced.md": "v1", "never.md": "v1", "keep.md": "v1"])
        let server = fake.server
        let stores = try fake.stores(workdir: tmp, clock: clock)
        // One memory's download write fails, so it is never on disk to begin with — that absence is not a deletion.
        await stores.setHooks(SessionMemoryHooks(beforePut: { rel in if rel == "never.md" { throw InjectedIOError() } }))
        try await stores.download(resources: fake.resources)
        await stores.setHooks(SessionMemoryHooks())
        let local = MemorySyncFolder(tmp + "/memory/notes")

        try local.unlink("drop.md")
        try local.unlink("raced.md")
        server.write("raced.md", "v2 from server")

        await memorySyncRun(stores)
        // The first pass only records the deletion; a corroborating pass after the window sends it.
        #expect(server.has("drop.md"))
        clock.now = DELETE_CORROBORATION_SECONDS + 1
        await memorySyncRun(stores)

        // Only the un-raced deletion went out, guarded by the last-synced content.
        let sent = [deleted("drop.md", was: "v1")]
        #expect(server.received == sent)
        #expect(!server.has("drop.md"))
        // The raced deletion lost — the server's edit came back to disk instead.
        #expect(local.read("raced.md") == "v2 from server")
        // The never-downloaded file was pulled, not deleted.
        #expect(local.read("never.md") == "v1")
        #expect(server.texts["never.md"] == "v1")

        await memorySyncRun(stores)
        #expect(server.received == sent)
    }

    @Test func readOnlyStoresAreNeverWritten() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["edit.md": "v1", "drop.md": "v1", "pull.md": "v1"], access: .readOnly)
        let server = fake.server

        try local.write("edit.md", "v2 from agent")
        try local.unlink("drop.md")
        try local.write("new.md", "new from agent")
        server.write("pull.md", "v2 from server")

        await memorySyncRun(stores)

        #expect(server.received.isEmpty)
        #expect(server.texts == ["edit.md": "v1", "drop.md": "v1", "pull.md": "v2 from server"])
        // Pulls still happen.
        #expect(local.read("pull.md") == "v2 from server")

        // A remote deletion is a pull too, so it removes the local copy even here.
        server.delete("pull.md")
        await memorySyncRun(stores)
        #expect(server.received.isEmpty)
        #expect(!local.exists("pull.md"))
    }

    @Test func pathsThatEscapeTheStoreAreRefused() async throws {
        let ((local, fake, stores, tmp), capture) = try await ToolDiagnostics.capture {
            try await memorySyncDownloaded(["../evil.md": "boom", "ok.md": "fine"])
        }
        let (_, capture2) = await ToolDiagnostics.capture { await memorySyncRun(stores) }

        #expect(local.read("ok.md") == "fine")
        #expect(!MemorySyncFolder(tmp).files().contains { $0.hasSuffix("evil.md") })
        #expect(!FileManager.default.fileExists(atPath: tmp + "/memory/evil.md"))
        #expect(fake.server.received.isEmpty)
        #expect((memorySyncLogText(capture) + memorySyncLogText(capture2)).contains("escapes"))
    }

    /// The worker's call sequence: download → syncIfDue per call → finish → dispose.
    @Test func workerLifecycleCadenceAndDispose() async throws {
        let clock = MemorySyncClock()
        let tmp = try memorySyncTempDir()
        let fake = MemorySyncFake(["note.md": "v1"])
        let server = fake.server
        let stores = try fake.stores(workdir: tmp, clock: clock, syncInterval: 300)
        try await stores.download(resources: fake.resources)
        let local = MemorySyncFolder(tmp + "/memory/notes")

        try local.write("note.md", "edit 1")
        await stores.syncIfDue()
        #expect(server.received.isEmpty)

        // One long gap fires exactly once, and not again until another interval.
        clock.now = 2000
        await stores.syncIfDue()
        await stores.syncIfDue()
        #expect(server.received == [updated("note.md", "edit 1", was: "v1")])
        clock.now = 2299
        await stores.syncIfDue()
        #expect(server.received.count == 1)

        // The last sync is finish(): unconditional, once.
        try local.write("note.md", "edit 2")
        try await stores.finish()
        #expect(server.received.last == updated("note.md", "edit 2", was: "edit 1"))
        await #expect(throws: AnthropicError.self) { try await stores.finish() }

        // Dispose removes the store dir the download created.
        #expect(local.exists())
        await stores.dispose()
        #expect(!local.exists())
    }

    /// The store is utf-8-restricted, so a binary file the agent drops in the folder is refused at read — warned once
    /// and skipped until it changes — while every other file keeps syncing.
    @Test func aBinaryLocalFileNeverBlocksTheOtherFiles() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v1"])

        try local.writeBytes("blob.bin", Data([0xFF, 0xFE, 0x00]) + Data(" not utf-8".utf8))
        try local.write("note.md", "v2")

        let (_, capture) = await ToolDiagnostics.capture {
            await memorySyncRun(stores)
            await memorySyncRun(stores)
        }

        #expect(fake.server.received == [updated("note.md", "v2", was: "v1")])
        #expect(!fake.server.has("blob.bin"))
        #expect(memorySyncLogText(capture).components(separatedBy: "stays un-synced until its content changes path=blob.bin").count - 1 == 1)
    }

    /// A file the server refuses as too large is warned once and skipped — not retried while unchanged, never
    /// blocking the other files — and syncs as soon as an edit brings it under the cap.
    @Test func anOversizedFileIsSkippedUntilItShrinks() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v1"])
        let server = fake.server
        server.maxContentBytes = 64

        try local.write("big.md", String(repeating: "x", count: 100))
        try local.write("note.md", "v2")

        let (_, capture) = await ToolDiagnostics.capture {
            await memorySyncRun(stores)
            await memorySyncRun(stores)
        }

        // The small edit landed; the big file was attempted exactly once.
        #expect(server.received.contains(updated("note.md", "v2", was: "v1")))
        #expect(server.received.filter { $0.kind == "create" }.count == 1)
        #expect(!server.has("big.md"))
        #expect(memorySyncLogText(capture).components(separatedBy: "stays un-synced until its content changes path=big.md").count - 1 == 1)

        try local.write("big.md", "small now")
        await memorySyncRun(stores)
        #expect(server.texts["big.md"] == "small now")
    }

    /// Anything but a content refusal is retried by the next sync.
    @Test(arguments: [401, 403, 404])
    func aRefusalThatSaysNothingAboutTheContentIsRetriedNextSync(status: Int) async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v1"])
        let server = fake.server
        try local.write("note.md", "v2")
        try local.write("new.md", "fresh")

        server.uploadHook = { _ in throw memorySyncStatusError(status) }
        let (_, capture) = await ToolDiagnostics.capture {
            await memorySyncRun(stores)
            server.uploadHook = nil
            await memorySyncRun(stores)
        }

        #expect(server.texts == ["note.md": "v2", "new.md": "fresh"])
        #expect(!memorySyncLogText(capture).contains("stays un-synced"))
    }

    /// The server changes between this sync's list and its update: the content_sha256 precondition rejects the push
    /// (409), and the next sync applies the conflict rule — the winning remote edit is pulled, the local edit is
    /// never re-pushed.
    @Test func anUploadThatLosesTheRacePullsTheWinnerNextSync() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["note.md": "v1"])
        let server = fake.server

        try local.write("note.md", "local edit")
        fake.memories.wrapUpdate = { _, real in
            // Race: the remote changes after this sync's list, before its update.
            server.write("note.md", "raced remote edit")
            return try await real()
        }
        let (_, capture) = await ToolDiagnostics.capture { await memorySyncRun(stores) }
        fake.memories.wrapUpdate = nil

        // The precondition rejected the push (one guarded attempt, no retry) and the server kept its raced edit.
        #expect(server.received == [updated("note.md", "local edit", was: "v1")])
        #expect(server.texts["note.md"] == "raced remote edit")
        #expect(memorySyncLogText(capture).contains("the upload was refused and the local edit loses"))
        #expect(local.read("note.md") == "local edit")

        // The next sync pulls the winner instead of re-pushing.
        await memorySyncRun(stores)
        #expect(local.read("note.md") == "raced remote edit")
        #expect(server.received.count == 1)
    }

    /// A store that cannot be materialised fails the download outright.
    @Test func aBrokenStoreFailsTheWholeDownload() async throws {
        let tmp = try memorySyncTempDir()
        let fake = MemorySyncFake(["note.md": "v1"], broken: true)
        let stores = try fake.stores(workdir: tmp)

        do {
            try await stores.download(resources: fake.resources)
            Issue.record("expected a SessionMemoryError")
        } catch let error as SessionMemoryError {
            #expect(error.message.contains("memstore_broken"))
        }

        // The half-downloaded folder self-destructed; nothing is tracked.
        #expect(!FileManager.default.fileExists(atPath: tmp + "/memory/broken"))
        #expect(await stores.readOnlyRoots.isEmpty)
    }

    /// A clean absolute `mount_path` is honored verbatim, and dispose removes it when the download created it.
    @Test func aLegalMountPathIsHonoredAndAnUncleanOneIsRefused() async throws {
        let tmp = try memorySyncTempDir()
        let mount = tmp + "/mnt/notes"
        let fake = MemorySyncFake(["note.md": "v1"], mountPath: mount)
        let stores = try fake.stores(workdir: tmp + "/wd")
        try await stores.download(resources: fake.resources)
        #expect(MemorySyncFolder(mount).read("note.md") == "v1")
        // The worker feeds these roots to the file tools' allowed roots.
        #expect(await stores.roots == [FileOps.resolve(mount)])
        await stores.dispose()
        #expect(!FileManager.default.fileExists(atPath: mount))
    }

    /// A mount the host cannot provide is an environment failure: the download fails loudly.
    @Test func anUnwritableMountPathFailsTheDownload() async throws {
        if geteuid() == 0 { return }  // directory modes do not bind root
        let tmp = try memorySyncTempDir()
        let parent = tmp + "/mnt"
        try FileManager.default.createDirectory(atPath: parent, withIntermediateDirectories: true)
        chmod(parent, 0o500)
        defer { chmod(parent, 0o700) }
        let fake = MemorySyncFake(["note.md": "v1"], mountPath: parent + "/notes")
        let stores = try fake.stores(workdir: tmp + "/wd")
        do {
            try await stores.download(resources: fake.resources)
            Issue.record("expected a SessionMemoryError")
        } catch let error as SessionMemoryError {
            #expect(error.message.contains("writable"))
        }
        #expect(fake.server.received.isEmpty)
    }

    @Test(arguments: ["/mnt/../../etc/cron.d", "relative/notes", "", "notes"])
    func anUncleanMountPathFailsTheDownload(bad: String) async throws {
        // "" means the resource carries no mount_path at all — that one falls back to the workdir.
        let tmp = try memorySyncTempDir()
        let fake = MemorySyncFake(["note.md": "v1"], mountPath: bad.isEmpty ? nil : bad)
        let stores = try fake.stores(workdir: tmp + "/wd")

        if bad.isEmpty {
            try await stores.download(resources: fake.resources)
            #expect(MemorySyncFolder(tmp + "/wd/memory/notes").read("note.md") == "v1")
            return
        }
        do {
            try await stores.download(resources: fake.resources)
            Issue.record("expected a SessionMemoryError")
        } catch let error as SessionMemoryError {
            #expect(error.message.contains("not a clean absolute path"))
        }
        // Nothing was written anywhere, and no store is tracked.
        #expect(!FileManager.default.fileExists(atPath: tmp + "/wd"))
        #expect(fake.server.received.isEmpty)
        #expect(await stores.readOnlyRoots.isEmpty)
    }

    /// Only `memory` items carry content — `memory_prefix` rollups pass through without touching the disk or the
    /// server. (Swift's `download(_:)` only reads the session's `memory_store` resources, so the foreign resource of
    /// the upstream test has no counterpart here.)
    @Test func prefixItemsAndForeignResourcesLeaveNoTrace() async throws {
        let tmp = try memorySyncTempDir()
        let fake = MemorySyncFake(["ok.md": "fine"], noise: true)
        let stores = try fake.stores(workdir: tmp)
        try await stores.download(resources: fake.resources)
        let local = MemorySyncFolder(tmp + "/memory/notes")

        #expect(local.read("ok.md") == "fine")
        #expect(try FileManager.default.contentsOfDirectory(atPath: tmp + "/memory") == ["notes"])
        #expect(!local.exists("projects"))
        await memorySyncRun(stores)
        #expect(fake.server.received.isEmpty)
    }

    /// Nothing but a dead run leaves a folder at the store's path. Refuse — and leave the folder as it was found.
    @Test func aStoreDirectoryThatAlreadyExistsIsRefused() async throws {
        let tmp = try memorySyncTempDir()
        let stale = MemorySyncFolder(tmp + "/memory/notes")
        try stale.write("debris.md", "left by another session")

        let fake = MemorySyncFake(["note.md": "v1"])
        let stores = try fake.stores(workdir: tmp)
        do {
            try await stores.download(resources: fake.resources)
            Issue.record("expected a SessionMemoryError")
        } catch let error as SessionMemoryError {
            #expect(error.message.contains("already exists"))
        }

        // Refused, not adopted and not deleted.
        #expect(stale.read("debris.md") == "left by another session")
        #expect(!stale.exists("note.md"))
        #expect(fake.server.received.isEmpty)
        #expect(await stores.readOnlyRoots.isEmpty)

        // A sibling folder in the same parent is none of our business.
        try FileManager.default.createDirectory(atPath: tmp + "/memory2/unrelated", withIntermediateDirectories: true)
        let fake2 = MemorySyncFake(["note.md": "v1"])
        let ok = try fake2.stores(workdir: tmp + "/memory2")
        try await ok.download(resources: fake2.resources)
        #expect(MemorySyncFolder(tmp + "/memory2/memory/notes").read("note.md") == "v1")
    }

    // MARK: - the sync matrix
    //
    // Every combination of (remote moved?, local moved?) for a path the store has already downloaded. `local` and
    // `remote` say what happened since the last sync (`nil` untouched, "-" deleted); `disk` and `store` are the state
    // both sides must agree on afterwards.

    @Test(arguments: [
        // baseline "v1" on both sides unless the row says otherwise
        ("untouched", nil, nil, "v1", "v1", []),
        ("local edit", "v2", nil, "v2", "v2", [MemorySyncCall(kind: "update", path: "f.md", content: "v2", sha: memorySyncSHA("v1"))]),
        ("remote edit", nil, "v2", "v2", "v2", []),
        ("both edit, server wins", "v2 local", "v2 remote", "v2 remote", "v2 remote", []),
        ("local delete", "-", nil, "-", "-", [MemorySyncCall(kind: "delete", path: "f.md", content: nil, sha: memorySyncSHA("v1"))]),
        ("remote delete", nil, "-", "-", "-", []),
        ("both delete", "-", "-", "-", "-", []),
        ("local delete, remote edit", "-", "v2", "v2", "v2", []),
        ("local edit, remote delete", "v2", "-", "v2", "v2", [MemorySyncCall(kind: "create", path: "f.md", content: "v2", sha: nil)]),
    ] as [(String, String?, String?, String, String, [MemorySyncCall])])
    func syncMatrix(name: String, local: String?, remote: String?, disk: String, store: String, sent: [MemorySyncCall]) async throws {
        let clock = MemorySyncClock()
        let (path, fake, stores, _) = try await memorySyncDownloaded(["f.md": "v1"], clock: clock)
        let server = fake.server

        if local == "-" { try path.unlink("f.md") } else if let local { try path.write("f.md", local) }
        if remote == "-" { server.delete("f.md") } else if let remote { server.write("f.md", remote) }

        // Two passes: a local deletion is only sent after its corroboration window.
        await memorySyncRun(stores)
        clock.now = DELETE_CORROBORATION_SECONDS + 1
        await memorySyncRun(stores)

        if disk == "-" { #expect(!path.exists("f.md"), "\(name)") } else { #expect(path.read("f.md") == disk, "\(name)") }
        if store == "-" { #expect(!server.has("f.md"), "\(name)") } else { #expect(server.texts["f.md"] == store, "\(name)") }
        #expect(server.received == sent, "\(name)")

        // Settled: a second pass sends nothing more and changes nothing.
        await memorySyncRun(stores)
        #expect(server.received == sent, "\(name)")
    }

    // MARK: - the failure column

    @Test func aFailedUploadKeepsTheLocalEditAndRetries() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["f.md": "v1"])
        try local.write("f.md", "v2 from agent")

        fake.memories.wrapUpdate = { _, _ in throw MemorySyncRuntimeError("upload exploded") }
        await memorySyncRun(stores)

        // The agent's edit survives; the server is untouched.
        #expect(local.read("f.md") == "v2 from agent")
        #expect(fake.server.texts["f.md"] == "v1")

        // The baseline still says v1, so the next (working) sync retries the push.
        fake.memories.wrapUpdate = nil
        await memorySyncRun(stores)
        #expect(fake.server.texts["f.md"] == "v2 from agent")
    }

    @Test func aFailedPullLeavesTheOldFileAndRetries() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["f.md": "v1"])
        fake.server.write("f.md", "v2 from server")

        await stores.setHooks(SessionMemoryHooks(beforePut: { _ in throw InjectedIOError() }))
        await memorySyncRun(stores)
        await stores.setHooks(SessionMemoryHooks())

        // The stale file is still there and the baseline never advanced...
        #expect(local.read("f.md") == "v1")
        #expect(fake.server.received.isEmpty)

        // ...so the next sync pulls it, rather than mistaking v1 for a local edit and pushing it back.
        await memorySyncRun(stores)
        #expect(local.read("f.md") == "v2 from server")
        #expect(fake.server.received.isEmpty)
    }

    /// The server deleted the memory; removing our copy fails. The baseline must stay put — dropping it would read the
    /// leftover file as a new local file and create the memory the server just deleted.
    @Test func aFailedLocalRemovalNeverReUploadsTheDeletedMemory() async throws {
        let (local, fake, stores, _) = try await memorySyncDownloaded(["f.md": "v1"])
        fake.server.delete("f.md")

        await stores.setHooks(SessionMemoryHooks(beforeRemove: { _ in throw InjectedIOError() }))
        let (_, capture) = await ToolDiagnostics.capture { await memorySyncRun(stores) }
        await stores.setHooks(SessionMemoryHooks())

        #expect(local.read("f.md") == "v1")
        #expect(fake.server.received.isEmpty)
        #expect(!fake.server.has("f.md"))
        #expect(memorySyncLogText(capture).contains("failed to remove memory deleted remotely"))

        // The retry deletes it locally; it is never pushed back.
        await memorySyncRun(stores)
        #expect(!local.exists("f.md"))
        #expect(fake.server.received.isEmpty)
        #expect(!fake.server.has("f.md"))
    }

    /// `download` throws on the first store it cannot materialise, but the ones that already landed are tracked — so
    /// the caller's dispose still reaps their directories.
    @Test func aStoreThatLandedIsDisposedWhenALaterOneFails() async throws {
        let tmp = try memorySyncTempDir()
        let fake = MemorySyncFake(["note.md": "v1"], brokenLast: true)
        let stores = try fake.stores(workdir: tmp)
        do {
            try await stores.download(resources: fake.resources)
            Issue.record("expected a SessionMemoryError")
        } catch let error as SessionMemoryError {
            #expect(error.message.contains("memstore_broken"))
        }

        let notes = MemorySyncFolder(tmp + "/memory/notes")
        #expect(notes.exists(), "the healthy store landed before the broken one failed")

        await stores.dispose()
        #expect(!notes.exists())
        // The broken store's own half-download self-destructed at the failure.
        #expect(!FileManager.default.fileExists(atPath: tmp + "/memory/broken"))
    }

    /// Stores sync concurrently, and one store's failure never blocks another. The slow store's listing waits for
    /// the fast store's listing to start — only a parallel sync satisfies that — then explodes.
    @Test func storesSyncInParallelAndOneFailureSparesTheRest() async throws {
        let slow = MemorySyncServer(["a.md": "v1"])
        let fast = MemorySyncServer(["b.md": "v1"])
        let router = MemorySyncRouter(["memstore_slow": MemorySyncFakeMemories(slow), "memstore_fast": MemorySyncFakeMemories(fast)])
        let tmp = try memorySyncTempDir()
        let stores = try SessionMemoryStores(memories: router, workdir: tmp, monotonic: { 0 })
        try await stores.download(resources: [("memstore_slow", "slow"), ("memstore_fast", "fast")].map {
            BetaManagedAgentsMemoryStoreResource(memoryStoreID: $0.0, name: $0.1)
        })

        router.syncing.value = true
        try MemorySyncFolder(tmp + "/memory/fast").write("b.md", "v2 from agent")
        let (_, capture) = await ToolDiagnostics.capture { await memorySyncRun(stores) }

        // The slow store failed after seeing the fast store's listing start — proof the two ran concurrently — and
        // the fast store still pushed.
        #expect(memorySyncLogText(capture).contains("slow store exploded"))
        #expect(fast.received == [updated("b.md", "v2 from agent", was: "v1")])
        // The failed store's baseline was kept, so nothing is re-uploaded once it heals.
        #expect(MemorySyncFolder(tmp + "/memory/slow").read("a.md") == "v1")
    }

    @Test func syncIntervalsBelowTheFloorAreRejected() async throws {
        let fake = MemorySyncFake([String: String]())
        let tmp = try memorySyncTempDir()
        // NaN fails every comparison, so a validator phrased as `< floor` would accept it.
        for interval in [4.9, 1.0, 0, -1.0, Double.nan] {
            #expect(throws: ValueError.self) { _ = try fake.stores(workdir: tmp, syncInterval: interval) }
            do {
                _ = try fake.stores(workdir: tmp, syncInterval: interval)
            } catch let error as ValueError {
                #expect(error.message.contains("at least"))
            }
        }
        // The floor itself and "never due" are fine.
        _ = try fake.stores(workdir: tmp, syncInterval: 5.0)
        _ = try fake.stores(workdir: tmp, syncInterval: .infinity)
    }
}

/// Routes each store's calls to its own fake; while `syncing`, the slow store's listing waits for the fast store's
/// to start, then explodes (the `_Router` of the parallel-sync test).
final class MemorySyncRouter: SessionMemoriesAPI, @unchecked Sendable {
    let resources: [String: MemorySyncFakeMemories]
    let syncing = ToolsBox(false)
    private let fastStarted = ToolsBox(false)

    init(_ resources: [String: MemorySyncFakeMemories]) { self.resources = resources }

    func list(_ memoryStoreID: String, view: String, limit: Int) async throws -> AsyncThrowingStream<SessionMemoryItem, Error> {
        if syncing.value {
            if memoryStoreID == "memstore_fast" {
                fastStarted.value = true
            } else {
                // Hangs under a serial sync (fast hasn't run yet) until the 10s bound.
                let start = Date()
                while !fastStarted.value {
                    if Date().timeIntervalSince(start) > 10 { throw MemorySyncRuntimeError("timed out waiting for the fast store") }
                    try await Task.sleep(nanoseconds: 1_000_000)
                }
                throw MemorySyncRuntimeError("slow store exploded")
            }
        }
        return try await resources[memoryStoreID]!.list(memoryStoreID, view: view, limit: limit)
    }

    func retrieve(_ memoryID: String, memoryStoreID: String, view: String) async throws -> SessionMemoryItem {
        try await resources[memoryStoreID]!.retrieve(memoryID, memoryStoreID: memoryStoreID, view: view)
    }

    func create(_ memoryStoreID: String, path: String, content: String) async throws -> SessionMemoryItem {
        try await resources[memoryStoreID]!.create(memoryStoreID, path: path, content: content)
    }

    func update(_ memoryID: String, memoryStoreID: String, content: String, preconditionSHA256: String) async throws -> SessionMemoryItem {
        try await resources[memoryStoreID]!.update(memoryID, memoryStoreID: memoryStoreID, content: content, preconditionSHA256: preconditionSHA256)
    }

    func delete(_ memoryID: String, memoryStoreID: String, expectedContentSHA256: String?) async throws {
        try await resources[memoryStoreID]!.delete(memoryID, memoryStoreID: memoryStoreID, expectedContentSHA256: expectedContentSHA256)
    }
}
