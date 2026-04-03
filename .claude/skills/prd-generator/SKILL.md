---
name: prd-generator
description: Transforms an idea brief into a complete PRD with user stories, acceptance criteria, task breakdown, dependencies, and priorities. Use after deep-interview or when planning a project.
level: 5
aliases: [prd, plan-generator, requirements-doc]
argument-hint: "[idea-brief-path]"
agent: planner
model: opus
pipeline: [deep-interview, prd-generator, system-design, parallel-build, tdd, verification, git-workflow, release]
next-skill: system-design
handoff: .omc/artifacts/02-plan/prd.md
---

<Purpose>
Transform a validated idea brief into a structured PRD with user stories, acceptance criteria, task breakdown, dependency graph, and priority ranking. The PRD becomes the contract that downstream phases (architect, build, test) work from.
</Purpose>

<Use_When>
- The `/plan` command is invoked
- `.omc/artifacts/01-idea/idea-brief.md` exists with all clarity scores >= 3
- User says "plan", "PRD", "requirements", "user stories", or "let's plan"
- Transitioning from IDEA to PLAN in the pipeline
</Use_When>

<Do_Not_Use_When>
- No idea brief exists (run deep-interview first)
- A valid PRD already exists and user hasn't requested a rewrite
- User wants to jump straight to architecture or code
</Do_Not_Use_When>

<Steps>

## Step 1: Load Inputs

1. Read `.omc/artifacts/01-idea/idea-brief.md` — extract problem, users, solution, success criteria, constraints
2. Read `.omc/state/pipeline-state.json` if it exists
3. Load knowledge: `knowledge/cs-fundamentals/system-design.md`, `knowledge/cs-fundamentals/design-patterns.md`

## Step 2: Extract User Stories

For every persona in the idea brief's Target Users section, generate user stories:

- Format: "As a [persona], I want [action] so that [benefit]"
- Minimum 3 stories total
- Every persona must appear in at least one story
- Stories should cover the core capabilities listed in the idea brief

Present stories to user for review. Add, modify, or remove based on feedback.

## Step 3: Define Acceptance Criteria

For each user story, define testable acceptance criteria:

- Use Given/When/Then format or equivalent testable conditions
- Each story gets at least 1 criterion
- Criteria must map back to success criteria from the idea brief
- Be specific enough that a tester can verify pass/fail

## Step 4: Build Task Breakdown

Decompose user stories into implementation tasks:

- Hierarchical: epics → tasks → subtasks
- Every user story is covered by at least one task
- Size estimates: S (< 2 hours), M (2-8 hours), L (1-2 days)
- No task larger than L — decompose further if needed
- Include setup/infrastructure tasks that stories imply

## Step 5: Map Dependencies

1. Identify task prerequisites (which tasks block others)
2. Flag external dependencies (APIs, services, libraries, accounts)
3. Highlight the critical path (longest chain of dependent tasks)
4. Present as an ordered list or simple dependency notation: `A → B → C`

## Step 6: Prioritize

Rank all tasks:
- **P0 (must-have):** Core functionality, required for MVP
- **P1 (should-have):** Important but can launch without
- **P2 (nice-to-have):** Enhancements, polish, stretch goals

At least one P0 task must exist. Provide rationale for rankings.

## Step 7: Define Scope Boundaries

- **In scope:** Derived from idea brief's Proposed Solution + core capabilities
- **Out of scope:** Derived from idea brief's explicit non-goals + constraints
- Resolve any ambiguity with the user

## Step 8: Draft and Write PRD

Assemble the PRD with these exact H2 sections:
- `## Overview` (project name, summary, reference to idea brief)
- `## User Stories`
- `## Acceptance Criteria`
- `## Task Breakdown`
- `## Dependencies`
- `## Priority Ranking`
- `## Scope & Non-Goals`

Write to `.omc/artifacts/02-plan/prd.md`. Update pipeline state.

</Steps>

<Tool_Usage>
- **Read**: Load idea brief, state, knowledge files
- **Glob/Grep**: Check for existing artifacts
- **Write**: Write the PRD artifact (done by invoking command when agent is read-only)
</Tool_Usage>

<Escalation_And_Stop_Conditions>
- **Stop if** idea brief doesn't exist — direct user to run `/idea` first
- **Stop if** idea brief has clarity scores < 3 — suggest re-running deep-interview
- **Escalate if** user stories conflict with each other — present the conflict and ask user to resolve
- **Escalate if** task decomposition would exceed 50 tasks — ask user to narrow scope or accept a phased approach
</Escalation_And_Stop_Conditions>

<Final_Checklist>
- [ ] All 7 H2 sections present and non-empty
- [ ] At least 3 user stories
- [ ] Every persona from idea brief represented in stories
- [ ] Every user story has >= 1 acceptance criterion
- [ ] Every user story covered by >= 1 task
- [ ] No task larger than L
- [ ] At least one P0 task
- [ ] Dependencies section present
- [ ] Scope boundaries defined
- [ ] Artifact written to `.omc/artifacts/02-plan/prd.md`
- [ ] Pipeline state updated
</Final_Checklist>
