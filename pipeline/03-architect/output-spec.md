# Architect Phase — Output Spec

> **Critic agent:** Validate the architecture artifact against this spec before allowing phase transition.

## Artifact

- **Path:** `.omc/artifacts/03-architect/architecture.md`
- **Format:** Markdown with required H2 sections

## Required Inputs

- `.omc/artifacts/02-plan/prd.md` must exist and be non-empty

## Required Sections

The artifact MUST contain all of the following H2 sections, each non-empty:

### 1. `## Tech Stack`
- Language(s) and runtime(s) with version constraints
- Framework(s) with justification
- Database/storage choice with justification
- Key libraries/dependencies
- Each choice includes a tradeoff note (why this over alternatives)

### 2. `## System Architecture`
- High-level component diagram (ASCII, Mermaid, or description)
- Component responsibilities (one paragraph each)
- Communication patterns between components (sync/async, protocol)
- Deployment topology (monolith, microservices, serverless, etc.)

### 3. `## Data Model`
- Entity definitions with fields and types
- Relationships between entities (1:1, 1:N, M:N)
- Primary keys and indexes noted
- At minimum, covers all entities implied by PRD user stories

### 4. `## API Contracts`
- Endpoint definitions: method, path, request/response schema
- Authentication/authorization approach
- Error response format
- At minimum, covers all actions implied by PRD acceptance criteria

### 5. `## File Structure`
- Planned directory layout for the project
- Key files and their purposes
- Follows conventions of the chosen framework

### 6. `## PRD Coverage Matrix`
- Table mapping each PRD task to the architectural component(s) that implement it
- Every PRD task must appear in the matrix
- No orphaned tasks (tasks with no architectural home)

### 7. `## Technical Risks & Mitigations`
- At least 1 identified risk
- Each risk has a mitigation strategy
- "None identified" is NOT acceptable — every architecture has risks

## Validation Rules

```
PASS if:
  - All 7 sections exist and are non-empty
  - Tech stack has justification for each choice
  - Data model covers entities from PRD user stories
  - API contracts cover actions from PRD acceptance criteria
  - PRD coverage matrix includes every task from prd.md
  - At least 1 technical risk identified with mitigation

FAIL if:
  - Any required section is missing or empty
  - Tech stack lacks justification
  - Data model missing entities implied by user stories
  - API contracts missing actions implied by acceptance criteria
  - PRD coverage matrix has orphaned tasks
  - No technical risks identified
```

## Outputs Consumed By

- **BUILD phase** reads `architecture.md` to implement the system
- Build phase expects: tech stack, file structure, data model, API contracts, and coverage matrix
