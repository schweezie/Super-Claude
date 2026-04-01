# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The **Super Repo** is a functional, executable system that guides any software project from idea to shipped product via Claude Code and multi-agent orchestration. It is not documentation — it is an installable pipeline.

**Pipeline:** `IDEA → PLAN → ARCHITECT → BUILD → TEST → SHIP`

Each phase has entry/exit criteria, agent configs, slash commands, templates, and curated knowledge. See `SUPER_REPO_CONTEXT.md` for full project spec and source repo descriptions.

## State Files (Read These First)

| File | Purpose | When to Read |
|------|---------|-------------|
| `AGENT_STATE.md` | Current step, last action, next action, active decisions | **Every session start and after every compaction** |
| `CHECKLIST.md` | 112 tasks across 10 steps. Source of truth for progress | After AGENT_STATE.md |
| `COMPACTION_PROTOCOL.md` | Full compaction rules and recovery procedures | When rules are unclear |
| `SUPER_REPO_CONTEXT.md` | Full project spec, source repo descriptions, architecture | When context is needed |

## Session Protocol

**Start every session:**
```
1. Read AGENT_STATE.md   ← know where you are
2. Read CHECKLIST.md     ← know what's done and what's next
3. Resume from NEXT_ACTION in AGENT_STATE.md
```

**During work:**
- Follow CHECKLIST.md task-by-task
- Update AGENT_STATE.md after completing tasks (current step, last action, files created)
- Mark tasks `[x]` in CHECKLIST.md only when fully complete

## Architecture

### Two-Layer Design

**Knowledge Layer** — 13 distilled reference files in `knowledge/` that agents load as context when needed. Sourced from 5 reference repos, organized by topic.

**Execution Layer** — The pipeline: agents, skills, commands, hooks, and team configs that execute each phase. Modeled after oh-my-claudecode's architecture, restructured around the six pipeline phases.

### Pipeline Artifact Chain

Each phase reads the previous phase's artifact from `.omc/artifacts/` and produces its own:
```
/idea  → .omc/artifacts/01-idea/idea-brief.md
/plan  → .omc/artifacts/02-plan/prd.md
/build reads → .omc/artifacts/03-architect/architecture.md
/test  → .omc/artifacts/05-test/test-report.md
/ship  → .omc/artifacts/06-ship/release-notes.md
```
Gate enforcement: each phase's output-spec must be satisfied before the next phase starts.

### Key Principles

- **Extract and adapt, don't fork.** Source repos in `references/` are reference material. Distill patterns, don't copy wholesale.
- **oh-my-claudecode is the backbone.** XML-tagged agent bodies, YAML frontmatter for skills with pipeline fields, file-based mailbox for teams, checkpoint+wisdom export for compaction survival.
- **3-tier memory.** File-based persistence that survives compaction: state files (AGENT_STATE.md, CHECKLIST.md), knowledge files (`knowledge/`), runtime state (`.omc/`).
- **Model selection.** Opus for planning/architecture/reviews. Sonnet for code generation/implementation. Haiku for quick lookups.

## Repository Layout

```
knowledge/                          # COMPLETE — 13 distilled reference files
  cs-fundamentals/                  # data-structures, algorithms, system-design, design-patterns
  claude-code-patterns/             # agent-design, skill-design, team-coordination, context-management, hook-patterns, prompt-patterns
  harness-internals/                # tool-orchestration, context-window, runtime-behavior

references/                         # Cloned source repos (read-only reference, not dependencies)
  oh-my-claudecode/                 # Backbone — multi-agent orchestration plugin
  claude-code-best-practice/        # Configuration patterns, hooks, skills
  claude-howto/                     # Templates, MCP, step-by-step examples
  claw-code/                        # Harness internals (Python + Rust reimplementation)
  coding-interview-university/      # CS fundamentals source

_prompts/                           # Session prompts (SESSION_1 through SESSION_6B)

pipeline/                           # NOT YET BUILT — phase templates and output specs (Steps 1-6)
.claude/commands/                   # NOT YET BUILT — slash commands (Step 4)
.claude/agents/                     # NOT YET BUILT — subagent definitions (Step 5)
.claude/skills/                     # NOT YET BUILT — skill definitions (Step 6)
.claude/hooks/                      # NOT YET BUILT — lifecycle hooks (Step 9)
templates/                          # NOT YET BUILT — project type starters (Step 8)
.omc/                               # NOT YET CREATED — runtime state (gitignored)
```

## Compaction Rules

1. **Compact at 200k tokens (50% context).** Never later. Quality degrades past 50%.
2. **Before compacting:** finish current atomic task → update AGENT_STATE.md → update CHECKLIST.md → git commit → then `/compact`
3. **After compacting:** re-read AGENT_STATE.md → CHECKLIST.md → resume from NEXT_ACTION. Trust state files over compacted memory.
4. **Use `/clear` when switching between major steps** (e.g., finishing Step 3, starting Step 4). Re-read state files after `/clear`.

Full compaction procedures, token budgets, multi-agent rules, and emergency recovery are in `COMPACTION_PROTOCOL.md`.

## Build Order and Progress

Step 7 (knowledge extraction) was completed first. Remaining steps build the execution layer.

- **Complete:** Step 7 — all 13 knowledge files distilled and validated (19/19 tasks)
- **Next:** Step 1 (scaffold), Step 2 (master CLAUDE.md), Step 3 (output specs), Steps 4-6 (commands, agents, skills), Steps 8-10 (templates, hooks, E2E testing)

**Always check AGENT_STATE.md for the current task — this section may be stale.**
