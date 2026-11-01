// Transformed from `tests/api_resources/organization/test_compliance_settings.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestOrganizationComplianceSettings {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/compliance_settings", json: #"{"state": {"type": "enabled"}, "type": "compliance_settings"}"#)
        let client = try route.client()
        let value = try await client.organization.complianceSettings.retrieve()
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/compliance_settings", json: #"{"state": {"type": "enabled"}, "type": "compliance_settings"}"#)
        let client = try route.client()
        let response = try await client.organization.complianceSettings.withRawResponse.retrieve()
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/compliance_settings", json: #"{"state": {"type": "enabled"}, "type": "compliance_settings"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.complianceSettings.withStreamingResponse.retrieve(body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/compliance_settings", json: #"{"state": {"type": "enabled"}, "type": "compliance_settings"}"#, validateBody: { try MockRoute.roundTrip(ComplianceSettingUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.organization.complianceSettings.update(state: ComplianceSettingsStateParam.enabled(ComplianceSettingsStateEnabledParam(type: "enabled")))
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/compliance_settings", json: #"{"state": {"type": "enabled"}, "type": "compliance_settings"}"#, validateBody: { try MockRoute.roundTrip(ComplianceSettingUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.organization.complianceSettings.withRawResponse.update(state: ComplianceSettingsStateParam.enabled(ComplianceSettingsStateEnabledParam(type: "enabled")))
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/compliance_settings", json: #"{"state": {"type": "enabled"}, "type": "compliance_settings"}"#, validateBody: { try MockRoute.roundTrip(ComplianceSettingUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.organization.complianceSettings.withStreamingResponse.update(state: ComplianceSettingsStateParam.enabled(ComplianceSettingsStateEnabledParam(type: "enabled")), body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }
}
