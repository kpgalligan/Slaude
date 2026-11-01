# `lib/threads`, `lib/environments` and `lib/sessions` port

Hand port of `src/anthropic/lib/threads/`, `src/anthropic/lib/environments/` and `src/anthropic/lib/sessions/`, with
the upstream tests of `tests/lib/threads/`, `tests/lib/environments/` and `tests/lib/sessions/`. Async variants only
(`AsyncAnthropic` is `Anthropic`, so `BetaAsyncMessageThread` is `BetaMessageThread`).

## Mapping

### Threads (`Sources/Anthropic/Lib/Threads/BetaMessageThread.swift`)

The thread's state (`_thread_state.py`, `_params.py`) and the sending half the tool runners share stay where the
tool-runner port put them, `Sources/Anthropic/Lib/Tools/Threads/` (`ThreadState`, `MessageThread`), so the concurrent
streaming-runner work that builds on them is not disturbed by a move. The public API is a thin layer on top.

| Upstream | Swift |
| --- | --- |
| `client.beta.messages.thread(max_tokens=..., model=..., messages=..., tools=..., output_format=..., unsupported_request_behavior=..., **ThreadCreateParams, extra_headers=...)` | `client.beta.messages.thread(maxTokens:model:messages:tools:unsupportedRequestBehavior:params: ThreadCreateParams?, extraHeaders:...)`; with `outputFormat: Output.Type` (a `StructuredOutput`) it returns a `BetaMessageThread<Output>` |
| `client.beta.messages.thread(**thread.params)` | `client.beta.messages.thread(params: thread.params)` |
| `BetaAsyncMessageThread(client, ...)` | `BetaMessageThread(client:params:extraHeaders:...)` |
| `ThreadParams` | `ThreadParams<Output>`: `fields` (request fields as JSON), `messages` (JSON), `tools` (as given, function tools included), `unsupportedRequestBehavior`, `hasOutputFormat`; `params["system"]` reads a field |
| `UnsupportedRequestBehavior` (`"error"`, `"continue_unthreaded"`) | `enum UnsupportedRequestBehavior { case error, continueUnthreaded }` |
| `thread.send(*messages, tools=..., extra_headers=..., **ThreadSendParams)` | `try await thread.send(_ messages: any BetaThreadMessageLike..., tools:params: ThreadSendParams?, extraHeaders:extraQuery:extraBody:timeout:)` |
| `thread.parse(...)` | `thread.parse(...) -> ParsedBetaMessage<Output>` |
| `async with thread.stream(...) as stream` | `let stream = try await thread.stream(...)` → `BetaThreadMessageStream<Output>` (an `AsyncSequence` of `ParsedBetaMessageStreamEvent` with `untilDone()`, `getFinalMessage()`, `getFinalText()`, `textStream`, `close()`). The turn ends when the events run out or fail, on `close()`, and when the stream is released at the latest (Python: on leaving the block) |
| `thread.update(tools=..., **ThreadSendParams, extra_headers=...)` | `thread.update(tools:params:extraHeaders:...)` |
| `thread.append(*messages)`, `thread.fork()`, `thread.messages`, `thread.previous_message_id` | `append(...)`, `fork()`, `messages` (`[BetaMessageParam]`; `messagesJSON` as sent), `previousMessageID` |
| `thread.tool_runner(max_iterations=..., extra_headers=...)` | `thread.toolRunner(maxIterations:extraHeaders:...)` → `BetaToolRunner` over the thread |
| `BetaMessageParam \| BetaMessage` arguments | `protocol BetaThreadMessageLike`: `BetaMessageParam`, `JSONValue`, `BetaMessage` and `ParsedBetaMessage` conform (a reply is recognised as the one the thread recorded) |
| `_check_message_threads_supported` | `AnthropicError("Message threads are not available on this client; ...")` for clients marked `MessageThreadsUnsupported` (Bedrock, Bedrock Mantle, Vertex) |

`ThreadState` gained the thread's output format (`output_config.format` sent on every turn, as `_turn_params`
merges it upstream), and `params` reports the tools a creating turn was given for itself while that turn is in flight, as `params` does upstream. The runner reads those tools back in `setMessagesParams` (`BetaRunner.swift`, one line: `thread.state.params.tools` in place of `thread.state.tools`, as upstream reads `self._thread.params`).

### Environments (`Sources/Anthropic/Lib/Environments/`)

| Upstream | Swift |
| --- | --- |
| `client.beta.environments.work.poller(environment_id=..., environment_key=..., ...)` / `aiter_work` | `client.beta.environments.work.poller(environmentID:environmentKey:workerID:blockMs:reclaimOlderThanMs:drain:autoStop:extraHeaders:)` → `EnvironmentWorkPoller` (`AsyncSequence` of `BetaSelfHostedWork`; `forEach(_:)`, `close()`, `next()`), over `EnvironmentWorkPoller(work: any EnvironmentWorkAPI, ...)` |
| the `try: yield item finally: work.stop(...)` of `aiter_work` | with `autoStop`, an item is stopped when the next one is asked for, when the body throws out of `forEach(_:)`, on `close()`, and (best-effort) when the poller is released |
| `Work` / `AsyncWork` (`poll`, `ack`, `stop`, `heartbeat`) as the poller's dependency | `protocol EnvironmentWorkAPI`, implemented over the generated `BetaEnvironmentsWorkResource` (an empty poll's `null` body is `nil`, as Python's `Optional[BetaSelfHostedWork]`) |
| `POLL_BLOCK_MS` | `POLL_BLOCK_MS` |
| `client.beta.environments.work.worker(...)` / `EnvironmentWorker(client, ...)` | `client.beta.environments.work.worker(environmentID:environmentKey:tools:workdir:unrestrictedPaths:maxFileBytes:maxIdle:memorySyncInterval:memorySyncDeletions:workerID:extraHeaders:)` / `try EnvironmentWorker(client:...)` (throws for a `memorySyncInterval` below `MIN_MEMORY_SYNC_INTERVAL`, and for any `unrestrictedPaths`), with `run()` and `handleItem(workID:environmentID:sessionID:environmentKey:workSecret:)` |
| `EnvironmentWorkerTools` (a list, or a factory over `AgentToolContext`) | `enum EnvironmentWorkerTools { case list([any BetaRunnableTool]), factory((AgentToolContext) throws -> [...]) }` |
| `tools=None` → `beta_agent_toolset_20260401(env)` | `tools: nil` → `betaAgentToolset20260401(context)` |
| `AgentToolContext(workdir=..., max_file_bytes=..., client=worker_client, session=session)`, `__aenter__` / `__aexit__` | `AgentToolContext` (`Lib/Tools/AgentToolset.swift`): `setupSkills()` on enter; `exit()` (close bash, remove the skills) on exit |
| `memory_sync_interval`, `memory_sync_deletions`, `SessionMemoryStores(worker_client, workdir=..., sync_interval=..., sync_deletions=...)` | `memorySyncInterval: TimeInterval?` (`nil` disables), `memorySyncDeletions: MemoryDeleteMode`, `SessionMemoryStores` (`Lib/Tools/Memories.swift`) through the internal `protocol EnvironmentMemoryStores` |
| `anyio.move_on_after(MEMORY_FLUSH_TIMEOUT)` around `finish()` / `flush_writes()` | a task group racing the pass against its bound; the pass is cancelled and waited for |
| the `anyio.CancelScope(shield=True)` teardown | the teardown runs in an unstructured `Task`, so cancelling the run (a lost lease) does not cancel it |
| `_Lease`, `_LeaseEndReason`, `_heartbeat_loop`, `_sessions_token_from_secret` | internal `EnvironmentLease`, `LeaseEndReason`, `heartbeatLoop`, `sessionsTokenFromSecret` |
| `lib/_retry.py`, `lib/_scoped_client.py` | the existing `HelperRetry` and `ScopedClient` |
| `logging.getLogger("anthropic.lib.environments._poller" / "._worker")` | `ToolLogger` records under the same names (`ToolDiagnostics`) |

Per-item flow, as upstream: the sessions token of the item's `secret` is preferred over the environment key; the
heartbeat starts before the session is fetched and its skills are downloaded; a heartbeat that ends the lease
(stopping / stopped, 412, a fatal 4xx, or no success for a whole TTL) ends the session run; the item is
force-stopped on exit unless the lease was lost; the latest server-reported TTL is the session tool runner's
send-retry window. Memory stores are mounted only for an item whose secret carries a sessions token (the memory
endpoints reject the environment key) while `memorySyncInterval` is set; an item without one whose session has memory
stores attached fails with `SessionMemoryError`. One session fetch is shared by the skills and the memory download; the
store folders become the context's `allowedRoots` (read-only stores its `readOnlyRoots`); `syncIfDue()` runs after
each dispatched tool call. The teardown closes the context first, then (after a clean end only) `finish()`, then
`flushWrites()`, each bounded by `MEMORY_FLUSH_TIMEOUT` with a warning when cut off, then `dispose()`; the heartbeat
keeps the lease until it is done.

OpenTelemetry work spans (`WorkSpan`, `as_current_span` of `lib/_tracing/_work.py`): the poller starts the
`anthropic.environment.work` span of each item a poll returns, from the client of its work API
(`EnvironmentWorkAPI.spanClient`, the resource's client; `nil` for a fake, whose items have no spans), and sends the
item's ack and stop with it current. A failed ack ends it with the error (a cancellation leaves it unset); otherwise it
ends `OK` when the consumer asks for the next item or closes the poller (and when the poller is released). The span is
not current in the consumer's code. `run()` gives its poller its own `WorkSpan` (an internal `init` parameter), serves
each item with the span current, and ends it first: `OK`, with the item's error, or unset when the lease was lost or
rejected, or the run was cancelled. `handleItem()` has no span. The poll now reads its response raw: the generated
method's type is not optional, and a call with a span parses the body into it, which an empty poll's `null` cannot be.

### Sessions (`Sources/Anthropic/Lib/Sessions/Accumulate.swift`)

| Upstream | Swift |
| --- | --- |
| `AccumulatedEvent` | `typealias AccumulatedEvent = BetaManagedAgentsAgentMessageEvent` |
| `accumulate_managed_agents_event(accumulated, event)` | `accumulateManagedAgentsEvent(_:_:)` over a `BetaManagedAgentsStreamSessionEvents`, plus overloads for the `BetaManagedAgentsAgentMessageEvent` (non-optional result), `BetaManagedAgentsStartEvent` and `BetaManagedAgentsDeltaEvent` |

## Tests

### Ported

| Upstream file | Swift file | Ported |
| --- | --- | --- |
| `threads/test_beta_threads.py` | `Lib/Threads/ThreadsSendTests.swift`, `ThreadsHistoryTests.swift`, `ThreadsStreamTests.swift` | 113 of 124 (parametrized cases kept as Swift arguments; the `output_format` / `output_config` pair of `test_output_format_adds_no_beta_beyond_the_threads_beta` is one test) |
| `threads/test_async_beta_threads.py` | `Lib/Threads/ThreadsAsyncTests.swift`, `ThreadsStreamTests.swift`, `ThreadsRunnerTests.swift` and the files above | its 72 twins of sync tests are the ports above; of its 8 async-only tests, 6 are ported (`send_creates_a_thread_then_continues_it`, `later_request_options_replace_the_threads_as_a_whole`, `send_while_another_send_is_in_flight_raises_and_stages_nothing`, `a_cancelled_send_takes_the_turn_back`, `runner_given_no_betas_sends_the_threads_beta_and_no_other`, `runner_with_thread_false_sends_no_thread`; `runner_refuses_a_thread_value` is covered by the two `runner_refuses_a_thread_value_*` ports) |
| `threads/test_thread_tool_runner.py` | `Lib/Threads/ThreadsRunnerTests.swift`, `ThreadsAsyncTests.swift` | 32 of 35 (non-streaming cases of `RESPONSE_KINDS`) |
| `threads/test_tool_runner_threading.py` | `Lib/Threads/ThreadsRunnerThreadingTests.swift` | 34 of 37 (non-streaming cases of `RESPONSE_KINDS`; `RUNNER_MODES` and `LOOP_BODIES` as arguments) |
| `environments/test_poller.py` | `Lib/Environments/PollerTests.swift` (`EnvRetryHelpersTests`) | 4 of 4 |
| `environments/test_poller_method.py` | `Lib/Environments/PollerTests.swift`, `PollerSpanTests.swift` (the span tests, over HTTP with a client that has spans) | 32 of 33 (a sync `iter_work` test and its async twin are one Swift test; sync-only ones run async); +3 Swift checks (`poller(...)` over HTTP, `close()`, the default worker id) |
| `environments/test_worker.py` | `Lib/Environments/WorkerTests.swift`, `WorkerSpanTests.swift` (the span tests: the real poller over a work API that answers its polls, `EnvSpanPolledWork`) | 34 of 36 (+1: the poll client of `run()`) |
| `tools/memory_sync/test_e2e_memory.py` | `Lib/Tools/MemorySync/MemorySyncE2ETests.swift` | 17 of 17 (see `tools.md`) |
| `sessions/test_accumulate.py` | `Lib/Sessions/AccumulateTests.swift` | 15 of 15 |

The worker tests run the worker with its real scoped clients over a mock transport: where upstream records the
`auth_token` / `helper` its fake scoped-client factory was called with, the Swift tests check each request's
`Authorization` and `x-stainless-helper` headers. Only the poll loop (`aiter_work`) and the session tool runner
(`_run_session_tools`) are replaced, through internal hooks. Upstream's `setup_skills` patch in
`test_heartbeat_starts_before_skill_download` is a skill-version fetch that waits on the first heartbeat.

### Skipped (no Swift meaning)

`threads/test_beta_threads.py`
* `test_parsed_reply_has_the_request_and_workspace_ids_of_its_response` (and its async twin), and
  `test_runner_replies_have_the_request_and_workspace_ids_of_their_responses` (`test_async_beta_threads.py`,
  `test_tool_runner_threading.py`): Swift models do not carry `_request_id` / `_workspace_id` (see `core-tests.md`).
* `test_a_stream_that_is_never_entered_stages_nothing`, `test_a_stream_manager_entered_again_streams_another_turn_and_frees_the_thread`:
  `thread.stream(...)` sends the request when it is awaited; there is no manager to leave un-entered or enter again.
* `test_the_constructor_takes_the_arguments_of_thread`, `test_send_parse_and_stream_take_the_arguments_of_update`,
  `test_thread_params_types_hold_the_fields_of_create`: they compare Python signatures and type hints.
* `test_the_output_format_is_given_only_when_the_thread_is_created`, `test_thread_requires_the_fields_create_requires`,
  `test_output_format_rejects_a_schema_dict`: the compiler enforces these (`ThreadSendParams` has no `outputConfig`,
  `maxTokens:` / `model:` are required, `outputFormat:` is a type). Of `test_a_thread_value_from_the_caller_is_refused`
  only the `thread(**thread.params, thread=...)` leg has a runtime check, and it is ported.
* `test_a_tools_list_edited_in_place_is_sent_on_the_create_and_refused_on_a_continue`,
  `test_system_or_a_tool_edited_in_place_is_refused_and_a_thread_from_the_params_takes_the_edit` (all three
  `IN_PLACE_EDITS`, and the async twin): they edit a list or dict after handing it to the thread; Swift values are
  copied.

`environments/test_worker.py`
* `test_work_resource_worker_and_poller_async_only`: there is no sync client.
* `test_heartbeat_keeps_beating_while_a_sync_tool_blocks`: Swift tools are async.

`environments/test_poller_method.py`
* The sync `iter_work` tests are the twins of the async ones (the `sync` case of each span test too).
* `test_a_work_item_without_data_is_acked_and_given_with_a_span`: `BetaSelfHostedWork.data` is required in the
  generated type, so a poll that answers an item with `data: null` does not decode, and there is no item to give.

### Deferred

* **Streaming tool runner** (ported concurrently): the `streaming` cases of `RESPONSE_KINDS` throughout, and
  `test_streaming_runner_set_messages_params_adds_ahead_of_the_in_flight_reply`,
  `test_streaming_runner_whose_stream_fails_leaves_the_thread_free` (and its async twin),
  `test_streaming_runner_keeps_messages_appended_after_a_mid_loop_rewrite`,
  `test_streaming_runner_set_messages_params_replaces_the_history_mid_loop` (async),
  `test_streaming_runner_does_not_add_the_structured_outputs_beta`.
* **`output_format` on the tool runner** (deferred in `tools.md`): `test_runner_output_format_sends_the_callers_betas_every_turn`.
  `test_runner_over_a_typed_thread_parses_the_final_message` is ported for its non-streaming case by parsing the
  runner's final message with the thread's output format (the Swift runner yields `BetaMessage`).
