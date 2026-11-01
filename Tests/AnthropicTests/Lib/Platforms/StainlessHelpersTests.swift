import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/test_stainless_helpers.py (the parts with Swift meaning).

@Suite struct StainlessHelpersTests {
    @Test func helperHeaderLayer() {
        #expect(helperHeader(.betaToolRunner) == [STAINLESS_HELPER_HEADER: "BetaToolRunner"])
    }

    @Test func helperHeaderIsAnAppendHeader() {
        // `mergeHeaders` only appends keys it knows about — keep this aligned.
        #expect(appendHeaderNames.contains(STAINLESS_HELPER_HEADER))
    }

    @Test func collectsDeduplicatedTags() {
        let items: [Any] = [HelperTagged("tool", helper: .mcpTool), "untagged", HelperTagged(1, helper: .mcpContent),
                            HelperTagged("again", helper: .mcpTool), HelperTagged(2, helper: nil)]
        #expect(collectHelpers(items) == ["mcp_tool", "mcp_content"])
        #expect(stainlessHelperHeader(items) == [STAINLESS_HELPER_HEADER: "mcp_tool, mcp_content"])
        #expect(stainlessHelperHeader(["x"]).isEmpty)
    }

    @Test func callerTagIsAppendedNotClobbered() async throws {
        let recorder = RequestRecorder()
        let client = try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, transport: recorder.transport, environment: [:])
        let tool = HelperTagged("t", helper: .mcpTool)
        _ = try await client.beta.messages.create(maxTokens: 16, messages: betaUserMessages("hello"), model: "claude-sonnet-5-5",
                                                  extraHeaders: mergeHeaders(stainlessHelperHeader([tool]), ["X-Stainless-Helper": "caller-tag"]))
        #expect(recorder.requests[0].headers.values(STAINLESS_HELPER_HEADER) == ["mcp_tool, caller-tag"])
    }

    @Test func fileUploadTagIsAppendedNotClobbered() async throws {
        let recorder = RequestRecorder { req, _ in
            platformJSON(#"{"id": "file_abc123", "type": "file", "created_at": "2026-01-01T00:00:00Z", "filename": "data.json", "mime_type": "application/json", "size_bytes": 2}"#)(req)
        }
        let client = try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, transport: recorder.transport, environment: [:])
        _ = try await client.files.upload(file: FileUpload(data: Data("{}".utf8), filename: "data.json", contentType: "application/json"),
                                          extraHeaders: mergeHeaders(helperHeader(.mcpResourceToFile), ["X-Stainless-Helper": "caller-tag"]))
        #expect(recorder.requests[0].headers.values(STAINLESS_HELPER_HEADER) == ["mcp_resource_to_file, caller-tag"])
    }

    /// Regression: the literal tag and the collected tags used to land under two casings of the
    /// key, producing two header lines on the wire.
    @Test func parseSendsSingleHeaderLine() async throws {
        let recorder = RequestRecorder()
        let client = try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, transport: recorder.transport, environment: [:])
        let tool: BetaToolUnionParam = try JSONValue.object(["name": "t", "description": "d", "input_schema": ["type": "object"]]).decode()
        _ = try await client.beta.messages.parse(maxTokens: 16, messages: betaUserMessages("hello"), model: "claude-sonnet-5-5", tools: [tool])
        let request = recorder.requests[0]
        #expect(request.headers.values(STAINLESS_HELPER_HEADER) == ["beta.messages.parse"])
        #expect(request.json["tools"] == [["name": "t", "description": "d", "input_schema": ["type": "object"]]])
    }

    /// Caller-supplied betas, user profile ID and extra headers all survive `parse()`'s merge
    /// alongside the helper tag.
    @Test func parseMergesCallerExtraHeaders() async throws {
        let recorder = RequestRecorder()
        let client = try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, transport: recorder.transport, environment: [:])
        _ = try await client.beta.messages.parse(maxTokens: 16, messages: betaUserMessages("hello"), model: "claude-sonnet-5-5",
                                                 betas: ["fake-beta-2026-01-01"], userProfileID: "upi_123",
                                                 extraHeaders: ["X-Custom": "1", "X-Stainless-Helper": "caller-tag"])
        let headers = recorder.requests[0].headers
        #expect(headers["anthropic-beta"] == "fake-beta-2026-01-01")
        #expect(headers["anthropic-user-profile-id"] == "upi_123")
        #expect(headers["X-Custom"] == "1")
        // The helper tag accumulates with the caller's on one line (append-header semantics).
        #expect(headers.values(STAINLESS_HELPER_HEADER) == ["beta.messages.parse, caller-tag"])
    }

    /// `extraHeaders` win outright on non-append headers, as with `create()`.
    @Test func parseCallerBetaHeaderOverrides() async throws {
        let recorder = RequestRecorder()
        let client = try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, transport: recorder.transport, environment: [:])
        _ = try await client.beta.messages.parse(maxTokens: 16, messages: betaUserMessages("hello"), model: "claude-sonnet-5-5",
                                                 extraHeaders: ["anthropic-beta": "explicit-only"])
        #expect(recorder.requests[0].headers["anthropic-beta"] == "explicit-only")
    }

    @Test func clientLevelTagAccumulatesWithRequestTag() async throws {
        let recorder = RequestRecorder()
        let client = try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, defaultHeaders: helperHeader(.environmentsWorker),
                                   transport: recorder.transport, environment: [:])
        _ = try await client.messages.create(maxTokens: 16, messages: userMessages("hello"), model: "claude-sonnet-5-5",
                                             extraHeaders: ["X-Stainless-Helper": "caller-tag"])
        #expect(recorder.requests[0].headers.values(STAINLESS_HELPER_HEADER) == ["environments-worker, caller-tag"])
    }
}
