// Port of `anthropic/lib/tools/_file_store.py`: `FileStore`, one confined folder; a relative path cannot escape it.
//
// Beta scope, as upstream: symlinks are refused or skipped wherever the store meets them, but there is no hardening
// against a process racing the store's own syscalls.

import Foundation

#if canImport(Glibc)
    import Glibc
#elseif canImport(Darwin)
    import Darwin
#endif

/// A refused operation: input the store will not act on. OS errors propagate as `ToolFileSystemError`.
public struct FileStoreError: Error, CustomStringConvertible, Equatable, Sendable {
    public static let ESCAPES_ROOT = "escapes the store root"
    public static let IS_A_SYMLINK = "is a symlink"
    public static let NOT_A_FILE = "is not a regular file"
    public static let NOT_A_DIRECTORY = "is not a directory"
    public static let NOT_UTF8 = "is not valid utf-8"
    public static let MOVE_DESTINATION_EXISTS = "already exists"

    public let reason: String
    public let relPath: String

    public init(_ reason: String, _ relPath: String) {
        self.reason = reason
        self.relPath = relPath
    }

    public var description: String { "path \(pythonStringRepr(relPath)) \(reason)" }
}

/// The store's resolved root, and whether `dispose()` removes it.
public struct FileStoreRoot: Sendable, Equatable {
    public let path: String
    /// `true` when `open` found no root, so `dispose()` removes it. A root that was already there is kept.
    public let removedOnDispose: Bool
}

/// One confined folder of regular files (`FileStore` / `LocalFileStore`).
///
/// Every `relPath` is relative to the root (a leading `/` also means the root) and refused with `FileStoreError`
/// when it escapes. The store holds regular files only: symlinks are refused on read and skipped by listings
/// (`findSymlinks` reports them). Only `createRoot()` makes the root: writes create directories below it, never the
/// root itself.
public actor FileStore {
    private struct Hashed {
        let mtimeNs: Int64
        let ctimeNs: Int64
        let size: Int64
        let sha: String
    }

    private let rootPath: String
    private let removedOnDispose: Bool
    private let utf8Only: Bool
    private var hashes: [String: Hashed] = [:]
    /// The clock `hashtree` compares file stamps against (tests freeze it).
    var nowNs: @Sendable () -> Int64 = { Int64(Date().timeIntervalSince1970 * 1_000_000_000) }
    /// Files whose stamps are this close to the walk are re-hashed next walk (`_TIMESTAMP_TRUST_MARGIN_NS`).
    var trustMarginNs: Int64 = 2_000_000_000
    /// Called with the name of every file whose contents are hashed (tests count re-reads).
    var onHashFile: (@Sendable (String) -> Void)?

    /// Replaces the clock, the trust margin and the hashing hook (what upstream's tests monkeypatch).
    func setHashingHooks(now: (@Sendable () -> Int64)? = nil, trustMarginNs: Int64? = nil,
                         onHashFile: (@Sendable (String) -> Void)? = nil)
    {
        if let now { nowNs = now }
        if let trustMarginNs { self.trustMarginNs = trustMarginNs }
        if let onHashFile { self.onHashFile = onHashFile }
    }

    init(root: String, removedOnDispose: Bool, utf8Only: Bool) {
        self.rootPath = root
        self.removedOnDispose = removedOnDispose
        self.utf8Only = utf8Only
    }

    /// `true` for a path usable verbatim as a store location: absolute, no `..`.
    public static func isPathLegal(_ path: String) -> Bool {
        path.hasPrefix("/") && !path.split(separator: "/").contains("..")
    }

    /// Resolves `root`; creates nothing (only `createRoot()` makes the folder).
    public static func open(_ root: String, utf8Only: Bool = false) async throws -> FileStore {
        let removed = FileOps.lstatInfo(root) == nil
        return FileStore(root: FileOps.resolve(root), removedOnDispose: removed, utf8Only: utf8Only)
    }

    /// Create the root directory and any missing ancestors; already existing is fine.
    public func createRoot() throws {
        var missing: [String] = []
        var current = rootPath
        while !FileOps.exists(current) && current != FileOps.parent(current) {
            missing.append(current)
            current = FileOps.parent(current)
        }
        for directory in missing.reversed() {
            if mkdir(directory, 0o700) != 0 && errno != EEXIST {
                throw ToolFileSystemError(code: errno, path: directory, operation: "mkdir")
            }
        }
    }

    public var root: FileStoreRoot { FileStoreRoot(path: rootPath, removedOnDispose: removedOnDispose) }

    /// Removes the root iff `open` created it; pre-existing roots are kept.
    public func dispose() throws {
        guard removedOnDispose, FileOps.lstatInfo(rootPath) != nil else { return }
        try FileOps.removeTree(rootPath)
    }

    /// Writes `data` atomically to the file at `relPath`. Missing directories below the root are created; a missing
    /// root is not (the write fails with `ENOENT`).
    public func put(_ relPath: String, _ data: Data, isExecutable: Bool = false) throws {
        let tail = relPath.replacingOccurrences(of: "\\", with: "/")
        if tail.hasSuffix("/") || tail.hasSuffix("/.") || tail == "" || tail == "." {
            throw FileStoreError(FileStoreError.NOT_A_FILE, relPath)
        }
        let dest = try resolveUnderRoot(relPath)
        try requireUTF8(relPath, data)
        try makeDirsBelowRoot(FileOps.parent(dest))
        try replaceViaTemp(dest, data, isExecutable: isExecutable)
    }

    /// Writes `text` (UTF-8) atomically to the file at `relPath`.
    public func put(_ relPath: String, _ text: String, isExecutable: Bool = false) throws {
        try put(relPath, Data(text.utf8), isExecutable: isExecutable)
    }

    /// The file's bytes; `nil` when absent.
    public func get(_ relPath: String) throws -> Data? {
        let dest = try resolveUnderRoot(relPath)
        let fd: Int32
        do { fd = try openRegularFile(relPath, dest) } catch let e as ToolFileSystemError where e.isNotFound { return nil }
        defer { close(fd) }
        let data = try readAll(fd, dest)
        try requireUTF8(relPath, data)
        return data
    }

    /// The relative path of every file under the directory `under`.
    public func ls(_ under: String = "/") throws -> Set<String> {
        Set(try filenames(under).map(\.0))
    }

    /// Every symlink under `under`: listings skip them and reads refuse them.
    public func findSymlinks(_ under: String = "/") throws -> Set<String> {
        let base = try resolveUnderRoot(under)
        guard let st = FileOps.lstatInfo(base) else { return [] }
        if (st.st_mode & S_IFMT) == S_IFLNK { return [relative(base)] }
        guard (st.st_mode & S_IFMT) == S_IFDIR else { throw FileStoreError(FileStoreError.NOT_A_DIRECTORY, under) }
        var out = Set<String>()
        try walk(base) { full, st in
            if (st.st_mode & S_IFMT) == S_IFLNK { out.insert(relative(full)) }
        }
        return out
    }

    /// `[relPath: sha256Hex]` of every file under `under`. Unchanged files (same size, mtime and ctime since the
    /// last call) reuse their recorded hash.
    public func hashtree(_ under: String = "/") throws -> [String: String] {
        let walkStart = nowNs()
        var out: [String: String] = [:]
        for (rel, full) in try filenames(under) {
            if let sha = try hashViaCache(rel, full, walkStart) { out[rel] = sha }
        }
        return out
    }

    /// One file's sha256; `nil` when absent. Shares `hashtree`'s cache.
    public func hashFile(_ relPath: String) throws -> String? {
        let dest = try resolveUnderRoot(relPath)
        guard let st = FileOps.lstatInfo(dest) else { return nil }
        if (st.st_mode & S_IFMT) == S_IFLNK { throw FileStoreError(FileStoreError.IS_A_SYMLINK, relPath) }
        if (st.st_mode & S_IFMT) != S_IFREG { throw FileStoreError(FileStoreError.NOT_A_FILE, relPath) }
        return try hashViaCache(relative(dest), dest, nowNs())
    }

    /// Renames `src` to `dst`; an existing `dst` is refused. The store root as either end does nothing.
    public func move(_ src: String, _ dst: String) throws {
        let s = try resolveUnderRoot(src)
        let d = try resolveUnderRoot(dst)
        if s == rootPath || d == rootPath { return }
        if FileOps.exists(d) { throw FileStoreError(FileStoreError.MOVE_DESTINATION_EXISTS, dst) }
        try makeDirsBelowRoot(FileOps.parent(d))
        try FileOps.renamePath(s, d)
    }

    /// Deletes a file or subtree; absent, and the store root, do nothing.
    public func remove(_ relPath: String) throws {
        let dest = try resolveUnderRoot(relPath)
        if dest == rootPath { return }
        guard let st = FileOps.lstatInfo(dest) else { return }
        if (st.st_mode & S_IFMT) == S_IFDIR {
            try? FileOps.removeTree(dest)
        } else if unlink(dest) != 0 && errno != ENOENT {
            throw ToolFileSystemError(code: errno, path: dest, operation: "unlink")
        }
    }

    // MARK: Helpers

    private func resolveUnderRoot(_ relPath: String) throws -> String {
        var normalized = relPath.replacingOccurrences(of: "\\", with: "/")
        while normalized.hasPrefix("/") { normalized.removeFirst() }
        let parts = normalized.split(separator: "/").map(String.init).filter { $0 != "." && !$0.isEmpty }
        if parts.contains("..") { throw FileStoreError(FileStoreError.ESCAPES_ROOT, relPath) }
        return parts.isEmpty ? rootPath : rootPath + "/" + parts.joined(separator: "/")
    }

    private func relative(_ full: String) -> String {
        full == rootPath ? "." : String(full.dropFirst(rootPath.count + 1))
    }

    private func requireUTF8(_ relPath: String, _ data: Data) throws {
        if utf8Only && String(data: data, encoding: .utf8) == nil { throw FileStoreError(FileStoreError.NOT_UTF8, relPath) }
    }

    /// Never the root itself: only `createRoot()` makes it.
    private func makeDirsBelowRoot(_ directory: String) throws {
        guard directory != rootPath else { return }
        var current = rootPath
        for part in String(directory.dropFirst(rootPath.count + 1)).split(separator: "/") {
            current += "/" + part
            if mkdir(current, 0o700) != 0 && errno != EEXIST {
                throw ToolFileSystemError(code: errno, path: current, operation: "mkdir")
            }
        }
    }

    private func replaceViaTemp(_ dest: String, _ data: Data, isExecutable: Bool) throws {
        let mode: mode_t = isExecutable ? 0o700 : 0o600
        let random = (0..<8).map { _ in String(format: "%02x", UInt8.random(in: 0...255)) }.joined()
        let tmp = FileOps.parent(dest) + "/.fs-\(random).tmp"
        let fd = Glibc_open(tmp, O_WRONLY | O_CREAT | O_EXCL | O_NOFOLLOW, mode)
        if fd < 0 { throw ToolFileSystemError(code: errno, path: tmp, operation: "open") }
        do {
            try data.withUnsafeBytes { raw in
                var offset = 0
                while offset < raw.count {
                    let n = write(fd, raw.baseAddress!.advanced(by: offset), raw.count - offset)
                    if n <= 0 { throw ToolFileSystemError(code: errno, path: tmp, operation: "write") }
                    offset += n
                }
            }
            close(fd)
            if rename(tmp, dest) != 0 { throw ToolFileSystemError(code: errno, path: dest, operation: "rename") }
        } catch {
            close(fd)
            unlink(tmp)
            throw error
        }
    }

    /// Opens a regular file without following a symlink; a FIFO fails the type check instead of blocking.
    private func openRegularFile(_ relPath: String, _ dest: String) throws -> Int32 {
        let fd = Glibc_open(dest, O_RDONLY | O_NOFOLLOW | O_NONBLOCK, 0)
        if fd < 0 {
            if errno == ELOOP || errno == EMLINK { throw FileStoreError(FileStoreError.IS_A_SYMLINK, relPath) }
            throw ToolFileSystemError(code: errno, path: dest, operation: "open")
        }
        var st = stat()
        if fstat(fd, &st) != 0 || (st.st_mode & S_IFMT) != S_IFREG {
            close(fd)
            throw FileStoreError(FileStoreError.NOT_A_FILE, relPath)
        }
        return fd
    }

    private func readAll(_ fd: Int32, _ path: String) throws -> Data {
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 1 << 20)
        while true {
            let n = read(fd, &buffer, buffer.count)
            if n < 0 { throw ToolFileSystemError(code: errno, path: path, operation: "read") }
            if n == 0 { return data }
            data.append(buffer, count: n)
        }
    }

    private func hashFileContents(_ path: String) throws -> String {
        let fd = try openRegularFile((path as NSString).lastPathComponent, path)
        defer { close(fd) }
        onHashFile?((path as NSString).lastPathComponent)
        var hasher = ToolsSHA256()
        var buffer = [UInt8](repeating: 0, count: 1 << 20)
        while true {
            let n = read(fd, &buffer, buffer.count)
            if n < 0 { throw ToolFileSystemError(code: errno, path: path, operation: "read") }
            if n == 0 { break }
            hasher.update(buffer[0..<n])
        }
        return hasher.hexDigest()
    }

    private func hashViaCache(_ rel: String, _ full: String, _ walkStart: Int64) throws -> String? {
        guard let st = FileOps.lstatInfo(full), (st.st_mode & S_IFMT) == S_IFREG else { return nil }
        let (mtime, ctime) = statTimesNs(st)
        let size = Int64(st.st_size)
        let sha: String
        if let cached = hashes[rel], cached.mtimeNs == mtime, cached.ctimeNs == ctime, cached.size == size {
            sha = cached.sha
        } else {
            do { sha = try hashFileContents(full) } catch let e as ToolFileSystemError {
                if e.isNotFound || e.code == ELOOP || e.code == EMLINK { return nil }
                throw e
            } catch is FileStoreError {
                return nil
            }
        }
        // Filesystems stamp times with coarse clocks: files younger than the margin are re-hashed next walk.
        if max(mtime, ctime) < walkStart - trustMarginNs {
            hashes[rel] = Hashed(mtimeNs: mtime, ctimeNs: ctime, size: size, sha: sha)
        }
        return sha
    }

    /// Every regular file under `under` as `(relPath, path)`; an absent `under` is empty, a non-directory refused.
    private func filenames(_ under: String) throws -> [(String, String)] {
        let base = try resolveUnderRoot(under)
        guard let st = FileOps.lstatInfo(base) else { return [] }
        guard (st.st_mode & S_IFMT) == S_IFDIR else { throw FileStoreError(FileStoreError.NOT_A_DIRECTORY, under) }
        var out: [(String, String)] = []
        try walk(base) { full, st in
            if (st.st_mode & S_IFMT) == S_IFREG { out.append((relative(full), full)) }
        }
        return out
    }

    /// Visits every entry below `directory` (lstat), never descending a symlinked directory. A directory that
    /// vanished mid-walk is skipped; any other error propagates.
    private func walk(_ directory: String, _ visit: (String, stat) throws -> Void) throws {
        let names: [String]
        do { names = try FileOps.listDirectory(directory) } catch let e as ToolFileSystemError where e.isNotFound { return }
        for name in names.sorted() {
            let full = directory + "/" + name
            guard let st = FileOps.lstatInfo(full) else { continue }
            try visit(full, st)
            if (st.st_mode & S_IFMT) == S_IFDIR { try walk(full, visit) }
        }
    }
}

/// A file's mtime and ctime in nanoseconds.
func statTimesNs(_ st: stat) -> (Int64, Int64) {
    #if canImport(Darwin)
        let m = st.st_mtimespec, c = st.st_ctimespec
    #else
        let m = st.st_mtim, c = st.st_ctim
    #endif
    return (Int64(m.tv_sec) * 1_000_000_000 + Int64(m.tv_nsec), Int64(c.tv_sec) * 1_000_000_000 + Int64(c.tv_nsec))
}

/// `LocalFileStore` is `FileStore`.
public typealias LocalFileStore = FileStore

private func Glibc_open(_ path: String, _ flags: Int32, _ mode: mode_t) -> Int32 { open(path, flags, mode) }

/// A minimal SHA-256 (FIPS 180-4), for content hashes (Foundation has none on Linux).
struct ToolsSHA256 {
    private var h: [UInt32] = [
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
    ]
    private var buffer: [UInt8] = []
    private var length: UInt64 = 0

    private static let k: [UInt32] = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01,
        0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
        0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
        0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116, 0x1e376c08,
        0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
        0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
    ]

    mutating func update<S: Sequence>(_ bytes: S) where S.Element == UInt8 {
        for b in bytes {
            buffer.append(b)
            length += 1
            if buffer.count == 64 {
                compress(buffer)
                buffer.removeAll(keepingCapacity: true)
            }
        }
    }

    private mutating func compress(_ block: [UInt8]) {
        var w = [UInt32](repeating: 0, count: 64)
        for i in 0..<16 {
            w[i] = UInt32(block[i * 4]) << 24 | UInt32(block[i * 4 + 1]) << 16 | UInt32(block[i * 4 + 2]) << 8 | UInt32(block[i * 4 + 3])
        }
        func rotr(_ x: UInt32, _ n: UInt32) -> UInt32 { (x >> n) | (x << (32 - n)) }
        for i in 16..<64 {
            let s0 = rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ (w[i - 15] >> 3)
            let s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ (w[i - 2] >> 10)
            w[i] = w[i - 16] &+ s0 &+ w[i - 7] &+ s1
        }
        var (a, b, c, d, e, f, g, hh) = (h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7])
        for i in 0..<64 {
            let s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25)
            let ch = (e & f) ^ (~e & g)
            let t1 = hh &+ s1 &+ ch &+ Self.k[i] &+ w[i]
            let s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22)
            let maj = (a & b) ^ (a & c) ^ (b & c)
            let t2 = s0 &+ maj
            (hh, g, f, e, d, c, b, a) = (g, f, e, d &+ t1, c, b, a, t1 &+ t2)
        }
        h[0] = h[0] &+ a; h[1] = h[1] &+ b; h[2] = h[2] &+ c; h[3] = h[3] &+ d
        h[4] = h[4] &+ e; h[5] = h[5] &+ f; h[6] = h[6] &+ g; h[7] = h[7] &+ hh
    }

    mutating func hexDigest() -> String {
        let bitLength = length * 8
        var tail = buffer + [0x80]
        while tail.count % 64 != 56 { tail.append(0) }
        for i in (0..<8).reversed() { tail.append(UInt8((bitLength >> (UInt64(i) * 8)) & 0xff)) }
        for start in stride(from: 0, to: tail.count, by: 64) { compress(Array(tail[start..<start + 64])) }
        return h.map { String(format: "%08x", $0) }.joined()
    }

    static func hex(_ data: Data) -> String {
        var hasher = ToolsSHA256()
        hasher.update(data)
        return hasher.hexDigest()
    }
}
