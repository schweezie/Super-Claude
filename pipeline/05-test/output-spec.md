# Test Phase — Output Spec

> **Critic agent:** Validate the test report artifact against this spec before allowing phase transition.

## Artifact

- **Path:** `.omc/artifacts/05-test/test-report.md`
- **Format:** Markdown with required H2 sections

## Required Inputs

- `.omc/artifacts/04-build/build-report.md` must exist and be non-empty
- `.omc/artifacts/02-plan/prd.md` must exist (for acceptance criteria cross-reference)

## Required Sections

The test report MUST contain all of the following H2 sections, each non-empty:

### 1. `## Test Summary`
- Total tests written and executed
- Pass/fail/skip counts
- Overall test result: PASS or FAIL

### 2. `## Acceptance Criteria Coverage`
- Table mapping each PRD acceptance criterion to its test(s)
- Every acceptance criterion from `prd.md` must have at least one test
- Status per criterion: covered-passing, covered-failing, or not-covered

### 3. `## Test Inventory`
- List of all test files created
- Each test file: path, what it tests, number of test cases
- Organized by component or test type (unit, integration, e2e)

### 4. `## Coverage Report`
- Code coverage percentage (line, branch, or statement — at least one metric)
- Coverage threshold: ≥ 60% for passing (configurable per project)
- Uncovered areas identified with justification

### 5. `## Bug Report`
- Bugs discovered during testing
- Each bug: severity (critical/high/medium/low), description, status (fixed/open/deferred)
- No critical or high severity bugs may be open
- "No bugs found" is acceptable

### 6. `## Deferred Test Items`
- Components or criteria not tested and why
- Must cross-reference build-report deferred items
- Impact assessment for untested areas

### 7. `## Test Execution Evidence`
- Command(s) used to run tests
- Summary output from test runner
- Timestamp of test execution

## Validation Rules

```
PASS if:
  - All 7 sections exist and are non-empty
  - Every PRD acceptance criterion has ≥ 1 test mapped to it
  - All mapped tests are passing (or failures are documented as known issues ≤ medium severity)
  - No critical or high severity bugs are open
  - Coverage meets threshold (≥ 60%)
  - Test execution evidence is present

FAIL if:
  - Any required section is missing or empty
  - Any PRD acceptance criterion has no test
  - Critical or high severity bugs are open
  - Coverage below threshold without justification
  - No test execution evidence
```

## Outputs Consumed By

- **SHIP phase** reads `test-report.md` to confirm release readiness
- Ship phase expects: overall test result, bug report status, coverage percentage, and acceptance criteria coverage
