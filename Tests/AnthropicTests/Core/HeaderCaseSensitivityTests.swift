// Port of tests/test_header_case_sensitivity.py. Header names (and media types) are case-insensitive:
// every merge, lookup and omit folds case. (Upstream runs each test for the sync and async client.)

import Foundation
import Testing
@testable import Anthropic

private func build(_ client: BaseClient, headers: Headers? = nil, jsonData: JSONValue? = nil,
                   files: [(String, FileUpload)]? = nil) throws -> HTTPRequest
{
    var o = FinalRequestOptions(method: "post", url: "/foo", files: files, jsonData: jsonData)
    if let headers { client.apply(RequestOptions(extraHeaders: headers), to: &o) }
    return try buildRequest(client, o)
}

private let emptyPage: JSONValue = ["data": [], "has_more": false, "first_id": nil, "last_id": nil]

@Suite("Header case sensitivity: build headers (test_header_case_sensitivity.py)")
struct HeaderCaseBuildTests {
    @Test func defaultHeadersReplaceSDKHeaderCaseInsensitively() throws {
        let request = try build(try makeTestClient(defaultHeaders: ["user-agent": "my-app/1.0"]))
        #expect(request.headers.values("user-agent") == ["my-app/1.0"])
    }

    @Test func defaultHeadersReplaceClientSubclassHeaderCaseInsensitively() throws {
        // `anthropic-version` is added by the `Anthropic` subclass after the custom headers
        let request = try build(try makeTestClient(defaultHeaders: ["Anthropic-Version": "2099-01-01"]))
        #expect(request.headers.values("anthropic-version") == ["2099-01-01"])
    }

    @Test func extraHeadersReplaceDefaultHeadersCaseInsensitively() throws {
        let request = try build(try makeTestClient(defaultHeaders: ["X-Foo": "from-client"]), headers: ["x-foo": "from-request"])
        #expect(request.headers.values("x-foo") == ["from-request"])
    }

    @Test func extraHeadersReplaceGeneratedHeaderParamCaseInsensitively() async throws {
        let server = MockServer(json: emptyPage)
        let client = try makeTestClient(server)
        _ = try await client.beta.models.list(betas: ["from-betas-param"], extraHeaders: ["Anthropic-Beta": "from-extra-headers"])
        #expect(server.request(0).headers.values("anthropic-beta") == ["from-extra-headers"])
    }

    @Test func extraHeadersReplaceSDKHeaderCaseInsensitively() throws {
        let request = try build(try makeTestClient(), headers: ["Anthropic-Version": "2099-01-01"])
        #expect(request.headers.values("anthropic-version") == ["2099-01-01"])
    }

    @Test func apiKeyHeaderOverrideDoesNotSendTwoCredentials() throws {
        let request = try build(try makeTestClient(apiKey: "sk-client-key"), headers: ["AUTHORIZATION": "Bearer sk-request-key"])
        #expect(request.headers.values("authorization") == ["Bearer sk-request-key"])
    }

    @Test func authorizationDefaultHeaderDoesNotSendTwoCredentials() throws {
        let client = try makeTestClient(apiKey: nil, authToken: "client-token", defaultHeaders: ["authorization": "Bearer gateway"])
        #expect(try build(client).headers.values("authorization") == ["Bearer gateway"])
    }

    @Test func customHeadersEnvVarIsOverriddenCaseInsensitively() throws {
        let client = try makeTestClient(defaultHeaders: ["X-Foo": "from-kwarg"], environment: ["ANTHROPIC_CUSTOM_HEADERS": "x-foo: from-env"])
        #expect(try build(client).headers.values("x-foo") == ["from-kwarg"])
    }
}

@Suite("Header case sensitivity: omit (test_header_case_sensitivity.py)")
struct HeaderCaseOmitTests {
    @Test func extraHeadersOmitRemovesDefaultHeaderCaseInsensitively() throws {
        let request = try build(try makeTestClient(defaultHeaders: ["X-Foo": "bar"]), headers: ["x-foo": .omit])
        #expect(!request.headers.contains("x-foo"))
    }

    @Test func extraHeadersOmitRemovesSDKHeaderCaseInsensitively() throws {
        #expect(!(try build(try makeTestClient(), headers: ["x-stainless-lang": .omit])).headers.contains("x-stainless-lang"))
    }

    @Test func defaultHeadersOmitRemovesClientSubclassHeaderCaseInsensitively() throws {
        #expect(!(try build(try makeTestClient(defaultHeaders: ["Anthropic-Version": .omit]))).headers.contains("anthropic-version"))
    }

    @Test func withOptionsOmitRemovesDefaultHeaderCaseInsensitively() throws {
        let client = try makeTestClient(defaultHeaders: ["X-Foo": "bar"]).withOptions(defaultHeaders: ["x-foo": .omit])
        #expect(!(try build(client)).headers.contains("x-foo"))
    }

    @Test func defaultHeadersOmitRemovesPerRequestSDKHeader() throws {
        #expect(!(try build(try makeTestClient(defaultHeaders: ["X-Stainless-Retry-Count": .omit]))).headers.contains("x-stainless-retry-count"))
    }
}

@Suite("Header case sensitivity: copy (test_header_case_sensitivity.py)")
struct HeaderCaseCopyTests {
    @Test func withOptionsReplacesDefaultHeaderCaseInsensitively() throws {
        let client = try makeTestClient(defaultHeaders: ["X-Foo": "parent"]).withOptions(defaultHeaders: ["x-foo": "child"])
        #expect(try build(client).headers.values("x-foo") == ["child"])
    }

    @Test func withOptionsDoesNotAccumulateCaseVariants() throws {
        let client = try makeTestClient().withOptions(defaultHeaders: ["X-Foo": "one"]).withOptions(defaultHeaders: ["x-foo": "two"])
            .withOptions(defaultHeaders: ["X-FOO": "three"])
        #expect(try build(client).headers.values("x-foo") == ["three"])
    }
}

@Suite("Header case sensitivity: validate headers (test_header_case_sensitivity.py)")
struct HeaderCaseValidateTests {
    @Test(arguments: ["x-api-key", "X-API-Key", "authorization", "AUTHORIZATION"])
    func authSuppliedViaDefaultHeaders(name: String) throws {
        let value = name.lowercased() == "x-api-key" ? "sk-from-header" : "Bearer from-header"
        let client = try makeTestClient(apiKey: nil, defaultHeaders: [name: .value(value)])
        #expect(try build(client).headers.values(name) == [value])
    }

    @Test(arguments: ["x-api-key", "authorization"])
    func authSuppliedViaExtraHeaders(name: String) throws {
        let value = name == "x-api-key" ? "sk-from-header" : "Bearer from-header"
        let request = try build(try makeTestClient(apiKey: nil), headers: [name: .value(value)])
        #expect(request.headers.values(name) == [value])
    }

    @Test func authSuppliedViaCustomHeadersEnvVar() throws {
        let client = try makeTestClient(apiKey: nil, environment: ["ANTHROPIC_CUSTOM_HEADERS": "x-api-key: sk-from-env"])
        #expect(try build(client).headers.values("x-api-key") == ["sk-from-env"])
    }

    @Test(arguments: ["authorization", "AUTHORIZATION"])
    func authExplicitlyOmitted(header: String) throws {
        let request = try build(try makeTestClient(apiKey: nil), headers: [header: .omit])
        #expect(!request.headers.contains(header))
    }

    @Test func authExplicitlyOmittedOnTheClient() throws {
        let client = try makeTestClient(apiKey: nil, defaultHeaders: ["authorization": .omit])
        #expect(!(try build(client)).headers.contains("authorization"))
    }

    /// Python passes an `httpx2.Auth` hook; the Swift counterpart is overriding `authenticate(_:)`.
    @Test func apiKeyMovedToXAPIKeyByHand() async throws {
        final class XAPIKeyClient: Anthropic, @unchecked Sendable {
            override func authenticate(_ request: inout HTTPRequest) async throws {
                if request.headers["Authorization"] == "Bearer sk-key" {
                    request.headers.remove("Authorization")
                    request.headers["X-Api-Key"] = "sk-key"
                }
            }
        }
        let server = MockServer(json: emptyPage)
        let client = try XAPIKeyClient(apiKey: "sk-key", baseURL: testBaseURL, transport: server.transport, environment: [:])
        _ = try await client.models.list()
        #expect(server.request(0).headers.values("x-api-key") == ["sk-key"])
        #expect(!server.request(0).headers.contains("authorization"))
    }
}

@Suite("Header case sensitivity: multipart content type (test_header_case_sensitivity.py)")
struct HeaderCaseMultipartTests {
    @Test(arguments: ["content-type", "Content-Type"], ["multipart/form-data", "Multipart/Form-Data"])
    func multipartContentType(name: String, value: String) throws {
        let request = try build(try makeTestClient(), headers: [name: .value(value)], jsonData: ["purpose": "test"],
                                files: [("file", FileUpload(data: Data("hello".utf8), filename: "hello.txt", contentType: "text/plain"))])
        let contentTypes = request.headers.values("content-type")
        #expect(contentTypes.count == 1)
        #expect(contentTypes.first?.hasPrefix("multipart/form-data; boundary=") == true)
        #expect(String(decoding: request.body ?? Data(), as: UTF8.self).contains(#"name="purpose""#))
    }
}
