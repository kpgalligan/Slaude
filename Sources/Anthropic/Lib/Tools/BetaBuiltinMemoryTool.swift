// Port of `anthropic/lib/tools/_beta_builtin_memory_tool.py` (the async classes) and `anthropic/tools/memory.py`.

import Foundation

#if canImport(Glibc)
    import Glibc
#elseif canImport(Darwin)
    import Darwin
#endif

let MEMORY_MAX_LINES = 999_999
let LINE_NUMBER_WIDTH = String(MEMORY_MAX_LINES).count

/// The base class for a memory tool backend (`BetaAsyncAbstractMemoryTool`). Subclass it and override the six
/// command handlers to store memories anywhere (a database, cloud storage, encrypted files, ...).
open class BetaAbstractMemoryTool: BetaBuiltinFunctionTool, @unchecked Sendable {
    public let cacheControl: BetaCacheControlEphemeralParam?

    public init(cacheControl: BetaCacheControlEphemeralParam? = nil) {
        self.cacheControl = cacheControl
        super.init()
    }

    open override func toDict() throws -> JSONValue {
        var param: JSONValue = ["type": "memory_20250818", "name": "memory"]
        if let cacheControl { param["cache_control"] = try JSONValue.from(cacheControl) }
        return param
    }

    open override var name: String { "memory" }

    open override func call(_ input: JSONValue) async throws -> BetaFunctionToolResult? {
        try await execute(try input.decode(as: BetaMemoryTool20250818Command.self))
    }

    /// Dispatches a memory command to its handler.
    open func execute(_ command: BetaMemoryTool20250818Command) async throws -> BetaFunctionToolResult {
        switch command {
        case .view(let c): return try await view(c)
        case .create(let c): return try await create(c)
        case .strReplace(let c): return try await strReplace(c)
        case .insert(let c): return try await insert(c)
        case .delete(let c): return try await delete(c)
        case .rename(let c): return try await rename(c)
        case .unknown(let raw): throw ValueError("Unknown command: \(raw["command"]?.stringValue ?? "None")")
        }
    }

    /// View the contents of a memory path.
    open func view(_ command: BetaMemoryTool20250818ViewCommand) async throws -> BetaFunctionToolResult { throw unimplemented("view") }
    /// Create a new memory file with the given content.
    open func create(_ command: BetaMemoryTool20250818CreateCommand) async throws -> BetaFunctionToolResult { throw unimplemented("create") }
    /// Replace text in a memory file.
    open func strReplace(_ command: BetaMemoryTool20250818StrReplaceCommand) async throws -> BetaFunctionToolResult {
        throw unimplemented("str_replace")
    }
    /// Insert text at a specific line number in a memory file.
    open func insert(_ command: BetaMemoryTool20250818InsertCommand) async throws -> BetaFunctionToolResult { throw unimplemented("insert") }
    /// Delete a memory file or directory.
    open func delete(_ command: BetaMemoryTool20250818DeleteCommand) async throws -> BetaFunctionToolResult { throw unimplemented("delete") }
    /// Rename or move a memory file or directory.
    open func rename(_ command: BetaMemoryTool20250818RenameCommand) async throws -> BetaFunctionToolResult { throw unimplemented("rename") }
    /// Clear all memory data.
    open func clearAllMemory() async throws -> BetaFunctionToolResult { throw unimplemented("clear_all_memory") }

    private func unimplemented(_ method: String) -> Error {
        ArgumentTypeError("\(type(of: self)) must override \(method)")
    }
}

/// A file-based memory tool (`BetaAsyncLocalFilesystemMemoryTool`): `/memories/...` paths map under
/// `<basePath>/memories`. Files are created owner-only, written atomically, and no path can escape the root,
/// through `..` or a symlink.
open class BetaLocalFilesystemMemoryTool: BetaAbstractMemoryTool, @unchecked Sendable {
    public let basePath: String
    public let memoryRoot: String

    public init(basePath: String = "./memory", cacheControl: BetaCacheControlEphemeralParam? = nil) {
        self.basePath = basePath
        self.memoryRoot = (basePath as NSString).appendingPathComponent("memories")
        super.init(cacheControl: cacheControl)
    }

    /// Ensures the memory root exists, creating it (and its parents) owner-only.
    public func ensureMemoryRoot() throws {
        try FileOps.secureMkdir(FileOps.absolute(memoryRoot))
    }

    /// Validates a `/memories/...` path and returns its resolved filesystem path.
    func validatePath(_ path: String) throws -> String {
        guard path.hasPrefix("/memories") else { throw ToolError("Path must start with /memories, got: \(path)") }
        var relative = String(path.dropFirst("/memories".count))
        while relative.hasPrefix("/") { relative.removeFirst() }
        let fullPath = relative.isEmpty ? memoryRoot : (memoryRoot as NSString).appendingPathComponent(relative)
        let resolvedPath = FileOps.resolve(fullPath)
        let resolvedRoot = FileOps.resolve(memoryRoot)
        if resolvedPath != resolvedRoot && !resolvedPath.hasPrefix(resolvedRoot + "/") {
            throw ToolError("Path \(path) would escape /memories directory")
        }
        try validateNoSymlinkEscape(FileOps.absolute(fullPath), memoryRoot: FileOps.absolute(memoryRoot))
        return resolvedPath
    }

    private func readContent(_ fullPath: String, _ memoryPath: String) throws -> String {
        do {
            return try FileOps.readTextExact(fullPath)
        } catch let e as FileSystemError where e.isNotFound {
            throw ToolError("The file \(memoryPath) no longer exists (may have been deleted or renamed concurrently).")
        }
    }

    open override func view(_ command: BetaMemoryTool20250818ViewCommand) async throws -> BetaFunctionToolResult {
        try ensureMemoryRoot()
        let fullPath = try validatePath(command.path)
        guard FileOps.exists(fullPath) else {
            throw ToolError("The path \(command.path) does not exist. Please provide a valid path.")
        }
        if FileOps.isDirectory(fullPath) {
            var items: [(String, String)] = []
            func collect(_ dir: String, _ relative: String, _ depth: Int) {
                if depth > 2 { return }
                guard let names = try? FileOps.listDirectory(dir).sorted() else { return }
                for name in names where !name.hasPrefix(".") {
                    let itemRelative = relative.isEmpty ? name : "\(relative)/\(name)"
                    let item = (dir as NSString).appendingPathComponent(name)
                    guard let size = FileOps.size(item) else { continue }
                    if FileOps.isDirectory(item) {
                        items.append((formatFileSize(size), "\(itemRelative)/"))
                        if depth < 2 { collect(item, itemRelative, depth + 1) }
                    } else if FileOps.isFile(item) {
                        items.append((formatFileSize(size), itemRelative))
                    }
                }
            }
            collect(fullPath, "", 1)
            let header = "Here're the files and directories up to 2 levels deep in \(command.path), excluding hidden items:"
            var lines = ["\(formatFileSize(FileOps.size(fullPath) ?? 0))\t\(command.path)"]
            lines += items.map { "\($0.0)\t\(command.path)/\($0.1)" }
            return .string("\(header)\n" + lines.joined(separator: "\n"))
        }
        guard FileOps.isFile(fullPath) else { throw ToolError("Unsupported file type for \(command.path)") }
        let content = try readContent(fullPath, command.path)
        if content.utf8.lazy.filter({ $0 == 0x0A }).count + 1 > MEMORY_MAX_LINES {
            throw ToolError("File \(command.path) exceeds maximum line limit of 999,999 lines.")
        }
        let lines = CodePoints(content).split("\n")
        if lines.count > MEMORY_MAX_LINES {
            throw ToolError("File \(command.path) exceeds maximum line limit of 999,999 lines.")
        }
        var display = lines[...]
        var startNumber = 1
        if let range = command.viewRange, range.count == 2 {
            let startLine = max(1, range[0]) - 1
            let endLine = range[1] == -1 ? lines.count : range[1]
            display = pythonSlice(lines, startLine, endLine)
            startNumber = startLine + 1
        }
        let numbered = display.enumerated().map { "\(rjust(String($0.offset + startNumber), LINE_NUMBER_WIDTH))\t\($0.element)" }
        return .string("Here's the content of \(command.path) with line numbers:\n" + numbered.joined(separator: "\n"))
    }

    open override func create(_ command: BetaMemoryTool20250818CreateCommand) async throws -> BetaFunctionToolResult {
        try ensureMemoryRoot()
        let fullPath = try validatePath(command.path)
        try FileOps.secureMkdir(FileOps.parent(fullPath))
        do {
            try FileOps.createExclusive(fullPath, Data(command.fileText.utf8))
        } catch let e as FileSystemError where e.isExists {
            throw ToolError("File \(command.path) already exists")
        }
        return .string("File created successfully at: \(command.path)")
    }

    open override func strReplace(_ command: BetaMemoryTool20250818StrReplaceCommand) async throws -> BetaFunctionToolResult {
        try ensureMemoryRoot()
        let fullPath = try validatePath(command.path)
        guard FileOps.exists(fullPath) else {
            throw ToolError("The path \(command.path) does not exist. Please provide a valid path.")
        }
        guard FileOps.isFile(fullPath) else { throw ToolError("The path \(command.path) is not a file.") }
        let content = CodePoints(try readContent(fullPath, command.path))
        let old = CodePoints(command.oldStr)
        let count = content.occurrences(old)
        if count == 0 {
            throw ToolError(
                "No replacement was performed, old_str `\(command.oldStr)` did not appear verbatim in \(command.path).")
        } else if count > 1 {
            var matchingLines: [Int] = []
            var start = 0
            while let pos = content.find(old, from: start) {
                matchingLines.append(content.countScalar("\n", upTo: pos) + 1)
                start = pos + 1
            }
            throw ToolError(
                "No replacement was performed. Multiple occurrences of old_str `\(command.oldStr)` in lines: "
                    + "\(matchingLines.map(String.init).joined(separator: ", ")). Please ensure it is unique")
        }
        let pos = content.find(old) ?? 0
        let changedLineIndex = content.countScalar("\n", upTo: pos)
        let newContent = content.replacing(old, with: CodePoints(command.newStr))
        try FileOps.atomicWrite(fullPath, Data(newContent.string.utf8))
        let newLines = newContent.split("\n")
        let contextStart = max(0, changedLineIndex - 2)
        let contextEnd = min(newLines.count, changedLineIndex + 3)
        let snippet = (contextStart + 1..<contextEnd + 1).map { "\(rjust(String($0), LINE_NUMBER_WIDTH))\t\(newLines[$0 - 1])" }
        return .string("The memory file has been edited. Here is the snippet showing the change (with line numbers):\n"
            + snippet.joined(separator: "\n"))
    }

    open override func insert(_ command: BetaMemoryTool20250818InsertCommand) async throws -> BetaFunctionToolResult {
        try ensureMemoryRoot()
        let fullPath = try validatePath(command.path)
        guard FileOps.exists(fullPath) else {
            throw ToolError("The path \(command.path) does not exist. Please provide a valid path.")
        }
        guard FileOps.isFile(fullPath) else { throw ToolError("The path \(command.path) is not a file.") }
        let content = try readContent(fullPath, command.path)
        var lines = splitLinesKeepingCR(content)
        if command.insertLine < 0 || command.insertLine > lines.count {
            throw ToolError(
                "Invalid `insert_line` parameter: \(command.insertLine). It should be within the range [0, \(lines.count)].")
        }
        var text = CodePoints(command.insertText)
        while text.hasSuffix("\n") { text.scalars.removeLast() }
        lines.insert(text.string, at: command.insertLine)
        var newContent = lines.joined(separator: "\n")
        if !CodePoints(newContent).hasSuffix("\n") { newContent += "\n" }
        try FileOps.atomicWrite(fullPath, Data(newContent.utf8))
        return .string("The file \(command.path) has been edited.")
    }

    open override func delete(_ command: BetaMemoryTool20250818DeleteCommand) async throws -> BetaFunctionToolResult {
        try ensureMemoryRoot()
        let fullPath = try validatePath(command.path)
        if command.path == "/memories" { throw ToolError("Cannot delete the /memories directory itself") }
        do {
            if FileOps.isFile(fullPath) {
                try FileOps.unlinkFile(fullPath)
            } else if FileOps.isDirectory(fullPath) {
                try FileOps.removeTree(fullPath)
            } else {
                throw ToolError("The path \(command.path) does not exist")
            }
        } catch let e as FileSystemError where e.isNotFound {
            throw ToolError("The path \(command.path) does not exist")
        }
        return .string("Successfully deleted \(command.path)")
    }

    open override func rename(_ command: BetaMemoryTool20250818RenameCommand) async throws -> BetaFunctionToolResult {
        try ensureMemoryRoot()
        let oldPath = try validatePath(command.oldPath)
        let newPath = try validatePath(command.newPath)
        if FileOps.exists(newPath) { throw ToolError("The destination \(command.newPath) already exists") }
        try FileOps.secureMkdir(FileOps.parent(newPath))
        do {
            try FileOps.renamePath(oldPath, newPath)
        } catch let e as FileSystemError where e.isNotFound {
            throw ToolError("The path \(command.oldPath) does not exist")
        }
        return .string("Successfully renamed \(command.oldPath) to \(command.newPath)")
    }

    open override func clearAllMemory() async throws -> BetaFunctionToolResult {
        if FileOps.exists(memoryRoot) { try FileOps.removeTree(memoryRoot) }
        try ensureMemoryRoot()
        return .string("All memory cleared")
    }
}

/// Rejects a path whose nearest existing ancestor resolves outside the memory root (`_validate_no_symlink_escape`).
func validateNoSymlinkEscape(_ targetPath: String, memoryRoot: String) throws {
    let resolvedRoot = FileOps.resolve(memoryRoot)
    // Non-strict resolution follows every symlink that exists along the path.
    let resolved = FileOps.resolve(targetPath)
    if resolved != resolvedRoot && !resolved.hasPrefix(resolvedRoot + "/") {
        throw ToolError("Path would escape /memories directory via symlink")
    }
}

/// Split on LF only (keeping any CR), without the empty tail a trailing newline leaves.
func splitLinesKeepingCR(_ content: String) -> [String] {
    var lines = CodePoints(content).split("\n")
    if lines.last == "" { lines.removeLast() }
    return lines
}

/// `lines[start:end]` with Python's slice clamping.
func pythonSlice<T>(_ items: [T], _ start: Int, _ end: Int) -> ArraySlice<T> {
    func clamp(_ i: Int) -> Int { i < 0 ? max(0, items.count + i) : min(i, items.count) }
    let s = clamp(start), e = clamp(end)
    return s < e ? items[s..<e] : []
}

/// A byte count as `12B`, `1.5K`, ... (`_format_file_size`).
func formatFileSize(_ bytes: Int) -> String {
    if bytes == 0 { return "0B" }
    let sizes = ["B", "K", "M", "G"]
    let bitLength = Int.bitWidth - bytes.leadingZeroBitCount
    let i = min((bitLength - 1) / 10, sizes.count - 1)
    let size = Double(bytes) / pow(1024, Double(i))
    if size == size.rounded(.towardZero) { return "\(Int(size))\(sizes[i])" }
    return String(format: "%.1f", size) + sizes[i]
}
