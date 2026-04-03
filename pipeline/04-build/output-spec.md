# Build Phase — Output Spec

> **Critic agent:** Validate the build artifacts against this spec before allowing phase transition.

## Artifacts

- **Primary:** `.omc/artifacts/04-build/build-report.md`
- **Secondary:** Working code in the project repository
- **Format:** Markdown with required H2 sections

## Required Inputs

- `.omc/artifacts/03-architect/architecture.md` must exist and be non-empty

## Required Sections (build-report.md)

The build report MUST contain all of the following H2 sections, each non-empty:

### 1. `## Implementation Summary`
- What was built (high-level description)
- Architecture decisions that changed during implementation (if any)
- Total files created/modified count

### 2. `## Component Status`
- Table listing each component from the architecture
- Status per component: complete, partial, deferred, or skipped
- Justification for any non-complete status

### 3. `## File Manifest`
- List of all files created or modified
- Each file has a one-line description of its purpose
- Organized by component or directory

### 4. `## Build Verification`
- Evidence that the code compiles/runs (command output or confirmation)
- Runtime: language version, dependency install status
- Any build warnings noted

### 5. `## Review Status`
- Reviewer agent assessment: approved, changes-requested, or pending
- If changes-requested: what was flagged and whether it was resolved
- If no reviewer was used: explicit note and justification

### 6. `## Deferred Items`
- Tasks from the architecture that were not implemented
- Reason for deferral
- Impact on functionality
- "None — all tasks implemented" is acceptable

### 7. `## Architecture Coverage`
- Table mapping each architecture component to implementation status
- Cross-references the PRD coverage matrix from architecture.md
- Every architecture component must appear

## Code Quality Requirements

The working code in the repository must satisfy:

```
- Project runs without errors (build/compile succeeds)
- Dependencies are declared (package.json, requirements.txt, etc.)
- No hardcoded secrets or credentials
- File structure matches architecture.md plan (or deviations documented)
```

## Validation Rules

```
PASS if:
  - All 7 sections in build-report.md exist and are non-empty
  - Build verification confirms code compiles/runs
  - Review status is "approved" or justified exemption
  - Architecture coverage matrix has no unaccounted components
  - Deferred items (if any) are justified

FAIL if:
  - Any required section is missing or empty
  - Code does not compile/run
  - Review status is "changes-requested" with unresolved issues
  - Architecture components missing from coverage
  - Deferred items lack justification
```

## Outputs Consumed By

- **TEST phase** reads `build-report.md` to plan test strategy
- Test phase expects: file manifest, component status, deferred items, and architecture coverage
