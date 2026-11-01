import Foundation

/// A non-negative big integer with 64-bit limbs (little-endian), just big enough for RSA.
///
/// Only what RSASSA-PKCS1-v1_5 needs is implemented: byte conversion, comparison and
/// Montgomery modular exponentiation with an odd modulus.
public struct BigUInt: Sendable, Hashable, CustomStringConvertible {
    /// Little-endian limbs, without trailing zero limbs.
    public private(set) var limbs: [UInt64]

    public init(limbs: [UInt64]) {
        self.limbs = limbs
        normalize()
    }

    public init(_ value: UInt64) { self.init(limbs: [value]) }

    /// Big-endian bytes, as DER and the RSA primitives use.
    public init<D: Collection>(bigEndian bytes: D) where D.Element == UInt8 {
        let b = Array(bytes)
        var limbs = [UInt64](repeating: 0, count: (b.count + 7) / 8)
        for (i, byte) in b.reversed().enumerated() {
            limbs[i / 8] |= UInt64(byte) << (UInt64(i % 8) * 8)
        }
        self.init(limbs: limbs)
    }

    private mutating func normalize() {
        while let last = limbs.last, last == 0 { limbs.removeLast() }
    }

    public var isZero: Bool { limbs.isEmpty }

    public var bitWidth: Int {
        guard let last = limbs.last else { return 0 }
        return (limbs.count - 1) * 64 + (64 - last.leadingZeroBitCount)
    }

    public var byteWidth: Int { (bitWidth + 7) / 8 }

    /// Big-endian bytes, left-padded with zeros to `length` (or the minimal length).
    public func bigEndianBytes(length: Int? = nil) -> [UInt8] {
        let n = max(length ?? 0, byteWidth)
        var out = [UInt8](repeating: 0, count: n)
        for i in 0..<byteWidth {
            out[n - 1 - i] = UInt8(truncatingIfNeeded: limbs[i / 8] >> (UInt64(i % 8) * 8))
        }
        return out
    }

    public func bit(_ i: Int) -> Bool {
        let limb = i / 64
        guard limb < limbs.count else { return false }
        return (limbs[limb] >> UInt64(i % 64)) & 1 == 1
    }

    public var description: String { "0x" + hexString(bigEndianBytes()) }

    static func compare(_ a: [UInt64], _ b: [UInt64]) -> Int {
        var la = a.count, lb = b.count
        while la > 0 && a[la - 1] == 0 { la -= 1 }
        while lb > 0 && b[lb - 1] == 0 { lb -= 1 }
        if la != lb { return la < lb ? -1 : 1 }
        var i = la - 1
        while i >= 0 {
            if a[i] != b[i] { return a[i] < b[i] ? -1 : 1 }
            i -= 1
        }
        return 0
    }

    public static func < (a: BigUInt, b: BigUInt) -> Bool { compare(a.limbs, b.limbs) < 0 }

    /// `a - b` in place, for `a >= b` (limb arrays of at least `b.count` limbs).
    static func subtractInPlace(_ a: inout [UInt64], _ b: [UInt64]) {
        var borrow: UInt64 = 0
        for i in 0..<a.count {
            let bi = i < b.count ? b[i] : 0
            let (d1, o1) = a[i].subtractingReportingOverflow(bi)
            let (d2, o2) = d1.subtractingReportingOverflow(borrow)
            a[i] = d2
            borrow = (o1 ? 1 : 0) + (o2 ? 1 : 0)
        }
    }

    /// `self^exponent mod modulus` (the modulus must be odd).
    public func power(_ exponent: BigUInt, modulus: BigUInt) -> BigUInt {
        let ctx = Montgomery(modulus: modulus)
        return ctx.power(self, exponent)
    }
}

/// Montgomery arithmetic modulo an odd `n` (CIOS multiplication).
struct Montgomery {
    let n: [UInt64]
    let k: Int
    let nInv: UInt64  // -n^-1 mod 2^64
    let r2: [UInt64]  // R^2 mod n, R = 2^(64k)

    init(modulus: BigUInt) {
        precondition(!modulus.isZero && modulus.limbs[0] & 1 == 1, "Montgomery modulus must be odd")
        n = modulus.limbs
        k = n.count
        // Newton iteration for n0^-1 mod 2^64.
        var inv: UInt64 = 1
        for _ in 0..<7 { inv = inv &* (2 &- n[0] &* inv) }
        nInv = 0 &- inv
        // R^2 mod n by doubling 1 (2 * 64k) times.
        var x = [UInt64](repeating: 0, count: k + 1)
        x[0] = 1
        let nPadded = n + [0]
        for _ in 0..<(2 * 64 * k) {
            var carry: UInt64 = 0
            for i in 0..<(k + 1) {
                let next = x[i] >> 63
                x[i] = (x[i] << 1) | carry
                carry = next
            }
            if BigUInt.compare(x, nPadded) >= 0 { BigUInt.subtractInPlace(&x, nPadded) }
        }
        r2 = Array(x[0..<k])
    }

    func multiply(_ a: [UInt64], _ b: [UInt64]) -> [UInt64] {
        var t = [UInt64](repeating: 0, count: k + 2)
        for i in 0..<k {
            let bi = i < b.count ? b[i] : 0
            var c: UInt64 = 0
            for j in 0..<k {
                let aj = j < a.count ? a[j] : 0
                let (hi, lo) = aj.multipliedFullWidth(by: bi)
                let (s1, o1) = t[j].addingReportingOverflow(lo)
                let (s2, o2) = s1.addingReportingOverflow(c)
                t[j] = s2
                c = hi &+ (o1 ? 1 : 0) &+ (o2 ? 1 : 0)
            }
            let (s, o) = t[k].addingReportingOverflow(c)
            t[k] = s
            t[k + 1] = o ? 1 : 0

            let m = t[0] &* nInv
            let (hi0, lo0) = m.multipliedFullWidth(by: n[0])
            let (_, oo) = t[0].addingReportingOverflow(lo0)
            c = hi0 &+ (oo ? 1 : 0)
            for j in 1..<max(k, 1) {
                let (hi, lo) = m.multipliedFullWidth(by: n[j])
                let (s1, o1) = t[j].addingReportingOverflow(lo)
                let (s2, o2) = s1.addingReportingOverflow(c)
                t[j - 1] = s2
                c = hi &+ (o1 ? 1 : 0) &+ (o2 ? 1 : 0)
            }
            let (s3, o3) = t[k].addingReportingOverflow(c)
            t[k - 1] = s3
            t[k] = t[k + 1] &+ (o3 ? 1 : 0)
        }
        var result = Array(t[0..<(k + 1)])
        if BigUInt.compare(result, n + [0]) >= 0 { BigUInt.subtractInPlace(&result, n + [0]) }
        return Array(result[0..<k])
    }

    func power(_ base: BigUInt, _ exponent: BigUInt) -> BigUInt {
        var b = base.limbs
        // Reduce the base below n (callers pass b < n; this handles b >= n by subtraction loops).
        while BigUInt.compare(b, n) >= 0 {
            var padded = b
            if padded.count < n.count { padded += [UInt64](repeating: 0, count: n.count - padded.count) }
            BigUInt.subtractInPlace(&padded, n)
            b = BigUInt(limbs: padded).limbs
        }
        let baseM = multiply(b, r2)
        var acc = multiply([1], r2)
        let bits = exponent.bitWidth
        var i = bits - 1
        while i >= 0 {
            acc = multiply(acc, acc)
            if exponent.bit(i) { acc = multiply(acc, baseM) }
            i -= 1
        }
        return BigUInt(limbs: multiply(acc, [1]))
    }
}

/// Errors from parsing keys or signing.
public struct CryptoError: Error, CustomStringConvertible, Sendable, Equatable {
    public let description: String
    public init(_ description: String) { self.description = description }
}

/// Minimal DER reader for the RSA key structures (PKCS#1, PKCS#8, SubjectPublicKeyInfo).
struct DERReader {
    let bytes: [UInt8]
    var offset: Int

    init(_ bytes: [UInt8]) {
        self.bytes = bytes
        self.offset = 0
    }

    var isAtEnd: Bool { offset >= bytes.count }

    mutating func read() throws -> (tag: UInt8, content: [UInt8]) {
        guard offset + 2 <= bytes.count else { throw CryptoError("truncated DER") }
        let tag = bytes[offset]
        var length = Int(bytes[offset + 1])
        offset += 2
        if length & 0x80 != 0 {
            let n = length & 0x7f
            guard n > 0, n <= 4, offset + n <= bytes.count else { throw CryptoError("bad DER length") }
            length = 0
            for _ in 0..<n {
                length = length << 8 | Int(bytes[offset])
                offset += 1
            }
        }
        guard offset + length <= bytes.count else { throw CryptoError("truncated DER value") }
        let content = Array(bytes[offset..<(offset + length)])
        offset += length
        return (tag, content)
    }

    mutating func expect(_ tag: UInt8) throws -> [UInt8] {
        let (t, c) = try read()
        guard t == tag else { throw CryptoError(String(format: "expected DER tag 0x%02x, got 0x%02x", tag, t)) }
        return c
    }

    mutating func integer() throws -> BigUInt { BigUInt(bigEndian: try expect(0x02)) }
}

/// An RSA public key.
public struct RSAPublicKey: Sendable, Hashable {
    public let modulus: BigUInt
    public let publicExponent: BigUInt

    public init(modulus: BigUInt, publicExponent: BigUInt) {
        self.modulus = modulus
        self.publicExponent = publicExponent
    }

    /// Parses `-----BEGIN PUBLIC KEY-----` (SubjectPublicKeyInfo) or `-----BEGIN RSA PUBLIC KEY-----` (PKCS#1).
    public init(pem: String) throws {
        let (label, der) = try decodePEM(pem)
        var outer = DERReader(der)
        var seq = DERReader(try outer.expect(0x30))
        if label == "RSA PUBLIC KEY" {
            self.init(modulus: try seq.integer(), publicExponent: try seq.integer())
            return
        }
        _ = try seq.expect(0x30)  // AlgorithmIdentifier
        var bits = try seq.expect(0x03)
        guard !bits.isEmpty else { throw CryptoError("empty BIT STRING") }
        bits.removeFirst()  // unused-bits byte
        var keyReader = DERReader(bits)
        var key = DERReader(try keyReader.expect(0x30))
        self.init(modulus: try key.integer(), publicExponent: try key.integer())
    }

    /// Verifies an RSASSA-PKCS1-v1_5 SHA-256 signature.
    public func isValidSignature(_ signature: [UInt8], for message: [UInt8]) -> Bool {
        let k = modulus.byteWidth
        guard signature.count == k else { return false }
        let s = BigUInt(bigEndian: signature)
        guard s < modulus else { return false }
        let m = s.power(publicExponent, modulus: modulus).bigEndianBytes(length: k)
        guard let expected = try? emsaPKCS1v15Encode(SHA256Hasher.hash(message), length: k) else { return false }
        return constantTimeEquals(m, expected)
    }
}

/// An RSA private key, for RS256 signatures (Google service-account JWTs).
public struct RSAPrivateKey: Sendable, Hashable {
    public let modulus: BigUInt
    public let publicExponent: BigUInt
    let privateExponent: BigUInt

    public init(modulus: BigUInt, publicExponent: BigUInt, privateExponent: BigUInt) {
        self.modulus = modulus
        self.publicExponent = publicExponent
        self.privateExponent = privateExponent
    }

    /// Parses `-----BEGIN PRIVATE KEY-----` (PKCS#8, as in service-account JSON files) or
    /// `-----BEGIN RSA PRIVATE KEY-----` (PKCS#1).
    public init(pem: String) throws {
        let (label, der) = try decodePEM(pem)
        var rsaDER = der
        if label == "PRIVATE KEY" {
            var outer = DERReader(der)
            var seq = DERReader(try outer.expect(0x30))
            _ = try seq.integer()  // version
            var alg = DERReader(try seq.expect(0x30))
            let oid = try alg.expect(0x06)
            guard oid == [0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01] else {
                throw CryptoError("the private key is not an RSA key")
            }
            rsaDER = try seq.expect(0x04)
        } else if label != "RSA PRIVATE KEY" {
            throw CryptoError("unsupported PEM type \(label)")
        }
        var outer = DERReader(rsaDER)
        var seq = DERReader(try outer.expect(0x30))
        _ = try seq.integer()  // version
        let n = try seq.integer()
        let e = try seq.integer()
        let d = try seq.integer()
        guard !n.isZero, n.limbs[0] & 1 == 1 else { throw CryptoError("invalid RSA modulus") }
        self.init(modulus: n, publicExponent: e, privateExponent: d)
    }

    public var publicKey: RSAPublicKey { RSAPublicKey(modulus: modulus, publicExponent: publicExponent) }

    /// RSASSA-PKCS1-v1_5 with SHA-256 (RFC 8017 §8.2), i.e. JWS `RS256`.
    public func signature(for message: [UInt8]) throws -> [UInt8] {
        let k = modulus.byteWidth
        let em = try emsaPKCS1v15Encode(SHA256Hasher.hash(message), length: k)
        let m = BigUInt(bigEndian: em)
        return m.power(privateExponent, modulus: modulus).bigEndianBytes(length: k)
    }
}

/// EMSA-PKCS1-v1_5 encoding of a SHA-256 digest.
func emsaPKCS1v15Encode(_ digest: [UInt8], length k: Int) throws -> [UInt8] {
    let prefix: [UInt8] = [0x30, 0x31, 0x30, 0x0d, 0x06, 0x09, 0x60, 0x86, 0x48, 0x01, 0x65, 0x03, 0x04, 0x02, 0x01, 0x05, 0x00, 0x04, 0x20]
    let t = prefix + digest
    guard k >= t.count + 11 else { throw CryptoError("intended encoded message length too short") }
    return [0x00, 0x01] + [UInt8](repeating: 0xff, count: k - t.count - 3) + [0x00] + t
}

/// Decodes a PEM block, returning its label (e.g. `PRIVATE KEY`) and DER bytes.
func decodePEM(_ pem: String) throws -> (String, [UInt8]) {
    let normalized = pem.replacingOccurrences(of: "\\n", with: "\n")
    guard let begin = normalized.range(of: "-----BEGIN ") else { throw CryptoError("no PEM header") }
    let afterBegin = normalized[begin.upperBound...]
    guard let labelEnd = afterBegin.range(of: "-----") else { throw CryptoError("malformed PEM header") }
    let label = String(afterBegin[..<labelEnd.lowerBound])
    let body = afterBegin[labelEnd.upperBound...]
    guard let end = body.range(of: "-----END \(label)-----") else { throw CryptoError("no PEM footer") }
    let b64 = body[..<end.lowerBound].filter { !$0.isWhitespace }
    guard let data = Data(base64Encoded: String(b64)) else { throw CryptoError("invalid base64 in PEM") }
    return (label, [UInt8](data))
}
