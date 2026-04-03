# SESSION 3 — Extract from claude-code-best-practice

You are working on the "super repo" project. Read AGENT_STATE.md and CHECKLIST.md first to understand where we are.

## Task
Clone https://github.com/shanraisshan/claude-code-best-practice.git into a `references/` directory (if not already there), then extract and distill patterns into the super repo's `knowledge/` directory.

## What to extract

Focus on reading these areas of the repo:
- CLAUDE.md best practices — how to structure the master orchestration file, routing patterns, rule definitions
- Hook patterns — PreToolUse, PostToolUse, Stop, SessionStart event handlers, common hook recipes
- Context management — /compact discipline (manual at 50%), /clear for task switches, memory tiers
- Subagent patterns — Command → Agent → Skill pattern, frontmatter fields (tools, disallowedTools, model, permissionMode, maxTurns, skills, hooks, memory)
- Model selection — when to use Opus vs Sonnet, cross-model review patterns
- Prompt patterns — ultrathink, verification prompts, challenge patterns, effective prompting techniques
- `.claude/` directory structure — how to organize settings.json, commands, agents, skills

## Where to write

Write distilled content into these files (create or update):
- `knowledge/claude-code-patterns/hook-patterns.md` — hook events, common handlers, lifecycle management
- `knowledge/claude-code-patterns/context-management.md` — update/extend with compaction strategy, /clear discipline
- `knowledge/claude-code-patterns/prompt-patterns.md` — effective prompting techniques, verification, challenge patterns
- `knowledge/claude-code-patterns/agent-design.md` — update/extend with subagent frontmatter conventions, delegation patterns

## Rules
- Each knowledge file must be concise — under 2000 tokens. Agent-readable reference cards, not docs.
- If a file already has content from Session 2, EXTEND it — do not overwrite. Add a section header like "## From claude-code-best-practice" to distinguish sources.
- Extract patterns and principles, not raw code.
- Do NOT check off tasks 7.8, 7.9, 7.11, 7.12 in CHECKLIST.md — these require content from ALL 3 repos (omc + best-practice + howto). This session covers best-practice only. You may check off 7.6 (clone) and 7.10, 7.13 if fully completed (those only need best-practice + howto).
- Update AGENT_STATE.md to record what was written and which sources are still pending per task.
- If you approach 50% context (100k tokens), follow the compaction protocol: save state, update files, then /compact.
