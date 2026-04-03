# Super Claude — User Guide

> How to take any idea from concept to shipped product using a structured AI pipeline.

---

## What Is Super Claude?

Super Claude turns Claude Code into a disciplined software factory. Instead of opening a chat and hoping for the best, you run a six-step pipeline that interviews you about your idea, writes a product spec, designs the architecture, builds the code, tests it, and ships a release. Each step is handled by a specialized AI agent, and each step produces a concrete document that feeds the next.

You don't need to be a professional developer. You need an idea and the willingness to answer questions about it. Super Claude handles the structure, the planning, and the implementation. You steer.

---

## Prerequisites

**You need two things:**

1. **Claude Code** — Anthropic's CLI tool. If you don't have it yet, install it from [claude.ai/download](https://claude.ai/download) and sign in.
2. **Git** — For version control. Most computers already have it. Type `git --version` in your terminal to check.

---

## Installation

```bash
# Clone the repo
git clone https://github.com/schweezie/Super-Claude.git my-project
cd my-project

# Create the runtime directories (needed for a fresh clone)
mkdir -p .omc/artifacts/01-idea .omc/artifacts/02-plan .omc/artifacts/03-architect
mkdir -p .omc/artifacts/04-build .omc/artifacts/05-test .omc/artifacts/06-ship
mkdir -p .omc/state .omc/memory

# Open Claude Code
claude
```

That's it. You're ready.

---

## The Full Walkthrough: Building a Habit Tracker

Let's build a real app from scratch. We'll go through every phase so you can see exactly what happens.

### Phase 1: The Idea Interview

**What you type:**

```
/idea
```

**What happens:**

Claude switches into interviewer mode. It doesn't start coding. It starts asking you questions — one at a time, like a thoughtful product manager.

The conversation might go like this:

> **Claude:** Tell me about the problem you want to solve. Who experiences it, and why do current solutions fall short?
>
> **You:** I want a simple habit tracker. I keep trying apps like Habitica and Streaks but they're too complicated. I just want to check off habits each day and see my streaks.
>
> **Claude:** What would make this different from a simple checklist app? What's the core behavior you want?
>
> **You:** Daily check-ins. I open it, I see my habits, I tap the ones I did today. I want to see how many days in a row I've done each one. That's it.
>
> **Claude:** Who is this for — just you, or are you building this for others too?
>
> **You:** Just me for now, but I'd share it if it works.

Claude keeps digging — asking about success criteria ("how will you know this works?"), constraints ("does it need to be mobile?"), and scope boundaries ("what will it NOT do?").

After enough clarity, Claude scores your idea on four dimensions:

```
| Dimension        | Score |
|------------------|-------|
| Problem          | 4/5   |
| User             | 4/5   |
| Scope            | 5/5   |
| Success Criteria | 4/5   |
```

All scores must be 3 or higher. If any are too low, Claude asks more questions until they're not.

**What it produces:**

A structured idea brief saved to `.omc/artifacts/01-idea/idea-brief.md`. This document captures everything: the problem, users, solution, success criteria, and constraints. You can open the file and read it.

**Claude tells you:**

> Idea brief complete. Run `/plan` to generate the PRD.

---

### Phase 2: The Product Plan

**What you type:**

```
/plan
```

**What happens:**

Claude reads the idea brief you just created and transforms it into a formal product requirements document (PRD). You don't need to repeat yourself — it already knows everything from Phase 1.

It generates:

- **User stories** — "As a user, I want to mark a habit as done today so that my streak count increases."
- **Acceptance criteria** — "Given I completed a habit yesterday and today, when I view the habit, then the streak shows 2."
- **Task breakdown** — Every piece of work needed, sized as S/M/L.
- **Priority ranking** — P0 (must have), P1 (should have), P2 (nice to have).
- **Dependencies** — What must be built before what.

Example output excerpt:

```
## User Stories

1. As a user, I want to see all my habits on one screen so I can
   quickly check in each day.
2. As a user, I want to tap a habit to mark it done today so that
   my streak updates.
3. As a user, I want to see my current streak for each habit so
   I stay motivated.
4. As a user, I want to add and remove habits so I can customize
   my routine.

## Task Breakdown

- T1 (S): Set up project scaffold
- T2 (M): Build habit list UI
- T3 (M): Implement daily check-in logic
- T4 (M): Build streak calculation engine
- T5 (S): Add/remove habit management
- T6 (S): Local storage persistence
- T7 (S): Deploy to Vercel

## Priority Ranking

- P0: T1, T2, T3, T4 (core loop — see habits, check in, see streaks)
- P1: T5 (habit management)
- P2: T6, T7 (persistence, deploy)
```

**What it produces:**

A PRD saved to `.omc/artifacts/02-plan/prd.md`.

---

### Phase 3: Architecture Design

**What you type:**

```
/architect
```

**What happens:**

Claude reads the PRD and designs the entire technical system. It chooses the tech stack, designs the data model, defines API contracts, plans the file structure, and maps every PRD task to an architectural component.

Every choice comes with a justification — not just "use React" but "use React because the PRD calls for a single-page app with interactive check-in behavior, and the team has familiarity with it."

Example output excerpt:

```
## Tech Stack

- Language: TypeScript — type safety for streak logic
- Framework: Next.js 14 — fast setup, good for single-page apps
- Storage: localStorage (MVP), upgradeable to Supabase
- Styling: Tailwind CSS — rapid UI development

## Data Model

- Habit: { id, name, createdAt }
- CheckIn: { habitId, date }
- Streak is calculated, not stored (count consecutive
  check-in dates backward from today)

## File Structure

src/
  app/page.tsx          — Main habit list + check-in UI
  lib/habits.ts         — Habit CRUD operations
  lib/streaks.ts        — Streak calculation logic
  lib/storage.ts        — localStorage wrapper
  components/
    HabitCard.tsx        — Single habit with check-in button
    AddHabitForm.tsx     — New habit input
```

**What it produces:**

An architecture document saved to `.omc/artifacts/03-architect/architecture.md`.

---

### Phase 4: Build

**What you type:**

```
/build
```

**What happens:**

This is where code gets written. Claude reads the architecture and implements it — creating files, installing dependencies, writing components, and wiring everything together.

For independent components (like `streaks.ts` and `AddHabitForm.tsx`), it can spawn parallel agents to build them simultaneously.

After building, a separate reviewer agent (read-only, cannot change code) audits the implementation against the architecture. If it finds issues, the builder fixes them.

**What it produces:**

- Working code in your project directory
- A build report at `.omc/artifacts/04-build/build-report.md` documenting what was built, what was deferred, and the reviewer's verdict

---

### Phase 5: Test

**What you type:**

```
/test
```

**What happens:**

Claude reads the PRD's acceptance criteria and the build report, then writes tests for every criterion. It runs the test suite, measures code coverage, and documents any bugs found.

Example output excerpt:

```
## Test Summary
- Total tests: 12
- Passed: 11 | Failed: 1 | Skipped: 0
- Coverage: 82%

## Bug Report
| Severity | Description                              | Status |
|----------|------------------------------------------|--------|
| medium   | Streak resets on timezone change          | open   |
```

Critical and high-severity bugs must be fixed before shipping. Medium and low can ship as known issues.

**What it produces:**

A test report at `.omc/artifacts/05-test/test-report.md`.

---

### Phase 6: Ship

**What you type:**

```
/ship
```

**What happens:**

Claude verifies the test report passes, picks a version number (0.1.0 for a first release), generates a changelog, and creates a git tag. It asks you before pushing anything.

**What it produces:**

Release notes at `.omc/artifacts/06-ship/release-notes.md`. Your project is shipped.

---

### The Shortcut: Full Pipeline

If you want to run all six phases back-to-back without typing each command:

```
/full-pipeline
```

Claude chains everything together, handling gates and context management automatically. If your session runs out of context mid-pipeline, it saves state and tells you how to resume.

---

## Quick Reference

| Command | What It Does | Agent | Produces |
|---------|-------------|-------|----------|
| `/idea` | Interviews you about your project | interviewer (Opus) | `idea-brief.md` |
| `/plan` | Generates PRD with user stories and tasks | planner (Opus) | `prd.md` |
| `/architect` | Designs tech stack, data model, APIs | architect (Opus) | `architecture.md` |
| `/build` | Writes the code | executor (Sonnet) | working code + `build-report.md` |
| `/test` | Writes and runs tests | tester (Sonnet) | `test-report.md` |
| `/ship` | Tags version, generates changelog | release-manager (Sonnet) | `release-notes.md` |
| `/full-pipeline` | Runs all 6 phases in sequence | all agents | all artifacts |

All artifacts are saved in `.omc/artifacts/` and can be opened and read at any time.

---

## Templates

If you already know what kind of project you're building, start with a template:

| I'm building a... | Use this template | Command |
|-------------------|-------------------|---------|
| Web app (React/Next.js) | `templates/web-app/` | Copy into project root |
| REST API (Python/FastAPI) | `templates/api-service/` | Copy into project root |
| CLI tool (Python) | `templates/cli-tool/` | Copy into project root |
| Full-stack app (frontend + backend) | `templates/full-stack/` | Copy into project root |
| Multi-agent AI system | `templates/agent-system/` | Copy into project root |

To use a template:

```bash
# Example: starting with the web-app template
cp -r templates/web-app/* .
cp templates/web-app/.* . 2>/dev/null
```

Then run `/idea` to start the pipeline. The template gives you the project skeleton; the pipeline fills it in.

---

## Tips and Troubleshooting

**My session ended mid-build. How do I resume?**
Just open Claude Code again and run the command you were on (e.g., `/build`). Super Claude tracks state in `.omc/state/pipeline-state.json`. It knows where you left off and offers to resume.

**Claude says I need to run a previous phase first.**
That's the gate system. Each phase requires the previous phase's output. Run the phase it suggests, or say "skip" to bypass the gate (with a warning).

**I want to redo a phase.**
Just run the command again. It overwrites the previous artifact. For example, if your architecture doesn't feel right, run `/architect` again.

**The context window is filling up.**
Run `/clear` to get a fresh context window. Super Claude's recovery protocol re-reads your state files automatically, so you pick up right where you left off.

**I want to change something in the PRD after building.**
You can re-run `/plan`, but note that downstream artifacts (architecture, code, tests) won't automatically update. You'll need to re-run those phases too. The pipeline flows forward.

**Can I use this on an existing project?**
Yes. Copy the `.claude/`, `knowledge/`, `pipeline/` directories and `CLAUDE.md` into your existing project. Create the `.omc/` directories. Then run `/idea` (or skip to a later phase if you already have the artifacts).

**What models does this use?**
Planning and review phases use Claude Opus (deeper reasoning). Implementation and testing use Claude Sonnet (faster, cost-effective). You don't need to manage this — the commands pick the right model automatically.

---

## How It All Fits Together

```
You have an idea
       |
       v
   /idea  ------>  idea-brief.md
       |
       v
   /plan  ------>  prd.md
       |
       v
 /architect ----->  architecture.md
       |
       v
   /build ------>  working code + build-report.md
       |
       v
   /test  ------>  test-report.md
       |
       v
   /ship  ------>  release-notes.md
       |
       v
  Your idea is shipped.
```

Each arrow is a gate. Each document is a contract. Nothing gets skipped unless you say so.

---

*Built with Super Claude. Powered by Claude Code.*
