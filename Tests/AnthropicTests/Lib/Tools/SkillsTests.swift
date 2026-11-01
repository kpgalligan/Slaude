// Port of tests/lib/tools/test_skills.py.
//
// Upstream builds its archives with `zipfile` / `tarfile`; here small writers produce the same bytes: stored zip
// entries, ustar members, and gzip with stored deflate blocks (plus one real deflate-compressed vector).

import Foundation
import Testing
@testable import Anthropic

#if canImport(Glibc)
    import Glibc
#elseif canImport(Darwin)
    import Darwin
#endif

private func le16(_ v: Int) -> [UInt8] { [UInt8(v & 0xFF), UInt8((v >> 8) & 0xFF)] }
private func le32(_ v: Int) -> [UInt8] { le16(v & 0xFFFF) + le16((v >> 16) & 0xFFFF) }

private func crc32(_ data: [UInt8]) -> UInt32 {
    var crc: UInt32 = 0xFFFF_FFFF
    for byte in data {
        crc ^= UInt32(byte)
        for _ in 0..<8 { crc = crc & 1 != 0 ? (crc >> 1) ^ 0xEDB8_8320 : crc >> 1 }
    }
    return ~crc
}

/// A zip entry: `externalAttr` holds the Unix mode in its high 16 bits; `createSystem` 3 is Unix.
struct ZipSpec {
    var name: String
    var data: [UInt8]
    var externalAttr: UInt32
    var createSystem: Int = 3

    /// `zf.writestr(name, data)`: Python records mode 0o600 for a plain name.
    static func named(_ name: String, _ data: String) -> ZipSpec { ZipSpec(name: name, data: Array(data.utf8), externalAttr: 0o600 << 16) }
    /// `ZipInfo(name)` with `external_attr = mode << 16`.
    static func mode(_ name: String, _ data: String, _ mode: Int, createSystem: Int = 3) -> ZipSpec {
        ZipSpec(name: name, data: Array(data.utf8), externalAttr: UInt32(mode) << 16, createSystem: createSystem)
    }
}

func makeZip(_ entries: [ZipSpec]) -> [UInt8] {
    var out: [UInt8] = []
    var central: [UInt8] = []
    for e in entries {
        let name = Array(e.name.utf8)
        let offset = out.count
        let crc = Int(crc32(e.data))
        out += le32(0x0403_4B50) + le16(20) + le16(0) + le16(0) + le16(0) + le16(0) + le32(crc) + le32(e.data.count)
            + le32(e.data.count) + le16(name.count) + le16(0) + name + e.data
        central += le32(0x0201_4B50) + le16(e.createSystem << 8 | 20) + le16(20) + le16(0) + le16(0) + le16(0) + le16(0)
            + le32(crc) + le32(e.data.count) + le32(e.data.count) + le16(name.count) + le16(0) + le16(0) + le16(0) + le16(0)
            + le32(Int(e.externalAttr)) + le32(offset) + name
    }
    let centralOffset = out.count
    out += central
    out += le32(0x0605_4B50) + le16(0) + le16(0) + le16(entries.count) + le16(entries.count) + le32(central.count)
        + le32(centralOffset) + le16(0)
    return out
}

/// A tar member (`tarfile.TarInfo`): type `"0"` regular, `"2"` symlink, ...
struct TarSpec {
    var name: String
    var data: [UInt8] = []
    var mode: Int = 0o644
    var type: Character = "0"
    var linkname: String = ""

    static func file(_ name: String, _ data: String, mode: Int = 0o644, type: Character = "0") -> TarSpec {
        TarSpec(name: name, data: Array(data.utf8), mode: mode, type: type)
    }
    static func special(_ name: String, _ type: Character, _ linkname: String = "") -> TarSpec {
        TarSpec(name: name, type: type, linkname: linkname)
    }
}

private func tarHeader(name: String, size: Int, mode: Int, type: Character, linkname: String = "") -> [UInt8] {
    var h = [UInt8](repeating: 0, count: 512)
    func put(_ s: String, _ offset: Int) { for (i, b) in s.utf8.enumerated() { h[offset + i] = b } }
    func octal(_ v: Int, _ width: Int) -> String { String(repeating: "0", count: max(0, width - 1 - String(v, radix: 8).count)) + String(v, radix: 8) }
    put(name, 0)
    put(octal(mode, 8), 100)
    put(octal(0, 8), 108)
    put(octal(0, 8), 116)
    put(octal(size, 12), 124)
    put(octal(0, 12), 136)
    put("        ", 148)
    h[156] = type.asciiValue!
    put(linkname, 157)
    put("ustar", 257)
    put("00", 263)
    let sum = h.reduce(0) { $0 + Int($1) }
    put(octal(sum, 7), 148)
    h[155] = 0x20
    return h
}

private func padded(_ data: [UInt8]) -> [UInt8] { data + [UInt8](repeating: 0, count: (512 - data.count % 512) % 512) }

func makeTar(_ members: [TarSpec], globalPax: [String: String]? = nil) -> [UInt8] {
    var out: [UInt8] = []
    if let globalPax {
        let records = globalPax.map { key, value -> String in
            let body = " \(key)=\(value)\n"
            var length = body.utf8.count + 1
            while String(length).count + body.utf8.count != length { length = String(length).count + body.utf8.count }
            return "\(length)\(body)"
        }.joined()
        out += tarHeader(name: "././@PaxHeader", size: records.utf8.count, mode: 0o644, type: "g") + padded(Array(records.utf8))
    }
    for m in members {
        out += tarHeader(name: m.name, size: m.data.count, mode: m.mode, type: m.type, linkname: m.linkname) + padded(m.data)
    }
    return out + [UInt8](repeating: 0, count: 1024)
}

/// gzip with stored (uncompressed) deflate blocks.
func gzip(_ data: [UInt8]) -> [UInt8] {
    var out: [UInt8] = [0x1F, 0x8B, 8, 0, 0, 0, 0, 0, 0, 0xFF]
    var i = 0
    repeat {
        let chunk = Array(data[i..<min(i + 65_535, data.count)])
        i += chunk.count
        out += [i >= data.count ? 1 : 0] + le16(chunk.count) + le16(~chunk.count & 0xFFFF) + chunk
    } while i < data.count
    return out + le32(Int(crc32(data))) + le32(data.count & 0xFFFF_FFFF)
}

private func mode(_ path: String) -> mode_t? { FileOps.mode(path) }

private func readFile(_ path: String) -> String? { try? String(contentsOfFile: path, encoding: .utf8) }

private func onlyFilesAndDirs(_ root: String) -> Bool {
    guard let enumerator = FileManager.default.enumerator(atPath: root) else { return true }
    while let rel = enumerator.nextObject() as? String {
        guard let st = FileOps.lstatInfo(root + "/" + rel) else { continue }
        let kind = st.st_mode & S_IFMT
        if kind != S_IFREG && kind != S_IFDIR { return false }
    }
    return true
}

@Suite struct SkillsTests {
    let tmp = ToolsTempDir()

    private func write(_ bytes: [UInt8], _ name: String = "skill.archive") throws -> String {
        let path = tmp.join(name)
        try Data(bytes).write(to: URL(fileURLWithPath: path))
        return path
    }

    private func makeZipArchive(_ entries: [(String, String)]) -> [UInt8] { makeZip(entries.map { ZipSpec.named($0.0, $0.1) }) }
    private func makeTarGz(_ entries: [(String, String)]) -> [UInt8] { gzip(makeTar(entries.map { TarSpec.file($0.0, $0.1) })) }

    @Test func inflateDecodesFixedAndDynamicHuffmanBlocks() throws {
        // Raw deflate streams from `zlib.compressobj(9, zlib.DEFLATED, -15)`: a fixed-Huffman block and a
        // dynamic-Huffman one.
        var consumed = 0
        let fixed: [UInt8] = [
            0xCB, 0x48, 0xCD, 0xC9, 0xC9, 0x57, 0xC8, 0x40, 0x27, 0x01,
        ]
        #expect(try Inflate.inflate(fixed, consumed: &consumed) == Array("hello hello hello hello".utf8))
        #expect(consumed == fixed.count)
        let dynamic: [UInt8] = [
            0x1D, 0x8F, 0xBB, 0x11, 0x44, 0x31, 0x08, 0x03, 0x73, 0xAA, 0xA0, 0x35, 0x0C, 0xE6, 0x67, 0x6C,
            0xE8, 0x3F, 0xBA, 0x37, 0x17, 0x4B, 0xB3, 0xD2, 0x6E, 0x0E, 0xE9, 0xD7, 0x65, 0xD2, 0x54, 0x97,
            0x5E, 0xB8, 0x20, 0x11, 0x01, 0x95, 0x5D, 0x1A, 0x7F, 0x0D, 0x7E, 0xDC, 0x5F, 0xD2, 0x05, 0xD1,
            0x14, 0x9C, 0x3B, 0x96, 0xD9, 0x53, 0xAB, 0xBD, 0xAE, 0x1E, 0x38, 0xFC, 0x46, 0x74, 0xEA, 0x34,
            0xF5, 0xCA, 0x52, 0x1D, 0x27, 0x03, 0xF0, 0x9A, 0x73, 0x5E, 0x7C, 0x9C, 0xD9, 0x03, 0x76, 0x57,
            0x1F, 0xB0, 0xB9, 0x7D, 0xEE, 0x21, 0x00, 0x7C, 0xE4, 0x0A, 0xCA, 0x10, 0x8B, 0x99, 0x1E, 0x85,
            0x87, 0xE8, 0x49, 0x56, 0x8D, 0xD1, 0xC8, 0x87, 0xDD, 0x42, 0x59, 0x78, 0x2D, 0x24, 0xE6, 0x7B,
            0xE2, 0x54, 0x7B, 0xE9, 0x9B, 0x0B, 0x3E, 0xCF, 0x87, 0xBE, 0x68, 0xE5, 0xB6, 0x95, 0xCC, 0x99,
            0x7A, 0x63, 0x13, 0x2C, 0x7B, 0x3A, 0xAB, 0xEC, 0x88, 0x5D, 0x6B, 0xA9, 0x9C, 0x26, 0xAC, 0x24,
            0x35, 0xDC, 0x7F, 0x50, 0xC1, 0x81, 0x4F, 0x87, 0x17, 0x6F, 0x55, 0xB0, 0xC0, 0x89, 0x83, 0x28,
            0xE9, 0xBD, 0x41, 0x70, 0x5D, 0xAE, 0xBD, 0x51, 0x8A, 0xBF, 0x4A, 0x9C, 0x04, 0x79, 0x21, 0x2B,
            0x89, 0xF8, 0xCA, 0x32, 0xBF, 0x2A, 0x4F, 0x5D, 0xE5, 0x16, 0x24, 0x44, 0xA3, 0x18, 0x2E, 0xA2,
            0xC4, 0x57, 0x58, 0xCC, 0xF8, 0x24, 0x0C, 0xFA, 0xC4, 0xC7, 0x4D, 0xF3, 0xC3, 0xC1, 0x8F, 0xD1,
            0x2B, 0x17, 0x2A, 0xA6, 0xA3, 0x00, 0xBB, 0x93, 0x17, 0x07, 0x7C, 0xBE, 0x94, 0xA7, 0x7B, 0xCB,
            0x20, 0x8F, 0xEA, 0xB7, 0x99, 0x32, 0x9F, 0xCB, 0x86, 0x85, 0x60, 0x3F,
        ]
        let expected = "ecidonolgdoalmanihd aaa\nalgmaphno\nhkhhnjam\ndfjd pmpgjjoplbohlmfk\nkcnpdfplkoaobjlffphag\n\nhlpkkni\nalpep\ngmbok\ngpmokmka\n\n nahf\nfc\nibccanaihidfkjcffipfijn oodajl mgidipgmahalebfnpm\nhpnhpal mbjegbjccjjfmiea\nbgnfpblgkdgmgodljpoa ljafg e mgidl\nk\no\nhcbceff\ngi pik  djhoe\nd bmclee dlc\nhcikj\ndnidbjaacmdbghmfdnfhfdml\nj\nio dg baaj nl lcc ndig\nokif\ngjghkcicnc hljb f jh d\nchhahlci\nccaajkooedp cpffee jdpjege\nb \ng"
        #expect(try String(decoding: Inflate.inflate(dynamic, consumed: &consumed), as: UTF8.self) == expected)
        #expect(try Inflate.gunzip(gzip(Array(expected.utf8))) == Array(expected.utf8))
    }

    @Test func archiveTopDirDetection() {
        #expect(archiveTopDir(["pdf/SKILL.md", "pdf/scripts/x.py"]) == "pdf")
        #expect(archiveTopDir(["pdf/SKILL.md"]) == "pdf")
        #expect(archiveTopDir(["SKILL.md", "scripts/x.py"]) == "")
        #expect(archiveTopDir(["a/x", "b/y"]) == "")
        #expect(archiveTopDir(["pdf/"]) == "")
        #expect(archiveTopDir([]) == "")
    }

    @Test func stripTopRemovesTheWrapper() {
        #expect(stripTop("pdf/SKILL.md", "pdf") == "SKILL.md")
        #expect(stripTop("pdf/scripts/x.py", "pdf") == "scripts/x.py")
        #expect(stripTop("pdf", "pdf") == "")
        #expect(stripTop("SKILL.md", "") == "SKILL.md")
        #expect(stripTop("other/x", "pdf") == "other/x")
    }

    @Test(arguments: ["zip", "targz"])
    func extractStripsSkillWrapperDir(format: String) throws {
        let entries = [("pdf/SKILL.md", "# PDF"), ("pdf/scripts/run.py", "print(1)")]
        let archive = try write(format == "zip" ? makeZipArchive(entries) : makeTarGz(entries))
        let dest = tmp.join("skills", "pdf")
        try extractSkillArchive(archive, dest)
        #expect(readFile(dest + "/SKILL.md") == "# PDF")
        #expect(readFile(dest + "/scripts/run.py") == "print(1)")
        #expect(!FileOps.exists(dest + "/pdf"), "wrapper dir was not stripped (doubling)")
    }

    @Test(arguments: ["zip", "targz"])
    func extractFlatArchiveUnchanged(format: String) throws {
        let entries = [("SKILL.md", "# flat"), ("scripts/run.py", "x")]
        let archive = try write(format == "zip" ? makeZipArchive(entries) : makeTarGz(entries))
        let dest = tmp.join("skills", "flat")
        try extractSkillArchive(archive, dest)
        #expect(readFile(dest + "/SKILL.md") == "# flat")
        #expect(readFile(dest + "/scripts/run.py") == "x")
    }

    @Test func extractRefusesZipSlip() throws {
        let archive = try write(makeZipArchive([("../escape.txt", "pwned")]), "evil.zip")
        #expect(throws: ValueError.self) { try extractSkillArchive(archive, tmp.join("skills", "x")) }
        #expect(!FileOps.exists(tmp.join("skills", "escape.txt")))
        #expect(!FileOps.exists(tmp.join("escape.txt")))
    }

    @Test(arguments: ["zip", "targz"])
    func preservesExecutableBit(format: String) throws {
        // `test_zip_preserves_executable_bit`, `test_tar_preserves_executable_bit`.
        let bytes = format == "zip"
            ? makeZip([.mode("scripts/run.sh", "#!/bin/sh\necho hi\n", 0o755), .mode("SKILL.md", "# doc", 0o644)])
            : gzip(makeTar([.file("scripts/run.sh", "#!/bin/sh\necho hi\n", mode: 0o755), .file("SKILL.md", "# doc", mode: 0o644)]))
        let dest = tmp.join("skills", "x")
        try extractSkillArchive(try write(bytes), dest)
        #expect(mode(dest + "/scripts/run.sh") == 0o755)
        #expect(mode(dest + "/SKILL.md") == 0o644)
    }

    @Test func zipWithoutUnixAttrsIsNotExecutable() throws {
        let dest = tmp.join("skills", "x")
        try extractSkillArchive(try write(makeZipArchive([("SKILL.md", "# doc"), ("scripts/run.sh", "echo hi")])), dest)
        #expect(mode(dest + "/SKILL.md") == 0o644)
        #expect(mode(dest + "/scripts/run.sh") == 0o644)
    }

    @Test(arguments: ["zip", "targz"])
    func extractDropsSetuidSetgidSticky(format: String) throws {
        let bytes = format == "zip"
            ? makeZip([.mode("scripts/run.sh", "#!/bin/sh\n", 0o7755), .mode("SKILL.md", "# doc", 0o4644)])
            : gzip(makeTar([.file("scripts/run.sh", "#!/bin/sh\n", mode: 0o7755), .file("SKILL.md", "# doc", mode: 0o4644)]))
        let dest = tmp.join("skills", "x")
        try extractSkillArchive(try write(bytes), dest)
        #expect(mode(dest + "/scripts/run.sh") == 0o755)
        #expect(mode(dest + "/SKILL.md") == 0o644)
    }

    @Test func tarSpecialMembersAreSkipped() throws {
        let archive = try write(gzip(makeTar([
            .file("pdf/SKILL.md", "# PDF"), .file("pdf/scripts/run.sh", "#!/bin/sh\n", mode: 0o755),
            TarSpec(name: "pdf/old", data: Array("v7".utf8), type: "\0"),
            .special("pdf/abs", "2", "/etc/passwd"), .special("pdf/rel", "2", "SKILL.md"), .special("pdf/hl", "1", "pdf/SKILL.md"),
            .special("pdf/fifo", "6"), .special("pdf/dev", "3"),
        ])), "skill.tar.gz")
        let dest = tmp.join("skills", "pdf")
        try extractSkillArchive(archive, dest)
        #expect(readFile(dest + "/SKILL.md") == "# PDF")
        #expect(readFile(dest + "/old") == "v7")
        #expect(mode(dest + "/scripts/run.sh") == 0o755)
        for name in ["abs", "rel", "hl", "fifo", "dev", "pdf"] { #expect(FileOps.lstatInfo(dest + "/" + name) == nil, "\(name)") }
        #expect(onlyFilesAndDirs(dest))
        #expect(try FileOps.listDirectory(tmp.path).sorted() == ["skill.tar.gz", "skills"])
        #expect(try FileOps.listDirectory(tmp.join("skills")) == ["pdf"])
    }

    @Test func zipUnixSpecialEntriesAreSkippedNotWrittenAsFiles() throws {
        let dest = tmp.join("skills", "pdf")
        try extractSkillArchive(try write(makeZip([
            .mode("pdf/SKILL.md", "# PDF", 0o644), .mode("pdf/lnk", "/etc/passwd", Int(S_IFLNK) | 0o777),
            .mode("pdf/fifo", "", Int(S_IFIFO) | 0o644),
        ])), dest)
        #expect(readFile(dest + "/SKILL.md") == "# PDF")
        #expect(FileOps.lstatInfo(dest + "/lnk") == nil)
        #expect(FileOps.lstatInfo(dest + "/fifo") == nil)
        #expect(onlyFilesAndDirs(dest))
    }

    @Test func zipNonUnixHostTypeBitsArePlainData() throws {
        let dest = tmp.join("skills", "pdf")
        try extractSkillArchive(try write(makeZip([
            .mode("pdf/SKILL.md", "# PDF", 0o644, createSystem: 0), .mode("pdf/lnk", "/etc/passwd", Int(S_IFLNK) | 0o777, createSystem: 0),
        ])), dest)
        #expect(FileOps.isFile(dest + "/lnk") && !FileOps.isSymlink(dest + "/lnk"))
        #expect(readFile(dest + "/lnk") == "/etc/passwd")
    }

    @Test func tarTopLevelSpecialDoesNotDefeatWrapperStripping() throws {
        let dest = tmp.join("skills", "pdf")
        try extractSkillArchive(try write(gzip(makeTar([.special("link", "2", "/tmp"), .file("pdf/SKILL.md", "# PDF")]))), dest)
        #expect(readFile(dest + "/SKILL.md") == "# PDF")
        #expect(!FileOps.exists(dest + "/pdf"))
        #expect(FileOps.lstatInfo(dest + "/link") == nil)
    }

    @Test func tarPaxGlobalHeaderIsNotExtracted() throws {
        let dest = tmp.join("skills", "pdf")
        try extractSkillArchive(try write(makeTar([.file("pdf/SKILL.md", "# PDF")], globalPax: ["comment": "0123abcd"]), "skill.tar"), dest)
        #expect(try FileOps.listDirectory(dest).sorted() == ["SKILL.md"])
    }

    @Test func zipEntriesWithoutTypeBitsAreRegularFiles() throws {
        let dest = tmp.join("skills", "pdf")
        try extractSkillArchive(try write(makeZip([.mode("pdf/scripts/run.sh", "#!/bin/sh\n", 0o755), .named("pdf/SKILL.md", "# PDF")])), dest)
        #expect(readFile(dest + "/SKILL.md") == "# PDF")
        #expect(mode(dest + "/scripts/run.sh") == 0o755)
    }

    @Test func zipUnixDirectoryBitsWithoutTrailingSlashMakeADirectory() throws {
        let dest = tmp.join("skills", "pdf")
        try extractSkillArchive(try write(makeZip([.mode("pdf/SKILL.md", "# PDF", 0o644), .mode("pdf/sub", "", Int(S_IFDIR) | 0o755)])), dest)
        #expect(FileOps.isDirectory(dest + "/sub"))
    }

    @Test func tarPathScreenAppliesToSkippedMembers() throws {
        try FileManager.default.createDirectory(atPath: tmp.join("sub"), withIntermediateDirectories: true)
        let archive = tmp.join("sub", "skill.tar.gz")
        try Data(gzip(makeTar([.special("../x", "2", "/etc/passwd"), .file("pdf/SKILL.md", "# PDF")]))).write(to: URL(fileURLWithPath: archive))
        let dest = tmp.join("sub", "skills", "pdf")
        #expect(throws: ValueError.self) { try extractSkillArchive(archive, dest) }
        #expect(!FileOps.exists(dest + "/SKILL.md"))
        #expect(FileOps.lstatInfo(tmp.join("sub", "skills", "x")) == nil)
        #expect(FileOps.lstatInfo(tmp.join("sub", "x")) == nil)
        #expect(FileOps.lstatInfo(tmp.join("x")) == nil)
    }

    @Test func downloadRetrievesByConfiguredVersionAndDownloadsByReturnedID() async throws {
        let archive = makeTarGz([("pdf/SKILL.md", "# PDF")])
        let paths = ToolsBox<[String]>([])
        let transport = MockTransport { request in
            paths.mutate { $0.append(request.url.path) }
            if request.url.path.hasSuffix("/content") {
                return HTTPResponse(statusCode: 200, headers: ["content-type": "application/octet-stream"], body: Data(archive), request: request)
            }
            return HTTPResponse.json([
                "id": "skillver_123", "created_at": "2026-01-01T00:00:00Z", "description": "d", "name": "pdf",
                "skill_id": "skill_01", "type": "skill_version",
            ], for: request)
        }
        let client = try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, maxRetries: 0, transport: transport, environment: [:])
        let work = tmp.join("work")
        try FileManager.default.createDirectory(atPath: work, withIntermediateDirectories: true)
        let created = try await downloadSessionSkills(client, workdir: work, skills: [(skillID: "skill_01", version: "latest")])
        #expect(paths.value == ["/v1/skills/skill_01/versions/latest", "/v1/skills/skill_01/versions/skillver_123/content"])
        #expect(created == [FileOps.resolve(work + "/skills/pdf")])
        #expect(readFile(work + "/skills/pdf/SKILL.md") == "# PDF")
        #expect(try FileOps.listDirectory(work + "/skills") == ["pdf"], "the temporary archive is removed")
    }
}
