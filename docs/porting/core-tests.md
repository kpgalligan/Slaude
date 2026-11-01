# Core runtime tests: what was ported, skipped, and changed

Hand-ported (not generated) ports of the upstream core test suite live in `Tests/AnthropicTests/Core/`.
Each suite is named after the upstream file it ports. Only the async variants are ported (`AsyncAnthropic`
→ `Anthropic`); sync-only upstream tests that test client behaviour (not sync-ness) are ported against
the Swift client and marked "Sync-only upstream" in a comment.

| Upstream file | Swift file | Notes |
| --- | --- | --- |
| `tests/test_client.py` (`TestAsyncAnthropic` + module tests) | `ClientTests.swift` | |
| `tests/test_middleware.py` | `MiddlewareTests.swift` | |
| `tests/test_header_case_sensitivity.py` | `HeaderCaseSensitivityTests.swift` | |
| `tests/test_streaming.py` | `StreamingTests.swift` | |
| `tests/decoders/test_jsonl.py`, `tests/test_qs.py`, `tests/test_utils/test_path.py`, `test_datetime_parse.py`, `test_json.py` | `UtilsTests.swift` | |
| `tests/test_response.py`, `tests/test_files.py`, `tests/test_extract_files.py` | `ResponseAndFilesTests.swift` | |
| `tests/test_models.py`, `tests/test_prepare.py` (parts with a Swift meaning) | `ModelsTests.swift` | |

## Skipped upstream tests

### `tests/test_client.py`

| Test | Reason |
| --- | --- |
| all of `TestAnthropic` | Sync client; the async twins are ported. |
| `test_copy_signature` | Reflection over `__init__` / `copy` signatures; Swift's are checked by the compiler. |
| `test_copy_build_request` | `tracemalloc` memory-leak check (already skipped upstream on Python ≥ 3.10). |
| `test_http_client_timeout_option`, `test_method_default_timeout_http_client_option` | Timeouts configured on an `httpx.AsyncClient`; Swift transports don't carry a timeout. |
| `test_invalid_http_client`, `test_httpx_objects_rejected` | httpx/httpx2 type checks; Swift's `HTTPTransport` is a protocol. |
| `test_request_data_prepared_before_prepare_options` | Preparation of untyped Python data (path objects, `Omit()` values, tuples, `datetime`s in dicts); Swift arguments are typed and encoded when the method builds the body. The `extra_body` half is `test_request_extra_json_merged_before_prepare_options`. |
| `test_request_extra_headers_httpx_headers` | Passing `httpx2.Headers` objects. |
| `test_binary_content_upload_with_asynciterator` | `content` is `Data` in Swift, not a lazily read async iterator. |
| `test_binary_content_upload_with_body_is_rejected` | Raw bytes can't be passed as a JSON `body` in Swift (type system). |
| `test_basic_union_response`, `test_union_response_different_types` | `cast_to=Union[...]` of ad-hoc pydantic models; union decoding of the generated types is covered in `ModelsTests`. |
| `test_copied_client_does_not_close_http`, `test_client_context_manager` | GC (`__del__`) and `async with` semantics; Swift closes the transport only on an explicit `close()`. |
| `test_client_max_retries_validation` | `max_retries=None`; `maxRetries` is a non-optional `Int`. |
| `test_received_text_for_expected_json` (non-strict half) | Non-strict validation returning the text for a model type; Swift decoding is always typed. The strict half is ported. |
| `test_retrying_*_doesnt_leak` (open-connection count) | No connection pool to inspect; ported as "every attempt's response is closed". |
| `test_every_attempt_has_the_qualifiers` | `qualifiers` is an OpenTelemetry option (tracing is owned elsewhere). |
| `test_platform_headers_do_not_spawn_subprocesses`, `test_proxy_environment_variables`, `test_default_client_creation` | Python `platform`/`subprocess` and httpx client construction specifics. `test_get_platform` is ported as a platform-header check. |
| `test_follow_redirects`, `test_follow_redirects_disabled` | Redirects are handled by the transport (`URLSession` follows them; `MockTransport` doesn't). `FinalRequestOptions.followRedirects` is not honoured by `URLSessionTransport` yet. |

### `tests/test_middleware.py`

| Test | Reason |
| --- | --- |
| `TestSyncMiddleware` (sync twins) | Sync client. Sync-only tests were ported against the async client. |
| `TestMiddlewareValidation` (except the request-handling test) | Python's runtime checks that sync clients get sync middleware and async clients async middleware, and that entries are callable; Swift's `Middleware` protocol makes these compile-time. |
| `test_construction_rejects_*`, `test_with_middleware_validates_like_the_constructor` | Same: enforced by the type system. |
| `test_middleware_iterator_argument_runs_middleware` | Passing a one-shot Python iterator; Swift takes an array. |
| `TestLibClientMiddleware` | Bedrock / Vertex / Mantle / Foundry clients are ported by another agent under `Sources/Anthropic/Lib/`. |
| Identity assertions (`message is cached`, `client._middleware_chain is chain`, `recorder.results[0] is file`) | Values are structs in Swift; ported as equality, or as identity of the underlying `HTTPResponse`. |
| `test_copy_inherits_replaces_and_clears_middleware`: `copy(middleware=None)` | `nil` means "inherit" in Swift; clear with `copy(middleware: [])`. |
| `test_middleware_sees_prepared_body`: file path in the body, `system=omit`, `extra_query={"q": omit}` | Swift has typed arguments (no path objects or `omit` sentinels); the `extra_body` / `extra_query` parts are ported. |

### `tests/test_streaming.py`, `tests/decoders/test_jsonl.py`, `tests/test_response.py`

| Test | Reason |
| --- | --- |
| sync parametrisations | Sync client. |
| `test_stream_has_what_its_subclass_sets_after_init`, `test_decoder_has_what_its_subclass_sets_after_init` | Subclassing `Stream`/`JSONLDecoder` and Python's copy-on-first-use; the Swift types are final. |
| `test_isinstance_check` | Trivial in Swift. |
| `test_extract_response_type_*`, `test_response_parse_mismatched_basemodel`, `test_response_parse_annotated_type` | Python typing introspection / pydantic. |
| `test_response_parse_expect_model_union_non_json_content`, `test_response_parse_pep604_union` | Unions of ad-hoc pydantic models and non-strict text fallback; see `ModelsTests` for unions. |
| `test_response_basemodel_request_id` (`obj._request_id`) | Swift models are plain structs; the request and workspace IDs are on `APIResponse` (`requestID`, `headers`). |

### `tests/test_files.py`, `tests/test_extract_files.py`

| Test | Reason |
| --- | --- |
| `TestDeepcopyWithPaths` | Copying Python containers without copying file objects; Swift values are copied by value. |
| `test_tuple_input`, `test_async_supports_anyio_path`, `test_unnamed_file_tuple_uses_base_name` (file objects), `test_string_not_allowed` | The Python `FileTypes` tuple/IO/anyio forms; Swift has one `FileUpload` type. |
| `test_multiple_files` (nested `documents[][file]`), `test_ignores_incorrect_paths`, `test_array_format_controls_file_field_names` | Swift has no generic `extract_files(paths:)`: generated methods move their (top-level) file arguments with `ParamsBuilder.setFile(s)`, which is tested. |

### `tests/test_models.py`, `tests/test_prepare.py`, `tests/test_utils/`

Most of `test_models.py` tests pydantic `construct()` leniency (mismatched values kept as-is), `model_dump`
/ `to_dict` options, pydantic v1/v2 compatibility, `TypeAliasType`, `Annotated`, `EagerIterable`, and the
discriminator cache. Swift decoding is typed (`Codable`), so those have no counterpart. Ported are the
semantics generated types do have: unknown fields, wire-name aliases, nested models, null vs omitted,
typed mismatches erroring, int/float conversion, ISO 8601 datetimes, open enums with unknown values,
discriminated unions (known, unknown and invalid variants), lists of unions, `str | list` unions.

Of `test_prepare.py`, the walk over untyped Python data (iterables, sets, generators, scalar subclasses,
file objects and path-likes, pydantic models, recursion limits, circular references, key order) has no
Swift counterpart; ported are omit vs `None`, `extra_body` merging, query params, empty queries, base64
file input and GET bodies. `test_extra_query_omit_removes_default_query` is not supported: `Query` values
can't be omitted in Swift.

`test_utils/test_proxy.py`, `test_reflection.py`, `test_typing.py`: Python runtime internals. The
`None`/`True`/`False` cases of `test_path.py::test_interpolation`: path values are `String`s in Swift.
The pydantic cases of `test_json.py` are covered by model encoding tests.

### Elsewhere

`tests/test_open_telemetry.py`, `tests/test_tracing.py`: tracing is ported by another agent.

## Core changes made while porting

Bugs found by the ported tests, and behaviour aligned with upstream:

* **Middleware** (`Core/Middleware.swift`, new): ported `_request.APIRequest` (method/url/headers/
  queryParams/json/timeout/maxRetries/castTo accessors, `copy(...)`) and `_middleware.Middleware` (default
  pass-through `handle`). The chain is built once per client; it runs per attempt inside the retry loop; a
  returned 4xx/5xx stays on the retry path and is turned into the typed error after the chain; errors
  thrown by middleware are not retried unless they are (or are caused by — new `ChainedError.cause`
  chain) a `RetryableError`, `APIStatusError` or `APIConnectionError`. Middleware can replace responses
  (`RawAPIResponse(_:for:)`) or short-circuit with a value (`RawAPIResponse.shortCircuit(_:for:)`).
  `RawAPIResponse` is now a class with a parse cache shared with the caller's `APIResponse`, so a value
  parsed in middleware is the value the caller gets (and a streamed body is never read twice).
* `extra_body` is merged into the body once before the retry loop (`_copy_and_prepare`), so
  `prepareOptions` and middleware see the body as sent.
* **Streams were read eagerly**: `Stream`, `SSEDecoder.events(from:)`, `JSONLDecoder` and
  `APIResponse.iterLines()` pumped the whole body into an unbounded buffer from a background task. They now
  pull one chunk per requested event, close the response when the stream and all its iterators are
  dropped (`test_dropped_response_is_closed_at_once`), and share a single position like Python's (iterating
  again continues). `parse()` of a raw response caches its value, so it returns the same `Stream`.
* `iterLines()` split a `\r\n` that straddled two chunks into two lines.
* SSE: an event with an empty `id:` and nothing else no longer dispatches (Python's `not self._last_event_id`).
* `HTTPHeaders` assignment keeps the casing it was last set with (httpx semantics) — `with_options`
  case variants (`test_with_options_headers_case_insensitive`).
* Retry-After: `now` is injectable (`calculateRetryTimeout(..., now:)`), numbers parse like Python's
  `float()` (no hex, `inf`/`nan` accepted), and HTTP dates tolerate any leading day name like
  `parsedate_tz`.
* Error responses closed before being read report `Error code: N` with no body (as upstream).
* `decodeBody`: `String` is the raw text (it used to unquote a JSON string), and `Bool`/`Int`/`Double`/
  `Data` parse from the text like Python's `cast_to=bool/int/float/bytes`.
* **Dates**: ported `_utils/_datetime_parse.py` (`DatetimeParse`) and use it to decode `Date` fields —
  previously one-digit components, `±HH` offsets, invalid offsets and µs/ns timestamps were wrong or
  rejected. Encoding dropped sub-millisecond precision (600 µs became `.001`); it now keeps microseconds.
* **Nullable vs omitted**: decoding `X??` params mapped an explicit `null` to "omitted"; a
  `KeyedDecodingContainer.decodeIfPresent` overload (`Core/NullableCoding.swift`) keeps `.some(nil)`.
* Multipart: a file without a filename is sent unnamed as `application/octet-stream`
  (`test_file_without_a_name_is_sent_unnamed`); it used to be named `upload`.
* `BaseClient.baseURL` and `timeout` are settable (Python's `client.base_url = ...`, `client.timeout = ...`;
  assigning the timeout counts as overriding it).

API additions: `APIRequest` members and `copy`, `RawAPIResponse` (now a class) `parse(as:)` cache,
`shortCircuit`, `cachedValue`; `Middleware` default `handle`; `ChainedError`; `sendRequest(_:stream:castTo:)`;
`requestHTTPResponse`, `request(HTTPResponse.self, ...)`, `get/post(..., as: HTTPResponse.self)`,
`requestStream`, a `content:` (raw body) argument on `request`/`post`; `APIResponse.parse(as: Stream<E>.self)`
/ `parse(as: JSONLDecoder<E>.self)`; `Anthropic.withOptions(middleware:)`; `DatetimeParse`.

Intentional differences: dates are sent as `...Z` rather than Python's `+00:00` (the API accepts both;
generated round-trip samples use `Z`); JSON objects have no key order (error messages render keys sorted);
blank lines in JSONL bodies are skipped instead of failing to parse.
