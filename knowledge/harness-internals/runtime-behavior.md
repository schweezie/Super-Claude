# Runtime Behavior — Harness Internals

How the agent loop runs, makes decisions, handles errors, and manages sessions.

## The Agent Loop

The core loop lives in `ConversationRuntime::run_turn()`. A single "turn" is one user message that may trigger multiple API round-trips:

```
1. Push user message to session
2. Loop:
   a. Check iteration count against max_iterations
   b. Build ApiRequest (system_prompt + all session messages)
   c. Stream API response → collect AssistantEvents
   d. Parse events into assistant message (text blocks + tool use blocks)
   e. Record usage from the stream
   f. Push assistant message to session
   g. If no tool_use blocks → break (turn complete)
   h. For each tool_use: authorize → hook → execute → hook → push result
3. Check auto-compaction threshold
4. Return TurnSummary
```

The loop has no explicit "decide what to do next" step — that decision is entirely delegated to the model. The harness is a faithful executor: it sends context, receives a response, and if the response contains tool calls, it executes them and sends the results back. The model drives the strategy.

## Iteration Control

`max_iterations` defaults to `usize::MAX` (effectively unbounded). This is intentional — the harness trusts the model to terminate. The configurable limit exists as a safety valve for programmatic use (tests, subagents with `maxTurns`). Exceeding the limit produces a `RuntimeError`, which terminates the turn.

## Bootstrap Sequence

The harness follows a 12-phase bootstrap before the first turn:

1. **CLI Entry** — parse args, determine mode
2. **Fast-path checks** — version, system prompt, MCP, daemon, bridge, background session, template, environment runner (each is a short-circuit that may exit early)
3. **Main Runtime** — if no fast-path matched:
   - Start prefetch side effects (MDM, keychain, project scan)
   - Build workspace context (count files, check archive)
   - Load command and tool snapshots (JSON files with mirrored inventories)
   - Prepare parity audit hooks
   - Run deferred init (trust-gated: plugins, skills, MCP prefetch, session hooks)
   - Assemble tool pool and system prompt
   - Enter the turn loop

The prefetch step runs concurrently with other setup — it doesn't block tool loading. Deferred init only runs in trusted mode, ensuring untrusted sessions skip plugin/MCP initialization.

## Prompt Routing

User input is routed by token-matching against command and tool inventories. Each command/tool module has a name, responsibility, and source_hint. The router scores each module by counting how many tokens from the user's prompt appear in its metadata. Top matches (up to `limit`, default 5) are selected, prioritizing one command and one tool match before filling with remaining matches by score.

## Error Handling Patterns

**API errors**: `RuntimeError` wraps stream failures (no message stop event, empty content). These are fatal to the turn — the turn returns `Err` and the caller decides whether to retry.

**Tool errors**: Non-fatal. A `ToolError` produces a tool result with `is_error: true`. The model sees the error and can retry, try a different approach, or explain the failure.

**Permission denials**: Non-fatal. Denied tools produce error results with a reason string. The model sees "tool X requires Y permission" and adapts.

**Hook denials**: Non-fatal. Pre-tool hooks with exit code 2 skip tool execution and return a denial message. Post-tool hooks with exit code 2 mark the result as error. Non-zero, non-2 exit codes produce warnings but allow execution.

**Stream interruption**: If `MessageStop` is never received, the harness returns a `RuntimeError`. Partial text deltas before interruption are lost.

## Session Restoration

Sessions persist as JSON. On restore:
1. Load session from file (version + messages array)
2. Reconstruct `UsageTracker` by walking message history and summing usage fields
3. Rebuild `ConversationRuntime` with the loaded session

The harness does not re-execute tools or replay the conversation — it trusts the persisted state. The system prompt is rebuilt fresh (it may change between sessions), but message history is treated as immutable truth.

## Multi-Turn Loop

For programmatic use, `run_turn_loop()` runs multiple turns sequentially. It appends `[turn N]` to the prompt for subsequent turns and stops when the stop_reason is not "completed" or max_turns is reached. This is used for automated pipelines, not interactive sessions.

## Design Implications for Agents

- **The model is the strategist, the harness is the executor.** The harness never decides "what tool to use next" — it only decides "is this tool allowed?" Everything else is model-driven.
- **Errors are information, not failures.** Tool errors, permission denials, and hook rejections all flow back to the model as context. The harness keeps the loop running unless the API itself fails.
- **Session state is the single source of truth.** There is no separate "agent memory" in the harness — everything is in the message list. Agents needing persistent state must write it to files, not rely on conversation history surviving compaction.
- **Bootstrap is fast-path optimized.** Most sessions hit a fast-path exit early. The full setup path (prefetch, deferred init, tool assembly) only runs for the main interactive runtime.
