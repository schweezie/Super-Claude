# Ship Phase — Output Spec

> **Critic agent:** Validate the release artifact against this spec before declaring pipeline complete.

## Artifact

- **Path:** `.omc/artifacts/06-ship/release-notes.md`
- **Format:** Markdown with required H2 sections

## Required Inputs

- `.omc/artifacts/05-test/test-report.md` must exist and be non-empty

## Required Sections

The release notes MUST contain all of the following H2 sections, each non-empty:

### 1. `## Release Info`
- Version number (semver format: MAJOR.MINOR.PATCH)
- Release date
- Project name
- One-line release summary

### 2. `## Changelog`
- List of changes grouped by category: Added, Changed, Fixed, Removed
- At least one category must have entries
- Each entry is a concise description of the change

### 3. `## Test Status`
- Reference to test-report.md results
- Overall test result: PASS (required for release)
- Coverage percentage
- Open bugs summary (must confirm: no critical/high open)

### 4. `## Deployment`
- How the release was deployed or packaged
- One of: git tag created, PR created, package published, deployed to environment, or manual release
- Evidence of the deployment action (tag name, PR URL, deploy log snippet)

### 5. `## Known Issues`
- Open medium/low severity bugs from test report (if any)
- Deferred items from build and test phases
- Workarounds documented for known issues
- "None" is acceptable

### 6. `## What's Next`
- Suggested follow-up work (deferred features, improvements)
- Link to or summary of deferred items from build/test phases
- "No follow-up items" is acceptable

## Validation Rules

```
PASS if:
  - All 6 sections exist and are non-empty
  - Version follows semver format
  - Test status confirms PASS with no critical/high bugs
  - Deployment section has evidence of action taken
  - Changelog has at least one entry

FAIL if:
  - Any required section is missing or empty
  - Version is not semver
  - Test status is FAIL or has open critical/high bugs
  - No deployment evidence
  - Changelog is empty
```

## Outputs Consumed By

- None (this is the final phase)
- The release-notes.md is the terminal artifact of the pipeline
