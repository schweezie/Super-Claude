# Prompt Patterns

> Reference card for effective prompting techniques with Claude Code. Distilled from claude-code-best-practice.

## Core Principle: Give Claude a Way to Verify

The single most impactful prompting technique: **give Claude a way to verify its output**. Claude will iterate until the result is correct when it can check its own work (browser for frontend, test runner for backend, linter for code quality).

## Challenge Patterns

Force Claude to prove its work instead of trusting assumptions:

| Pattern | Prompt | Effect |
|---------|--------|--------|
| **Grill me** | "Grill me on these changes and don't make a PR until I pass your test" | Claude becomes your reviewer |
| **Prove it** | "Prove to me this works" — diff behavior between main and feature branch | Evidence-based verification |
| **Elegant redo** | "Knowing everything you know now, scrap this and implement the elegant solution" | Forces fresh approach after learning from failed attempt |
| **Go fix** | "Go fix the failing CI tests" | Autonomous debugging without micromanagement |

## Plan-First Pattern

**Always start complex tasks in plan mode.** Pour energy into the plan so Claude can 1-shot the implementation.

- Use Opus for planning, Sonnet for implementation
- One Claude writes the plan, a second Claude reviews it as a staff engineer
- When things go sideways, switch back to plan mode and re-plan — don't keep pushing
- Enter plan mode for verification steps too, not just the build

## Cross-Model Review (Test Time Compute)

Multiple uncorrelated context windows find more bugs than one context window trying harder:

```
Plan (Opus) → QA Review (separate model/session) → Implement (Opus) → Verify (separate session)
```

**Why it works:** "If Boris causes a bug, his coworker reviewing the code might find it more reliably than he can." The same model in a separate context window acts like an independent reviewer.

## RPI Workflow (Research → Plan → Implement)

Structured development with validation gates:

```
/rpi:research → GO/NO-GO → /rpi:plan → PLAN.md → /rpi:implement → PR
```

Each phase uses specialized agents (requirement-parser, product-manager, senior-engineer, cto-advisor). Prevents wasted effort on non-viable features.

## CLAUDE.md as Self-Writing Rules

After every correction: **"Update your CLAUDE.md so you don't make that mistake again."**

- Claude writes rules for itself with high fidelity
- Ruthlessly edit CLAUDE.md over time until mistake rate measurably drops
- Keep CLAUDE.md under 200 lines per file for reliable adherence
- Maintain per-task notes directories, point CLAUDE.md at them

## Subagent Amplification

Append **"use subagents"** to any request where you want Claude to throw more compute at the problem. This offloads tasks to separate context windows, keeping the main context clean and focused.

## Workflow Patterns

| Pattern | When to Use |
|---------|-------------|
| Human-gated task list | Multi-step tasks needing approval checkpoints |
| Break subtasks < 50% context | Prevents context overflow mid-task |
| Skills for repetition | Anything done more than once a day → skill or command |
| `/loop` for automation | Recurring tasks: PR babysitting, Slack feedback, stale PR cleanup |

## High-Velocity Practices

- **Squash merge always** — Clean history, easy reverts at scale (141 PRs/day, median 118 lines)
- **Git worktrees** — Dozens of parallel Claude sessions in same repo via `claude -w`
- **`/batch`** — Fan out massive changesets to many worktree agents (dozens to thousands)

## Key Anti-Patterns

1. **Don't micromanage** — Give the goal, not step-by-step instructions
2. **Don't push through failure** — Re-plan instead of iterating on broken approaches
3. **Don't skip verification** — Every claim needs evidence; enter plan mode for verification too
4. **Don't overload CLAUDE.md** — >200 lines degrades adherence

---

## From claude-howto

### Dynamic Context Injection in Skills/Commands

Use `` !`command` `` to resolve shell output before Claude sees the prompt:
```yaml
---
name: commit
allowed-tools: Bash(git *)
---
Git status: !`git status`
Git diff: !`git diff HEAD`
Branch: !`git branch --show-current`
Recent commits: !`git log --oneline -5`
Create a commit based on the above.
```

### Variable Substitution

- `$ARGUMENTS` — all args passed to the skill
- `$0`, `$1`, `$N` — positional arguments (0-based)
- `${CLAUDE_SESSION_ID}` — current session ID
- `${CLAUDE_SKILL_DIR}` — skill's own directory

### `@file` References

Include file contents directly: `Review @src/utils/helpers.js`. Also works in CLAUDE.md for importing documentation with `@path/to/file` syntax (recursive, max depth 5).

### Commands Architecture (Merged Into Skills)

Commands (`.claude/commands/`) and skills (`.claude/skills/`) both create `/command-name` shortcuts. Skills take precedence on name conflict. Skills add: directory structure, auto-invocation, `context: fork`, progressive disclosure.

### 55+ Built-in Commands

Key additions beyond common knowledge:
- `/btw` — side question without adding to history
- `/branch` — fork conversation into new session
- `/diff` — interactive diff viewer for uncommitted changes
- `/insights` — generate session analysis report
- `/schedule` — create/manage scheduled remote agents
- `/rewind` — rewind conversation and/or code (alias: `/checkpoint`)
- `/batch` — orchestrate large-scale parallel changes via worktrees

### MCP Prompts as Commands

MCP servers expose prompts as slash commands: `/mcp__<server>__<prompt> [args]`

### Plugin Commands

Plugins provide namespaced commands: `/plugin-name:command-name`
