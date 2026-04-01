# Agent Design Patterns

> Reference card for designing Claude Code agents. Distilled from oh-my-claudecode.

## Agent Definition Format

Agents are `.md` files with YAML frontmatter + XML-tagged body in `.claude/agents/`.

### Frontmatter Schema

```yaml
---
name: agent-name              # kebab-case identifier
description: Brief description # <150 chars, used for agent selection
model: claude-sonnet-4-6      # Model tier (see below)
level: 2                      # 2=specialist, 3=advisor, 4=orchestrator
disallowedTools: Write, Edit  # Optional: tools this agent cannot use
---
```

### Model Selection Tiers

| Tier | Model | Cost | Use For | Example Agents |
|------|-------|------|---------|----------------|
| Haiku | claude-haiku-4-5 | FREE | Quick lookups, file search, simple writing | explore, writer |
| Sonnet | claude-sonnet-4-6 | CHEAP | Implementation, debugging, testing, verification | executor, debugger, verifier, test-engineer |
| Opus | claude-opus-4-6 | EXPENSIVE | Architecture, planning, critical reviews, complex analysis | architect, planner, critic, code-reviewer |

**Rule of thumb:** Use the cheapest model that can reliably do the job. Opus for decisions, Sonnet for execution, Haiku for lookups.

## Agent Body Structure

Use XML tags for clear section boundaries:

```xml
<Agent_Prompt>
  <Role>What this agent does / does NOT do</Role>
  <Success_Criteria>Measurable, verifiable outcomes</Success_Criteria>
  <Constraints>Hard boundaries, tool restrictions</Constraints>
  <Investigation_Protocol>4-8 numbered steps</Investigation_Protocol>
  <Tool_Usage>Primary tools + parallel execution guidance
    <External_Consultation>When to delegate to other agents</External_Consultation>
  </Tool_Usage>
  <Output_Format>Exact response structure expected</Output_Format>
  <Failure_Modes_To_Avoid>Anti-patterns with explanations</Failure_Modes_To_Avoid>
  <Examples><Good>...</Good><Bad>...</Bad></Examples>
  <Final_Checklist>Pre-completion verification items</Final_Checklist>
</Agent_Prompt>
```

## Key Design Principles

1. **Role clarity** -- Every agent explicitly states what it IS and IS NOT responsible for. Prevents scope creep.
2. **Separation of concerns** -- Writer agents (executor, designer) never review their own work. Reviewer agents (code-reviewer, critic) are READ-ONLY (`disallowedTools: Write, Edit`).
3. **Evidence-based verification** -- Agents require fresh test/build output, not assumptions. Every claim needs `file:line` references.
4. **Circuit breaker** -- After 3 failed attempts, escalate to a higher-tier agent (e.g., debugger -> architect). Always document the blocker.
5. **Investigation protocols** -- Each agent has 4-8 numbered steps specific to its role. Include parallel execution guidance and stop conditions.

## Delegation Patterns

**When to delegate:**
- Multi-file changes, refactors, debugging, reviews, planning, research
- Work needing specialist prompts (security, API design, test strategy)
- 2+ independent parallel tasks

**When to work directly:**
- Trivial operations, single commands, quick clarifications

**Routing decision tree:**
- Scope unclear -> `explore` (haiku)
- Requirements unclear -> `analyst` (opus)
- Planning needed -> `planner` (opus)
- Implementation -> `executor` (sonnet)
- Quality gate -> `code-reviewer` (opus) or `verifier` (sonnet)

## Workflow Sequences

```
Feature:  analyst -> planner -> executor -> test-engineer -> code-reviewer -> verifier
Bug fix:  explore + debugger -> executor -> test-engineer -> verifier
Review:   code-reviewer + security-reviewer (parallel)
```

---

## From claude-code-best-practice

### Extended Frontmatter Schema (16 Fields)

Beyond the core fields above, agents support:

| Field | Type | Purpose |
|-------|------|---------|
| `permissionMode` | string | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | integer | Maximum agentic turns before forced stop |
| `skills` | list | Skill names preloaded into agent context at startup (full content injected) |
| `mcpServers` | list | MCP servers for this subagent (name strings or inline configs) |
| `hooks` | object | Lifecycle hooks scoped to agent (PreToolUse, PostToolUse, Stop, etc.) |
| `memory` | string | Persistent memory scope: `user`, `project`, or `local` |
| `background` | boolean | Always run as background task |
| `effort` | string | Effort override: `low`, `medium`, `high`, `max` |
| `isolation` | string | `"worktree"` for temporary git worktree isolation |
| `initialPrompt` | string | Auto-submitted first user turn when running as main session agent |
| `color` | string | CLI output color for visual distinction |

### Official Built-in Agent Types (6)

| Agent | Model | Purpose |
|-------|-------|---------|
| `general-purpose` | inherit | Default for complex multi-step tasks |
| `Explore` | haiku | Fast read-only codebase search |
| `Plan` | inherit | Pre-planning research (read-only) |
| `Bash` | inherit | Terminal commands in separate context |
| `statusline-setup` | sonnet | Configure status line |
| `claude-code-guide` | haiku | Answer Claude Code feature questions |

### Command → Agent → Skill Architecture

Three extension mechanisms with distinct roles:

| | Agent | Command | Skill |
|---|---|---|---|
| **Context** | Separate (isolated) | Inline (shared) | Inline or `fork` |
| **Auto-invoked** | Yes (via description) | No (user `/` only) | Yes (via description) |
| **User `/` menu** | No | Yes | Yes (unless `user-invocable: false`) |
| **Tool restrictions** | `tools:` / `disallowedTools:` | `allowed-tools:` | `allowed-tools:` |

**Use agent when:** autonomous multi-step, context isolation needed, persistent memory, background/worktree work.
**Use command when:** user-initiated entry point, orchestrating agents/skills.
**Use skill when:** auto-invoked by intent, reusable procedure, agent preloading.

### Agent Skill Preloading

Two patterns for skills with agents:
1. **Preloaded (agent skill):** Listed in `skills:` frontmatter — full content injected at startup as domain knowledge
2. **Invoked (direct skill):** Called via `Skill()` tool — runs independently in command/conversation context

### Auto-Invocation Control

Use `"PROACTIVELY"` in agent description to encourage Claude to auto-spawn it. Agents are selected by lightest-weight match: Skill (inline) > Agent (separate context) > Command (user-initiated only).

---

## From claude-howto

### Subagent Memory Scopes

| Scope | Directory | Use Case |
|-------|-----------|----------|
| `user` | `~/.claude/agent-memory/<name>/` | Personal notes across all projects |
| `project` | `.claude/agent-memory/<name>/` | Team-shared project knowledge |
| `local` | `.claude/agent-memory-local/<name>/` | Local project knowledge (not committed) |

First 200 lines of `MEMORY.md` auto-loaded into subagent system prompt. Read/Write/Edit tools auto-enabled for memory management.

### Worktree Isolation

Set `isolation: worktree` to give subagent its own git worktree + branch. No-change worktrees auto-cleaned; changed worktrees return path and branch to parent.

### CLI-Defined Agents (`--agents` flag)

Session-only agents via JSON: `claude --agents '{"name": {"description": "...", "prompt": "...", "tools": [...], "model": "sonnet"}}'`. Highest priority — overrides all file-based definitions.

### Restrict Spawnable Subagents

Use `tools: Agent(worker, researcher), Read, Bash` to limit which subagents a coordinator can spawn.

### Plugin Subagent Security

Plugin-provided agents cannot use: `hooks`, `mcpServers`, `permissionMode`. Prevents privilege escalation.

### Copy-Paste Agent Template

```yaml
---
name: code-reviewer
description: Expert code review specialist. Use PROACTIVELY after writing or modifying code.
tools: Read, Grep, Glob, Bash
model: inherit
---

You are a senior code reviewer. When invoked:
1. Run git diff to see recent changes
2. Focus on modified files
3. Begin review immediately

For each issue: Severity, Category, Location, Description, Fix, Impact.
```
