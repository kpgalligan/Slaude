// Transformed from `tests/api_resources/beta/organization/test_compliance_settings.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationComplianceSettings {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/compliance_settings", json: #"{"state": {"type": "enabled"}, "type": "compliance_settings"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.complianceSettings.retrieve(extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/compliance_settings", json: #"{"state": {"type": "enabled"}, "type": "compliance_settings"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.complianceSettings.withRawResponse.retrieve(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/compliance_settings", json: #"{"state": {"type": "enabled"}, "type": "compliance_settings"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.complianceSettings.withStreamingResponse.retrieve(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/compliance_settings", json: #"{"state": {"type": "enabled"}, "type": "compliance_settings"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationComplianceSettingUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.complianceSettings.update(state: BetaComplianceSettingsStateParam.enabled(BetaComplianceSettingsStateEnabledParam(type: "enabled")), extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/compliance_settings", json: #"{"state": {"type": "enabled"}, "type": "compliance_settings"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationComplianceSettingUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.complianceSettings.withRawResponse.update(state: BetaComplianceSettingsStateParam.enabled(BetaComplianceSettingsStateEnabledParam(type: "enabled")), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/compliance_settings", json: #"{"state": {"type": "enabled"}, "type": "compliance_settings"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationComplianceSettingUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.complianceSettings.withStreamingResponse.update(state: BetaComplianceSettingsStateParam.enabled(BetaComplianceSettingsStateEnabledParam(type: "enabled")), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }
}
