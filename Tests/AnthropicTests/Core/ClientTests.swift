// Port of tests/test_client.py (`TestAsyncAnthropic` and the module-level tests). The sync twins
// (`TestAnthropic`) are redundant in Swift. See docs/porting/core-tests.md for skipped tests.

import Foundation
import Testing
@testable import Anthropic

private func emptyOK() -> MockServer { MockServer { req, _ in .empty(200, for: req) } }

private struct FooModel: Codable, Equatable, Sendable { var foo: Int }
private struct FooStringModel: Codable, Equatable, Sendable { var foo: String }
private struct NameModel: Codable, Sendable { var name: String }

@Suite("Status error mapping (test_client.py)")
struct StatusErrorMappingTests {
    /// `test_make_status_error_sync_async_parity`: every status code maps to its typed error.
    @Test(arguments: [
        (400, "BadRequestError"), (401, "AuthenticationError"), (403, "PermissionDeniedError"), (404, "NotFoundError"),
        (409, "ConflictError"), (413, "RequestTooLargeError"), (422, "UnprocessableEntityError"), (429, "RateLimitError"),
        (500, "InternalServerError"), (503, "InternalServerError"), (529, "OverloadedError"),
    ])
    func makeStatusErrorTypes(status: Int, name: String) throws {
        let client = try makeTestClient()
        let err = client.makeStatusError("msg", body: nil, response: .empty(status, for: dummyRequest))
        #expect(String(describing: type(of: err)) == name)
    }
}

@Suite("Client (test_client.py)")
struct ClientTests {
    @Test func userProfileIDHeader() async throws {
        let server = MockServer(json: [:])
        let client = try makeTestClient(server)
        _ = try await client.messages.withRawResponse.create(maxTokens: 16, messages: helloMessages(), model: "claude",
                                                            userProfileID: "uprof_test")
        let request = try #require(server.lastRequest)
        #expect(request.headers["anthropic-user-profile-id"] == "uprof_test")
        #expect(request.jsonBody?["user_profile_id"] == nil)
    }

    @Test func rawResponse() async throws {
        let client = try makeTestClient(MockServer(json: ["foo": "bar"]))
        let response = try await client.post("/foo", as: HTTPResponse.self)
        #expect(response.statusCode == 200)
        #expect(try JSONValue.parse(try await response.read()) == ["foo": "bar"])
    }

    @Test func rawResponseForBinary() async throws {
        let server = MockServer { req, _ in .text(#"{"foo": "bar"}"#, headers: ["Content-Type": "application/binary"], for: req) }
        let client = try makeTestClient(server)
        let response = try await client.post("/foo", as: HTTPResponse.self)
        #expect(response.statusCode == 200)
        #expect(try JSONValue.parse(try await response.read()) == ["foo": "bar"])
    }

    @Test func copy() throws {
        let client = try makeTestClient()
        let copied = try client.copy()
        #expect(copied !== client)
        let copied2 = try client.copy(apiKey: "another my-anthropic-api-key")
        #expect(copied2.apiKey == "another my-anthropic-api-key")
        #expect(client.apiKey == "my-anthropic-api-key")
    }

    @Test func copyDefaultOptions() throws {
        let client = try makeTestClient()
        // options that have a default are overridden correctly
        let copied = try client.copy(maxRetries: 7)
        #expect(copied.maxRetries == 7)
        #expect(client.maxRetries == 2)
        let copied2 = try copied.copy(maxRetries: 6)
        #expect(copied2.maxRetries == 6)
        #expect(copied.maxRetries == 7)
        // timeout
        #expect(client.timeout == DEFAULT_TIMEOUT)
        let copied3 = try client.copy(timeout: Timeout.none)
        #expect(copied3.timeout == Timeout.none)
        #expect(client.timeout == DEFAULT_TIMEOUT)
    }

    @Test func copyDefaultHeaders() throws {
        let client = try makeTestClient(defaultHeaders: ["X-Foo": "bar"])
        #expect(client.defaultHeaders["X-Foo"] == "bar")
        // does not override the already given value when not specified
        #expect(try client.copy().defaultHeaders["X-Foo"] == "bar")
        // merges already given headers
        var copied = try client.copy(defaultHeaders: ["X-Bar": "stainless"])
        #expect(copied.defaultHeaders["X-Foo"] == "bar")
        #expect(copied.defaultHeaders["X-Bar"] == "stainless")
        // uses new values for any already given headers
        copied = try client.copy(defaultHeaders: ["X-Foo": "stainless"])
        #expect(copied.defaultHeaders["X-Foo"] == "stainless")
        // set_default_headers completely overrides already set values
        copied = try client.copy(setDefaultHeaders: [:])
        #expect(copied.defaultHeaders["X-Foo"] == nil)
        copied = try client.copy(setDefaultHeaders: ["X-Bar": "Robert"])
        #expect(copied.defaultHeaders["X-Bar"] == "Robert")
        #expect(throws: ValueError("The `default_headers` and `set_default_headers` arguments are mutually exclusive")) {
            try client.copy(defaultHeaders: ["X-Foo": "Bar"], setDefaultHeaders: [:])
        }
    }

    @Test func copyDefaultQuery() throws {
        let client = try makeTestClient(defaultQuery: ["foo": "bar"])
        #expect(try defaultParams(client)["foo"] == "bar")
        // does not override the already given value when not specified
        #expect(try defaultParams(try client.copy())["foo"] == "bar")
        // merges already given params
        var params = try defaultParams(try client.copy(defaultQuery: ["bar": "stainless"]))
        #expect(params["foo"] == "bar")
        #expect(params["bar"] == "stainless")
        // uses new values for any already given params
        #expect(try defaultParams(try client.copy(defaultQuery: ["foo": "stainless"]))["foo"] == "stainless")
        // set_default_query completely overrides already set values
        #expect(try defaultParams(try client.copy(setDefaultQuery: [:])) == [:])
        params = try defaultParams(try client.copy(setDefaultQuery: ["bar": "Robert"]))
        #expect(params["bar"] == "Robert")
        #expect(throws: ValueError("The `default_query` and `set_default_query` arguments are mutually exclusive")) {
            try client.copy(defaultQuery: ["foo": "Bar"], setDefaultQuery: [:])
        }
    }

    @Test func requestTimeout() throws {
        let client = try makeTestClient()
        var request = try buildRequest(client, FinalRequestOptions(method: "get", url: "/foo"))
        #expect(request.timeout == DEFAULT_TIMEOUT)
        request = try buildRequest(client, FinalRequestOptions(method: "get", url: "/foo", timeout: Timeout(100.0)))
        #expect(request.timeout == Timeout(100.0))
    }

    @Test func clientTimeoutOption() throws {
        let client = try makeTestClient(timeout: Timeout(0))
        let request = try buildRequest(client, FinalRequestOptions(method: "get", url: "/foo"))
        #expect(request.timeout == Timeout(0))
    }

    enum TimeoutSetting: Sendable {
        case unset, set(Timeout)
    }

    /// `test_method_default_timeout`: (timeout, assigned, copy options, expected read timeout).
    @Test(arguments: [
        ("unset", TimeoutSetting.unset, TimeoutSetting.unset, nil as Timeout?, false, 600.0 as Double?),
        ("set to the default", .set(DEFAULT_TIMEOUT), .unset, nil, false, DEFAULT_TIMEOUT.read),
        ("set", .set(30), .unset, nil, false, 30),
        ("set to none", .set(Timeout.none), .unset, nil, false, nil),
        ("copy of unset", .unset, .unset, nil, true, 600),
        ("copy of set", .set(DEFAULT_TIMEOUT), .unset, nil, true, DEFAULT_TIMEOUT.read),
        ("copy that sets", .unset, .unset, DEFAULT_TIMEOUT, true, DEFAULT_TIMEOUT.read),
        ("assigned the default", .unset, .set(DEFAULT_TIMEOUT), nil, false, DEFAULT_TIMEOUT.read),
        ("assigned", .unset, .set(30), nil, false, 30),
        ("copy of assigned", .unset, .set(DEFAULT_TIMEOUT), nil, true, DEFAULT_TIMEOUT.read),
    ])
    func methodDefaultTimeout(id: String, timeout: TimeoutSetting, assigned: TimeoutSetting, copyTimeout: Timeout?, copy: Bool,
                              expected: Double?) async throws
    {
        var t: Timeout? = nil
        if case .set(let v) = timeout { t = v }
        var client = try makeTestClient(emptyOK(), timeout: t)
        if case .set(let v) = assigned { client.timeout = v }
        if copy { client = try client.withOptions(timeout: copyTimeout, maxRetries: copyTimeout == nil ? 1 : nil) }
        let response = try await client.messages.withRawResponse.create(maxTokens: 1024, messages: helloMessages("Hello, world"),
                                                                        model: "claude-opus-5-5")
        #expect(response.httpRequest.timeout.read == expected, "\(id)")
    }

    @Test(arguments: [nil, 30.0] as [Double?])
    func methodDefaultTimeoutRequestOption(clientTimeout: Double?) async throws {
        let client = try makeTestClient(emptyOK(), timeout: clientTimeout.map { Timeout($0) })
        let response = try await client.messages.withRawResponse.create(maxTokens: 1024, messages: helloMessages("Hello, world"),
                                                                        model: "claude-opus-5-5", timeout: 7)
        #expect(response.httpRequest.timeout.read == 7)
    }

    @Test func defaultHeadersOption() throws {
        let client = try makeTestClient(defaultHeaders: ["X-Foo": "bar"])
        var request = try buildRequest(client, FinalRequestOptions(method: "get", url: "/foo"))
        #expect(request.headers["x-foo"] == "bar")
        #expect(request.headers["x-stainless-lang"] == "swift")

        let client2 = try makeTestClient(defaultHeaders: ["X-Foo": "stainless", "X-Stainless-Lang": "my-overriding-header"])
        request = try buildRequest(client2, FinalRequestOptions(method: "get", url: "/foo"))
        #expect(request.headers["x-foo"] == "stainless")
        #expect(request.headers["x-stainless-lang"] == "my-overriding-header")
    }

    @Test func validateHeaders() throws {
        let client = try makeTestClient()
        let request = try buildRequest(client, FinalRequestOptions(method: "get", url: "/foo"))
        #expect(request.headers["Authorization"] == "Bearer \(testAPIKey)")

        let client2 = try makeTestClient(apiKey: nil)
        do {
            _ = try buildRequest(client2, FinalRequestOptions(method: "get", url: "/foo"))
            Issue.record("expected the request to be rejected")
        } catch let e as ArgumentTypeError {
            #expect(e.message.contains("Could not resolve authentication method. Expected one of api_key, auth_token, or credentials to be set. Or for the `Authorization` header to be explicitly omitted"))
        }
        let request2 = try buildRequest(client2, FinalRequestOptions(method: "get", url: "/foo", headers: ["Authorization": .omit]))
        #expect(request2.headers["Authorization"] == nil)
        let request3 = try buildRequest(client2, FinalRequestOptions(method: "get", url: "/foo", headers: ["authorization": .omit]))
        #expect(request3.headers["Authorization"] == nil)
        let request4 = try buildRequest(client2, FinalRequestOptions(method: "get", url: "/foo", headers: ["authorization": "from-header"]))
        #expect(request4.headers.values("Authorization") == ["from-header"])
    }

    @Test func defaultHeadersCaseInsensitive() throws {
        // replaces the SDK's own `User-Agent` rather than being sent next to it
        let client = try makeTestClient(defaultHeaders: ["user-agent": "my-app/1.0"])
        let request = try buildRequest(client, FinalRequestOptions(method: "get", url: "/foo"))
        #expect(request.headers.values("user-agent") == ["my-app/1.0"])
    }

    @Test func extraHeadersCaseInsensitive() throws {
        let client = try makeTestClient().withOptions(defaultHeaders: ["X-Foo": "client"])
        let request = try buildRequest(client, FinalRequestOptions(method: "post", url: "/foo", headers: ["x-foo": "request"]))
        #expect(request.headers.values("x-foo") == ["request"])
    }

    @Test func omitHeadersCaseInsensitive() throws {
        let client = try makeTestClient()
        var request = try buildRequest(try client.withOptions(defaultHeaders: ["X-Foo": "bar"]),
                                       FinalRequestOptions(method: "post", url: "/foo", headers: ["x-foo": .omit]))
        #expect(!request.headers.contains("x-foo"))
        request = try buildRequest(try client.withOptions(defaultHeaders: ["X-FOO": .omit]), FinalRequestOptions(method: "post", url: "/foo"))
        #expect(!request.headers.contains("x-foo"))
        request = try buildRequest(client, FinalRequestOptions(method: "post", url: "/foo", headers: ["X-STAINLESS-LANG": .omit]))
        #expect(!request.headers.contains("x-stainless-lang"))
        // request-time SDK headers sit in the lowest layer too, so a client-level omit also removes them
        request = try buildRequest(try client.withOptions(defaultHeaders: ["X-Stainless-Retry-Count": .omit]),
                                   FinalRequestOptions(method: "post", url: "/foo"))
        #expect(!request.headers.contains("x-stainless-retry-count"))
    }

    @Test func withOptionsHeadersCaseInsensitive() throws {
        let copied = try makeTestClient().withOptions(defaultHeaders: ["X-Foo": "one"]).withOptions(defaultHeaders: ["x-foo": "two"])
        let request = try buildRequest(copied, FinalRequestOptions(method: "get", url: "/foo"))
        #expect(request.headers.values("x-foo") == ["two"])
        #expect(copied.defaultHeaders["x-foo"] == "two")
        #expect(copied.defaultHeaders["X-Foo"] == nil)
    }

    @Test func multipartContentTypeCaseInsensitive() throws {
        let client = try makeTestClient()
        let request = try buildRequest(client, FinalRequestOptions(
            method: "post", url: "/foo", headers: ["content-type": "Multipart/Form-Data"],
            files: [("file", FileUpload(data: Data("hello world".utf8), filename: "foo.txt"))], jsonData: ["foo": "bar"]))
        let contentTypes = request.headers.values("content-type")
        #expect(contentTypes.count == 1)
        #expect(contentTypes.first?.hasPrefix("multipart/form-data; boundary=") == true)
        #expect(String(decoding: request.body ?? Data(), as: UTF8.self).contains(#"name="foo""#))
    }

    @Test func defaultQueryOption() throws {
        let client = try makeTestClient(defaultQuery: ["query_param": "bar"])
        var request = try buildRequest(client, FinalRequestOptions(method: "get", url: "/foo"))
        #expect(queryDict(request) == ["query_param": "bar"])
        request = try buildRequest(client, FinalRequestOptions(method: "get", url: "/foo", params: [("foo", "baz"), ("query_param", "overridden")]))
        #expect(queryDict(request) == ["foo": "baz", "query_param": "overridden"])
    }

    @Test func hardcodedQueryParamsInURL() throws {
        let client = try makeTestClient()
        var request = try buildRequest(client, FinalRequestOptions(method: "get", url: "/foo?beta=true"))
        #expect(queryDict(request) == ["beta": "true"])
        request = try buildRequest(client, FinalRequestOptions(method: "get", url: "/foo?beta=true", params: [("limit", "10"), ("page", "abc")]))
        #expect(queryDict(request) == ["beta": "true", "limit": "10", "page": "abc"])
        request = try buildRequest(client, FinalRequestOptions(method: "get", url: "/files/a%2Fb?beta=true", params: [("limit", "10")]))
        #expect(request.url.absoluteString.hasSuffix("/files/a%2Fb?beta=true&limit=10"))
    }

    @Test func requestExtraJSON() throws {
        let client = try makeTestClient()
        var request = try client.buildRequest(FinalRequestOptions(method: "post", url: "/foo", jsonData: ["foo": "bar"], extraJSON: ["baz": false]))
        #expect(request.jsonBody == ["foo": "bar", "baz": false])
        request = try client.buildRequest(FinalRequestOptions(method: "post", url: "/foo", extraJSON: ["baz": false]))
        #expect(request.jsonBody == ["baz": false])
        // `extra_json` takes priority over `json_data` when keys clash
        request = try client.buildRequest(FinalRequestOptions(method: "post", url: "/foo", jsonData: ["foo": "bar", "baz": true], extraJSON: ["baz": nil]))
        #expect(request.jsonBody == ["foo": "bar", "baz": nil])
    }

    /// A client whose `prepareOptions` hook records what it sees.
    final class RecordingClient: Anthropic, @unchecked Sendable {
        let seen = Locked<[FinalRequestOptions]>([])
        override func prepareOptions(_ options: FinalRequestOptions) async throws -> FinalRequestOptions {
            seen.withValue { $0.append(options) }
            return try await super.prepareOptions(options)
        }
    }

    @Test func requestExtraJSONMergedBeforePrepareOptions() async throws {
        // client hooks see the body with `extra_body` applied
        let server = MockServer(json: [:])
        let client = try RecordingClient(apiKey: testAPIKey, baseURL: testBaseURL, transport: server.transport, environment: [:])
        let response = try await client.post("/foo", body: ["foo": "bar", "baz": true], as: HTTPResponse.self,
                                             options: RequestOptions(extraBody: ["baz": nil]))
        #expect(client.seen.value.count == 1)
        #expect(client.seen.value[0].jsonData == ["foo": "bar", "baz": nil])
        #expect(client.seen.value[0].extraJSON == nil)
        #expect(response.request.jsonBody == ["foo": "bar", "baz": nil])
    }

    @Test func requestDoesNotModifyTheOptionsItIsGiven() async throws {
        let server = MockServer(json: [:])
        let client = try makeTestClient(server)
        let options = FinalRequestOptions(method: "post", url: "/foo", params: [("since", "2024-01-02")],
                                          jsonData: ["foo": "bar"], extraJSON: ["baz": [1, 2]])
        let response = try await client.requestHTTPResponse(options).parse()
        // what is sent is merged
        #expect(response.request.jsonBody == ["foo": "bar", "baz": [1, 2]])
        #expect(response.request.query("since") == "2024-01-02")
        // the caller's options are unchanged
        #expect(options.jsonData == ["foo": "bar"])
        #expect(options.extraJSON == ["baz": [1, 2]])
        #expect(options.params.map(\.0) == ["since"])
    }

    @Test func requestExtraHeaders() throws {
        let client = try makeTestClient()
        var o = FinalRequestOptions(method: "post", url: "/foo")
        client.apply(RequestOptions(extraHeaders: ["X-Foo": "Foo"]), to: &o)
        #expect(try buildRequest(client, o).headers["X-Foo"] == "Foo")
        // `extra_headers` takes priority over `default_headers` when keys clash
        let copied = try client.withOptions(defaultHeaders: ["X-Bar": "true"])
        var o2 = FinalRequestOptions(method: "post", url: "/foo")
        copied.apply(RequestOptions(extraHeaders: ["X-Bar": "false"]), to: &o2)
        #expect(try buildRequest(copied, o2).headers["X-Bar"] == "false")
    }

    @Test func requestXStainlessHelperHeaderAppends() throws {
        // `x-stainless-helper` accumulates across mappings instead of being clobbered
        let client = try makeTestClient().withOptions(defaultHeaders: ["x-stainless-helper": "session_runner"])
        let request = try buildRequest(client, FinalRequestOptions(method: "post", url: "/foo", headers: ["x-stainless-helper": "message_batches"]))
        #expect(request.headers["x-stainless-helper"] == "session_runner, message_batches")
    }

    @Test func requestXStainlessHelperHeaderDedupes() throws {
        let client = try makeTestClient().withOptions(defaultHeaders: ["x-stainless-helper": "session_runner"])
        let request = try buildRequest(client, FinalRequestOptions(method: "post", url: "/foo", headers: ["x-stainless-helper": "session_runner"]))
        #expect(request.headers["x-stainless-helper"] == "session_runner")
    }

    @Test func requestXStainlessHelperHeaderCollapsesCaseVariants() throws {
        // differently-cased duplicates fold into a single deduplicated value
        let client = try makeTestClient().withOptions(defaultHeaders: ["X-Stainless-Helper": "parent", "x-stainless-helper": "scoped"])
        let request = try buildRequest(client, FinalRequestOptions(method: "post", url: "/foo", headers: ["x-stainless-helper": "message_batches"]))
        #expect(request.headers["x-stainless-helper"] == "parent, scoped, message_batches")
        #expect(request.headers.values("x-stainless-helper").count == 1)
    }

    @Test func requestXStainlessHelperHeaderDedupesMultiValue() throws {
        let client = try makeTestClient().withOptions(defaultHeaders: ["x-stainless-helper": "session_runner, memory_tool"])
        let request = try buildRequest(client, FinalRequestOptions(method: "post", url: "/foo", headers: ["x-stainless-helper": "memory_tool, message_batches"]))
        #expect(request.headers["x-stainless-helper"] == "session_runner, memory_tool, message_batches")
    }

    @Test func copyXStainlessHelperHeaderAppends() throws {
        let client = try makeTestClient().withOptions(defaultHeaders: ["x-stainless-helper": "parent"])
            .withOptions(defaultHeaders: ["x-stainless-helper": "child"])
        let request = try buildRequest(client, FinalRequestOptions(method: "post", url: "/foo"))
        #expect(request.headers["x-stainless-helper"] == "parent, child")
    }

    @Test func copyPreservesHeaderRemoval() throws {
        // an omit set on the client survives a subsequent copy
        let client = try makeTestClient().withOptions(defaultHeaders: ["X-Foo": .omit]).withOptions(defaultHeaders: ["X-Bar": "true"])
        let request = try buildRequest(client, FinalRequestOptions(method: "post", url: "/foo"))
        #expect(request.headers["X-Foo"] == nil)
        #expect(request.headers["X-Bar"] == "true")
    }

    @Test func requestExtraQuery() throws {
        let client = try makeTestClient()
        var o = FinalRequestOptions(method: "post", url: "/foo")
        client.apply(RequestOptions(extraQuery: ["my_query_param": "Foo"]), to: &o)
        #expect(queryDict(try buildRequest(client, o)) == ["my_query_param": "Foo"])
        // if both `query` and `extra_query` are given, they are merged
        o = FinalRequestOptions(method: "post", url: "/foo")
        client.apply(RequestOptions(extraQuery: ["foo": "2"]), to: &o, query: [("bar", "1")])
        #expect(queryDict(try buildRequest(client, o)) == ["bar": "1", "foo": "2"])
        // `extra_query` takes priority over `query` when keys clash
        o = FinalRequestOptions(method: "post", url: "/foo")
        client.apply(RequestOptions(extraQuery: ["foo": "2"]), to: &o, query: [("foo", "1")])
        #expect(queryDict(try buildRequest(client, o)) == ["foo": "2"])
    }

    @Test func multipartRepeatingArray() throws {
        let client = try makeTestClient()
        let request = try buildRequest(client, FinalRequestOptions(
            method: "post", url: "/foo", headers: ["Content-Type": "multipart/form-data; boundary=6b7ba517decee4a450543ea6ae821c82"],
            files: [("foo.txt", FileUpload(data: Data("hello world".utf8)))], jsonData: ["array": ["foo", "bar"]]))
        let lines = String(decoding: request.body ?? Data(), as: UTF8.self).components(separatedBy: "\r\n")
        #expect(lines == [
            "--6b7ba517decee4a450543ea6ae821c82",
            #"Content-Disposition: form-data; name="array[]""#,
            "",
            "foo",
            "--6b7ba517decee4a450543ea6ae821c82",
            #"Content-Disposition: form-data; name="array[]""#,
            "",
            "bar",
            "--6b7ba517decee4a450543ea6ae821c82",
            // httpx names bare bytes "upload"; the SDK's own file handling (and Swift) sends them unnamed,
            // see test_files.py::test_file_without_a_name_is_sent_unnamed
            #"Content-Disposition: form-data; name="foo.txt""#,
            "Content-Type: application/octet-stream",
            "",
            "hello world",
            "--6b7ba517decee4a450543ea6ae821c82--",
            "",
        ])
    }

    @Test func binaryContentUpload() async throws {
        let server = MockServer { req, _ in HTTPResponse(statusCode: 200, body: req.body ?? Data(), request: req) }
        let client = try makeTestClient(server)
        let fileContent = Data("Hello, this is a test file.".utf8)
        let response = try await client.post("/upload", content: fileContent, as: HTTPResponse.self,
                                             options: RequestOptions(extraHeaders: ["Content-Type": "application/octet-stream"]))
        #expect(response.statusCode == 200)
        #expect(response.request.headers["Content-Type"] == "application/octet-stream")
        #expect(try await response.read() == fileContent)
    }

    @Test func nonApplicationJSONContentTypeForJSONData() async throws {
        // a response with a Content-Type other than application/json that holds JSON
        let server = MockServer { req, _ in .text(#"{"foo": 2}"#, headers: ["Content-Type": "application/text"], for: req) }
        let client = try makeTestClient(server)
        let response = try await client.get("/foo", as: FooModel.self)
        #expect(response.foo == 2)
    }

    @Test func baseURLSetter() throws {
        let client = try makeTestClient(baseURL: "https://example.com/from_init")
        #expect(client.baseURL.absoluteString == "https://example.com/from_init/")
        client.baseURL = URL(string: "https://example.com/from_setter")!
        #expect(client.baseURL.absoluteString == "https://example.com/from_setter/")
    }

    @Test func baseURLEnv() throws {
        let client = try Anthropic(apiKey: testAPIKey, environment: ["ANTHROPIC_BASE_URL": "http://localhost:5000/from/env"])
        #expect(client.baseURL.absoluteString == "http://localhost:5000/from/env/")
    }

    @Test(arguments: ["http://localhost:5000/custom/path/", "http://localhost:5000/custom/path"])
    func baseURLTrailingSlash(baseURL: String) throws {
        let client = try makeTestClient(baseURL: baseURL)
        let request = try buildRequest(client, FinalRequestOptions(method: "post", url: "/foo", jsonData: ["foo": "bar"]))
        #expect(request.url.absoluteString == "http://localhost:5000/custom/path/foo")
    }

    @Test func absoluteRequestURL() throws {
        let client = try makeTestClient(baseURL: "http://localhost:5000/custom/path/")
        let request = try buildRequest(client, FinalRequestOptions(method: "post", url: "https://myapi.com/foo", jsonData: ["foo": "bar"]))
        #expect(request.url.absoluteString == "https://myapi.com/foo")
    }

    @Test func clientResponseValidationError() async throws {
        let client = try makeTestClient(MockServer(json: ["foo": ["invalid": true]]))
        let error = await expectThrows(APIResponseValidationError.self) { _ = try await client.get("/foo", as: FooStringModel.self) }
        #expect(error?.cause is DecodingError)
    }

    @Test func defaultStreamCls() async throws {
        let client = try makeTestClient(MockServer(json: ["foo": "bar"]))
        let stream = try await client.requestStream(NameModel.self, method: "post", path: "/foo")
        stream.close()
        #expect(stream.response.isClosed)
    }

    @Test func receivedTextForExpectedJSON() async throws {
        let client = try makeTestClient(MockServer { req, _ in .text("my-custom-format", for: req) })
        await expectThrows(APIResponseValidationError.self) { _ = try await client.get("/foo", as: NameModel.self) }
    }

    /// `test_parse_retry_after_header`, with `time.time()` fixed at 1696004797.
    @Test(arguments: [
        (3, "20", 20.0), (3, "0", 0.5), (3, "-10", 0.5), (3, "60", 60), (3, "61", 61),
        (3, "Fri, 29 Sep 2023 16:26:57 GMT", 20), (3, "Fri, 29 Sep 2023 16:26:37 GMT", 0.5),
        (3, "Fri, 29 Sep 2023 16:26:27 GMT", 0.5), (3, "Fri, 29 Sep 2023 16:27:37 GMT", 60),
        (3, "Fri, 29 Sep 2023 16:27:38 GMT", 61), (3, "99999999999999999999999999999999999", 4294967),
        (3, "inf", 4294967), (3, "nan", 0.5), (3, "Zun, 29 Sep 2023 16:26:27 GMT", 0.5), (3, "", 0.5),
        (2, "", 0.5 * 2.0), (1, "", 0.5 * 4.0), (-1100, "", 8),
    ])
    func parseRetryAfterHeader(remainingRetries: Int, retryAfter: String, timeout: Double) throws {
        let client = try makeTestClient()
        let headers: HTTPHeaders = ["retry-after": retryAfter]
        let options = FinalRequestOptions(method: "get", url: "/foo", maxRetries: 3)
        let calculated = client.calculateRetryTimeout(remainingRetries: remainingRetries, options: options, responseHeaders: headers,
                                                      now: Date(timeIntervalSince1970: 1_696_004_797))
        // pytest.approx(timeout, rel=0.5 * 0.875)
        #expect(abs(calculated - timeout) <= timeout * 0.5 * 0.875, "\(retryAfter) -> \(calculated)")
    }

    @Test func retryAfterMsHeader() throws {
        let client = try makeTestClient()
        let options = FinalRequestOptions(method: "get", url: "/foo", maxRetries: 3)
        #expect(client.calculateRetryTimeout(remainingRetries: 3, options: options, responseHeaders: ["retry-after-ms": "1500", "retry-after": "20"]) == 1.5)
    }

    @Test func retryingTimeoutErrorsDoesntLeak() async throws {
        let server = MockServer { _, _ in throw TransportTimeoutError() }
        let client = try makeTestClient(server)
        await expectThrows(APITimeoutError.self) {
            try await client.messages.withStreamingResponse.create(maxTokens: 1024, messages: helloMessages("Hello, world"),
                                                                  model: "claude-opus-5-5") { _ in }
        }
        #expect(server.callCount == 3)
    }

    @Test func retryingStatusErrorsDoesntLeak() async throws {
        let bodies = Locked<[CountingBody]>([])
        let server = MockServer { req, _ in
            let body = CountingBody(strings: [])
            bodies.withValue { $0.append(body) }
            return body.response(status: 500, headers: [:], for: req)
        }
        let client = try makeTestClient(server)
        await expectThrows(APIStatusError.self) {
            try await client.messages.withStreamingResponse.create(maxTokens: 1024, messages: helloMessages("Hello, world"),
                                                                  model: "claude-opus-5-5") { _ in }
        }
        // every attempt's response was released
        #expect(bodies.value.count == 3)
        #expect(bodies.value.allSatisfy { $0.closeCount >= 1 })
    }

    @Test(arguments: [0, 2, 4], ["status", "exception"])
    func retriesTaken(failuresBeforeSuccess: Int, failureMode: String) async throws {
        struct Oops: Error {}
        let server = MockServer { req, i in
            if i < failuresBeforeSuccess {
                if failureMode == "exception" { throw Oops() }
                return .empty(500, for: req)
            }
            return .empty(200, for: req)
        }
        let client = try makeTestClient(server).withOptions(maxRetries: 4)
        let response = try await client.messages.withRawResponse.create(maxTokens: 1024, messages: helloMessages("Hello, world"),
                                                                        model: "claude-opus-5-5")
        #expect(response.retriesTaken == failuresBeforeSuccess)
        #expect(Int(response.httpRequest.headers["x-stainless-retry-count"] ?? "") == failuresBeforeSuccess)
    }

    @Test(arguments: [0, 2, 4])
    func omitRetryCountHeader(failuresBeforeSuccess: Int) async throws {
        let server = MockServer { req, i in i < failuresBeforeSuccess ? .empty(500, for: req) : .empty(200, for: req) }
        let client = try makeTestClient(server).withOptions(maxRetries: 4)
        let response = try await client.messages.withRawResponse.create(maxTokens: 1024, messages: helloMessages("Hello, world"),
                                                                        model: "claude-opus-5-5", extraHeaders: ["x-stainless-retry-count": .omit])
        #expect(response.httpRequest.headers.values("x-stainless-retry-count").isEmpty)
    }

    @Test(arguments: [0, 2, 4])
    func overwriteRetryCountHeader(failuresBeforeSuccess: Int) async throws {
        let server = MockServer { req, i in i < failuresBeforeSuccess ? .empty(500, for: req) : .empty(200, for: req) }
        let client = try makeTestClient(server).withOptions(maxRetries: 4)
        let response = try await client.messages.withRawResponse.create(maxTokens: 1024, messages: helloMessages("Hello, world"),
                                                                        model: "claude-opus-5-5", extraHeaders: ["x-stainless-retry-count": "42"])
        #expect(response.httpRequest.headers["x-stainless-retry-count"] == "42")
    }

    @Test func retriesSleepWithBackoff() async throws {
        let server = MockServer { req, i in i < 2 ? .empty(500, for: req) : .empty(200, for: req) }
        let client = try makeTestClient(server)
        let delays = Locked<[TimeInterval]>([])
        client.sleeper = { t in delays.withValue { $0.append(t) } }
        _ = try await client.messages.withRawResponse.create(maxTokens: 1024, messages: helloMessages(), model: "claude-opus-5-5")
        #expect(delays.value.count == 2)
        #expect(delays.value[0] > 0.5 * 0.75 - 1e-9 && delays.value[0] <= 0.5)
        #expect(delays.value[1] > 1.0 * 0.75 - 1e-9 && delays.value[1] <= 1.0)
    }

    @Test func idempotencyKeyIsReusedAcrossRetries() async throws {
        final class KeyedClient: Anthropic, @unchecked Sendable {
            override var idempotencyHeader: String? { "Idempotency-Key" }
        }
        let server = MockServer { req, i in i < 2 ? .empty(500, for: req) : .empty(200, for: req) }
        let client = try KeyedClient(apiKey: testAPIKey, baseURL: testBaseURL, transport: server.transport, environment: [:])
        client.sleeper = { _ in }
        _ = try await client.messages.withRawResponse.create(maxTokens: 1024, messages: helloMessages(), model: "claude-opus-5-5")
        let keys = server.calls.value.map { $0.headers["Idempotency-Key"] }
        #expect(keys.count == 3)
        #expect(keys[0]?.hasPrefix("stainless-swift-retry-") == true)
        #expect(Set(keys).count == 1)
    }

    @Test func getPlatform() throws {
        let client = try makeTestClient()
        let request = try buildRequest(client, FinalRequestOptions(method: "get", url: "/foo"))
        #expect(!(request.headers["X-Stainless-OS"] ?? "").isEmpty)
        #expect(!(request.headers["X-Stainless-Arch"] ?? "").isEmpty)
        #expect(request.headers["X-Stainless-Package-Version"] == ANTHROPIC_SDK_VERSION)
    }

    @Test func statusErrorTypeField() async throws {
        let server = MockServer(json: ["type": "error", "error": ["type": "invalid_request_error", "message": "Bad request"]], status: 400)
        let client = try makeTestClient(server)
        let error = await expectThrows(APIStatusError.self) { _ = try await createHello(client) }
        #expect(error?.type == .invalidRequestError)
        #expect(error?.statusCode == 400)
        #expect(error?.message == "Error code: 400 - {'error': {'message': 'Bad request', 'type': 'invalid_request_error'}, 'type': 'error'}")
    }
}
