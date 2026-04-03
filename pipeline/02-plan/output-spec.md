# Plan Phase — Output Spec

> **Critic agent:** Validate the PRD artifact against this spec before allowing phase transition.

## Artifact

- **Path:** `.omc/artifacts/02-plan/prd.md`
- **Format:** Markdown with required H2 sections

## Required Inputs

- `.omc/artifacts/01-idea/idea-brief.md` must exist and be non-empty

## Required Sections

The artifact MUST contain all of the following H2 sections, each non-empty:

### 1. `## Overview`
- Project name
- One-paragraph summary (derived from idea-brief problem statement)
- Link/reference to the source idea-brief

### 2. `## User Stories`
- At least 3 user stories
- Each story follows the format: "As a [persona], I want [action] so that [benefit]"
- Every persona from the idea-brief must appear in at least one story

### 3. `## Acceptance Criteria`
- Every user story has at least one acceptance criterion
- Each criterion is a testable condition (Given/When/Then or equivalent)
- Criteria map back to success criteria from the idea-brief

### 4. `## Task Breakdown`
- Hierarchical list of implementation tasks
- Each user story is covered by at least one task
- Tasks have size estimates (S/M/L or story points)
- No task larger than L (large tasks must be decomposed)

### 5. `## Dependencies`
- Dependency graph or ordered list showing task prerequisites
- External dependencies identified (APIs, services, libraries)
- Critical path highlighted

### 6. `## Priority Ranking`
- All tasks ranked by priority (P0 = must-have, P1 = should-have, P2 = nice-to-have)
- At least one P0 task exists
- Ranking rationale provided

### 7. `## Scope & Non-Goals`
- Explicit list of what is in scope (derived from idea-brief proposed solution)
- Explicit list of what is out of scope (derived from idea-brief constraints)

## Validation Rules

```
PASS if:
  - All 7 sections exist and are non-empty
  - At least 3 user stories present
  - Every user story has ≥ 1 acceptance criterion
  - Every user story is covered by ≥ 1 task in the breakdown
  - At least one P0 task exists
  - Dependencies section is present (even if "none")
  - All idea-brief personas appear in user stories

FAIL if:
  - Any required section is missing or empty
  - Fewer than 3 user stories
  - Any user story lacks acceptance criteria
  - Any user story has no corresponding task
  - No P0 tasks defined
  - Idea-brief personas not represented
```

## Outputs Consumed By

- **ARCHITECT phase** reads `prd.md` to design the system
- Architect phase expects: task breakdown, acceptance criteria, dependencies, and scope
