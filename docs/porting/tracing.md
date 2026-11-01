# OpenTelemetry tracing: what was ported, skipped, and changed

Port of `src/anthropic/_tracing.py` and `src/anthropic/lib/_tracing/` to `Sources/Anthropic/Lib/Tracing/`, and of
`tests/test_open_telemetry.py` and `tests/test_tracing.py` to `Tests/AnthropicTests/Lib/Tracing/`.

## The tracing API

There is no OpenTelemetry package that builds offline with Foundation only, so the SDK defines the subset of the
OpenTelemetry API that it uses, and an application bridges it to its tracing system by implementing `TracerProvider`
(and, for propagation, `TextMapPropagator`).

| File | What |
| --- | --- |
| `OpenTelemetryAPI.swift` | `AttributeValue`, `SpanContext` (`TraceID`, `SpanID`, `TraceFlags`, `TraceState`), `Span`, `NonRecordingSpan`, `Tracer` (`startSpan`, `withActiveSpan` = `start_as_current_span`), `TracerProvider`, `NoOpTracerProvider`; `TracingContext`: the current span and baggage, task-local (`trace.use_span` = `TracingContext.withSpan`); `TextMapPropagator` with the W3C `TraceContextPropagator` (`traceparent` / `tracestate`), `BaggagePropagator` and `CompositePropagator`; `OpenTelemetry`: the registered provider and propagator (`set_tracer_provider` / `set_global_textmap`), with task-scoped overrides (`withTracerProvider`, `withPropagator`) that the tests use, since they run in parallel. |
| `OpenTelemetrySDK.swift` | The recording implementation (`opentelemetry.sdk.trace`): `SDKTracerProvider` with a `Sampler` (`AlwaysOn`, `AlwaysOff`, `ParentBased`), an `IDGenerator` and `SpanProcessor`s; `RecordingSpan`, `SpanData` (`ReadableSpan`), `SimpleSpanProcessor`, `InMemorySpanExporter`. A failing sampler or processor, and a change to an ended span, are recorded in `loggedWarnings` (the SDK's warning log). |
| `OpenTelemetryOptions.swift` | The `openTelemetry:` client option (`OpenTelemetryOptions`, `OpenTelemetryTraces`, `OpenTelemetryContentMode`; `.disabled` is Python's `False`), its resolution and the `ANTHROPIC_OPEN_TELEMETRY*` variables (`resolve_open_telemetry`, `env_open_telemetry`), `OpenTelemetryConfig` (`_config.py`), `getTracer`. |
| `Tracing.swift` | `_tracing.py`: `ApiCall`, `ApiCallResult`, `startApiCallSpan`, trace header injection and removal, `endApiCallSpan(WhenBodyEnds)`, `StreamObserver`, `StreamedBodyObserver`, `FirstEnd`, the URL attributes (`definedQuery`, `isContentQuery`), `errorType`, and `_attributes.py`. |
| `ApiCallSpan.swift` | `_api_call.py` and `_response.py`: the response attributes, created IDs, and the start attributes of `messages.create`, `messages.count_tokens`, `messages.batches.create` and `sessions.create`. |
| `Content.swift` | `_content.py` and `_utils.py`: the content attributes and their size bound. `OrderedJSON` keeps the key order of a Python `dict`, and writes JSON as `json.dumps(..., separators=(",", ":"), ensure_ascii=False)` does. |
| `StreamedMessage.swift` | `_streaming.py`: a streamed Message recorded as the application reads it. |
| `ToolAndWorkSpans.swift` | `_tools.py` and `_work.py`: `startToolRunnerSpan`, `withToolUseSpan`, `ToolRun`, `WorkSpan`, for the tool runners and the environment worker. |
| `ClientTracing.swift` | `AsyncAPIClient.request`: the call span around the retry loop. |

The instrumentation scope is `com.anthropic.sdk.swift` (`.<platform>` for a platform client), as `X-Stainless-Lang`
reports `swift`.

## How it is wired in

* `BaseClient(openTelemetry:openTelemetryEnvironment:)` resolves the option once (`client.openTelemetry` reads it back,
  with every field set); `Anthropic` and each platform client take `openTelemetry:` in `init`, `copy` and
  `withOptions`, and a copy that is given none keeps the client's resolved option. `genAIProviderName` and
  `otelPlatform` are overridden by the platform clients (`_gen_ai_provider_name`, `_otel_platform`).
* Every typed entry point (`requestResponse`, `requestStreamResponse`, `requestPageResponse`, `requestJSONLResponse`,
  `requestBinaryResponse`, `requestHTTPResponse`) goes through `tracedRequest`: it prepares the options, starts the call
  span, runs the retry loop with the span current, and finishes the span with the result. A parsed call is parsed there
  (cached), as `_process_response` runs inside `_request` in Python, so the span has the response.
* `attemptRequest` counts each attempt on the `ApiCall` and records the URL of the first; it removes the trace headers
  before `prepareRequest` (which may sign the request) and injects them after. A traced call builds its own middleware
  chain (`buildMiddlewareChain(call:)`), as upstream's `_build_middleware_chain(call)`.
* `HTTPResponse` carries the `streamObserver` (Python's `response.stream.stream_observer`): reading the body to its
  end, a failure, `close()`, and dropping the response (`deinit`) report how the body ended. `Stream` calls `begin`,
  `item` and `end` on it. `MessageStream` / `BetaMessageStream` give their snapshots to the span's `StreamedMessage`
  (`share_message_snapshot`), and withhold them when an event cannot be accumulated.
* `FinalRequestOptions` gained `spanQueryParams`, `spanContentQueryParams`, `spanAttributes`, `spanBodyAttributes` and
  `spanCreatedID`; `ParamsBuilder.keys` is every query parameter the method declares.

## Transpiler

`Tools/codegen/resourcesgen.py` now passes `span_route`, `span_attributes`, `span_created_id` and
`span_content_query_params` of `make_request_options` to `makeRequestOptions`. A dict of path parameters becomes
`spanAttributes:`; the four `lambda body: ...` / function forms map to the Swift functions of `ApiCallSpan.swift`
(`spanBodyAttributes:`). Anything else is reported as unsupported.

## Differences from Python

* A Swift response always decodes into its type (there is no `_strict_response_validation=False`). Upstream tests that
  give a call a body with only the fields that the span reads make the call with `withRawResponse` here, whose body is
  read and not decoded: the span reads it all the same. List calls whose canned page does not decode fail after their
  request was sent, which leaves the URL attributes as they are.
* A request is typed, so requests with content that no param type has send their `messages` (or `system`,
  `stop_sequences`, `agent`, `requests`) as `extraBody`, which is merged into the body that the span reads.
* `JSONValue` keeps no key order, so the JSON of a block that came from the request or the response has its keys
  sorted; the parts that the SDK makes have Python's order. Sizes do not depend on the order.
* A stream helper's snapshot is a typed Message re-encoded to JSON, which leaves out a `null` optional field
  (`page_age: None` in a streamed web search result).
* A response made from bytes is closed from the start in httpx; a Swift `HTTPResponse` with a whole body is not closed
  until it is read, so `stream.response.is_closed` is not asserted.
* Dropped streams and responses end their span in `deinit`, which Swift runs when the last reference goes, so the
  `del ...; gc.collect()` tests are ported as values that go out of scope.

## Tests

| Upstream | Swift | Notes |
| --- | --- | --- |
| `tests/test_tracing.py` | `OpenTelemetryOptionTests.swift` (`TracingModuleTests`) | all, async only |
| `TestCallSpans` | `OpenTelemetryCallSpanTests.swift` | |
| `TestHttpAttributes` | `OpenTelemetryHTTPAttributeTests.swift` | |
| `TestTracesOption`, `TestPropagationOption`, `TestConversationId` | `OpenTelemetryOptionTests.swift` | |
| `TestContent` | `OpenTelemetryContentTests.swift` | |
| `TestResourceIds`, `TestMalformedResponses`, `TestMalformedCountsAndBatches`, `TestTracingFailures`, tripwires | `OpenTelemetryResourceTests.swift` | |
| (`_tools.py`, `_work.py` helpers) | `TracingWorkAndToolSpanTests.swift` | Swift-only checks of the helpers that the runners call |

Only the async variants are ported (`SYNC_AND_ASYNC` parametrizations run once; a sync test whose async twin exists is
the twin). Sync-only upstream tests are ported against the async client.

## Skipped upstream tests

### `tests/lib/tools/test_open_telemetry.py`

Skipped whole: it drives the tool runners, which another agent is porting concurrently. The span helpers that the runners
call are ported (`ToolAndWorkSpans.swift`) and checked in `TracingWorkAndToolSpanTests.swift`.

### `tests/test_open_telemetry.py`

| Test | Reason |
| --- | --- |
| every sync twin of an async test (`test_x` beside `test_async_x`, and the `sync` case of `SYNC_AND_ASYNC`) | Sync client. |
| `test_request_body_that_cannot_be_prepared_has_no_span` (and async) | Python reads file paths in a body when it prepares it; a Swift body is typed and encoded by the method before the call. |
| `test_a_failure_to_record_attributes_does_not_fail_the_api_call` | Monkeypatches a private function to raise; the Swift recorder has no throwing path. |
| `test_a_body_read_the_wrong_way_can_still_be_read_the_right_way` | Reading an httpx body with the sync API in an async client and back. |
| `test_async_dropped_stream` | A real socket server and the asyncio event loop closing generators; the dropped stream itself is `droppedStream`. |
| `test_async_call_reads_the_platform_off_the_event_loop` (thread half) | asyncio's worker thread; the `anthropic.beta` half is `betaHeaderOfTheClientsDefaultHeadersIsOnTheSpan`. |
| `test_server_attributes_are_on_the_span_from_its_start_only` (half) | The half that monkeypatches `SdkSpan.set_attribute` to see that `server.*` is never set later; the sampler half is `serverAttributesAreOnTheSpanFromItsStart`. |
| `test_sigv4_signature_does_not_cover_the_trace_headers_that_the_sdk_replaces`, `test_signed_request_without_propagation_keeps_a_valid_signature` (half) | Recomputing the signature with botocore; that the header is (or is not) in `SignedHeaders` is ported. |
| `test_stream_over_a_stand_in_for_the_response`, `test_stream_helper_over_a_stand_in_for_the_stream` | Duck-typed stand-ins for a response and a stream; ported as a stream over a response that no call returned, and a helper over a stream without events. |
| `test_a_redirect_is_not_a_request_of_the_sdk` | Redirects are the transport's (`URLSession` follows them, `MockTransport` does not). |
| `test_option_types_are_exported` | Python's `__all__`; the Swift types are public declarations. |
| `test_debug_logging_dumps_the_request_options_with_their_span_fields` | Python's debug log of the pydantic options model. |
| `test_methods_have_no_keyword_for_it` | A `TypeError` for an unknown keyword; the Swift compiler rejects it. |
| `test_copy_of_a_client_whose_constructor_takes_no_open_telemetry_keeps_the_option` | A Python subclass with an `__init__` of its own that `copy` calls; a Swift subclass overrides `copy`. |
| `test_stream_helper_content_comes_from_its_snapshot`, `test_stream_read_without_the_stream_helper_records_everything_but_its_content` (halves) | `count_accumulated_events` monkeypatches `accumulate_event`; the Swift recorder accumulates its JSON on its own. The span assertions are ported. |
| `TestMalformedResponses.test_create`, `test_async_create`, `test_stream_read_without_the_stream_helper` (and async), `test_stream_helper` | A malformed body does not decode in Swift, so the call throws `APIResponseValidationError` instead of returning a result. `test_raw_response` is ported (a raw body is not decoded), and what `set_response` makes of each malformed Message is `setResponseReadsWhatItCan`. |
| `TestMalformedCountsAndBatches` parsed halves | Same; the raw halves are ported. |
| `test_a_url_that_cannot_be_recorded_leaves_the_call_as_it_is` | Monkeypatches `set_url_attributes` to raise; the Swift function cannot throw. |
| `test_a_propagator_that_is_not_installed_fails_neither_the_import_nor_a_call` | `OTEL_PROPAGATORS` read by `opentelemetry.propagate` at import, in a subprocess. |
| `test_global_tracer_provider_that_cannot_be_loaded_leaves_the_client_without_spans`, `..._platform_clients_without_spans` | `OTEL_PYTHON_TRACER_PROVIDER` naming a provider that is not installed, and the debug log; ported as `registeredTracerProviderThatCannotGiveATracerLeavesTheClientWithoutSpans`, with a registered provider that throws. |
| `test_usage_iteration_types_are_all_recorded_or_left_out`, `test_message_block_types_are_all_a_part_with_content_or_with_only_their_type`, `test_tool_result_block_types_all_keep_their_fields_or_only_their_type`, `test_result_block_list_types_all_keep_their_fields_or_only_their_type`, `test_types_in_result_blocks_are_all_kept_or_lose_their_data`, `test_view_result_file_types_all_keep_or_lose_their_content`, `test_stream_event_types_are_all_handled_or_passed_over` | Tripwires over pydantic type hints (union members, `Literal` values); the generated Swift enums cannot be enumerated at runtime. `test_usage_fields_are_all_recorded_or_left_out` is ported with `Mirror`. |

### `tests/test_tracing.py`

| Test | Reason |
| --- | --- |
| `test_tracer_provider_that_is_not_installed_leaves_a_client_without_spans` | `OTEL_PYTHON_TRACER_PROVIDER`; ported as `tracerProviderThatCannotGiveATracerLeavesAClientWithoutSpans`, with a registered provider that throws. |
| the `sync` case of every test | Sync client. |
