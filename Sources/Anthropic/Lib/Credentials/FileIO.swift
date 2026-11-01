import Foundation

#if canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#elseif canImport(Darwin)
    import Darwin
#endif

/// The POSIX file operations the credentials subsystem needs (Python's `os` / `pathlib` calls),
/// with `errno` preserved so callers can tell "not found" from "permission denied".

/// An operating-system error (`OSError`).
struct FileSystemError: Error, CustomStringConvertible {
    let code: Int32
    let path: String

    var description: String {
        "[Errno \(code)] \(String(cString: strerror(code))): \(pythonStringRepr(path))"
    }

    var isNotFound: Bool { code == ENOENT }
    var isPermissionDenied: Bool { code == EACCES || code == EPERM }
    var isDirectory: Bool { code == EISDIR }
}

/// Whether the platform has POSIX permission bits (`os.name == "posix"`).
#if os(Windows)
    let credentialsCheckPosixModes = false
#else
    let credentialsCheckPosixModes = true
#endif

/// The status of the file at `path`, following symlinks unless `followSymlinks` is false.
func fileStatus(_ path: String, followSymlinks: Bool = true) throws -> stat {
    var st = stat()
    let rc = followSymlinks ? stat(path, &st) : lstat(path, &st)
    if rc != 0 { throw FileSystemError(code: errno, path: path) }
    return st
}

func isSymlink(_ st: stat) -> Bool { (st.st_mode & S_IFMT) == S_IFLNK }
func isDirectoryMode(_ st: stat) -> Bool { (st.st_mode & S_IFMT) == S_IFDIR }
func permissionBits(_ st: stat) -> Int { Int(st.st_mode) & 0o7777 }

func isRegularFile(_ path: String) -> Bool {
    guard let st = try? fileStatus(path) else { return false }
    return (st.st_mode & S_IFMT) == S_IFREG
}

func fileExists(_ path: String) -> Bool { (try? fileStatus(path)) != nil }

/// `0o644`-style rendering of a mode (Python's `f"{mode:#o}"`).
func octalMode(_ mode: Int) -> String { "0o" + String(mode, radix: 8) }

/// Opens `path` and reads it whole. `checkMode` sees the opened file's status first (an `fstat`,
/// so a symlink is judged by its target) and may throw to refuse the file.
func readFileBytes(_ path: String, checkMode: ((stat) throws -> Void)? = nil) throws -> Data {
    let fd = open(path, O_RDONLY)
    if fd < 0 { throw FileSystemError(code: errno, path: path) }
    defer { _ = posixClose(fd) }
    var st = stat()
    if fstat(fd, &st) != 0 { throw FileSystemError(code: errno, path: path) }
    if isDirectoryMode(st) { throw FileSystemError(code: EISDIR, path: path) }
    try checkMode?(st)
    var data = Data()
    var buffer = [UInt8](repeating: 0, count: 64 * 1024)
    while true {
        let n = buffer.withUnsafeMutableBytes { read(fd, $0.baseAddress, $0.count) }
        if n < 0 {
            if errno == EINTR { continue }
            throw FileSystemError(code: errno, path: path)
        }
        if n == 0 { break }
        data.append(contentsOf: buffer[0..<n])
    }
    return data
}

/// The resolved absolute path, like `Path.resolve(strict=False)`: symlinks in the existing part of
/// the path are followed and `.` / `..` segments normalized.
func resolvePath(_ path: String) -> String {
    let absolute = path.hasPrefix("/") ? path : FileManager.default.currentDirectoryPath + "/" + path
    var existing = absolute
    var rest: [String] = []
    while true {
        if let resolved = realpath(existing, nil) {
            let base = String(cString: resolved)
            free(resolved)
            var components = base.split(separator: "/").map(String.init)
            for c in rest.reversed() {
                if c == "." || c.isEmpty { continue }
                if c == ".." { if !components.isEmpty { components.removeLast() } } else { components.append(c) }
            }
            return "/" + components.joined(separator: "/")
        }
        guard let slash = existing.lastIndex(of: "/"), existing != "/" else { return absolute }
        rest.append(String(existing[existing.index(after: slash)...]))
        existing = slash == existing.startIndex ? "/" : String(existing[..<slash])
    }
}

/// Atomically replaces `url` with `data` (mode 0600): a unique temp file in the same directory,
/// `fsync`, `rename`, then a best-effort `fsync` of the directory. The parent is created 0700.
func atomicWriteSecretFile(_ url: URL, _ data: Data) throws {
    let parent = url.deletingLastPathComponent()
    do {
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true,
                                                attributes: [.posixPermissions: 0o700])
    } catch {
        throw FileSystemError(code: errno == 0 ? EIO : errno, path: parent.path)
    }
    var template = Array((parent.path + "/." + url.lastPathComponent + ".XXXXXX.tmp").utf8CString)
    let fd = template.withUnsafeMutableBufferPointer { mkstemps($0.baseAddress!, 4) }
    if fd < 0 { throw FileSystemError(code: errno, path: parent.path) }
    let tmp = template.withUnsafeBufferPointer { String(cString: $0.baseAddress!) }
    do {
        do {
            defer { _ = posixClose(fd) }
            if fchmod(fd, 0o600) != 0 { throw FileSystemError(code: errno, path: tmp) }
            try data.withUnsafeBytes { raw in
                var offset = 0
                while offset < raw.count {
                    let n = write(fd, raw.baseAddress! + offset, raw.count - offset)
                    if n < 0 {
                        if errno == EINTR { continue }
                        throw FileSystemError(code: errno, path: tmp)
                    }
                    offset += n
                }
            }
            if fsync(fd) != 0 { throw FileSystemError(code: errno, path: tmp) }
        }
        if rename(tmp, url.path) != 0 { throw FileSystemError(code: errno, path: url.path) }
    } catch {
        _ = unlink(tmp)
        throw error
    }
    let dirFD = open(parent.path, O_RDONLY)
    if dirFD >= 0 {
        _ = fsync(dirFD)
        _ = posixClose(dirFD)
    }
}

/// `close(2)`, named so it doesn't clash with the many `close()` methods in scope.
@inline(__always) func posixClose(_ fd: Int32) -> Int32 {
    #if canImport(Glibc)
        return Glibc.close(fd)
    #elseif canImport(Musl)
        return Musl.close(fd)
    #else
        return Darwin.close(fd)
    #endif
}
