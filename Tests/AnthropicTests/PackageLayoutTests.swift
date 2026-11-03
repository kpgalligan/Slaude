import Foundation
import Testing

/// Guards the package's file layout.
///
/// SwiftPM names a target's object files after its sources' basenames, so on a case-insensitive volume (macOS's
/// default APFS) two files in one target whose names differ only in case, such as `Generated/Types/diagnostics.swift`
/// and a hand-written `Lib/Tools/Diagnostics.swift`, compile to one `.o`: one of them silently drops out of the link
/// and every executable or test bundle that needs its symbols fails to link. swiftc rejects only exact duplicates.
/// `Tools/codegen` refuses to write a generated file with such a name; this suite checks the whole tree.
@Suite struct PackageLayoutTests {
    /// The groups of paths whose basenames are equal ignoring case: each group sorted, the groups in path order.
    static func caseInsensitiveCollisions(_ paths: [String]) -> [[String]] {
        let groups = Dictionary(grouping: paths) { ($0 as NSString).lastPathComponent.lowercased() }
        return groups.values.filter { $0.count > 1 }.map { $0.sorted() }.sorted { $0[0] < $1[0] }
    }

    /// The package root: the nearest directory above this file that holds `Package.swift`.
    static func packageRoot() throws -> URL {
        var directory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        while !FileManager.default.fileExists(atPath: directory.appendingPathComponent("Package.swift").path) {
            let parent = directory.deletingLastPathComponent()
            try #require(parent.path != directory.path, "no Package.swift above \(#filePath)")
            directory = parent
        }
        return directory
    }

    /// Every target directory (each folder directly under `Sources` and `Tests`) with the `.swift` files in it,
    /// as paths relative to the target.
    static func targets() throws -> [(name: String, files: [String])] {
        let root = try packageRoot()
        let fileManager = FileManager.default
        var targets: [(name: String, files: [String])] = []
        for group in ["Sources", "Tests"] {
            let groupDirectory = root.appendingPathComponent(group)
            for name in try fileManager.contentsOfDirectory(atPath: groupDirectory.path).sorted() {
                var isDirectory: ObjCBool = false
                let directory = groupDirectory.appendingPathComponent(name)
                guard !name.hasPrefix("."), fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory),
                      isDirectory.boolValue
                else { continue }
                let files = (fileManager.enumerator(atPath: directory.path)?.allObjects as? [String] ?? [])
                    .filter { $0.hasSuffix(".swift") }
                targets.append((name: "\(group)/\(name)", files: files))
            }
        }
        return targets
    }

    @Test func findsNamesThatDifferOnlyInCase() {
        let paths = ["Lib/Tools/Files.swift", "Generated/Resources/files.swift", "Lib/Other.swift"]
        #expect(Self.caseInsensitiveCollisions(paths) == [["Generated/Resources/files.swift", "Lib/Tools/Files.swift"]])
        #expect(Self.caseInsensitiveCollisions(["A/Same.swift", "B/Other.swift"]) == [])
    }

    @Test func noTargetHoldsSwiftFileNamesThatDifferOnlyInCase() throws {
        let targets = try Self.targets()
        #expect(Set(targets.map(\.name)).isSuperset(of: ["Sources/Anthropic", "Tests/AnthropicTests"]))
        for target in targets {
            #expect(!target.files.isEmpty, "\(target.name) holds no Swift files")
            for group in Self.caseInsensitiveCollisions(target.files) {
                Issue.record(
                    """
                    \(target.name): \(group.joined(separator: " and ")) differ only in letter case, so SwiftPM \
                    compiles them to one object file on a case-insensitive volume; rename the hand-written one
                    """)
            }
        }
    }
}
