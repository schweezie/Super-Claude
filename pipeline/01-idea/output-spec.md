# Idea Phase — Output Spec

> **Critic agent:** Validate the idea-brief artifact against this spec before allowing phase transition.

## Artifact

- **Path:** `.omc/artifacts/01-idea/idea-brief.md`
- **Format:** Markdown with required H2 sections

## Required Sections

The artifact MUST contain all of the following H2 sections, each non-empty:

### 1. `## Problem Statement`
- Clearly states the problem being solved
- Identifies who experiences this problem
- Explains why existing solutions are insufficient

### 2. `## Target Users`
- At least one user persona defined
- Each persona has: role/description, key pain points, what success looks like for them

### 3. `## Proposed Solution`
- High-level description of what will be built
- Core capabilities (bulleted list, at least 3 items)
- What it explicitly will NOT do (scope boundaries)

### 4. `## Success Criteria`
- At least 3 measurable success criteria
- Each criterion is testable (can be verified as met or not met)

### 5. `## Constraints`
- Technical constraints (platform, language, infrastructure limitations)
- Time/resource constraints (if any)
- Regulatory or compliance constraints (if any)
- "None identified" is acceptable but the section must exist

### 6. `## Clarity Scores`
- Scores for each dimension on a 1–5 scale:
  - Problem clarity
  - User clarity
  - Scope clarity
  - Success criteria clarity
- Each score must be ≥ 3 to pass
- If any score < 3, the interviewer must loop back for clarification

### 7. `## User Confirmation`
- Explicit record that the user reviewed and approved the brief
- Timestamp of confirmation

## Validation Rules

```
PASS if:
  - All 7 sections exist and are non-empty
  - All clarity scores ≥ 3
  - At least 3 success criteria listed
  - At least 1 user persona defined
  - User confirmation section has approval record

FAIL if:
  - Any required section is missing or empty
  - Any clarity score < 3
  - Fewer than 3 success criteria
  - No user personas defined
  - No user confirmation recorded
```

## Inputs

- None (this is the first phase)

## Outputs Consumed By

- **PLAN phase** reads `idea-brief.md` to generate the PRD
- Plan phase expects: problem statement, target users, success criteria, and constraints
