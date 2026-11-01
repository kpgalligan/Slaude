// Transformed from `anthropic.resources.organization.compliance_settings` (compliance_settings.py).

import Foundation

public struct OrganizationComplianceSettingsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Retrieve your organization's Compliance Settings.
    ///
    /// Compliance Settings is a singleton resource: there is exactly one per
    /// organization, addressed without an identifier. The `state` field reflects
    /// whether the Compliance API is enabled. An organization with a parent
    /// organization reads the state inherited from the parent's configuration.
    public func retrieve(extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> OrganizationComplianceSettings {
        try await _retrieve(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<OrganizationComplianceSettings> {
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/compliance_settings", headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.compliance_settings.retrieve", spanRoute: "/v1/organizations/compliance_settings")
        return try await client.requestResponse(OrganizationComplianceSettings.self, options, stream: _mode == .stream)
    }

    /// Update your organization's Compliance Settings.
    ///
    /// Setting `state` to `enabled` turns on the Compliance API and begins capturing
    /// organization activity events. Setting it to `disabled` turns both off. `state`
    /// reflects whether the Compliance API is enabled.
    ///
    /// A request that sets `state` to its current value succeeds and leaves the
    /// resource unchanged. A `disabled` request stays in effect until a later `enabled`
    /// request or the organization's next provisioning action that enables Access
    /// Transparency: enabling Access Transparency also enables the Compliance API,
    /// which serves its activity events, so such provisioning (including re-runs)
    /// re-enables the Compliance API even after a `disabled` request. Automated
    /// provisioning never disables compliance settings.
    ///
    /// Args:
    ///   state: Desired state. Accepts the string shorthand "enabled" or "disabled" in place of
    ///       the object form; the response always returns the canonical object form.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func update(state: ComplianceSettingsStateParam, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> OrganizationComplianceSettings {
        try await _update(state: state, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(state: ComplianceSettingsStateParam, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<OrganizationComplianceSettings> {
        var body = ParamsBuilder()
        try body.set("state", state)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/compliance_settings", body: body, headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.compliance_settings.update", spanRoute: "/v1/organizations/compliance_settings")
        return try await client.requestResponse(OrganizationComplianceSettings.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: OrganizationComplianceSettingsResource

    /// Retrieve your organization's Compliance Settings.
    ///
    /// Compliance Settings is a singleton resource: there is exactly one per
    /// organization, addressed without an identifier. The `state` field reflects
    /// whether the Compliance API is enabled. An organization with a parent
    /// organization reads the state inherited from the parent's configuration.
        public func retrieve(extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<OrganizationComplianceSettings> {
            try await resource._retrieve(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update your organization's Compliance Settings.
    ///
    /// Setting `state` to `enabled` turns on the Compliance API and begins capturing
    /// organization activity events. Setting it to `disabled` turns both off. `state`
    /// reflects whether the Compliance API is enabled.
    ///
    /// A request that sets `state` to its current value succeeds and leaves the
    /// resource unchanged. A `disabled` request stays in effect until a later `enabled`
    /// request or the organization's next provisioning action that enables Access
    /// Transparency: enabling Access Transparency also enables the Compliance API,
    /// which serves its activity events, so such provisioning (including re-runs)
    /// re-enables the Compliance API even after a `disabled` request. Automated
    /// provisioning never disables compliance settings.
    ///
    /// Args:
    ///   state: Desired state. Accepts the string shorthand "enabled" or "disabled" in place of
    ///       the object form; the response always returns the canonical object form.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update(state: ComplianceSettingsStateParam, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<OrganizationComplianceSettings> {
            try await resource._update(state: state, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: OrganizationComplianceSettingsResource

    /// Retrieve your organization's Compliance Settings.
    ///
    /// Compliance Settings is a singleton resource: there is exactly one per
    /// organization, addressed without an identifier. The `state` field reflects
    /// whether the Compliance API is enabled. An organization with a parent
    /// organization reads the state inherited from the parent's configuration.
        public func retrieve<R: Sendable>(extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<OrganizationComplianceSettings>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Update your organization's Compliance Settings.
    ///
    /// Setting `state` to `enabled` turns on the Compliance API and begins capturing
    /// organization activity events. Setting it to `disabled` turns both off. `state`
    /// reflects whether the Compliance API is enabled.
    ///
    /// A request that sets `state` to its current value succeeds and leaves the
    /// resource unchanged. A `disabled` request stays in effect until a later `enabled`
    /// request or the organization's next provisioning action that enables Access
    /// Transparency: enabling Access Transparency also enables the Compliance API,
    /// which serves its activity events, so such provisioning (including re-runs)
    /// re-enables the Compliance API even after a `disabled` request. Automated
    /// provisioning never disables compliance settings.
    ///
    /// Args:
    ///   state: Desired state. Accepts the string shorthand "enabled" or "disabled" in place of
    ///       the object form; the response always returns the canonical object form.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update<R: Sendable>(state: ComplianceSettingsStateParam, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<OrganizationComplianceSettings>) async throws -> R) async throws -> R {
            let response = try await resource._update(state: state, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
