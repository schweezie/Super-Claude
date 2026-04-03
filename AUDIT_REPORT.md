# Super Repo — Cross-File Consistency Audit Report

**Date:** April 1, 2026
**Files audited:** `SUPER_REPO_CONTEXT.md`, `CHECKLIST.md`, `AGENT_STATE.md`, `COMPACTION_PROTOCOL.md`

---

## 1. Directory Structure Match (Section 4.2 vs CHECKLIST.md)

**Verdict: 1 discrepancy found.**

Every file and directory listed in Section 4.2 of `SUPER_REPO_CONTEXT.md` has a corresponding scaffold task (Step 1) in `CHECKLIST.md`. The mapping is exact for all of the following:

- Root files (CLAUDE.md, README.md, setup.sh) — Tasks 1.1–1.3
- `.claude/settings.json` — Task 1.4
- `.claude/commands/` (7 files) — Tasks 1.5.1–1.5.7
- `.claude/agents/` (8 files) — Tasks 1.6.1–1.6.8
- `.claude/skills/` (8 skill dirs) — Tasks 1.7.1–1.7.8
- `.claude/hooks/` (4 files) — Tasks 1.8.1–1.8.4
- `knowledge/` (13 files across 3 subdirs) — Tasks 1.9.1–1.9.13
- `pipeline/` (17 files across 6 phase dirs) — Tasks 1.10.1–1.10.17
- `templates/` (5 project types) — Tasks 1.11.1–1.11.5
- `.omc/` (3 runtime dirs) — Tasks 1.12.1–1.12.3

**Discrepancy:**

| # | Issue | Details |
|---|-------|---------|
| 1.1 | **CHECKLIST task with no architecture backing** | Task **1.13** creates `.gitignore` with `.omc/` exclusion. This file does not appear anywhere in the Section 4.2 directory tree. The task is reasonable infrastructure, but the architecture is incomplete — `.gitignore` should be listed in the directory structure. |

---

## 2. Phase Coverage

**Verdict: 1 discrepancy found.**

All 6 pipeline phases (Idea, Plan, Architect, Build, Test, Ship) were checked for: slash command, agent(s), skill(s), output-spec, and knowledge references.

| Phase | Command | Agent(s) | Skill(s) | Output-Spec | Knowledge Refs |
|-------|---------|----------|----------|-------------|----------------|
| Idea | idea.md | interviewer | deep-interview | 01-idea/output-spec.md | None (by design) |
| Plan | plan.md | planner | prd-generator | 02-plan/output-spec.md | system-design, design-patterns |
| Architect | architect.md | architect | system-design | 03-architect/output-spec.md | data-structures, algorithms, system-design, design-patterns |
| Build | build.md | executor, reviewer | parallel-build, verification | 04-build/output-spec.md | agent-design, context-management, team-coordination, **coding-standards** |
| Test | test.md | tester | tdd, verification | 05-test/output-spec.md | algorithms, prompt-patterns |
| Ship | ship.md | release-manager | git-workflow, release | 06-ship/output-spec.md | hook-patterns |

All commands, agents, skills, and output-specs have matching CHECKLIST tasks in Steps 3–6. The `critic` agent has no dedicated phase but is correctly described as cross-cutting (used in the Verify sub-step of every phase per Section 4.3). This is consistent.

**Discrepancy:**

| # | Issue | Details |
|---|-------|---------|
| 2.1 | **Mislocated knowledge reference in BUILD phase** | Section 4.4 Phase 4 lists `coding-standards.md` as "Knowledge loaded," implying it lives in the `knowledge/` directory. However, this file is actually located at `pipeline/04-build/coding-standards.md` — a pipeline artifact, not a knowledge file. Either the file should be moved to `knowledge/`, or the phase description should distinguish between knowledge files and pipeline-local references. |

---

## 3. State Protocol Alignment (AGENT_STATE.md vs COMPACTION_PROTOCOL.md)

**Verdict: 3 discrepancies found.**

Both files define overlapping protocols for task completion, compaction, and recovery. The core mechanics align (compact at 200k/50%, re-read state files after compaction, git commit after steps). However, there are contradictions in sequencing and gaps in coverage.

| # | Issue | Details |
|---|-------|---------|
| 3.1 | **Compaction log timing contradiction** | `COMPACTION_PROTOCOL.md` Rule 2 says to log the compaction in the Compaction Log table **before** running `/compact` (step 4 of the pre-compaction checklist). `AGENT_STATE.md` says to log the compaction **after** compaction completes (step 4 of the post-compaction recovery sequence). These directly contradict each other. The pre-compaction approach (Rule 2) is more robust because it ensures the log entry survives the compaction. The AGENT_STATE.md post-compaction step should be removed or changed to "verify the compaction log entry." |
| 3.2 | **AGENT_STATE.md missing pre-compaction protocol** | `AGENT_STATE.md` defines what to do *after* compaction and *after* completing tasks, but has **no pre-compaction section**. `COMPACTION_PROTOCOL.md` Rule 2 defines a detailed 5-step pre-compaction procedure (finish atomic task, update state, update checklist, log compaction, git commit). This critical procedure exists only in `COMPACTION_PROTOCOL.md` and is not referenced from `AGENT_STATE.md`. An agent that reads only `AGENT_STATE.md` (as instructed) would miss the pre-compaction steps entirely. |
| 3.3 | **`/clear` between phases not mentioned in AGENT_STATE.md** | `COMPACTION_PROTOCOL.md` Rule 4 defines using `/clear` instead of `/compact` when switching between major pipeline phases. `AGENT_STATE.md` has no mention of `/clear` at all. Since agents are told to treat `AGENT_STATE.md` as their primary memory file, this gap means the `/clear` discipline could be missed. |

---

## 4. Task Count Accuracy

**Verdict: Ambiguity found. Top-level count is correct; total checkboxes are not reflected.**

The Progress Summary table claims **112 total tasks**. Verification of top-level task counts per step:

| Step | Summary Claims | Actual Top-Level Tasks | Match? |
|------|---------------|----------------------|--------|
| 1 — Scaffold | 14 | 14 (1.1–1.14) | Yes |
| 2 — CLAUDE.md | 12 | 12 (2.1–2.12) | Yes |
| 3 — Output Specs | 8 | 8 (3.1–3.8) | Yes |
| 4 — Commands | 9 | 9 (4.1–4.9) | Yes |
| 5 — Agents | 10 | 10 (5.1–5.10) | Yes |
| 6 — Skills | 10 | 10 (6.1–6.10) | Yes |
| 7 — Knowledge Base | 19 | 19 (7.1–7.19) | Yes |
| 8 — Templates | 7 | 7 (8.1–8.7) | Yes |
| 9 — Hooks | 7 | 7 (9.1–9.7) | Yes |
| 10 — E2E Testing | 16 | 16 (10.1–10.16) | Yes |
| **Total** | **112** | **112** | **Yes** |

**However**, Step 1 contains **65 additional indented subtask checkboxes** (e.g., 1.5.1–1.5.7, 1.6.1–1.6.8, etc.), bringing the actual total checkbox count to **177**.

| # | Issue | Details |
|---|-------|---------|
| 4.1 | **Subtask checkboxes not reflected in totals** | The Progress Summary counts 112 top-level tasks but the file contains 177 checkboxes. The 65 subtasks in Step 1 are each individually checkable but are invisible to the progress tracker. An agent checking off subtask 1.5.1 through 1.5.7 individually has no effect on the "0/112" progress counter until the parent task 1.5 is also checked. This creates ambiguity about what "progress" means and could confuse automated or agent-driven tracking. Recommendation: either fold subtasks into their parents (removing subtask checkboxes) or update the total to 177. |

---

## 5. Cross-References

**Verdict: 2 discrepancies found.**

All three state files are correctly cross-referenced by name across the documents. The CLAUDE.md integration block at the bottom of `COMPACTION_PROTOCOL.md` correctly names:
- `AGENT_STATE.md` — confirmed to exist
- `CHECKLIST.md` — confirmed to exist
- `SUPER_REPO_CONTEXT.md` — confirmed to exist

| # | Issue | Details |
|---|-------|---------|
| 5.1 | **COMPACTION_PROTOCOL.md not referenced in the recovery sequence** | Both `AGENT_STATE.md` (post-compaction steps) and `COMPACTION_PROTOCOL.md` Rule 3 (recovery sequence) instruct the agent to re-read `AGENT_STATE.md`, `CHECKLIST.md`, and `SUPER_REPO_CONTEXT.md`. Neither mentions re-reading `COMPACTION_PROTOCOL.md` itself. If an agent forgets the compaction rules after compaction, there is no trigger to reload them. The CLAUDE.md integration block partially solves this by embedding a summary, but the full 10-rule protocol would be lost. |
| 5.2 | **CLAUDE.md integration block omits COMPACTION_PROTOCOL.md as a file reference** | The integration block at the bottom of `COMPACTION_PROTOCOL.md` lists three files for the agent to know about (AGENT_STATE.md, CHECKLIST.md, SUPER_REPO_CONTEXT.md) but does not list `COMPACTION_PROTOCOL.md` itself. The block says to embed the rules inline, but the inline summary covers only 5 of the 10 rules — missing Rules 4 (`/clear` between phases), 7 (token budgets), 8 (multi-agent awareness), 9 (active decisions guidance), and 10 (emergency recovery). |

---

## Summary of All Discrepancies

| # | Category | Severity | Description |
|---|----------|----------|-------------|
| 1.1 | Directory Structure | Low | `.gitignore` in CHECKLIST but missing from Section 4.2 directory tree |
| 2.1 | Phase Coverage | Medium | `coding-standards.md` listed as "knowledge loaded" but lives in `pipeline/`, not `knowledge/` |
| 3.1 | State Protocol | High | Compaction log timing contradicts: COMPACTION_PROTOCOL says log before, AGENT_STATE says log after |
| 3.2 | State Protocol | High | AGENT_STATE.md has no pre-compaction protocol; agents reading only this file would miss critical steps |
| 3.3 | State Protocol | Medium | `/clear` between phases exists only in COMPACTION_PROTOCOL, absent from AGENT_STATE.md |
| 4.1 | Task Count | Medium | 177 actual checkboxes vs 112 claimed; 65 subtasks invisible to progress tracking |
| 5.1 | Cross-References | Low | COMPACTION_PROTOCOL.md not included in post-compaction recovery reading list |
| 5.2 | Cross-References | Medium | CLAUDE.md integration block summarizes only 5 of 10 compaction rules; omits self-reference |

**Total discrepancies found: 8** (2 High, 4 Medium, 2 Low)
