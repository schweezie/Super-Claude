# /test — TEST Phase Entry Point

You are starting the **TEST** phase of the pipeline. Your job is to write and run tests, then produce a test report.

## Entry Gate

**Required:** `.omc/artifacts/04-build/build-report.md` must exist and be non-empty.

If the artifact is missing:
1. Tell the user: "The TEST phase requires a build report. Run `/build` first."
2. Offer to run `/build` for them.
3. Do NOT proceed until the gate is satisfied or the user says "skip" or "override".

If the user overrides, log the skip in state and proceed with a warning.

## Phase Setup

1. **Load knowledge files:**
   - `knowledge/cs-fundamentals/algorithms.md`
   - `knowledge/claude-code-patterns/prompt-patterns.md`
2. **Read input artifacts:**
   - `.omc/artifacts/04-build/build-report.md` (primary — file manifest, component status)
   - `.omc/artifacts/02-plan/prd.md` (secondary — acceptance criteria for coverage mapping)
3. **Update state:**
   ```json
   {
     "current_phase": "test",
     "phase_status": "in_progress",
     "last_updated": "<now>"
   }
   ```

## Execution

Invoke the `tester` agent (Sonnet model) to run the `tdd` and `verification` skills. The tester must:

1. **Plan test strategy** — determine test types needed (unit, integration, e2e) based on the build report's component list.
2. **Map acceptance criteria** — create a matrix linking every PRD acceptance criterion to planned test(s). Every criterion must have at least one test.
3. **Write tests** — create test files organized by component or test type. Follow the project's testing framework conventions.
4. **Run tests** — execute the full test suite. Capture pass/fail/skip counts and output.
5. **Measure coverage** — generate code coverage report. Target >= 60% (line, branch, or statement).
6. **Document bugs** — any failures are logged with severity (critical/high/medium/low). Critical and high bugs must be fixed or escalated.
7. **Track deferred test items** — components not tested must be documented with justification, cross-referencing build report deferred items.

## Exit Gate

Validate the output against `pipeline/05-test/output-spec.md`:

- All 7 required sections: Test Summary, Acceptance Criteria Coverage, Test Inventory, Coverage Report, Bug Report, Deferred Test Items, Test Execution Evidence
- Every PRD acceptance criterion has >= 1 test
- All mapped tests passing (or failures documented as <= medium severity)
- No critical/high severity bugs open
- Coverage >= 60%
- Test execution evidence present

If validation fails, loop back to the tester for fixes.

## Output

Write the validated artifact to: `.omc/artifacts/05-test/test-report.md`

Update `.omc/state/pipeline-state.json` with `phases_completed` including "test".

## Handoff

Tell the user: "Testing complete. Run `/ship` to release, or review the test report at `.omc/artifacts/05-test/test-report.md`."

## User Input

$ARGUMENTS
