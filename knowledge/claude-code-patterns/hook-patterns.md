# Hook Patterns

> Reference card for Claude Code lifecycle hooks. Distilled from claude-code-best-practice.

## Hook Events (22)

| Category | Events | Purpose |
|----------|--------|---------|
| Tool lifecycle | PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest | Guard, log, and control tool execution |
| Session lifecycle | SessionStart, SessionEnd, Setup | Load context on start, cleanup on end |
| Agent lifecycle | SubagentStart, SubagentStop, TeammateIdle, TaskCompleted | Monitor and coordinate agents |
| Context management | PreCompact, PostCompact | Checkpoint before compaction, restore after |
| User interaction | UserPromptSubmit, Notification, Elicitation, ElicitationResult | Preprocess prompts, handle notifications |
| Configuration | ConfigChange, InstructionsLoaded | React to settings/CLAUDE.md changes |
| Workspace | WorktreeCreate, WorktreeRemove | Custom VCS setup for worktree isolation |
| Completion | Stop | Nudge agent to continue, verify completion |

## Hook Types

| Type | Mechanism | Best For |
|------|-----------|----------|
| `command` | Runs shell command, receives JSON on stdin | Logging, notifications, deterministic checks |
| `prompt` | Single-turn LLM evaluation (yes/no JSON) | Judgment-based decisions (PreToolUse, Stop) |
| `agent` | Multi-turn subagent with tool access (Read, Grep, Glob) | Verification requiring file inspection |
| `http` | POST JSON to URL, receive JSON response | External service integration, webhooks |

## Configuration

**Hierarchy:** Managed settings (org-enforced) > CLI args > `.claude/settings.local.json` (personal) > `.claude/settings.json` (team) > `~/.claude/settings.json` (global).

**Disable all:** Set `"disableAllHooks": true` in `settings.local.json`.

**Disable individual:** Use per-hook config files with `disablePreToolUseHook`, etc.

## Decision Control

| Hook | Control Field | Values |
|------|--------------|--------|
| PreToolUse | `hookSpecificOutput.permissionDecision` | `allow`, `deny`, `ask` |
| PermissionRequest | `hookSpecificOutput.decision.behavior` | `allow`, `deny` |
| PostToolUse, Stop, SubagentStop | Top-level `decision` | `block` |
| UserPromptSubmit | Modified `prompt` field via stdout | Rewritten prompt text |

**Universal output fields:** `continue` (bool), `stopReason`, `systemMessage`, `additionalContext`, `suppressOutput`.

## Agent-Scoped Hooks

Agent/skill frontmatter supports 6 hooks: PreToolUse, PostToolUse, PermissionRequest, PostToolUseFailure, Stop, SubagentStop. Define in YAML frontmatter `hooks:` block.

**Known issue:** Agent `Stop` hooks receive `hook_event_name: "SubagentStop"` instead of `"Stop"` — handle both in scripts.

## Matchers

Filter which events trigger a hook using regex patterns:
- PreToolUse/PostToolUse: match `tool_name` (e.g., `"Bash"`, `"mcp__memory__.*"`)
- SessionStart: match `source` (`startup`, `resume`, `clear`, `compact`)
- SubagentStart/Stop: match `agent_type`
- PreCompact/PostCompact: match `trigger` (`manual`, `auto`)

## Common Recipes

1. **SessionStart context loading** — Inject project state, hot paths, tech stack via `systemMessage`
2. **Stop nudge** — Use `prompt` hook to check if work is complete; return `continue: false` with `stopReason` if not
3. **PreToolUse guard** — Block dangerous commands (`rm -rf`, `DROP TABLE`, force-push) via `deny` decision
4. **On-demand hooks via skills** — `/careful` blocks destructive ops, `/freeze` locks edits outside specific dirs
5. **Logging** — Async PostToolUse hook logs all tool calls to JSONL for audit trail

## Environment Variables

| Variable | Availability | Purpose |
|----------|-------------|---------|
| `$CLAUDE_PROJECT_DIR` | All hooks | Project root directory |
| `$CLAUDE_ENV_FILE` | SessionStart | Persist env vars for subsequent Bash commands |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin hooks | Plugin's root directory |
| `${CLAUDE_SKILL_DIR}` | Skill hooks | Skill's own directory |

## Key Principles

1. **Use async for side-effects** — Notifications, logging, sounds should not block execution
2. **Deterministic over probabilistic** — Prefer `command` hooks for safety checks; use `prompt`/`agent` only when judgment is needed
3. **Layer configuration** — Team defaults in `settings.json`, personal overrides in `settings.local.json`
4. **Scope hooks to context** — Use agent/skill frontmatter hooks for scoped behavior, settings hooks for global

---

## From claude-howto

### Updated Event Count (25)

Beyond the 22 events above, howto documents: `StopFailure` (API error ends turn), `SessionEnd` (cleanup/logging), `TaskCreated` (task tracking), `CwdChanged` (directory-specific setup), `FileChanged` (file monitoring/rebuild).

### HTTP Hooks (v2.1.63+)

```json
{"type": "http", "url": "https://my-webhook.example.com/hook", "matcher": "Write"}
```
Routed through sandbox. Requires explicit `allowedEnvVars` for URL env var interpolation.

### Agent Hooks

Multi-turn subagent verification — unlike prompt hooks (single-turn), agents use tools (Read, Grep, Bash) for complex checks:
```json
{"type": "agent", "prompt": "Verify changes follow architecture guidelines.", "timeout": 120}
```

### Exit Codes

| Code | Meaning | Behavior |
|------|---------|----------|
| 0 | Success | Continue, parse JSON stdout |
| 2 | Block | Block operation, stderr shown as error |
| Other | Non-blocking error | Continue, stderr in verbose mode |

### Component-Scoped Hooks in Frontmatter

```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/check.sh"
          once: true  # Run once per session
```

Supported in skill, agent, and command frontmatter. Agent `Stop` hooks auto-convert to `SubagentStop`.

### Concrete Recipe: Bash Command Validator

```python
#!/usr/bin/env python3
import json, sys, re
BLOCKED = [(r"\brm\s+-rf\s+/", "Blocking rm -rf /"), (r"\bsudo\s+rm", "Blocking sudo rm")]
data = json.load(sys.stdin)
cmd = data.get("tool_input", {}).get("command", "")
for pattern, msg in BLOCKED:
    if re.search(pattern, cmd):
        print(msg, file=sys.stderr); sys.exit(2)
sys.exit(0)
```

### Concrete Recipe: Security Scanner (PostToolUse)

Scans Write/Edit content for hardcoded passwords/API keys. Returns `additionalContext` warning via `hookSpecificOutput`.

### Plugin Hooks

Plugins define hooks in `hooks/hooks.json` using `${CLAUDE_PLUGIN_ROOT}` and `${CLAUDE_PLUGIN_DATA}` vars.
