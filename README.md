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
- ~3,750 tests in all. See [docs/porting/STATUS.md](docs/porting/STATUS.md) for the upstream → Swift
  map and what (if anything) was skipped, and why.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for how the transformation works and how Python
constructs map to Swift.

## Requirements

Swift 6.0+. Foundation only, no third-party dependencies. `swift build` and `swift test` pass with Swift 6.2.3
(Xcode 26.2) on macOS 26 (arm64, case-insensitive APFS), and the suite was tested with Swift 6.4 on Linux. CI
([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) builds and tests on macOS with Xcode 26 and on Linux in the
`swift:6.4.2-noble` container.

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
