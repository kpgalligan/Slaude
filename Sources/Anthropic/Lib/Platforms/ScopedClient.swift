import Foundation

/// Port of `lib/_scoped_client.py`: a Bearer-only sub-client for a helper.
///
/// Several helpers (the environment poller and worker, the session tool runner) issue requests
/// authenticated by a per-helper credential rather than the parent client's own API key. They
/// inherit the parent's full configuration (timeout, retries, transport, custom headers, default
/// query) and override only the auth, plus tag every request with their own `x-stainless-helper`.
public enum ScopedClient {
    /// A copy of `client` authenticated with `authToken` as Bearer.
    ///
    /// - The new token replaces the parent's API key / auth token; the API key is also cleared
    ///   after the copy (a subclass that overrides `copy`, such as `AnthropicAWS`, passes its own
    ///   key back in, and a key wins over a bearer token).
    /// - The parent's base URL and the headers of its credential (such as a profile's
    ///   `anthropic-workspace-id`) are kept.
    /// - `x-stainless-helper: <helper>` is merged into the default headers.
    /// - Inherited `Authorization` / `X-Api-Key` custom headers are stripped, since they would win
    ///   over the bearer.
    public static func copyWithBearerAuth<C: Anthropic>(_ client: C, authToken: String, helper: StainlessHelper) throws -> C {
        if authToken.isEmpty {
            throw ValueError("Expected a non-empty value for `auth_token` but received ''")
        }
        let headers = stripAuth(mergeHeaders(client.customHeaders, helperHeader(helper)))
        guard let scoped = try client.copy(authToken: authToken, baseURL: client.baseURL.absoluteString,
                                           setDefaultHeaders: headers) as? C
        else { throw AnthropicError("copy() of \(type(of: client)) did not return the same client type") }
        // `copy()` drops the headers that came with the parent's credential (such as a profile's
        // `anthropic-workspace-id`), but the bearer is for the workspace the parent talks to.
        scoped.credentialHeaders = client.credentialHeaders
        scoped.apiKey = nil
        return scoped
    }

    /// A copy of a client `copyWithBearerAuth` made, sending the same Bearer alone
    /// (`copy_scoped_client`).
    public static func copyScopedClient<C: Anthropic>(_ scoped: C) throws -> C {
        guard let copy = try scoped.copy(setDefaultHeaders: stripAuth(scoped.customHeaders)) as? C else {
            throw AnthropicError("copy() of \(type(of: scoped)) did not return the same client type")
        }
        copy.apiKey = nil
        return copy
    }

    /// `keep_only_bearer_auth`, applied to a header layer.
    static func stripAuth(_ headers: Headers) -> Headers {
        headers.filter { !["authorization", "x-api-key"].contains($0.key.lowercased()) }
    }
}
