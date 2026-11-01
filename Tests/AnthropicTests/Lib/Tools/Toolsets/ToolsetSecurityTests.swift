// Port of `tests/lib/tools/toolsets/test_security.py`: the upload path check and `BetaLocalFilePolicy`.

import Foundation
import Testing
@testable import Anthropic

private let UPLOAD_OUTSIDE_ROOTS = "file_upload path is outside the configured upload roots"
private let UPLOAD_NO_ROOTS = "file_upload has no configured upload roots"
private let UPLOAD_EMPTY_PATH = "file_upload path is empty or contains a NUL byte"
private let UPLOAD_DOTDOT = "file_upload path must not contain a '..' component"

/// The refusal text `betaCheckUploadPath` throws, or `nil` when it passes.
private func refusalText(_ path: String, _ roots: [String], strictRoots: Bool = true) -> String? {
    do {
        _ = try betaCheckUploadPath(path, roots, strictRoots: strictRoots)
        return nil
    } catch let error as ToolError {
        return error.message
    } catch {
        return "\(error)"
    }
}

@Suite struct ToolsetSecurityTests {
    @Test func uploadPathTable() throws {
        let tmp = try ToolsetTempDir()
        let root = try tmp.mkdir("srv", "upload")
        _ = try tmp.write("x", "srv", "upload", "ok.txt")
        _ = try tmp.write("x", "srv", "uploads-old", "x")
        _ = try tmp.write("s", "secret")
        try tmp.symlink(root + "/link-out", to: tmp.path("secret"))
        try tmp.symlink(root + "/chain", to: root + "/link-out")
        let roots = [root]

        #expect(try betaCheckUploadPath(root + "/ok.txt", roots) == root + "/ok.txt")
        #expect(try betaCheckUploadPath(root, roots) == root)
        #expect(try betaCheckUploadPath(root + "/.", roots) == root)
        #expect(try betaCheckUploadPath(root + "/new/file.bin", roots) == root + "/new/file.bin")
        #expect(try betaCheckUploadPath(root + "/ok.txt", [tmp.path("nope"), root]) == root + "/ok.txt")

        for bad in [tmp.path("srv", "uploads-old", "x"), root + "/link-out", root + "/chain", "relative/path.txt"] {
            #expect(refusalText(bad, roots) == UPLOAD_OUTSIDE_ROOTS, "\(bad)")
        }
        for dots in [root + "/../uploads-old/x", root + "/../../secret"] {
            #expect(refusalText(dots, roots) == UPLOAD_DOTDOT, "\(dots)")
        }
        #expect(refusalText(root + "/ok.txt", []) == UPLOAD_NO_ROOTS)
        for invalid in ["", "a\u{0}b"] { #expect(refusalText(invalid, roots) == UPLOAD_EMPTY_PATH) }
    }

    @Test func uploadSiblingPrefixIsNotARootMatch() throws {
        let tmp = try ToolsetTempDir()
        _ = try tmp.mkdir("upload")
        _ = try tmp.write("x", "upload-evil", "x")
        #expect(refusalText(tmp.path("upload-evil", "x"), [tmp.path("upload")]) != nil)
    }

    @Test func uploadDotdotComponentIsRefused() throws {
        let tmp = try ToolsetTempDir()
        let root = try tmp.mkdir("srv", "upload")
        _ = try tmp.write("s", "secret")
        for bad in [root + "/ghost/../../../secret", root + "/ghost/../../secret", root + "/a/b/../../../secret", root + "/ghost/../file.bin"] {
            #expect(refusalText(bad, [root]) == UPLOAD_DOTDOT, "\(bad)")
        }
    }

    @Test func aDanglingSymlinkInARootIsJudgedByItsTargetAndACycleResolvesAsWritten() throws {
        let tmp = try ToolsetTempDir()
        let root = try tmp.mkdir("upload")
        let outside = try tmp.mkdir("outside")
        try tmp.symlink(root + "/dangling", to: outside + "/gone.txt")
        try tmp.symlink(root + "/a", to: root + "/b")
        try tmp.symlink(root + "/b", to: root + "/a")
        #expect(refusalText(root + "/dangling", [root]) == UPLOAD_OUTSIDE_ROOTS)
        for loop in ["a", "b"] { #expect(try betaCheckUploadPath(root + "/" + loop, [root]) == root + "/" + loop) }
        // a genuinely absent child still resolves
        #expect(try betaCheckUploadPath(root + "/new.bin", [root]) == root + "/new.bin")
    }

    @Test func anUploadPathOutsideEveryRootIsRefusedWithoutTouchingTheFilesystem() throws {
        let tmp = try ToolsetTempDir()
        let root = try tmp.mkdir("uploads")
        try tmp.symlink(root + "/escape", to: tmp.root)
        let resolved = ToolsBox<[String]>([])
        try ToolsetSecurity.$resolveObserver.withValue({ path in resolved.mutate { $0.append(path) } }) { () throws in
            #expect(refusalText("/net/elsewhere.example/share/f", [root]) == UPLOAD_OUTSIDE_ROOTS)
            #expect(!resolved.value.contains { $0.contains("elsewhere") })  // only the deployer's root was looked at

            let escape = root + "/escape/secret"
            #expect(refusalText(escape, [root]) == UPLOAD_OUTSIDE_ROOTS)
            #expect(resolved.value.contains(escape))  // the spy sees a path that is resolved
            #expect(try betaCheckUploadPath(root + "/f.txt", [root]) == root + "/f.txt")
        }
    }

    @Test func aDownloadPathOutsideTheDownloadDirIsHiddenWithoutTouchingTheFilesystem() throws {
        let tmp = try ToolsetTempDir()
        let downloads = try tmp.mkdir("downloads")
        let policy = try BetaLocalFilePolicy(downloadDir: downloads, exposeDownloadPaths: true)
        let resolved = ToolsBox<[String]>([])
        try ToolsetSecurity.$resolveObserver.withValue({ path in resolved.mutate { $0.append(path) } }) { () throws in
            #expect(try policy.isPathVisible("/net/elsewhere.example/share/f.bin") == false)
            // A ".." component is refused on its text alone.
            #expect(try policy.isPathVisible("/net/elsewhere.example/share/../../..\(downloads)/f.bin") == false)
            #expect(!resolved.value.contains { $0.contains("elsewhere") })
            let inside = downloads + "/f.bin"
            #expect(try policy.isPathVisible(inside) == true)
            #expect(resolved.value.contains(inside))
        }
    }

    @Test(arguments: [
        #"\\attacker.example\share\f.txt"#, "//attacker.example/share/f.txt", #"/\attacker.example\share\f.txt"#, #"\/?\C:\x"#,
        #"\\?\C:\x"#, "CON", "com1.tar", "NUL.txt", #"sub\COM1.txt"#, "C:CON", "C:NUL.txt", "COM1 ", "f.txt:CON", "CON .txt",
        "NUL   .bin", "COM1 .log", "CONIN$", "CONOUT$", "COM0", "lpt0.txt",
    ])
    func windowsNetworkAndDevicePathsAreRefusedLexicallyOnWindows(_ candidate: String) throws {
        let tmp = try ToolsetTempDir()
        let path = candidate.hasPrefix("\\") || candidate.hasPrefix("/") ? candidate : tmp.root + "/" + candidate
        try ToolsetSecurity.$onWindows.withValue(true) { () throws in
            ToolsetSecurity.$resolveObserver.withValue({ _ in Issue.record("the candidate must be refused before it is resolved") }) {
                #expect(refusalText(path, [tmp.root]) == UPLOAD_OUTSIDE_ROOTS)
            }
        }
    }

    @Test func elsewhereADeviceNamedFileIsAnOrdinaryFile() throws {
        let tmp = try ToolsetTempDir()
        let root = tmp.root
        _ = try tmp.mkdir("aux")
        for name in ["CON", "con.pdf", "aux/notes.txt", "COM1 .log"] {
            #expect(try betaCheckUploadPath(root + "/" + name, [root]) == root + "/" + name)
        }
        // two leading slashes name no network location here; such a path is judged by containment like any other
        #expect(refusalText("//attacker.example/share/f.txt", [root]) != nil)
        let policy = try BetaLocalFilePolicy(downloadDir: root, exposeDownloadPaths: true)
        #expect(try policy.isPathVisible(root + "/nul.bin") == true)
        try ToolsetSecurity.$onWindows.withValue(true) { () throws in #expect(try policy.isPathVisible(root + "/nul.bin") == false) }
    }

    @Test func uploadRootThatDoesNotExistGrantsNothing() throws {
        let tmp = try ToolsetTempDir()
        let missing = tmp.path("nope")
        #expect(refusalText(missing + "/file.bin", [missing]) != nil)
        // Same when the missing root sits behind a symlink whose target exists but the leaf does not.
        let link = tmp.path("link")
        try tmp.symlink(link, to: tmp.root)
        #expect(refusalText(link + "/uploads/file.bin", [link + "/uploads"]) != nil)
    }

    @Test func allBlankUploadRootsReportNoConfiguredRoots() {
        for roots in [[""], ["  "], ["", "  "]] { #expect(refusalText("/x/f", roots) == UPLOAD_NO_ROOTS) }
    }

    @Test func localFilePolicyResolvesUploadsUnderItsRoots() throws {
        let tmp = try ToolsetTempDir()
        let root = try tmp.mkdir("uploads")
        _ = try tmp.write("x", "uploads", "form.pdf")
        let ctx = BetaURLContext(member: .fileUpload)
        let policy = try BetaLocalFilePolicy(uploadRoots: [root])
        #expect(try policy.resolveUploadPaths(context: ctx, paths: [root + "/form.pdf"]) == [root + "/form.pdf"])
        #expect(throws: UploadOutsideRootsError.self) { try policy.resolveUploadPaths(context: ctx, paths: [tmp.path("secret")]) }
        do {
            _ = try policy.resolveUploadPaths(context: ctx, paths: [root + "/../secret"])
            Issue.record("expected a refusal")
        } catch let error as ToolError {
            #expect(error.message.contains("must not contain a '..' component"))
        }
        // No roots configured: every path-bearing upload is refused.
        #expect(throws: UploadNoRootsError.self) { try BetaLocalFilePolicy().resolveUploadPaths(context: ctx, paths: [root + "/form.pdf"]) }
    }

    @Test func localFilePolicyVetsDocumentIDsAgainstItsAllowlist() throws {
        let ctx = BetaURLContext(member: .fileUpload)
        #expect(throws: UploadRefusedError.self) { try BetaLocalFilePolicy().resolveUploadDocuments(context: ctx, documentIDs: ["file_abc"]) }
        let policy = try BetaLocalFilePolicy(uploadDocumentIDs: ["file_abc", "file_def"])
        #expect(try policy.resolveUploadDocuments(context: ctx, documentIDs: ["file_def"]) == ["file_def"])
        do {
            _ = try policy.resolveUploadDocuments(context: ctx, documentIDs: ["file_def", "file_xyz"])
            Issue.record("expected a refusal")
        } catch let error as ToolError {
            #expect(!error.message.contains("file_xyz") && error.message.contains("not in the upload allowlist"))
        }
        #expect(policy.uploadDocumentIDs == ["file_abc", "file_def"])
    }

    @Test func localFilePolicyDownloadVisibility() throws {
        let tmp = try ToolsetTempDir()
        let downloads = try tmp.mkdir("downloads")
        #expect(try BetaLocalFilePolicy(downloadDir: downloads).isPathVisible(downloads + "/a.bin") == false)
        let exposing = try BetaLocalFilePolicy(downloadDir: downloads, exposeDownloadPaths: true)
        #expect(try exposing.isPathVisible(downloads + "/a.bin") == true)
        #expect(try exposing.isPathVisible(downloads + "/sub/not-yet.bin") == true)
        // A server-suggested name that climbs out, or a path elsewhere, stays hidden.
        #expect(try exposing.isPathVisible(downloads + "/../a.bin") == false)
        #expect(try exposing.isPathVisible("/etc/passwd") == false)
    }

    @Test func localFilePolicyConstructionRules() throws {
        let tmp = try ToolsetTempDir()
        // with no download_dir there is nothing to expose
        #expect(try BetaLocalFilePolicy(exposeDownloadPaths: true).isPathVisible(tmp.path("f.bin")) == false)

        func configError(_ build: () throws -> BetaLocalFilePolicy) -> String? {
            do {
                _ = try build()
                return nil
            } catch let error as ToolsetConfigError {
                return error.message
            } catch {
                return "\(error)"
            }
        }
        #expect(configError { try BetaLocalFilePolicy(uploadRoots: [""]) }?.contains("must not be empty") == true)
        #expect(configError { try BetaLocalFilePolicy(downloadDir: " ") }?.contains("must not be empty") == true)

        // The download-then-upload loop: a download directory inside (or containing) an upload root.
        #expect(configError { try BetaLocalFilePolicy(uploadRoots: [tmp.root], downloadDir: tmp.path("dl")) }?
            .hasPrefix("download_dir \(pythonStringRepr(tmp.path("dl"))) must be outside") == true)
        #expect(configError { try BetaLocalFilePolicy(uploadRoots: [tmp.path("up")], downloadDir: tmp.root) }?
            .contains("outside every upload root") == true)
        // On a disk that ignores letter case a case variant names the same directory, so it is refused everywhere.
        #expect(configError { try BetaLocalFilePolicy(uploadRoots: [tmp.path("Uploads")], downloadDir: tmp.path("uploads", "dl")) }?
            .contains("outside every upload root") == true)
        // The same disk ignores the Unicode form of a name too.
        #expect(configError { try BetaLocalFilePolicy(uploadRoots: [tmp.path("t\u{00e9}l\u{00e9}")], downloadDir: tmp.path("te\u{0301}le\u{0301}")) }?
            .contains("outside every upload root") == true)

        // A download_dir that is a symlink into an upload root is the same loop by another spelling.
        let uploads = try tmp.mkdir("uploads", "dl")
        try tmp.symlink(tmp.path("downloads"), to: uploads)
        #expect(configError { try BetaLocalFilePolicy(uploadRoots: [tmp.path("uploads")], downloadDir: tmp.path("downloads")) }?
            .contains("outside every upload root") == true)
        // ... and so is an upload root that is a symlink into the download directory.
        let realDownloads = try tmp.mkdir("real_downloads")
        try tmp.symlink(tmp.path("root_link"), to: realDownloads)
        #expect(configError { try BetaLocalFilePolicy(uploadRoots: [tmp.path("root_link")], downloadDir: realDownloads + "/sub") }?
            .contains("outside every upload root") == true)

        let policy = try BetaLocalFilePolicy(uploadRoots: [tmp.path("up")], downloadDir: tmp.path("dl"))
        #expect(policy.uploadRoots == [tmp.path("up")] && policy.downloadDir == tmp.path("dl"))
    }
}
