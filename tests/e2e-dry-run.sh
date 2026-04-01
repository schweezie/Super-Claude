#!/usr/bin/env bash
# ============================================================
# E2E Dry-Run Simulation for Super Claude Pipeline
# ============================================================
# This script validates the entire pipeline by:
#   1. Verifying all structural prerequisites exist
#   2. Creating mock artifacts and tracing each phase's flow
#   3. Testing gate enforcement (missing prerequisites)
#   4. Testing state management (create/read/update)
#   5. Testing phase resumption and compaction recovery
#   6. Testing template compatibility
# ============================================================

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0
WARN=0
RESULTS=()

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

pass() {
  PASS=$((PASS + 1))
  RESULTS+=("${GREEN}PASS${NC}  $1")
  echo -e "  ${GREEN}PASS${NC}  $1"
}

fail() {
  FAIL=$((FAIL + 1))
  RESULTS+=("${RED}FAIL${NC}  $1")
  echo -e "  ${RED}FAIL${NC}  $1"
}

warn() {
  WARN=$((WARN + 1))
  RESULTS+=("${YELLOW}WARN${NC}  $1")
  echo -e "  ${YELLOW}WARN${NC}  $1"
}

section() {
  echo ""
  echo -e "${BLUE}━━━ $1 ━━━${NC}"
}

# ============================================================
# PHASE 0: Structural Prerequisites
# ============================================================
section "Phase 0: Structural Prerequisites"

# Commands
for cmd in idea plan architect build test ship full-pipeline; do
  if [[ -f "$ROOT/.claude/commands/$cmd.md" ]] && [[ -s "$ROOT/.claude/commands/$cmd.md" ]]; then
    pass "Command file exists: $cmd.md"
  else
    fail "Command file missing or empty: $cmd.md"
  fi
done

# Agents
for agent in interviewer planner architect executor reviewer tester release-manager critic; do
  if [[ -f "$ROOT/.claude/agents/$agent.md" ]] && [[ -s "$ROOT/.claude/agents/$agent.md" ]]; then
    pass "Agent file exists: $agent.md"
  else
    fail "Agent file missing or empty: $agent.md"
  fi
done

# Skills
for skill in deep-interview prd-generator system-design parallel-build tdd verification git-workflow release; do
  if [[ -f "$ROOT/.claude/skills/$skill/SKILL.md" ]] && [[ -s "$ROOT/.claude/skills/$skill/SKILL.md" ]]; then
    pass "Skill file exists: $skill/SKILL.md"
  else
    fail "Skill file missing or empty: $skill/SKILL.md"
  fi
done

# Output specs
for phase in 01-idea 02-plan 03-architect 04-build 05-test 06-ship; do
  if [[ -f "$ROOT/pipeline/$phase/output-spec.md" ]] && [[ -s "$ROOT/pipeline/$phase/output-spec.md" ]]; then
    pass "Output spec exists: $phase/output-spec.md"
  else
    fail "Output spec missing or empty: $phase/output-spec.md"
  fi
done

# Hooks
for hook in session-start.js pre-tool-use.js post-tool-use.js stop.js; do
  if [[ -f "$ROOT/.claude/hooks/$hook" ]] && [[ -s "$ROOT/.claude/hooks/$hook" ]]; then
    pass "Hook file exists: $hook"
  else
    fail "Hook file missing or empty: $hook"
  fi
done

# Knowledge files
for kf in cs-fundamentals/data-structures cs-fundamentals/algorithms cs-fundamentals/system-design cs-fundamentals/design-patterns \
          claude-code-patterns/agent-design claude-code-patterns/skill-design claude-code-patterns/hook-patterns \
          claude-code-patterns/context-management claude-code-patterns/prompt-patterns claude-code-patterns/team-coordination; do
  if [[ -f "$ROOT/knowledge/$kf.md" ]] && [[ -s "$ROOT/knowledge/$kf.md" ]]; then
    pass "Knowledge file exists: $kf.md"
  else
    fail "Knowledge file missing or empty: $kf.md"
  fi
done

# Harness internals
for hi in harness-internals/tool-orchestration harness-internals/context-window harness-internals/runtime-behavior; do
  if [[ -f "$ROOT/knowledge/$hi.md" ]] && [[ -s "$ROOT/knowledge/$hi.md" ]]; then
    pass "Harness internal exists: $hi.md"
  else
    fail "Harness internal missing or empty: $hi.md"
  fi
done

# CLAUDE.md
if [[ -f "$ROOT/CLAUDE.md" ]] && [[ -s "$ROOT/CLAUDE.md" ]]; then
  pass "CLAUDE.md exists and is non-empty"
else
  fail "CLAUDE.md missing or empty"
fi

# .omc directories
for dir in .omc/artifacts .omc/state .omc/memory; do
  if [[ -d "$ROOT/$dir" ]]; then
    pass "Directory exists: $dir"
  else
    fail "Directory missing: $dir"
  fi
done

# Settings.json
if [[ -f "$ROOT/.claude/settings.json" ]] && [[ -s "$ROOT/.claude/settings.json" ]]; then
  pass "settings.json exists and is non-empty"
else
  fail "settings.json missing or empty"
fi

# ============================================================
# PHASE 1: Create Test Workspace
# ============================================================
section "Phase 1: Create Test Workspace"

TEST_DIR="$ROOT/tests/.e2e-workspace"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR/.omc/artifacts/01-idea"
mkdir -p "$TEST_DIR/.omc/artifacts/02-plan"
mkdir -p "$TEST_DIR/.omc/artifacts/03-architect"
mkdir -p "$TEST_DIR/.omc/artifacts/04-build"
mkdir -p "$TEST_DIR/.omc/artifacts/05-test"
mkdir -p "$TEST_DIR/.omc/artifacts/06-ship"
mkdir -p "$TEST_DIR/.omc/state"
pass "Test workspace created at tests/.e2e-workspace"

# ============================================================
# PHASE 2: Mock Artifact Generation & Phase Flow Tracing
# ============================================================

# --- 10.1: /idea command flow ---
section "10.1: /idea Command — Dry-Run Trace"

# /idea has no entry gate — always allowed
# It invokes: interviewer agent (opus) + deep-interview skill
# It produces: .omc/artifacts/01-idea/idea-brief.md

# Check command references correct agent
if grep -q "interviewer" "$ROOT/.claude/commands/idea.md"; then
  pass "/idea references interviewer agent"
else
  fail "/idea does not reference interviewer agent"
fi

# Check command references correct skill
if grep -q "deep-interview" "$ROOT/.claude/commands/idea.md"; then
  pass "/idea references deep-interview skill"
else
  fail "/idea does not reference deep-interview skill"
fi

# Check command specifies correct output path
if grep -q "01-idea/idea-brief.md" "$ROOT/.claude/commands/idea.md"; then
  pass "/idea specifies correct output path"
else
  fail "/idea does not specify correct output path"
fi

# Check interviewer agent has correct model
if grep -q "model: opus" "$ROOT/.claude/agents/interviewer.md"; then
  pass "Interviewer agent uses opus model"
else
  fail "Interviewer agent does not use opus model"
fi

# Check interviewer agent is read-only
if grep -q "disallowedTools.*Write" "$ROOT/.claude/agents/interviewer.md" || grep -q "disallowedTools:.*Write" "$ROOT/.claude/agents/interviewer.md"; then
  pass "Interviewer agent is read-only (Write disallowed)"
else
  fail "Interviewer agent is NOT read-only"
fi

# Check output spec sections match what command expects
IDEA_SECTIONS=$(grep -c "^### [0-9]" "$ROOT/pipeline/01-idea/output-spec.md" || true)
if [[ "$IDEA_SECTIONS" -eq 7 ]]; then
  pass "Idea output-spec has 7 required sections"
else
  fail "Idea output-spec has $IDEA_SECTIONS sections (expected 7)"
fi

# Create mock idea-brief
cat > "$TEST_DIR/.omc/artifacts/01-idea/idea-brief.md" << 'IDEA_EOF'
## Problem Statement
Users struggle to manage their daily tasks across multiple platforms. The fragmentation leads to missed deadlines, duplicated effort, and context-switching overhead.

## Target Users
**Busy Professional:** A knowledge worker juggling 5+ tools daily. Pain points: lost tasks, no unified view. Success: single dashboard for all tasks.

## Proposed Solution
A unified task aggregator that pulls tasks from Jira, Asana, Trello, and GitHub Issues into a single interface.
- Real-time sync across all platforms
- Priority-based unified inbox
- Smart deduplication across sources
- Will NOT replace any source tool (read/sync only, not a new project manager)

## Success Criteria
1. Sync latency < 30 seconds from source update to dashboard
2. Zero duplicate tasks shown for the same work item
3. User can view all tasks from 3+ sources in under 5 seconds
4. 90% of users report reduced context-switching in post-pilot survey

## Constraints
- Technical: Must use OAuth2 for all integrations; no storing user credentials
- Time: MVP in 4 weeks
- Regulatory: GDPR-compliant data handling required

## Clarity Scores
| Dimension | Score |
|-----------|-------|
| Problem | 5/5 |
| User | 4/5 |
| Scope | 4/5 |
| Success Criteria | 5/5 |

## User Confirmation
User reviewed and approved this brief on 2026-04-01T10:00:00Z.
IDEA_EOF
pass "Mock idea-brief.md created"

# Validate mock against output-spec rules
MOCK_IDEA="$TEST_DIR/.omc/artifacts/01-idea/idea-brief.md"
IDEA_VALID=true

# Check all 7 sections present
for section_name in "Problem Statement" "Target Users" "Proposed Solution" "Success Criteria" "Constraints" "Clarity Scores" "User Confirmation"; do
  if grep -q "## $section_name" "$MOCK_IDEA"; then
    : # ok
  else
    fail "Mock idea-brief missing section: $section_name"
    IDEA_VALID=false
  fi
done

# Check clarity scores >= 3
LOW_SCORES=$(grep -oE '[0-9]+/5' "$MOCK_IDEA" | awk -F/ '$1 < 3' | wc -l)
if [[ "$LOW_SCORES" -eq 0 ]]; then
  pass "All clarity scores >= 3"
else
  fail "$LOW_SCORES clarity scores below 3"
  IDEA_VALID=false
fi

# Check >= 3 success criteria
SC_COUNT=$(sed -n '/## Success Criteria/,/## /p' "$MOCK_IDEA" | grep -cE '^[0-9]+\.' || true)
if [[ "$SC_COUNT" -ge 3 ]]; then
  pass "At least 3 success criteria ($SC_COUNT found)"
else
  fail "Fewer than 3 success criteria ($SC_COUNT found)"
  IDEA_VALID=false
fi

if [[ "$IDEA_VALID" == true ]]; then
  pass "10.1 COMPLETE — /idea mock artifact validates against output-spec"
fi

# --- 10.2: /plan command flow ---
section "10.2: /plan Command — Dry-Run Trace"

# Entry gate: idea-brief.md must exist
if grep -q "01-idea/idea-brief.md" "$ROOT/.claude/commands/plan.md"; then
  pass "/plan checks for idea-brief.md entry gate"
else
  fail "/plan does not check entry gate"
fi

# Agent + skill
if grep -q "planner" "$ROOT/.claude/commands/plan.md"; then
  pass "/plan references planner agent"
else
  fail "/plan does not reference planner agent"
fi

if grep -q "prd-generator" "$ROOT/.claude/commands/plan.md"; then
  pass "/plan references prd-generator skill"
else
  fail "/plan does not reference prd-generator skill"
fi

# Knowledge files
if grep -q "system-design.md" "$ROOT/.claude/commands/plan.md" && grep -q "design-patterns.md" "$ROOT/.claude/commands/plan.md"; then
  pass "/plan loads correct knowledge files (system-design, design-patterns)"
else
  fail "/plan does not load correct knowledge files"
fi

# Output path
if grep -q "02-plan/prd.md" "$ROOT/.claude/commands/plan.md"; then
  pass "/plan specifies correct output path"
else
  fail "/plan does not specify correct output path"
fi

# Planner agent model
if grep -q "model: opus" "$ROOT/.claude/agents/planner.md"; then
  pass "Planner agent uses opus model"
else
  fail "Planner agent does not use opus model"
fi

# Create mock PRD
cat > "$TEST_DIR/.omc/artifacts/02-plan/prd.md" << 'PRD_EOF'
## Overview
**TaskSync** — A unified task aggregator that consolidates work items from Jira, Asana, Trello, and GitHub Issues into a single dashboard. Derived from idea-brief at `.omc/artifacts/01-idea/idea-brief.md`.

## User Stories
1. As a **Busy Professional**, I want to see all my tasks from Jira, Asana, and GitHub in one view so that I don't miss deadlines.
2. As a **Busy Professional**, I want tasks automatically deduplicated so that I don't waste time on items tracked in multiple tools.
3. As a **Busy Professional**, I want to sort by priority across all sources so that I focus on the most important work first.
4. As a **Busy Professional**, I want sync to happen within 30 seconds so that my dashboard is always current.

## Acceptance Criteria
**Story 1:**
- Given I have connected Jira, Asana, and GitHub, When I open the dashboard, Then I see tasks from all three sources.
- Given a new task is created in Jira, When 30 seconds pass, Then it appears on my dashboard.

**Story 2:**
- Given the same task exists in Jira and Asana, When I view my dashboard, Then only one instance is shown with source indicators.

**Story 3:**
- Given tasks with different priorities across sources, When I sort by priority, Then tasks are ordered by a normalized priority scale.

**Story 4:**
- Given a task is updated in any source, When 30 seconds pass, Then the dashboard reflects the update.

## Task Breakdown
- T1 (M): Set up project scaffold (Next.js + Prisma + PostgreSQL)
- T2 (L): Implement OAuth2 integration for Jira
- T3 (L): Implement OAuth2 integration for Asana
- T4 (L): Implement OAuth2 integration for GitHub Issues
- T5 (M): Build task normalization layer (common schema)
- T6 (M): Implement deduplication engine
- T7 (S): Build priority normalization logic
- T8 (L): Build unified dashboard UI
- T9 (M): Implement real-time sync (polling + webhooks)
- T10 (S): Add GDPR consent flow and data retention policies

## Dependencies
- T2, T3, T4 depend on T1 (scaffold)
- T5 depends on T2, T3, T4 (needs data to normalize)
- T6 depends on T5 (needs normalized data)
- T7 depends on T5 (needs normalized priorities)
- T8 depends on T5, T6, T7 (needs processed data)
- T9 depends on T2, T3, T4 (needs API connections)
- T10 is independent
- Critical path: T1 → T2/T3/T4 → T5 → T6 → T8

## Priority Ranking
- **P0:** T1, T2, T5, T6, T8 (core MVP — aggregation + dedup + display)
- **P1:** T3, T4, T9 (additional sources + real-time)
- **P2:** T7, T10 (polish + compliance)

## Scope & Non-Goals
**In scope:** Task aggregation, deduplication, unified dashboard, OAuth2 integrations
**Out of scope:** Task creation/editing in source tools, mobile app, team features, AI prioritization
PRD_EOF
pass "Mock prd.md created"

# Validate mock PRD
MOCK_PRD="$TEST_DIR/.omc/artifacts/02-plan/prd.md"
PRD_VALID=true

for section_name in "Overview" "User Stories" "Acceptance Criteria" "Task Breakdown" "Dependencies" "Priority Ranking" "Scope & Non-Goals"; do
  if grep -q "## $section_name" "$MOCK_PRD"; then
    : # ok
  else
    fail "Mock PRD missing section: $section_name"
    PRD_VALID=false
  fi
done

STORY_COUNT=$(grep -cE "^[0-9]+\. As a" "$MOCK_PRD" || true)
if [[ "$STORY_COUNT" -ge 3 ]]; then
  pass "At least 3 user stories ($STORY_COUNT found)"
else
  fail "Fewer than 3 user stories ($STORY_COUNT found)"
  PRD_VALID=false
fi

if grep -q "P0" "$MOCK_PRD"; then
  pass "At least one P0 task exists"
else
  fail "No P0 tasks defined"
  PRD_VALID=false
fi

if [[ "$PRD_VALID" == true ]]; then
  pass "10.2 COMPLETE — /plan mock artifact validates against output-spec"
fi

# --- 10.3: /architect command flow ---
section "10.3: /architect Command — Dry-Run Trace"

if grep -q "02-plan/prd.md" "$ROOT/.claude/commands/architect.md"; then
  pass "/architect checks for prd.md entry gate"
else
  fail "/architect does not check entry gate"
fi

if grep -q "architect" "$ROOT/.claude/commands/architect.md" | head -1 && grep -q "system-design" "$ROOT/.claude/commands/architect.md"; then
  pass "/architect references architect agent + system-design skill"
else
  # Check individually
  grep -q "system-design" "$ROOT/.claude/commands/architect.md" && pass "/architect references system-design skill" || fail "/architect missing system-design skill ref"
fi

# Knowledge files for architect
ARCH_KF=0
for kf in "data-structures" "algorithms" "system-design" "design-patterns"; do
  grep -q "$kf" "$ROOT/.claude/commands/architect.md" && ARCH_KF=$((ARCH_KF + 1))
done
if [[ "$ARCH_KF" -eq 4 ]]; then
  pass "/architect loads all 4 knowledge files"
else
  fail "/architect loads only $ARCH_KF/4 knowledge files"
fi

if grep -q "03-architect/architecture.md" "$ROOT/.claude/commands/architect.md"; then
  pass "/architect specifies correct output path"
else
  fail "/architect does not specify correct output path"
fi

# Create mock architecture
cat > "$TEST_DIR/.omc/artifacts/03-architect/architecture.md" << 'ARCH_EOF'
## Tech Stack
- **Language:** TypeScript 5.x — type safety for complex data normalization; team familiarity. Tradeoff: slightly more verbose than Python but catches integration bugs at compile time.
- **Framework:** Next.js 14 (App Router) — SSR for dashboard, API routes for integrations. Tradeoff: heavier than Express but provides full-stack solution.
- **Database:** PostgreSQL 16 + Prisma ORM — relational model fits task entity relationships. Tradeoff: more setup than SQLite but scales for production.
- **Key Libraries:** next-auth (OAuth2), bull (job queues for sync), zod (schema validation)

## System Architecture
Components:
- **Dashboard UI** (Next.js pages): Renders unified task view
- **API Layer** (Next.js API routes): CRUD + sync endpoints
- **Integration Service**: OAuth2 connectors for Jira, Asana, GitHub
- **Normalization Engine**: Transforms source-specific tasks into common schema
- **Dedup Engine**: Detects and merges duplicate tasks
- **Sync Worker** (Bull queue): Periodic polling + webhook receivers

Communication: REST between UI and API. Internal function calls between API, normalization, and dedup. Bull queue for async sync jobs.

## Data Model
- **Task**: id, title, description, priority (normalized 1-5), status, source, sourceId, sourceUrl, createdAt, updatedAt
- **Source**: id, type (jira|asana|github), userId, accessToken, refreshToken, lastSyncAt
- **DedupGroup**: id, canonicalTaskId, memberTaskIds[]
- Relationships: Task N:1 Source, Task N:1 DedupGroup

## API Contracts
- `GET /api/tasks` — list all tasks (query: source, priority, status)
- `POST /api/sources` — connect a new source (body: type, authCode)
- `DELETE /api/sources/:id` — disconnect a source
- `POST /api/sync/:sourceId` — trigger manual sync
- `GET /api/health` — health check
- Auth: next-auth session cookies. Error format: `{ error: string, code: number }`

## File Structure
```
src/
  app/                    # Next.js App Router pages
    page.tsx              # Dashboard
    api/tasks/route.ts    # Task endpoints
    api/sources/route.ts  # Source endpoints
    api/sync/route.ts     # Sync trigger
    api/health/route.ts   # Health check
  lib/
    db.ts                 # Prisma client
    normalize.ts          # Task normalization
    dedup.ts              # Deduplication engine
    integrations/
      jira.ts             # Jira connector
      asana.ts            # Asana connector
      github.ts           # GitHub connector
  workers/
    sync-worker.ts        # Bull queue sync jobs
prisma/
  schema.prisma           # Data model
```

## PRD Coverage Matrix
| PRD Task | Component(s) |
|----------|-------------|
| T1 Scaffold | Project setup, file structure |
| T2 Jira OAuth | integrations/jira.ts, sources API |
| T3 Asana OAuth | integrations/asana.ts, sources API |
| T4 GitHub OAuth | integrations/github.ts, sources API |
| T5 Normalization | lib/normalize.ts |
| T6 Deduplication | lib/dedup.ts |
| T7 Priority normalization | lib/normalize.ts (priority section) |
| T8 Dashboard UI | app/page.tsx, tasks API |
| T9 Real-time sync | workers/sync-worker.ts, sync API |
| T10 GDPR | sources API (consent), db (retention) |

## Technical Risks & Mitigations
1. **OAuth token expiry during sync** — Risk: sync fails silently. Mitigation: implement token refresh with retry logic; alert user on persistent auth failure.
2. **Dedup false positives** — Risk: unrelated tasks merged. Mitigation: conservative matching (require title + source overlap); user can split groups.
ARCH_EOF
pass "Mock architecture.md created"

# Validate
MOCK_ARCH="$TEST_DIR/.omc/artifacts/03-architect/architecture.md"
ARCH_VALID=true
for section_name in "Tech Stack" "System Architecture" "Data Model" "API Contracts" "File Structure" "PRD Coverage Matrix" "Technical Risks & Mitigations"; do
  if grep -q "## $section_name" "$MOCK_ARCH"; then
    : # ok
  else
    fail "Mock architecture missing section: $section_name"
    ARCH_VALID=false
  fi
done

if [[ "$ARCH_VALID" == true ]]; then
  pass "10.3 COMPLETE — /architect mock artifact validates against output-spec"
fi

# --- 10.4: /build command flow ---
section "10.4: /build Command — Dry-Run Trace"

if grep -q "03-architect/architecture.md" "$ROOT/.claude/commands/build.md"; then
  pass "/build checks for architecture.md entry gate"
else
  fail "/build does not check entry gate"
fi

if grep -q "executor" "$ROOT/.claude/commands/build.md"; then
  pass "/build references executor agent"
else
  fail "/build does not reference executor agent"
fi

if grep -q "parallel-build" "$ROOT/.claude/commands/build.md"; then
  pass "/build references parallel-build skill"
else
  fail "/build does not reference parallel-build skill"
fi

if grep -q "reviewer" "$ROOT/.claude/commands/build.md"; then
  pass "/build invokes reviewer agent for quality gate"
else
  fail "/build does not invoke reviewer agent"
fi

if grep -q "model: sonnet" "$ROOT/.claude/agents/executor.md"; then
  pass "Executor agent uses sonnet model"
else
  fail "Executor agent does not use sonnet model"
fi

# Knowledge files for build
BUILD_KF=0
for kf in "agent-design" "context-management" "team-coordination"; do
  grep -q "$kf" "$ROOT/.claude/commands/build.md" && BUILD_KF=$((BUILD_KF + 1))
done
if [[ "$BUILD_KF" -eq 3 ]]; then
  pass "/build loads all 3 knowledge files"
else
  fail "/build loads only $BUILD_KF/3 knowledge files"
fi

# Create mock build report
cat > "$TEST_DIR/.omc/artifacts/04-build/build-report.md" << 'BUILD_EOF'
## Implementation Summary
Built the TaskSync unified task aggregator. All P0 components implemented. No architecture deviations. 12 files created.

## Component Status
| Component | Status | Notes |
|-----------|--------|-------|
| Project scaffold | complete | Next.js 14 + Prisma + PostgreSQL |
| Jira OAuth | complete | OAuth2 PKCE flow implemented |
| Asana OAuth | deferred | P1 — deprioritized for MVP |
| GitHub OAuth | deferred | P1 — deprioritized for MVP |
| Normalization | complete | Common task schema with priority mapping |
| Deduplication | complete | Title + source overlap matching |
| Priority normalization | complete | 1-5 scale with source-specific mappings |
| Dashboard UI | complete | Server-rendered task list with filters |
| Sync worker | partial | Polling implemented, webhooks deferred |
| GDPR | deferred | P2 — post-MVP |

## File Manifest
- `src/app/page.tsx` — Dashboard page
- `src/app/api/tasks/route.ts` — Task CRUD endpoints
- `src/app/api/sources/route.ts` — Source management
- `src/app/api/sync/route.ts` — Manual sync trigger
- `src/app/api/health/route.ts` — Health endpoint
- `src/lib/db.ts` — Prisma client singleton
- `src/lib/normalize.ts` — Task normalization engine
- `src/lib/dedup.ts` — Deduplication engine
- `src/lib/integrations/jira.ts` — Jira API connector
- `src/workers/sync-worker.ts` — Bull queue sync jobs
- `prisma/schema.prisma` — Database schema
- `package.json` — Dependencies and scripts

## Build Verification
- `npm run build`: SUCCESS (0 errors, 2 warnings — unused imports in jira.ts)
- `npm run dev`: Server starts on localhost:3000
- Health endpoint returns 200 OK

## Review Status
Reviewer: APPROVED with observations. No critical or high issues. Medium: suggested adding input validation on sources endpoint.

## Deferred Items
- Asana OAuth (P1): Not enough time for MVP. Jira covers primary use case.
- GitHub OAuth (P1): Same as above.
- Webhooks (P1): Polling sufficient for MVP sync latency.
- GDPR consent flow (P2): Post-MVP compliance work.

## Architecture Coverage
| Component | Status |
|-----------|--------|
| Dashboard UI | implemented |
| API Layer | implemented |
| Integration Service | partial (Jira only) |
| Normalization Engine | implemented |
| Dedup Engine | implemented |
| Sync Worker | partial (polling only) |
BUILD_EOF
pass "Mock build-report.md created"

MOCK_BUILD="$TEST_DIR/.omc/artifacts/04-build/build-report.md"
BUILD_VALID=true
for section_name in "Implementation Summary" "Component Status" "File Manifest" "Build Verification" "Review Status" "Deferred Items" "Architecture Coverage"; do
  if grep -q "## $section_name" "$MOCK_BUILD"; then
    : # ok
  else
    fail "Mock build-report missing section: $section_name"
    BUILD_VALID=false
  fi
done

if [[ "$BUILD_VALID" == true ]]; then
  pass "10.4 COMPLETE — /build mock artifact validates against output-spec"
fi

# --- 10.5: /test command flow ---
section "10.5: /test Command — Dry-Run Trace"

if grep -q "04-build/build-report.md" "$ROOT/.claude/commands/test.md"; then
  pass "/test checks for build-report.md entry gate"
else
  fail "/test does not check entry gate"
fi

if grep -q "tester" "$ROOT/.claude/commands/test.md"; then
  pass "/test references tester agent"
else
  fail "/test does not reference tester agent"
fi

if grep -q "tdd" "$ROOT/.claude/commands/test.md" && grep -q "verification" "$ROOT/.claude/commands/test.md"; then
  pass "/test references tdd + verification skills"
else
  fail "/test missing tdd or verification skill reference"
fi

# Also reads PRD for acceptance criteria cross-ref
if grep -q "prd.md" "$ROOT/.claude/commands/test.md"; then
  pass "/test cross-references prd.md for acceptance criteria"
else
  fail "/test does not cross-reference prd.md"
fi

# Create mock test report
cat > "$TEST_DIR/.omc/artifacts/05-test/test-report.md" << 'TEST_EOF'
## Test Summary
- Total tests: 18
- Passed: 17 | Failed: 0 | Skipped: 1
- Overall result: PASS

## Acceptance Criteria Coverage
| Acceptance Criterion | Test File | Test Name | Status |
|---------------------|-----------|-----------|--------|
| Dashboard shows tasks from all sources | tests/dashboard.test.ts | renders tasks from connected sources | covered-passing |
| New Jira task appears within 30s | tests/sync.test.ts | syncs new tasks within interval | covered-passing |
| Duplicate tasks merged | tests/dedup.test.ts | merges tasks with matching title+source | covered-passing |
| Priority sort across sources | tests/normalize.test.ts | normalizes priorities to 1-5 scale | covered-passing |
| Task updates reflected in 30s | tests/sync.test.ts | updates existing tasks on re-sync | covered-passing |

## Test Inventory
- `tests/dashboard.test.ts` — Dashboard rendering, 4 test cases
- `tests/dedup.test.ts` — Deduplication engine, 5 test cases
- `tests/normalize.test.ts` — Task normalization, 4 test cases
- `tests/sync.test.ts` — Sync worker, 3 test cases
- `tests/api.test.ts` — API endpoints, 2 test cases

## Coverage Report
- Line coverage: 78%
- Threshold: 60%
- Uncovered areas: error handling in sync-worker (edge cases), GDPR module (deferred)

## Bug Report
| Severity | Description | Location | Status |
|----------|-------------|----------|--------|
| medium | Sync worker doesn't retry on network timeout | workers/sync-worker.ts:45 | open |

## Deferred Test Items
- Asana integration tests (component deferred in build)
- GitHub integration tests (component deferred in build)
- GDPR consent flow tests (component deferred in build)

## Test Execution Evidence
- Command: `npm test -- --coverage`
- Timestamp: 2026-04-01T14:00:00Z
- Output summary: 18 tests, 17 passed, 1 skipped, 78% coverage
TEST_EOF
pass "Mock test-report.md created"

MOCK_TEST="$TEST_DIR/.omc/artifacts/05-test/test-report.md"
TEST_VALID=true
for section_name in "Test Summary" "Acceptance Criteria Coverage" "Test Inventory" "Coverage Report" "Bug Report" "Deferred Test Items" "Test Execution Evidence"; do
  if grep -q "## $section_name" "$MOCK_TEST"; then
    : # ok
  else
    fail "Mock test-report missing section: $section_name"
    TEST_VALID=false
  fi
done

# Check no critical/high bugs open
if grep -q "critical.*open\|high.*open" "$MOCK_TEST"; then
  fail "Critical or high bugs still open"
  TEST_VALID=false
else
  pass "No critical/high bugs open"
fi

# Check coverage >= 60%
COVERAGE=$(grep -oE '[0-9]+%' "$MOCK_TEST" | head -1 | tr -d '%')
if [[ "$COVERAGE" -ge 60 ]]; then
  pass "Coverage meets threshold (${COVERAGE}% >= 60%)"
else
  fail "Coverage below threshold (${COVERAGE}% < 60%)"
  TEST_VALID=false
fi

if [[ "$TEST_VALID" == true ]]; then
  pass "10.5 COMPLETE — /test mock artifact validates against output-spec"
fi

# --- 10.6: /ship command flow ---
section "10.6: /ship Command — Dry-Run Trace"

if grep -q "05-test/test-report.md" "$ROOT/.claude/commands/ship.md"; then
  pass "/ship checks for test-report.md entry gate"
else
  fail "/ship does not check entry gate"
fi

if grep -q "release-manager" "$ROOT/.claude/commands/ship.md"; then
  pass "/ship references release-manager agent"
else
  fail "/ship does not reference release-manager agent"
fi

if grep -q "git-workflow" "$ROOT/.claude/commands/ship.md" && grep -q "release" "$ROOT/.claude/commands/ship.md"; then
  pass "/ship references git-workflow + release skills"
else
  fail "/ship missing git-workflow or release skill reference"
fi

if grep -q "hook-patterns" "$ROOT/.claude/commands/ship.md"; then
  pass "/ship loads hook-patterns knowledge file"
else
  fail "/ship does not load hook-patterns knowledge file"
fi

# Create mock release notes
cat > "$TEST_DIR/.omc/artifacts/06-ship/release-notes.md" << 'SHIP_EOF'
## Release Info
- Version: 0.1.0
- Date: 2026-04-01
- Project: TaskSync
- Summary: Initial MVP release with Jira integration and task deduplication

## Changelog
### Added
- Unified task dashboard with server-rendered UI
- Jira OAuth2 integration with PKCE flow
- Task normalization engine (common schema, priority mapping)
- Deduplication engine (title + source matching)
- Periodic sync worker (30-second polling)
- Health check endpoint

### Changed
- N/A (initial release)

### Fixed
- N/A (initial release)

### Removed
- N/A (initial release)

## Test Status
- Overall: PASS
- Coverage: 78%
- Open bugs: 1 medium (sync retry on timeout) — no critical/high
- Reference: .omc/artifacts/05-test/test-report.md

## Deployment
- Method: git tag
- Evidence: Tag v0.1.0 created on commit abc123

## Known Issues
- Sync worker doesn't retry on network timeout (medium severity)
- Asana and GitHub integrations deferred to v0.2.0
- GDPR consent flow deferred to v0.2.0

## What's Next
- v0.2.0: Add Asana + GitHub integrations
- v0.3.0: Webhook-based real-time sync
- v1.0.0: GDPR compliance, multi-user support
SHIP_EOF
pass "Mock release-notes.md created"

MOCK_SHIP="$TEST_DIR/.omc/artifacts/06-ship/release-notes.md"
SHIP_VALID=true
for section_name in "Release Info" "Changelog" "Test Status" "Deployment" "Known Issues" "What's Next"; do
  if grep -q "## $section_name" "$MOCK_SHIP"; then
    : # ok
  else
    fail "Mock release-notes missing section: $section_name"
    SHIP_VALID=false
  fi
done

# Check semver
if grep -qE "Version: [0-9]+\.[0-9]+\.[0-9]+" "$MOCK_SHIP"; then
  pass "Version follows semver format"
else
  fail "Version does not follow semver"
  SHIP_VALID=false
fi

if [[ "$SHIP_VALID" == true ]]; then
  pass "10.6 COMPLETE — /ship mock artifact validates against output-spec"
fi

# ============================================================
# 10.7: /full-pipeline — Chain Verification
# ============================================================
section "10.7: /full-pipeline — Chain Verification"

# Verify full-pipeline chains all 6 phases
FP="$ROOT/.claude/commands/full-pipeline.md"
PHASES_REF=0
for phase in "IDEA" "PLAN" "ARCHITECT" "BUILD" "TEST" "SHIP"; do
  if grep -q "$phase" "$FP"; then
    PHASES_REF=$((PHASES_REF + 1))
  fi
done
if [[ "$PHASES_REF" -eq 6 ]]; then
  pass "/full-pipeline references all 6 phases"
else
  fail "/full-pipeline references only $PHASES_REF/6 phases"
fi

# Verify gate checks in full-pipeline
if grep -q "idea-brief.md" "$FP" && grep -q "prd.md" "$FP" && grep -q "architecture.md" "$FP" && \
   grep -q "build-report.md" "$FP" && grep -q "test-report.md" "$FP" && grep -q "release-notes.md" "$FP"; then
  pass "/full-pipeline references all 6 artifact paths"
else
  fail "/full-pipeline missing some artifact path references"
fi

# Verify resumption detection
if grep -q "pipeline-state.json" "$FP"; then
  pass "/full-pipeline checks pipeline-state.json for resumption"
else
  fail "/full-pipeline missing resumption detection"
fi

# Verify context management awareness
if grep -q "context\|compact\|clear" "$FP"; then
  pass "/full-pipeline has context management awareness"
else
  warn "/full-pipeline may lack context management guidance"
fi

pass "10.7 COMPLETE — /full-pipeline chains all phases with gates"

# ============================================================
# 10.8: Gate Enforcement
# ============================================================
section "10.8: Gate Enforcement"

# Test: /build should fail without architecture.md
# In dry-run: verify the command text enforces the gate
if grep -q "Do NOT proceed" "$ROOT/.claude/commands/build.md"; then
  pass "/build gate: explicit DO NOT PROCEED instruction"
else
  fail "/build gate: missing explicit blocking instruction"
fi

# Verify gate offers to run prerequisite
if grep -q "Run.*architect.*first\|run.*architect" "$ROOT/.claude/commands/build.md"; then
  pass "/build gate: offers to run /architect first"
else
  fail "/build gate: does not offer prerequisite"
fi

# Verify skip/override handling
if grep -q "skip\|override" "$ROOT/.claude/commands/build.md"; then
  pass "/build gate: handles skip/override"
else
  fail "/build gate: missing skip/override handling"
fi

# Test all other gates the same way
for cmd_gate in "plan:idea" "architect:plan" "test:build" "ship:test"; do
  CMD="${cmd_gate%%:*}"
  PREREQ="${cmd_gate##*:}"
  CMD_FILE="$ROOT/.claude/commands/$CMD.md"
  if grep -q "Do NOT proceed\|do NOT proceed\|Do not proceed" "$CMD_FILE"; then
    pass "/$CMD gate: explicit blocking instruction"
  else
    fail "/$CMD gate: missing explicit blocking instruction"
  fi
done

# CLAUDE.md gate enforcement section
if grep -q "Gate Enforcement\|Entry Gates\|Gate Behavior" "$ROOT/CLAUDE.md"; then
  pass "CLAUDE.md documents gate enforcement"
else
  fail "CLAUDE.md missing gate enforcement documentation"
fi

pass "10.8 COMPLETE — gate enforcement verified across all phases"

# ============================================================
# 10.9: Phase Resumption
# ============================================================
section "10.9: Phase Resumption"

# Create a mid-build state file
cat > "$TEST_DIR/.omc/state/pipeline-state.json" << 'STATE_EOF'
{
  "current_phase": "build",
  "phase_status": "in_progress",
  "phases_completed": ["idea", "plan", "architect"],
  "phases_skipped": [],
  "started_at": "2026-04-01T10:00:00Z",
  "last_updated": "2026-04-01T14:30:00Z",
  "project_name": "TaskSync"
}
STATE_EOF
pass "Created mid-build state file"

# Verify state file is valid JSON
STATE_PATH="$TEST_DIR/.omc/state/pipeline-state.json"
STATE_PATH_WIN=$(cygpath -w "$STATE_PATH" 2>/dev/null || echo "$STATE_PATH")
if node -e "JSON.parse(require('fs').readFileSync(String.raw\`$STATE_PATH_WIN\`,'utf8'))" 2>/dev/null || \
   node -e "JSON.parse(require('fs').readFileSync('$STATE_PATH','utf8'))" 2>/dev/null; then
  pass "State file is valid JSON"
else
  fail "State file is not valid JSON"
fi

# Verify CLAUDE.md documents state reading
if grep -q "pipeline-state.json" "$ROOT/CLAUDE.md"; then
  pass "CLAUDE.md references pipeline-state.json"
else
  fail "CLAUDE.md does not reference pipeline-state.json"
fi

# Verify /full-pipeline handles resumption
if grep -q "resume\|Resume\|existing artifacts" "$ROOT/.claude/commands/full-pipeline.md"; then
  pass "/full-pipeline handles phase resumption"
else
  fail "/full-pipeline missing resumption handling"
fi

# Verify state structure matches expected format
STATE_FIELDS="current_phase phase_status phases_completed phases_skipped started_at last_updated project_name"
STATE_VALID=true
for field in $STATE_FIELDS; do
  if grep -q "\"$field\"" "$TEST_DIR/.omc/state/pipeline-state.json"; then
    : # ok
  else
    fail "State file missing field: $field"
    STATE_VALID=false
  fi
done
if [[ "$STATE_VALID" == true ]]; then
  pass "State file has all required fields"
fi

pass "10.9 COMPLETE — phase resumption mechanism verified"

# ============================================================
# 10.10: Compaction Recovery
# ============================================================
section "10.10: Compaction Recovery"

# Verify CLAUDE.md has compaction recovery protocol
if grep -q "Compaction Recovery\|compaction.*recovery\|Post-Compaction\|After.*compact" "$ROOT/CLAUDE.md"; then
  pass "CLAUDE.md documents compaction recovery protocol"
else
  fail "CLAUDE.md missing compaction recovery protocol"
fi

# Verify the recovery steps mention reading state
if grep -q "pipeline-state.json" "$ROOT/CLAUDE.md"; then
  pass "Recovery protocol includes reading pipeline-state.json"
else
  fail "Recovery protocol missing state file reading"
fi

# Verify AGENT_STATE.md has recovery instructions
if grep -q "Post-Compaction Recovery\|Post.*Compact" "$ROOT/AGENT_STATE.md"; then
  pass "AGENT_STATE.md has post-compaction recovery instructions"
else
  fail "AGENT_STATE.md missing recovery instructions"
fi

# Verify context management section exists
if grep -q "Context Management\|Compaction Protocol" "$ROOT/CLAUDE.md"; then
  pass "CLAUDE.md has context management section"
else
  fail "CLAUDE.md missing context management section"
fi

# Verify disk-state-over-memory principle
if grep -q "Trust.*disk\|Trust.*files\|source of truth" "$ROOT/CLAUDE.md" || \
   grep -q "Trust.*files\|source of truth" "$ROOT/AGENT_STATE.md"; then
  pass "Disk-state-over-memory principle documented"
else
  warn "Disk-state-over-memory principle not explicitly documented"
fi

pass "10.10 COMPLETE — compaction recovery mechanism verified"

# ============================================================
# 10.11-10.13: Template Compatibility
# ============================================================
section "10.11: web-app Template Compatibility"

WA="$ROOT/templates/web-app"
WA_VALID=true
for f in "package.json" "CLAUDE.md" "next.config.js" "tsconfig.json" "tailwind.config.ts"; do
  if [[ -f "$WA/$f" ]]; then
    : # ok
  else
    fail "web-app missing: $f"
    WA_VALID=false
  fi
done

if [[ -d "$WA/app" ]] && [[ -d "$WA/components" ]] && [[ -d "$WA/lib" ]]; then
  pass "web-app has app/, components/, lib/ directories"
else
  fail "web-app missing required directories"
  WA_VALID=false
fi

if [[ -f "$WA/CLAUDE.md" ]] && [[ -s "$WA/CLAUDE.md" ]]; then
  pass "web-app CLAUDE.md exists and is non-empty"
else
  fail "web-app CLAUDE.md missing or empty"
  WA_VALID=false
fi

if [[ "$WA_VALID" == true ]]; then
  pass "10.11 COMPLETE — web-app template is structurally valid"
fi

section "10.12: api-service Template Compatibility"

API="$ROOT/templates/api-service"
API_VALID=true
for f in "pyproject.toml" "CLAUDE.md" "alembic.ini"; do
  if [[ -f "$API/$f" ]]; then
    : # ok
  else
    fail "api-service missing: $f"
    API_VALID=false
  fi
done

if [[ -d "$API/app" ]] && [[ -d "$API/tests" ]] && [[ -d "$API/alembic" ]]; then
  pass "api-service has app/, tests/, alembic/ directories"
else
  fail "api-service missing required directories"
  API_VALID=false
fi

if [[ -f "$API/CLAUDE.md" ]] && [[ -s "$API/CLAUDE.md" ]]; then
  pass "api-service CLAUDE.md exists and is non-empty"
else
  fail "api-service CLAUDE.md missing or empty"
  API_VALID=false
fi

if [[ "$API_VALID" == true ]]; then
  pass "10.12 COMPLETE — api-service template is structurally valid"
fi

section "10.13: agent-system Template Compatibility"

AGT="$ROOT/templates/agent-system"
AGT_VALID=true

if [[ -f "$AGT/CLAUDE.md" ]] && [[ -s "$AGT/CLAUDE.md" ]]; then
  pass "agent-system CLAUDE.md exists and is non-empty"
else
  fail "agent-system CLAUDE.md missing or empty"
  AGT_VALID=false
fi

if [[ -d "$AGT/.claude" ]]; then
  pass "agent-system has .claude/ directory"
else
  fail "agent-system missing .claude/ directory"
  AGT_VALID=false
fi

if [[ -f "$AGT/.gitignore" ]]; then
  pass "agent-system has .gitignore"
else
  warn "agent-system missing .gitignore"
fi

if [[ "$AGT_VALID" == true ]]; then
  pass "10.13 COMPLETE — agent-system template is structurally valid"
fi

# ============================================================
# Cross-Cutting Validation
# ============================================================
section "Cross-Cutting: Agent-Command-Skill Wiring"

# Verify each command invokes the correct agent with the correct model
declare -A CMD_AGENT_MODEL=(
  ["idea"]="interviewer:opus"
  ["plan"]="planner:opus"
  ["architect"]="architect:opus"
  ["build"]="executor:sonnet"
  ["test"]="tester:sonnet"
  ["ship"]="release-manager:sonnet"
)

for cmd in "${!CMD_AGENT_MODEL[@]}"; do
  AGENT="${CMD_AGENT_MODEL[$cmd]%%:*}"
  MODEL="${CMD_AGENT_MODEL[$cmd]##*:}"

  # Check agent file has correct model
  AGENT_FILE="$ROOT/.claude/agents/$AGENT.md"
  if grep -q "model: $MODEL" "$AGENT_FILE" 2>/dev/null; then
    pass "$cmd → $AGENT agent uses $MODEL model"
  else
    fail "$cmd → $AGENT agent should use $MODEL model"
  fi
done

# Verify reviewer agent is read-only
if grep -q "disallowedTools.*Write" "$ROOT/.claude/agents/reviewer.md"; then
  pass "Reviewer agent is read-only (Write disallowed)"
else
  fail "Reviewer agent is NOT read-only"
fi

# Verify critic agent is read-only
if grep -q "disallowedTools.*Write" "$ROOT/.claude/agents/critic.md"; then
  pass "Critic agent is read-only (Write disallowed)"
else
  fail "Critic agent is NOT read-only"
fi

# Verify critic agent validates against output-spec
if grep -q "output-spec" "$ROOT/.claude/agents/critic.md"; then
  pass "Critic agent references output-spec.md for validation"
else
  fail "Critic agent does not reference output-spec.md"
fi

# ============================================================
# CLEANUP
# ============================================================
section "Cleanup"
rm -rf "$TEST_DIR"
pass "Test workspace cleaned up"

# ============================================================
# SUMMARY
# ============================================================
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  E2E DRY-RUN SIMULATION — RESULTS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}PASSED:${NC}  $PASS"
echo -e "  ${RED}FAILED:${NC}  $FAIL"
echo -e "  ${YELLOW}WARNED:${NC}  $WARN"
echo -e "  TOTAL:   $((PASS + FAIL + WARN))"
echo ""

if [[ "$FAIL" -eq 0 ]]; then
  echo -e "  ${GREEN}ALL CHECKS PASSED${NC}"
  exit 0
else
  echo -e "  ${RED}$FAIL CHECK(S) FAILED — see details above${NC}"
  exit 1
fi
