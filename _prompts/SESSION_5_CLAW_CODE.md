# SESSION 5 — Extract from claw-code

You are working on the "super repo" project. Read AGENT_STATE.md and CHECKLIST.md first to understand where we are.

## Task
Clone https://github.com/instructkr/claw-code.git into a `references/` directory (if not already there), then extract and distill harness internals into the super repo's `knowledge/` directory.

## What to extract

This is a clean-room Python rewrite of Claude Code's agent harness. Focus on understanding:
- Tool orchestration — how tools are wired and invoked at runtime, tool registration, tool dispatch
- Context window management — how context is managed internally, token budgets, when/how compaction is triggered
- Runtime behavior — the agent loop mechanics, how the agent decides what to do next, error handling, retry patterns
- Task orchestration — how tasks are queued, executed, and tracked internally

## Where to write

Write distilled content into these files (create them):
- `knowledge/harness-internals/tool-orchestration.md` — how tools are wired, registered, dispatched, and invoked
- `knowledge/harness-internals/context-window.md` — internal context management, token accounting, compaction mechanics
- `knowledge/harness-internals/runtime-behavior.md` — agent loop, decision-making, error handling, retry patterns

## Rules
- Each knowledge file must be concise — under 2000 tokens. These explain "how the engine works under the hood" for agents that need to make informed design decisions.
- This is a smaller repo — you should be able to complete it well within the 200k context budget.
- Focus on architectural understanding, not implementation details. Write in terms of "the harness does X because Y" not "line 42 of file Z calls function W."
- After writing each file, update CHECKLIST.md (tasks 7.14, 7.15, 7.16, 7.17 as applicable) and AGENT_STATE.md.
