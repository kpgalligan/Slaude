// Ports of tests/test_response.py, tests/test_files.py and tests/test_extract_files.py.

import Foundation
import Testing
@testable import Anthropic

private struct CustomModel: Codable, Equatable, Sendable {
    var foo: String
    var bar: Int
}

private func apiResponse(_ content: String, headers: HTTPHeaders = HTTPHeaders()) throws -> APIResponse<String> {
    let client = try makeTestClient()
    let http = HTTPResponse(statusCode: 200, headers: headers, body: Data(content.utf8), request: dummyRequest)
    return APIResponse(http: http, options: FinalRequestOptions(method: "get", url: "/foo"), retriesTaken: 0, client: client) { resp in
        try await resp.client.decodeBody(String.self, from: resp.http)
    }
}

// MARK: - test_response.py

@Suite("APIResponse (test_response.py)")
struct ResponseTests {
    @Test func parseCustomStream() async throws {
        let response = try apiResponse("event: completion\ndata: 1\n\n")
        let stream = try await response.parse(as: SSEStream<Int>.self)
        var values: [Int] = []
        for try await v in stream { values.append(v) }
        #expect(values == [1])
    }

    @Test func parseCustomModel() async throws {
        let response = try apiResponse(#"{"foo": "hello!", "bar": 2}"#)
        let obj = try await response.parse(as: CustomModel.self)
        #expect(obj == CustomModel(foo: "hello!", bar: 2))
    }

    @Test func requestIDAndWorkspaceID() async throws {
        let response = try apiResponse(#"{"foo": "hello!", "bar": 2}"#, headers: ["request-id": "my-req-id", "anthropic-workspace-id": "wrkspc_123"])
        #expect(response.requestID == "my-req-id")
        #expect(response.headers["anthropic-workspace-id"] == "wrkspc_123")
        #expect(try await response.parse(as: CustomModel.self) == CustomModel(foo: "hello!", bar: 2))
    }

    @Test(arguments: [("false", false), ("true", true), ("False", false), ("True", true), ("TrUe", true), ("FalSe", false)])
    func parseBool(content: String, expected: Bool) async throws {
        #expect(try await apiResponse(content).parse(as: Bool.self) == expected)
    }

    @Test func parseStrIntFloatBytes() async throws {
        #expect(try await apiResponse(#""quoted""#).parse() == #""quoted""#)
        #expect(try await apiResponse("42").parse(as: Int.self) == 42)
        #expect(try await apiResponse("1.5").parse(as: Double.self) == 1.5)
        #expect(try await apiResponse("abc").parse(as: Data.self) == Data("abc".utf8))
        await expectThrows(APIResponseValidationError.self) { _ = try await apiResponse("abc").parse(as: Int.self) }
    }

    @Test func parseJSONContentTypeCaseInsensitive() async throws {
        let response = try apiResponse(#"{"foo": "bar"}"#, headers: ["Content-Type": "Application/JSON; Charset=UTF-8"])
        #expect(try await response.parse(as: JSONValue.self) == ["foo": "bar"])
    }

    @Test func parseIsCached() async throws {
        let response = try apiResponse(#"{"foo": "hello!", "bar": 2}"#)
        _ = try await response.parse(as: CustomModel.self)
        #expect(response.cache.get(CustomModel.self) == CustomModel(foo: "hello!", bar: 2))
    }

    @Test func iterLines() async throws {
        let body = CountingBody(strings: ["a\r", "\nb\n", "c\rd", ""])
        let response = APIResponse<String>(http: body.response(for: dummyRequest), options: FinalRequestOptions(method: "get", url: "/"),
                                           retriesTaken: 0, client: try makeTestClient()) { _ in "" }
        var lines: [String] = []
        for try await line in response.iterLines() { lines.append(line) }
        #expect(lines == ["a", "b", "c", "d"])
    }
}

// MARK: - test_files.py / test_extract_files.py

@Suite("Files (test_files.py, test_extract_files.py)")
struct FilesTests {
    let readme = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("upstream/anthropic-sdk-python/README.md")

    @Test func pathIncludesFileName() throws {
        let file = try FileUpload(path: readme)
        #expect(file.filename == "README.md")
        #expect(file.data == (try Data(contentsOf: readme)))
    }

    @Test func pathInFileTuple() throws {
        let file = try FileUpload(path: readme, filename: "custom.md")
        #expect(file.filename == "custom.md")
        #expect(file.data == (try Data(contentsOf: readme)))
        let withHeaders = FileUpload(data: file.data, filename: "custom.md", contentType: "text/markdown", headers: ["X-Custom": "1"])
        let body = String(decoding: Multipart.encode(fields: [], files: [("file", withHeaders)], boundary: "B"), as: UTF8.self)
        #expect(body.hasPrefix("--B\r\nContent-Disposition: form-data; name=\"file\"; filename=\"custom.md\"\r\nContent-Type: text/markdown\r\nX-Custom: 1\r\n\r\n"))
    }

    @Test func fileWithoutANameIsSentUnnamed() {
        let body = Multipart.encode(fields: [], files: [("file", FileUpload(data: Data("content".utf8)))], boundary: "B")
        #expect(String(decoding: body, as: UTF8.self) == "--B\r\nContent-Disposition: form-data; name=\"file\"\r\nContent-Type: application/octet-stream\r\n\r\ncontent\r\n--B--\r\n")
    }

    @Test func namedFileGuessesItsContentType() {
        let body = Multipart.encode(fields: [("na\"me", "v")], files: [("file", FileUpload(data: Data("content".utf8), filename: "a\"b.txt"))], boundary: "B")
        // the same bytes httpx2 produces for `files={"file": ('a"b.txt', b"content")}, data={'na"me': "v"}`
        #expect(String(decoding: body, as: UTF8.self) == "--B\r\nContent-Disposition: form-data; name=\"na%22me\"\r\n\r\nv\r\n--B\r\nContent-Disposition: form-data; name=\"file\"; filename=\"a%22b.txt\"\r\nContent-Type: text/plain\r\n\r\ncontent\r\n--B--\r\n")
    }

    /// `extract_files`: generated methods move file arguments out of the JSON body into multipart parts.
    @Test func removesFilesFromInput() throws {
        var body = ParamsBuilder()
        try body.set("hello", "world")
        body.setFile("foo", FileUpload(data: Data("Bar".utf8)))
        #expect(body.object == ["hello": "world"])
        #expect(body.files.map(\.0) == ["foo"])
        #expect(body.files.first?.1.data == Data("Bar".utf8))
    }

    @Test func topLevelFileArray() throws {
        var body = ParamsBuilder()
        try body.set("title", "hello")
        body.setFiles("files", [FileUpload(data: Data("file one".utf8)), FileUpload(data: Data("file two".utf8))])
        #expect(body.object == ["title": "hello"])
        #expect(body.files.map(\.0) == ["files[]", "files[]"])
        #expect(body.files.map(\.1.data) == [Data("file one".utf8), Data("file two".utf8)])
    }

    @Test func absentFilesAreIgnored() {
        var body = ParamsBuilder()
        body.setFile("file", nil)
        body.setFiles("files", nil)
        #expect(body.files.isEmpty)
    }

    @Test func uploadSendsMultipart() async throws {
        let server = MockServer(json: [
            "id": "file_123", "created_at": "2024-01-01T00:00:00Z", "filename": "upload.txt",
            "mime_type": "text/plain", "size_bytes": 13, "type": "file",
        ])
        let client = try makeTestClient(server)
        _ = try await client.beta.files.upload(file: FileUpload(data: Data("file contents".utf8), filename: "upload.txt"))
        let request = try #require(server.lastRequest)
        let contentType = try #require(request.headers["Content-Type"])
        #expect(contentType.hasPrefix("multipart/form-data; boundary="))
        let text = String(decoding: request.body ?? Data(), as: UTF8.self)
        #expect(text.contains("Content-Disposition: form-data; name=\"file\"; filename=\"upload.txt\"\r\nContent-Type: text/plain\r\n\r\nfile contents\r\n"))
    }
}
