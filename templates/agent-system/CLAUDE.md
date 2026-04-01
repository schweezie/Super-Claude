# CLAUDE.md — Multi-Agent System

This project uses Claude Code's native agent and skill infrastructure to coordinate specialist agents around a central coordinator.

## Architecture

```
coordinator (opus)
  ├── researcher (sonnet)   — search, read, summarize
  ├── implementer (sonnet)  — write, edit, run commands
  └── reviewer (opus)       — critique, validate, approve
```

The coordinator never writes code directly. It reads the task, picks the right specialist, delegates with a tight prompt, and synthesizes the result.

## Agent Conventions

Agent files live in `.claude/agents/`. Each file has YAML frontmatter followed by a system prompt.

```yaml
---
name: agent-name
description: One-line description. Used by the coordinator to pick the right agent.
model: claude-sonnet-4-6        # or claude-opus-4-6
tools:                          # optional — restrict to specific tools
  - Read
  - Glob
  - Grep
disallowedTools:                # optional — block dangerous tools
  - Write
  - Edit
  - Bash
---
```

### Model Selection

| Role | Model | Reason |
|------|-------|--------|
| coordinator, reviewer | claude-opus-4-6 | Complex reasoning, routing decisions |
| researcher, implementer | claude-sonnet-4-6 | Fast, capable, cost-effective |

### Tool Constraints

- Read-only agents (researcher, reviewer) use `disallowedTools: [Write, Edit, Bash]`
- Implementation agents (implementer) get full tool access
- The coordinator uses only the Agent tool plus Read — it does not write code

## Skill Conventions

Skills live in `.claude/skills/<name>/SKILL.md`. They are invoked with the Skill tool and inject a structured workflow into the active agent's context.

```yaml
---
name: skill-name
description: What this skill does and when to use it.
trigger: keyword or condition that causes this skill to be invoked
---
```

Skills are stateless workflow templates. They describe a sequence of steps — the agent calling the skill executes those steps.

## Adding a New Agent

1. Create `.claude/agents/<name>.md` with frontmatter and a system prompt
2. Choose the right model and tool constraints for the agent's role
3. Add an entry to the coordinator's agent roster so it knows the agent exists
4. Test by invoking it via `/run` with a task that should route to the new agent

## Adding a New Skill

1. Create `.claude/skills/<name>/SKILL.md` with frontmatter and step-by-step instructions
2. Decide which agent(s) should use it — update their system prompts to reference it
3. Skills can also be invoked directly from command files

## State Management

Runtime state lives in `.state/` (gitignored). Write state files to checkpoint progress on long tasks.

```
.state/current-task.md     — Active task description and progress
.state/research-notes.md   — Accumulated research findings
```

At session start, read `.state/current-task.md` if it exists. If a task was in progress, offer to resume it before starting anything new.

## Routing Logic

```
1. User runs /run <task>
2. Coordinator reads the task and .state/current-task.md
3. Coordinator decides: research first, implement, or review?
4. Coordinator delegates to the right agent via the Agent tool
5. Result returns to coordinator, which synthesizes and responds
```
