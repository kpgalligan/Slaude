// Transformed from `tests/api_resources/beta/test_organization.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganization {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/me", json: #"{"id": "string", "name": "string", "type": "organization"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.retrieve(extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/me", json: #"{"id": "string", "name": "string", "type": "organization"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.withRawResponse.retrieve(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/me", json: #"{"id": "string", "name": "string", "type": "organization"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.withStreamingResponse.retrieve(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }
}
