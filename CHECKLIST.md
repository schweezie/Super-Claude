# SUPER REPO — Implementation Checklist

> **FOR CODING AGENTS:** This file is your source of truth. After every completed task, update this file by changing `[ ]` to `[x]`. After every compaction, re-read this file and `AGENT_STATE.md` before continuing work.

---

## STEP 1: Scaffold (Directory Structure)
- [x] 1.1 Create root `CLAUDE.md` placeholder
- [x] 1.2 Create root `README.md` placeholder
- [x] 1.3 Create `setup.sh` placeholder
- [x] 1.4 Create `.claude/settings.json`
- [x] 1.5 Create `.claude/commands/` directory with placeholder files:
  - [x] 1.5.1 `idea.md`
  - [x] 1.5.2 `plan.md`
  - [x] 1.5.3 `architect.md`
  - [x] 1.5.4 `build.md`
  - [x] 1.5.5 `test.md`
  - [x] 1.5.6 `ship.md`
  - [x] 1.5.7 `full-pipeline.md`
- [x] 1.6 Create `.claude/agents/` directory with placeholder files:
  - [x] 1.6.1 `interviewer.md`
  - [x] 1.6.2 `planner.md`
  - [x] 1.6.3 `architect.md`
  - [x] 1.6.4 `executor.md`
  - [x] 1.6.5 `reviewer.md`
  - [x] 1.6.6 `tester.md`
  - [x] 1.6.7 `release-manager.md`
  - [x] 1.6.8 `critic.md`
- [x] 1.7 Create `.claude/skills/` directory with SKILL.md placeholders:
  - [x] 1.7.1 `deep-interview/SKILL.md`
  - [x] 1.7.2 `prd-generator/SKILL.md`
  - [x] 1.7.3 `system-design/SKILL.md`
  - [x] 1.7.4 `parallel-build/SKILL.md`
  - [x] 1.7.5 `tdd/SKILL.md`
  - [x] 1.7.6 `verification/SKILL.md`
  - [x] 1.7.7 `git-workflow/SKILL.md`
  - [x] 1.7.8 `release/SKILL.md`
- [x] 1.8 Create `.claude/hooks/` directory with placeholder files:
  - [x] 1.8.1 `session-start.js`
  - [x] 1.8.2 `pre-tool-use.js`
  - [x] 1.8.3 `stop.js`
  - [x] 1.8.4 `post-tool-use.js`
- [x] 1.9 Create `knowledge/` directory structure:
  - [x] 1.9.1 `knowledge/cs-fundamentals/data-structures.md`
  - [x] 1.9.2 `knowledge/cs-fundamentals/algorithms.md`
  - [x] 1.9.3 `knowledge/cs-fundamentals/system-design.md`
  - [x] 1.9.4 `knowledge/cs-fundamentals/design-patterns.md`
  - [x] 1.9.5 `knowledge/claude-code-patterns/agent-design.md`
  - [x] 1.9.6 `knowledge/claude-code-patterns/skill-design.md`
  - [x] 1.9.7 `knowledge/claude-code-patterns/hook-patterns.md`
  - [x] 1.9.8 `knowledge/claude-code-patterns/context-management.md`
  - [x] 1.9.9 `knowledge/claude-code-patterns/team-coordination.md`
  - [x] 1.9.10 `knowledge/claude-code-patterns/prompt-patterns.md`
  - [x] 1.9.11 `knowledge/harness-internals/tool-orchestration.md`
  - [x] 1.9.12 `knowledge/harness-internals/context-window.md`
  - [x] 1.9.13 `knowledge/harness-internals/runtime-behavior.md`
- [x] 1.10 Create `pipeline/` directory structure:
  - [x] 1.10.1 `pipeline/01-idea/interview-template.md`
  - [x] 1.10.2 `pipeline/01-idea/output-spec.md`
  - [x] 1.10.3 `pipeline/02-plan/prd-template.md`
  - [x] 1.10.4 `pipeline/02-plan/task-breakdown-template.md`
  - [x] 1.10.5 `pipeline/02-plan/output-spec.md`
  - [x] 1.10.6 `pipeline/03-architect/design-doc-template.md`
  - [x] 1.10.7 `pipeline/03-architect/data-model-template.md`
  - [x] 1.10.8 `pipeline/03-architect/output-spec.md`
  - [x] 1.10.9 `pipeline/04-build/team-config-template.md`
  - [x] 1.10.10 `pipeline/04-build/coding-standards.md`
  - [x] 1.10.11 `pipeline/04-build/output-spec.md`
  - [x] 1.10.12 `pipeline/05-test/test-strategy-template.md`
  - [x] 1.10.13 `pipeline/05-test/qa-checklist.md`
  - [x] 1.10.14 `pipeline/05-test/output-spec.md`
  - [x] 1.10.15 `pipeline/06-ship/release-checklist.md`
  - [x] 1.10.16 `pipeline/06-ship/deploy-template.md`
  - [x] 1.10.17 `pipeline/06-ship/output-spec.md`
- [x] 1.11 Create `templates/` directory structure:
  - [x] 1.11.1 `templates/web-app/` starter
  - [x] 1.11.2 `templates/api-service/` starter
  - [x] 1.11.3 `templates/cli-tool/` starter
  - [x] 1.11.4 `templates/full-stack/` starter
  - [x] 1.11.5 `templates/agent-system/` starter
- [x] 1.12 Create `.omc/` runtime directories (gitignored):
  - [x] 1.12.1 `.omc/artifacts/`
  - [x] 1.12.2 `.omc/state/`
  - [x] 1.12.3 `.omc/memory/`
- [x] 1.13 Create `.gitignore` with `.omc/` exclusion
- [x] 1.14 **STEP 1 COMPLETE** — Update `AGENT_STATE.md`

---

## STEP 2: Master CLAUDE.md
- [x] 2.1 Write phase detection routing logic (keyword → phase mapping)
- [x] 2.2 Write knowledge loading rules (which files load per phase)
- [x] 2.3 Write gate enforcement rules (what must exist before each phase starts)
- [x] 2.4 Write state tracking rules (read/write `.omc/state/`)
- [x] 2.5 Write delegation rules (when to use subagent vs team vs direct)
- [x] 2.6 Write context management rules (compaction at 200k, `/clear` between phases)
- [x] 2.7 Write artifact path conventions
- [x] 2.8 Write model selection guidance (Opus for planning, Sonnet for code)
- [x] 2.9 Reference all commands, agents, skills in the routing table
- [x] 2.10 Add compaction recovery protocol (re-read AGENT_STATE.md + CHECKLIST.md)
- [x] 2.11 Test CLAUDE.md loads correctly in Claude Code
- [x] 2.12 **STEP 2 COMPLETE** — Update `AGENT_STATE.md`

---

## STEP 3: Pipeline Output Specs
- [x] 3.1 Write `pipeline/01-idea/output-spec.md` — Define what idea phase must produce
- [x] 3.2 Write `pipeline/02-plan/output-spec.md` — Define what plan phase must produce
- [x] 3.3 Write `pipeline/03-architect/output-spec.md` — Define what architect phase must produce
- [x] 3.4 Write `pipeline/04-build/output-spec.md` — Define what build phase must produce
- [x] 3.5 Write `pipeline/05-test/output-spec.md` — Define what test phase must produce
- [x] 3.6 Write `pipeline/06-ship/output-spec.md` — Define what ship phase must produce
- [x] 3.7 Cross-validate: each output-spec's outputs match next phase's expected inputs
- [x] 3.8 **STEP 3 COMPLETE** — Update `AGENT_STATE.md`

---

## STEP 4: Slash Commands
- [x] 4.1 Write `.claude/commands/idea.md` — Entry point, invokes interviewer agent
- [x] 4.2 Write `.claude/commands/plan.md` — Reads idea artifact, invokes planner
- [x] 4.3 Write `.claude/commands/architect.md` — Reads plan artifact, invokes architect
- [x] 4.4 Write `.claude/commands/build.md` — Reads architecture, invokes executor/teams
- [x] 4.5 Write `.claude/commands/test.md` — Reads build output, invokes tester
- [x] 4.6 Write `.claude/commands/ship.md` — Reads test report, invokes release-manager
- [x] 4.7 Write `.claude/commands/full-pipeline.md` — Chains all phases with gates
- [x] 4.8 Test each command loads and triggers correctly
- [x] 4.9 **STEP 4 COMPLETE** — Update `AGENT_STATE.md`

---

## STEP 5: Agent Definitions
- [x] 5.1 Write `.claude/agents/interviewer.md` with YAML frontmatter (tools, model, maxTurns, skills)
- [x] 5.2 Write `.claude/agents/planner.md` with YAML frontmatter
- [x] 5.3 Write `.claude/agents/architect.md` with YAML frontmatter
- [x] 5.4 Write `.claude/agents/executor.md` with YAML frontmatter
- [x] 5.5 Write `.claude/agents/reviewer.md` with YAML frontmatter
- [x] 5.6 Write `.claude/agents/tester.md` with YAML frontmatter
- [x] 5.7 Write `.claude/agents/release-manager.md` with YAML frontmatter
- [x] 5.8 Write `.claude/agents/critic.md` with YAML frontmatter
- [x] 5.9 Validate all agents have correct tool allowlists and model assignments
- [x] 5.10 **STEP 5 COMPLETE** — Update `AGENT_STATE.md`

---

## STEP 6: Skill Definitions
- [x] 6.1 Write `.claude/skills/deep-interview/SKILL.md` with frontmatter + pipeline handoff
- [x] 6.2 Write `.claude/skills/prd-generator/SKILL.md` with frontmatter + pipeline handoff
- [x] 6.3 Write `.claude/skills/system-design/SKILL.md` with frontmatter + pipeline handoff
- [x] 6.4 Write `.claude/skills/parallel-build/SKILL.md` with frontmatter + pipeline handoff
- [x] 6.5 Write `.claude/skills/tdd/SKILL.md` with frontmatter + pipeline handoff
- [x] 6.6 Write `.claude/skills/verification/SKILL.md` with frontmatter + pipeline handoff
- [x] 6.7 Write `.claude/skills/git-workflow/SKILL.md` with frontmatter + pipeline handoff
- [x] 6.8 Write `.claude/skills/release/SKILL.md` with frontmatter + pipeline handoff
- [x] 6.9 Validate all skill pipeline handoff chains are correct (skill A → skill B → skill C)
- [x] 6.10 **STEP 6 COMPLETE** — Update `AGENT_STATE.md`

---

## STEP 7: Knowledge Base Curation

> **Multi-source rule:** Tasks 7.8–7.13 synthesize from 3 repos (oh-my-claudecode, best-practice, howto). Do NOT mark complete until ALL applicable sources have been incorporated. Each session should EXTEND the file, not overwrite it.

- [x] 7.1 Clone/fetch `coding-interview-university` repo
- [x] 7.2 Distill `knowledge/cs-fundamentals/data-structures.md` — tradeoffs, Big-O, when-to-use
- [x] 7.3 Distill `knowledge/cs-fundamentals/algorithms.md` — patterns, complexity, common applications
- [x] 7.4 Distill `knowledge/cs-fundamentals/system-design.md` — scalability, databases, caching, infra
- [x] 7.5 Distill `knowledge/cs-fundamentals/design-patterns.md` — GoF patterns, when to apply
- [x] 7.6 Clone/fetch `claude-code-best-practice` repo
- [x] 7.7 Clone/fetch `claude-howto` repo
- [x] 7.8 Distill `knowledge/claude-code-patterns/agent-design.md` — from omc + best-practice + howto (ALL 3)
- [x] 7.9 Distill `knowledge/claude-code-patterns/skill-design.md` — from omc + best-practice + howto (ALL 3)
- [x] 7.10 Distill `knowledge/claude-code-patterns/hook-patterns.md` — from best-practice + howto
- [x] 7.11 Distill `knowledge/claude-code-patterns/context-management.md` — from omc + best-practice + howto (ALL 3)
- [x] 7.12 Distill `knowledge/claude-code-patterns/team-coordination.md` — from omc + best-practice + howto (ALL 3)
- [x] 7.13 Distill `knowledge/claude-code-patterns/prompt-patterns.md` — from best-practice + howto
- [x] 7.14 Clone/fetch `claw-code` repo
- [x] 7.15 Distill `knowledge/harness-internals/tool-orchestration.md` — from claw-code
- [x] 7.16 Distill `knowledge/harness-internals/context-window.md` — from claw-code
- [x] 7.17 Distill `knowledge/harness-internals/runtime-behavior.md` — from claw-code
- [x] 7.18 Validate all knowledge files are concise (<2000 tokens each) and agent-readable
- [x] 7.19 **STEP 7 COMPLETE** — Update `AGENT_STATE.md`

---

## STEP 8: Project Templates
- [x] 8.1 Create `templates/web-app/` — Next.js + Tailwind + Supabase starter
- [x] 8.2 Create `templates/api-service/` — FastAPI + SQLAlchemy starter
- [x] 8.3 Create `templates/cli-tool/` — Python Click/Typer starter
- [x] 8.4 Create `templates/full-stack/` — Next.js + FastAPI + Supabase starter
- [x] 8.5 Create `templates/agent-system/` — Multi-agent Claude Code starter
- [x] 8.6 Each template includes its own CLAUDE.md overlay, basic file structure, and README
- [x] 8.7 **STEP 8 COMPLETE** — Update `AGENT_STATE.md`

---

## STEP 9: Lifecycle Hooks
- [x] 9.1 Write `.claude/hooks/session-start.js` — Load state, detect phase, print status
- [x] 9.2 Write `.claude/hooks/pre-tool-use.js` — Guard rails, log actions
- [x] 9.3 Write `.claude/hooks/stop.js` — Check completion, nudge if incomplete, save state
- [x] 9.4 Write `.claude/hooks/post-tool-use.js` — Track progress, update state file
- [x] 9.5 Register all hooks in `.claude/settings.json`
- [x] 9.6 Test hooks fire correctly in Claude Code
- [x] 9.7 **STEP 9 COMPLETE** — Update `AGENT_STATE.md`

---

## STEP 10: End-to-End Testing
- [x] 10.1 Test `/idea` command — produces valid idea-brief artifact
- [x] 10.2 Test `/plan` command — reads idea-brief, produces PRD artifact
- [x] 10.3 Test `/architect` command — reads PRD, produces architecture artifact
- [x] 10.4 Test `/build` command — reads architecture, produces working code
- [x] 10.5 Test `/test` command — reads build output, produces test report
- [x] 10.6 Test `/ship` command — reads test report, produces release
- [x] 10.7 Test `/full-pipeline` command — chains all 6 phases with gate enforcement
- [x] 10.8 Test gate enforcement — verify `/build` fails without architecture artifact
- [x] 10.9 Test phase resumption — kill mid-build, resume, confirm state recovery
- [x] 10.10 Test compaction recovery — force compact, verify agent re-reads state and continues
- [x] 10.11 Test with `web-app` template end-to-end
- [x] 10.12 Test with `api-service` template end-to-end
- [x] 10.13 Test with `agent-system` template end-to-end
- [x] 10.14 Write root `README.md` with setup instructions, usage guide, examples
- [x] 10.15 **STEP 10 COMPLETE** — Update `AGENT_STATE.md`
- [x] 10.16 **PROJECT COMPLETE**

---

## Progress Summary

| Step | Description | Tasks | Complete | Status |
|------|-------------|-------|----------|--------|
| 1 | Scaffold | 14 | 14 | ✅ Complete |
| 2 | CLAUDE.md | 12 | 12 | ✅ Complete |
| 3 | Output Specs | 8 | 8 | ✅ Complete |
| 4 | Commands | 9 | 9 | ✅ Complete |
| 5 | Agents | 10 | 10 | ✅ Complete |
| 6 | Skills | 10 | 10 | ✅ Complete |
| 7 | Knowledge Base | 19 | 19 | ✅ Complete |
| 8 | Templates | 7 | 7 | ✅ Complete |
| 9 | Hooks | 7 | 7 | ✅ Complete |
| 10 | E2E Testing | 16 | 16 | ✅ Complete |
| **TOTAL** | | **112** | **112** | **100%** |

> **Counting convention:** The 112 total reflects **top-level tasks** only (e.g., task 1.5 counts as 1, even though it has 7 subtask checkboxes 1.5.1–1.5.7). Step 1 contains 65 additional subtask checkboxes, bringing the actual total checkbox count to **177**. For progress tracking, mark the **parent task** complete only after all its subtasks are checked. The progress percentage above is based on the 112 top-level tasks.

---

*Last updated by: Session 16 (Step 10 E2E Testing complete — all 16 tasks done. PROJECT COMPLETE 112/112)*