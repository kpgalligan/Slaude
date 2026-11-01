import Foundation
import Testing
@testable import Anthropic

func platformHexBytes(_ hex: String) -> [UInt8] {
    var out: [UInt8] = []
    var i = hex.startIndex
    while i < hex.endIndex {
        let j = hex.index(i, offsetBy: 2)
        out.append(UInt8(hex[i..<j], radix: 16)!)
        i = j
    }
    return out
}

/// Known-answer tests for the pure-Swift primitives in `Lib/Crypto`.
@Suite struct CryptoTests {
    // FIPS 180-4 / NIST CAVP example vectors.
    @Test func sha256Vectors() {
        #expect(hexString(SHA256Hasher.hash("")) == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
        #expect(hexString(SHA256Hasher.hash("abc")) == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
        #expect(hexString(SHA256Hasher.hash("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"))
            == "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1")
        #expect(hexString(SHA256Hasher.hash([UInt8](repeating: 0x61, count: 1_000_000)))
            == "cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0")
    }

    @Test func sha256IncrementalMatchesOneShot() {
        let data = [UInt8]((0..<1000).map { UInt8(truncatingIfNeeded: $0 &* 31) })
        for split in [0, 1, 63, 64, 65, 500, 999, 1000] {
            var h = SHA256Hasher()
            h.update(data[0..<split])
            h.update(data[split...])
            #expect(h.finalize() == SHA256Hasher.hash(data), "split at \(split)")
        }
    }

    // RFC 4231 test cases 1, 2, 6 and 7.
    @Test func hmacSHA256Vectors() {
        #expect(hexString(HMACSHA256.authenticationCode(key: [UInt8](repeating: 0x0b, count: 20), string: "Hi There"))
            == "b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7")
        #expect(hexString(HMACSHA256.authenticationCode(key: Array("Jefe".utf8), string: "what do ya want for nothing?"))
            == "5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843")
        #expect(hexString(HMACSHA256.authenticationCode(key: [UInt8](repeating: 0xaa, count: 131),
                                                        string: "Test Using Larger Than Block-Size Key - Hash Key First"))
            == "60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f0ee37f54")
        #expect(hexString(HMACSHA256.authenticationCode(
            key: [UInt8](repeating: 0xaa, count: 131),
            string: "This is a test using a larger than block-size key and a larger than block-size data. The key needs to be hashed before being used by the HMAC algorithm."))
            == "9b09ffa71b942fcb27635fbcd5b0e944bfdc63644f0713938a7f51535c3a35e2")
    }

    @Test func crc32Vectors() {
        #expect(CRC32.checksum(Array("123456789".utf8)) == 0xCBF4_3926)
        #expect(CRC32.checksum([UInt8]()) == 0)
        #expect(CRC32.checksum(Array("The quick brown fox jumps over the lazy dog".utf8)) == 0x414F_A339)
    }

    @Test func base64URL() {
        #expect(Data([0xfb, 0xff, 0xfe]).base64URLEncodedString() == "-__-")
        #expect(Data(base64URLEncoded: "-__-") == Data([0xfb, 0xff, 0xfe]))
        #expect(Data("a".utf8).base64URLEncodedString() == "YQ")
    }

    @Test func bigUIntModPow() {
        // 4^13 mod 497 = 445 (the classic textbook example).
        #expect(BigUInt(4).power(BigUInt(13), modulus: BigUInt(497)) == BigUInt(445))
        // Fermat: a^(p-1) = 1 mod p for the Mersenne prime 2^127 - 1.
        let p = BigUInt(limbs: [UInt64.max, UInt64.max >> 1])
        let pMinus1 = BigUInt(limbs: [UInt64.max - 1, UInt64.max >> 1])
        #expect(BigUInt(3).power(pMinus1, modulus: p) == BigUInt(1))
        #expect(BigUInt(bigEndian: [0x01, 0x00]).bigEndianBytes() == [0x01, 0x00])
        #expect(BigUInt(bigEndian: [0x00, 0x00, 0x05]).bigEndianBytes(length: 4) == [0, 0, 0, 5])
    }

    // The expected signatures come from `openssl dgst -sha256 -sign`; PKCS#1 v1.5 is deterministic.
    @Test func rsaSignatureMatchesOpenSSL() throws {
        let key = try RSAPrivateKey(pem: RSATestVectors.privateKeyPKCS8)
        #expect(key.modulus.bitWidth == 2048)
        #expect(key.publicExponent == BigUInt(65537))
        let sig = try key.signature(for: Array("header.payload".utf8))
        #expect(hexString(sig) == RSATestVectors.signature)

        let pkcs1 = try RSAPrivateKey(pem: RSATestVectors.privateKeyPKCS1)
        #expect(pkcs1 == key)

        let small = try RSAPrivateKey(pem: RSATestVectors.privateKey1024)
        #expect(hexString(try small.signature(for: Array("The quick brown fox".utf8))) == RSATestVectors.signature1024)
    }

    @Test func rsaVerify() throws {
        let pub = try RSAPublicKey(pem: RSATestVectors.publicKey)
        let sig = platformHexBytes(RSATestVectors.signature)
        #expect(pub.isValidSignature(sig, for: Array("header.payload".utf8)))
        #expect(!pub.isValidSignature(sig, for: Array("header.payloaX".utf8)))
        var tampered = sig
        tampered[10] ^= 1
        #expect(!pub.isValidSignature(tampered, for: Array("header.payload".utf8)))
        #expect(pub == (try RSAPrivateKey(pem: RSATestVectors.privateKeyPKCS8)).publicKey)
    }

    @Test func pemWithEscapedNewlines() throws {
        // Service-account JSON files carry the key with literal `\n` escapes once embedded in strings.
        let escaped = RSATestVectors.privateKeyPKCS8.replacingOccurrences(of: "\n", with: "\\n")
        #expect(try RSAPrivateKey(pem: escaped) == RSAPrivateKey(pem: RSATestVectors.privateKeyPKCS8))
        #expect(throws: CryptoError.self) { try RSAPrivateKey(pem: "not a key") }
    }
}
