# /ship — SHIP Phase Entry Point

You are starting the **SHIP** phase of the pipeline. Your job is to release the project and produce release notes.

## Entry Gate

**Required:** `.omc/artifacts/05-test/test-report.md` must exist and be non-empty.

If the artifact is missing:
1. Tell the user: "The SHIP phase requires a test report. Run `/test` first."
2. Offer to run `/test` for them.
3. Do NOT proceed until the gate is satisfied or the user says "skip" or "override".

If the user overrides, log the skip in state and proceed with a warning.

## Phase Setup

1. **Load knowledge files:**
   - `knowledge/claude-code-patterns/hook-patterns.md`
2. **Read input artifact:** `.omc/artifacts/05-test/test-report.md`
3. **Also read** (for context):
   - `.omc/artifacts/04-build/build-report.md` (deferred items, file manifest)
   - `.omc/artifacts/01-idea/idea-brief.md` (project name for release)
4. **Update state:**
   ```json
   {
     "current_phase": "ship",
     "phase_status": "in_progress",
     "last_updated": "<now>"
   }
   ```

## Execution

Invoke the `release-manager` agent (Sonnet model) to run the `git-workflow` and `release` skills. The release manager must:

1. **Verify release readiness** — confirm test report shows PASS, no critical/high bugs open, coverage meets threshold.
2. **Determine version** — choose semver version (MAJOR.MINOR.PATCH) based on the nature of changes. Ask the user if uncertain.
3. **Generate changelog** — categorize changes as Added, Changed, Fixed, Removed based on build report and git history.
4. **Execute release action** — one of:
   - Create a git tag
   - Create a release PR
   - Publish a package
   - Deploy to an environment
   - Manual release documentation
5. **Document known issues** — carry forward open medium/low bugs and deferred items from build/test phases.
6. **Suggest follow-ups** — list deferred features and improvements for future work.

## Exit Gate

Validate the output against `pipeline/06-ship/output-spec.md`:

- All 6 required sections: Release Info, Changelog, Test Status, Deployment, Known Issues, What's Next
- Version follows semver
- Test status confirms PASS with no critical/high bugs
- Deployment section has evidence of action taken
- Changelog has at least one entry

If validation fails, loop back to the release manager for fixes.

## Output

Write the validated artifact to: `.omc/artifacts/06-ship/release-notes.md`

Update `.omc/state/pipeline-state.json`:
```json
{
  "current_phase": "ship",
  "phase_status": "complete",
  "phases_completed": ["idea", "plan", "architect", "build", "test", "ship"],
  "last_updated": "<now>"
}
```

## Handoff

Tell the user: "Release complete! The full pipeline is done. Review release notes at `.omc/artifacts/06-ship/release-notes.md`."

## User Input

$ARGUMENTS
