// Port of `anthropic/lib/tools/mcp.py`: helpers converting MCP (Model Context Protocol) values to Anthropic API
// types.
//
// Upstream converts the `mcp` package's models. No MCP client library is available to this package, so the MCP
// values the helpers take are small Swift types (`MCPTool`, `MCPContentBlock`, ...) mirroring the MCP schema, and
// the session a tool calls through is the `MCPClientSession` protocol: adapt your MCP client to them.

import Foundation

/// An MCP tool definition (`mcp.types.Tool`), as `tools/list` returns it.
public struct MCPTool: Sendable, Hashable {
    public var name: String
    public var description: String?
    public var inputSchema: [String: JSONValue]

    public init(name: String, description: String? = nil, inputSchema: [String: JSONValue]) {
        self.name = name
        self.description = description
        self.inputSchema = inputSchema
    }
}

/// The contents of an MCP resource (`TextResourceContents` / `BlobResourceContents`).
public enum MCPResourceContents: Sendable, Hashable {
    case text(uri: String, mimeType: String? = nil, text: String)
    /// `blob` is base64.
    case blob(uri: String, mimeType: String? = nil, blob: String)

    public var uri: String {
        switch self {
        case .text(let uri, _, _), .blob(let uri, _, _): return uri
        }
    }

    public var mimeType: String? {
        switch self {
        case .text(_, let m, _), .blob(_, let m, _): return m
        }
    }
}

/// An MCP content block (`mcp.types.ContentBlock`).
public enum MCPContentBlock: Sendable, Hashable {
    case text(String)
    /// `data` is base64.
    case image(data: String, mimeType: String)
    case audio(data: String, mimeType: String)
    case resourceLink(uri: String, name: String)
    case embeddedResource(MCPResourceContents)
    /// A content type this port doesn't model.
    case other(type: String)

    var typeName: String {
        switch self {
        case .text: return "text"
        case .image: return "image"
        case .audio: return "audio"
        case .resourceLink: return "resource_link"
        case .embeddedResource: return "resource"
        case .other(let t): return t
        }
    }
}

/// An MCP prompt message (`mcp.types.PromptMessage`).
public struct MCPPromptMessage: Sendable, Hashable {
    public var role: String
    public var content: MCPContentBlock

    public init(role: String, content: MCPContentBlock) {
        self.role = role
        self.content = content
    }
}

/// The result of an MCP `tools/call` (`mcp.types.CallToolResult`).
public struct MCPCallToolResult: Sendable, Hashable {
    public var content: [MCPContentBlock]
    public var isError: Bool
    public var structuredContent: JSONValue?

    public init(content: [MCPContentBlock], isError: Bool = false, structuredContent: JSONValue? = nil) {
        self.content = content
        self.isError = isError
        self.structuredContent = structuredContent
    }
}

/// The result of an MCP `resources/read` (`mcp.types.ReadResourceResult`).
public struct MCPReadResourceResult: Sendable, Hashable {
    public var contents: [MCPResourceContents]
    public init(contents: [MCPResourceContents]) { self.contents = contents }
}

/// The part of an MCP client session a tool calls through (`mcp.ClientSession.call_tool`).
public protocol MCPClientSession: Sendable {
    func callTool(name: String, arguments: [String: JSONValue]) async throws -> MCPCallToolResult
}

/// An MCP value that cannot be converted to a format the Claude API supports.
public struct UnsupportedMCPValueError: Error, CustomStringConvertible, Sendable {
    public let message: String
    public init(_ message: String) { self.message = message }
    public var description: String { message }
}

private let SUPPORTED_IMAGE_TYPES: Set<String> = ["image/jpeg", "image/png", "image/gif", "image/webp"]

private func isSupportedResourceMimeType(_ mimeType: String?) -> Bool {
    guard let mimeType else { return true }
    return mimeType.hasPrefix("text/") || mimeType == "application/pdf" || SUPPORTED_IMAGE_TYPES.contains(mimeType)
}

private func withCacheControl(_ block: JSONValue, _ cacheControl: BetaCacheControlEphemeralParam?) throws -> JSONValue {
    var block = block
    if let cacheControl { block["cache_control"] = try JSONValue.from(cacheControl) }
    return block
}

/// Convert a single MCP content block to an Anthropic content block (`mcp_content`): text, image, and embedded
/// resource content. Audio and resource links throw `UnsupportedMCPValueError`.
public func mcpContent(_ content: MCPContentBlock, cacheControl: BetaCacheControlEphemeralParam? = nil) throws
    -> BetaToolResultBlockParam.Content
{
    try mcpContentJSON(content, cacheControl: cacheControl).decode()
}

func mcpContentJSON(_ content: MCPContentBlock, cacheControl: BetaCacheControlEphemeralParam?) throws -> JSONValue {
    switch content {
    case .text(let text):
        return try withCacheControl(["type": "text", "text": .string(text)], cacheControl)
    case .image(let data, let mimeType):
        guard SUPPORTED_IMAGE_TYPES.contains(mimeType) else { throw UnsupportedMCPValueError("Unsupported image MIME type: \(mimeType)") }
        return try withCacheControl(
            ["type": "image", "source": ["type": "base64", "data": .string(data), "media_type": .string(mimeType)]], cacheControl)
    case .embeddedResource(let resource):
        return try resourceContentsToBlock(resource, cacheControl: cacheControl)
    default:
        throw UnsupportedMCPValueError("Unsupported MCP content type: \(content.typeName)")
    }
}

private func resourceContentsToBlock(_ resource: MCPResourceContents, cacheControl: BetaCacheControlEphemeralParam?) throws -> JSONValue {
    let mimeType = resource.mimeType
    if let mimeType, SUPPORTED_IMAGE_TYPES.contains(mimeType) {
        guard case .blob(_, _, let blob) = resource else {
            throw UnsupportedMCPValueError("Image resource must have blob data, not text. URI: \(resource.uri)")
        }
        return try withCacheControl(
            ["type": "image", "source": ["type": "base64", "data": .string(blob), "media_type": .string(mimeType)]], cacheControl)
    }
    if mimeType == "application/pdf" {
        guard case .blob(_, _, let blob) = resource else {
            throw UnsupportedMCPValueError("PDF resource must have blob data, not text. URI: \(resource.uri)")
        }
        return try withCacheControl(
            ["type": "document", "source": ["type": "base64", "data": .string(blob), "media_type": "application/pdf"]], cacheControl)
    }
    if mimeType == nil || mimeType!.hasPrefix("text/") {
        let data: String
        switch resource {
        case .text(_, _, let text): data = text
        case .blob(_, _, let blob):
            guard let bytes = Data(base64Encoded: blob), let text = String(data: bytes, encoding: .utf8) else {
                throw UnsupportedMCPValueError("Text resource is not valid base64-encoded UTF-8. URI: \(resource.uri)")
            }
            data = text
        }
        return try withCacheControl(
            ["type": "document", "source": ["type": "text", "data": .string(data), "media_type": "text/plain"]], cacheControl)
    }
    throw UnsupportedMCPValueError("Unsupported MIME type \"\(mimeType!)\" for resource: \(resource.uri)")
}

/// Convert an MCP prompt message to an Anthropic `BetaMessageParam` (`mcp_message`).
public func mcpMessage(_ message: MCPPromptMessage, cacheControl: BetaCacheControlEphemeralParam? = nil) throws -> BetaMessageParam {
    try JSONValue.object([
        "role": .string(message.role), "content": [try mcpContentJSON(message.content, cacheControl: cacheControl)],
    ]).decode()
}

/// Convert MCP resource contents to an Anthropic content block, using the first resource with a supported MIME
/// type (`mcp_resource_to_content`).
public func mcpResourceToContent(_ result: MCPReadResourceResult, cacheControl: BetaCacheControlEphemeralParam? = nil) throws
    -> BetaToolResultBlockParam.Content
{
    if result.contents.isEmpty { throw UnsupportedMCPValueError("Resource contents array must contain at least one item") }
    guard let supported = result.contents.first(where: { isSupportedResourceMimeType($0.mimeType) }) else {
        throw UnsupportedMCPValueError(
            "No supported MIME type found in resource contents. Available: \(result.contents.compactMap(\.mimeType).joined(separator: ", "))")
    }
    return try resourceContentsToBlock(supported, cacheControl: cacheControl).decode()
}

/// Convert MCP resource contents to a file for `files.upload()` (`mcp_resource_to_file`): the name is the last
/// component of the URI's path.
public func mcpResourceToFile(_ result: MCPReadResourceResult) throws -> FileUpload {
    guard let resource = result.contents.first else {
        throw UnsupportedMCPValueError("Resource contents array must contain at least one item")
    }
    let path = URLComponents(string: resource.uri)?.path ?? ""
    let name = path.isEmpty ? nil : path.split(separator: "/", omittingEmptySubsequences: false).last.map(String.init)
    let data: Data
    switch resource {
    case .blob(_, _, let blob):
        guard let bytes = Data(base64Encoded: blob) else { throw UnsupportedMCPValueError("Invalid base64 blob for resource: \(resource.uri)") }
        data = bytes
    case .text(_, _, let text): data = Data(text.utf8)
    }
    return FileUpload(data: data, filename: name, contentType: resource.mimeType)
}

/// The value a tool returns for an MCP `CallToolResult`: an error result throws a `ToolError` with its content.
func convertToolResult(_ result: MCPCallToolResult) throws -> BetaFunctionToolResult {
    let blocks = try result.content.map { try mcpContent($0) }
    if result.isError { throw ToolError(.contents(blocks)) }
    if result.content.isEmpty, let structured = result.structuredContent {
        return .string(pythonJSONDumps(structured))
    }
    return .contents(blocks)
}

/// Convert an MCP tool to a runnable tool for `toolRunner()` (`async_mcp_tool` / `mcp_tool`).
///
/// ```swift
/// let tools = try await mcpClient.listTools()
/// let runner = try client.beta.messages.toolRunner(
///     maxTokens: 1024, messages: [...], model: "claude-sonnet-5-5",
///     tools: tools.map { mcpTool($0, client: mcpSession) })
/// ```
public func mcpTool(_ tool: MCPTool, client: any MCPClientSession, cacheControl: BetaCacheControlEphemeralParam? = nil,
                    deferLoading: Bool? = nil, allowedCallers: [BetaFunctionTool.AllowedCaller]? = nil,
                    eagerInputStreaming: Bool? = nil, inputExamples: [[String: JSONValue]]? = nil, strict: Bool? = nil)
    -> BetaFunctionTool
{
    let name = tool.name
    let runnable = BetaFunctionTool(
        name: name, description: tool.description ?? "", inputSchema: tool.inputSchema, deferLoading: deferLoading,
        cacheControl: cacheControl, allowedCallers: allowedCallers, eagerInputStreaming: eagerInputStreaming,
        inputExamples: inputExamples, strict: strict
    ) { arguments in
        try convertToolResult(try await client.callTool(name: name, arguments: arguments))
    }
    runnable.helperTag = "mcp_tool"
    return runnable
}
