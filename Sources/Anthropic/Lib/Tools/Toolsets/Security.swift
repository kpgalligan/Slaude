// Port of `anthropic/lib/tools/_toolsets/_security.py`: filesystem checks for browser toolsets.
//
// `betaCheckUploadPath` is default-deny: no roots means every path is refused. `BetaLocalFilePolicy` is the file
// policy the SDK ships: upload roots, a download directory, and whether download paths reach the model. The path
// handling follows Python's `posixpath` (`normpath`, `abspath`, non-strict `realpath`).

import Foundation
#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

/// A crafted path with tens of thousands of components would stall the component-by-component resolution, and no
/// real upload path is anywhere near this, so an over-long one is refused before the walk.
let MAX_UPLOAD_PATH_LENGTH = 4096

enum ToolsetSecurity {
    /// Whether the Windows-only checks apply (`ON_WINDOWS`); task-local so a test can switch them on.
    @TaskLocal static var onWindows = false
    /// Sees every path `realpathLenient` resolves (a test's spy on `realpath_lenient`).
    @TaskLocal static var resolveObserver: (@Sendable (String) -> Void)?
}

// MARK: - posixpath

/// `posixpath.normpath`.
func posixNormpath(_ path: String) -> String {
    if path.isEmpty { return "." }
    var initialSlashes = path.hasPrefix("/") ? 1 : 0
    // POSIX allows one or two initial slashes, but treats three or more as a single slash.
    if initialSlashes == 1 && path.hasPrefix("//") && !path.hasPrefix("///") { initialSlashes = 2 }
    var comps: [String] = []
    for comp in path.split(separator: "/", omittingEmptySubsequences: true).map(String.init) {
        if comp == "." { continue }
        if comp != ".." || (initialSlashes == 0 && comps.isEmpty) || (comps.last == "..") {
            comps.append(comp)
        } else if !comps.isEmpty {
            comps.removeLast()
        }
    }
    let joined = comps.joined(separator: "/")
    let result = String(repeating: "/", count: initialSlashes) + joined
    return result.isEmpty ? "." : result
}

/// `posixpath.join(a, b)`.
func posixJoin(_ a: String, _ b: String) -> String {
    if b.hasPrefix("/") { return b }
    if a.isEmpty || a.hasSuffix("/") { return a + b }
    return a + "/" + b
}

/// `posixpath.abspath`.
func posixAbspath(_ path: String) -> String {
    if path.hasPrefix("/") { return posixNormpath(path) }
    return posixNormpath(posixJoin(FileManager.default.currentDirectoryPath, path))
}

/// `posixpath.split`.
private func posixSplit(_ path: String) -> (String, String) {
    guard let slash = path.lastIndex(of: "/") else { return ("", path) }
    let head = String(path[...slash])
    let tail = String(path[path.index(after: slash)...])
    let trimmed = head.allSatisfy { $0 == "/" } ? head : String(head.reversed().drop(while: { $0 == "/" }).reversed())
    return (trimmed, tail)
}

private struct RealpathError: Error {}

private func lstatIsLink(_ path: String, strict: Bool) throws -> Bool {
    var st = stat()
    if lstat(path, &st) != 0 {
        if strict { throw RealpathError() }
        return false
    }
    return (st.st_mode & S_IFMT) == S_IFLNK
}

private func readLinkTarget(_ path: String) throws -> String {
    var buffer = [CChar](repeating: 0, count: 4097)
    let count = readlink(path, &buffer, 4096)
    if count < 0 { throw RealpathError() }
    return String(decoding: buffer[0..<count].map { UInt8(bitPattern: $0) }, as: UTF8.self)
}

/// CPython's `_joinrealpath`.
private func joinRealpath(_ start: String, _ rest: String, strict: Bool, _ seen: inout [String: String?]) throws -> (String, Bool) {
    var path = start
    var rest = Substring(rest)
    if rest.hasPrefix("/") {
        rest = rest.dropFirst()
        path = "/"
    }
    while !rest.isEmpty {
        let name: String
        if let slash = rest.firstIndex(of: "/") {
            name = String(rest[..<slash])
            rest = rest[rest.index(after: slash)...]
        } else {
            name = String(rest)
            rest = ""
        }
        if name.isEmpty || name == "." { continue }
        if name == ".." {
            if !path.isEmpty {
                let (head, tail) = posixSplit(path)
                path = head
                if tail == ".." { path = posixJoin(posixJoin(path, ".."), "..") }
            } else {
                path = ".."
            }
            continue
        }
        let newpath = posixJoin(path, name)
        if !(try lstatIsLink(newpath, strict: strict)) {
            path = newpath
            continue
        }
        if let known = seen[newpath] {
            if let resolved = known {
                path = resolved
                continue
            }
            // a symlink loop
            if strict { throw RealpathError() }
            return (posixJoin(newpath, String(rest)), false)
        }
        seen[newpath] = .some(nil)
        let (resolved, ok) = try joinRealpath(path, try readLinkTarget(newpath), strict: strict, &seen)
        path = resolved
        if !ok { return (posixJoin(path, String(rest)), false) }
        seen[newpath] = .some(path)
    }
    return (path, true)
}

/// `os.path.realpath(path, strict=strict)`: absolute, every existing symlink resolved and `..` collapsed. Strict, a
/// component that does not exist (or a loop) throws.
func posixRealpath(_ path: String, strict: Bool = false) throws -> String {
    var seen: [String: String?] = [:]
    let (resolved, _) = try joinRealpath("", path, strict: strict, &seen)
    let absolute = posixAbspath(resolved)
    if strict {
        var st = stat()
        if stat(absolute, &st) != 0 { throw RealpathError() }
    }
    return absolute
}

/// `path` made absolute with every existing symlink resolved and `..` collapsed (`realpath_lenient`). Components
/// that do not exist yet stay as written after the resolved prefix.
func realpathLenient(_ path: String) -> String {
    ToolsetSecurity.resolveObserver?(path)
    return (try? posixRealpath(path)) ?? posixAbspath(path)
}

private func components(_ path: String) -> [String] {
    path.split(separator: "/", omittingEmptySubsequences: true).map(String.init)
}

/// Whether `parent` is a proper ancestor of `child` (`PurePath(parent) in PurePath(child).parents`).
private func isAncestor(_ parent: String, of child: String) -> Bool {
    let p = components(parent)
    let c = components(child)
    return p.count < c.count && Array(c.prefix(p.count)) == p && (parent.hasPrefix("/") == child.hasPrefix("/"))
}

// MARK: - Windows network and device names

private let dosDeviceNameRegex = try! NSRegularExpression(
    pattern: "^(?:CON|PRN|AUX|NUL|CONIN\\$|CONOUT\\$|COM[0-9\u{00b9}\u{00b2}\u{00b3}]|LPT[0-9\u{00b9}\u{00b2}\u{00b3}])(?:[.:].*)?$",
    options: [.caseInsensitive])

private func pythonRStrip(_ s: String, _ chars: Set<Character>) -> String {
    var s = Substring(s)
    while let last = s.last, chars.contains(last) { s = s.dropLast() }
    return String(s)
}

/// Whether, on Windows, `candidate` is a UNC / device-namespace path or has a component naming a DOS device
/// (`names_network_or_device`). Elsewhere these are ordinary names and this is `false`.
func namesNetworkOrDevice(_ candidate: String) -> Bool {
    guard ToolsetSecurity.onWindows else { return false }
    if candidate.hasPrefix("//") || candidate.hasPrefix("\\\\") || candidate.hasPrefix("/\\") || candidate.hasPrefix("\\/") {
        return true
    }
    for part in candidate.split(whereSeparator: { $0 == "\\" || $0 == "/" || $0 == ":" }) {
        // Win32 resolves a device name from a component's stem: the text up to the first "." or ":", with trailing
        // spaces and dots dropped.
        let stemEnd = part.firstIndex(where: { $0 == "." || $0 == ":" }) ?? part.endIndex
        let stemText = pythonRStrip(String(part[..<stemEnd]), [" ", "."])
        let range = NSRange(stemText.startIndex..., in: stemText)
        if dosDeviceNameRegex.firstMatch(in: stemText, range: range) != nil { return true }
    }
    return false
}

// MARK: - The upload check

/// Whether `candidate`, normalised as text, is `directory` (as written or as it resolves) or below it
/// (`lexically_under`).
func lexicallyUnder(_ candidate: String, _ directory: String) -> Bool {
    let text = posixNormpath(candidate)
    for base in Set([directory, realpathLenient(directory)]) {
        let normalized = posixNormpath(base)
        var trimmed = normalized
        while trimmed.hasSuffix("/") || trimmed.hasSuffix("\\") { trimmed.removeLast() }
        if text == normalized || text.hasPrefix(trimmed + "/") { return true }
    }
    return false
}

/// Return the resolved path of `path` if it lies under one of `roots` (symlinks resolved on both sides,
/// whole-component comparison), else throw `UploadRefusedError` (a `ToolError`) (`beta_check_upload_path`).
///
/// The refusal never lists the roots. Empty `roots` refuses everything. With `strictRoots` (the default), a root that
/// does not resolve on disk grants nothing; pass `strictRoots: false` for a lenient containment check that tolerates
/// a not-yet-existing root.
public func betaCheckUploadPath(_ path: String, _ roots: [String], strictRoots: Bool = true) throws -> String {
    if roots.isEmpty { throw UploadNoRootsError() }
    let candidate = path
    if candidate.isEmpty || candidate.contains("\u{0}") {
        throw UploadRefusedError("file_upload path is empty or contains a NUL byte")
    }
    if candidate.unicodeScalars.count > MAX_UPLOAD_PATH_LENGTH { throw UploadRefusedError("file_upload path is too long") }

    // Refused before anything touches the filesystem, on Windows: resolving a UNC path makes the redirector
    // authenticate to the named host, and a DOS device name opens the device rather than a file.
    if namesNetworkOrDevice(candidate) { throw UploadOutsideRootsError() }

    let usableRoots = roots.filter { !pythonStrip($0).isEmpty && !$0.contains("\u{0}") }
    if usableRoots.isEmpty { throw UploadNoRootsError() }

    if strictRoots && candidate.split(whereSeparator: { $0 == "/" || $0 == "\\" }).contains("..") {
        // An upload path is model output, so a ".." component is never legitimate.
        throw UploadRefusedError("file_upload path must not contain a '..' component")
    }
    if strictRoots && !usableRoots.contains(where: { lexicallyUnder(posixAbspath(candidate), $0) }) {
        // Decided on the text first: a path that does not even claim to be under an upload root is refused without
        // touching the filesystem.
        throw UploadOutsideRootsError()
    }

    let resolved = realpathLenient(candidate)
    if namesNetworkOrDevice(resolved) { throw UploadOutsideRootsError() }

    for rootText in usableRoots {
        let resolvedRoot: String
        if strictRoots {
            // a root that does not exist grants nothing
            guard let r = try? posixRealpath(rootText, strict: true) else { continue }
            resolvedRoot = r
        } else {
            resolvedRoot = (try? posixRealpath(rootText)) ?? posixAbspath(rootText)
        }
        if resolved == resolvedRoot || isAncestor(resolvedRoot, of: resolved) { return resolved }
    }
    throw UploadOutsideRootsError()
}

private func foldedForComparison(_ path: String) -> String {
    // a macOS disk usually ignores letter case and the Unicode form of a name
    path.lowercased().precomposedStringWithCanonicalMapping
}

/// Whether `downloadDir` is inside (or contains) an upload root, which opens the download-then-upload loop
/// (`download_dir_conflicts`). Compared on the literal and on the resolved paths.
func downloadDirConflicts(_ downloadDir: String, _ uploadRoots: [String]) -> Bool {
    let literal = downloadDir
    let resolved = realpathLenient(downloadDir)
    for root in uploadRoots {
        let resolvedRoot = realpathLenient(root)
        for (d, r) in [(literal, root), (resolved, resolvedRoot)] {
            let df = posixNormpath(foldedForComparison(d))
            let rf = posixNormpath(foldedForComparison(r))
            if df == rf || isAncestor(rf, of: df) || isAncestor(df, of: rf) { return true }
        }
    }
    return false
}

/// The file policy the SDK ships (`BetaLocalFilePolicy`): `file_upload` may read paths under `uploadRoots`
/// (symlinks resolved, whole components compared, a `..` component refused outright) and may name the document ids
/// listed in `uploadDocumentIDs` (none by default), and a `download_completed` path reaches the model only with
/// `exposeDownloadPaths: true` and only when it lies inside `downloadDir`.
///
/// Keep the roots to one dedicated directory holding only the task's files, and put `downloadDir` outside every
/// upload root and outside anything another tool can reach. The driver chooses where downloads are written; this
/// object only controls what the model may see.
open class BetaLocalFilePolicy: BetaFilePolicy, @unchecked Sendable {
    public let uploadRoots: [String]
    public let uploadDocumentIDs: Set<String>
    public let downloadDir: String?
    public let exposeDownloadPaths: Bool

    public init(uploadRoots: [String] = [], uploadDocumentIDs: [String] = [], downloadDir: String? = nil,
                exposeDownloadPaths: Bool = false) throws
    {
        if uploadRoots.contains(where: { pythonStrip($0).isEmpty }) {
            // Anchoring an empty entry would silently make it the working directory.
            throw ToolsetConfigError("upload_roots entries must not be empty")
        }
        if let downloadDir, pythonStrip(downloadDir).isEmpty { throw ToolsetConfigError("download_dir must not be empty") }
        // Anchored once, here: re-resolving a relative root against the working directory at check time would move
        // the containment boundary.
        self.uploadRoots = uploadRoots.map(posixAbspath)
        self.uploadDocumentIDs = Set(uploadDocumentIDs)
        self.downloadDir = downloadDir.map(posixAbspath)
        self.exposeDownloadPaths = exposeDownloadPaths
        if let dir = self.downloadDir, downloadDirConflicts(dir, self.uploadRoots) {
            throw ToolsetConfigError(
                "download_dir \(pythonStringRepr(dir)) must be outside every upload root, otherwise a page-triggered "
                    + "download landing in an upload root can be read back through file_upload")
        }
    }

    open func resolveUploadPaths(context: BetaURLContext, paths: [String]) throws -> [String] {
        try paths.map { try betaCheckUploadPath($0, uploadRoots) }
    }

    open func resolveUploadDocuments(context: BetaURLContext, documentIDs: [String]) throws -> [String] {
        for doc in documentIDs where !uploadDocumentIDs.contains(doc) {
            // Named by neither id nor count: the refusal must not tell a steering page which ids exist.
            throw UploadRefusedError("document not in the upload allowlist")
        }
        return documentIDs
    }

    open func isPathVisible(_ path: String) throws -> Bool {
        guard exposeDownloadPaths, let downloadDir else { return false }
        if !lexicallyUnder(path, downloadDir) || path.split(whereSeparator: { $0 == "/" || $0 == "\\" }).contains("..") {
            // Decided on the text alone: such a path is never resolved.
            return false
        }
        do {
            _ = try betaCheckUploadPath(path, [downloadDir], strictRoots: false)
        } catch is ToolError {
            return false
        }
        return true
    }
}
