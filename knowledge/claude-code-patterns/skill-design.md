# Skill Design Patterns

> Reference card for designing Claude Code skills with pipeline handoffs. Distilled from oh-my-claudecode.

## Skill Definition Format

Skills are `SKILL.md` files in `.claude/skills/<skill-name>/` directories.

### Frontmatter Schema

```yaml
---
name: skill-name                          # Primary identifier
description: Brief description            # One-line, used for matching
level: 4                                  # Complexity (1-7)
aliases: [alt-name1, alt-name2]           # Alternative trigger names
argument-hint: "<file> [options]"         # Usage hint
agent: executor                           # Default agent for this skill
model: sonnet                             # Model override
pipeline: [skill-a, skill-b, skill-c]    # Full pipeline chain
next-skill: skill-b                       # Explicit next skill to invoke
next-skill-args: --direct                 # Arguments for next skill
handoff: .omc/plans/artifact-*.md         # Artifact location pattern
---
```

**Required:** `name`, `description`. Everything else is optional.

## Skill Body Structure

```markdown
<Purpose>What this skill accomplishes</Purpose>
<Use_When>Conditions where this skill applies</Use_When>
<Do_Not_Use_When>When to avoid this skill</Do_Not_Use_When>
<Steps>Numbered phases with concrete instructions</Steps>
<Tool_Usage>Which tools to use and how</Tool_Usage>
<Escalation_And_Stop_Conditions>When to stop or escalate</Escalation_And_Stop_Conditions>
<Final_Checklist>Verification items before completion</Final_Checklist>
```

## Pipeline Handoff Contracts

Skills chain via `pipeline`, `next-skill`, and `handoff` frontmatter fields.

### How It Works

1. Each skill declares its position in a pipeline via `pipeline: [a, b, c]`
2. `next-skill` names the specific skill to invoke on completion
3. `handoff` specifies the artifact glob pattern the next skill reads
4. The runtime auto-appends pipeline guidance to each skill's prompt

### Canonical 3-Stage Example

```
deep-interview -> omc-plan -> autopilot

Stage 1 (deep-interview):
  handoff: .omc/specs/deep-interview-{slug}.md
  next-skill: omc-plan
  Produces: Interview spec with ambiguity scores

Stage 2 (omc-plan):
  handoff: .omc/plans/ralplan-*.md
  next-skill: autopilot
  Produces: Validated plan with ADR, pre-mortem

Stage 3 (autopilot):
  Detects upstream artifacts, skips redundant phases
  Produces: Working implementation
```

### Handoff Protocol

When a stage completes:
1. Write the handoff artifact at the declared `handoff` path
2. Carry forward decisions, outputs, and remaining risks
3. Invoke `Skill("next-skill")` with `next-skill-args`

### Key Artifact Locations

| Skill | Artifact Path | Contents |
|-------|--------------|----------|
| deep-interview | `.omc/specs/deep-interview-*.md` | Interview state, final spec |
| omc-plan | `.omc/plans/ralplan-*.md` | Plan, ADR, RALPLAN-DR summary |
| autopilot | `.omc/autopilot/spec.md` | Specification + impl plan |
| ralph | `.omc/prd.json` + `.omc/progress.txt` | User stories + progress |

## Auto-Discovery

- **Built-in skills:** Scanned from `skills/*/SKILL.md` at startup, cached
- **Learned skills:** Scanned from `.omc/skills/` (project) and `~/.claude/skills/` (user). Project overrides user.
- **Native command safety:** Skills that conflict with Claude Code builtins (plan, review, init, etc.) are auto-prefixed with `omc-`

## Trigger Patterns

**Keyword triggers** (hardcoded in CLAUDE.md):
```
"autopilot" / "build me" / "I want a"  -> autopilot
"ralph" / "don't stop"                  -> ralph
"plan this" / "let's plan"              -> omc-plan
"deep interview"                        -> deep-interview
"deslop" / "anti-slop"                  -> ai-slop-cleaner
```

**Learned skill matching** (scored):
- Trigger keyword match: +10 points
- Tag match: +5 points
- Quality bonus: +quality/20
- Usage bonus: +min(usageCount, 10)
- Top 5 by score are presented

## Quality Gates for Learned Skills

Three tests (all must pass):
1. "Could someone Google this in 5 minutes?" -> NO
2. "Is this specific to THIS codebase?" -> YES
3. "Did this take real debugging effort?" -> YES

---

## From claude-code-best-practice

### Extended Frontmatter Fields (13)

Beyond the omc schema, official Claude Code skills support:

| Field | Type | Purpose |
|-------|------|---------|
| `disable-model-invocation` | boolean | Prevent auto-invocation by Claude |
| `user-invocable` | boolean | `false` hides from `/` menu (background knowledge only) |
| `allowed-tools` | string | Tools allowed without permission prompts when active |
| `context` | string | `fork` runs skill in isolated subagent context |
| `agent` | string | Subagent type when `context: fork` (default: `general-purpose`) |
| `hooks` | object | Lifecycle hooks scoped to this skill |
| `paths` | string/list | Glob patterns for auto-activation on matching files |
| `effort` | string | Effort override: `low`, `medium`, `high`, `max` |
| `shell` | string | Shell for `!command` blocks: `bash` or `powershell` |

### Skill Type Taxonomy (9 Categories)

From Anthropic's internal usage (Thariq, Anthropic team):

| Category | Purpose | Examples |
|----------|---------|----------|
| Library & API Reference | Correct usage of libs/CLIs/SDKs | billing-lib, frontend-design |
| Product Verification | Test/verify code with external tools | signup-flow-driver, tmux-cli-driver |
| Data Fetching & Analysis | Connect to data/monitoring stacks | funnel-query, grafana |
| Business Process | Automate repetitive workflows | standup-post, weekly-recap |
| Code Scaffolding | Generate framework boilerplate | new-migration, create-app |
| Code Quality & Review | Enforce quality standards | adversarial-review, testing-practices |
| CI/CD & Deployment | Fetch, push, deploy code | babysit-pr, deploy-service |
| Runbooks | Symptom → investigation → report | oncall-runner, log-correlator |
| Infrastructure Ops | Routine maintenance with guardrails | dependency-management, cost-investigation |

### Writing Effective Skills (9 Tips)

1. **Don't state the obvious** — Focus on info that pushes Claude beyond its defaults
2. **Build a Gotchas section** — Highest-signal content; update over time from failure points
3. **Use progressive disclosure** — Skill is a folder: split details into `references/`, `examples/`, scripts
4. **Avoid railroading** — Give goals and constraints, not prescriptive step-by-step
5. **Think through setup** — Store config in `config.json`; use AskUserQuestion for structured input
6. **Description = trigger** — Write for the model, not humans; describe WHEN to invoke
7. **Memory via file system** — Append-only logs, JSON, or SQLite for skill-local memory
8. **Store scripts** — Give Claude reusable code; it spends turns on composition not reconstruction
9. **On-demand hooks** — Skills can register hooks active only during their session

### Distribution

- **Small teams:** Check into `.claude/skills/` in repo
- **Large orgs:** Internal plugin marketplace; organic curation before official release
- **Measurement:** PreToolUse hook to log skill invocation frequency

---

## From claude-howto

### Progressive Disclosure (3-Level Loading)

| Level | When Loaded | Token Cost | Content |
|-------|------------|------------|---------|
| **1: Metadata** | Always (startup) | ~100 tokens/skill | `name` + `description` from YAML |
| **2: Instructions** | When triggered | Under 5k tokens | SKILL.md body |
| **3: Resources** | As needed | Unlimited | Bundled scripts, templates, docs |

Description budget: **2% of context window** (fallback: 16K chars). Check `/context` for warnings.

### Content Types

- **Reference**: Background knowledge Claude applies to work (conventions, patterns). Runs inline.
- **Task**: Step-by-step actions invoked with `/skill-name`. Often uses `context: fork`.

### Dynamic Context Injection

Shell commands via `` !`command` `` resolve before skill content reaches Claude:
```yaml
---
name: pr-summary
context: fork
agent: Explore
---
PR diff: !`gh pr diff`
Changed files: !`gh pr diff --name-only`
```

### Argument Substitution

- `$ARGUMENTS` — all args: `/fix-issue 123` → `$ARGUMENTS` = "123"
- `$0`, `$1` — positional: `/review-pr 456 high` → `$0`="456", `$1`="high"

### Commands Merged Into Skills

`.claude/commands/` still works but skills (`.claude/skills/`) are recommended. Skills take precedence on name conflict. Skills add: directory structure, auto-invocation, `context: fork`, progressive disclosure.
