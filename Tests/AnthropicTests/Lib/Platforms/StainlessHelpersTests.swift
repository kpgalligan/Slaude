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

    @Test func clientLevelTagAccumulatesWithRequestTag() async throws {
        let recorder = RequestRecorder()
        let client = try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, defaultHeaders: helperHeader(.environmentsWorker),
                                   transport: recorder.transport, environment: [:])
        _ = try await client.messages.create(maxTokens: 16, messages: userMessages("hello"), model: "claude-sonnet-5-5",
                                             extraHeaders: ["X-Stainless-Helper": "caller-tag"])
        #expect(recorder.requests[0].headers.values(STAINLESS_HELPER_HEADER) == ["environments-worker, caller-tag"])
    }
}
