// Port of tests/lib/tools/test_file_store.py and tests/lib/tools/test_files.py.

import Foundation
import Testing
@testable import Anthropic

#if canImport(Glibc)
    import Glibc
#elseif canImport(Darwin)
    import Darwin
#endif

private func sha(_ content: String) -> String { ToolsSHA256.hex(Data(content.utf8)) }

private func createdStore(_ root: String, utf8Only: Bool = false) async throws -> FileStore {
    let fs = try await FileStore.open(root, utf8Only: utf8Only)
    try await fs.createRoot()
    return fs
}

private func readText(_ path: String) -> String? { try? String(contentsOfFile: path, encoding: .utf8) }

private func expectStoreError(_ match: String? = nil, sourceLocation: SourceLocation = #_sourceLocation, _ body: () async throws -> Void) async {
    do {
        try await body()
        Issue.record("expected FileStoreError", sourceLocation: sourceLocation)
    } catch let e as FileStoreError {
        if let match { #expect(e.description.contains(match), "\(e) !~ \(match)", sourceLocation: sourceLocation) }
    } catch {
        Issue.record("expected FileStoreError, got \(error)", sourceLocation: sourceLocation)
    }
}

private func expectNotFound(sourceLocation: SourceLocation = #_sourceLocation, _ body: () async throws -> Void) async {
    do {
        try await body()
        Issue.record("expected ENOENT", sourceLocation: sourceLocation)
    } catch let e as FileSystemError {
        #expect(e.isNotFound, "\(e)", sourceLocation: sourceLocation)
    } catch {
        Issue.record("expected FileSystemError, got \(error)", sourceLocation: sourceLocation)
    }
}

@Suite struct FileStoreTests {
    let tmp = TempDir()

    func store() async throws -> FileStore { try await createdStore(tmp.join("store")) }

    @Test func shaMatchesKnownVectors() {
        #expect(sha("") == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        #expect(sha("abc") == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
        #expect(sha(String(repeating: "a", count: 1000)) == "41edece42d63e8d9bf515a9ba6932e1c20cbc9f5a5d134645adb5db1b9737ea3")
    }

    @Test func putWritesTextAndCreatesOwnerOnlyParents() async throws {
        let store = try await store()
        try await store.put("projects/foo/notes.md", "héllo")
        let dest = tmp.join("store", "projects", "foo", "notes.md")
        #expect(readText(dest) == "héllo")
        #expect(FileOps.mode(FileOps.parent(dest)) == 0o700)
        #expect(FileOps.mode(dest) == 0o600)
    }

    @Test func putExecutableSetsOwnerExec() async throws {
        let store = try await store()
        try await store.put("run.sh", Data("#!/bin/sh\necho hi\n".utf8), isExecutable: true)
        #expect(FileOps.mode(tmp.join("store", "run.sh")) == 0o700)
    }

    @Test func putIsAtomicAndLeavesNoTempOnSuccess() async throws {
        let store = try await store()
        try await store.put("a.md", "first")
        try await store.put("a.md", "second")
        #expect(readText(tmp.join("store", "a.md")) == "second")
        #expect(try FileOps.listDirectory(tmp.join("store")).sorted() == ["a.md"])
    }

    @Test func createsEveryParentOwnerOnlyUnderPermissiveUmask() async throws {
        let old = umask(0)
        defer { umask(old) }
        let root = tmp.join("nested", "store")
        let fs = try await createdStore(root)
        try await fs.put("projects/foo/notes.md", "hi")
        for directory in [tmp.join("nested"), root, root + "/projects", root + "/projects/foo"] {
            #expect(FileOps.mode(directory) == 0o700, "\(directory)")
        }
    }

    @Test(arguments: ["../secret.md", "a/../../secret.md"])
    func everyVerbRefusesAnEscapingPath(bad: String) async throws {
        try "top secret".write(toFile: tmp.join("secret.md"), atomically: false, encoding: .utf8)
        let store = try await store()
        try await store.put("ok.md", "ok")
        await expectStoreError { try await store.put(bad, "nope") }
        await expectStoreError { _ = try await store.get(bad) }
        await expectStoreError { _ = try await store.ls(bad) }
        await expectStoreError { _ = try await store.hashtree(bad) }
        await expectStoreError { _ = try await store.hashFile(bad) }
        await expectStoreError { _ = try await store.findSymlinks(bad) }
        await expectStoreError { try await store.move("ok.md", bad) }
        await expectStoreError { try await store.move(bad, "landed.md") }
        await expectStoreError { try await store.remove(bad) }
        #expect(readText(tmp.join("secret.md")) == "top secret")
    }

    @Test func getDoesNotFollowASymlinkLeaf() async throws {
        let store = try await store()
        try await store.put("real.md", "original")
        symlink(tmp.join("store", "real.md"), tmp.join("store", "link.md"))
        await expectStoreError { _ = try await store.get("link.md") }
        try await store.put("link.md", "new")
        #expect(readText(tmp.join("store", "real.md")) == "original")
        #expect(!FileOps.isSymlink(tmp.join("store", "link.md")))
        #expect(readText(tmp.join("store", "link.md")) == "new")
    }

    @Test func getRefusesANonRegularFile() async throws {
        let store = try await store()
        mkfifo(tmp.join("store", "pipe.md"), 0o600)
        symlink(tmp.join("store", "pipe.md"), tmp.join("store", "link.md"))
        await expectStoreError("not a regular file") { _ = try await store.get("pipe.md") }
        await expectStoreError("is a symlink") { _ = try await store.get("link.md") }
    }

    @Test func getReturnsNilWhenAbsent() async throws {
        let store = try await store()
        #expect(try await store.get("absent.md") == nil)
        try await store.put("present.md", "here")
        #expect(try await store.get("present.md") == Data("here".utf8))
    }

    @Test func lsListsRecursivelyAndNeverDescendsSymlinks() async throws {
        let store = try await store()
        try await store.put("a.md", "alpha")
        try await store.put("sub/b.md", "bravo")
        let outside = tmp.join("outside")
        try FileManager.default.createDirectory(atPath: outside, withIntermediateDirectories: true)
        try "secret".write(toFile: outside + "/s.md", atomically: false, encoding: .utf8)
        symlink(outside, tmp.join("store", "lnkdir"))
        symlink(outside + "/s.md", tmp.join("store", "lnk.md"))
        #expect(try await store.ls() == ["a.md", "sub/b.md"])
        #expect(try await store.ls("sub") == ["sub/b.md"])
        #expect(try await store.ls("absent") == [])
        #expect(try await store.ls("a.md/under") == [])
        await expectStoreError("not a directory") { _ = try await store.ls("a.md") }
    }

    @Test func findSymlinksReportsEverySymlink() async throws {
        let store = try await store()
        try await store.put("a.md", "alpha")
        try await store.put("sub/b.md", "bravo")
        #expect(try await store.findSymlinks() == [])
        let outside = tmp.join("outside")
        try FileManager.default.createDirectory(atPath: outside, withIntermediateDirectories: true)
        try "secret".write(toFile: outside + "/s.md", atomically: false, encoding: .utf8)
        symlink(outside, tmp.join("store", "lnkdir"))
        symlink(outside + "/s.md", tmp.join("store", "sub", "lnk.md"))
        symlink(tmp.join("store", "gone.md"), tmp.join("store", "dangling.md"))
        #expect(try await store.findSymlinks() == ["lnkdir", "sub/lnk.md", "dangling.md"])
        #expect(try await store.findSymlinks("sub") == ["sub/lnk.md"])
        #expect(try await store.findSymlinks("absent") == [])
    }

    @Test func hashtreeHashesRegularFilesAndSkipsSymlinks() async throws {
        let store = try await store()
        try await store.put("a.md", "alpha")
        try await store.put("sub/b.md", "bravo")
        try "secret".write(toFile: tmp.join("secret.txt"), atomically: false, encoding: .utf8)
        symlink(tmp.join("secret.txt"), tmp.join("store", "link.md"))
        #expect(try await store.hashtree() == ["a.md": sha("alpha"), "sub/b.md": sha("bravo")])
        #expect(try await store.hashtree("sub/") == ["sub/b.md": sha("bravo")])
    }

    @Test func listingsRaiseOnAnUnreadableSubdirectory() async throws {
        // Permission checks do not bind root (upstream skips the test there too).
        guard geteuid() != 0 else { return }
        let store = try await store()
        try await store.put("a.md", "alpha")
        try await store.put("locked/b.md", "bravo")
        let locked = tmp.join("store", "locked")
        chmod(locked, 0)
        defer { chmod(locked, 0o700) }
        await #expect(throws: FileSystemError.self) { _ = try await store.hashtree() }
        await #expect(throws: FileSystemError.self) { _ = try await store.ls() }
        await #expect(throws: FileSystemError.self) { _ = try await store.findSymlinks() }
    }

    @Test func hashtreeRefusesASymlinkedPrefix() async throws {
        let store = try await store()
        let outside = tmp.join("outside")
        try FileManager.default.createDirectory(atPath: outside, withIntermediateDirectories: true)
        try "secret".write(toFile: outside + "/secret.md", atomically: false, encoding: .utf8)
        symlink(outside, tmp.join("store", "sub"))
        await expectStoreError { _ = try await store.hashtree("sub") }
    }

    @Test func hashFileHashesOneFileAndSharesTheCache() async throws {
        let store = try await store()
        let hashed = Box<[String]>([])
        await store.setHashingHooks(trustMarginNs: -1_000_000_000_000_000, onHashFile: { name in hashed.mutate { $0.append(name) } })
        try await store.put("a.md", "alpha")
        #expect(try await store.hashFile("a.md") == sha("alpha"))
        #expect(try await store.hashFile("absent.md") == nil)
        #expect(try await store.hashtree() == ["a.md": sha("alpha")])
        #expect(hashed.value == ["a.md"])
        symlink(tmp.join("store", "a.md"), tmp.join("store", "lnk.md"))
        await expectStoreError("is a symlink") { _ = try await store.hashFile("lnk.md") }
    }

    @Test func moveRenamesWithinRootAndRefusesExistingDest() async throws {
        let store = try await store()
        try await store.put("a.md", "alpha")
        try await store.move("a.md", "nested/b.md")
        #expect(try await store.get("nested/b.md") == Data("alpha".utf8))
        #expect(try await store.get("a.md") == nil)
        try await store.put("c.md", "charlie")
        await expectStoreError("exists") { try await store.move("nested/b.md", "c.md") }
    }

    @Test func rootPathIsBannedFromTheInterface() async throws {
        let store = try await store()
        try await store.put("x.md", "x")
        try await store.remove("/")
        #expect(try await store.get("x.md") == Data("x".utf8))
        try await store.move("/", "elsewhere")
        try await store.move("x.md", "/")
        #expect(try await store.ls() == ["x.md"])
        await expectStoreError { try await store.put("/", "data") }
        await expectStoreError("not a regular file") { _ = try await store.get("/") }
    }

    @Test func removeDeletesFileAndSubtree() async throws {
        let store = try await store()
        try await store.put("a.md", "a")
        try await store.put("sub/b.md", "b")
        try await store.remove("a.md")
        #expect(!FileOps.exists(tmp.join("store", "a.md")))
        try await store.remove("sub")
        #expect(!FileOps.exists(tmp.join("store", "sub")))
        try await store.remove("absent.md")
    }

    @Test func removeUnlinksADanglingSymlink() async throws {
        let store = try await store()
        symlink(tmp.join("store", "gone.md"), tmp.join("store", "dangling.md"))
        try await store.remove("dangling.md")
        #expect(!FileOps.isSymlink(tmp.join("store", "dangling.md")))
    }

    @Test func disposeRemovesTheRootItCreatedAndKeepsPreexisting() async throws {
        // `test_filestore_async_with_removes_root_only_if_created` and
        // `test_filestore_dispose_removes_the_root_it_created_and_keeps_preexisting`.
        let fresh = try await createdStore(tmp.join("fresh"))
        try await fresh.put("x.md", "x")
        #expect(await fresh.root == FileStoreRoot(path: FileOps.resolve(tmp.join("fresh")), removedOnDispose: true))
        try await fresh.dispose()
        #expect(!FileOps.exists(tmp.join("fresh")))

        try FileManager.default.createDirectory(atPath: tmp.join("old"), withIntermediateDirectories: true)
        let old = try await FileStore.open(tmp.join("old"))
        try await old.put("y.md", "y")
        #expect(await old.root.removedOnDispose == false)
        try await old.dispose()
        #expect(readText(tmp.join("old", "y.md")) == "y")
    }

    @Test func putWritesArchiveBytesVerbatim() async throws {
        let store = try await store()
        // A zip's local-file-header magic followed by arbitrary bytes.
        let blob = Data([0x50, 0x4B, 0x03, 0x04] + Array("pdf/SKILL.md# pdf".utf8) + [0x00, 0xFF])
        try await store.put("bundle.zip", blob)
        #expect(try await store.get("bundle.zip") == blob)
        #expect(try await store.hashtree() == ["bundle.zip": ToolsSHA256.hex(blob)])
    }

    @Test(arguments: ["bundles/v1/", "dir/.", ".", "/", ""])
    func putRefusesADirectoryRel(bad: String) async throws {
        let store = try await store()
        await expectStoreError { try await store.put(bad, Data("data".utf8)) }
        #expect(try await store.hashtree() == [:])
    }

    @Test func utf8RestrictionRefusesBinaryContent() async throws {
        let store = try await createdStore(tmp.join("store"), utf8Only: true)
        let binary = Data([0xFF, 0xFE, 0x00] + Array(" not utf-8".utf8))
        await expectStoreError("not valid utf-8") { try await store.put("blob.bin", binary) }
        #expect(!FileOps.exists(tmp.join("store", "blob.bin")))
        try await store.put("note.md", "hello")
        try await store.put("bytes.md", Data("hello".utf8))
        #expect(try await store.get("note.md") == Data("hello".utf8))
        try binary.write(to: URL(fileURLWithPath: tmp.join("store", "smuggled.bin")))
        await expectStoreError("not valid utf-8") { _ = try await store.get("smuggled.bin") }
        let loose = try await createdStore(tmp.join("store2"))
        try await loose.put("blob.bin", binary)
        #expect(try await loose.get("blob.bin") == binary)
    }

    @Test func isPathLegal() {
        #expect(FileStore.isPathLegal("/mnt/memory/notes"))
        #expect(!FileStore.isPathLegal("mnt/relative"))
        #expect(!FileStore.isPathLegal("/mnt/../../etc/cron.d"))
        #expect(!FileStore.isPathLegal(""))
    }

    @Test func hashtreeRehashesOnlyWhatChanged() async throws {
        let store = try await store()
        let hashed = Box<[String]>([])
        await store.setHashingHooks(trustMarginNs: -1_000_000_000_000_000, onHashFile: { name in hashed.mutate { $0.append(name) } })
        try await store.put("a.md", "alpha")
        try await store.put("b.md", "bravo")
        #expect(try await store.hashtree() == ["a.md": sha("alpha"), "b.md": sha("bravo")])
        #expect(hashed.value.sorted() == ["a.md", "b.md"])
        hashed.value = []
        #expect(try await store.hashtree() == ["a.md": sha("alpha"), "b.md": sha("bravo")])
        #expect(hashed.value == [])
        // An mtime-and-size-preserving rewrite: ctime is the one stamp it cannot restore.
        try await Task.sleep(nanoseconds: 50_000_000)
        let b = tmp.join("store", "b.md")
        let st = try #require(FileOps.statInfo(b))
        try "BRAVO".write(toFile: b, atomically: false, encoding: .utf8)
        #if canImport(Darwin)
            var times = [st.st_atimespec, st.st_mtimespec]
        #else
            var times = [st.st_atim, st.st_mtim]
        #endif
        utimensat(AT_FDCWD, b, &times, 0)
        #expect(try await store.hashtree()["b.md"] == sha("BRAVO"))
        #expect(hashed.value == ["b.md"])
    }

    @Test func hashtreeDistrustsFreshStamps() async throws {
        let store = try await store()
        let hashed = Box<[String]>([])
        await store.setHashingHooks(onHashFile: { name in hashed.mutate { $0.append(name) } })
        try await store.put("racy.md", "AAAAAA")
        let stamp = statTimesNs(try #require(FileOps.statInfo(tmp.join("store", "racy.md")))).1
        await store.setHashingHooks(now: { stamp })
        #expect(try await store.hashtree()["racy.md"] == sha("AAAAAA"))
        #expect(try await store.hashtree()["racy.md"] == sha("AAAAAA"))
        #expect(hashed.value == ["racy.md", "racy.md"])
        try "BBBBBB".write(toFile: tmp.join("store", "racy.md"), atomically: false, encoding: .utf8)
        #expect(try await store.hashtree()["racy.md"] == sha("BBBBBB"))

        hashed.value = []
        let now = statTimesNs(try #require(FileOps.statInfo(tmp.join("store", "racy.md")))).1
        await store.setHashingHooks(now: { now + 1_500_000_000 })
        _ = try await store.hashtree()
        _ = try await store.hashtree()
        #expect(hashed.value == ["racy.md", "racy.md"])
        await store.setHashingHooks(now: { now + 10_000_000_000 })
        _ = try await store.hashtree()
        _ = try await store.hashtree()
        #expect(hashed.value == ["racy.md", "racy.md", "racy.md"])
    }

    @Test func createRootMakesTheFolderOwnerOnly() async throws {
        let store = try await FileStore.open(tmp.join("store"))
        try await store.createRoot()
        #expect(FileOps.mode(tmp.join("store")) == 0o700)
        try await store.createRoot()
        #expect(await store.root.removedOnDispose)
    }

    @Test func putNeverCreatesAMissingRoot() async throws {
        let root = tmp.join("mnt", "store")
        let fs = try await FileStore.open(root)
        await expectNotFound { try await fs.put("a.md", "a") }
        await expectNotFound { try await fs.put("sub/a.md", "a") }
        #expect(!FileOps.exists(tmp.join("mnt")))
        try await fs.createRoot()
        try await fs.put("a.md", "a")
        try FileOps.removeTree(root)
        await expectNotFound { try await fs.put("b.md", "b") }
        await expectNotFound { try await fs.put("sub/b.md", "b") }
        #expect(!FileOps.exists(root))
        try FileOps.removeTree(tmp.join("mnt"))
        await expectNotFound { try await fs.put("z.md", "z") }
        #expect(!FileOps.exists(tmp.join("mnt")))
        try await fs.createRoot()
        try await fs.put("z.md", "z")
        #expect(try await fs.get("z.md") == Data("z".utf8))
    }

    @Test func moveNeverCreatesAMissingRoot() async throws {
        let store = try await store()
        try await store.put("a.md", "a")
        try FileOps.removeTree(tmp.join("store"))
        await expectNotFound { try await store.move("a.md", "sub/b.md") }
        #expect(!FileOps.exists(tmp.join("store")))
    }
}

@Suite struct FilesTests {
    let tmp = TempDir()

    @Test func readTextExactKeepsCRLFAndLoneCR() throws {
        let path = tmp.join("f.txt")
        try Data("a\r\nb\rc\n".utf8).write(to: URL(fileURLWithPath: path))
        #expect(try FileOps.readTextExact(path) == "a\r\nb\rc\n")
    }

    @Test func writeTextExactWritesVerbatim() throws {
        let path = tmp.join("f.txt")
        try FileOps.atomicWrite(path, Data("a\r\nb\rc\né".utf8))
        #expect(try Data(contentsOf: URL(fileURLWithPath: path)) == Data([0x61, 0x0D, 0x0A, 0x62, 0x0D, 0x63, 0x0A, 0xC3, 0xA9]))
    }

    @Test func readLineRangeCapsTheSelectedBytes() throws {
        let path = tmp.join("lines.txt")
        try Data("one\ntwo\nthree\n".utf8).write(to: URL(fileURLWithPath: path))
        #expect(try readLineRange(path, filePath: "lines.txt", startLine: 2, endLine: 3, limit: 100) == "two\nthree")
        #expect(try readLineRange(path, filePath: "lines.txt", startLine: 3, endLine: 2, limit: 100) == "")
        #expect(throws: ToolError.self) { try readLineRange(path, filePath: "lines.txt", startLine: 1, endLine: 3, limit: 4) }
    }
}
