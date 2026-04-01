# SESSION 4 — Extract from claude-howto

You are working on the "super repo" project. Read AGENT_STATE.md and CHECKLIST.md first to understand where we are.

## Task
Clone https://github.com/luongnv89/claude-howto.git into a `references/` directory (if not already there), then extract and distill templates and patterns into the super repo's `knowledge/` directory.

## What to extract

Focus on reading these areas of the repo:
- Skill SKILL.md templates — frontmatter patterns, how skills are auto-discovered, example skill definitions
- Subagent .md definitions — YAML frontmatter examples, how agents are configured
- Hook event handlers — concrete examples of PreToolUse, PostToolUse, Stop, SessionStart hooks
- MCP server integration — how MCP servers are configured and used with Claude Code
- Agent Team coordination — examples of multi-agent setups, task distribution
- Mermaid diagrams — any visual architecture diagrams worth extracting as reference

## Where to write

Write distilled content into these files (create or update):
- `knowledge/claude-code-patterns/skill-design.md` — update/extend with copy-paste-ready templates, frontmatter examples
- `knowledge/claude-code-patterns/agent-design.md` — update/extend with concrete agent definition examples
- `knowledge/claude-code-patterns/hook-patterns.md` — update/extend with concrete hook code examples
- `knowledge/claude-code-patterns/team-coordination.md` — update/extend with Agent Team examples

## Rules
- Each knowledge file must be concise — under 2000 tokens total. If a file is approaching the limit from previous sessions, prioritize the most useful additions and trim redundancy.
- If a file already has content from Sessions 2–3, EXTEND it — do not overwrite. Add a section header like "## From claude-howto" to distinguish sources.
- This repo is tutorial-style — extract the templates and patterns, skip the tutorial prose.
- This is the FINAL session for tasks 7.8, 7.9, 7.11, 7.12 (all 3 sources now covered: omc + best-practice + howto). After extending these files, you MAY check off 7.7 (clone), 7.8, 7.9, 7.11, 7.12. Also check off 7.10, 7.13 if Session 3 content is already present and you've added howto content.
- Update AGENT_STATE.md to record completion.
- If you approach 50% context (100k tokens), follow the compaction protocol: save state, update files, then /compact.
