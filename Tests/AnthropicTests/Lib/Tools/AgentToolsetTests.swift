// Port of `tests/lib/tools/test_agent_toolset.py`: the `agent_toolset_20260401` tools and `AgentToolContext`.

import Foundation
import Testing
@testable import Anthropic

/// Calls a tool with a JSON input and returns its result as JSON.
private func run(_ tool: BetaFunctionTool, _ input: JSONValue) async throws -> JSONValue {
    guard let result = try await tool.call(input) else { return .null }
    return try JSONValue.from(result)
}

/// The text of the `ToolError` a tool call throws.
private func refusal(_ tool: BetaFunctionTool, _ input: JSONValue) async -> String {
    do {
        let result = try await run(tool, input)
        Issue.record("expected a ToolError, got \(result)")
        return ""
    } catch let error as ToolError {
        return error.message
    } catch {
        Issue.record("expected a ToolError, got \(error)")
        return ""
    }
}

/// The `ValueError` text `resolvePath` throws, or `nil`.
private func resolveError(_ ctx: AgentToolContext, _ p: String) -> String? {
    do {
        _ = try resolvePath(ctx, p)
        return nil
    } catch let error as ValueError {
        return error.message
    } catch {
        return "\(error)"
    }
}

private func bytes(_ path: String) -> [UInt8] { (try? [UInt8](Data(contentsOf: URL(fileURLWithPath: path)))) ?? [] }

private func writeBytes(_ path: String, _ data: [UInt8]) throws {
    try Data(data).write(to: URL(fileURLWithPath: path))
}

private func writeBytes(_ path: String, _ text: String) throws { try writeBytes(path, Array(text.utf8)) }

/// Workdir with two symlink cycles, a link that escapes, and a link whose target spells its way through a cycle to
/// the escaping link (`_symlink_fixture`).
private func symlinkFixture(_ tmp: ToolsetTempDir) throws -> String {
    _ = try tmp.write("SECRET", "outside", "secret.txt")
    let work = try tmp.mkdir("work")
    try tmp.symlink(work + "/loop_a", to: "loop_b")
    try tmp.symlink(work + "/loop_b", to: "loop_a")
    try tmp.symlink(work + "/self", to: "self")
    try tmp.symlink(work + "/evil_link", to: tmp.path("outside", "secret.txt"))
    try tmp.symlink(work + "/L", to: "loop_a/../evil_link")
    return work
}

@Suite struct AgentToolsetPathTests {
    @Test(arguments: [("a/b.txt", false), ("a/../b.txt", false), ("../etc/passwd", true), ("/etc/passwd", true)])
    func resolvePathCases(_ p: String, _ expectError: Bool) throws {
        let tmp = try ToolsetTempDir()
        let ctx = try AgentToolContext(workdir: tmp.root)
        #expect((resolveError(ctx, p) != nil) == expectError)
    }

    @Test(arguments: [true, false])
    func unrestrictedPathsIsRejectedWithGuidance(_ value: Bool) throws {
        let tmp = try ToolsetTempDir()
        do {
            _ = try AgentToolContext(workdir: tmp.root, unrestrictedPaths: value)
            Issue.record("expected a TypeError")
        } catch let error as ArgumentTypeError {
            #expect(error.message.hasPrefix("unrestricted_paths is no longer supported") && error.message.contains("allowed_roots"))
        }
    }

    @Test func resolvePathAbsoluteInsideWorkdir() throws {
        let tmp = try ToolsetTempDir()
        let ctx = try AgentToolContext(workdir: tmp.root)
        _ = try tmp.write("x", "a.txt")
        #expect(try resolvePath(ctx, tmp.path("a.txt")) == tmp.path("a.txt"))
        #expect(try resolvePath(ctx, tmp.root) == tmp.root)
        let sub = try tmp.mkdir("sub")
        #expect(try resolvePath(ctx, sub + "/b.txt") == sub + "/b.txt")
        // Still rejected: absolute outside, and absolute-that-symlinks-outside.
        #expect(resolveError(ctx, "/etc/passwd")?.contains("outside the session's working directory") == true)
        try tmp.symlink(tmp.path("out"), to: "/etc/passwd")
        #expect(resolveError(ctx, tmp.path("out"))?.contains("outside the session's working directory") == true)
    }

    @Test(arguments: ["loop_a", "loop_a/child.txt", "self", "self/x"])
    func resolvePathRejectsSymlinkLoop(_ p: String) throws {
        let tmp = try ToolsetTempDir()
        let ctx = try AgentToolContext(workdir: try symlinkFixture(tmp))
        let started = Date()
        let error = resolveError(ctx, p)
        #expect(error == "path \(pythonStringRepr(p)): too many levels of symbolic links")
        #expect(Date().timeIntervalSince(started) < 2)
        #expect(error?.contains(tmp.root) == false)
    }

    @Test func resolvePathDotdotIsLexicalBeforeSymlinks() throws {
        let tmp = try ToolsetTempDir()
        let work = try symlinkFixture(tmp)
        let ctx = try AgentToolContext(workdir: work)
        for p in ["loop_a/../evil_link", "self/../evil_link"] {
            #expect(resolveError(ctx, p)?.contains("outside the session's working directory") == true)
        }
        let viaL = resolveError(ctx, "L") ?? ""
        #expect(viaL.contains("too many levels of symbolic links") || viaL.contains("outside the session's working directory"))
        _ = try tmp.write("ok", "work", "ok.txt")
        #expect(try resolvePath(ctx, "loop_a/../ok.txt") == work + "/ok.txt")
    }

    @Test func resolvePathRejectsSymlinkEscapeLiveAndDangling() throws {
        let tmp = try ToolsetTempDir()
        let work = try symlinkFixture(tmp)
        try tmp.symlink(work + "/dangle_out", to: tmp.path("outside", "nope"))
        let ctx = try AgentToolContext(workdir: work)
        for p in ["evil_link", "dangle_out"] {
            #expect(resolveError(ctx, p)?.contains("outside the session's working directory") == true)
        }
    }

    @Test func resolvePathAllowedRoots() throws {
        let tmp = try ToolsetTempDir()
        let work = try tmp.mkdir("work")
        let mount = try tmp.mkdir("mount")
        let ctx = try AgentToolContext(workdir: work, allowedRoots: [mount])
        #expect(try resolvePath(ctx, mount + "/note.md") == mount + "/note.md")
        #expect(try resolvePath(ctx, "inside.txt") == work + "/inside.txt")
        let both = "outside the session's working directory and its other permitted directories"
        #expect(resolveError(ctx, tmp.path("elsewhere", "x"))?.contains(both) == true)
        #expect(resolveError(ctx, "../elsewhere/x")?.contains(both) == true)
    }

    @Test func resolvePathSymlinkOutOfAllowedRootIsRejected() throws {
        let tmp = try ToolsetTempDir()
        let work = try tmp.mkdir("work")
        let mount = try tmp.mkdir("mount")
        try tmp.symlink(mount + "/leak", to: "/etc/passwd")
        let ctx = try AgentToolContext(workdir: work, allowedRoots: [mount])
        #expect(resolveError(ctx, mount + "/leak")?.contains("outside the session's working directory and its other permitted directories") == true)
    }

    @Test func resolvePathSegmentAwareSibling() throws {
        let tmp = try ToolsetTempDir()
        let ctx = try AgentToolContext(workdir: try tmp.mkdir("work"))
        #expect(resolveError(ctx, "../work2/file") != nil)
    }

    @Test func aSymlinkedReadOnlyRootStillRefusesWrites() throws {
        let tmp = try ToolsetTempDir()
        let work = try tmp.mkdir("work")
        let real = try tmp.mkdir("real-store")
        let link = tmp.path("link-store")
        try tmp.symlink(link, to: real)
        let ctx = try AgentToolContext(workdir: work, allowedRoots: [link], readOnlyRoots: [link])
        let target = try resolvePath(ctx, link + "/note.md")
        #expect(target == real + "/note.md")
        #expect(throws: ToolError.self) { try rejectReadOnly(ctx, target, op: "write", filePath: link + "/note.md") }
    }
}

@Suite struct AgentToolsetFileToolTests {
    @Test func agentToolsetNamesAndFilter() throws {
        let tmp = try ToolsetTempDir()
        let ctx = try AgentToolContext(workdir: tmp.root)
        #expect(betaAgentToolset20260401(ctx).map(\.name) == ["bash", "read", "write", "edit", "glob", "grep"])
        // a plain list that callers can filter or extend
        let subset = betaAgentToolset20260401(ctx).filter { !["bash", "grep"].contains($0.name) }
        #expect(subset.map(\.name) == ["read", "write", "edit", "glob"])
        #expect((subset + [betaReadTool(ctx)]).last?.name == "read")
    }

    @Test func readWriteEditRoundtrip() async throws {
        let tmp = try ToolsetTempDir()
        let ctx = try AgentToolContext(workdir: tmp.root)
        let message = try await run(betaWriteTool(ctx), ["file_path": "f.txt", "content": "hello world"])
        #expect(message.stringValue?.contains("wrote") == true)
        #expect(try await run(betaReadTool(ctx), ["file_path": "f.txt"]) == "hello world")
        _ = try await run(betaEditTool(ctx), ["file_path": "f.txt", "old_string": "world", "new_string": "there"])
        #expect(try String(contentsOfFile: tmp.path("f.txt"), encoding: .utf8) == "hello there")
    }

    @Test func readViewRange() async throws {
        let tmp = try ToolsetTempDir()
        try writeBytes(tmp.path("f.txt"), "a\nb\nc\nd\n")
        #expect(try await run(betaReadTool(try AgentToolContext(workdir: tmp.root)), ["file_path": "f.txt", "view_range": [2, 3]]) == "b\nc")
    }

    @Test(arguments: [([2, 2], "line2"), ([2, 0], "line2\nline3"), ([10, 12], ""), ([3, 1], ""), ([], "line1\nline2\nline3")] as [([Int], String)])
    func readViewRangeEdges(_ viewRange: [Int], _ want: String) async throws {
        let tmp = try ToolsetTempDir()
        try writeBytes(tmp.path("a.txt"), "line1\nline2\nline3")
        let range = JSONValue.array(viewRange.map { .int($0) })
        #expect(try await run(betaReadTool(try AgentToolContext(workdir: tmp.root)), ["file_path": "a.txt", "view_range": range]) == .string(want))
    }

    @Test func readViewRangeWrongArityIsRejected() async throws {
        let tmp = try ToolsetTempDir()
        try writeBytes(tmp.path("a.txt"), "line1\nline2\nline3")
        try writeBytes(tmp.path("big.txt"), [UInt8](repeating: 0x61, count: 257 * 1024))
        let read = betaReadTool(try AgentToolContext(workdir: tmp.root))
        #expect(await refusal(read, ["file_path": "a.txt", "view_range": [2]]) == "read: view_range must be [start_line, end_line]")
        #expect(await refusal(read, ["file_path": "big.txt", "view_range": [2]]) == "read: view_range must be [start_line, end_line]")
    }

    @Test func readPreservesLineEndings() async throws {
        // test_read_preserves_crlf_line_endings and test_read_preserves_lone_cr
        let tmp = try ToolsetTempDir()
        try writeBytes(tmp.path("crlf.txt"), "line1\r\nline2\r\nline3\r\n")
        try writeBytes(tmp.path("cr.txt"), "a\rb\rc\r")
        let read = betaReadTool(try AgentToolContext(workdir: tmp.root))
        #expect(try await run(read, ["file_path": "crlf.txt"]) == "line1\r\nline2\r\nline3\r\n")
        #expect(try await run(read, ["file_path": "crlf.txt", "view_range": [1, 2]]) == "line1\r\nline2\r")
        #expect(try await run(read, ["file_path": "cr.txt"]) == "a\rb\rc\r")
        #expect(try await run(read, ["file_path": "cr.txt", "view_range": [1, 1]]) == "a\rb\rc\r")
        #expect(try await run(read, ["file_path": "cr.txt", "view_range": [2, 2]]) == "")
    }

    @Test func editAndWritePreserveBytes() async throws {
        // test_edit_preserves_crlf_line_endings and test_write_preserves_content_bytes
        let tmp = try ToolsetTempDir()
        let ctx = try AgentToolContext(workdir: tmp.root)
        try writeBytes(tmp.path("crlf.txt"), "line1\r\nline2\r\nline3\r\n")
        _ = try await run(betaEditTool(ctx), ["file_path": "crlf.txt", "old_string": "line2", "new_string": "LINE2"])
        #expect(bytes(tmp.path("crlf.txt")) == Array("line1\r\nLINE2\r\nline3\r\n".utf8))
        _ = try await run(betaWriteTool(ctx), ["file_path": "w.txt", "content": "a\r\nb\nc\r"])
        #expect(bytes(tmp.path("w.txt")) == Array("a\r\nb\nc\r".utf8))
    }

    @Test func readRejectsOversizedFile() async throws {
        let tmp = try ToolsetTempDir()
        try writeBytes(tmp.path("big.txt"), [UInt8](repeating: 0x61, count: 257 * 1024))
        let text = await refusal(betaReadTool(try AgentToolContext(workdir: tmp.root)), ["file_path": "big.txt"])
        #expect(text.contains("exceeds") && text.contains("view_range") && !text.contains("bash"))
    }

    @Test(arguments: [([2, 2], "line2"), ([2, 0], "line2\nline3\n"), ([10, 12], ""), ([3, 1], "")] as [([Int], String)])
    func readViewRangeStreamsFileOverCap(_ viewRange: [Int], _ want: String) async throws {
        let tmp = try ToolsetTempDir()
        try writeBytes(tmp.path("a.txt"), "line1\nline2\nline3\n")
        let read = betaReadTool(try AgentToolContext(workdir: tmp.root, maxFileBytes: 16))
        #expect(try await run(read, ["file_path": "a.txt", "view_range": .array(viewRange.map { .int($0) })]) == .string(want))
    }

    @Test func readViewRangeOverCapRejectsOversizedSliceAndLongLines() async throws {
        // test_read_view_range_over_cap_rejects_oversized_slice and ..._single_long_line
        let tmp = try ToolsetTempDir()
        try writeBytes(tmp.path("a.txt"), "line1\nline2\nline3\n")
        try writeBytes(tmp.path("long.txt"), String(repeating: "x", count: 100) + "\nok\n")
        let read = betaReadTool(try AgentToolContext(workdir: tmp.root, maxFileBytes: 16))
        let slice = await refusal(read, ["file_path": "a.txt", "view_range": [1, 3]])
        #expect(slice.contains("exceeds") && slice.contains("Narrow the view_range") && !slice.contains("bash"))
        #expect(await refusal(read, ["file_path": "long.txt", "view_range": [1, 1]]).contains("cannot return part of a line"))
        #expect(try await run(read, ["file_path": "long.txt", "view_range": [2, 2]]) == "ok")
    }

    @Test func readViewRangeOverCapPreservesLineEndings() async throws {
        let tmp = try ToolsetTempDir()
        try writeBytes(tmp.path("a.txt"), "line1\r\nline2\r\nline3\r\n")
        #expect(try await run(betaReadTool(try AgentToolContext(workdir: tmp.root, maxFileBytes: 16)), ["file_path": "a.txt", "view_range": [1, 2]])
            == "line1\r\nline2\r")

        try writeBytes(tmp.path("cr.txt"), "a\rb\rc\r")
        let tight = betaReadTool(try AgentToolContext(workdir: tmp.root, maxFileBytes: 4))
        #expect(await refusal(tight, ["file_path": "cr.txt", "view_range": [1, 1]]).contains("cannot return part of a line"))
        #expect(try await run(tight, ["file_path": "cr.txt", "view_range": [2, 2]]) == "")

        try writeBytes(tmp.path("b.txt"), "a\rb\rc\r\n0123456789\n")
        let read = betaReadTool(try AgentToolContext(workdir: tmp.root, maxFileBytes: 16))
        #expect(try await run(read, ["file_path": "b.txt", "view_range": [1, 1]]) == "a\rb\rc\r")
        #expect(try await run(read, ["file_path": "b.txt", "view_range": [3, 3]]) == "")
    }

    @Test func readViewRangeOverCapCrossesChunkBoundaries() async throws {
        let tmp = try ToolsetTempDir()
        let rows = (1...5000).map { "row" + rjust(String($0), 4).replacingOccurrences(of: " ", with: "0") + String(repeating: ".", count: 90) }
        try writeBytes(tmp.path("big.txt"), rows.map { $0 + "\n" }.joined())
        let out = try await run(betaReadTool(try AgentToolContext(workdir: tmp.root)), ["file_path": "big.txt", "view_range": [1000, 1002]])
        #expect(out == .string(rows[999..<1002].joined(separator: "\n")))
    }

    @Test func readAndEditRejectDirectoriesEvenWhenUncapped() async throws {
        let tmp = try ToolsetTempDir()
        _ = try tmp.mkdir("sub")
        for cap in [nil, .some(nil)] as [Int??] {
            let ctx = try AgentToolContext(workdir: tmp.root, maxFileBytes: cap)
            #expect(await refusal(betaReadTool(ctx), ["file_path": "sub"]).contains("not a regular file"))
            #expect(await refusal(betaEditTool(ctx), ["file_path": "sub", "old_string": "a", "new_string": "b"]).contains("not a regular file"))
        }
    }

    @Test func editCaps() async throws {
        // test_edit_rejects_oversized_file, ..._normal_within_limit, ..._custom_max_bytes_*, ..._uncapped_allows_oversized
        let tmp = try ToolsetTempDir()
        try writeBytes(tmp.path("big.txt"), [UInt8](repeating: 0x61, count: 257 * 1024))
        let oversized = await refusal(betaEditTool(try AgentToolContext(workdir: tmp.root)), ["file_path": "big.txt", "old_string": "a", "new_string": "b"])
        #expect(oversized.contains("exceeds") && !oversized.contains("bash"))

        try writeBytes(tmp.path("f.txt"), "hello world")
        _ = try await run(betaEditTool(try AgentToolContext(workdir: tmp.root)), ["file_path": "f.txt", "old_string": "world", "new_string": "there"])
        #expect(try String(contentsOfFile: tmp.path("f.txt"), encoding: .utf8) == "hello there")

        try writeBytes(tmp.path("small.txt"), Array("OLD".utf8) + [UInt8](repeating: 0, count: 2000))
        let below = await refusal(betaEditTool(try AgentToolContext(workdir: tmp.root, maxFileBytes: 1024)),
                                  ["file_path": "small.txt", "old_string": "OLD", "new_string": "NEW"])
        #expect(below.contains("exceeds") && !below.contains("bash"))

        try writeBytes(tmp.path("large.txt"), Array("OLD".utf8) + [UInt8](repeating: 0, count: 257 * 1024))
        _ = try await run(betaEditTool(try AgentToolContext(workdir: tmp.root, maxFileBytes: 512 * 1024)),
                          ["file_path": "large.txt", "old_string": "OLD", "new_string": "NEW"])
        #expect(Array(bytes(tmp.path("large.txt")).prefix(3)) == Array("NEW".utf8))
        _ = try await run(betaEditTool(try AgentToolContext(workdir: tmp.root, maxFileBytes: .some(nil))),
                          ["file_path": "large.txt", "old_string": "NEW", "new_string": "OLD"])
    }

    @Test func readCaps() async throws {
        // test_read_custom_max_bytes_rejects_below_cap and test_read_uncapped_allows_oversized
        let tmp = try ToolsetTempDir()
        try writeBytes(tmp.path("f.txt"), [UInt8](repeating: 0x61, count: 2000))
        let below = await refusal(betaReadTool(try AgentToolContext(workdir: tmp.root, maxFileBytes: 1024)), ["file_path": "f.txt"])
        #expect(below.contains("exceeds") && below.contains("view_range") && !below.contains("bash"))
        try writeBytes(tmp.path("big.txt"), [UInt8](repeating: 0x61, count: 257 * 1024))
        _ = try await run(betaReadTool(try AgentToolContext(workdir: tmp.root, maxFileBytes: .some(nil))), ["file_path": "big.txt"])
    }

    @Test func binaryMediaTypesTrackGeneratedAPITypes() {
        let supported = Set(BetaBase64ImageSourceParam.MediaType.allCases.map(\.rawValue) + ["application/pdf"])
        #expect(Set(BINARY_MEDIA_TYPES.values) == supported)
    }

    static let jpeg: [UInt8] = [0xFF, 0xD8, 0xFF, 0xE0] + [UInt8](repeating: 0, count: 32)
    static let png: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A] + [UInt8](repeating: 0, count: 32)
    static let pdf: [UInt8] = Array("%PDF-1.4\n%".utf8) + [0xE2, 0xE3, 0xCF, 0xD3, 0x0A]

    @Test(arguments: [("slide.jpg", 0, "image", "image/jpeg"), ("slide.JPEG", 0, "image", "image/jpeg"), ("chart.png", 1, "image", "image/png"),
                      ("doc.pdf", 2, "document", "application/pdf")])
    func readBinaryReturnsContentBlock(_ filename: String, _ which: Int, _ kind: String, _ mediaType: String) async throws {
        let tmp = try ToolsetTempDir()
        let data = [Self.jpeg, Self.png, Self.pdf][which]
        try writeBytes(tmp.path(filename), data)
        let result = try await run(betaReadTool(try AgentToolContext(workdir: tmp.root)), ["file_path": .string(filename)])
        let blocks = result.arrayValue ?? []
        #expect(blocks.count == 1 && blocks[0]["type"] == .string(kind))
        #expect(blocks[0]["source"]?["type"] == "base64" && blocks[0]["source"]?["media_type"] == .string(mediaType))
        #expect(blocks[0]["source"]?["data"]?.stringValue.flatMap { Data(base64Encoded: $0) }.map { [UInt8]($0) } == data)
    }

    @Test func readBinaryCaps() async throws {
        // test_read_binary_not_subject_to_text_cap, ..._honors_explicit_cap, ..._rejects_over_media_cap,
        // ..._custom_media_caps, ..._rejects_view_range
        let tmp = try ToolsetTempDir()
        try writeBytes(tmp.path("big.png"), Self.png + [UInt8](repeating: 0, count: 300 * 1024))
        #expect(try await run(betaReadTool(try AgentToolContext(workdir: tmp.root)), ["file_path": "big.png"])[0]?["type"] == "image")
        try writeBytes(tmp.path("img.png"), Self.png + [UInt8](repeating: 0, count: 2048))
        #expect(await refusal(betaReadTool(try AgentToolContext(workdir: tmp.root, maxFileBytes: 1024)), ["file_path": "img.png"]).contains("exceeds"))

        let rawCap = (DEFAULT_MAX_IMAGE_BASE64_BYTES / 4) * 3
        try writeBytes(tmp.path("huge.png"), [UInt8](repeating: 0, count: rawCap + 1))
        #expect(await refusal(betaReadTool(try AgentToolContext(workdir: tmp.root, maxFileBytes: .some(nil))), ["file_path": "huge.png"]).contains("exceeds"))

        try writeBytes(tmp.path("doc.pdf"), Self.pdf + [UInt8](repeating: 0, count: 2048))
        let tight = betaReadTool(try AgentToolContext(workdir: tmp.root, maxImageBase64Bytes: 1024, maxPDFBytes: 1024))
        #expect(await refusal(tight, ["file_path": "img.png"]).contains("exceeds"))
        #expect(await refusal(tight, ["file_path": "doc.pdf"]).contains("exceeds"))
        let loose = betaReadTool(try AgentToolContext(workdir: tmp.root, maxImageBase64Bytes: 1024 * 1024, maxPDFBytes: .some(nil)))
        #expect(try await run(loose, ["file_path": "img.png"])[0]?["type"] == "image")
        #expect(try await run(loose, ["file_path": "doc.pdf"])[0]?["type"] == "document")

        try writeBytes(tmp.path("slide.jpg"), Self.jpeg)
        #expect(await refusal(betaReadTool(try AgentToolContext(workdir: tmp.root)), ["file_path": "slide.jpg", "view_range": [1, 2]])
            .contains("view_range is not supported"))
    }

    @Test func undecodableBinaryRaisesToolError() async throws {
        // test_read_undecodable_binary_raises_tool_error and test_edit_binary_raises_tool_error
        let tmp = try ToolsetTempDir()
        try writeBytes(tmp.path("blob.bin"), [0xFF, 0xFE, 0x00, 0x01])
        let ctx = try AgentToolContext(workdir: tmp.root)
        #expect(await refusal(betaReadTool(ctx), ["file_path": "blob.bin"]).contains("not valid UTF-8"))
        #expect(await refusal(betaEditTool(ctx), ["file_path": "blob.bin", "old_string": "a", "new_string": "b"]).contains("not valid UTF-8"))
    }

    @Test(arguments: [
        (["file_path": "f.txt", "old_string": "nope", "new_string": "x"], true),
        (["file_path": "f.txt", "old_string": "ab", "new_string": "x"], true),
        (["file_path": "f.txt", "old_string": "ab", "new_string": "x", "replace_all": true], false),
    ] as [(JSONValue, Bool)])
    func editUniqueness(_ args: JSONValue, _ wantError: Bool) async throws {
        let tmp = try ToolsetTempDir()
        try writeBytes(tmp.path("f.txt"), "ab ab")
        let edit = betaEditTool(try AgentToolContext(workdir: tmp.root))
        if wantError {
            _ = await refusal(edit, args)
        } else {
            #expect(try await run(edit, args) == "edited f.txt (2 replacement(s))")
        }
    }

    @Test func fileToolsConfinementMatrix() async throws {
        let tmp = try ToolsetTempDir()
        let work = try tmp.mkdir("work")
        let mount = try tmp.mkdir("mnt", "notes")
        let ro = try tmp.mkdir("mnt", "facts")
        _ = try tmp.write("immutable", "mnt", "facts", "facts.md")
        let outside = try tmp.mkdir("outside")
        _ = try tmp.write("secret", "outside", "secret.txt")
        let ctx = try AgentToolContext(workdir: work, allowedRoots: [mount, ro], readOnlyRoots: [ro])
        let (read, write, edit) = (betaReadTool(ctx), betaWriteTool(ctx), betaEditTool(ctx))

        _ = try await run(write, ["file_path": "w.txt", "content": "in workdir"])
        #expect(try String(contentsOfFile: work + "/w.txt", encoding: .utf8) == "in workdir")
        _ = try await run(write, ["file_path": .string(mount + "/note.md"), "content": "remembered"])
        #expect(try await run(read, ["file_path": .string(mount + "/note.md")]) == "remembered")
        _ = try await run(edit, ["file_path": .string(mount + "/note.md"), "old_string": "remembered", "new_string": "edited"])
        #expect(try String(contentsOfFile: mount + "/note.md", encoding: .utf8) == "edited")

        #expect(try await run(read, ["file_path": .string(ro + "/facts.md")]) == "immutable")
        #expect(await refusal(write, ["file_path": .string(ro + "/facts.md"), "content": "x"]).contains("read-only"))
        #expect(try String(contentsOfFile: ro + "/facts.md", encoding: .utf8) == "immutable")

        let both = "outside the session's working directory and its other permitted directories"
        #expect(await refusal(read, ["file_path": .string(outside + "/secret.txt")]).contains(both))
        #expect(await refusal(write, ["file_path": .string(outside + "/new.txt"), "content": "x"]).contains(both))
        #expect(!FileManager.default.fileExists(atPath: outside + "/new.txt"))
    }

    @Test func symlinksThroughTheFileTools() async throws {
        // test_read_through_symlink_escape_is_rejected, test_read_symlink_loop_is_rejected,
        // test_write_under_symlink_loop_creates_nothing
        let tmp = try ToolsetTempDir()
        let work = try symlinkFixture(tmp)
        try tmp.symlink(work + "/escape", to: tmp.path("outside"))
        let ctx = try AgentToolContext(workdir: work)
        #expect(await refusal(betaReadTool(ctx), ["file_path": "escape/secret.txt"]).contains("outside the session's working directory"))
        #expect(await refusal(betaReadTool(ctx), ["file_path": "loop_a"]) == "read: path 'loop_a': too many levels of symbolic links")
        for p in ["loop_a/../evil_link", "L"] { #expect(!(await refusal(betaReadTool(ctx), ["file_path": .string(p)])).contains("SECRET")) }

        let before = try FileManager.default.contentsOfDirectory(atPath: work).sorted()
        #expect(await refusal(betaWriteTool(ctx), ["file_path": "loop_a/child.txt", "content": "x"]).contains("too many levels of symbolic links"))
        #expect(try FileManager.default.contentsOfDirectory(atPath: work).sorted() == before)
    }

    @Test func symlinksInsideTheWorkdirAreFollowed() async throws {
        // test_write_through_dangling_symlink_inside_workdir, test_read_follows_symlink_chain_inside_workdir,
        // test_write_creates_deeply_nested_missing_directories
        let tmp = try ToolsetTempDir()
        let ctx = try AgentToolContext(workdir: tmp.root)
        try tmp.symlink(tmp.path("d"), to: tmp.path("newdir", "f.txt"))
        _ = try await run(betaWriteTool(ctx), ["file_path": "d", "content": "via link"])
        #expect(try String(contentsOfFile: tmp.path("newdir", "f.txt"), encoding: .utf8) == "via link")

        _ = try tmp.write("payload", "real.txt")
        try tmp.symlink(tmp.path("c2"), to: "real.txt")
        try tmp.symlink(tmp.path("c1"), to: "c2")
        try tmp.symlink(tmp.path("c0"), to: "c1")
        #expect(try await run(betaReadTool(ctx), ["file_path": "c0"]) == "payload")

        let rel = (0..<50).map { "d\($0)" }.joined(separator: "/") + "/f.txt"
        _ = try await run(betaWriteTool(ctx), ["file_path": .string(rel), "content": "deep"])
        #expect(try String(contentsOfFile: tmp.path(rel), encoding: .utf8) == "deep")
    }

    @Test func readUnderUnreadableDirectoryReportsPermissionDenied() async throws {
        if geteuid() == 0 { return }  // root bypasses POSIX mode bits, as upstream skips it
        let tmp = try ToolsetTempDir()
        let noperm = try tmp.mkdir("noperm")
        chmod(noperm, 0)
        defer { chmod(noperm, 0o700) }
        #expect(await refusal(betaReadTool(try AgentToolContext(workdir: tmp.root)), ["file_path": "noperm/x"])
            == "read: path 'noperm/x': permission denied")
    }
}

@Suite struct AgentToolsetSearchTests {
    @Test func globMtimeOrder() async throws {
        let tmp = try ToolsetTempDir()
        let a = try tmp.write("a", "a.txt")
        let b = try tmp.write("b", "b.txt")
        try FileManager.default.setAttributes([.modificationDate: Date(timeIntervalSince1970: 1)], ofItemAtPath: a)
        try FileManager.default.setAttributes([.modificationDate: Date(timeIntervalSince1970: 2)], ofItemAtPath: b)
        let lines = (try await run(betaGlobTool(try AgentToolContext(workdir: tmp.root)), ["pattern": "*.txt"])).stringValue?
            .split(separator: "\n").map(String.init) ?? []
        #expect(lines.count == 2 && lines[0].hasSuffix("b.txt") && lines[1].hasSuffix("a.txt"))
    }

    @Test func globWithPath() async throws {
        let tmp = try ToolsetTempDir()
        _ = try tmp.write("a", "sub", "a.txt")
        _ = try tmp.write("b", "b.txt")
        let res = try await run(betaGlobTool(try AgentToolContext(workdir: tmp.root)), ["pattern": "*.txt", "path": "sub"]).stringValue ?? ""
        #expect(res.hasSuffix("a.txt") && !res.contains("b.txt"))
    }

    @Test func globRejectsDotdotPatternAndFiltersEscapes() async throws {
        // test_glob_rejects_dotdot_pattern, test_glob_post_filters_symlink_escape
        let tmp = try ToolsetTempDir()
        _ = try tmp.write("secret", "outside", "secret.txt")
        let work = try tmp.mkdir("work")
        try tmp.symlink(work + "/escape", to: tmp.path("outside"))
        let glob = betaGlobTool(try AgentToolContext(workdir: work))
        #expect(await refusal(glob, ["pattern": "../outside/*.txt"]).contains(".."))
        #expect(try await run(glob, ["pattern": "escape/*.txt"]) == "no matches")
    }

    @Test func globDropsMatchesThatCannotBeCanonicalised() async throws {
        let tmp = try ToolsetTempDir()
        let work = try symlinkFixture(tmp)
        _ = try tmp.write("ok", "work", "ok.txt")
        let res = try await run(betaGlobTool(try AgentToolContext(workdir: work)), ["pattern": "*"]).stringValue ?? ""
        #expect(res.split(separator: "\n").map { ($0 as NSString).lastPathComponent } == ["ok.txt"])
    }

    @Test func grepFindsMatch() async throws {
        let tmp = try ToolsetTempDir()
        _ = try tmp.write("foo\nbar\nbaz\n", "x.txt")
        let ctx = try AgentToolContext(workdir: tmp.root)
        let res = try await run(betaGrepTool(ctx), ["pattern": "ba.", "path": "."]).stringValue ?? ""
        #expect(res.contains("bar") && res.contains("baz"))
        // the fallback walker finds the same
        let walked = try await AgentToolset.$findRipgrep.withValue({ nil }) {
            try await run(betaGrepTool(ctx), ["pattern": "ba.", "path": "."]).stringValue ?? ""
        }
        #expect(walked.contains("bar") && walked.contains("baz"))
    }

    @Test func grepSingleFilePath() async throws {
        let tmp = try ToolsetTempDir()
        _ = try tmp.write("alpha\nbeta\n", "x.txt")
        let ctx = try AgentToolContext(workdir: tmp.root)
        let res = try await AgentToolset.$findRipgrep.withValue({ nil }) {
            try await run(betaGrepTool(ctx), ["pattern": "beta", "path": "x.txt"]).stringValue ?? ""
        }
        #expect(res.contains("beta") && res != "no matches")
    }

    @Test func grepSkipsSymlinkedFiles() async throws {
        let tmp = try ToolsetTempDir()
        let secret = try tmp.write("TOPSECRET", "secret.txt")
        let work = try tmp.mkdir("work")
        try tmp.symlink(work + "/leak", to: secret)
        _ = try tmp.write("ordinary\n", "work", "real.txt")
        let ctx = try AgentToolContext(workdir: work)
        let res = try await AgentToolset.$findRipgrep.withValue({ nil }) { try await run(betaGrepTool(ctx), ["pattern": "TOPSECRET"]) }
        #expect(res == "no matches")
    }

    @Test func globAndGrepReachAnAllowedRoot() async throws {
        let tmp = try ToolsetTempDir()
        let work = try tmp.mkdir("work")
        let mount = try tmp.mkdir("mnt", "notes")
        _ = try tmp.write("remembered fact", "mnt", "notes", "note.md")
        let ctx = try AgentToolContext(workdir: work, allowedRoots: [mount])
        #expect(try await run(betaGlobTool(ctx), ["pattern": "*.md", "path": .string(mount)]) == .string(mount + "/note.md"))
        let res = try await AgentToolset.$findRipgrep.withValue({ nil }) {
            try await run(betaGrepTool(ctx), ["pattern": "remembered", "path": .string(mount)]).stringValue ?? ""
        }
        #expect(res.contains("note.md"))
    }
}

@Suite struct AgentToolsetBashTests {
    @Test func bashSessionPersistence() async throws {
        let tmp = try ToolsetTempDir()
        let session = try await BashSession.start(workdir: tmp.root)
        let set = try await session.exec("export FOO=bar; echo set")
        #expect(set == BashResult(output: "set", exitCode: 0))
        #expect(try await session.exec("echo $FOO") == BashResult(output: "bar", exitCode: 0))
        await session.close()
    }

    @Test func bashTimeout() async throws {
        let tmp = try ToolsetTempDir()
        let session = try await BashSession.start(workdir: tmp.root)
        await #expect(throws: BashTimeoutError.self) { _ = try await session.exec("sleep 5", timeout: 0.2) }
        #expect(session.closed)
    }

    @Test func bashSentinelIsNotSpoofable() async throws {
        let tmp = try ToolsetTempDir()
        let session = try await BashSession.start(workdir: tmp.root)
        let result = try await session.exec("printf '__ANT_CMD_DONE__7\\nafter\\n'; (exit 3)")
        #expect(result.output.contains("__ANT_CMD_DONE__7") && result.output.contains("after") && result.exitCode == 3)
        await session.close()
    }

    @Test func bashStdinRedirect() async throws {
        let tmp = try ToolsetTempDir()
        let session = try await BashSession.start(workdir: tmp.root)
        #expect(try await session.exec("cat; echo done", timeout: 2) == BashResult(output: "done", exitCode: 0))
        await session.close()
    }

    @Test func bashSessionClosedProperty() async throws {
        let tmp = try ToolsetTempDir()
        let session = try await BashSession.start(workdir: tmp.root)
        #expect(session.closed == false)
        await session.close()
        #expect(session.closed == true)
        // A closed session refuses further commands rather than silently hanging.
        await #expect(throws: BashSessionTerminatedError.self) { _ = try await session.exec("echo nope") }
    }

    @Test func bashOuterCancelClosesTheProcessWithNoStaleState() async throws {
        let tmp = try ToolsetTempDir()
        let session = try await BashSession.start(workdir: tmp.root)
        let running = Task { try await session.exec("sleep 5; echo STALE_MARKER", timeout: 120) }
        try await Task.sleep(nanoseconds: 300_000_000)
        running.cancel()
        _ = try? await running.value
        // The outer cancel fired mid-exec: the process was closed, so the next exec refuses outright.
        #expect(session.closed == true)
        await #expect(throws: BashSessionTerminatedError.self) { _ = try await session.exec("echo NEXT") }
        await session.close()
    }

    @Test func theBashToolRunsCommandsAndRestarts() async throws {
        // the tool around the session: a failing command's output is the refusal, restart starts a fresh shell
        let tmp = try ToolsetTempDir()
        let bash = betaBashTool(try AgentToolContext(workdir: tmp.root))
        #expect(try await run(bash, ["command": "export X=1; echo $X"]) == "1")
        #expect(try await run(bash, ["command": "echo $X"]) == "1")
        #expect(await refusal(bash, ["command": "echo failed; exit 2"]) == "failed")
        #expect(await refusal(bash, [:]) == "bash: command is required")
        #expect(try await run(bash, ["restart": true]) == "bash session restarted")
        #expect(try await run(bash, ["command": "echo ${X:-unset}"]) == "unset")
        try await bash.closeTool()
    }
}
