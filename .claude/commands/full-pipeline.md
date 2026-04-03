# /full-pipeline — End-to-End Pipeline Execution

You are running the **full pipeline** from IDEA through SHIP. This chains all 6 phases sequentially with gate enforcement between each.

## Pipeline Sequence

```
/idea → /plan → /architect → /build → /test → /ship
```

## Resumption Detection

Before starting, check for existing progress:

1. Read `.omc/state/pipeline-state.json` if it exists.
2. Check which phases have completed artifacts:
   - `.omc/artifacts/01-idea/idea-brief.md`
   - `.omc/artifacts/02-plan/prd.md`
   - `.omc/artifacts/03-architect/architecture.md`
   - `.omc/artifacts/04-build/build-report.md`
   - `.omc/artifacts/05-test/test-report.md`
   - `.omc/artifacts/06-ship/release-notes.md`
3. If completed artifacts exist, ask the user:
   - "I found existing artifacts for [phases]. Do you want to resume from [next phase] or start fresh?"
4. If starting fresh, warn that existing artifacts will be overwritten.

## Execution Protocol

For each phase in sequence:

### 1. IDEA Phase
- No entry gate — always starts.
- Run the `/idea` command logic (invoke `interviewer` agent with `deep-interview` skill).
- Validate against `pipeline/01-idea/output-spec.md`.
- Write `.omc/artifacts/01-idea/idea-brief.md`.
- **Context management:** After completing IDEA, consider context usage. If above 40%, summarize key outputs before proceeding.

### 2. PLAN Phase
- Entry gate: `idea-brief.md` exists.
- Load knowledge: `system-design.md`, `design-patterns.md`.
- Run the `/plan` command logic (invoke `planner` agent with `prd-generator` skill).
- Validate against `pipeline/02-plan/output-spec.md`.
- Write `.omc/artifacts/02-plan/prd.md`.

### 3. ARCHITECT Phase
- Entry gate: `prd.md` exists.
- Load knowledge: `data-structures.md`, `algorithms.md`, `system-design.md`, `design-patterns.md`.
- Run the `/architect` command logic (invoke `architect` agent with `system-design` skill).
- Validate against `pipeline/03-architect/output-spec.md`.
- Write `.omc/artifacts/03-architect/architecture.md`.
- **Context management:** After ARCHITECT, context is likely high. Use `/clear` or compact before BUILD if above 50%.

### 4. BUILD Phase
- Entry gate: `architecture.md` exists.
- Load knowledge: `agent-design.md`, `context-management.md`, `team-coordination.md`.
- Run the `/build` command logic (invoke `executor` agent with `parallel-build` skill, `reviewer` for quality gate).
- Validate against `pipeline/04-build/output-spec.md`.
- Write `.omc/artifacts/04-build/build-report.md`.

### 5. TEST Phase
- Entry gate: `build-report.md` exists.
- Load knowledge: `algorithms.md`, `prompt-patterns.md`.
- Run the `/test` command logic (invoke `tester` agent with `tdd` + `verification` skills).
- Validate against `pipeline/05-test/output-spec.md`.
- Write `.omc/artifacts/05-test/test-report.md`.

### 6. SHIP Phase
- Entry gate: `test-report.md` exists.
- Load knowledge: `hook-patterns.md`.
- Run the `/ship` command logic (invoke `release-manager` agent with `git-workflow` + `release` skills).
- Validate against `pipeline/06-ship/output-spec.md`.
- Write `.omc/artifacts/06-ship/release-notes.md`.

## State Tracking

Update `.omc/state/pipeline-state.json` after each phase completes. The state file tracks overall pipeline progress and allows resumption if the session is interrupted.

## Error Handling

- If any phase fails validation, retry that phase (up to 2 retries).
- If a phase fails after retries, ask the user: "Phase [X] failed validation. Override and continue, or stop here?"
- If the user stops, update state to reflect partial completion.
- If context runs low during the pipeline, save state and tell the user to run `/clear` then resume with `/full-pipeline`.

## Completion

When all 6 phases complete:

1. Update state to show full pipeline complete.
2. Print a summary:
   ```
   Pipeline Complete!
   - Idea Brief: .omc/artifacts/01-idea/idea-brief.md
   - PRD: .omc/artifacts/02-plan/prd.md
   - Architecture: .omc/artifacts/03-architect/architecture.md
   - Build Report: .omc/artifacts/04-build/build-report.md
   - Test Report: .omc/artifacts/05-test/test-report.md
   - Release Notes: .omc/artifacts/06-ship/release-notes.md
   ```
3. Suggest next steps: "Your project has shipped! Review the release notes or start a new project with `/idea`."

## User Input

$ARGUMENTS
