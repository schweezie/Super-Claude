# Multi-Agent Claude Code Starter

A minimal starter template demonstrating the multi-agent coordination pattern with Claude Code's native agent and skill infrastructure.

## Pattern Overview

```
User → /run command → coordinator agent → specialist agents
                                        ↘ researcher (read-only)
                                        ↘ implementer (full access)
                                        ↘ reviewer (review-only)
```

The coordinator receives a task, breaks it into subtasks, delegates to the right specialist, and synthesizes results. Specialists run in isolated context — they see only what the coordinator passes them.

## Setup

```bash
# Clone or copy this template into your project
cp -r templates/agent-system /path/to/your/project

# No dependencies — this is pure Claude Code configuration
# Open with Claude Code
claude /path/to/your/project
```

## Usage

```
/run <task description>      — Route a task through the coordinator
/review                      — Review recent changes
```

## Adding Agents

1. Create `.claude/agents/<name>.md`
2. Add YAML frontmatter: `name`, `model`, `description`, and optionally `tools` or `disallowedTools`
3. Write the agent's system prompt below the frontmatter
4. Tell the coordinator about the new agent so it knows when to delegate

## Adding Skills

1. Create `.claude/skills/<name>/SKILL.md`
2. Add YAML frontmatter: `name`, `description`, `trigger`
3. Write the skill instructions — injected into the active agent's context when triggered
4. Reference the skill in the relevant agent or command file

## Project Structure

```
.claude/
  agents/
    coordinator.md    — Routes tasks to specialists (opus)
    researcher.md     — Reads and searches, no writes (sonnet)
    implementer.md    — Full tool access for code changes (sonnet)
    reviewer.md       — Reviews output, no writes (opus)
  skills/
    research/SKILL.md     — Structured research workflow
    implement/SKILL.md    — Implementation workflow
  commands/
    run.md            — Entry point: delegates to coordinator
    review.md         — Entry point: delegates to reviewer
  settings.json       — Project-level Claude Code settings
.state/               — Runtime state (gitignored)
CLAUDE.md             — Project instructions for Claude Code
```

## State Management

Runtime state lives in `.state/` and is gitignored. Agents write progress notes there so work can resume after a context reset.

```
.state/
  current-task.md     — What is being worked on right now
  research-notes.md   — Findings from the researcher
```
