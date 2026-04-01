# /architect — ARCHITECT Phase Entry Point

You are starting the **ARCHITECT** phase of the pipeline. Your job is to design the system architecture from the PRD.

## Entry Gate

**Required:** `.omc/artifacts/02-plan/prd.md` must exist and be non-empty.

If the artifact is missing:
1. Tell the user: "The ARCHITECT phase requires a PRD. Run `/plan` first."
2. Offer to run `/plan` for them.
3. Do NOT proceed until the gate is satisfied or the user says "skip" or "override".

If the user overrides, log the skip in state and proceed with a warning.

## Phase Setup

1. **Load knowledge files:**
   - `knowledge/cs-fundamentals/data-structures.md`
   - `knowledge/cs-fundamentals/algorithms.md`
   - `knowledge/cs-fundamentals/system-design.md`
   - `knowledge/cs-fundamentals/design-patterns.md`
2. **Read input artifact:** `.omc/artifacts/02-plan/prd.md`
3. **Update state:**
   ```json
   {
     "current_phase": "architect",
     "phase_status": "in_progress",
     "last_updated": "<now>"
   }
   ```

## Execution

Invoke the `architect` agent (Opus model) to run the `system-design` skill. The architect must:

1. **Choose tech stack** — language, framework, database, key libraries. Each choice must include justification and tradeoff notes.
2. **Design system architecture** — component diagram, responsibilities, communication patterns, deployment topology.
3. **Define data model** — entities, fields, types, relationships. Must cover all entities implied by PRD user stories.
4. **Specify API contracts** — endpoints, methods, request/response schemas, auth approach, error format. Must cover all actions from PRD acceptance criteria.
5. **Plan file structure** — directory layout, key files, following framework conventions.
6. **Build PRD coverage matrix** — map every PRD task to architectural component(s). No orphans allowed.
7. **Identify technical risks** — at least 1 risk with mitigation strategy.

## Exit Gate

Validate the output against `pipeline/03-architect/output-spec.md`:

- All 7 required sections present and non-empty: Tech Stack, System Architecture, Data Model, API Contracts, File Structure, PRD Coverage Matrix, Technical Risks & Mitigations
- Tech stack has justification for each choice
- Data model covers entities from PRD user stories
- API contracts cover actions from PRD acceptance criteria
- Coverage matrix includes every PRD task
- At least 1 technical risk with mitigation

If validation fails, loop back to the architect for revisions.

## Output

Write the validated artifact to: `.omc/artifacts/03-architect/architecture.md`

Update `.omc/state/pipeline-state.json` with `phases_completed` including "architect".

## Handoff

Tell the user: "Architecture complete. Run `/build` to implement, or review the design at `.omc/artifacts/03-architect/architecture.md`."

## User Input

$ARGUMENTS
