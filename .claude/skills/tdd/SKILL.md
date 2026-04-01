---
name: tdd
description: Test-driven development skill that writes tests against PRD acceptance criteria and build report components. Ensures coverage, catches bugs, and produces a structured test inventory. Use for the TEST phase.
level: 5
aliases: [test, write-tests, test-driven]
argument-hint: "[component]"
agent: tester
model: sonnet
pipeline: [deep-interview, prd-generator, system-design, parallel-build, tdd, verification, git-workflow, release]
next-skill: verification
handoff: test files in project repository
---

<Purpose>
Write and execute tests that verify the built code satisfies PRD acceptance criteria. Map every acceptance criterion to at least one test. Discover bugs, measure coverage, and produce a test inventory that the verification skill uses to compile the final test report.
</Purpose>

<Use_When>
- The `/test` command is invoked
- `.omc/artifacts/04-build/build-report.md` exists and is non-empty
- User says "test", "QA", "coverage", "write tests"
- Transitioning from BUILD to TEST in the pipeline
</Use_When>

<Do_Not_Use_When>
- No build report exists (run parallel-build first)
- User wants to test a single function in isolation (just write the test directly)
- User is doing exploratory testing without the pipeline
</Do_Not_Use_When>

<Steps>

## Step 1: Load Inputs

1. Read `.omc/artifacts/04-build/build-report.md` — extract file manifest, component status, deferred items
2. Read `.omc/artifacts/02-plan/prd.md` — extract acceptance criteria (the test targets)
3. Read `.omc/artifacts/03-architect/architecture.md` — extract tech stack (to choose test framework)
4. Read `.omc/state/pipeline-state.json` if it exists

## Step 2: Choose Test Framework

Based on the tech stack from the architecture:

| Stack | Test Framework | Runner |
|-------|---------------|--------|
| Node/TypeScript | Jest or Vitest | `npm test` |
| Python | pytest | `pytest` |
| Rust | built-in | `cargo test` |
| Go | built-in | `go test ./...` |
| Other | Framework-appropriate | As specified |

Install test dependencies if not already present.

## Step 3: Map Acceptance Criteria to Tests

Create a coverage map:

| PRD Acceptance Criterion | Test File | Test Name | Type |
|-------------------------|-----------|-----------|------|
| AC-1: Given X, When Y, Then Z | `test/auth.test.ts` | `should Z when Y` | unit |

Rules:
- Every acceptance criterion from the PRD must have at least 1 test
- Prefer unit tests for logic, integration tests for API/DB, e2e for workflows
- Skip components marked as "deferred" in the build report (note in deferred test items)

## Step 4: Write Tests (Test-First Where Possible)

For each acceptance criterion:

1. Write the test that verifies the criterion
2. Run the test — if it passes, good; if it fails, investigate
3. If the failure is a bug in the implementation, document it
4. If the failure is in the test, fix the test

Organize tests by component, mirroring the project's file structure.

## Step 5: Run Full Test Suite

1. Execute all tests with the chosen runner
2. Record: total, passed, failed, skipped
3. Capture test runner output as evidence
4. If any test fails: investigate, categorize as bug or test issue

## Step 6: Measure Coverage

1. Run coverage tool (e.g., `--coverage` flag, `pytest-cov`, `cargo tarpaulin`)
2. Record coverage percentage (line, branch, or statement)
3. Threshold: >= 60% to pass
4. Identify uncovered areas and justify why they're uncovered

## Step 7: Document Bugs

For each bug discovered:
- Severity: critical / high / medium / low
- Description: what's wrong
- Status: fixed / open / deferred
- Fix critical and high bugs before proceeding
- Medium and low can be deferred with justification

## Step 8: Hand Off to Verification

The tdd skill writes test files and produces a working test suite. The verification skill reads the results and compiles the formal test report. Pass forward:
- List of test files created
- Test run results (pass/fail counts)
- Coverage percentage
- Bug list with severities

</Steps>

<Tool_Usage>
- **Read**: Load build report, PRD, architecture, existing code
- **Write**: Create test files
- **Edit**: Fix tests or implementation bugs found during testing
- **Bash**: Run test suite, install test dependencies, run coverage tools
- **Glob/Grep**: Find source files to test, locate existing tests
</Tool_Usage>

<Escalation_And_Stop_Conditions>
- **Stop if** build report doesn't exist — direct user to run `/build` first
- **Stop if** project doesn't compile — cannot test broken code, go back to build
- **Escalate if** critical bug found that requires architecture change — present to user
- **Escalate if** coverage cannot reach 60% due to untestable code — explain and ask user to accept or refactor
- **Escalate if** test framework setup fails repeatedly — ask user for guidance on test tooling
</Escalation_And_Stop_Conditions>

<Final_Checklist>
- [ ] Every PRD acceptance criterion has >= 1 test
- [ ] All tests pass (or failures documented as bugs)
- [ ] No critical or high severity bugs open
- [ ] Coverage >= 60% (or justified exception)
- [ ] Test files organized by component
- [ ] Test runner output captured
- [ ] Bug list documented with severities
- [ ] Ready for verification skill to compile test report
</Final_Checklist>
