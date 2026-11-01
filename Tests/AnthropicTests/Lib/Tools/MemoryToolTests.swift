// Port of tests/lib/tools/memory_tools/test_filesystem.py (`TestBetaAsyncLocalFilesystemMemoryTool`).

import Foundation
import Testing
@testable import Anthropic

#if canImport(Glibc)
    import Glibc
#elseif canImport(Darwin)
    import Darwin
#endif

/// A fresh temporary directory, removed when the value is released.
final class ToolsTempDir: @unchecked Sendable {
    let path: String
    init() {
        path = FileManager.default.temporaryDirectory.appendingPathComponent("slaude-\(UUID().uuidString)").path
        try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
    }
    deinit { try? FileManager.default.removeItem(atPath: path) }

    func join(_ components: String...) -> String {
        components.reduce(path) { ($0 as NSString).appendingPathComponent($1) }
    }
}

/// A snapshot of directory contents with relative paths (`get_directory_snapshot`).
func directorySnapshot(_ base: String) -> [String: String] {
    var out: [String: String] = [:]
    guard let enumerator = FileManager.default.enumerator(atPath: base) else { return out }
    while let rel = enumerator.nextObject() as? String {
        let full = (base as NSString).appendingPathComponent(rel)
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: full, isDirectory: &isDir), !isDir.boolValue {
            out[rel] = (try? String(contentsOfFile: full, encoding: .utf8)) ?? ""
        }
    }
    return out
}

func expectToolError(_ pattern: String, sourceLocation: SourceLocation = #_sourceLocation, _ body: () async throws -> Void) async {
    do {
        try await body()
        Issue.record("expected ToolError matching \(pattern)", sourceLocation: sourceLocation)
    } catch let e as ToolError {
        #expect(e.message.range(of: pattern, options: .regularExpression) != nil, "\(e.message) !~ \(pattern)",
                sourceLocation: sourceLocation)
    } catch {
        Issue.record("expected ToolError, got \(error)", sourceLocation: sourceLocation)
    }
}

private func text(_ result: BetaFunctionToolResult) -> String {
    if case .string(let s) = result { return s }
    return "\(result)"
}

@Suite struct LocalFilesystemMemoryToolTests {
    let dir = ToolsTempDir()
    var tool: BetaLocalFilesystemMemoryTool { BetaLocalFilesystemMemoryTool(basePath: dir.path) }

    private func create(_ tool: BetaLocalFilesystemMemoryTool, _ path: String, _ text: String) async throws {
        _ = try await tool.create(BetaMemoryTool20250818CreateCommand(fileText: text, path: path))
    }

    private func writeRaw(_ name: String, _ bytes: [UInt8]) throws -> String {
        try FileManager.default.createDirectory(atPath: tool.memoryRoot, withIntermediateDirectories: true)
        let path = (tool.memoryRoot as NSString).appendingPathComponent(name)
        try Data(bytes).write(to: URL(fileURLWithPath: path))
        return path
    }

    @Test func mkdirParentsNotWorldWritableUnderPermissiveUmask() async throws {
        let old = umask(0)
        defer { umask(old) }
        let base = dir.join("nested", "memory")
        let tool = BetaLocalFilesystemMemoryTool(basePath: base)
        try tool.ensureMemoryRoot()
        for directory in [dir.join("nested"), base, tool.memoryRoot] {
            let mode = try #require(FileOps.mode(directory))
            #expect(mode == 0o700, "\(directory) has mode \(String(mode, radix: 8)), expected 0700")
        }
    }

    @Test func createdFilesAreOwnerOnly() async throws {
        let tool = self.tool
        try await create(tool, "/memories/secret.txt", "x")
        #expect(FileOps.mode((tool.memoryRoot as NSString).appendingPathComponent("secret.txt")) == 0o600)
    }

    @Test func createFile() async throws {
        let result = try await tool.create(BetaMemoryTool20250818CreateCommand(fileText: "Hello, World!", path: "/memories/test_file.txt"))
        #expect(text(result) == "File created successfully at: /memories/test_file.txt")
        #expect(directorySnapshot(dir.path) == ["memories/test_file.txt": "Hello, World!"])
    }

    @Test func createNestedDirectories() async throws {
        let result = try await tool.create(BetaMemoryTool20250818CreateCommand(fileText: "Nested file", path: "/memories/deep/nested/file.txt"))
        #expect(text(result) == "File created successfully at: /memories/deep/nested/file.txt")
        #expect(directorySnapshot(dir.path) == ["memories/deep/nested/file.txt": "Nested file"])
    }

    @Test func createErrorIfFileAlreadyExists() async throws {
        let tool = self.tool
        try await create(tool, "/memories/existing.txt", "Original")
        await expectToolError("File /memories/existing.txt already exists") { try await create(tool, "/memories/existing.txt", "New") }
    }

    @Test func viewFile() async throws {
        let tool = self.tool
        try await create(tool, "/memories/view_test.txt", "Line 1\nLine 2\nLine 3")
        let result = try await tool.view(BetaMemoryTool20250818ViewCommand(path: "/memories/view_test.txt"))
        #expect(text(result) == "Here's the content of /memories/view_test.txt with line numbers:\n     1\tLine 1\n     2\tLine 2\n     3\tLine 3")
    }

    @Test func viewDirectory() async throws {
        let tool = self.tool
        try await create(tool, "/memories/dir/file1.txt", "File 1")
        try await create(tool, "/memories/dir/file2.txt", "File 2")
        let result = text(try await tool.view(BetaMemoryTool20250818ViewCommand(path: "/memories/dir")))
        #expect(result.contains("Here're the files and directories up to 2 levels deep in /memories/dir"))
        #expect(result.contains("/memories/dir"))
        #expect(result.contains("6B\t/memories/dir/file1.txt"))
        #expect(result.contains("/memories/dir/file2.txt"))
    }

    @Test func viewFileWithRange() async throws {
        let tool = self.tool
        try await create(tool, "/memories/range_test.txt", "Line 1\nLine 2\nLine 3\nLine 4\nLine 5")
        let result = try await tool.view(BetaMemoryTool20250818ViewCommand(path: "/memories/range_test.txt", viewRange: [2, 4]))
        #expect(text(result) == "Here's the content of /memories/range_test.txt with line numbers:\n     2\tLine 2\n     3\tLine 3\n     4\tLine 4")
    }

    @Test func viewErrorForNonExistentFile() async throws {
        let tool = self.tool
        await expectToolError("The path /memories/nonexistent.txt does not exist. Please provide a valid path.") {
            _ = try await tool.view(BetaMemoryTool20250818ViewCommand(path: "/memories/nonexistent.txt"))
        }
    }

    @Test func viewErrorForFilesWithTooManyLines() async throws {
        let tool = self.tool
        try await create(tool, "/memories/huge.txt", Array(repeating: "line", count: 1_000_000).joined(separator: "\n"))
        await expectToolError("exceeds maximum line limit of 999,999 lines") {
            _ = try await tool.view(BetaMemoryTool20250818ViewCommand(path: "/memories/huge.txt"))
        }
    }

    @Test func strReplace() async throws {
        let tool = self.tool
        try await create(tool, "/memories/replace_test.txt", "Line 1\nOld Text\nLine 3")
        let result = try await tool.strReplace(BetaMemoryTool20250818StrReplaceCommand(newStr: "New Text", oldStr: "Old Text", path: "/memories/replace_test.txt"))
        #expect(text(result) == "The memory file has been edited. Here is the snippet showing the change (with line numbers):\n     1\tLine 1\n     2\tNew Text\n     3\tLine 3")
        #expect(directorySnapshot(dir.path) == ["memories/replace_test.txt": "Line 1\nNew Text\nLine 3"])
    }

    @Test func strReplaceErrorWhenStringNotFound() async throws {
        let tool = self.tool
        try await create(tool, "/memories/replace_test.txt", "Hello World")
        await expectToolError("No replacement was performed, old_str `Nonexistent` did not appear verbatim in /memories/replace_test.txt") {
            _ = try await tool.strReplace(BetaMemoryTool20250818StrReplaceCommand(newStr: "New", oldStr: "Nonexistent", path: "/memories/replace_test.txt"))
        }
    }

    @Test func strReplaceErrorWhenStringAppearsMultipleTimes() async throws {
        let tool = self.tool
        try await create(tool, "/memories/replace_test.txt", "Hello\nMiddle\nHello")
        await expectToolError(#"No replacement was performed\. Multiple occurrences of old_str `Hello` in lines: 1, 3\. Please ensure it is unique"#) {
            _ = try await tool.strReplace(BetaMemoryTool20250818StrReplaceCommand(newStr: "Hi", oldStr: "Hello", path: "/memories/replace_test.txt"))
        }
    }

    @Test func strReplaceErrorForNonExistentFile() async throws {
        let tool = self.tool
        await expectToolError("The path /memories/nonexistent.txt does not exist. Please provide a valid path.") {
            _ = try await tool.strReplace(BetaMemoryTool20250818StrReplaceCommand(newStr: "new", oldStr: "old", path: "/memories/nonexistent.txt"))
        }
    }

    @Test(arguments: [(1, "Inserted Line", "Line 1\nInserted Line\nLine 2\n"), (0, "First Line", "First Line\nLine 1\nLine 2\n"),
                      (2, "Last Line", "Line 1\nLine 2\nLast Line\n")])
    func insert(line: Int, inserted: String, expected: String) async throws {
        // `test_insert`, `test_insert_at_beginning_of_file`, `test_insert_at_end_of_file`.
        let tool = self.tool
        try await create(tool, "/memories/insert_test.txt", "Line 1\nLine 2")
        let result = try await tool.insert(BetaMemoryTool20250818InsertCommand(insertLine: line, insertText: inserted, path: "/memories/insert_test.txt"))
        #expect(text(result) == "The file /memories/insert_test.txt has been edited.")
        #expect(directorySnapshot(dir.path) == ["memories/insert_test.txt": expected])
    }

    @Test func viewPreservesCRLFLineEndings() async throws {
        _ = try writeRaw("crlf.txt", Array("line1\r\nline2\r\nline3\r\n".utf8))
        let result = try await tool.view(BetaMemoryTool20250818ViewCommand(path: "/memories/crlf.txt"))
        #expect(text(result) == "Here's the content of /memories/crlf.txt with line numbers:\n     1\tline1\r\n     2\tline2\r\n     3\tline3\r\n     4\t")
    }

    @Test func strReplacePreservesCRLFLineEndings() async throws {
        let path = try writeRaw("crlf.txt", Array("line1\r\nline2\r\nline3\r\n".utf8))
        _ = try await tool.strReplace(BetaMemoryTool20250818StrReplaceCommand(newStr: "LINE2", oldStr: "line2", path: "/memories/crlf.txt"))
        #expect(try Data(contentsOf: URL(fileURLWithPath: path)) == Data("line1\r\nLINE2\r\nline3\r\n".utf8))
    }

    @Test func insertPreservesCRLFLineEndings() async throws {
        let path = try writeRaw("crlf.txt", Array("line1\r\nline2\r\nline3\r\n".utf8))
        _ = try await tool.insert(BetaMemoryTool20250818InsertCommand(insertLine: 1, insertText: "Inserted", path: "/memories/crlf.txt"))
        #expect(try Data(contentsOf: URL(fileURLWithPath: path)) == Data("line1\r\nInserted\nline2\r\nline3\r\n".utf8))
    }

    @Test func insertErrorForNonExistentFile() async throws {
        let tool = self.tool
        await expectToolError("The path /memories/nonexistent.txt does not exist. Please provide a valid path.") {
            _ = try await tool.insert(BetaMemoryTool20250818InsertCommand(insertLine: 0, insertText: "text", path: "/memories/nonexistent.txt"))
        }
    }

    @Test func insertErrorForInvalidInsertLine() async throws {
        let tool = self.tool
        try await create(tool, "/memories/insert_test.txt", "Line 1\nLine 2")
        await expectToolError(#"Invalid `insert_line` parameter: 10\. It should be within the range \[0, 2\]"#) {
            _ = try await tool.insert(BetaMemoryTool20250818InsertCommand(insertLine: 10, insertText: "text", path: "/memories/insert_test.txt"))
        }
    }

    @Test func deleteFile() async throws {
        let tool = self.tool
        try await create(tool, "/memories/delete_me.txt", "To be deleted")
        let result = try await tool.delete(BetaMemoryTool20250818DeleteCommand(path: "/memories/delete_me.txt"))
        #expect(text(result) == "Successfully deleted /memories/delete_me.txt")
        #expect(directorySnapshot(dir.path) == [:])
    }

    @Test func deleteDirectory() async throws {
        let tool = self.tool
        try await create(tool, "/memories/subdir/file.txt", "Content")
        let result = try await tool.delete(BetaMemoryTool20250818DeleteCommand(path: "/memories/subdir"))
        #expect(text(result) == "Successfully deleted /memories/subdir")
        #expect(directorySnapshot(dir.path) == [:])
    }

    @Test func deleteErrorWhenFileNotFound() async throws {
        let tool = self.tool
        await expectToolError("The path /memories/nonexistent.txt does not exist") {
            _ = try await tool.delete(BetaMemoryTool20250818DeleteCommand(path: "/memories/nonexistent.txt"))
        }
    }

    @Test func deleteNotAllowDeletingMemoriesDirectory() async throws {
        let tool = self.tool
        await expectToolError("Cannot delete the /memories directory itself") {
            _ = try await tool.delete(BetaMemoryTool20250818DeleteCommand(path: "/memories"))
        }
    }

    @Test func renameFile() async throws {
        let tool = self.tool
        try await create(tool, "/memories/old_name.txt", "Original content")
        let result = try await tool.rename(BetaMemoryTool20250818RenameCommand(newPath: "/memories/new_name.txt", oldPath: "/memories/old_name.txt"))
        #expect(text(result) == "Successfully renamed /memories/old_name.txt to /memories/new_name.txt")
        #expect(directorySnapshot(dir.path) == ["memories/new_name.txt": "Original content"])
    }

    @Test func renameToNestedPath() async throws {
        let tool = self.tool
        try await create(tool, "/memories/file.txt", "Content")
        let result = try await tool.rename(BetaMemoryTool20250818RenameCommand(newPath: "/memories/nested/dir/file.txt", oldPath: "/memories/file.txt"))
        #expect(text(result) == "Successfully renamed /memories/file.txt to /memories/nested/dir/file.txt")
        #expect(directorySnapshot(dir.path) == ["memories/nested/dir/file.txt": "Content"])
    }

    @Test func renameErrorWhenSourceNotFound() async throws {
        let tool = self.tool
        await expectToolError("The path /memories/nonexistent.txt does not exist") {
            _ = try await tool.rename(BetaMemoryTool20250818RenameCommand(newPath: "/memories/new.txt", oldPath: "/memories/nonexistent.txt"))
        }
    }

    @Test func renameErrorWhenDestinationExists() async throws {
        let tool = self.tool
        try await create(tool, "/memories/file1.txt", "File 1")
        try await create(tool, "/memories/file2.txt", "File 2")
        await expectToolError("The destination /memories/file2.txt already exists") {
            _ = try await tool.rename(BetaMemoryTool20250818RenameCommand(newPath: "/memories/file2.txt", oldPath: "/memories/file1.txt"))
        }
    }

    @Test func pathValidationRejectPathsNotStartingWithMemories() async throws {
        let tool = self.tool
        await expectToolError("Path must start with /memories") { try await create(tool, "/invalid/path.txt", "Invalid") }
    }

    @Test func pathValidationRejectPathsTryingToEscapeMemories() async throws {
        let tool = self.tool
        await expectToolError(#"Path /memories/\.\./\.\./\.\./etc/passwd would escape /memories directory"#) {
            try await create(tool, "/memories/../../../etc/passwd", "Escape attempt")
        }
    }

    @Test func validatePathReturnsResolvedPathNotSymlinkTarget() async throws {
        let tool = self.tool
        let legit = (tool.memoryRoot as NSString).appendingPathComponent("legit")
        try FileManager.default.createDirectory(atPath: legit, withIntermediateDirectories: true)
        try "content".write(toFile: (legit as NSString).appendingPathComponent("file.txt"), atomically: false, encoding: .utf8)
        try FileManager.default.createSymbolicLink(atPath: (tool.memoryRoot as NSString).appendingPathComponent("link"), withDestinationPath: legit)
        let result = try tool.validatePath("/memories/link/file.txt")
        #expect(!result.contains("link"), "validatePath returned unresolved symlink path: \(result)")
        #expect(result.contains(FileOps.resolve(legit)))
    }

    @Test(arguments: ["view", "create", "nested"])
    func symlinkValidationRejectsSymlinksPointingOutsideMemories(kind: String) async throws {
        // `test_symlink_validation_reject_symlink_pointing_outside_memories`,
        // `..._reject_creating_files_through_symlink_pointing_outside`,
        // `..._reject_parent_directory_that_is_symlink_pointing_outside`.
        let outside = ToolsTempDir()
        try "sensitive data".write(toFile: outside.join("secret.txt"), atomically: false, encoding: .utf8)
        let tool = self.tool
        try FileManager.default.createDirectory(atPath: tool.memoryRoot, withIntermediateDirectories: true)
        try FileManager.default.createSymbolicLink(atPath: (tool.memoryRoot as NSString).appendingPathComponent("link"), withDestinationPath: outside.path)
        await expectToolError("Path .* would escape /memories directory") {
            switch kind {
            case "view": _ = try await tool.view(BetaMemoryTool20250818ViewCommand(path: "/memories/link/secret.txt"))
            case "create": try await create(tool, "/memories/link/hacked.txt", "malicious content")
            default: try await create(tool, "/memories/link/nested/file.txt", "content")
            }
        }
        #expect(!FileManager.default.fileExists(atPath: outside.join("hacked.txt")))
    }

    @Test func runsThroughTheToolRunnerInterface() async throws {
        let tool = self.tool
        #expect(try tool.toToolParam() == ["type": "memory_20250818", "name": "memory"])
        #expect(tool.name == "memory")
        let result = try await tool.call(["command": "create", "path": "/memories/a.txt", "file_text": "hi"])
        #expect(result == "File created successfully at: /memories/a.txt")
        #expect(try await tool.clearAllMemory() == "All memory cleared")
        #expect(directorySnapshot(dir.path) == [:])
    }
}
