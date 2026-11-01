// Port of `anthropic/lib/tools/_files.py` plus the POSIX file primitives the file-backed tools share: exact-byte
// reads and writes, restrictive create modes, atomic replace, symlink-aware path resolution.

import Foundation

#if canImport(Glibc)
    import Glibc
#elseif canImport(Darwin)
    import Darwin
#endif

/// Owner read/write only: memory files hold private data, and container umasks are often permissive.
let FILE_CREATE_MODE: mode_t = 0o600
/// Owner-only directories.
let DIR_CREATE_MODE: mode_t = 0o700

let READ_STREAM_CHUNK_BYTES = 64 * 1024

/// A POSIX error from a file primitive, with its `errno`.
struct ToolFileSystemError: Error, CustomStringConvertible {
    let code: Int32
    let path: String
    let operation: String

    var isNotFound: Bool { code == ENOENT }
    var isExists: Bool { code == EEXIST }
    var description: String { "[Errno \(code)] \(String(cString: strerror(code))): '\(path)'" }
}

enum FileOps {
    private static func fail(_ op: String, _ path: String) -> ToolFileSystemError {
        ToolFileSystemError(code: errno, path: path, operation: op)
    }

    static func lstatInfo(_ path: String) -> stat? {
        var s = stat()
        return lstat(path, &s) == 0 ? s : nil
    }

    static func statInfo(_ path: String) -> stat? {
        var s = stat()
        return stat(path, &s) == 0 ? s : nil
    }

    static func exists(_ path: String) -> Bool { statInfo(path) != nil }

    static func isDirectory(_ path: String) -> Bool {
        guard let s = statInfo(path) else { return false }
        return (s.st_mode & S_IFMT) == S_IFDIR
    }

    static func isFile(_ path: String) -> Bool {
        guard let s = statInfo(path) else { return false }
        return (s.st_mode & S_IFMT) == S_IFREG
    }

    static func isSymlink(_ path: String) -> Bool {
        guard let s = lstatInfo(path) else { return false }
        return (s.st_mode & S_IFMT) == S_IFLNK
    }

    static func size(_ path: String) -> Int? { statInfo(path).map { Int($0.st_size) } }

    static func mode(_ path: String) -> mode_t? { statInfo(path).map { $0.st_mode & 0o7777 } }

    /// The exact bytes of a file.
    static func readBytes(_ path: String) throws -> Data {
        let fd = open(path, O_RDONLY)
        if fd < 0 { throw fail("open", path) }
        defer { close(fd) }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: READ_STREAM_CHUNK_BYTES)
        while true {
            let n = read(fd, &buffer, buffer.count)
            if n < 0 { throw fail("read", path) }
            if n == 0 { break }
            data.append(buffer, count: n)
        }
        return data
    }

    /// A UTF-8 file without newline translation (`read_text_exact`).
    static func readTextExact(_ path: String) throws -> String {
        let data = try readBytes(path)
        guard let text = String(data: data, encoding: .utf8) else {
            throw ValueError("'utf-8' codec can't decode the contents of \(path)")
        }
        return text
    }

    private static func writeAll(_ fd: Int32, _ data: Data, _ path: String) throws {
        try data.withUnsafeBytes { (raw: UnsafeRawBufferPointer) in
            var offset = 0
            while offset < raw.count {
                let n = write(fd, raw.baseAddress!.advanced(by: offset), raw.count - offset)
                if n < 0 { throw fail("write", path) }
                if n == 0 { throw ToolFileSystemError(code: EIO, path: path, operation: "write") }
                offset += n
            }
        }
    }

    /// Creates `path` exclusively with `FILE_CREATE_MODE`, writes `data` and fsyncs it.
    static func createExclusive(_ path: String, _ data: Data) throws {
        let fd = open(path, O_CREAT | O_EXCL | O_WRONLY, FILE_CREATE_MODE)
        if fd < 0 { throw fail("open", path) }
        defer { close(fd) }
        try writeAll(fd, data, path)
        if fsync(fd) != 0 { throw fail("fsync", path) }
    }

    /// Writes `data` to a fresh temporary file beside `path`, fsyncs it and renames it over `path`
    /// (`_atomic_write_file`).
    static func atomicWrite(_ path: String, _ data: Data) throws {
        let dir = (path as NSString).deletingLastPathComponent
        let temp = (dir as NSString).appendingPathComponent(".tmp-\(getpid())-\(UUID().uuidString.lowercased())")
        do {
            try createExclusive(temp, data)
            if rename(temp, path) != 0 { throw fail("rename", path) }
        } catch {
            unlink(temp)
            throw error
        }
    }

    /// Creates `path` and any missing parents with `mode`, regardless of umask (`_secure_mkdir`).
    static func secureMkdir(_ path: String, mode: mode_t = DIR_CREATE_MODE) throws {
        var missing: [String] = []
        var current = path
        while !exists(current) {
            missing.append(current)
            let parent = (current as NSString).deletingLastPathComponent
            if parent == current || parent.isEmpty { break }
            current = parent
        }
        for directory in missing.reversed() {
            if mkdir(directory, mode) != 0 {
                if errno == EEXIST { continue }
                throw fail("mkdir", directory)
            }
            // mkdir() is subject to umask; chmod is not.
            chmod(directory, mode)
        }
    }

    /// Removes a file or an empty directory entry (no follow).
    static func unlinkFile(_ path: String) throws {
        if unlink(path) != 0 { throw fail("unlink", path) }
    }

    /// `shutil.rmtree`.
    static func removeTree(_ path: String) throws {
        if let s = lstatInfo(path), (s.st_mode & S_IFMT) == S_IFDIR {
            for name in try listDirectory(path) { try removeTree((path as NSString).appendingPathComponent(name)) }
            if rmdir(path) != 0 { throw fail("rmdir", path) }
        } else {
            try unlinkFile(path)
        }
    }

    static func renamePath(_ old: String, _ new: String) throws {
        if rename(old, new) != 0 { throw fail("rename", old) }
    }

    /// The names in a directory, without `.` and `..`.
    static func listDirectory(_ path: String) throws -> [String] {
        guard let dir = opendir(path) else { throw fail("opendir", path) }
        defer { closedir(dir) }
        var names: [String] = []
        while let entry = readdir(dir) {
            let name = withUnsafePointer(to: entry.pointee.d_name) {
                $0.withMemoryRebound(to: CChar.self, capacity: Int(NAME_MAX) + 1) { String(cString: $0) }
            }
            if name != "." && name != ".." { names.append(name) }
        }
        return names
    }

    static func readLink(_ path: String) -> String? {
        var buffer = [CChar](repeating: 0, count: Int(PATH_MAX) + 1)
        let n = readlink(path, &buffer, buffer.count - 1)
        if n < 0 { return nil }
        buffer[n] = 0
        return String(cString: buffer)
    }

    static var currentDirectory: String { FileManager.default.currentDirectoryPath }

    /// `Path(path).absolute()`.
    static func absolute(_ path: String) -> String {
        path.hasPrefix("/") ? path : (currentDirectory as NSString).appendingPathComponent(path)
    }

    /// `Path.resolve()` (non-strict `os.path.realpath`): symlinks resolved as far as the path exists, `..` applied
    /// to the resolved prefix, the missing tail kept.
    static func resolve(_ path: String) -> String {
        var resolved: [String] = []
        var pending = absolute(path).split(separator: "/", omittingEmptySubsequences: true).map(String.init)
        var hops = 0
        while !pending.isEmpty {
            let component = pending.removeFirst()
            if component == "." { continue }
            if component == ".." {
                if !resolved.isEmpty { resolved.removeLast() }
                continue
            }
            let candidate = "/" + (resolved + [component]).joined(separator: "/")
            if isSymlink(candidate), hops < 40, let target = readLink(candidate) {
                hops += 1
                let targetParts = target.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
                if target.hasPrefix("/") { resolved = [] }
                pending = targetParts + pending
                continue
            }
            resolved.append(component)
        }
        return "/" + resolved.joined(separator: "/")
    }

    /// The parent directory of `path`.
    static func parent(_ path: String) -> String {
        let p = (path as NSString).deletingLastPathComponent
        return p.isEmpty ? "/" : p
    }
}


/// Python string operations over code points (`str` indexes code points; Swift `Character`s merge `\r\n`).
struct CodePoints {
    var scalars: [Unicode.Scalar]

    init(_ s: String) { scalars = Array(s.unicodeScalars) }
    init(_ scalars: [Unicode.Scalar]) { self.scalars = scalars }

    var string: String {
        var view = String.UnicodeScalarView()
        view.append(contentsOf: scalars)
        return String(view)
    }

    var count: Int { scalars.count }

    /// `str.find(sub, start)`.
    func find(_ sub: CodePoints, from start: Int = 0) -> Int? {
        if sub.count == 0 { return start <= count ? start : nil }
        if sub.count > count { return nil }
        var i = start
        while i + sub.count <= count {
            if scalars[i] == sub.scalars[0] && Array(scalars[i..<(i + sub.count)]) == sub.scalars { return i }
            i += 1
        }
        return nil
    }

    /// `str.count(sub)`: non-overlapping occurrences.
    func occurrences(_ sub: CodePoints) -> Int {
        if sub.count == 0 { return count + 1 }
        var n = 0
        var i = 0
        while let pos = find(sub, from: i) {
            n += 1
            i = pos + sub.count
        }
        return n
    }

    /// `str.replace(old, new)`.
    func replacing(_ old: CodePoints, with new: CodePoints) -> CodePoints {
        if old.count == 0 { return self }
        var out: [Unicode.Scalar] = []
        var i = 0
        while let pos = find(old, from: i) {
            out += scalars[i..<pos]
            out += new.scalars
            i = pos + old.count
        }
        out += scalars[i...]
        return CodePoints(out)
    }

    /// `str.split("\n")` for a one-scalar separator.
    func split(_ separator: Unicode.Scalar) -> [String] {
        var parts: [String] = []
        var current: [Unicode.Scalar] = []
        for s in scalars {
            if s == separator {
                parts.append(CodePoints(current).string)
                current = []
            } else {
                current.append(s)
            }
        }
        parts.append(CodePoints(current).string)
        return parts
    }

    /// How many times `scalar` occurs in the first `end` code points.
    func countScalar(_ scalar: Unicode.Scalar, upTo end: Int) -> Int {
        scalars[0..<min(end, count)].filter { $0 == scalar }.count
    }

    func hasSuffix(_ scalar: Unicode.Scalar) -> Bool { scalars.last == scalar }
}

/// Python's `str.rjust(width)`.
func rjust(_ s: String, _ width: Int) -> String {
    let n = s.unicodeScalars.count
    return n >= width ? s : String(repeating: " ", count: width - n) + s
}

/// Collects the bytes of lines `[startLine, endLine]` from consecutive file chunks, capped at `limit`
/// (`LineRangeCollector`).
struct LineRangeCollector {
    let filePath: String
    let startLine: Int
    let endLine: Int
    private let start: Int
    private let end: Int
    let limit: Int
    private var line = 0
    private var collected = Data()

    init(filePath: String, startLine: Int, endLine: Int, limit: Int) {
        self.filePath = filePath
        self.startLine = startLine
        self.endLine = endLine
        self.start = max(0, startLine - 1)
        self.end = endLine > 0 ? endLine : Int.max
        self.limit = limit
    }

    var rangeIsEmpty: Bool { end <= start }
    var rangeIsCollected: Bool { line >= end }

    mutating func collect(from chunk: Data) throws {
        let bytes = [UInt8](chunk)
        var lineStart = 0
        while lineStart < bytes.count && !rangeIsCollected {
            let newline = bytes[lineStart...].firstIndex(of: 0x0A)
            let lineEnd = newline ?? bytes.count
            if line >= start {
                collected.append(contentsOf: bytes[lineStart..<lineEnd])
                if newline != nil && line + 1 < end { collected.append(0x0A) }
                if collected.count > limit { throw overLimitError() }
            }
            guard let newline else { break }
            line += 1
            lineStart = newline + 1
        }
    }

    private func overLimitError() -> ToolError {
        if end - start == 1 {
            return ToolError(
                "read: line \(start + 1) of \(filePath) alone exceeds \(limit)-byte limit. "
                    + "The read tool cannot return part of a line, so view_range cannot narrow this further.")
        }
        return ToolError(
            "read: view_range [\(startLine), \(endLine)] of \(filePath) exceeds \(limit)-byte limit. "
                + "Narrow the view_range to read a smaller portion.")
    }

    func text() throws -> String {
        guard let s = String(data: collected, encoding: .utf8) else { throw ValueError("'utf-8' codec can't decode \(filePath)") }
        return s
    }
}

/// Lines `[startLine, endLine]` of `path`, capping the selected bytes at `limit` (`read_line_range`).
func readLineRange(_ path: String, filePath: String, startLine: Int, endLine: Int, limit: Int) throws -> String {
    var lines = LineRangeCollector(filePath: filePath, startLine: startLine, endLine: endLine, limit: limit)
    if lines.rangeIsEmpty { return "" }
    let fd = open(path, O_RDONLY)
    if fd < 0 { throw ToolFileSystemError(code: errno, path: path, operation: "open") }
    defer { close(fd) }
    var buffer = [UInt8](repeating: 0, count: READ_STREAM_CHUNK_BYTES)
    while true {
        let n = read(fd, &buffer, buffer.count)
        if n < 0 { throw ToolFileSystemError(code: errno, path: path, operation: "read") }
        if n == 0 { break }
        try lines.collect(from: Data(buffer[0..<n]))
        if lines.rangeIsCollected { break }
    }
    return try lines.text()
}
