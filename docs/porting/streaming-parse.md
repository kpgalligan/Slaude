# Message streaming, structured outputs, refusal fallbacks, batch results

Hand ports of `anthropic/lib/streaming`, `anthropic/lib/_parse`, `anthropic/lib/middleware` and the
resource methods the transpiler skips (`messages.stream`, `messages.parse`, `messages.batches.results`
and their `beta` twins).

## Where things live

| Upstream | Swift |
| --- | --- |
| `lib/streaming/_messages.py`, `_types.py` | `Sources/Anthropic/Lib/Streaming/MessageStream.swift`, `MessageStreamEvents.swift` |
| `lib/streaming/_beta_messages.py`, `_beta_types.py` | `Sources/Anthropic/Lib/Streaming/BetaMessageStream.swift`, `MessageStreamEvents.swift` |
| `jiter.from_json(..., partial_mode=...)` | `Sources/Anthropic/Lib/Streaming/PartialJSON.swift` (the parser is `Core/JSONText.swift`, shared with `RawJSON.parse`) |
| — (verbatim JSON: `createStreaming(body:)`) | `Sources/Anthropic/Lib/Streaming/JSONMessageStream.swift`, `Core/RawJSON.swift`, `Core/JSONStreamEvent.swift` |
| `messages.stream`, `beta.messages.stream` | `Sources/Anthropic/Lib/Streaming/MessagesStreamResource.swift` |
| `messages.batches.results`, `beta.messages.batches.results` | `Sources/Anthropic/Lib/Streaming/BatchResults.swift` |
| `lib/_parse/_transform.py`, `_response.py` | `Sources/Anthropic/Lib/Parse/StructuredOutput.swift`, `ParsedMessage.swift` |
| `messages.parse`, `beta.messages.parse`, `count_tokens(output_format=)` | `Sources/Anthropic/Lib/Parse/MessagesParseResource.swift` |
| `lib/middleware/_fallbacks.py` | `Sources/Anthropic/Lib/Middleware/RefusalFallback.swift` |

## Design notes

* **Structured outputs.** Python derives the schema from a pydantic type. A Swift type adopts
  `StructuredOutput` (`Decodable` plus `static var jsonSchema: JSONValue`); the SDK runs the schema
  through `transformSchema` and sends it as `output_config.format`, then decodes each text block
  with the SDK's JSON decoder. `parse` / `stream` take `outputFormat: T.self`; calls without one
  return `ParsedMessage<Never>` / `MessageStream<Never>`.
* `ParsedMessage<Output>` / `ParsedBetaMessage<Output>` wrap the generated `Message` /
  `BetaMessage` (every property is reachable through `@dynamicMemberLookup`) and keep the parsed
  values beside the content (`parsedOutput`, `parsedOutput(at:)`). Encoding produces the plain
  message, so `parsed_output` never reaches the wire. (The generated `ParsedMessageParsed*` unions
  from `types/parsed_message.py` are not used.)
* **Stream events.** `ParsedMessageStreamEvent` / `ParsedBetaMessageStreamEvent` are enums over the
  raw events plus the helper events (`.text`, `.inputJson`, `.citation`, `.thinking`, `.signature`,
  `.compaction`); events the stream does not process (unknown types, anything before
  `message_start`) pass through as `.raw(...)`. The names avoid the generated aliases
  `MessageStreamEvent` / `MessageStopEvent` / `ContentBlockStopEvent` (= the raw types).
* **Verbatim JSON.** `createStreaming(body:)` (GA and beta) sends a `RawJSON` body unchanged and returns a
  `JSONMessageStream`: each event is a `JSONStreamEvent` (the SSE name, the data as `RawJSON` in document order, the
  typed event, and `decodingError` when a known event did not decode). `JSONMessageAccumulator` is
  `accumulate_event` over that JSON, so the Message keeps every field the API sent: `message`, `messageParam` (the
  turn to append to a history) and `isComplete` (`message_stop` seen). A tool input is parsed at its
  `content_block_stop` in partial mode (`trailingStrings` with the fine-grained tool streaming beta, as the typed
  streams do), keeping the model's key order; an input that is not JSON raises the upstream `ValueError` there.
  `RawJSON.parse` and `PartialJSON` share one parser, which accepts only the JSON grammar (no leading zeros) and nests at
  most 64 levels (it recurses per level, on a task's 512 KiB stack).
* `stream(...)` is `async throws` and returns once the response headers arrived (Python's
  `async with` entering the manager). A stream is one sequence: iterating it, `textStream`,
  `untilDone()` and `getFinalMessage()` all continue where the previous consumer stopped.
* **Cancellation and early ends.** A Messages stream ends normally only after `message_stop` (`StreamEndEvent` in
  `Core/Streaming.swift`). Before it, a cancelled task or `close()` makes every read throw `CancellationError`, and a
  body that ends or breaks makes every read throw `StreamEndedEarlyError`; `getFinalMessage()` /
  `getFinalText()` of `MessageStream`, `BetaMessageStream`, `BetaThreadMessageStream` and `JSONMessageStream` throw
  rather than return a partial message (upstream returns the snapshot). `messageComplete` (typed) and `isComplete`
  (JSON) say whether `message_stop` arrived. `textStream` is a `MessageTextStream` rather than an
  `AsyncThrowingStream(unfolding:)`, which would end without an error in a cancelled task. A tool input that does not
  parse ends a `JSONMessageStream` with that error (`Stream.fail`), which later reads rethrow.
* **Refusal fallbacks.** `BetaRefusalFallbackMiddleware` conforms to the core `Middleware` protocol.
  Python's context variable becomes a task-local: `BetaFallbackState().run { ... }` replaces
  `with state:`. Python logs to `anthropic.lib.middleware`; Swift takes a `MiddlewareLogger`
  (stderr by default). The streaming splice is a pull-driven state machine (the Python generator),
  so a hop request is only sent once the consumer has read up to the refusal.
* `transformSchema` lists leftover keywords in the description in sorted key order (`JSONValue`
  objects are unordered); Python uses the schema's insertion order. An unsupported `type` throws
  `ValueError` (Python: `AssertionError` from `assert_never`).

## Changes outside these directories

* `Core/RequestOptions.swift`, `Core/ResourceSupport.swift`: `FinalRequestOptions.qualifiers`
  (Python's `make_request_options(qualifiers=...)`) and a `qualifiers:` argument to
  `makeRequestOptions`. The middleware only handles requests marked `["beta": "true"]`.
* `Tools/codegen/resourcesgen.py`: emits `qualifiers: ["beta": "true"]` for the beta resources
  (regenerated; only `Generated/Resources/beta.*` changed).
* `Core/BaseClient.swift`: `Middleware.handle(_:next:)` takes `next` as `@escaping` — the streaming
  splice issues hop requests after `handle` returned, while the client reads the body.
* `Core/Streaming.swift`: `SSEDecoder.events(from:)` and `Stream` decode on demand instead of
  draining the body in a background task, and `Stream` only takes the body when iteration starts
  (so `stream.response.read()` still returns the raw bytes). Abandoning an iterator still closes
  the response.

## Upstream tests not ported

Sync test classes (`TestSync*`, and the sync halves of `test_refusal_fallback*.py`) are covered by
the async ports. Where a test only existed in a sync class it was ported as an async test.

| Test | Reason |
| --- | --- |
| `streaming/test_messages.py::TestAsyncMessages::test_file_input_is_read_when_the_stream_is_entered` (and the beta twin) | Swift's `Base64ImageSourceParam.data` is `Data`: there is no deferred file read on an event-loop thread to observe. |
| `streaming/test_messages.py::test_stream_method_definition_in_sync`, `streaming/test_beta_messages.py::test_stream_method_definition_in_sync`, `::test_parse_method_definition_in_sync` | `assert_signatures_in_sync` is Python signature introspection; the Swift methods are written against `create`'s argument list and the compiler checks every forwarded argument. |
| `streaming/test_beta_messages.py::test_tool_runner_method_definition_in_sync` | Signature introspection, like the other `*_method_definition_in_sync` tests; that `toolRunner` / `streamingToolRunner` send the requests `create` would is checked by `RunnerFromParamsTests` (see `tools.md`). |
| `streaming/test_parsed_content_blocks.py::test_parsed_union_matches_generated_union` | There is no hand-written parallel union to drift: `ParsedMessage` wraps the generated `ContentBlock` / `BetaContentBlock`. |
| `test_output_format_helpers.py::test_count_tokens_rejects_a_schema_dict`, `::test_stream_rejects_a_schema_dict`, `::test_async_count_tokens_rejects_a_schema_dict`, `api_resources/beta/test_output_format_conversion.py::test_stream_rejects_schema_dict` | `outputFormat:` only accepts a `StructuredOutput` type, so passing a schema dictionary does not compile. |
| `api_resources/beta/test_output_format_conversion.py::TestOutputFormatNoDeprecationWarning::test_no_warning_when_output_format_not_provided`, `::test_no_warning_when_using_output_config`, `::test_parse_does_not_warn_for_type` | Swift has no deprecated `output_format` request path that could warn (`streamWithOutputFormatDoesNotWarn` covers the typed path). |

Tests ported in adapted form:

* `test_tracks_tool_input_type_alias_is_up_to_date` (both files): pydantic field introspection
  becomes a check that every content block type with an `input` accumulates `input_json_delta`.
* `test_message_delta_fields_are_all_accumulated` (both files): fields are listed with `Mirror`.
* `test_parsed_output_is_readable_but_not_dumped`: copies are value copies in Swift.
* `TestBetaFallbackState::test_one_state_shared_across_threads`: two concurrent tasks share a state.
* `api_resources/messages/test_batches.py::test_method_results` (and beta): the results lines are
  valid `MessageBatchIndividualResponse`s (Swift decoding is strict; Python constructs `{"foo": "bar"}` loosely).
* `_parse` snapshot tests replay the recorded `http_snapshot` exchanges (`__inline_snapshot__/*.json`)
  and additionally check the request's `output_config` against the recording.
