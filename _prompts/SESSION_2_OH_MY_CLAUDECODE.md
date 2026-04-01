# SESSION 2 — Extract from oh-my-claudecode

You are working on the "super repo" project. Read AGENT_STATE.md and CHECKLIST.md first to understand where we are.

## Task
Clone https://github.com/Yeachan-Heo/oh-my-claudecode.git into a `references/` directory, then extract and distill patterns into the super repo's `knowledge/` directory. This is the backbone repo — it contributes the most to our architecture.

## What to extract

Focus on reading these areas of the repo:
- Agent definitions — how agents are structured, YAML frontmatter fields, delegation patterns
- Skill definitions — SKILL.md frontmatter, pipeline handoff contracts, auto-discovery
- Team coordination — Agent Teams setup, mailbox patterns, task distribution, shared task lists
- HUD / observability — how orchestration state is tracked in real-time
- Memory system — three-tier persistence, what survives compaction
- Skill pipelines — declarative handoff contracts (e.g., deep-interview → omc-plan → autopilot)
- CLAUDE.md routing — how task type detection works, auto-routing patterns
- `.omc/` state directory — how artifacts, specs, and session state are stored

## Where to write

Write distilled content into these files (create them if they don't exist yet):
- `knowledge/claude-code-patterns/agent-design.md` — agent definition patterns, delegation, model selection
- `knowledge/claude-code-patterns/skill-design.md` — skill frontmatter, pipeline handoffs, auto-discovery
- `knowledge/claude-code-patterns/team-coordination.md` — Agent Teams, parallel coordination, mailbox patterns
- `knowledge/claude-code-patterns/context-management.md` — memory tiers, compaction survival, state persistence

## Rules
- Each knowledge file must be concise — under 2000 tokens. These are agent-readable reference cards, not documentation.
- Extract patterns and principles, not raw code. Write in a format an AI agent can load as context and immediately apply.
- Do NOT copy code verbatim. Distill into "when to use X, how to structure Y, tradeoffs of Z" format.
- Do NOT check off tasks 7.8, 7.9, 7.11, 7.12 in CHECKLIST.md — these require content from ALL 3 repos (omc + best-practice + howto). This session only covers omc. Update AGENT_STATE.md to record what was written and note that these tasks are partially done (omc source complete).
- If you approach 50% context (100k tokens), follow the compaction protocol: save state, update files, then /compact.
