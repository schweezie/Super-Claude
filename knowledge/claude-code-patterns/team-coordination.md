# Team Coordination Patterns

> Reference card for multi-agent team orchestration. Distilled from oh-my-claudecode.

## Team Architecture

Teams coordinate multiple agents working in parallel on decomposed tasks, using file-based state for communication.

### Team Pipeline Stages

```
team-plan -> team-prd -> team-exec -> team-verify -> team-fix (loop)
```

| Stage | Lead Agents | Purpose |
|-------|------------|---------|
| team-plan | explore (haiku) + planner (opus) | Analyze codebase, create work plan |
| team-prd | analyst (opus) | Refine requirements, acceptance criteria |
| team-exec | executor (sonnet) per subtask | Parallel implementation |
| team-verify | verifier (sonnet) | Check against acceptance criteria |
| team-fix | executor/debugger | Fix failures, loop back to verify |

### Team Lifecycle

```
Lead: TeamCreate -> Decompose -> TaskCreate x N -> Spawn Workers -> Monitor -> Shutdown
Worker: Claim task -> Execute -> Report -> Claim next -> Shutdown on signal
```

## Mailbox Pattern (Agent Communication)

Two-channel file-based messaging, no shared memory bus:

**Inbox (Lead -> Worker):**
- Path: `.omc/state/team/{team}/workers/{worker}/inbox.md`
- JSONL format, append-only
- Message types: `message`, `context`

**Outbox (Worker -> Lead):**
- Path: `.omc/state/team/{team}/workers/{worker}/outbox.jsonl`
- JSONL append-only, auto-rotates at 500 lines
- Message types: `ready`, `task_complete`, `task_failed`, `idle`, `shutdown_ack`, `heartbeat`

**Hybrid routing:** Native Claude agents use `SendMessage` tool; MCP/external workers use inbox files. Message router abstracts the difference.

## Task Distribution

### Task State Machine

```
pending -> blocked -> in_progress -> completed | failed
```

- Tasks have `blocked_by[]` and `depends_on[]` for dependency tracking
- `computeTaskReadiness()` checks unmet dependencies before allowing claims

### Optimistic Locking for Task Claims

```json
{
  "claim": { "owner": "worker-1", "token": "uuid", "leased_until": "ISO+15min" },
  "version": 3
}
```

- Worker calls `claimTask(taskId, workerName, expectedVersion)`
- If version mismatch -> conflict, rejected
- 15-minute lease prevents deadlocks from crashed workers

### Load Balancing

- **Uniform pool:** Round-robin by current load count
- **Mixed roles:** Score by role match + load penalty
- Prevents all tasks going to a single worker

### Role-Based Routing

Intent detection from task description keywords:
- "fix the build" -> `build-fix` intent -> debugger
- "write tests" -> `verification` intent -> test-engineer
- "implement feature" -> `implementation` intent -> executor

## State Directory Layout

```
.omc/state/team/{teamName}/
  config.json              # Team manifest
  tasks/task-{id}.json     # Versioned task state (one file per task)
  workers/{name}/
    heartbeat.json         # Liveness signal
    inbox.md               # Lead -> worker messages
    outbox.jsonl           # Worker -> lead messages
    .ready                 # Sentinel: worker started
  events.jsonl             # Append-only audit log
  dispatch/requests.json   # Dispatch queue with directory-based locking
```

## Observability

**Heartbeat monitoring:**
- Workers write heartbeat on each poll cycle
- Fields: `lastPollAt`, `currentTaskId`, `consecutiveErrors`, `status`
- Lead checks freshness to detect dead workers

**Phase inference** (from task status distribution):
- All pending, none started -> `planning`
- Any in_progress -> `executing`
- All completed -> `completed`
- Failed with retries -> `fixing`

**Event log:** Append-only JSONL recording `task_completed`, `task_failed`, `worker_idle`, `shutdown_ack`, etc. Used for debugging and replay.

**Idle detection:**
- NudgeTracker monitors workers showing a prompt but no active task
- Configurable delay (30s default), max nudges (3)
- Sends "continue working" message to prevent stalls

## Governance Policies

```json
{
  "delegation_only": false,
  "plan_approval_required": false,
  "nested_teams_allowed": false,
  "one_team_per_leader_session": true,
  "cleanup_requires_all_workers_inactive": true
}
```

## Key Design Principles

1. **File-based state** -- No shared memory; everything on disk. Survives crashes and restarts.
2. **Append-only events** -- Thread-safe without locks; enables audit trail.
3. **Optimistic concurrency** -- Version numbers on tasks prevent lost updates.
4. **Hybrid transport** -- Abstracts native vs MCP workers behind single API.
5. **Graceful shutdown** -- Drain signal lets workers finish current task before stopping.

---

## From claude-code-best-practice

### High-Velocity Workflow Patterns

- **Squash merge always** — At 141 PRs/day, individual commits within branches are noise. One PR = one commit for clean reverts and `git bisect`
- **Median PR size: 118 lines** — Keep PRs focused and reviewable; occasional large PRs (migrations) are fine as outliers
- **Multiple uncorrelated context windows** — The same model in a separate context acts as an independent reviewer, catching bugs the author's context missed

### Agent Teams (Experimental)

Enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. Adds:
- `TeammateIdle` hook — Fires when a teammate agent becomes idle
- `TaskCompleted` hook — Fires when a background task completes
- Decision control via `continue: false` + `stopReason` in hook output

### Cross-Model Review Pattern

Use different models/sessions for different phases:
```
Plan (Opus, Terminal 1) → QA Review (separate model, Terminal 2) → Implement (Opus, fresh session) → Verify (separate session)
```

The QA reviewer inserts intermediate phases ("Phase 2.5") with "Finding" headings — it adds to the plan, never rewrites original phases.

### `/batch` Fan-Out

For massive parallel work: `/batch` interviews you, then fans out to as many **worktree agents** as needed (dozens to thousands). Each works independently on its own copy of the codebase. Use for large code migrations, bulk renames, and parallelizable transformations.

---

## From claude-howto

### Agent Teams vs Subagents

| Aspect | Subagents | Agent Teams |
|--------|-----------|-------------|
| Delegation | Parent delegates, waits for result | Lead assigns, teammates work independently |
| Context | Fresh per subtask, results distilled back | Each teammate maintains persistent context |
| Communication | Return values only | Inter-agent mailbox messaging |
| Best for | Focused subtasks | Large multi-file parallel work |

Enable: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`

### Teammate Display Modes

| Mode | Flag | Description |
|------|------|-------------|
| Auto | `--teammate-mode auto` | Auto-selects best mode |
| In-process | `--teammate-mode in-process` | Inline in current terminal |
| Split-panes | `--teammate-mode tmux` | Separate tmux/iTerm2 panes |

### Team Best Practices

- **Team size:** 3-5 teammates optimal
- **Task sizing:** 5-15 minutes each — parallelizable but meaningful
- **Avoid file conflicts:** Assign different files/dirs to different teammates
- **Plan approval:** Lead creates execution plan for user review before work begins

### Team Hook Events

| Event | Fires When | Use Case |
|-------|-----------|----------|
| `TeammateIdle` | Teammate finishes work, no pending tasks | Assign follow-up, trigger notifications |
| `TaskCompleted` | Shared task marked complete | Validation, dashboards, chain dependent work |
