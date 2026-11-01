// Readers for the archive formats skill bundles ship in (zip, tar, tar.gz), standing in for Python's `zipfile`,
// `tarfile` and `zlib`: Foundation has no decompression on Linux.

import Foundation

struct ArchiveError: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}

/// A raw DEFLATE (RFC 1951) decoder.
enum Inflate {
    private struct BitReader {
        let bytes: [UInt8]
        var position = 0
        var bitBuffer: UInt32 = 0
        var bitCount = 0

        mutating func bits(_ n: Int) throws -> Int {
            while bitCount < n {
                guard position < bytes.count else { throw ArchiveError("deflate stream ends early") }
                bitBuffer |= UInt32(bytes[position]) << UInt32(bitCount)
                position += 1
                bitCount += 8
            }
            let value = Int(bitBuffer & ((1 << UInt32(n)) - 1))
            bitBuffer >>= UInt32(n)
            bitCount -= n
            return value
        }

        mutating func alignToByte() {
            bitBuffer = 0
            bitCount = 0
        }
    }

    /// Canonical Huffman decoding table: counts per length and symbols in code order.
    private struct Huffman {
        var counts = [Int](repeating: 0, count: 16)
        var symbols: [Int] = []

        init(lengths: [Int]) {
            for l in lengths { counts[l] += 1 }
            counts[0] = 0
            var offsets = [Int](repeating: 0, count: 16)
            for i in 1..<16 { offsets[i] = offsets[i - 1] + counts[i - 1] }
            symbols = [Int](repeating: 0, count: lengths.count)
            for (symbol, l) in lengths.enumerated() where l != 0 {
                symbols[offsets[l]] = symbol
                offsets[l] += 1
            }
        }

        func decode(_ reader: inout BitReader) throws -> Int {
            var code = 0, first = 0, index = 0
            for length in 1..<16 {
                code |= try reader.bits(1)
                let count = counts[length]
                if code - count < first { return symbols[index + (code - first)] }
                index += count
                first += count
                first <<= 1
                code <<= 1
            }
            throw ArchiveError("invalid Huffman code")
        }
    }

    private static let lengthBase = [3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258]
    private static let lengthExtra = [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0]
    private static let distBase = [1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537, 2049, 3073,
                                   4097, 6145, 8193, 12289, 16385, 24577]
    private static let distExtra = [0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13]

    /// Inflates `data`; `consumed` is how many input bytes the stream used.
    static func inflate(_ data: [UInt8], consumed: inout Int) throws -> [UInt8] {
        var reader = BitReader(bytes: data)
        var out: [UInt8] = []
        var last = false
        while !last {
            last = try reader.bits(1) == 1
            switch try reader.bits(2) {
            case 0:
                reader.alignToByte()
                guard reader.position + 4 <= data.count else { throw ArchiveError("truncated stored block") }
                let len = Int(data[reader.position]) | Int(data[reader.position + 1]) << 8
                reader.position += 4
                guard reader.position + len <= data.count else { throw ArchiveError("truncated stored block") }
                out += data[reader.position..<reader.position + len]
                reader.position += len
            case 1:
                var lengths = [Int](repeating: 8, count: 288)
                for i in 144..<256 { lengths[i] = 9 }
                for i in 256..<280 { lengths[i] = 7 }
                try inflateBlock(&reader, &out, Huffman(lengths: lengths), Huffman(lengths: [Int](repeating: 5, count: 30)))
            case 2:
                let hlit = try reader.bits(5) + 257, hdist = try reader.bits(5) + 1, hclen = try reader.bits(4) + 4
                let order = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]
                var codeLengths = [Int](repeating: 0, count: 19)
                for i in 0..<hclen { codeLengths[order[i]] = try reader.bits(3) }
                let codeHuffman = Huffman(lengths: codeLengths)
                var lengths: [Int] = []
                while lengths.count < hlit + hdist {
                    let symbol = try codeHuffman.decode(&reader)
                    switch symbol {
                    case 0..<16: lengths.append(symbol)
                    case 16:
                        guard let prev = lengths.last else { throw ArchiveError("repeat with no previous length") }
                        lengths += Array(repeating: prev, count: 3 + (try reader.bits(2)))
                    case 17: lengths += Array(repeating: 0, count: 3 + (try reader.bits(3)))
                    default: lengths += Array(repeating: 0, count: 11 + (try reader.bits(7)))
                    }
                }
                try inflateBlock(&reader, &out, Huffman(lengths: Array(lengths[0..<hlit])),
                                 Huffman(lengths: Array(lengths[hlit..<hlit + hdist])))
            default:
                throw ArchiveError("invalid deflate block type")
            }
        }
        consumed = reader.position
        return out
    }

    private static func inflateBlock(_ reader: inout BitReader, _ out: inout [UInt8], _ lit: Huffman, _ dist: Huffman) throws {
        while true {
            let symbol = try lit.decode(&reader)
            if symbol < 256 {
                out.append(UInt8(symbol))
            } else if symbol == 256 {
                return
            } else {
                let i = symbol - 257
                guard i < lengthBase.count else { throw ArchiveError("invalid length symbol") }
                let length = lengthBase[i] + (try reader.bits(lengthExtra[i]))
                let d = try dist.decode(&reader)
                guard d < distBase.count else { throw ArchiveError("invalid distance symbol") }
                let distance = distBase[d] + (try reader.bits(distExtra[d]))
                guard distance <= out.count else { throw ArchiveError("distance too far back") }
                let start = out.count - distance
                for k in 0..<length { out.append(out[start + k]) }
            }
        }
    }

    /// Decompresses a gzip (RFC 1952) stream, all members.
    static func gunzip(_ data: [UInt8]) throws -> [UInt8] {
        var out: [UInt8] = []
        var p = 0
        while p + 10 <= data.count && data[p] == 0x1F && data[p + 1] == 0x8B {
            guard data[p + 2] == 8 else { throw ArchiveError("unsupported gzip compression method") }
            let flags = data[p + 3]
            p += 10
            if flags & 0x04 != 0 {
                guard p + 2 <= data.count else { throw ArchiveError("truncated gzip header") }
                p += 2 + (Int(data[p]) | Int(data[p + 1]) << 8)
            }
            if flags & 0x08 != 0 { while p < data.count && data[p] != 0 { p += 1 }; p += 1 }
            if flags & 0x10 != 0 { while p < data.count && data[p] != 0 { p += 1 }; p += 1 }
            if flags & 0x02 != 0 { p += 2 }
            guard p <= data.count else { throw ArchiveError("truncated gzip header") }
            var consumed = 0
            out += try inflate(Array(data[p...]), consumed: &consumed)
            p += consumed + 8
        }
        return out
    }
}

/// One entry of a zip archive (`zipfile.ZipInfo`).
struct ZipEntry {
    let filename: String
    let createSystem: Int
    let externalAttr: UInt32
    let method: Int
    let compressedSize: Int
    let headerOffset: Int

    var isDirectoryName: Bool { filename.hasSuffix("/") }
}

/// A zip archive read from memory (`zipfile.ZipFile`).
struct ZipArchive {
    let bytes: [UInt8]
    let entries: [ZipEntry]

    private static func u16(_ b: [UInt8], _ i: Int) -> Int { Int(b[i]) | Int(b[i + 1]) << 8 }
    private static func u32(_ b: [UInt8], _ i: Int) -> Int { u16(b, i) | u16(b, i + 2) << 16 }

    /// The offset of the end-of-central-directory record, if `bytes` is a zip (`zipfile.is_zipfile`).
    static func endOfCentralDirectory(_ bytes: [UInt8]) -> Int? {
        guard bytes.count >= 22 else { return nil }
        var i = bytes.count - 22
        let lowest = max(0, bytes.count - 22 - 65_535)
        while i >= lowest {
            if bytes[i] == 0x50 && bytes[i + 1] == 0x4B && bytes[i + 2] == 0x05 && bytes[i + 3] == 0x06 { return i }
            i -= 1
        }
        return nil
    }

    init(_ bytes: [UInt8]) throws {
        guard let eocd = ZipArchive.endOfCentralDirectory(bytes) else { throw ArchiveError("not a zip file") }
        self.bytes = bytes
        let count = ZipArchive.u16(bytes, eocd + 10)
        var p = ZipArchive.u32(bytes, eocd + 16)
        var entries: [ZipEntry] = []
        for _ in 0..<count {
            guard p + 46 <= bytes.count, ZipArchive.u32(bytes, p) == 0x0201_4B50 else { throw ArchiveError("bad central directory") }
            let madeBy = ZipArchive.u16(bytes, p + 4)
            let method = ZipArchive.u16(bytes, p + 10)
            let compressed = ZipArchive.u32(bytes, p + 20)
            let nameLength = ZipArchive.u16(bytes, p + 28), extraLength = ZipArchive.u16(bytes, p + 30)
            let commentLength = ZipArchive.u16(bytes, p + 32)
            let external = UInt32(ZipArchive.u32(bytes, p + 38))
            let offset = ZipArchive.u32(bytes, p + 42)
            guard p + 46 + nameLength <= bytes.count else { throw ArchiveError("bad central directory") }
            let name = String(decoding: bytes[(p + 46)..<(p + 46 + nameLength)], as: UTF8.self)
            entries.append(ZipEntry(filename: name, createSystem: madeBy >> 8, externalAttr: external, method: method,
                                    compressedSize: compressed, headerOffset: offset))
            p += 46 + nameLength + extraLength + commentLength
        }
        self.entries = entries
    }

    /// The uncompressed contents of `entry`.
    func read(_ entry: ZipEntry) throws -> [UInt8] {
        let h = entry.headerOffset
        guard h + 30 <= bytes.count, ZipArchive.u32(bytes, h) == 0x0403_4B50 else { throw ArchiveError("bad local header") }
        let start = h + 30 + ZipArchive.u16(bytes, h + 26) + ZipArchive.u16(bytes, h + 28)
        guard start + entry.compressedSize <= bytes.count else { throw ArchiveError("truncated zip member") }
        let raw = Array(bytes[start..<start + entry.compressedSize])
        switch entry.method {
        case 0: return raw
        case 8:
            var consumed = 0
            return try Inflate.inflate(raw, consumed: &consumed)
        default: throw ArchiveError("unsupported zip compression method \(entry.method)")
        }
    }
}

/// One member of a tar archive (`tarfile.TarInfo`).
struct TarMember {
    let name: String
    let type: UInt8
    let mode: Int
    let data: ArraySlice<UInt8>

    var isRegular: Bool { type == UInt8(ascii: "0") || type == 0 || type == UInt8(ascii: "7") }
    var isDirectory: Bool { type == UInt8(ascii: "5") }
}

/// A tar archive (plain or gzip) read from memory (`tarfile.open(mode="r:*")`): every member, pax and GNU long
/// names applied, global pax headers dropped.
func readTarMembers(_ raw: [UInt8]) throws -> [TarMember] {
    var bytes = raw
    if bytes.count >= 2 && bytes[0] == 0x1F && bytes[1] == 0x8B { bytes = try Inflate.gunzip(bytes) }
    if bytes.count >= 3 && bytes[0] == 0x42 && bytes[1] == 0x5A && bytes[2] == 0x68 { throw ArchiveError("bzip2 archives are not supported") }
    if bytes.count >= 6 && bytes[0] == 0xFD && bytes[1] == 0x37 { throw ArchiveError("xz archives are not supported") }
    func field(_ header: ArraySlice<UInt8>, _ offset: Int, _ length: Int) -> String {
        let slice = header[(header.startIndex + offset)..<(header.startIndex + offset + length)]
        let end = slice.firstIndex(of: 0) ?? slice.endIndex
        return String(decoding: slice[slice.startIndex..<end], as: UTF8.self)
    }
    func octal(_ s: String) -> Int { Int(s.trimmingCharacters(in: CharacterSet(charactersIn: " \0")), radix: 8) ?? 0 }

    var members: [TarMember] = []
    var p = 0
    var pendingName: String?
    while p + 512 <= bytes.count {
        let header = bytes[p..<p + 512]
        if header.allSatisfy({ $0 == 0 }) { break }
        let size = octal(field(header, 124, 12))
        let type = header[header.startIndex + 156]
        let dataStart = p + 512
        guard dataStart + size <= bytes.count else { throw ArchiveError("truncated tar member") }
        let data = bytes[dataStart..<dataStart + size]
        p = dataStart + (size + 511) / 512 * 512
        switch type {
        case UInt8(ascii: "x"):
            // A pax extended header: `"<len> key=value\n"` records; `path` renames the next member.
            for record in String(decoding: data, as: UTF8.self).split(separator: "\n") {
                if let space = record.firstIndex(of: " "), let eq = record.firstIndex(of: "="), record[record.index(after: space)..<eq] == "path" {
                    pendingName = String(record[record.index(after: eq)...])
                }
            }
            continue
        case UInt8(ascii: "g"):
            continue
        case UInt8(ascii: "L"):
            pendingName = String(decoding: data.prefix { $0 != 0 }, as: UTF8.self)
            continue
        default: break
        }
        var name = field(header, 0, 100)
        if field(header, 257, 6).hasPrefix("ustar") {
            let prefix = field(header, 345, 155)
            if !prefix.isEmpty { name = prefix + "/" + name }
        }
        if let pending = pendingName {
            name = pending
            pendingName = nil
        }
        var memberType = type
        if memberType == 0 && name.hasSuffix("/") { memberType = UInt8(ascii: "5") }
        if name.hasSuffix("/") && name.count > 1 { name.removeLast() }
        members.append(TarMember(name: name, type: memberType, mode: octal(field(header, 100, 8)), data: data))
    }
    return members
}
