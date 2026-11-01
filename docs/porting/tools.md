# `lib/tools` port

Hand port of `src/anthropic/lib/tools/` (and the parts of `lib/threads/` the tool runners send through) to
`Sources/Anthropic/Lib/Tools/`, with the upstream tests in `Tests/AnthropicTests/Lib/Tools/`.

## Mapping

| Upstream | Swift |
| --- | --- |
| `@beta_async_tool` / `BetaAsyncFunctionTool` | `BetaFunctionTool(name:description:inputSchema:...) { (input: T) in ... }` — explicit JSON schema; the closure takes the raw JSON object or any `Decodable` input (a decode failure is `ValueError("Invalid arguments for function <name>")`, as pydantic's validation is upstream) |
| `@beta_async_tool` over an `@asynccontextmanager` | `BetaFunctionTool(..., enter: { (function, exit) })`: entered on the first call, exited by `acloseRunnableTool` |
| `BetaAsyncBuiltinFunctionTool` | `open class BetaBuiltinFunctionTool` (override `toDict()` / `call(_:)`) |
| `BetaAsyncRunnableToolset` | `open class BetaRunnableToolset` (override `toolsetName`, `toDict()`, `call(context:name:input:)`) |
| `ToolError` and the toolset refusals | `open class ToolError: Error` and subclasses; `ToolsetUsageError` family derive from `AnthropicError` |
| `BetaToolLike` / `to_tool_params` | `protocol BetaToolLike` (function tools, builtin tools, toolsets, `BetaToolUnionParam`, `BetaToolParam` and a raw `JSONValue` definition conform) / `toToolParams` |
| `client.beta.messages.tool_runner(...)` | `client.beta.messages.toolRunner(...)` (extension on `BetaMessagesResource`) → `BetaToolRunner` |
| `BetaAsyncToolRunner` | `actor BetaToolRunner: AsyncSequence` (`for try await message in runner`, `untilDone()`, `generateToolCallResponse()`, `setMessagesParams`, `appendMessages`, `addTools`, `removeTools`, `compactBeforeNextTurn`, `close()`, `init(params:tools:client:)`) |
| `lib/threads` `ThreadState` / `BetaAsyncMessageThread` (sending half) | internal `ThreadState` / `MessageThread` in `Lib/Tools/Threads/`; `MessageThreadsUnsupported` marks a client without message threads (`_supports_message_threads = False`) |
| `SessionToolRunner` / `client.beta.sessions.events.tool_runner(...)` | `final class SessionToolRunner: AsyncSequence` of `DispatchedToolCall` / `client.beta.sessions.events.toolRunner(...)`; events are handled as JSON through `protocol SessionEventsAPI` (the generated resource, or a fake) |
| `BetaAsyncAbstractMemoryTool` / `BetaAsyncLocalFilesystemMemoryTool` (`anthropic.tools.memory`) | `open class BetaAbstractMemoryTool` / `BetaLocalFilesystemMemoryTool(basePath:)` (POSIX I/O: exact bytes, `O_EXCL` 0600 files, 0700 directories regardless of umask, atomic replace with fsync, `..` and symlink escapes refused) |
| `FileStore` / `LocalFileStore` | `actor FileStore` (`open`, `createRoot`, `put`, `get`, `ls`, `findSymlinks`, `hashtree`, `hashFile`, `move`, `remove`, `dispose`); SHA-256 is a small internal implementation (Foundation has none on Linux) |
| `_files.py` | `FileOps.readTextExact`, `FileOps.atomicWrite`, `readLineRange`, `LineRangeCollector` |
| `mcp.py` (`mcp_tool` / `async_mcp_tool`, `mcp_content`, `mcp_message`, `mcp_resource_to_content`, `mcp_resource_to_file`) | `mcpTool`, `mcpContent`, `mcpMessage`, `mcpResourceToContent`, `mcpResourceToFile` over small MCP value types (`MCPTool`, `MCPContentBlock`, `MCPResourceContents`, `MCPPromptMessage`, `MCPCallToolResult`, `MCPReadResourceResult`) and `protocol MCPClientSession` (no MCP client library is available). Only `mcpTool` carries its helper tag (`mcp_tool`): the value-type results can't carry `mcp_content` / `mcp_message` tags |
| `_skills.py` (`download_session_skills`, `_extract_skill_archive`) | `downloadSessionSkills(_:workdir:session:)` (and `skills:` for explicit skill ids), `extractSkillArchive`; zip (stored / deflate), tar and tar.gz are read by small internal readers (`Archives.swift`: inflate, gunzip, zip and ustar/pax/GNU tar), since Foundation has no decompression on Linux. bzip2 / xz tarballs are refused |
| `logging` / `warnings` in the helpers | `ToolDiagnostics` (log handler, `AnthropicWarnings` for warnings, task-local `capture` for tests) |

As `AsyncAnthropic` is `Anthropic`, the async classes take the sync names (`BetaAsyncFunctionTool` →
`BetaFunctionTool`, `BetaAsyncToolRunner` → `BetaToolRunner`, `BetaAsyncLocalFilesystemMemoryTool` →
`BetaLocalFilesystemMemoryTool`, ...).

Request fields and messages are held as JSON inside the runner, as Python holds them as dicts; the public API takes
and returns the generated types (`BetaMessageParam`, `BetaMessage`, `BetaToolResultBlockParam`).

## Deferred

* **The streaming tool runner** (`tool_runner(stream=True)`, `BetaAsyncStreamingToolRunner`, `run_tools_eagerly`,
  `defer_tool_call`, `deferred_tool_calls`): it hands out `BetaMessageStream`s, which `lib/streaming` (ported in
  parallel) provides. `MessageThread.openStream` and `ThreadState.recordPartialReply` are ported and ready for it.
  Deferred tests:
  * `test_runners.py`: `test_streaming_call_sync`, `test_streaming_call_sync_events`, `test_tool_changes_when_streaming`,
    `test_compact_before_next_turn_when_streaming_{sync,async}`, and the `streaming` / `streaming_eagerly` cases of
    `test_a_runner_made_from_params_*`.
  * `test_runner_eager_tools.py` (all 39 tests) and `test_runner_eager_toolsets.py` (all 16 tests).
* **`output_format`** (a structured-output class parsed into `parsed_output`): belongs to `lib/_parse`. The runner
  takes `outputConfig` with a JSON-schema format. Deferred: the `forced tool and output_format` case of
  `test_compaction_request_leaves_off_reply_params_*` and the `two_output_formats` case of
  `test_a_runner_made_from_params_raises_the_errors_of_tool_runner`.
* **`_memories.py` (`SessionMemoryStores`, memory-store sync for the environment worker)** and its tests
  (`memory_sync/`): not ported in this pass.
* The public `client.beta.messages.thread(...)` API (`BetaMessageThread`) is ported in `Lib/Threads/` (see `threads-environments-sessions.md`).
* **Not reached in this pass** (layer 4 of the port): `agent_toolset.py` (the bash / file tools and
  `AgentToolContext`), `_deprecations.py`, `_toolsets/` (computer and browser toolsets, pipeline, enforcement,
  security, confirm) and `src/anthropic/tools/{browser,computer}.py`, with their tests (`test_agent_toolset.py`,
  `toolsets/*`). The runnable-toolset contract they build on (`_toolsets/_runnable.py`, `_errors.py`,
  `_sanitize.py`) is ported.
* `test_open_telemetry.py` belongs to the tracing port.

## Skipped tests (no Swift meaning)

`test_functions.py`
* `test_function_without_type_hints`, `test_docstring_parsing_with_parameters` (all cases), `test_docstring_parsing_simple`,
  `test_custom_input_schema_with_pydantic_model`: schema/description inference from a Python signature, docstring or
  pydantic model. Swift tools take an explicit schema.
* `test_decorator_without_parentheses`, `test_decorator_with_parentheses`, `test_decorator_with_custom_parameters`:
  Python decorator syntax (the custom-parameter behaviour is covered by `customNameAndDescription` / `toDictCarriesTheOptionalFields`).
* `test_sync_context_manager_tool`: a sync `@contextmanager` entered at decoration time; Swift tools are async (the
  lazily entered variant is ported).
* `test_wrong_decorator_raises`, `test_async_context_manager_requires_input_schema`: detecting the wrong decorator
  flavour / a missing schema at runtime; the Swift initializers make both impossible at compile time.

`test_runners.py`
* `test_custom_message_handling`: `xfail` upstream.
* `test_tool_runner_method_in_sync`: `assert_signatures_in_sync` reads Python signatures.
* `test_tool_error_text_with_a_lone_surrogate_does_not_break_the_next_request`,
  `test_tool_error_content_with_a_lone_surrogate_does_not_break_the_next_request`,
  `test_tool_result_text_with_a_lone_surrogate_does_not_break_the_next_request`: a Swift `String` cannot hold an
  unpaired surrogate.
* `test_a_runner_takes_either_a_thread_or_params_tools_and_client`: the Swift initializers take exactly one of the
  two argument sets, so the mixed calls don't compile.
* The `tool_of_the_other_flavour` case of `test_a_runner_made_from_params_raises_the_errors_of_tool_runner`: there
  is one (async) flavour of tool in Swift.
* `test_compaction_param_is_refused_on_a_tool_runner`: the `from_thread` leg needs the public thread API; the setter
  and params legs are ported.
* `test_compact_before_next_turn_is_refused_beside_a_compaction_edit`, last leg, and the in-place `edits.append` in
  `test_compact_before_next_turn_on_the_compaction_response_is_ignored_sync`: they mutate a params list in place
  after handing it to the runner; Swift values are copied.

`test_session_runner.py`
* `test_sync_tool_runs_off_the_event_loop`: sync tools on a worker thread; Swift tools are async. The timeout for
  a tool that blocks without honouring cancellation is ported (`toolTimeoutFiresForAToolThatIgnoresCancellation`).
* `test_environment_key_threads_through_to_scoped_client`, `test_no_environment_key_threads_none_to_scoped_client`:
  they patch the private `_scoped_client` factory; `SessionRunnerHTTPTests` checks the same over a mock transport
  (Bearer environment key, helper tag, passthrough headers).
* `test_environments_public_reexports`: `lib.environments` is not part of this port.
* `test_send_retry_window_update_bounds_send_already_retrying` drives the internal `send_retry_window` hook directly
  (no `_run_session_tools` shim, which only the environment worker uses).

`memory_tools/test_filesystem.py`
* The sync class `TestBetaLocalFilesystemMemoryTool` is the twin of the async one, which is ported (Swift's
  `BetaLocalFilesystemMemoryTool` is the async tool under the sync name, as `AsyncAnthropic` is `Anthropic`).
  Three insert cases and three symlink cases are parametrized tests.

`test_file_store.py`
* `test_localfilestore_is_an_alias_for_the_combined_class`: `LocalFileStore` is a typealias (checked by the compiler).
* `test_filestore_open_raises_on_an_unreadable_mount_path`, `test_filestore_listings_raise_on_an_unreadable_subdirectory`:
  permission checks do not bind root, so upstream skips them as root too; the second is ported and returns early under root.
* The direct `_open_regular_file` leg of `test_filestore_get_refuses_a_non_regular_file` calls a private helper; the
  public `get` legs are ported.

`test_mcp_tool.py`
* `test_async_mcp_tool_to_dict` is the twin of `test_mcp_tool_to_dict` (one Swift `mcpTool`). Test helpers built from
  the `mcp` package's pydantic models become the Swift MCP value types.

`test_skills.py`
* The archives upstream builds with `zipfile` / `tarfile` are built by small writers in the test (stored zip entries,
  ustar members, gzip of stored deflate blocks); the inflater is checked separately against `zlib` output.
* `test_download_retrieves_by_configured_version_and_downloads_by_returned_id` runs over a mock transport instead of
  fake resource objects.

Sync/async twins are ported once (async). Tests that exist only as `_sync` exercise behaviour the async runner
shares and are ported as async tests.

## Tests ported

| Upstream file | Swift file | Ported |
| --- | --- | --- |
| `test_functions.py` | `FunctionsTests.swift` | 9 of 19 (+4 Swift-specific checks) |
| `test_runners.py` | `RunnersTests.swift`, `RunnerToolChangesTests.swift`, `RunnerCompactionTests.swift` | 71 of 82 test functions (twins counted; the 11 others are listed above), as 60 Swift tests |
| `memory_tools/test_filesystem.py` | `MemoryToolTests.swift` | the 41 async tests (as 33 Swift tests, some parametrized) + 2 |
| `test_file_store.py` | `FileStoreTests.swift` | 29 of 31 (+ SHA-256 vectors) |
| `test_files.py` | `FileStoreTests.swift` (`FilesTests`) | 2 of 2 (+1) |
| `test_mcp_tool.py` | `MCPToolTests.swift` | 37 of 38 (+1 runner integration test) |
| `test_skills.py` | `SkillsTests.swift` | 18 of 18 (parametrized pairs as one) + inflate vectors |
| `test_session_runner.py` | `SessionRunnerTests.swift` | 55 of 59 (2 merged into one parametrized test, 1 via HTTP) |

No core or generated files were changed.
