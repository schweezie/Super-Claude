---
name: system-design
description: Designs system architecture from a PRD — tech stack, data model, API contracts, file structure, and risk analysis. Use after prd-generator or when designing a system.
level: 6
aliases: [architect, architecture, design-system]
argument-hint: "[prd-path]"
agent: architect
model: opus
pipeline: [deep-interview, prd-generator, system-design, parallel-build, tdd, verification, git-workflow, release]
next-skill: parallel-build
handoff: .omc/artifacts/03-architect/architecture.md
---

<Purpose>
Transform a PRD into a complete architecture document with tech stack decisions, system architecture, data model, API contracts, file structure, PRD coverage matrix, and risk analysis. This document becomes the blueprint the executor agent implements.
</Purpose>

<Use_When>
- The `/architect` command is invoked
- `.omc/artifacts/02-plan/prd.md` exists and is non-empty
- User says "architect", "design", "tech stack", "data model", or "system design"
- Transitioning from PLAN to ARCHITECT in the pipeline
</Use_When>

<Do_Not_Use_When>
- No PRD exists (run prd-generator first)
- A valid architecture document already exists and user hasn't requested a redesign
- User wants to skip design and go straight to coding
</Do_Not_Use_When>

<Steps>

## Step 1: Load Inputs

1. Read `.omc/artifacts/02-plan/prd.md` — extract user stories, acceptance criteria, task breakdown, dependencies
2. Load knowledge: `knowledge/cs-fundamentals/data-structures.md`, `knowledge/cs-fundamentals/algorithms.md`, `knowledge/cs-fundamentals/system-design.md`, `knowledge/cs-fundamentals/design-patterns.md`
3. Read `.omc/state/pipeline-state.json` if it exists

## Step 2: Choose Tech Stack

For each technology decision (language, framework, database, key libraries):

1. State the choice
2. Justify: why this over alternatives
3. Note tradeoffs: what you gain and what you sacrifice
4. Ensure choices align with PRD constraints and dependencies

Consider the PRD's task sizes and priorities — choose a stack proportionate to project complexity. Don't over-engineer a small project.

## Step 3: Design System Architecture

1. Define components and their responsibilities
2. Describe communication patterns (sync REST, async events, shared DB, etc.)
3. Specify deployment topology (monolith, services, serverless)
4. Create a component diagram (ASCII or Mermaid)

Each component should map to one or more PRD tasks.

## Step 4: Define Data Model

For every entity implied by PRD user stories:

1. Entity name
2. Fields with types
3. Relationships (1:1, 1:N, M:N)
4. Primary keys and notable indexes
5. Constraints (unique, not-null, foreign keys)

## Step 5: Specify API Contracts

For every action implied by PRD acceptance criteria:

1. Method + path (e.g., `POST /api/users`)
2. Request schema (body, params, headers)
3. Response schema (success + error)
4. Authentication/authorization requirements
5. Error response format

## Step 6: Plan File Structure

1. Define directory layout following framework conventions
2. List key files and their purposes
3. Map components to directories
4. Include config files, entry points, test directories

## Step 7: Build PRD Coverage Matrix

Create a table mapping every PRD task to its architectural component(s):

| PRD Task | Component(s) | Status |
|----------|-------------|--------|
| Task 1 | Component A, Component B | Covered |

Every task must appear. No orphans.

## Step 8: Identify Risks

List at least 1 technical risk (every architecture has risks):

For each risk:
- Description of the risk
- Likelihood (low/medium/high)
- Impact (low/medium/high)
- Mitigation strategy

## Step 9: Write Architecture Document

Assemble with these exact H2 sections:
- `## Tech Stack`
- `## System Architecture`
- `## Data Model`
- `## API Contracts`
- `## File Structure`
- `## PRD Coverage Matrix`
- `## Technical Risks & Mitigations`

Write to `.omc/artifacts/03-architect/architecture.md`. Update pipeline state.

</Steps>

<Tool_Usage>
- **Read**: Load PRD, state, knowledge files
- **Glob/Grep**: Check for existing artifacts, explore reference repos if templates exist
- **Write**: Write the architecture artifact (done by invoking command when agent is read-only)
</Tool_Usage>

<Escalation_And_Stop_Conditions>
- **Stop if** PRD doesn't exist — direct user to run `/plan` first
- **Stop if** PRD has orphan tasks with no acceptance criteria — suggest fixing PRD first
- **Escalate if** tech stack choice has significant cost implications (paid APIs, cloud services) — confirm with user
- **Escalate if** PRD scope implies architecture beyond a single developer's capacity — suggest scoping down or phasing
</Escalation_And_Stop_Conditions>

<Final_Checklist>
- [ ] All 7 H2 sections present and non-empty
- [ ] Tech stack has justification for each choice
- [ ] Data model covers all entities from PRD user stories
- [ ] API contracts cover all actions from PRD acceptance criteria
- [ ] File structure follows chosen framework conventions
- [ ] PRD coverage matrix includes every PRD task (no orphans)
- [ ] At least 1 technical risk with mitigation
- [ ] Artifact written to `.omc/artifacts/03-architect/architecture.md`
- [ ] Pipeline state updated
</Final_Checklist>
