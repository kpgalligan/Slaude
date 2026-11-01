# Credentials subsystem (`anthropic/lib/credentials/`)

Hand-ported to `Sources/Anthropic/Lib/Credentials/` and wired into `Anthropic` (`Sources/Anthropic/Client.swift`).
Tests: `Tests/AnthropicTests/Lib/Credentials/` (port of `tests/lib/test_credentials.py`).

## Mapping

| Python | Swift |
| --- | --- |
| `_types.py`: `AccessToken`, `AccessTokenProvider` / `AsyncAccessTokenProvider`, `BaseURLBoundProvider`, `IdentityTokenProvider`, `CredentialResult` | `Types.swift`: `AccessToken`, `protocol AccessTokenProvider` (one async protocol, `callAsFunction(forceRefresh:)` + `close()`), `protocol BaseURLBoundProvider`, `protocol IdentityTokenProvider`, `CredentialResult`; closure wrappers `AccessTokenProviderFunction`, `IdentityTokenProviderFunction` |
| `os.environ` | `CredentialEnvironment` (`.process` reads the live process environment; a dictionary is a snapshot). The client passes its `environment:` dictionary. |
| `_constants.py` | `Constants.swift` (config dir, active profile, profile-name validation, https enforcement, path containment) |
| `_secrets.py` (`SecretStr`, `_wrap_secret_fields`, `_redact_body`) | `Secrets.swift`: `SecretPayload` (parsed credential JSON whose `description` / `debugDescription` / reflection mirror mask every non-plumbing string), `redactBody`, and a `json.loads`-compatible parser (`parseJSONFragment`) |
| `_workload.py` | `Workload.swift`: `WorkloadIdentityError`, `WorkloadIdentityCredentials`, `exchangeFederationAssertion` |
| `_providers.py` | `Providers.swift`: `StaticToken`, `EnvToken`, `IdentityTokenFile`, `CredentialsFile`, `InMemoryConfig` |
| `_cache.py` | `Cache.swift`: `TokenCache` (`getToken()` = `async_get_token`, `invalidate()`) |
| `_auth.py` | `Auth.swift`: `AccessTokenAuth`, one-shot shadowing warnings, `CredentialsLog` (the `anthropic` logger records) |
| `_chain.py` | `Chain.swift`: `defaultCredentials(baseURL:environment:transport:)` |
| `_close.py` | `AccessTokenProvider.close()` (default no-op); `Anthropic.close()` closes the transport, then the provider |
| `httpx2.Client` of a provider | `transport: HTTPTransport?` — a provider given none creates (and closes) a `URLSessionTransport` |
| POSIX file checks (`os.stat`, `fstat`, `mkstemp`, `os.replace`, `fsync`) | `FileIO.swift` (libc calls with `errno` preserved) |

Client (`_client.py`): `init(credentials:config:profile:...)` and `copy(credentials:config:profile:...)`, the
`ValueError` for more than one credential argument, credential precedence, profile base URL / headers,
`_unchosen_base_url`, `for_base_url` binding, `TokenCache` sharing across `copy()` only while the provider
and base URL are unchanged, `_validate_headers`, `custom_auth` (the `authenticate(_:)` hook), `_should_retry`
(401 → invalidate + retry once), `close`, and `_is_base_client` (subclasses skip the credential chain and
the warnings). `copy(credentials: .some(nil))` is Python's explicit `credentials=None`.

## Deliberate differences

* **One async client and cache.** Python's sync/async provider split (`is_async_token_provider`,
  `asyncify`, `aclose` vs `close`, the "use `AsyncAnthropic` instead" errors) has no counterpart.
* **Providers the client builds use the client's transport.** A provider built from `config:`, `profile:`
  or the environment exchanges tokens through the client's `transport:` (borrowed, not closed by the
  provider), where Python creates a separate `httpx2.Client`. That keeps token exchange testable with
  `MockTransport` and on the caller's network configuration.
* **Logging.** Python logs to the `anthropic` logger; Swift records go to `CredentialsLog` (process-wide
  handler, `setHandler(_:)`; warnings go to standard error by default). Tests capture records per task.
* **User-Agent** on token requests is `anthropic-swift/<version>` (Python: `anthropic-python/<version>`).
* **`AccessToken.token` is a `String`**, and its `description` keeps Python's masked `repr` format.
* **The client's environment is a snapshot** taken at construction (its `environment:` dictionary), so
  `ANTHROPIC_IDENTITY_TOKEN` / `ANTHROPIC_AUTH_TOKEN` rotation in the process is not seen by an existing
  client; standalone providers and `defaultCredentials()` default to the live process environment.
* **Write-back failures** of a refreshed `user_oauth` token throw `CredentialsError` ("could not be
  written: ...") instead of a raw `OSError`, so the error stays inside the SDK hierarchy.
* **JSON.** Payloads parse like `json.loads` (an out-of-range number such as `1e400` is `inf`, `NaN` /
  `Infinity` literals accepted), so a malformed field fails that field's check rather than the whole
  parse — whose error would quote the raw, secret-bearing body.

## Tests

282 upstream tests → 245 ported (async variants; the `client_cls` parametrizations collapse to the one
Swift client), plus 2 Swift-specific ones (`closeReleasesProviderOwnedTransportOnly`,
`secretPayloadRendersRedacted`) — 247 Swift tests.

* `TestNoSecretsInTracebackFrameLocals`: Swift errors carry no traceback frames, so each test checks
  that the thrown error itself (description, debug description, reflection `dump`, which walks stored
  properties such as `body`) holds none of the secrets; the `cause.__traceback__ is None` sub-assertions
  are dropped. `test_failed_writeback_after_refresh_does_not_retain_tokens` makes the credentials
  directory read-only instead of patching `mkstemp`, and — like
  `test_identity_token_file_permission_error_raises_anthropic_error` upstream — is skipped when running
  as root.
* `test_copy_inherits_the_parents_host_and_headers`: the second half (after `client.api_key = ...`) is
  dropped; `test_copy_credential_keeps_a_passed_base_url`: the `passed_to="attribute"` case is dropped
  (Swift's `apiKey` / `baseURL` are immutable).
* `tests/test_client.py` has no credentials-specific tests; its `test_validate_headers` (which stubs out
  `default_credentials`) is a general header test and stays with the `test_client.py` port.

### Skipped (37)

Covered by the one Swift implementation (the async twin of a ported sync test, or vice versa):

| Test | Reason |
| --- | --- |
| `TestAsyncAnthropicCredentials::test_workspace_id_header_from_config` | same as the ported `TestAnthropicCredentials` test (one client) |
| `TestAsyncAnthropicCredentials::test_async_static_token` | same as `test_static_token_credentials` |
| `TestAsyncAnthropicCredentials::test_async_workload_identity_exchange` | same as `test_messages_request_has_bearer_and_beta` |
| `TestAsyncAnthropicCredentials::test_async_copy_with_different_base_url_exchanges_per_client` | same as the sync test |
| `TestAsyncAnthropicCredentials::test_async_copy_with_same_base_url_shares_token_exchange` | same as the sync test |
| `TestAsyncAnthropicCredentials::test_async_workload_identity_error_propagates_through_request_flow` | same as the sync test |
| `TestAsyncAccessTokenProvider::test_next_force_preserved_on_provider_failure` | same as the `TestTokenCache` test (one cache) |
| `TestAsyncAccessTokenProvider::test_per_request_mode_still_forces_after_invalidate` | same as the `TestTokenCache` test |
| `TestAsyncAccessTokenProvider::test_concurrent_invalidate_survives_non_forced_call` | same as the `TestTokenCache` test |
| `TestAsyncAccessTokenProvider::test_unforced_result_is_not_cached_after_a_concurrent_invalidate` | same as the `TestTokenCache` test |
| `TestAsyncAccessTokenProvider::test_zero_expiry_token_is_not_reused` | same as the `TestTokenCache` test |

No Swift meaning:

| Test | Reason |
| --- | --- |
| `TestTokenCache::test_provider_must_return_an_access_token` | the protocol's return type is `AccessToken`; nothing else can be returned |
| `TestTokenCache::test_sync_callable_returning_a_coroutine_is_rejected` | Python coroutine objects |
| `TestTokenCache::test_get_token_rejects_async_provider` | sync/async cache split (Swift has one async `getToken()`) |
| `TestTokenCache::test_zero_arg_provider_backward_compat` | signature introspection of legacy zero-argument callables; Swift closures have a fixed type |
| `TestTokenCache::test_provider_annotated_with_an_undefined_name` | Python 3.14 lazy annotations / `inspect.signature` |
| `TestTokenCache::test_var_keyword_provider_receives_force_refresh` | `**kwargs` signature introspection |
| `TestTokenCache::test_next_force_preserved_when_provider_returns_non_token` | a provider cannot return a non-token (type system) |
| `TestAsyncAccessTokenProvider::test_next_force_preserved_when_provider_returns_non_token` | same |
| `TestAnthropicCredentials::test_duck_typed_token_is_rejected` | duck-typed `NamedTuple` tokens (type system) |
| `TestAnthropicCredentials::test_401_retry_forces_refresh_while_another_request_is_fetching` | monkeypatches `TokenCache.invalidate` to interleave threads; the interleaving is covered at the cache level by `latePerRequestResultDoesNotReplaceCachedExpiringToken` and `oneForcedCallPerInvalidateInPerRequestMode` |
| `TestAsyncAnthropicCredentials::test_async_aclose_via_context_manager` | `async with`; Swift has no async context managers (`close()` is ported) |
| `TestAsyncAccessTokenProvider::test_detection` | `is_async_token_provider` / `functools.partial` shapes |
| `TestAsyncAccessTokenProvider::test_sync_providers_are_not_detected_as_async` | same |
| `TestAsyncAccessTokenProvider::test_partial_of_a_callable_object_is_awaited` | `functools.partial` |
| `TestAsyncAccessTokenProvider::test_sync_provider_runs_off_the_event_loop_thread` | sync providers / worker threads |
| `TestAsyncAccessTokenProvider::test_sync_callable_returning_a_coroutine_is_rejected` | Python coroutine objects |
| `TestAsyncAccessTokenProvider::test_zero_arg_provider_behind_a_decorator_or_call_method` | `functools.wraps` signature introspection |
| `TestAsyncAccessTokenProvider::test_provider_must_return_an_access_token` | type system |
| `TestAsyncAccessTokenProvider::test_close_awaits_aclose` | `aclose()` vs `close()` hooks; Swift has the one `close()` (ported as `test_close_awaits_an_async_close`) |
| `TestAsyncAccessTokenProvider::test_close_tolerates_hooks_that_return_nothing_to_await` | `MagicMock` / non-awaitable hooks |
| `TestAsyncAccessTokenProvider::test_close_reaches_a_partial_wrapped_provider` | `functools.partial` |
| `TestAsyncAccessTokenProvider::test_sync_client_rejects_an_async_close` | sync client |
| `TestAsyncAccessTokenProvider::test_sync_client_calls_close_and_ignores_aclose` | sync client |
| `TestAsyncAccessTokenProvider::test_sync_client_accepts_a_provider_that_only_has_aclose` | sync client |
| `TestCredentialPrecedence::test_copy_of_a_client_assigned_a_second_credential` | assigns `client.api_key`; Swift's `apiKey` is immutable |
| `TestAccessTokenReprMasking::test_non_str_token_does_not_crash_repr` | `AccessToken.token` is typed `String` |
