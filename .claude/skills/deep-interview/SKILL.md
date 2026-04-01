---
name: deep-interview
description: Socratic requirements interview that extracts problem, users, solution, success criteria, and constraints through structured questioning. Use when starting a new project or when idea clarity is insufficient.
level: 4
aliases: [interview, idea-interview, requirements-interview]
argument-hint: "[topic]"
agent: interviewer
model: opus
pipeline: [deep-interview, prd-generator, system-design, parallel-build, tdd, verification, git-workflow, release]
next-skill: prd-generator
handoff: .omc/artifacts/01-idea/idea-brief.md
---

<Purpose>
Extract a complete, unambiguous project vision from the user through Socratic questioning. Produce a structured idea brief that scores >= 3 on all clarity dimensions and satisfies the IDEA phase output spec.
</Purpose>

<Use_When>
- User says "I want to build...", "new project", "brainstorm", or "idea"
- The `/idea` command is invoked
- No `.omc/artifacts/01-idea/idea-brief.md` exists yet
- An existing idea brief has clarity scores < 3 and needs refinement
</Use_When>

<Do_Not_Use_When>
- A valid idea brief already exists with all clarity scores >= 3
- User is asking about an existing codebase, not a new project
- User has already provided a complete spec and wants to skip to planning
</Do_Not_Use_When>

<Steps>

## Step 1: Load Context

Read `.omc/state/pipeline-state.json` if it exists. If an idea brief already exists at `.omc/artifacts/01-idea/idea-brief.md`, read it and assess whether it needs refinement or is complete.

## Step 2: Open Exploration

Ask one broad question to understand the user's intent:

> "Tell me about the problem you want to solve. Who experiences it, and why do current solutions fall short?"

If `$ARGUMENTS` is provided, use it as the starting topic instead of asking cold.

## Step 3: Structured Deep Dive

Work through 5 dimensions, one at a time. For each, ask targeted follow-ups until clarity >= 3:

1. **Problem Statement** — Core problem, why it matters, who is affected
2. **Target Users** — Primary users, pain points, what success looks like
3. **Proposed Solution** — What to build, core capabilities (3+), explicit out-of-scope
4. **Success Criteria** — Measurable outcomes (at least 3), testable conditions
5. **Constraints** — Technical, time, regulatory, resource limitations

Rules:
- Ask 1-2 focused questions per turn, never a barrage
- Mirror back what you heard before moving to the next dimension
- Expose hidden assumptions — "fast compared to what?"
- Never fill gaps with your own assumptions

## Step 4: Score Clarity

Score each dimension 1-5:

| Dimension | 1 (Fail) | 3 (Pass) | 5 (Excellent) |
|-----------|----------|----------|---------------|
| Problem | Vague | Clear statement | Root cause + impact quantified |
| User | Unknown | Persona defined | Validated pain points + workflows |
| Scope | Unbounded | Core features listed | In/out scope + MVP defined |
| Success Criteria | None | 3+ testable criteria | Metrics + thresholds defined |

**All scores must be >= 3.** If any score < 3, loop back with targeted questions for that dimension.

## Step 5: Draft the Idea Brief

Assemble the structured brief with these exact H2 sections:
- `## Problem Statement`
- `## Target Users`
- `## Proposed Solution`
- `## Success Criteria`
- `## Constraints`
- `## Clarity Scores`
- `## User Confirmation`

Present the draft to the user for review.

## Step 6: Confirm and Write

After user approval:
1. Write the artifact to `.omc/artifacts/01-idea/idea-brief.md`
2. Update `.omc/state/pipeline-state.json` (current_phase: "idea", phase_status: "completed")
3. Announce: "Idea brief complete. Run `/plan` to generate the PRD."

</Steps>

<Tool_Usage>
- **Read**: Load existing state and artifacts
- **Glob**: Check if artifacts exist
- **AskUserQuestion**: NOT used — the interviewer agent conducts the conversation directly through turn-by-turn dialogue
- **Write**: Write the final idea-brief.md artifact (done by the invoking command, not the skill itself when agent is read-only)
</Tool_Usage>

<Escalation_And_Stop_Conditions>
- **Stop if** the user explicitly says they want to skip the interview
- **Stop if** the user provides a complete written spec and asks to jump to planning
- **Escalate if** clarity scores cannot reach >= 3 after 3 rounds of follow-up on the same dimension — present what you have and ask the user if they want to proceed anyway
- **Max turns:** 30 (if reached, present the best brief you have with current scores)
</Escalation_And_Stop_Conditions>

<Final_Checklist>
- [ ] All 7 H2 sections present and non-empty
- [ ] All clarity scores >= 3
- [ ] At least 3 success criteria listed
- [ ] At least 1 user persona defined
- [ ] User confirmation recorded with timestamp
- [ ] Artifact written to `.omc/artifacts/01-idea/idea-brief.md`
- [ ] Pipeline state updated
</Final_Checklist>
