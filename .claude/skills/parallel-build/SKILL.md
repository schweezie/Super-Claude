---
name: parallel-build
description: Multi-agent parallel implementation that turns an architecture document into working code. Spawns executor subagents for independent components and gates with reviewer. Use for the BUILD phase.
level: 6
aliases: [build, implement, code-build]
argument-hint: "[architecture-path]"
agent: executor
model: sonnet
pipeline: [deep-interview, prd-generator, system-design, parallel-build, tdd, verification, git-workflow, release]
next-skill: tdd
handoff: .omc/artifacts/04-build/build-report.md
---

<Purpose>
Transform an architecture document into working, buildable code. Set up the project, implement components (parallelizing independent work), run the reviewer agent as a quality gate, and produce a build report documenting what was built, deferred, and verified.
</Purpose>

<Use_When>
- The `/build` command is invoked
- `.omc/artifacts/03-architect/architecture.md` exists and is non-empty
- User says "build", "implement", "code", "create", or "develop"
- Transitioning from ARCHITECT to BUILD in the pipeline
</Use_When>

<Do_Not_Use_When>
- No architecture document exists (run system-design first)
- User wants to write a single file or make a small edit (just do it directly)
- User is prototyping and doesn't want the full pipeline
</Do_Not_Use_When>

<Steps>

## Step 1: Load Inputs

1. Read `.omc/artifacts/03-architect/architecture.md` — extract tech stack, file structure, data model, API contracts, coverage matrix
2. Read `.omc/artifacts/02-plan/prd.md` — extract task priorities (P0/P1/P2)
3. Load knowledge: `knowledge/claude-code-patterns/agent-design.md`, `knowledge/claude-code-patterns/context-management.md`, `knowledge/claude-code-patterns/team-coordination.md`
4. Read `.omc/state/pipeline-state.json` if it exists

## Step 2: Project Setup

1. Create directory structure from architecture's File Structure section
2. Initialize project (package manager, config files, entry points)
3. Install dependencies from tech stack
4. Verify bare project compiles/runs — fix any setup issues before proceeding

## Step 3: Plan Implementation Order

From the coverage matrix and dependency graph:

1. **Foundation first:** Data models, config, utilities, shared types
2. **Core logic second:** Business logic, services, state management
3. **Interface layer third:** API routes, UI components, CLI handlers
4. **Integration last:** External services, auth, deployment config

Identify independent components that can be built in parallel.

## Step 4: Implement Components

For each component group:

**If components are independent** (no shared state or sequential dependency):
- Spawn parallel executor subagents via the Agent tool
- Each subagent gets: the architecture section for its component, the relevant data model, and API contracts
- Subagents write code directly to the project

**If components are dependent:**
- Build sequentially in dependency order
- Verify each component works before starting the next

Track progress per component: not-started → in-progress → complete → reviewed.

## Step 5: Build Verification

After all components are implemented:

1. Run the build/compile command — ensure zero errors
2. Run the application briefly — ensure it starts
3. Fix any build failures before proceeding
4. Note any warnings

## Step 6: Code Review Gate

Invoke the reviewer agent to audit the implementation:

- Reviewer checks: code quality, architecture adherence, security, missing error handling
- If reviewer requests changes: implement fixes, re-run reviewer
- If reviewer approves: record approval in build report
- If no reviewer available: note this with justification

## Step 7: Write Build Report

Assemble with these exact H2 sections:
- `## Implementation Summary` (what was built, architecture changes, file count)
- `## Component Status` (table: component, status, justification)
- `## File Manifest` (all files created/modified with descriptions)
- `## Build Verification` (compile/run evidence, dependency status)
- `## Review Status` (reviewer assessment)
- `## Deferred Items` (what wasn't built and why)
- `## Architecture Coverage` (component → implementation mapping)

Write to `.omc/artifacts/04-build/build-report.md`. Update pipeline state.

</Steps>

<Tool_Usage>
- **Read**: Load architecture, PRD, state, knowledge
- **Write**: Create new project files
- **Edit**: Modify existing files
- **Bash**: Run build commands, install dependencies, start application
- **Glob/Grep**: Find files, check for patterns
- **Agent**: Spawn parallel executor subagents for independent components
</Tool_Usage>

<Escalation_And_Stop_Conditions>
- **Stop if** architecture document doesn't exist — direct user to run `/architect` first
- **Stop if** build fails after 3 attempts on the same error — present error and ask user for guidance
- **Escalate if** a P0 task cannot be implemented due to missing information in architecture — ask user to resolve
- **Escalate if** reviewer flags critical security issues — do not proceed until resolved
- **Escalate if** context is approaching 50% — checkpoint progress, update state, and compact
</Escalation_And_Stop_Conditions>

<Final_Checklist>
- [ ] All 7 H2 sections present and non-empty in build report
- [ ] Project compiles/runs without errors
- [ ] Dependencies declared (package.json, requirements.txt, etc.)
- [ ] No hardcoded secrets or credentials
- [ ] File structure matches architecture plan (or deviations documented)
- [ ] Review status is "approved" or has justified exemption
- [ ] All architecture components accounted for in coverage
- [ ] Deferred items (if any) are justified
- [ ] Artifact written to `.omc/artifacts/04-build/build-report.md`
- [ ] Pipeline state updated
</Final_Checklist>
