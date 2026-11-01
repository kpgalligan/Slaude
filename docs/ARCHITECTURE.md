# Slaude architecture

Slaude is a Swift implementation of the Claude API client, produced by **source transformation of the
official Python SDK** (`anthropic`, vendored at `upstream/anthropic-sdk-python`, currently **2.3.0**).

## Why Python (not TypeScript)

The Python sdist ships the complete upstream test suite (`tests/`, ~110k lines), so every
upstream test can be ported 1:1 and run against the Swift code. The npm package of the TypeScript
SDK ships sources only. Python's explicit, one-class-per-file models also map directly onto Swift
structs.

## Layout

| Path | What | Origin |
| --- | --- | --- |
| `upstream/anthropic-sdk-python/` | The tracked Python SDK (src + tests), unmodified | vendored |
| `Tools/codegen/` | The transpiler (Python `ast` → Swift) | hand-written |
| `Sources/Anthropic/Generated/Types/` | One file per `anthropic/types/**.py` module | **generated** |
| `Sources/Anthropic/Generated/Resources/` | One file per `anthropic/resources/**.py` module | **generated** |
| `Sources/Anthropic/Core/` | Port of `_base_client`, `_streaming`, `_qs`, `_exceptions`, `pagination`, ... | hand-ported |
| `Sources/Anthropic/Client.swift` | Port of `_client.AsyncAnthropic` | hand-ported |
| `Sources/Anthropic/Lib/` | Port of `anthropic/lib/**` (helpers, tool runners, platform clients) | hand-ported |
| `Sources/Anthropic/Lib/Platforms/`, `Lib/Crypto/` | AWS / Bedrock / Vertex / Google Cloud / Foundry clients, SigV4, pure-Swift SHA-256 / HMAC / CRC32 / RSA (see `docs/porting/platforms.md`) | hand-ported |
| `Sources/Anthropic/Lib/Tracing/` | OpenTelemetry tracing of API calls: a small tracing API (tracer provider, spans, task-local context, W3C propagation) with an in-memory SDK, and the call spans (see `docs/porting/tracing.md`) | hand-ported |
| `Tests/AnthropicTests/Generated/` | One file per `tests/api_resources/**.py` | **generated** |
| `Tests/AnthropicTests/Support/` | Test helpers (`MockRoute`, ...) | hand-written |
| `Tests/AnthropicTests/Core/`, `Tests/AnthropicTests/Lib/` | Ports of the other upstream tests | hand-ported |
| `docs/porting/` | What the transpiler could not handle, regenerated each run | generated |

Never edit generated files by hand: change the transpiler and run
`python3 -I Tools/codegen/generate.py`.

## Mapping rules

* `AsyncAnthropic` → `Anthropic` (Swift concurrency only; the sync twin is redundant in Swift).
* `class X(BaseModel)` / `class X(TypedDict)` → `struct X: Codable, Hashable, Sendable` with `CodingKeys`
  mapping snake_case keys to camelCase properties (`message_id` → `messageID`).
* `Literal["a", "b"]` → `enum: OpenEnum` with an `unknown(String)` case (forward compatible, like Python's
  runtime behaviour). Inline literals become nested enums named after the field.
* `Union[...]` → `indirect enum` with one case per variant plus `unknown(JSONValue)`. Discriminated unions
  (`UnionDiscriminator("type")`, or variants with distinct constant `type` fields) decode by discriminator;
  others try each variant in order. Unions with a `str` variant are `ExpressibleByStringLiteral`.
* Field optionality: model `Optional[X] = None` → `X?`; params `Required[X]` → `X`, not-required → `X?`,
  not-required and nullable → `X??` (`nil` = omit, `.some(nil)` = send `null`).
* Helper classes declared in a module (not its primary export) are nested in the primary type.
* Name clashes between top-level types get the package path as prefix (`types/beta/x.py: X` → `BetaX`
  when `types/x.py: X` exists); types clashing with runtime names (e.g. the `RateLimitError` model vs. the
  exception) get the package prefix too (`SharedRateLimitError`).
* Resource classes → `struct <Path>Resource` (e.g. `beta/messages/batches.py: AsyncBatches` →
  `BetaMessagesBatchesResource`). Each method `m(...)` exists three ways, like Python:
  `resource.m(...)` (parsed), `resource.withRawResponse.m(...)` (→ `APIResponse<T>`, body read), and
  `resource.withStreamingResponse.m(...) { response in ... }` (body not read eagerly).
  The keyword arguments `extra_headers`, `extra_query`, `extra_body`, `timeout` become
  `extraHeaders:`, `extraQuery:`, `extraBody:`, `timeout:`.
* `create(stream=True)` overloads → a separate `createStreaming(...)` returning `Stream<Event>`.
* `AsyncPaginator[T, AsyncPage[T]]` → `Page<T>` (awaiting gives the first page; iterating a page
  auto-paginates through all items, `iterPages()` yields pages).
* Exceptions → classes deriving from `AnthropicError` with the same names (`RateLimitError`, ...).
  Python built-ins raised for argument errors map to `ValueError` / `ArgumentTypeError` structs.
* Telemetry headers report `X-Stainless-Lang: swift` (upstream tests asserting `"python"` are ported to
  assert `"swift"`).

## Testing

`swift test` runs everything. The upstream API-resource tests run against a mock server generated from
the OpenAPI spec; that spec isn't distributed, so each generated Swift test uses a `MockRoute` that:

1. asserts the HTTP method and path template,
2. decodes the JSON request body into the endpoint's `*Params` type and checks it re-encodes to the same
   JSON (catches wrong keys/shapes),
3. answers with a sample built from the response type, and the test checks the decoded response
   re-encodes to that sample.

Hand-ported tests use `MockTransport` (the counterpart of `httpx2.MockTransport` / `respx`).

## Conventions for hand-ported code

* Keep the upstream structure and names (camelCased); put a `/// Port of ...` reference where helpful.
* Only use Foundation (no third-party packages): the toolchain must build offline.
* Swift 6 strict concurrency: public types are `Sendable`.
