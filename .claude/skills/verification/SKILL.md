---
name: verification
description: Compiles test results into a formal test report, validates against output spec, and confirms release readiness. Use after tdd skill to complete the TEST phase.
level: 4
aliases: [verify, test-report, qa-report]
argument-hint: ""
agent: tester
model: sonnet
pipeline: [deep-interview, prd-generator, system-design, parallel-build, tdd, verification, git-workflow, release]
next-skill: git-workflow
handoff: .omc/artifacts/05-test/test-report.md
---

<Purpose>
Compile the output of the tdd skill (test files, results, coverage, bugs) into a formal test report that satisfies the TEST phase output spec. Verify that all acceptance criteria are covered, no critical bugs are open, and coverage meets the threshold.
</Purpose>

<Use_When>
- Called automatically after the tdd skill completes
- Test files exist and the test suite has been run
- The `/test` command invokes tdd then verification in sequence
</Use_When>

<Do_Not_Use_When>
- No tests have been written yet (run tdd first)
- User wants to write more tests before compiling the report
</Do_Not_Use_When>

<Steps>

## Step 1: Gather Test Results

1. Read test files in the project (find via glob patterns like `**/*.test.*`, `**/test_*.py`, etc.)
2. Run the full test suite one final time to get authoritative results
3. Run coverage tool to get authoritative coverage numbers
4. Read `.omc/artifacts/02-plan/prd.md` for the acceptance criteria list
5. Read `.omc/artifacts/04-build/build-report.md` for deferred items

## Step 2: Build Acceptance Criteria Coverage Table

Map every PRD acceptance criterion to its test(s):

| Acceptance Criterion | Test File | Test Name | Status |
|---------------------|-----------|-----------|--------|
| AC-1 | `test/auth.test.ts` | `should authenticate user` | covered-passing |
| AC-2 | `test/api.test.ts` | `should return 404` | covered-passing |
| AC-3 | — | — | not-covered (deferred) |

Rules:
- Every criterion must appear in the table
- Status: `covered-passing`, `covered-failing`, or `not-covered`
- `not-covered` must cross-reference build report deferred items

## Step 3: Compile Test Inventory

List all test files:

| Test File | What It Tests | Test Cases |
|-----------|--------------|------------|
| `test/auth.test.ts` | Authentication flows | 5 |
| `test/api.test.ts` | API endpoints | 8 |

Organize by component or test type (unit, integration, e2e).

## Step 4: Compile Coverage Report

- Coverage metric (line, branch, or statement) and percentage
- Threshold check: >= 60% → PASS, < 60% → needs justification
- List uncovered areas with brief justification

## Step 5: Compile Bug Report

From the tdd skill's findings:

| Bug ID | Severity | Description | Status |
|--------|----------|-------------|--------|
| BUG-1 | medium | Edge case in date parsing | fixed |
| BUG-2 | low | Missing validation message | deferred |

Verify: no critical or high severity bugs are open. If any are, this is a FAIL.

## Step 6: Record Execution Evidence

- Command(s) used to run tests
- Summary output from test runner (truncated if long)
- Timestamp of execution

## Step 7: Write Test Report

Assemble with these exact H2 sections:
- `## Test Summary` (total, pass, fail, skip, overall result)
- `## Acceptance Criteria Coverage` (the mapping table)
- `## Test Inventory` (all test files)
- `## Coverage Report` (percentage, threshold check)
- `## Bug Report` (bugs with severity and status)
- `## Deferred Test Items` (what wasn't tested and why)
- `## Test Execution Evidence` (commands, output, timestamp)

Write to `.omc/artifacts/05-test/test-report.md`. Update pipeline state.

</Steps>

<Tool_Usage>
- **Read**: Load test files, PRD, build report, existing test results
- **Bash**: Run test suite, run coverage tool
- **Glob/Grep**: Find test files, search for test patterns
- **Write**: Write the test report artifact
</Tool_Usage>

<Escalation_And_Stop_Conditions>
- **Stop if** no test files exist — run tdd skill first
- **Stop if** test suite cannot run (broken dependencies) — go back to build
- **Escalate if** critical/high bugs are open — cannot pass; ask user whether to fix or override
- **Escalate if** coverage is below 60% and cannot be improved — present justification, ask user to accept or request more tests
</Escalation_And_Stop_Conditions>

<Final_Checklist>
- [ ] All 7 H2 sections present and non-empty
- [ ] Every PRD acceptance criterion mapped to a test
- [ ] All mapped tests are passing (or failures documented <= medium)
- [ ] No critical/high severity bugs open
- [ ] Coverage >= 60% (or justified exception)
- [ ] Test execution evidence present with timestamp
- [ ] Deferred items cross-reference build report
- [ ] Artifact written to `.omc/artifacts/05-test/test-report.md`
- [ ] Pipeline state updated
</Final_Checklist>
