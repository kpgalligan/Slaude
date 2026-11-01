import Foundation

/// AWS Signature Version 4 request signing, ported from botocore's `SigV4Auth`
/// (header-based signing with a SHA-256 payload hash).
public struct AWSSigV4Signer: Sendable {
    public let credentials: AWSCredentials
    public let service: String
    public let region: String

    /// Header names botocore never signs.
    static let unsignedHeaders: Set<String> = ["expect", "transfer-encoding", "user-agent", "x-amzn-trace-id", "connection"]
    static let emptySHA256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

    public init(credentials: AWSCredentials, service: String, region: String) {
        self.credentials = credentials
        self.service = service
        self.region = region
    }

    /// The headers to add to the request: `X-Amz-Date`, `X-Amz-Security-Token` (with a session
    /// token) and `Authorization`.
    public func authHeaders(method: String, url: URL, headers: HTTPHeaders, body: Data?, date: Date = Date()) -> [(String, String)] {
        let timestamp = AWSSigV4Signer.timestamp(date)
        var signing = HTTPHeaders()
        for (name, value) in headers {
            let lower = name.lowercased()
            // Replaced below, as `_modify_request_before_signing` does.
            if lower == "authorization" || lower == "x-amz-date" || lower == "x-amz-security-token" { continue }
            signing.add(name, value)
        }
        signing["X-Amz-Date"] = timestamp
        if let token = credentials.sessionToken { signing["X-Amz-Security-Token"] = token }

        let (canonical, signedHeaders) = canonicalRequest(method: method, url: url, headers: signing, body: body)
        let scope = "\(timestamp.prefix(8))/\(region)/\(service)/aws4_request"
        let stringToSign = ["AWS4-HMAC-SHA256", timestamp, scope, hexString(SHA256Hasher.hash(canonical))].joined(separator: "\n")
        let signature = hexString(HMACSHA256.authenticationCode(key: signingKey(date: String(timestamp.prefix(8))), string: stringToSign))
        var out: [(String, String)] = [("X-Amz-Date", timestamp)]
        if let token = credentials.sessionToken { out.append(("X-Amz-Security-Token", token)) }
        out.append(("Authorization",
                    "AWS4-HMAC-SHA256 Credential=\(credentials.accessKeyID)/\(scope), SignedHeaders=\(signedHeaders), Signature=\(signature)"))
        return out
    }

    /// Signs `request` in place.
    public func sign(_ request: inout HTTPRequest, date: Date = Date()) {
        for (name, value) in authHeaders(method: request.method, url: request.url, headers: request.headers, body: request.body, date: date) {
            request.headers[name] = value
        }
    }

    static func timestamp(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return f.string(from: date)
    }

    func signingKey(date: String) -> [UInt8] {
        let kDate = HMACSHA256.authenticationCode(key: Array(("AWS4" + credentials.secretAccessKey).utf8), string: date)
        let kRegion = HMACSHA256.authenticationCode(key: kDate, string: region)
        let kService = HMACSHA256.authenticationCode(key: kRegion, string: service)
        return HMACSHA256.authenticationCode(key: kService, string: "aws4_request")
    }

    /// The canonical request and the `SignedHeaders` list.
    func canonicalRequest(method: String, url: URL, headers: HTTPHeaders, body: Data?) -> (String, String) {
        let comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let rawPath = comps?.percentEncodedPath ?? url.path
        let path = pythonQuote(AWSSigV4Signer.normalizePath(rawPath), safe: "/~")

        var query = ""
        if let q = comps?.percentEncodedQuery, !q.isEmpty {
            let pairs = q.split(separator: "&", omittingEmptySubsequences: false).map { pair -> (String, String) in
                if let eq = pair.firstIndex(of: "=") { return (String(pair[..<eq]), String(pair[pair.index(after: eq)...])) }
                return (String(pair), "")
            }
            query = pairs.sorted { $0.0 != $1.0 ? $0.0 < $1.0 : $0.1 < $1.1 }.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
        }

        var map: [String: [String]] = [:]
        for (name, value) in headers {
            let lower = name.lowercased()
            if AWSSigV4Signer.unsignedHeaders.contains(lower) { continue }
            map[lower, default: []].append(value)
        }
        if map["host"] == nil, let host = url.host {
            let port = url.port
            let isDefault = port == nil || (url.scheme == "https" && port == 443) || (url.scheme == "http" && port == 80)
            map["host"] = [isDefault ? host : "\(host):\(port!)"]
        }
        let names = map.keys.sorted()
        let canonicalHeaders = names.map { name in
            "\(name):" + map[name]!.map { $0.split(whereSeparator: { $0 == " " || $0 == "\t" }).joined(separator: " ") }.joined(separator: ",")
        }.joined(separator: "\n")
        let signedHeaders = names.joined(separator: ";")

        let payloadHash: String
        if let sha = headers["X-Amz-Content-SHA256"] {
            payloadHash = sha
        } else if let body, !body.isEmpty {
            payloadHash = hexString(SHA256Hasher.hash(body))
        } else {
            payloadHash = AWSSigV4Signer.emptySHA256
        }
        let canonical = [method.uppercased(), path, query, canonicalHeaders + "\n", signedHeaders, payloadHash].joined(separator: "\n")
        return (canonical, signedHeaders)
    }

    /// botocore's `normalize_url_path`: removes dot segments and empty segments.
    static func normalizePath(_ path: String) -> String {
        if path.isEmpty { return "/" }
        var output: [Substring] = []
        for segment in path.split(separator: "/", omittingEmptySubsequences: false) {
            if segment.isEmpty || segment == "." { continue }
            if segment == ".." {
                if !output.isEmpty { output.removeLast() }
            } else {
                output.append(segment)
            }
        }
        let first = path.hasPrefix("/") ? "/" : ""
        let last = path.hasSuffix("/") && !output.isEmpty ? "/" : ""
        return first + output.joined(separator: "/") + last
    }
}

/// `get_auth_headers` of `lib/aws/_auth.py` / `lib/bedrock/_auth.py`: resolves credentials and
/// returns the SigV4 headers for a request. The `Connection` header is never signed, since a proxy
/// may strip it.
public func awsAuthHeaders(method: String, url: URL, headers: HTTPHeaders, body: Data?, credentials: AWSCredentials,
                           region: String, serviceName: String, date: Date = Date()) -> [(String, String)]
{
    AWSSigV4Signer(credentials: credentials, service: serviceName, region: region)
        .authHeaders(method: method.uppercased(), url: url, headers: headers, body: body, date: date)
}
