# Context Window Management — Harness Internals

How the harness tracks, estimates, and manages context window usage internally.

## Token Estimation

The harness uses a character-based heuristic rather than a tokenizer: `chars / 4 + 1` per content block. For `ToolUse` blocks, both name and input are counted. For `ToolResult` blocks, tool_name and output are counted. This is fast but approximate — it provides a floor estimate for compaction decisions rather than exact token accounting.

## Usage Tracking

A `UsageTracker` accumulates actual token usage reported by the API across turns. It tracks four dimensions: `input_tokens`, `output_tokens`, `cache_creation_input_tokens`, and `cache_read_input_tokens`. The tracker is reconstructed from session history on restore — it walks all messages and sums usage from any message that carries a `TokenUsage` payload. This means usage survives session save/load without a separate counter file.

## Auto-Compaction Trigger

The harness triggers auto-compaction when cumulative `input_tokens` exceeds a threshold. The default is **200,000 tokens**, configurable via the `CLAUDE_CODE_AUTO_COMPACT_INPUT_TOKENS` environment variable. The check runs at the end of every turn (after all tool executions complete). If the threshold is crossed, the harness compacts immediately — the model never sees the bloated context on the next call.

## Compaction Mechanics

Compaction is controlled by `CompactionConfig`:
- `preserve_recent_messages`: number of most-recent messages to keep verbatim (default: 4)
- `max_estimated_tokens`: minimum estimated tokens before compaction is eligible (default: 10,000)

The algorithm:
1. Check eligibility: enough messages AND estimated tokens >= threshold
2. Split messages at `len - preserve_recent_messages`
3. Summarize the removed (older) messages
4. Create a System message with the continuation text
5. Prepend continuation message to preserved messages
6. Return the compacted session

## Summary Generation

The summary is structured, not freeform. It extracts:
- **Scope**: message counts by role (user, assistant, tool)
- **Tools mentioned**: deduplicated tool names from ToolUse/ToolResult blocks
- **Recent user requests**: last 3 user text messages, truncated to 160 chars
- **Pending work**: messages containing "todo", "next", "pending", "remaining" keywords
- **Key files**: path-like tokens with recognized extensions (rs, ts, js, json, md), max 8
- **Current work**: most recent non-empty text message
- **Key timeline**: every message summarized as `role: content_summary`

The summary is wrapped in `<summary>` XML tags. An `<analysis>` block (if present) is stripped during formatting. The continuation message tells the model: "This session is being continued from a previous conversation" and instructs it to resume without asking questions or acknowledging the summary.

## Session Persistence

Sessions serialize to JSON with a version field and a messages array. Each message includes role, content blocks, and optional usage. The `QueryEnginePort` (Python side) adds a `TranscriptStore` that compacts independently — when mutable messages exceed `compact_after_turns` (default: 12), the oldest are dropped. This is a separate mechanism from the session-level compaction in the Rust runtime.

## Cost Tracking

The harness tracks cost alongside tokens. `ModelPricing` structs hold per-million-token rates for input, output, cache creation, and cache read. Model-specific pricing is available for Haiku, Sonnet, and Opus tiers. Cost estimates are computed from cumulative usage and surfaced via `/cost` command.

## Design Implications for Agents

- **Compaction is lossy**: the summary is a heuristic extraction, not a full transcript. Agents relying on exact earlier content must persist it externally (state files, not conversation history).
- **200k threshold is ~50% of context**: this matches the observed quality degradation point. Agents should design for compaction as a normal event, not an exception.
- **Preserved messages create a "hot zone"**: the 4 most recent messages survive compaction intact. Time-critical context should be in recent messages or in the system prompt, not buried in history.
- **Token estimation underestimates**: the `chars/4` heuristic consistently underestimates actual token usage (actual tokenizers produce more tokens for short words, special characters, non-Latin text). The real trigger is API-reported tokens, which is accurate.
