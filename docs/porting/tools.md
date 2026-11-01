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
| `BetaAsyncAbstractBrowserToolset20260801` (`_toolsets/_browser.py`, `_pipeline.py`, `_registry.py`, `_render.py`, `_results.py`, `_hooks.py`) | `open class BetaAbstractBrowserToolset20260801` (`Toolsets/Browser.swift`, `BrowserPipeline.swift`, `Render.swift`, `Results.swift`): one `open func` per member (`navigate(context:input:)`, `listTabs`, …, typed generated inputs and results), `open func browserState(context:)` (Python's `_browser_state`), `open func execute(context:name:input:)` over `BetaBrowserMemberName` / `BetaBrowserMemberInput` / `BetaBrowserMemberResult`, and `final` `call` / `toDict()` / `configs`. Options: `configs`, `confirm` (`BetaConfirmCallable`), `urlPolicy` (`BetaURLPolicy`), `filePolicy` (`protocol BetaFilePolicy`), `toolConfigs` |
| `BetaAsyncAbstractComputerToolset20260801` (`_computer.py`, `_computer_registry.py`, `_computer_results.py`) | `open class BetaAbstractComputerToolset20260801` (`Toolsets/Computer.swift`): the same shape over `BetaComputerMemberName` / `BetaComputerMemberInput` / `BetaComputerMemberResult`, `BetaComputerConfirmContext` |
| method-identity override detection (`overridden`, `DEFAULT_BODIES`) | Swift cannot see whether a subclass overrides a method, so a driver declares it: `open var implementedMembers: Set<…MemberName>` lists the member methods it overrides (a subclass extends `super.implementedMembers`), and `open var overridesExecute: Bool` says it overrides `execute` (and so serves every member) |
| `_base.py` (`Registry`, `BaseToolsetOptions`, `parse_input`, `confirm_outcome`, the call lock) | `Toolsets/Base.swift`: `ToolsetRegistry`, `ToolsetOptions`, `parseMemberInput` (decodes the generated input, reporting every bad field as `loc: message` without the value; an `unknown` literal or union case is refused, as pydantic refuses it), `ToolsetCallGate` (one call at a time; a task-local marks the call in flight, so a nested `call()` is `NestedCallError` and `close()` from inside a member does not wait) |
| `_security.py` (`beta_check_upload_path`, `BetaLocalFilePolicy`) | `Toolsets/Security.swift`: `betaCheckUploadPath(_:_:strictRoots:)`, `open class BetaLocalFilePolicy`; `posixpath` `normpath` / `abspath` / non-strict `realpath` ported for the checks. `ON_WINDOWS` and the `realpath_lenient` spy are task-locals (`ToolsetSecurity.$onWindows`, `.$resolveObserver`) |
| `BetaBrowserState`, `StateChange`, `BetaNavigationRefused`, `BetaDialogDismissed`, `BetaScreenshotResult`, `BetaComputerCursorPositionResult` | structs, and `enum BetaBrowserStateChange` (`.change(BetaBrowserStateChangeParam)`, `.navigationRefused`, `.dialogDismissed`; decodes from JSON by `type`, refusing a missing or unknown one). The pipeline reads the report as JSON, as Python reads dicts, so a malformed raw `.change(.unknown(...))` entry is the driver's `ToolsetContractError` |
| `anthropic.tools.browser` / `anthropic.tools.computer` (the re-export modules) | the same names, public in the `Anthropic` module |
| `raise ToolError(content) from cause` | `ToolError(_:cause:)` and `ToolError.cause` (added to `BetaFunctions.swift`) |
| `with toolset:` / `async with toolset:` | `toolset.use { ... }` |
| a toolset instance in `messages.create(tools=[...])` | `toolset.toToolUnionParam()` |
| `agent_toolset.py` (`AgentToolContext`, `BashSession`, `resolve_path`, `beta_*_tool`, `beta_agent_toolset_20260401`) and `_deprecations.py` | `AgentToolset.swift`: `final class AgentToolContext` (`use { }` for `async with`; `maxFileBytes: Int??` etc., `nil` = default, `.some(nil)` = uncapped), `BashSession` over Foundation `Process` (`BashResult`, `BashTimeoutError`, `BashSessionTerminatedError`), `resolvePath`, `betaBashTool` … `betaGrepTool`, `betaAgentToolset20260401`. `glob` is a small `Path.glob` port (`*`, `?`, `[…]`, `**`); `grep` runs `rg` when it is on `PATH` (task-local `AgentToolset.$findRipgrep` for tests) and otherwise walks with `NSRegularExpression` |

As `AsyncAnthropic` is `Anthropic`, the async classes take the sync names (`BetaAsyncAbstractBrowserToolset20260801` →
`BetaAbstractBrowserToolset20260801`, `BetaAsyncFunctionTool` →
`BetaFunctionTool`, `BetaAsyncToolRunner` → `BetaToolRunner`, `BetaAsyncLocalFilesystemMemoryTool` →
`BetaLocalFilesystemMemoryTool`, ...).

Request fields and messages are held as JSON inside the runner, as Python holds them as dicts; the public API takes
and returns the generated types (`BetaMessageParam`, `BetaMessage`, `BetaToolResultBlockParam`).

Toolset differences from upstream, all forced by Swift's types:

* A member receives its generated input struct, which holds the declared fields only; a key the schema does not
  declare stays on `context.toolUse?.input` (Python keeps it on the parsed model).
* `confirm` returns `Bool` and `urlPolicy` returns `Void`, so upstream's "anything but `True` declines" and
  "a non-`None` return is a contract error" cases cannot arise. Both may be `async`; the file policy is synchronous,
  as upstream's protocol is.
* Tabs and the generated change kinds are typed, so a driver's extra keys on them are dropped; a change of a kind
  the SDK does not know (`.change(.unknown(json))`) is forwarded as built.
* A member's typed method cannot return an off-type result; `execute` (which returns the result enum) can, and the
  pipeline answers it as upstream does (`ValueError('navigate returned str, not its result model')`).
* `browserState(context:)` cannot be made abstract: a driver that does not override it gets a
  `ToolsetContractError` on its first call instead of at construction.

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
* The public `client.beta.messages.thread(...)` API (`BetaMessageThread`) is not ported; only what the runners use.
* `toolsets/test_runner.py::test_a_streamed_member_call_is_routed_to_the_toolset`: needs `stream=True` in the runner
  (the streaming tool runner, ported separately).
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

`toolsets/` (the browser and computer toolsets). The sync and async classes are one Swift class, so each pair of
twins is one test. These have no Swift meaning:
* The flavour checks (an `async def` member, `execute`, `_browser_state`, `confirm` or `url_policy` on the
  synchronous class, a plain `def` one on the asynchronous class, a runner of the other flavour):
  `test_pipeline.py::test_an_async_browser_state_on_the_sync_class_is_a_contract_error`,
  `::test_an_async_execute_override_on_the_sync_class_is_a_contract_error`,
  `::test_a_plain_execute_override_on_the_async_class_is_a_contract_error`,
  `::test_a_sync_member_or_browser_state_on_the_async_class_is_a_contract_error`,
  `test_interface.py::test_an_async_member_on_the_sync_class_is_a_contract_error` (and the sync-member half of
  `::test_async_execute_awaits_async_members_and_a_sync_one_is_a_contract_error`),
  `test_computer_pipeline.py::test_an_async_execute_override_on_the_sync_class_is_a_contract_error`,
  `::test_a_plain_execute_override_on_the_async_class_is_a_contract_error`,
  `test_computer_interface.py::test_an_async_member_on_the_sync_class_is_a_contract_error`,
  `test_enforcement.py::test_a_predicate_shaped_or_async_policy_on_the_sync_class_is_a_contract_error`,
  `test_browser_runner.py::test_a_toolset_of_the_other_flavour_is_refused_when_the_runner_is_built`,
  `test_runner.py::test_sync_tool_runner_rejects_an_async_toolset`, `::test_async_tool_runner_rejects_a_sync_toolset`,
  `::test_tool_runner_rejects_a_function_tool_of_the_other_flavour`.
* Python values the Swift types rule out: `test_pipeline.py::test_an_async_file_policy_hides_the_path_on_the_async_class_too`
  (an `async def is_path_visible`), `::test_an_undeclared_key_named_after_a_model_attribute_is_dropped` (pydantic v1),
  `test_enforcement.py::test_an_explicit_none_policy_refuses_navigate_on_both_classes` (`None` vs unset),
  `::test_a_file_policy_hook_may_return_any_iterable` and its async twin (generators),
  `test_security.py::test_a_single_path_string_is_a_config_error` (`roots: [String]`), and inside ported tests the
  truthy / non-`bool` answers, the `dict` subclasses of `test_configs_are_gated_on_the_copy_that_is_sent`, the
  `None` title of a malformed report, a `__str__` that raises, the generator file policies, `upload_roots="/srv/uploads"`
  and `expose_download_paths="true"`.
* Python module surface: `test_surface.py::test_every_documented_name_is_exported`,
  `::test_the_module_exports_only_the_browser_only_errors`,
  `::test_the_abstract_classes_declare_every_member_and_the_constructor_options`,
  `test_computer_surface.py::test_every_documented_name_is_exported`,
  `::test_the_abstract_classes_declare_every_member_and_the_constructor_options` (the compiler checks the declarations),
  `test_runnable.py::test_the_runnable_toolset_bases_are_exported_next_to_the_runner`, and the dynamic method
  assignment half of `test_interface.py` / `test_computer_interface.py::test_override_detection_...`.
* Lone surrogates: `test_runnable.py::test_a_lone_surrogate_in_error_text_becomes_the_replacement_character` and the
  surrogate assertions inside ported tests (a Swift `String` cannot hold one; the surrogate rows of `text_cases.json`
  are read as the U+FFFD they become). The `KeyError` case of
  `test_runnable.py::test_a_raised_exception_reads_the_same_on_the_function_tool_and_toolset_paths` has no Swift error.
* In-place edits of a list handed to the runner, and one-shot iterables (Swift values are copied):
  `test_browser_runner.py::test_a_tools_list_is_kept_so_editing_it_in_place_reaches_the_next_request`,
  `::test_a_function_tool_appended_to_the_list_in_place_is_sent_with_the_next_request`,
  `::test_a_toolset_taken_out_of_the_list_in_place_is_not_sent_with_the_next_request`,
  `::test_a_tools_list_edited_in_place_is_sent_when_the_message_thread_is_created_and_refused_after_that`,
  `::test_tools_passed_as_a_one_shot_iterable_reach_every_request`, `::test_messages_passed_as_a_one_shot_iterable_reach_every_request`,
  `test_runner.py::test_tool_runner_accepts_a_generator_of_tools`.

`test_agent_toolset.py`
* `test_text_io_is_utf8_under_ascii_locale`: Python's locale-dependent default encoding; Swift reads and writes UTF-8
  regardless of locale. `test_read_under_unreadable_directory_reports_permission_denied` returns early under root, as
  upstream skips it there.

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
| `toolsets/test_runnable.py` | `Toolsets/ToolsetRunnableTests.swift` (`ToolsetRunnableTests`) | 14 of 16 (twins merged) |
| `toolsets/test_refusals.py` | `Toolsets/ToolsetRunnableTests.swift` (`ToolsetRefusalTests`) | 8 of 8 (twins merged) |
| `toolsets/test_pipeline.py` | `Toolsets/ToolsetPipelineTests.swift` | 62 of 68 (twins merged, as 47 Swift tests) |
| `toolsets/test_confirm.py` | `Toolsets/ToolsetConfirmTests.swift` (`ToolsetConfirmTests`) | 12 of 12 (twins merged) |
| `toolsets/test_enforcement.py` | `Toolsets/ToolsetConfirmTests.swift` (`ToolsetEnforcementTests`) | 16 of 20 (twins merged) |
| `toolsets/test_security.py` | `Toolsets/ToolsetSecurityTests.swift` | 14 of 15 |
| `toolsets/test_interface.py` | `Toolsets/ToolsetInterfaceTests.swift` (`ToolsetInterfaceTests`) | 18 of 19 (twins merged; `test_browser_state_is_abstract` as a first-call contract error) |
| `toolsets/test_registry.py` | `Toolsets/ToolsetInterfaceTests.swift` (`ToolsetRegistryTests`, reading `_data/browser_toolset_members.py`) | 11 of 11 |
| `toolsets/test_surface.py` | `Toolsets/ToolsetInterfaceTests.swift`, `ToolsetRunnableTests.swift` | 6 of 9 |
| `toolsets/test_computer_pipeline.py` | `Toolsets/ToolsetComputerTests.swift` (`ToolsetComputerPipelineTests`) | 27 of 29 (twins merged) |
| `toolsets/test_computer_interface.py` | `Toolsets/ToolsetComputerTests.swift` (`ToolsetComputerInterfaceTests`) | 15 of 16 |
| `toolsets/test_computer_registry.py`, `test_computer_surface.py` | `Toolsets/ToolsetComputerTests.swift` (`ToolsetComputerRegistryTests`) | 7 of 7, 4 of 6 |
| `toolsets/test_runner.py` | `Toolsets/ToolsetRunnerTests.swift` (`ToolsetRunnerRoutingTests`) | 17 of 22 (twins merged; 1 deferred on streaming) |
| `toolsets/test_browser_runner.py` | `Toolsets/ToolsetRunnerTests.swift` (`ToolsetBrowserRunnerTests`) | 12 of 19 |
| `toolsets/test_computer_runner.py` | `Toolsets/ToolsetRunnerTests.swift` (`ToolsetComputerRunnerTests`) | 7 of 7 |
| `test_agent_toolset.py` | `AgentToolsetTests.swift` | 72 of 73 (related cases merged, as 49 Swift tests) |

The fakes of `toolsets/_fakes.py`, `_computer_fakes.py` and `_stubs.py` are in `Toolsets/ToolsetTestSupport.swift`
(`ToolsetWorld` / `ToolsetFakeBrowser`, `ToolsetDesktop` / `ToolsetFakeDesktop`, `ToolsetEchoBrowser`); Python's
per-test subclasses become closures on the fakes (`memberBodies`, `executeHook`, `stateHook`), as Swift's local
classes cannot capture a test's variables.

No core or generated files were changed. Outside `Lib/Tools/Toolsets/` and `AgentToolset.swift`, the toolset port added
`ToolError.cause` (`BetaFunctions.swift`).
