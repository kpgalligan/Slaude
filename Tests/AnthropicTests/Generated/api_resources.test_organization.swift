// Transformed from `tests/api_resources/test_organization.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestOrganization {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/me", json: #"{"id": "string", "name": "string", "type": "organization"}"#)
        let client = try route.client()
        let value = try await client.organization.retrieve()
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/me", json: #"{"id": "string", "name": "string", "type": "organization"}"#)
        let client = try route.client()
        let response = try await client.organization.withRawResponse.retrieve()
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/me", json: #"{"id": "string", "name": "string", "type": "organization"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.withStreamingResponse.retrieve(body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }
}
