# /idea — IDEA Phase Entry Point

You are starting the **IDEA** phase of the pipeline. Your job is to interview the user and produce a structured idea brief.

## Entry Gate

None — this is the first phase. Always allowed.

## Phase Setup

1. **Check for existing state.** Read `.omc/state/pipeline-state.json` if it exists. If an idea phase was already completed, ask the user if they want to start fresh or resume.
2. **No knowledge files to load** for this phase (IDEA captures the human's vision).
3. **Initialize state.** Create or update `.omc/state/pipeline-state.json`:
   ```json
   {
     "current_phase": "idea",
     "phase_status": "in_progress",
     "phases_completed": [],
     "phases_skipped": [],
     "started_at": "<now>",
     "last_updated": "<now>",
     "project_name": "TBD"
   }
   ```

## Execution

Invoke the `interviewer` agent (Opus model) to run the `deep-interview` skill. The interviewer must:

1. **Run Socratic questioning** to extract from the user:
   - What problem are they solving?
   - Who are the target users?
   - What does the solution look like at a high level?
   - What are the success criteria?
   - What are the constraints (technical, time, regulatory)?
2. **Score clarity** on 4 dimensions (1-5 scale): problem, user, scope, success criteria.
3. **Loop if any score < 3** — ask targeted follow-up questions to raise clarity.
4. **Get user confirmation** — present the draft brief and ask the user to approve.

## Exit Gate

Validate the output against `pipeline/01-idea/output-spec.md`:

- All 7 required sections present and non-empty: Problem Statement, Target Users, Proposed Solution, Success Criteria, Constraints, Clarity Scores, User Confirmation
- All clarity scores >= 3
- At least 3 success criteria
- At least 1 user persona
- User confirmation recorded

If validation fails, loop back to the interviewer for revisions. If the user says "override" or "skip validation", allow it with a warning logged to state.

## Output

Write the validated artifact to: `.omc/artifacts/01-idea/idea-brief.md`

Update `.omc/state/pipeline-state.json`:
```json
{
  "current_phase": "idea",
  "phase_status": "complete",
  "phases_completed": ["idea"],
  "last_updated": "<now>",
  "project_name": "<extracted from interview>"
}
```

## Handoff

Tell the user: "Idea brief complete. Run `/plan` to generate the PRD, or review the brief at `.omc/artifacts/01-idea/idea-brief.md`."

## User Input

$ARGUMENTS
