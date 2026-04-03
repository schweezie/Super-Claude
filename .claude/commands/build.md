# /build — BUILD Phase Entry Point

You are starting the **BUILD** phase of the pipeline. Your job is to implement the system from the architecture design.

## Entry Gate

**Required:** `.omc/artifacts/03-architect/architecture.md` must exist and be non-empty.

If the artifact is missing:
1. Tell the user: "The BUILD phase requires an architecture document. Run `/architect` first."
2. Offer to run `/architect` for them.
3. Do NOT proceed until the gate is satisfied or the user says "skip" or "override".

If the user overrides, log the skip in state and proceed with a warning.

## Phase Setup

1. **Load knowledge files:**
   - `knowledge/claude-code-patterns/agent-design.md`
   - `knowledge/claude-code-patterns/context-management.md`
   - `knowledge/claude-code-patterns/team-coordination.md`
2. **Read input artifact:** `.omc/artifacts/03-architect/architecture.md`
3. **Update state:**
   ```json
   {
     "current_phase": "build",
     "phase_status": "in_progress",
     "last_updated": "<now>"
   }
   ```

## Execution

Invoke the `executor` agent (Sonnet model) to run the `parallel-build` skill. The executor must:

1. **Parse the architecture** — extract tech stack, file structure, data model, API contracts, coverage matrix.
2. **Decompose into work units** — identify independent components that can be built in parallel vs. sequential dependencies.
3. **Set up project scaffold** — initialize project with chosen framework, install dependencies, create directory structure per file structure plan.
4. **Implement components** — build each component per the architecture spec. Use Agent Teams for parallel independent components.
5. **Run build verification** — confirm code compiles/runs, dependencies resolve, no errors.
6. **Invoke reviewer** — the `reviewer` agent (Opus model, read-only) reviews the implementation against the architecture. If changes are requested, the executor addresses them.
7. **Track deferred items** — any architecture components not implemented must be documented with justification.

## Exit Gate

Validate the output against `pipeline/04-build/output-spec.md`:

- All 7 required sections in build-report.md: Implementation Summary, Component Status, File Manifest, Build Verification, Review Status, Deferred Items, Architecture Coverage
- Build verification confirms code compiles/runs
- Review status is "approved" or justified exemption
- Architecture coverage has no unaccounted components
- Deferred items (if any) are justified

If validation fails, loop back to the executor for fixes.

## Output

Write the validated artifact to: `.omc/artifacts/04-build/build-report.md`

Update `.omc/state/pipeline-state.json` with `phases_completed` including "build".

## Handoff

Tell the user: "Build complete. Run `/test` to verify, or review the build report at `.omc/artifacts/04-build/build-report.md`."

## User Input

$ARGUMENTS
