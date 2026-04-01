# Super Claude

> A complete operating system for taking any software project from idea to shipped product, powered by Claude Code and multi-agent orchestration.

## What Is This?

Super Claude is a structured pipeline that transforms a vague idea into a deployed, tested, versioned product through six phases — each orchestrated by specialized AI agents with defined entry/exit gates, knowledge injection, and quality validation.

```
/idea  -->  /plan  -->  /architect  -->  /build  -->  /test  -->  /ship
```

Each phase produces a versioned artifact that feeds the next. Gates prevent phase-skipping. A critic agent validates every phase exit against its output spec. State is tracked on disk so work survives context compactions and session restarts.

## Quick Start

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and authenticated
- Git

### Installation

```bash
git clone <this-repo-url> my-project
cd my-project
```

Super Claude works by configuring your Claude Code environment. The `.claude/` directory contains all commands, agents, skills, and hooks. The `CLAUDE.md` file at the root orchestrates everything.

### First Run

Start a new project:

```
/idea
```

Claude will interview you to extract your vision, then produce a structured idea brief. Continue through the pipeline:

```
/plan        # Generate PRD from idea brief
/architect   # Design system architecture from PRD
/build       # Implement the architecture
/test        # Write and run tests
/ship        # Tag, release, and deploy
```

Or run everything end-to-end:

```
/full-pipeline
```

## Pipeline Phases

### /idea — Requirements Interview

**Agent:** `interviewer` (Opus) | **Skill:** `deep-interview`

Socratic questioning extracts problem, users, solution, success criteria, and constraints. Scores clarity on 4 dimensions (1-5). Loops until all scores >= 3.

**Produces:** `.omc/artifacts/01-idea/idea-brief.md`

### /plan — PRD Generation

**Agent:** `planner` (Opus) | **Skill:** `prd-generator`

Transforms the idea brief into a PRD with user stories, acceptance criteria, task breakdown, dependencies, and priority ranking (P0/P1/P2).

**Produces:** `.omc/artifacts/02-plan/prd.md`

### /architect — System Design

**Agent:** `architect` (Opus) | **Skill:** `system-design`

Designs tech stack, system architecture, data model, API contracts, file structure, and PRD coverage matrix. Every choice includes justification and tradeoff notes.

**Produces:** `.omc/artifacts/03-architect/architecture.md`

### /build — Implementation

**Agent:** `executor` (Sonnet) + `reviewer` (Opus) | **Skill:** `parallel-build`

Implements the architecture with parallel agent teams for independent components. A reviewer agent gates the output for quality.

**Produces:** `.omc/artifacts/04-build/build-report.md` + working code

### /test — Quality Assurance

**Agent:** `tester` (Sonnet) | **Skills:** `tdd` + `verification`

Maps every PRD acceptance criterion to tests. Runs the suite, measures coverage (>= 60% threshold), and documents bugs by severity.

**Produces:** `.omc/artifacts/05-test/test-report.md`

### /ship — Release

**Agent:** `release-manager` (Sonnet) | **Skills:** `git-workflow` + `release`

Verifies release readiness, determines semver version, generates changelog, creates git tags or PRs, and documents known issues.

**Produces:** `.omc/artifacts/06-ship/release-notes.md`

## Gate Enforcement

Each phase (except `/idea`) requires the previous phase's artifact to exist:

| Phase | Requires |
|-------|----------|
| /plan | `idea-brief.md` |
| /architect | `prd.md` |
| /build | `architecture.md` |
| /test | `build-report.md` |
| /ship | `test-report.md` |

If a gate blocks you, the system offers to run the prerequisite phase. You can say "skip" or "override" to bypass with a warning.

## Templates

Super Claude includes starter templates for common project types:

| Template | Stack | Location |
|----------|-------|----------|
| **web-app** | Next.js + Tailwind + TypeScript | `templates/web-app/` |
| **api-service** | FastAPI + SQLAlchemy + Alembic | `templates/api-service/` |
| **cli-tool** | Python + Click + Rich | `templates/cli-tool/` |
| **full-stack** | Next.js frontend + FastAPI backend | `templates/full-stack/` |
| **agent-system** | Claude Code agents + skills | `templates/agent-system/` |

Each template includes its own `CLAUDE.md` with framework-specific conventions.

## Architecture

```
Super Claude/
  CLAUDE.md                    # Pipeline orchestration brain
  .claude/
    commands/                  # Slash command entry points (7)
    agents/                    # Specialist agent configs (8)
    skills/                    # Reusable skill definitions (8)
    hooks/                     # Lifecycle hooks (4)
    settings.json              # Tool permissions + hook registration
  pipeline/
    01-idea/ .. 06-ship/       # Output specs per phase
  knowledge/
    cs-fundamentals/           # Data structures, algorithms, design patterns, system design
    claude-code-patterns/      # Agent design, context mgmt, team coordination, hooks, prompts, skills
    harness-internals/         # Tool orchestration, context window, runtime behavior
  templates/                   # Starter project scaffolds
  .omc/
    artifacts/                 # Phase output artifacts (gitignored)
    state/                     # Pipeline state tracking (gitignored)
```

### Agent Roster

| Agent | Model | Role | Access |
|-------|-------|------|--------|
| interviewer | Opus | Requirements gathering | Read-only |
| planner | Opus | PRD generation | Read-only |
| architect | Opus | System design | Read-only |
| executor | Sonnet | Code implementation | Full |
| reviewer | Opus | Code review gate | Read-only |
| tester | Sonnet | Test writing + QA | Full |
| release-manager | Sonnet | Git + deploy | Full |
| critic | Opus | Phase exit validation | Read-only |

### Knowledge Base

13 distilled knowledge files injected per-phase to provide domain context without overloading the context window. Each file is under 2000 tokens. Only the files relevant to the current phase are loaded.

## State & Recovery

Pipeline state is tracked in `.omc/state/pipeline-state.json`. If a session ends mid-phase, the next session reads this file and offers to resume.

After a context compaction (`/compact`) or clear (`/clear`), the agent follows a recovery protocol:

1. Read `pipeline-state.json` for current phase
2. Read the current phase's handoff artifact
3. Read the previous phase's artifact for input context
4. Load knowledge files for the current phase
5. Resume work

The principle: **trust disk state over compacted memory.**

## Hooks

Four lifecycle hooks provide guardrails:

- **session-start.js** — Reads pipeline state, sets context
- **pre-tool-use.js** — Blocks dangerous operations (`rm -rf`, force push, `curl|bash`)
- **post-tool-use.js** — Logs actions, enforces artifact path conventions
- **stop.js** — Nudges agent to update state before stopping

## Running Tests

```bash
bash tests/e2e-dry-run.sh
```

This validates the entire pipeline structure: all files exist, commands reference correct agents/skills, gate enforcement is wired correctly, mock artifacts validate against output specs, and templates are structurally complete.

## License

MIT
