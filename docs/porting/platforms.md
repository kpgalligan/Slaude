# Platform clients, request signing, webhooks

Hand-ported from `anthropic` 2.3.0. Sources live in `Sources/Anthropic/Lib/Platforms/`,
`Sources/Anthropic/Lib/Crypto/` and `Sources/Anthropic/Lib/Webhooks/`; tests in
`Tests/AnthropicTests/Lib/Platforms/`.

## What maps to what

| Python | Swift |
| --- | --- |
| `lib/aws/_client.py` `AsyncAnthropicAWS` | `AnthropicAWS` (subclass of `Anthropic`) |
| `lib/aws/_credentials.py` | `AWSConfig.validateCredentials / resolveAuthMode / resolveAPIKey / resolveRegion / resolveWorkspaceID / resolveBaseURL` |
| `lib/aws/_auth.py`, `lib/bedrock/_auth.py` `get_auth_headers` (botocore `SigV4Auth`) | `awsAuthHeaders(...)`, `AWSSigV4Signer` |
| boto3 session credential resolution | `AWSDefaultCredentialsChain`, `AWSSharedConfig`, `AWSCredentialsProvider` |
| `lib/bedrock/_client.py` `AsyncAnthropicBedrock` | `AnthropicBedrock` (subclass of `BaseClient`), `AnthropicBedrock.prepareBedrockOptions` |
| `lib/bedrock/_beta.py`, `_beta_messages.py` | `BedrockBetaResource` (`beta.messages` is the generated `BetaMessagesResource`) |
| `lib/bedrock/_stream_decoder.py`, botocore `EventStreamBuffer` | `AWSEventStreamDecoder`, `AWSEventStreamBuffer`, `AWSEventStreamMessage` |
| `lib/bedrock/_mantle.py` | `AnthropicBedrockMantle`, `MantleBetaResource` |
| `lib/vertex/*` | `AnthropicVertex`, `VertexBetaResource`, `AnthropicVertex.prepareVertexOptions` |
| `lib/google_cloud/_client.py` | `AnthropicGoogleCloud` (subclass of `Anthropic`), `GoogleTokenProvider` |
| `lib/_extras/_google_auth.py` (+ `google.auth`) | `GoogleAuth.loadDefaultCredentials`, `GoogleCredentials` protocol, `GoogleServiceAccountCredentials`, `GoogleAuthorizedUserCredentials`, `GoogleComputeEngineCredentials`, `GoogleAccessTokenCredentials`, `GoogleCredentialsState` |
| `lib/foundry.py` | `AnthropicFoundry`, `AzureADTokenProvider`, `MutuallyExclusiveAuthError` |
| `lib/_scoped_client.py` | `ScopedClient.copyWithBearerAuth`, `ScopedClient.copyScopedClient` |
| `lib/_stainless_helpers.py` | `STAINLESS_HELPER_HEADER` & co., `StainlessHelper`, `helperHeader`, `HelperTagged`, `collectHelpers`, `stainlessHelperHeader` |
| `lib/_retry.py` | `HelperRetry.backoff / jitter / isTransient / isFatalStatusError` |
| `resources/beta/webhooks.py` `unwrap` / `parse_unverified` (+ `standardwebhooks`) | `BetaWebhooksResource.unwrap(_:headers:key:)` / `parseUnverified(_:)`, `StandardWebhook`, `WebhookVerificationError` |

Every client takes `environment:` (defaults to the process environment) instead of reading
`os.environ`, and a `transport:` (Python's `http_client=`). Python's `monkeypatch` of
`_load_adc_credentials` is the `credentialsLoader:` argument; `get_auth_headers` stand-ins are
replaced by asserting on the real SigV4 `Authorization` header.

## Crypto (`Lib/Crypto`)

Pure Swift, no CryptoKit / swift-crypto:

* `SHA256Hasher` (FIPS 180-4), `HMACSHA256` (RFC 2104), `CRC32` (zlib polynomial), base64url,
  `constantTimeEquals`.
* `BigUInt` with Montgomery modular exponentiation, a DER reader, PEM decoding, and
  `RSAPrivateKey` / `RSAPublicKey` (PKCS#1 and PKCS#8 / SPKI keys) for RSASSA-PKCS1-v1_5 SHA-256
  (`RS256`) signing and verification.

Verification (`CryptoTests`, `SigV4VectorTests`, `WebhooksTests`):

* SHA-256: NIST vectors (empty, `abc`, the 448-bit message, one million `a`), plus incremental
  updates across block boundaries. HMAC: RFC 4231 cases 1, 2, 6, 7. CRC-32: `123456789` → `cbf43926`.
* RSA: the signatures of a 2048-bit (PKCS#8 and PKCS#1 PEM) and a 1024-bit key are compared
  byte for byte with `openssl dgst -sha256 -sign` output (PKCS#1 v1.5 is deterministic), and
  verified against the `openssl pkey -pubout` public key; tampered signatures fail.
* SigV4: AWS's published `get-vanilla` test-suite signature, and a POST with a session token,
  a `%2F`-encoded / `:`-containing path, an unsorted query and whitespace-collapsing headers,
  checked against a Python reference of botocore's `SigV4Auth` algorithm (which itself reproduces
  the AWS vector). The file-upload test re-signs the exact multipart body that was sent.
* Standard Webhooks: a signature computed with Python's `hmac` / `base64`.
* Google service-account JWTs are signed with the test key and the test verifies the JWT
  signature with the public key.

## Credential resolution: what is supported

AWS (`AWSDefaultCredentialsChain`, used when no explicit keys / `credentialsProvider:` are given):
environment variables (skipped when a profile is passed explicitly, as boto3 does), the shared
credentials file, `credential_process` (macOS / Linux), static keys in the config file, the
ECS/EKS container endpoint (`AWS_CONTAINER_CREDENTIALS_RELATIVE_URI` / `_FULL_URI`, with
`AWS_CONTAINER_AUTHORIZATION_TOKEN[_FILE]`), and EC2 IMDSv2 (unless `AWS_EC2_METADATA_DISABLED=true`).
Temporary credentials are cached until five minutes before they expire. Bedrock infers its region
from `AWS_REGION` / `AWS_DEFAULT_REGION`, then the profile's `region` in the config file.
**Not supported** (pass an `AWSCredentialsProvider`): SSO / IAM Identity Center profiles,
`role_arn` + `source_profile` assume-role profiles, web-identity federation
(`AWS_WEB_IDENTITY_TOKEN_FILE`).

Google (`GoogleAuth.loadDefaultCredentials`, Application Default Credentials):
`GOOGLE_APPLICATION_CREDENTIALS`, then the gcloud ADC file (`$CLOUDSDK_CONFIG` or
`~/.config/gcloud/application_default_credentials.json`), then the GCE metadata server;
`GOOGLE_CLOUD_PROJECT` / `GCLOUD_PROJECT` override the project. Credential files of type
`service_account` (RS256 JWT bearer grant — RSA is implemented) and `authorized_user`
(refresh-token grant) are supported. **Not supported**: `external_account` (workload identity
federation), `impersonated_service_account`, and the gcloud-configured project of user
credentials (google-auth shells out to `gcloud`). Any other source can be plugged in by
conforming to `GoogleCredentials`, passing `tokenProvider:` / `accessToken:`, or a
`credentialsLoader:`.

## Differences from Python

* Python hides unsupported resources (`client.models` on Foundry, `messages.batches`); Swift
  subclasses cannot remove inherited properties, so they are present and the service rejects
  them. Bedrock / Mantle / Vertex do not subclass `Anthropic`, so their surface is restricted at
  compile time (`messages`, `beta.messages` only).
* `copy()` on `Anthropic` subclasses: the inherited `copy(apiKey:…)` is overridden to return the
  subclass, and a fuller overload adds the platform options
  (`let c: AnthropicAWS = try client.copy(awsRegion: "us-west-2")`). Passing `apiKey:` /
  `authToken:` to `AnthropicGoogleCloud.copy` throws `ArgumentTypeError` (Python: `TypeError`).
* `AnthropicGoogleCloud.copy(workspaceID: .some(nil))` clears the workspace (Python's `workspace_id=None`).
* Google token providers are `async` closures, so Python's sync/async-provider distinctions
  (`asyncify`, "awaitable returned to the sync client") have no counterpart.
* The Bedrock event-stream decoder maps exception frames like botocore: the code and message come
  from the `:exception-type` header and payload for the exceptions in Bedrock Runtime's
  `ResponseStream` shape, else from `:error-code` / `:error-message`.
* Extra keys on streamed events (e.g. `amazon-bedrock-invocationMetrics`) are not kept by the
  typed Swift models.

## Core changes (additive)

* `BaseClient.baseURL` is now `open var` (lock-protected, trailing slash enforced on assignment):
  Python allows `client.base_url = ...`, and `AnthropicGoogleCloud` derives its base URL lazily.
* `Anthropic.apiKey` / `authToken` are `public internal(set) var`: the platform clients and the
  scoped-client helper reset them after construction, as the Python code does.

## Upstream tests not ported

Sync/async twins are ported once (the async variant). Beyond that:

| Upstream test | Reason |
| --- | --- |
| `test_aws.py::test_ambient_first_party_credentials_do_not_warn`, `test_google_cloud.py::test_no_spurious_env_shadow_warning` | Python logging of the first-party credential chain (`lib/credentials`), which is not part of this port and does not log in Swift. |
| `test_aws.py::test_copy_accepts_credentials_none_noop[_async]`, `test_copy_rejects_real_credentials_provider[_async]` | The Swift `Anthropic.copy` has no `credentials:` parameter (the credentials-provider port lives in `Lib/Credentials`). |
| `test_aws.py`, `test_bedrock.py`, `test_bedrock_mantle.py`: `test_sigv4_signing_runs_off_event_loop*`; `test_google_cloud.py::test_sync_token_provider_on_async_client_runs_off_event_loop` | Python threading / `asyncify`; Swift signing and token providers are already async. |
| `test_google_cloud.py::test_async_token_provider_on_sync_client_rejected_clearly` | There is no sync client; providers are async closures. |
| `test_bedrock.py::test_beta_tool_runner_routes_through_invoke[_async]`, `test_vertex.py::test_beta_tool_runner_routes_through_raw_predict` (both classes), `test_bedrock.py::test_beta_messages_helpers_are_bound`, `test_vertex.py::test_beta_messages_helpers_are_bound` | The tool runner and `parse` / `stream` helpers are not part of this port (owned by the helpers port); the request rewriting they exercise is covered by the `create` tests. |
| `test_bedrock_mantle.py::TestUserProfileID` `beta_parse` / `beta_tool_runner` / `stream` (`MessageStream`) parametrizations | Same: helpers not in this port. `stream` is covered with the raw `createStreaming`, plus `beta.messages.createStreaming`. |
| `test_stainless_helpers.py::test_parse_*` (3 tests × sync/async) | `beta.messages.parse` helper not in this port. |
| `test_stainless_helpers.py::test_count_tokens_takes_a_tool_object` | Python duck typing (`tools=` taking objects with `to_dict()`); Swift tools are typed params. |
| `test_stainless_helpers.py::test_caller_tag_is_appended_not_clobbered`, `test_file_upload_tag_is_appended_not_clobbered` | Adapted, not ported 1:1: Swift values cannot carry Python's hidden `_stainless_helper` attribute and the generated resources do not collect tags, so the tests pass the helper header through `extraHeaders` and check the append-not-clobber behaviour on the wire. |
| `test_vertex.py::test_refresh_without_google_auth_raises_actionable_error`, `test_google_cloud.py::test_refresh_without_google_auth_raises_actionable_error` | `MissingDependencyError` for the optional `google-auth` package; Swift has no optional dependency (`lib/_extras/_common.py` is not ported for the same reason). |
| `test_google_cloud.py::test_bearer_token_not_in_debug_logs` | The Swift client does no debug logging of requests. |
| `test_google_cloud.py::test_base_credential_chain_never_engages[_async]`, `test_resolvable_profile_cannot_leak[_async]` | Exercise the first-party credential chain (`ANTHROPIC_PROFILE`, `ANTHROPIC_CONFIG_DIR`, `default_credentials`), not in this port; the api-key / auth-token isolation they also check is covered by `GoogleCloudIsolationTests`. |
| `test_google_cloud.py::test_api_key_and_auth_token_rejected` (both classes) | Enforced at compile time: the initializer has no such parameters. |
| `*::test_user_profiles_not_available`, `test_bedrock_mantle.py::TestEndpointRestrictions` (`not hasattr`), `TestAsyncClient::test_async_client_has_same_restrictions` | Enforced at compile time: the properties do not exist on `AnthropicBedrock` / `AnthropicBedrockMantle` / `AnthropicVertex` / their beta resources. |
| `test_bedrock.py::test_stream_skips_typeless_chunk[_async]` — the `events[1].to_dict()["amazon-bedrock-invocationMetrics"]` assertion | Typed Swift models do not keep unknown keys; the rest of the test is ported. |
| `test_scoped_client.py::test_clears_inherited_credentials_provider` | No credentials provider on the Swift `Anthropic` in this port. |
| `test_scoped_client.py::test_keeps_the_host_and_headers_of_the_parents_credential[_async]` | Uses a credentials `config=` profile (not in this port); ported as `keepsTheHostOfTheParent` with an explicit base URL and workspace header. |
| `test_scoped_client.py::test_scoped_client_and_its_copy_keep_what_the_parent_read_from_the_environment`, and the `open_telemetry` assertions of `test_copy_of_a_scoped_client_keeps_its_bearer_alone` | OpenTelemetry options are not ported to Swift. |
| `test_azure.py::test_copy` — `copied._client is client._client` | Ported as "the copy keeps the transport". |
