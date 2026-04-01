# CLAUDE.md — Pipeline Orchestration

> This file is the brain of the Super Repo. It routes user intent to the correct pipeline phase, loads relevant knowledge, enforces gates between phases, and manages state across sessions.

## Phase Detection & Routing

When a user message arrives, detect the intended phase from keywords and context, then route to the correct command.

### Keyword → Phase Mapping

| Keywords / Patterns | Phase | Command | Agent |
|---------------------|-------|---------|-------|
| "idea", "I want to build", "new project", "brainstorm", "what should I build" | IDEA | `/idea` | `interviewer` |
| "plan", "PRD", "requirements", "user stories", "spec", "let's plan" | PLAN | `/plan` | `planner` |
| "architect", "design", "tech stack", "data model", "API design", "system design" | ARCHITECT | `/architect` | `architect` |
| "build", "implement", "code", "create", "develop", "let's build" | BUILD | `/build` | `executor` |
| "test", "QA", "coverage", "verify", "validate", "acceptance" | TEST | `/test` | `tester` |
| "ship", "deploy", "release", "tag", "publish", "launch" | SHIP | `/ship` | `release-manager` |
| "full pipeline", "end to end", "idea to ship", "run everything" | ALL | `/full-pipeline` | (chained) |

### Routing Logic

```
1. Check if user invoked a slash command directly → use that phase
2. Check for keyword match in user message → suggest the matched phase
3. Check .omc/state/pipeline-state.json for current phase → offer to resume
4. If no match → ask user what phase they want to start with
```

### Phase Resumption

If `.omc/state/pipeline-state.json` exists, read it first. If a phase was in-progress when the session ended, offer to resume it before starting anything new.

---

## Knowledge Loading Rules

Each phase loads only the knowledge files relevant to its work. Knowledge files live in `knowledge/` and are injected into agent context at phase start.

| Phase | Knowledge Files to Load |
|-------|------------------------|
| IDEA | None (this phase captures the human's vision) |
| PLAN | `cs-fundamentals/system-design.md`, `cs-fundamentals/design-patterns.md` |
| ARCHITECT | `cs-fundamentals/data-structures.md`, `cs-fundamentals/algorithms.md`, `cs-fundamentals/system-design.md`, `cs-fundamentals/design-patterns.md` |
| BUILD | `claude-code-patterns/agent-design.md`, `claude-code-patterns/context-management.md`, `claude-code-patterns/team-coordination.md` |
| TEST | `cs-fundamentals/algorithms.md`, `claude-code-patterns/prompt-patterns.md` |
| SHIP | `claude-code-patterns/hook-patterns.md` |

**Rule:** Never load all 13 knowledge files at once. Each file is under 2000 tokens, but loading all of them wastes ~26k tokens of context. Load only what the current phase needs.

### How to Load Knowledge

When a phase starts, read the relevant knowledge files and include their content as context for the agent. Use the Agent tool's `prompt` parameter to inject knowledge, or have the agent read the files as its first action.

---

## Gate Enforcement

Gates prevent phase-skipping. Each phase has an entry gate (what must exist before it starts) and an exit gate (what it must produce).

### Entry Gates

| Phase | Required Artifact | Check |
|-------|------------------|-------|
| IDEA | None | Always allowed |
| PLAN | `.omc/artifacts/01-idea/idea-brief.md` | File exists and is non-empty |
| ARCHITECT | `.omc/artifacts/02-plan/prd.md` | File exists and is non-empty |
| BUILD | `.omc/artifacts/03-architect/architecture.md` | File exists and is non-empty |
| TEST | `.omc/artifacts/04-build/build-report.md` | File exists and is non-empty |
| SHIP | `.omc/artifacts/05-test/test-report.md` | File exists and is non-empty |

### Gate Behavior

```
IF required artifact missing:
  1. Tell user: "Phase X requires the output of Phase Y. Run /Y first."
  2. Offer to run the prerequisite phase.
  3. Do NOT proceed with the requested phase.

IF user says "skip" or "override":
  1. Allow the skip with a warning.
  2. Log the skip in .omc/state/pipeline-state.json.
  3. The skipped phase's artifact will be marked as "skipped" in state.
```

### Exit Gates

Each phase must satisfy its `pipeline/XX-phase/output-spec.md` before the handoff artifact is written. The critic agent validates output against the spec. If validation fails, the phase loops until the spec is met or the user overrides.

---

## State Tracking

All pipeline state lives in `.omc/state/`. These files are gitignored — they are runtime state, not source code.

### Pipeline State File

**Path:** `.omc/state/pipeline-state.json`

```json
{
  "current_phase": "build",
  "phase_status": "in_progress",
  "phases_completed": ["idea", "plan", "architect"],
  "phases_skipped": [],
  "started_at": "2026-04-01T10:00:00Z",
  "last_updated": "2026-04-01T14:30:00Z",
  "project_name": "my-project"
}
```

### State Operations

- **Read state** at session start to know where the project is in the pipeline.
- **Update state** when a phase starts, completes, or fails.
- **Create state** on first `/idea` invocation if it doesn't exist.
- **State is advisory.** The handoff artifacts in `.omc/artifacts/` are the real source of truth. State just tracks progress for UX.

---

## Delegation Rules

Choose the right delegation pattern based on the work to be done.

### When to Use Subagents

- Focused, single-responsibility tasks (e.g., "review this file", "write tests for this module")
- Work that benefits from context isolation (agent doesn't need to see the full conversation)
- Sequential tasks where each task's output feeds the next

### When to Use Agent Teams

- Parallel implementation of independent components (BUILD phase)
- Multiple files/modules that don't depend on each other
- Large codebases where a single agent would hit context limits

### When to Work Directly

- Simple queries, clarifications, or single-file edits
- Reading and summarizing artifacts
- State management operations

### Delegation Decision Tree

```
Is this a multi-component parallel task?
  YES → Agent Team (executor team with reviewer gate)
  NO →
    Does this need specialist knowledge?
      YES → Subagent (pick by role: interviewer, planner, architect, etc.)
      NO →
        Is this a simple operation?
          YES → Work directly
          NO → Subagent (executor for implementation, tester for tests)
```

### Agent Roster

| Agent | Role | Model | When to Use |
|-------|------|-------|-------------|
| `interviewer` | Requirements gathering | opus | IDEA phase, clarifying scope |
| `planner` | PRD generation | opus | PLAN phase |
| `architect` | System design | opus | ARCHITECT phase |
| `executor` | Implementation | sonnet | BUILD phase, code changes |
| `reviewer` | Code review | opus | BUILD phase quality gate |
| `tester` | Test writing & QA | sonnet | TEST phase |
| `release-manager` | Git, deploy, version | sonnet | SHIP phase |
| `critic` | Cross-cutting quality | opus | Any phase exit gate |

---

## Context Management

### Compaction Protocol

1. **Monitor context usage.** Compact at 50% (approximately 200k tokens). Never wait until context is full.
2. **Before compacting:**
   - Finish the current atomic task (never compact mid-file-creation).
   - Update `.omc/state/pipeline-state.json` with current progress.
   - If working on a project with AGENT_STATE.md, update it too.
   - Commit any changed files.
3. **After compacting:**
   - Re-read `.omc/state/pipeline-state.json` to restore pipeline position.
   - Re-read the current phase's handoff artifact to restore context.
   - Resume from where you left off.

### Phase Transitions

Use `/clear` when transitioning between pipeline phases (e.g., finishing PLAN, starting ARCHITECT). This gives a clean context window for the new phase. After `/clear`:
1. Read `.omc/state/pipeline-state.json`
2. Read the previous phase's handoff artifact
3. Load knowledge files for the new phase
4. Begin the new phase

### Subagent Context Budgets

| Agent Type | Max Context | Rationale |
|-----------|-------------|-----------|
| Haiku agents (explore) | Minimal | Fast lookups, small responses |
| Sonnet agents (executor, tester) | Standard | Implementation work |
| Opus agents (planner, architect, critic) | Full | Complex reasoning needs full context |

---

## Artifact Path Conventions

All phase artifacts are written to `.omc/artifacts/{phase}/`. These paths are fixed and must not change — every command, agent, and skill depends on them.

### Artifact Paths

| Phase | Directory | Primary Artifact | Description |
|-------|-----------|-----------------|-------------|
| IDEA | `.omc/artifacts/01-idea/` | `idea-brief.md` | Structured idea summary with clarity scores |
| PLAN | `.omc/artifacts/02-plan/` | `prd.md` | PRD with user stories, acceptance criteria, task breakdown |
| ARCHITECT | `.omc/artifacts/03-architect/` | `architecture.md` | Design doc with tech stack, data model, API contracts |
| BUILD | `.omc/artifacts/04-build/` | `build-report.md` | What was built, what was deferred, file manifest |
| TEST | `.omc/artifacts/05-test/` | `test-report.md` | Coverage report, acceptance criteria → test mapping |
| SHIP | `.omc/artifacts/06-ship/` | `release-notes.md` | Version, changelog, deploy status |

### Artifact Rules

- Each phase writes its artifact when its exit gate is satisfied.
- Artifacts are append-safe — a phase may write supplementary files (e.g., `architecture-adr.md`) alongside the primary artifact.
- The primary artifact filename is the contract. Agents look for it by exact name.
- If re-running a phase, the old artifact is overwritten (not versioned).

---

## Model Selection

| Task Type | Model | Rationale |
|-----------|-------|-----------|
| Planning, architecture, complex analysis | `claude-opus-4-6` | Needs deep reasoning |
| Code generation, implementation, tests | `claude-sonnet-4-6` | Fast, capable, cost-effective |
| Quick lookups, file search, simple queries | `claude-haiku-4-5` | Fastest, cheapest |
| Critical reviews, quality gates | `claude-opus-4-6` | High-stakes decisions |

**Default:** Use Sonnet for agents unless the task explicitly requires Opus-level reasoning. Use Haiku only for read-only exploration.

---

## Routing Table

### Commands (User Entry Points)

| Command | Phase | Reads | Produces | Invokes |
|---------|-------|-------|----------|---------|
| `/idea` | IDEA | Nothing | `idea-brief.md` | `interviewer` agent, `deep-interview` skill |
| `/plan` | PLAN | `idea-brief.md` | `prd.md` | `planner` agent, `prd-generator` skill |
| `/architect` | ARCHITECT | `prd.md` | `architecture.md` | `architect` agent, `system-design` skill |
| `/build` | BUILD | `architecture.md` | `build-report.md` | `executor` agent, `parallel-build` skill |
| `/test` | TEST | `build-report.md` | `test-report.md` | `tester` agent, `tdd` + `verification` skills |
| `/ship` | SHIP | `test-report.md` | `release-notes.md` | `release-manager` agent, `git-workflow` + `release` skills |
| `/full-pipeline` | ALL | Nothing | All artifacts | Chains all phases with gates |

### Skills (Auto-Invoked or Agent-Loaded)

| Skill | Phase | Pipeline Position | Handoff |
|-------|-------|-------------------|---------|
| `deep-interview` | IDEA | 1st | `.omc/artifacts/01-idea/idea-brief.md` |
| `prd-generator` | PLAN | 2nd | `.omc/artifacts/02-plan/prd.md` |
| `system-design` | ARCHITECT | 3rd | `.omc/artifacts/03-architect/architecture.md` |
| `parallel-build` | BUILD | 4th | `.omc/artifacts/04-build/build-report.md` |
| `tdd` | TEST | 5th | Test files in project |
| `verification` | TEST | 5th | `.omc/artifacts/05-test/test-report.md` |
| `git-workflow` | SHIP | 6th | Git tags, branches |
| `release` | SHIP | 6th | `.omc/artifacts/06-ship/release-notes.md` |

### Agents (Specialist Workers)

| Agent | Primary Phase | Model | Key Constraint |
|-------|--------------|-------|----------------|
| `interviewer` | IDEA | opus | Read-only (no code changes) |
| `planner` | PLAN | opus | Read-only |
| `architect` | ARCHITECT | opus | Read-only (produces design, not code) |
| `executor` | BUILD | sonnet | Full tool access |
| `reviewer` | BUILD | opus | Read-only (`disallowedTools: Write, Edit`) |
| `tester` | TEST | sonnet | Full tool access |
| `release-manager` | SHIP | sonnet | Git + file access |
| `critic` | Any exit gate | opus | Read-only, validates against output-spec |

---

## Compaction Recovery Protocol

After any compaction (`/compact`) or context clear (`/clear`):

```
1. Read .omc/state/pipeline-state.json     ← know which phase you're in
2. Read the current phase's handoff artifact ← know what was produced so far
3. Read the previous phase's artifact        ← know the input you're working from
4. Load knowledge files for current phase    ← restore domain context
5. Resume work from where state indicates
```

**Trust disk state over compacted memory.** The compacted summary is lossy. The state files and artifacts are the source of truth.

---

## Pipeline Execution Protocol

When running any phase:

```
1. CHECK GATE    → Does the required input artifact exist?
2. LOAD CONTEXT  → Read knowledge files for this phase
3. READ INPUT    → Read the previous phase's handoff artifact
4. EXECUTE       → Run the phase's agent/skill
5. VALIDATE      → Run critic agent against pipeline/XX-phase/output-spec.md
6. WRITE OUTPUT  → Save handoff artifact to .omc/artifacts/XX-phase/
7. UPDATE STATE  → Update .omc/state/pipeline-state.json
8. HANDOFF       → If running full-pipeline, proceed to next phase
```

---

## Quick Reference

- **Start a new project:** `/idea`
- **Resume where you left off:** Check `.omc/state/pipeline-state.json`
- **Skip a phase:** Say "skip" when gate blocks you
- **Run everything:** `/full-pipeline`
- **Check phase requirements:** Read `pipeline/XX-phase/output-spec.md`
- **Available knowledge:** 13 files in `knowledge/` (4 CS fundamentals, 6 Claude Code patterns, 3 harness internals)
