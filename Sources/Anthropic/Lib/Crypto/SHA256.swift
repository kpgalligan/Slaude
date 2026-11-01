import Foundation

/// SHA-256 (FIPS 180-4), in pure Swift.
///
/// Foundation on Linux has no CryptoKit, so the SDK carries the few primitives it needs:
/// SigV4 request signing (AWS), webhook verification and RS256 JWTs (Google service accounts).
public struct SHA256Hasher: Sendable {
    public static let digestLength = 32
    public static let blockLength = 64

    private var state: [UInt32] = [
        0x6a09_e667, 0xbb67_ae85, 0x3c6e_f372, 0xa54f_f53a, 0x510e_527f, 0x9b05_688c, 0x1f83_d9ab, 0x5be0_cd19,
    ]
    private var buffer: [UInt8] = []
    private var length: UInt64 = 0

    private static let k: [UInt32] = [
        0x428a_2f98, 0x7137_4491, 0xb5c0_fbcf, 0xe9b5_dba5, 0x3956_c25b, 0x59f1_11f1, 0x923f_82a4, 0xab1c_5ed5,
        0xd807_aa98, 0x1283_5b01, 0x2431_85be, 0x550c_7dc3, 0x72be_5d74, 0x80de_b1fe, 0x9bdc_06a7, 0xc19b_f174,
        0xe49b_69c1, 0xefbe_4786, 0x0fc1_9dc6, 0x240c_a1cc, 0x2de9_2c6f, 0x4a74_84aa, 0x5cb0_a9dc, 0x76f9_88da,
        0x983e_5152, 0xa831_c66d, 0xb003_27c8, 0xbf59_7fc7, 0xc6e0_0bf3, 0xd5a7_9147, 0x06ca_6351, 0x1429_2967,
        0x27b7_0a85, 0x2e1b_2138, 0x4d2c_6dfc, 0x5338_0d13, 0x650a_7354, 0x766a_0abb, 0x81c2_c92e, 0x9272_2c85,
        0xa2bf_e8a1, 0xa81a_664b, 0xc24b_8b70, 0xc76c_51a3, 0xd192_e819, 0xd699_0624, 0xf40e_3585, 0x106a_a070,
        0x19a4_c116, 0x1e37_6c08, 0x2748_774c, 0x34b0_bcb5, 0x391c_0cb3, 0x4ed8_aa4a, 0x5b9c_ca4f, 0x682e_6ff3,
        0x748f_82ee, 0x78a5_636f, 0x84c8_7814, 0x8cc7_0208, 0x90be_fffa, 0xa450_6ceb, 0xbef9_a3f7, 0xc671_78f2,
    ]

    public init() {}

    public mutating func update<D: Sequence>(_ data: D) where D.Element == UInt8 {
        let bytes = Array(data)
        length &+= UInt64(bytes.count)
        var i = 0
        if !buffer.isEmpty {
            let take = min(SHA256Hasher.blockLength - buffer.count, bytes.count)
            buffer += bytes[0..<take]
            i = take
            if buffer.count == SHA256Hasher.blockLength {
                processBlock(buffer[...])
                buffer.removeAll(keepingCapacity: true)
            }
        }
        while bytes.count - i >= SHA256Hasher.blockLength {
            processBlock(bytes[i..<(i + SHA256Hasher.blockLength)])
            i += SHA256Hasher.blockLength
        }
        if i < bytes.count { buffer += bytes[i...] }
    }

    public mutating func update(_ string: String) { update(Array(string.utf8)) }

    public func finalize() -> [UInt8] {
        var copy = self
        let bitLength = copy.length &* 8
        var padding: [UInt8] = [0x80]
        let rem = (copy.buffer.count + 1) % 64
        padding += [UInt8](repeating: 0, count: rem <= 56 ? 56 - rem : 120 - rem)
        for i in (0..<8).reversed() { padding.append(UInt8(truncatingIfNeeded: bitLength >> (UInt64(i) * 8))) }
        let saved = copy.length
        copy.update(padding)
        copy.length = saved
        precondition(copy.buffer.isEmpty)
        var out = [UInt8]()
        out.reserveCapacity(32)
        for word in copy.state {
            out += [UInt8(word >> 24), UInt8((word >> 16) & 0xff), UInt8((word >> 8) & 0xff), UInt8(word & 0xff)]
        }
        return out
    }

    private mutating func processBlock(_ block: ArraySlice<UInt8>) {
        let o = block.startIndex
        var w = [UInt32](repeating: 0, count: 64)
        for i in 0..<16 {
            w[i] = UInt32(block[o + i * 4]) << 24 | UInt32(block[o + i * 4 + 1]) << 16 | UInt32(block[o + i * 4 + 2]) << 8 | UInt32(block[o + i * 4 + 3])
        }
        for i in 16..<64 {
            let s0 = rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ (w[i - 15] >> 3)
            let s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ (w[i - 2] >> 10)
            w[i] = w[i - 16] &+ s0 &+ w[i - 7] &+ s1
        }
        var a = state[0], b = state[1], c = state[2], d = state[3]
        var e = state[4], f = state[5], g = state[6], h = state[7]
        for i in 0..<64 {
            let s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25)
            let ch = (e & f) ^ (~e & g)
            let t1 = h &+ s1 &+ ch &+ SHA256Hasher.k[i] &+ w[i]
            let s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22)
            let maj = (a & b) ^ (a & c) ^ (b & c)
            let t2 = s0 &+ maj
            h = g; g = f; f = e; e = d &+ t1
            d = c; c = b; b = a; a = t1 &+ t2
        }
        state[0] &+= a; state[1] &+= b; state[2] &+= c; state[3] &+= d
        state[4] &+= e; state[5] &+= f; state[6] &+= g; state[7] &+= h
    }

    @inline(__always) private func rotr(_ x: UInt32, _ n: UInt32) -> UInt32 { (x >> n) | (x << (32 - n)) }

    /// The digest of `data`.
    public static func hash<D: Sequence>(_ data: D) -> [UInt8] where D.Element == UInt8 {
        var h = SHA256Hasher()
        h.update(data)
        return h.finalize()
    }

    public static func hash(_ string: String) -> [UInt8] { hash(Array(string.utf8)) }
}

/// HMAC (RFC 2104) over SHA-256.
public enum HMACSHA256 {
    public static func authenticationCode<K: Sequence, D: Sequence>(key: K, data: D) -> [UInt8]
        where K.Element == UInt8, D.Element == UInt8
    {
        var k = Array(key)
        if k.count > SHA256Hasher.blockLength { k = SHA256Hasher.hash(k) }
        k += [UInt8](repeating: 0, count: SHA256Hasher.blockLength - k.count)
        var inner = SHA256Hasher()
        inner.update(k.map { $0 ^ 0x36 })
        inner.update(data)
        var outer = SHA256Hasher()
        outer.update(k.map { $0 ^ 0x5c })
        outer.update(inner.finalize())
        return outer.finalize()
    }

    public static func authenticationCode<K: Sequence>(key: K, string: String) -> [UInt8] where K.Element == UInt8 {
        authenticationCode(key: key, data: Array(string.utf8))
    }
}

/// CRC-32 (IEEE 802.3, the `zlib.crc32` / `binascii.crc32` polynomial), used by AWS event-stream frames.
public enum CRC32 {
    private static let table: [UInt32] = (0..<256).map { i -> UInt32 in
        var c = UInt32(i)
        for _ in 0..<8 { c = (c & 1) != 0 ? 0xEDB8_8320 ^ (c >> 1) : c >> 1 }
        return c
    }

    public static func checksum<D: Sequence>(_ data: D, initial: UInt32 = 0) -> UInt32 where D.Element == UInt8 {
        var crc = ~initial
        for byte in data { crc = table[Int((crc ^ UInt32(byte)) & 0xff)] ^ (crc >> 8) }
        return ~crc
    }
}

/// Lowercase hex encoding.
public func hexString<D: Sequence>(_ bytes: D) -> String where D.Element == UInt8 {
    let digits = Array("0123456789abcdef".utf8)
    var out = [UInt8]()
    for b in bytes {
        out.append(digits[Int(b >> 4)])
        out.append(digits[Int(b & 0x0f)])
    }
    return String(decoding: out, as: UTF8.self)
}

/// Compares two byte strings in time independent of where they differ.
public func constantTimeEquals(_ a: [UInt8], _ b: [UInt8]) -> Bool {
    guard a.count == b.count else { return false }
    var diff: UInt8 = 0
    for i in 0..<a.count { diff |= a[i] ^ b[i] }
    return diff == 0
}

extension Data {
    /// Base64url without padding (RFC 7515 §2), as JWTs use.
    public func base64URLEncodedString() -> String {
        base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// Decodes base64url, with or without padding.
    public init?(base64URLEncoded string: String) {
        var s = string.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
        while s.count % 4 != 0 { s += "=" }
        self.init(base64Encoded: s)
    }
}
