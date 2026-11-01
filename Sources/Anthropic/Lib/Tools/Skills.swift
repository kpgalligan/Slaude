// Port of `anthropic/lib/tools/_skills.py`: skill download and archive extraction.
//
// Fetching a session agent's skills and safely unpacking a (possibly third-party) archive: members that would
// escape the destination are refused (zip-slip / tar-slip), members that are not regular files or directories are
// skipped, and modes collapse to 0755 / 0644.

import Foundation

#if canImport(Glibc)
    import Glibc
#elseif canImport(Darwin)
    import Darwin
#endif

/// Skill dirs hold downloaded, possibly third-party content: owner-only.
let SKILL_DIR_MODE: mode_t = 0o700

let skillsLog = ToolLogger(name: "anthropic.lib.tools.agent_toolset")

/// `true` if `child` is `root` or a path inside it (both resolved).
func isWithin(_ child: String, _ root: String) -> Bool {
    child == root || child.hasPrefix(root == "/" ? "/" : root + "/")
}

/// `name` as a confined relative path, or throws on path traversal (`_safe_member_name`). Strips `.` components;
/// rejects absolute paths and any `..` component. Returns `""` for entries that resolve to nothing.
func safeMemberName(_ name: String) throws -> String {
    let normalized = name.replacingOccurrences(of: "\\", with: "/")
    if normalized.hasPrefix("/") { throw ValueError("refusing archive member with absolute path \(pythonStringRepr(name))") }
    let parts = normalized.split(separator: "/").map(String.init).filter { $0 != "." }
    if parts.contains("..") { throw ValueError("refusing archive member with '..' component: \(pythonStringRepr(name))") }
    return parts.joined(separator: "/")
}

/// The single top-level directory shared by every archive entry, or `""` (`_archive_top_dir`).
func archiveTopDir(_ names: [String]) -> String {
    var tops = Set<String>()
    var hasNested = false
    for name in names {
        let parts = name.split(separator: "/")
        guard let first = parts.first else { continue }
        tops.insert(String(first))
        if parts.count > 1 { hasNested = true }
    }
    return tops.count == 1 && hasNested ? tops.first! : ""
}

/// Screen every member name, then return the wrapper directory shared by the members that will be extracted.
func wrapperDir(_ allNames: [String], _ plainNames: [String]) throws -> String {
    for name in allNames { _ = try safeMemberName(name) }
    return archiveTopDir(try plainNames.map(safeMemberName).filter { !$0.isEmpty })
}

/// Drop the leading `top` component from `safe` (`_strip_top`).
func stripTop(_ safe: String, _ top: String) -> String {
    guard !top.isEmpty else { return safe }
    let parts = safe.split(separator: "/").map(String.init)
    if parts.first == top { return parts.dropFirst().joined(separator: "/") }
    return safe
}

/// An archive entry's mode reduced to 0755 if executable, 0644 otherwise (`_archive_file_mode`).
func archiveFileMode(_ sourceMode: Int) -> mode_t { sourceMode & 0o111 != 0 ? 0o755 : 0o644 }

private let ZIP_UNIX_HOSTS: Set<Int> = [3, 19]
private let SPECIAL_FILE_TYPES: Set<Int> = [Int(S_IFLNK), Int(S_IFCHR), Int(S_IFBLK), Int(S_IFIFO), Int(S_IFSOCK)]

private func zipUnixMode(_ entry: ZipEntry) -> Int? {
    ZIP_UNIX_HOSTS.contains(entry.createSystem) ? Int(entry.externalAttr >> 16) : nil
}

private func zipEntryIsSpecial(_ entry: ZipEntry) -> Bool {
    guard let mode = zipUnixMode(entry) else { return false }
    return SPECIAL_FILE_TYPES.contains(mode & Int(S_IFMT))
}

private func zipEntryIsDirectory(_ entry: ZipEntry) -> Bool {
    if entry.isDirectoryName { return true }
    guard let mode = zipUnixMode(entry) else { return false }
    return mode & Int(S_IFMT) == Int(S_IFDIR)
}

private func makeDirectories(_ path: String) throws {
    try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
}

private func writeMember(_ target: String, _ data: some Sequence<UInt8>, mode: mode_t) throws {
    try makeDirectories(FileOps.parent(target))
    try Data(data).write(to: URL(fileURLWithPath: target))
    chmod(target, mode)
}

/// Extract a skill download (a zip or tar archive, plain or gzip) into `dest` (`_extract_skill_archive`). The
/// single wrapper directory is stripped.
func extractSkillArchive(_ archivePath: String, _ dest: String) throws {
    if !FileOps.exists(dest) { try FileOps.secureMkdir(dest, mode: SKILL_DIR_MODE) }
    let root = FileOps.resolve(dest)
    let bytes = [UInt8](try FileOps.readBytes(archivePath))
    if ZipArchive.endOfCentralDirectory(bytes) != nil {
        let zip = try ZipArchive(bytes)
        let plain = zip.entries.filter { !zipEntryIsSpecial($0) }
        let top = try wrapperDir(zip.entries.map(\.filename), plain.map(\.filename))
        for entry in plain {
            let safe = stripTop(try safeMemberName(entry.filename), top)
            if safe.isEmpty { continue }
            let target = FileOps.resolve(root + "/" + safe)
            guard isWithin(target, root) else { throw ValueError("refusing to extract unsafe zip member \(pythonStringRepr(entry.filename))") }
            if zipEntryIsDirectory(entry) {
                try makeDirectories(target)
                continue
            }
            try writeMember(target, try zip.read(entry), mode: archiveFileMode(Int(entry.externalAttr >> 16)))
        }
        return
    }
    let all = try readTarMembers(bytes)
    let members = all.filter { $0.isRegular || $0.isDirectory }
    let top = try wrapperDir(all.map(\.name), members.map(\.name))
    for member in members {
        let safe = stripTop(try safeMemberName(member.name), top)
        if safe.isEmpty { continue }
        let target = FileOps.resolve(root + "/" + safe)
        guard isWithin(target, root) else { throw ValueError("refusing to extract unsafe tar member \(pythonStringRepr(member.name))") }
        if member.isDirectory {
            try makeDirectories(target)
            continue
        }
        try writeMember(target, member.data, mode: archiveFileMode(member.mode))
    }
}

/// Download the session agent's skills into `{workdir}/skills/<name>/` (`download_session_skills`).
///
/// For each of the session agent's skills, retrieves the configured version, downloads the archive of the version
/// it resolves to, and extracts it under a directory named after the skill (reduced to one safe path component). A
/// failure on one skill is logged and does not block the others.
///
/// - Returns: The skill directories that were created, so the caller can remove them.
public func downloadSessionSkills(_ client: Anthropic, workdir: String, session: BetaManagedAgentsSession) async throws -> [String] {
    let skills: [(skillID: String, version: String)] = session.agent.skills.map { skill in
        let raw = (try? JSONValue.from(skill)) ?? .null
        return (raw["skill_id"]?.stringValue ?? "", raw["version"]?.stringValue ?? "latest")
    }
    return try await downloadSessionSkills(client, workdir: workdir, skills: skills)
}

/// Download the given skills (`skill_id`, configured version) into `{workdir}/skills/<name>/`.
public func downloadSessionSkills(_ client: Anthropic, workdir: String, skills: [(skillID: String, version: String)]) async throws
    -> [String]
{
    let skillsRoot = FileOps.resolve((workdir as NSString).appendingPathComponent("skills"))
    var downloaded: [String] = []
    for (skillID, configuredVersion) in skills {
        do {
            let version = try await client.beta.skills.versions.retrieve(configuredVersion, skillID: skillID)
            var dirname = (version.name.trimmingCharacters(in: .whitespacesAndNewlines) as NSString).lastPathComponent
            if dirname.isEmpty || dirname == "." || dirname == ".." || version.name.hasSuffix("/") { dirname = skillID }
            let dest = FileOps.resolve(skillsRoot + "/" + dirname)
            guard isWithin(dest, skillsRoot) else {
                skillsLog.warning("skill name \(pythonStringRepr(version.name)) escapes the skills dir; skipping")
                continue
            }
            if FileOps.isSymlink(dest) { unlink(dest) }
            try? FileOps.removeTree(dest)
            try await downloadAndExtract(client, skillID: skillID, versionID: version.id, dest: dest)
            downloaded.append(dest)
            skillsLog.info("downloaded skill skill_id=\(skillID) version=\(version.id) -> \(dest)")
        } catch {
            skillsLog.warning("failed to download skill skill_id=\(skillID): \(error)")
        }
    }
    return downloaded
}

/// Stream the skill archive to a temp file, then extract it into `dest`.
private func downloadAndExtract(_ client: Anthropic, skillID: String, versionID: String, dest: String) async throws {
    let parent = FileOps.parent(dest)
    if !FileOps.exists(parent) { try FileOps.secureMkdir(parent, mode: SKILL_DIR_MODE) }
    let temp = parent + "/.skill-\(UUID().uuidString.lowercased()).archive"
    defer { unlink(temp) }
    let fd = open(temp, O_CREAT | O_EXCL | O_WRONLY, 0o600)
    if fd < 0 { throw ToolFileSystemError(code: errno, path: temp, operation: "open") }
    close(fd)
    try await client.beta.skills.versions.withStreamingResponse.download(versionID, skillID: skillID) { (response: APIResponse<BinaryResponse>) in
        let handle = try FileHandle(forWritingTo: URL(fileURLWithPath: temp))
        defer { try? handle.close() }
        for try await chunk in try await response.parse().iterBytes() { handle.write(chunk) }
    }
    try extractSkillArchive(temp, dest)
}
