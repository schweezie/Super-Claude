# Context Management Patterns

> Reference card for memory tiers, compaction survival, and state persistence. Distilled from oh-my-claudecode.

## Three-Tier Memory System

Stored in `.omc/notepad.md` with three sections:

| Tier | Section | Max Size | Auto-Prune | Purpose |
|------|---------|----------|------------|---------|
| 1 | Priority Context | 500 chars | Never | Critical discoveries that MUST survive compaction |
| 2 | Working Memory | Unlimited | After 7 days | Session notes, temporary insights |
| 3 | MANUAL | Unlimited | Never | User-edited permanent reference material |

**Rule:** Only promote to Tier 1 if losing it would break the current workflow. Tier 2 is the default. Tier 3 is user-controlled.

## Compaction Protocol

### What Happens Before Compaction

The pre-compact hook (`src/hooks/pre-compact/`) creates:

1. **Checkpoint** at `.omc/state/checkpoints/checkpoint-{timestamp}.json`:
   - Active mode states (phase, iteration, prompt)
   - TODO summary (pending/in_progress/completed counts)
   - Background job metadata (active/recent jobs)

2. **Wisdom export** at `.omc/state/checkpoints/wisdom-{timestamp}.md`:
   - Learnings, decisions, issues, problems from `.omc/notepads/{plan}/`

3. **Project memory injection** via `systemMessage`:
   - User directives from `.omc/project-memory.json`
   - Hot paths (frequently accessed files)
   - Tech stack info

### What Survives Compaction

| Data | Location | Mechanism |
|------|----------|-----------|
| Checkpoint | `.omc/state/checkpoints/` | Written pre-compact |
| Wisdom | `.omc/state/checkpoints/` | Extracted from notepads |
| Project memory | `.omc/project-memory.json` | Re-injected via systemMessage |
| Priority Context (Tier 1) | `.omc/notepad.md` | Always reloaded |
| MANUAL (Tier 3) | `.omc/notepad.md` | Never pruned |
| Mode states | `.omc/state/{mode}-state.json` | Persisted to disk |
| Team state | `.omc/state/team/` | Independent persistence |
| Shared memory | `.omc/state/shared-memory/` | TTL-based, cross-session |

### What Does NOT Survive

- Working Memory (Tier 2) entries older than 7 days
- In-context reasoning, conversation flow
- Uncommitted tool results

## State File Patterns

### Meta-Envelope Wrapping

All state files are wrapped with `_meta` on write:
```json
{
  "...state fields...",
  "_meta": {
    "written_at": "ISO timestamp",
    "mode": "mode-name",
    "sessionId": "session-id"
  }
}
```
Envelope stripped on read. Enables session-scoped cleanup (delete files owned by ended sessions).

### Session-Scoped vs Worktree-Scoped

- **Session-scoped:** `.omc/state/sessions/{sessionId}/{mode}-state.json` -- isolated per session, cleaned up on session end
- **Worktree-scoped:** `.omc/state/{mode}-state.json` -- shared across sessions in same worktree
- **Cross-session:** `.omc/state/shared-memory/{namespace}/{key}.json` -- survives sessions, has optional TTL

### Centralized State Option

Set `OMC_STATE_DIR` environment variable to store state outside the worktree:
- Path: `$OMC_STATE_DIR/{dirName}-{SHA256-first-16}/`
- Survives worktree deletion
- Stable across worktrees of same project

## .omc/ Directory Structure

```
.omc/
  notepad.md                    # Three-tier memory
  project-memory.json           # Project-scoped directives
  state/
    checkpoints/                # Compaction checkpoints + wisdom
    sessions/{sessionId}/       # Session-scoped mode state
    shared-memory/{ns}/{key}    # Cross-session shared state
    team/{teamName}/            # Team coordination state
    autopilot-state.json        # Mode-specific state files
    ralph-state.json
    cancel-signal.json          # 30-second TTL cancel signal
  plans/                        # Planning artifacts
  notepads/{plan}/              # Per-plan learnings, decisions, issues
  specs/                        # Interview/spec artifacts
  skills/                       # Project-scoped learned skills
```

## Preemptive Compaction Monitor

- **Warning:** 80% context usage -> system reminder
- **Critical:** 95% context usage -> compaction recommended
- Debounced with 500ms window for concurrent tool completions
- Session state cleanup after 30 minutes idle

## Key Principles

1. **Disk is truth** -- All state on disk, not in context. Context is ephemeral.
2. **Graceful degradation** -- All state I/O fails silently. System continues without state.
3. **Session isolation** -- Session-scoped state prevents cross-session leakage.
4. **Mutex on compaction** -- Prevents race conditions from concurrent subagent completions.
5. **Cancel signal TTL** -- 30-second window prevents enforcement re-triggering after cancel.
6. **Checkpoint before compact** -- Zero information loss guaranteed if protocol followed.

---

## From claude-code-best-practice

### Manual Compaction Discipline

- Perform manual `/compact` at ~50% context usage — never let context fill up
- Break subtasks small enough to complete in under 50% context
- Use `/clear` when switching between major tasks or phases
- Use `/context` to visualize current context usage as a colored grid

### CLAUDE.md Loading in Monorepos

Two loading mechanisms:
1. **Ancestor loading (UP):** Walks upward from CWD to filesystem root; all CLAUDE.md files loaded at startup
2. **Descendant loading (DOWN):** Subdirectory CLAUDE.md files only load when Claude reads files in those directories (lazy loading)
3. **Siblings never load:** Working in `frontend/` won't load `backend/CLAUDE.md`

**Best practice:** Shared conventions in root CLAUDE.md; component-specific instructions in component CLAUDE.md; personal prefs in `CLAUDE.local.md` (gitignored).

### CLAUDE.md Sizing

Keep CLAUDE.md under **200 lines** per file for reliable adherence. After every correction, tell Claude: "Update your CLAUDE.md so you don't make that mistake again." Ruthlessly edit over time.

### Configuration Hierarchy (5 Levels)

| Priority | Location | Scope |
|----------|----------|-------|
| 1 | Managed settings | Organization-enforced, cannot be overridden |
| 2 | CLI arguments | Single-session overrides |
| 3 | `.claude/settings.local.json` | Personal project (gitignored) |
| 4 | `.claude/settings.json` | Team-shared (committed) |
| 5 | `~/.claude/settings.json` | Global personal defaults |

### Parallel Context Strategies

- **Git worktrees** (`claude -w`): Dozens of parallel Claude sessions in same repo — biggest productivity unlock
- **`/batch`**: Fan out massive changesets to many worktree agents (dozens to thousands)
- **`/btw` side queries**: Ask quick questions without interrupting agent's current task
- **`/branch` / `--fork-session`**: Fork session to explore alternatives without losing original context

### Session Management

- Name worktrees and set up shell aliases (`2a`, `2b`, `2c`) for quick hopping
- Use `/statusline` to show context usage and git branch at a glance
- Use `/rename` to label sessions for easy `/resume` later
- `--bare` flag for SDK/print mode: skip CLAUDE.md/settings/MCP scanning for up to 10x faster startup

---

## From claude-howto

### 8-Level Memory Hierarchy

| Priority | Location | Scope |
|----------|----------|-------|
| 1 | Managed Policy (`/Library/.../ClaudeCode/CLAUDE.md`) | Org-enforced |
| 2 | Managed Drop-ins (`managed-settings.d/`) | Modular policy (v2.1.83+) |
| 3 | Project Memory (`./CLAUDE.md`) | Team-shared (git) |
| 4 | Project Rules (`.claude/rules/*.md`) | Path-specific, modular |
| 5 | User Memory (`~/.claude/CLAUDE.md`) | Personal global |
| 6 | User Rules (`~/.claude/rules/*.md`) | Personal rules |
| 7 | Local Project (`./CLAUDE.local.md`) | Personal project (gitignored) |
| 8 | Auto Memory (`~/.claude/projects/<project>/memory/`) | Claude's own notes |

### Auto Memory

- `MEMORY.md` entrypoint: first 200 lines loaded at session start
- Topic files (`debugging.md`, `api-conventions.md`) loaded on demand
- Claude reads/writes during sessions as it discovers patterns
- All worktrees in same repo share one auto memory directory
- Disable: `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`

### Modular Rules with Path Scoping

```yaml
---
paths: src/api/**/*.ts
---
# API rules apply only to matching files
```

Rules in `.claude/rules/` are recursive, support subdirectories and symlinks.

### Quick Memory Updates

- `# rule text` prefix adds rule to memory during conversation
- `/init` creates starter CLAUDE.md (set `CLAUDE_CODE_NEW_INIT=true` for interactive flow)
- `/memory` opens memory files in editor for bulk editing
- `@path/to/file` imports (recursive, max depth 5) avoid duplication
