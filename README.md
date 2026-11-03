# Slaude — the Claude API in Swift

A Swift client for the [Claude API](https://docs.anthropic.com/en/api/), produced by **source
transformation of the official Python SDK** ([`anthropic`](https://pypi.org/project/anthropic/)),
which it tracks version for version. Currently tracking **anthropic 2.3.0** (API version `2026-10-21`).

- Every type in `anthropic/types` (2,181 modules) and every resource method in
  `anthropic/resources` is transformed by the transpiler in `Tools/codegen`.
- The upstream API-resource test suite is transformed too: 1,574 tests, each checking the request's
  method, path and body schema and the decoding of the response.
- The hand-written parts are ported by hand alongside their upstream tests: the client core (retries,
  streaming, pagination, middleware), message stream helpers, structured outputs, tool runners (incl.
  streaming and eager tools), memory/computer/browser/agent toolsets, message threads, environment
  workers, credentials (profiles, workload identity federation), OpenTelemetry tracing, refusal
  fallbacks, webhooks, and the AWS, Bedrock, Vertex, Google Cloud and Azure Foundry clients.
- ~3,800 tests in all. See [docs/porting/STATUS.md](docs/porting/STATUS.md) for the upstream → Swift
  map and what (if anything) was skipped, and why.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for how the transformation works and how Python
constructs map to Swift.

## Requirements

Swift 6.0+. Foundation only, no third-party dependencies. `swift build` and `swift test` pass with Swift 6.2.3
(Xcode 26.2) on macOS 26 (arm64, case-insensitive APFS), the only toolchain they were run with here. CI
([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) builds and tests on macOS with Xcode 26.2 and with the newest
Xcode 26, and on Linux in the `swift:6.4.2-noble` container.

```swift
// Package.swift
.package(url: "https://github.com/kpgalligan/Slaude", branch: "main")
// target dependency
.product(name: "Anthropic", package: "Slaude")
```

## Getting started

```swift
import Anthropic

let client = try Anthropic()  // reads ANTHROPIC_API_KEY (or pass apiKey:)

let message = try await client.messages.create(
    maxTokens: 1024,
    messages: [.user(UserMessageParam(content: "Hello, Claude"))],
    model: "claude-opus-5-5"
)
for block in message.content {
    if case .text(let text) = block { print(text.text) }
}
```

Keyword arguments are the Python ones in camelCase (`max_tokens` → `maxTokens`, `workspace_id` →
`workspaceID`). Every method also takes `extraHeaders:`, `extraQuery:`, `extraBody:` and `timeout:`.

### Streaming

```swift
let stream = try await client.messages.createStreaming(
    maxTokens: 1024,
    messages: [.user(UserMessageParam(content: "Write a haiku"))],
    model: "claude-opus-5-5"
)
for try await event in stream {
    if case .contentBlockDelta(let e) = event, case .textDelta(let d) = e.delta {
        print(d.text, terminator: "")
    }
}
```

Stream reading is lenient: an event, block or delta type this version does not know, or an event whose fields
drifted from the schema (a `null` where a number was expected), comes through as the `unknown` case with its JSON and
the stream goes on. The accumulating helpers (`stream(...)`) still take a drifted event into the Message, losing only
the fields that do not decode: a block whose start did not decode is kept as its JSON and takes its deltas (and is the
typed block again once it decodes), and a drifted `message_delta` keeps its stop reason. An `error` event throws the typed error for its `error.type`: `OverloadedError` for
`overloaded_error` (with `statusCode` 529), `RateLimitError`, `InternalServerError` for `api_error`, and so on;
`errorMessage` is its `error.message`.

### Raw JSON for a verbatim history

A typed `BetaMessage` keeps only the fields this SDK version models, and `JSONValue` keeps no key order. A client that
keeps its history as the JSON the API returned, and sends it back unchanged on every request, uses `RawJSON` with
`stream(body:)` (beta and GA; `createStreaming(body:)` gives the same events without building the Message). `RawJSON` is
an order-preserving JSON value: parsing keeps each object's keys in document order, every field, explicit `null`s and
each number's text. Building one keeps insertion order, and `serialized()` writes the stored order back without
re-sorting.

```swift
var history: [RawJSON] = [["role": "user", "content": "What's the weather in Paris?"]]
let tools: [RawJSON] = try toolDefinitions.map { try RawJSON.parse($0) }  // JSON text, in its own order

let stream = try await client.beta.messages.stream(
    body: ["model": "claude-opus-5-5", "max_tokens": 1024, "tools": .array(tools), "messages": .array(history)]
)
for try await event in stream {
    // `event.json` is the event as received; `event.event` is the typed event, `.unknown` when it doesn't decode
    if case .contentBlockDelta(let e) = event.event, case .textDelta(let d) = e.delta { print(d.text, terminator: "") }
}
if stream.messageComplete, let reply = stream.messageParam {
    history.append(reply)  // {"role": "assistant", "content": [...]}, every block as the API sent it
}

// Saving and loading it: as text, which keeps the order and the numbers
try RawJSON.array(history).serialized().write(to: file)
history = try RawJSON.parse(Data(contentsOf: file)).arrayValue ?? []
```

The body is sent exactly as given, with `stream: true` added. The stream builds the reply from the events' JSON: each
`content_block_start` object as received, with text, thinking, signature and citations deltas applied, and a tool
input's `input_json_delta` parts parsed at its `content_block_stop` in the model's key order. A loop over the stream
that ends without an error has had `message_stop`, so `messageComplete` is true there (see below for one that is
cancelled or cut short). `RawJSON(encoding:)` turns a typed value into `RawJSON`, with its keys sorted.

`RawJSON` is deliberately not `Codable`: a `Decoder` hands keys over unordered and an `Encoder` writes numbers from their
values, so a `Codable` round trip would change the bytes of every earlier turn and miss the prompt cache. Persist a
history as text (`serialized()`) and read it back with `RawJSON.parse(_:)`, as above. Arrays and objects may nest 128
levels (a tool input 120, so that a history holding it reads back).

Every request body is deterministic. A body built from typed parameters has each object's keys sorted, so the same
request produces the same bytes in every process, which prompt caching needs. A `RawJSON` body keeps its own order,
and middleware or `extraBody` changes are folded in without reordering the rest.

### Pagination

List methods return the first page; iterating a page walks every item across all pages.

```swift
for try await batch in try await client.messages.batches.list(limit: 20) {
    print(batch.id)
}
let page = try await client.models.list()
if page.hasNextPage() { let next = try await page.getNextPage() }
```

### Raw responses

```swift
let response = try await client.messages.withRawResponse.create(maxTokens: 1024, messages: messages, model: "claude-opus-5-5")
print(response.headers["request-id"] ?? "")
let message = try await response.parse()

// Don't read the body eagerly:
let text = try await client.models.withStreamingResponse.list { response in
    try await response.text()
}
```

### Errors

The Python exception hierarchy is preserved:

```swift
do {
    _ = try await client.messages.create(...)
} catch let error as RateLimitError {
    print(error.statusCode, error.requestID ?? "")
} catch let error as APIStatusError {
    print(error.statusCode, error.body ?? .null)
} catch let error as APIConnectionError {
    print("connection failed", error)
}
```

Requests are retried twice by default on connection errors, 408, 409, 429 and 5xx, honouring
`retry-after`/`retry-after-ms` (`maxRetries:` configures it), and time out after 10 minutes
(`timeout:`).

### Cancellation and streams that end early

A Messages stream never ends normally before its message is whole. Reading one throws:

- `CancellationError` when the task reading it is cancelled, or `close()` was called on it, before `message_stop`. The
  response is closed at once, which cancels the URLSession task: the connection closes and nothing more is read.
- `StreamEndedEarlyError` (an `APIConnectionError`) when its body ended, or its connection broke, before
  `message_stop` without a cancel. `underlying` is the transport's error when it reported one (URLSession reports a
  chunked body cut off by the server as a normal end, so `underlying` is often `nil`), and `requestID` the response's.

Every later read of that stream throws the same error, and `getFinalMessage()` / `getFinalText()` throw it rather than
return a partial message; what arrived stays readable as such (`currentMessageSnapshot`, with `messageComplete`
false). A connection that breaks after `message_stop` does not change a whole stream, which ends normally. A cancel while the request is still waiting for its response headers throws
`CancellationError` too, never `APIConnectionError`, and is not retried. A cancel or `close()` after `message_stop`
ends the stream normally.

```swift
let turn = Task {
    let stream = try await client.beta.messages.stream(body: body)
    for try await event in stream { show(event) }
    return stream.messageParam!  // only reached after message_stop
}
// When the user stops the turn:
turn.cancel()

do {
    history.append(try await turn.value)
} catch is CancellationError {
    // stopped: the history stays as it was
} catch let error as StreamEndedEarlyError {
    report("The reply was cut short.", error.requestID)  // the server or the network ended it
}
```

### Helpers

```swift
// Accumulating stream helper
let stream = try await client.messages.stream(maxTokens: 1024, messages: messages, model: "claude-opus-5-5")
for try await text in stream.textStream { print(text, terminator: "") }
let final = try await stream.getFinalMessage()

// Structured outputs: a Decodable type that supplies its JSON schema
struct Person: StructuredOutput { let name: String; static let jsonSchema: JSONValue = [
    "type": "object", "properties": ["name": ["type": "string"]], "required": ["name"]] }
let parsed = try await client.messages.parse(maxTokens: 1024, messages: messages, model: "claude-opus-5-5", outputFormat: Person.self)

// Tool runner
let weather = BetaFunctionTool(name: "get_weather", description: "Current weather",
                               inputSchema: ["type": "object", "properties": ["city": ["type": "string"]]]) { (input: BetaToolInput) in
    .string("Sunny in \(input["city"]?.stringValue ?? "?")")
}
let runner = try client.beta.messages.toolRunner(maxTokens: 1024, messages: betaMessages, model: "claude-opus-5-5", tools: [weather])
let last = try await runner.untilDone()
```

Platform clients: `AnthropicBedrock`, `AnthropicBedrockMantle`, `AnthropicVertex`, `AnthropicAWS`,
`AnthropicGoogleCloud`, `AnthropicFoundry` expose the same resources with their own auth.

### Configuration

```swift
let client = try Anthropic(
    apiKey: "sk-ant-...",
    baseURL: "https://api.anthropic.com",
    timeout: 60,                      // or Timeout(60, connect: 5)
    maxRetries: 4,
    defaultHeaders: ["anthropic-beta": "some-beta"],
    transport: myTransport            // any HTTPTransport; URLSessionTransport by default
)
let quick = try client.withOptions(timeout: 10)
```

Environment variables read: `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, `ANTHROPIC_BASE_URL`,
`ANTHROPIC_CUSTOM_HEADERS`, `ANTHROPIC_WEBHOOK_SIGNING_KEY`.

## Tracking upstream

```sh
Tools/update-upstream.sh 2.4.0     # fetch the new sdist, regenerate sources and tests
python3 -I Tools/codegen/generate.py   # regenerate from the vendored copy
swift test
```

`docs/porting/` lists what the transpiler could not handle (ported by hand) and upstream tests that
weren't transformed, with reasons.

## License

Apache 2.0 (see `LICENSE`). The vendored upstream SDK under `upstream/` keeps its own MIT/Apache
licenses.
