// Port of tests/lib/tools/test_mcp_tool.py.

import Foundation
import Testing
@testable import Anthropic

private func json(_ content: BetaToolResultBlockParam.Content) throws -> JSONValue { try JSONValue.from(content) }

private func expectUnsupported(_ match: String, sourceLocation: SourceLocation = #_sourceLocation, _ body: () throws -> Void) {
    do {
        try body()
        Issue.record("expected UnsupportedMCPValueError", sourceLocation: sourceLocation)
    } catch let e as UnsupportedMCPValueError {
        #expect(e.message.contains(match), "\(e.message) !~ \(match)", sourceLocation: sourceLocation)
    } catch {
        Issue.record("expected UnsupportedMCPValueError, got \(error)", sourceLocation: sourceLocation)
    }
}

/// Quacks like the `call_tool` part of `mcp.ClientSession`, recording each call.
final class FakeMCPSession: MCPClientSession, @unchecked Sendable {
    let result: MCPCallToolResult
    let calls = ToolsBox<[JSONValue]>([])

    init(result: MCPCallToolResult = MCPCallToolResult(content: [.text("tool output")])) { self.result = result }

    func callTool(name: String, arguments: [String: JSONValue]) async throws -> MCPCallToolResult {
        calls.mutate { $0.append(["name": .string(name), "arguments": .object(arguments)]) }
        return result
    }
}

@Suite struct MCPContentTests {
    @Test func textContent() throws {
        let result = try json(mcpContent(.text("hello world")))
        #expect(result["type"] == "text")
        #expect(result["text"] == "hello world")
    }

    @Test func textContentWithCacheControl() throws {
        let result = try json(mcpContent(.text("hi"), cacheControl: BetaCacheControlEphemeralParam()))
        #expect(result["type"] == "text")
        #expect(result["cache_control"] == ["type": "ephemeral"])
    }

    @Test(arguments: ["image/png", "image/jpeg", "image/gif", "image/webp"])
    func imageContent(mime: String) throws {
        let result = try json(mcpContent(.image(data: "abc123", mimeType: mime)))
        #expect(result["type"] == "image")
        #expect(result["source"] == ["type": "base64", "data": "abc123", "media_type": .string(mime)])
    }

    @Test func imageUnsupportedMimeType() {
        expectUnsupported("image/bmp") { _ = try mcpContent(.image(data: "abc", mimeType: "image/bmp")) }
    }

    @Test func embeddedResourceText() throws {
        let result = try json(mcpContent(.embeddedResource(.text(uri: "file:///x.txt", mimeType: "text/plain", text: "doc content"))))
        #expect(result["type"] == "document")
        #expect(result["source"]?["type"] == "text")
        #expect(result["source"]?["data"] == "doc content")
    }

    @Test func embeddedResourcePDF() throws {
        let pdf = Data("pdf bytes".utf8).base64EncodedString()
        let result = try json(mcpContent(.embeddedResource(.blob(uri: "file:///doc.pdf", mimeType: "application/pdf", blob: pdf))))
        #expect(result["type"] == "document")
        #expect(result["source"]?["type"] == "base64")
        #expect(result["source"]?["media_type"] == "application/pdf")
    }

    @Test func embeddedResourceImage() throws {
        let result = try json(mcpContent(.embeddedResource(.blob(uri: "file:///img.png", mimeType: "image/png", blob: "aW1nZGF0YQ=="))))
        #expect(result["type"] == "image")
        #expect(result["source"]?["media_type"] == "image/png")
    }

    @Test func audioUnsupported() {
        expectUnsupported("audio") { _ = try mcpContent(.audio(data: "base64data", mimeType: "audio/mpeg")) }
    }

    @Test func resourceLinkUnsupported() {
        expectUnsupported("resource_link") { _ = try mcpContent(.resourceLink(uri: "https://example.com", name: "x")) }
    }

    @Test func embeddedResourceNoMimeDefaultsToText() throws {
        let result = try json(mcpContent(.embeddedResource(.text(uri: "file:///x.txt", text: "content"))))
        #expect(result["type"] == "document")
        #expect(result["source"]?["type"] == "text")
        #expect(result["source"]?["data"] == "content")
    }

    @Test func embeddedResourceUnsupportedMime() {
        expectUnsupported("application/octet-stream") {
            _ = try mcpContent(.embeddedResource(.blob(uri: "file:///x.bin", mimeType: "application/octet-stream", blob: "data")))
        }
    }

    @Test(arguments: ["image/png", "application/pdf"])
    func embeddedResourceRequiresBlob(mime: String) {
        // `test_embedded_resource_image_requires_blob`, `test_embedded_resource_pdf_requires_blob`.
        expectUnsupported("blob data") { _ = try mcpContent(.embeddedResource(.text(uri: "file:///x", mimeType: mime, text: "not blob"))) }
    }
}

@Suite struct MCPMessageTests {
    @Test func toolsUserMessage() throws {
        let result = try JSONValue.from(mcpMessage(MCPPromptMessage(role: "user", content: .text("hello"))))
        #expect(result["role"] == "user")
        #expect(result["content"] == [["type": "text", "text": "hello"]])
    }

    @Test func assistantMessage() throws {
        let result = try JSONValue.from(mcpMessage(MCPPromptMessage(role: "assistant", content: .text("hi there"))))
        #expect(result["role"] == "assistant")
    }

    @Test func messageWithCacheControl() throws {
        let result = try JSONValue.from(mcpMessage(MCPPromptMessage(role: "user", content: .text("hi")), cacheControl: BetaCacheControlEphemeralParam()))
        #expect(result["content"]?[0]?["cache_control"] == ["type": "ephemeral"])
    }

    @Test func listComprehension() throws {
        let result = try [MCPPromptMessage(role: "user", content: .text("q1")), MCPPromptMessage(role: "assistant", content: .text("a1"))]
            .map { try JSONValue.from(mcpMessage($0)) }
        #expect(result.map { $0["role"] } == ["user", "assistant"])
    }
}

@Suite struct MCPResourceTests {
    @Test func textResourceToContent() throws {
        let result = try json(mcpResourceToContent(MCPReadResourceResult(contents: [.text(uri: "file:///x.txt", mimeType: "text/plain", text: "hello")])))
        #expect(result["type"] == "document")
        #expect(result["source"]?["data"] == "hello")
    }

    @Test func pdfResourceToContent() throws {
        let pdf = Data("pdf content".utf8).base64EncodedString()
        let result = try json(mcpResourceToContent(MCPReadResourceResult(contents: [.blob(uri: "file:///x.bin", mimeType: "application/pdf", blob: pdf)])))
        #expect(result["type"] == "document")
        #expect(result["source"]?["media_type"] == "application/pdf")
    }

    @Test func imageResourceToContent() throws {
        let result = try json(mcpResourceToContent(MCPReadResourceResult(contents: [.blob(uri: "file:///x.bin", mimeType: "image/png", blob: "aW1n")])))
        #expect(result["type"] == "image")
    }

    @Test func emptyContentsRaises() {
        expectUnsupported("at least one item") { _ = try mcpResourceToContent(MCPReadResourceResult(contents: [])) }
        expectUnsupported("at least one item") { _ = try mcpResourceToFile(MCPReadResourceResult(contents: [])) }
    }

    @Test func noSupportedMimeRaises() {
        expectUnsupported("No supported MIME type") {
            _ = try mcpResourceToContent(MCPReadResourceResult(contents: [.blob(uri: "file:///x.bin", mimeType: "application/octet-stream", blob: "")]))
        }
    }

    @Test func selectsFirstSupported() throws {
        let result = try json(mcpResourceToContent(MCPReadResourceResult(contents: [
            .blob(uri: "file:///x.bin", mimeType: "application/octet-stream", blob: ""),
            .text(uri: "file:///x.txt", mimeType: "text/plain", text: "found it"),
        ])))
        #expect(result["type"] == "document")
        #expect(result["source"]?["data"] == "found it")
    }

    @Test func textResourceToFile() throws {
        let file = try mcpResourceToFile(MCPReadResourceResult(contents: [.text(uri: "file:///path/to/doc.txt", text: "hello")]))
        #expect(file.filename == "doc.txt")
        #expect(file.data == Data("hello".utf8))
    }

    @Test func blobResourceToFile() throws {
        let blob = Data("binary data".utf8).base64EncodedString()
        let file = try mcpResourceToFile(MCPReadResourceResult(contents: [.blob(uri: "file:///img.png", mimeType: "image/png", blob: blob)]))
        #expect(file.filename == "img.png")
        #expect(file.data == Data("binary data".utf8))
        #expect(file.contentType == "image/png")
    }
}

@Suite struct MCPToolTests {
    @Test func mcpToolToDict() throws {
        let tool = MCPTool(name: "my_tool", description: "Does stuff", inputSchema: ["type": "object", "properties": ["x": ["type": "integer"]]])
        let d = try mcpTool(tool, client: FakeMCPSession()).toToolParam()
        #expect(d["name"] == "my_tool")
        #expect(d["description"] == "Does stuff")
        #expect(d["input_schema"]?["type"] == "object")
    }

    @Test func mcpToolName() {
        #expect(mcpTool(MCPTool(name: "my_tool", inputSchema: ["type": "object"]), client: FakeMCPSession()).name == "my_tool")
    }

    @Test func mcpToolNoDescription() throws {
        let d = try mcpTool(MCPTool(name: "t", inputSchema: ["type": "object"]), client: FakeMCPSession()).toToolParam()
        #expect((d["description"] ?? "") == "")
    }

    @Test func mcpToolWithCacheControl() throws {
        let d = try mcpTool(MCPTool(name: "t", inputSchema: ["type": "object"]), client: FakeMCPSession(), cacheControl: BetaCacheControlEphemeralParam()).toToolParam()
        #expect(d["cache_control"] == ["type": "ephemeral"])
    }

    @Test func listComprehension() {
        let client = FakeMCPSession()
        let result = [MCPTool(name: "t1", inputSchema: ["type": "object"]), MCPTool(name: "t2", inputSchema: ["type": "object"])].map {
            mcpTool($0, client: client)
        }
        #expect(result.map(\.name) == ["t1", "t2"])
        #expect(result.allSatisfy { $0.helperTag == "mcp_tool" })
    }

    @Test func callSuccess() async throws {
        let client = FakeMCPSession(result: MCPCallToolResult(content: [.text("42")]))
        let result = try await mcpTool(MCPTool(name: "calc", inputSchema: ["type": "object"]), client: client).call(["x": 1])
        #expect(try JSONValue.from(result) == [["type": "text", "text": "42"]])
        #expect(client.calls.value == [["name": "calc", "arguments": ["x": 1]]])
    }

    @Test func callError() async throws {
        let client = FakeMCPSession(result: MCPCallToolResult(content: [.text("something went wrong")], isError: true))
        do {
            _ = try await mcpTool(MCPTool(name: "fail_tool", inputSchema: ["type": "object"]), client: client).call([:])
            Issue.record("expected ToolError")
        } catch let e as ToolError {
            #expect(e.message.contains("something went wrong"))
            #expect(try JSONValue.from(e.content) == [["type": "text", "text": "something went wrong"]])
        }
    }

    @Test func callStructuredContentFallback() async throws {
        let client = FakeMCPSession(result: MCPCallToolResult(content: [], structuredContent: ["key": "value"]))
        let result = try await mcpTool(MCPTool(name: "structured", inputSchema: ["type": "object"]), client: client).call([:])
        #expect(result == .string(#"{"key": "value"}"#))
    }

    @Test func callEmptyContentReturnsEmptyList() async throws {
        let client = FakeMCPSession(result: MCPCallToolResult(content: []))
        let result = try await mcpTool(MCPTool(name: "empty", inputSchema: ["type": "object"]), client: client).call([:])
        #expect(result == .contents([]))
    }

    @Test func mcpToolRunsInTheToolRunnerAndTagsItsRequests() async throws {
        let mock = MessagesMock([toolUseResponse("calc", "toolu_1", input: ["x": 1]), endTurnResponse()])
        let client = FakeMCPSession(result: MCPCallToolResult(content: [.text("42")]))
        let runner = try mock.client().beta.messages.toolRunner(
            maxTokens: 1024, messages: [toolsUserMessage("go")], model: "claude-haiku-4-5",
            tools: [mcpTool(MCPTool(name: "calc", inputSchema: ["type": "object"]), client: client)], thread: false)
        _ = try await runner.untilDone()
        #expect(mock.requests.first?.headers["x-stainless-helper"] == "BetaToolRunner, mcp_tool")
        #expect(mock.lastBody["messages"]?.arrayValue?.last == toolResultMessage("toolu_1", [["type": "text", "text": "42"]]))
    }
}
