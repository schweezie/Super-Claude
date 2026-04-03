# /plan — PLAN Phase Entry Point

You are starting the **PLAN** phase of the pipeline. Your job is to generate a PRD from the idea brief.

## Entry Gate

**Required:** `.omc/artifacts/01-idea/idea-brief.md` must exist and be non-empty.

If the artifact is missing:
1. Tell the user: "The PLAN phase requires an idea brief. Run `/idea` first."
2. Offer to run `/idea` for them.
3. Do NOT proceed until the gate is satisfied or the user says "skip" or "override".

If the user overrides, log the skip in state and proceed with a warning.

## Phase Setup

1. **Load knowledge files:**
   - `knowledge/cs-fundamentals/system-design.md`
   - `knowledge/cs-fundamentals/design-patterns.md`
2. **Read input artifact:** `.omc/artifacts/01-idea/idea-brief.md`
3. **Update state:**
   ```json
   {
     "current_phase": "plan",
     "phase_status": "in_progress",
     "last_updated": "<now>"
   }
   ```

## Execution

Invoke the `planner` agent (Opus model) to run the `prd-generator` skill. The planner must:

1. **Parse the idea brief** — extract problem statement, target users, success criteria, constraints.
2. **Generate user stories** — at least 3, covering every persona from the idea brief. Format: "As a [persona], I want [action] so that [benefit]."
3. **Define acceptance criteria** — at least one per user story, using Given/When/Then or equivalent testable conditions.
4. **Break down tasks** — hierarchical list with size estimates (S/M/L). No task larger than L.
5. **Map dependencies** — identify prerequisites, external dependencies, critical path.
6. **Rank priorities** — P0 (must-have), P1 (should-have), P2 (nice-to-have). At least one P0.
7. **Define scope** — in-scope and out-of-scope items derived from the idea brief.

## Exit Gate

Validate the output against `pipeline/02-plan/output-spec.md`:

- All 7 required sections present and non-empty: Overview, User Stories, Acceptance Criteria, Task Breakdown, Dependencies, Priority Ranking, Scope & Non-Goals
- At least 3 user stories
- Every user story has >= 1 acceptance criterion
- Every user story covered by >= 1 task
- At least one P0 task
- All idea-brief personas represented

If validation fails, loop back to the planner for revisions.

## Output

Write the validated artifact to: `.omc/artifacts/02-plan/prd.md`

Update `.omc/state/pipeline-state.json` with `phases_completed` including "plan".

## Handoff

Tell the user: "PRD complete. Run `/architect` to design the system, or review the PRD at `.omc/artifacts/02-plan/prd.md`."

## User Input

$ARGUMENTS
