# SUPER REPO — LLM Context Briefing

> **Purpose of this document:** You are receiving this as context for a software project. Read it in full before taking any action. This document describes the goals, source materials, architecture, and implementation plan for building a "super repo" — a unified system that guides any software project from initial idea to shipped product. Your job is to help build it.

---

## 1. Project Owner

**Dominic Schimizzi (Dom)** — Senior Economics major, Co-founder/CSO of Licom AI (AI consultancy), incoming AI Implementor at Metro Development Group. Background in multi-agent orchestration (Paperclip platform), Python, Claude Code, RAG architectures, and prompt engineering. Not a traditional CS grad — learns by building. Treats AI tooling as infrastructure, not novelty.

---

## 2. The Goal

Build a single repository that serves as a **complete operating system for taking any software project from idea to shipped product**, powered by Claude Code and multi-agent orchestration.

The pipeline has six phases:

```
IDEA → PLAN → ARCHITECT → BUILD → TEST → SHIP
```

Every phase must have:
- Defined entry/exit criteria
- Agent configurations (skills, subagents, or team setups)
- Templates and prompts that can be invoked via slash commands
- Access to relevant knowledge (CS fundamentals, Claude Code patterns, architectural best practices)

The super repo is NOT a tutorial. It is NOT documentation. It is a **functional, executable system** that a developer installs and uses inside Claude Code to run real projects.

---

## 3. Source Repositories

The super repo is synthesized from 5 existing GitHub repositories. Each contributes a specific layer. Do not blindly copy content — extract, distill, and restructure what is useful.

### 3.1 — claw-code
- **Repo:** `https://github.com/instructkr/claw-code.git`
- **What it is:** Clean-room Python rewrite of Claude Code's agent harness architecture. Being rewritten in Rust.
- **What it contributes:** Deep understanding of how the agent runtime works — tool wiring, task orchestration, context management. This is the "how the engine works under the hood" layer.
- **Use it for:** Informing agent design decisions. Understanding what the harness can and cannot do. Extracting patterns for tool orchestration, context window management, and runtime behavior.
- **Do NOT:** Ship this code directly. It is reference material, not a dependency.

### 3.2 — claude-code-best-practice
- **Repo:** `https://github.com/shanraisshan/claude-code-best-practice.git`
- **What it is:** Comprehensive reference implementation for Claude Code configuration — commands, agents, skills, hooks, workflows, subagent patterns. Includes tips from Boris Cherny (creator of Claude Code).
- **What it contributes:** Production-tested patterns for structuring `.claude/` directories, writing effective CLAUDE.md files, configuring hooks, designing subagent architectures (Command → Agent → Skill pattern), and managing context.
- **Use it for:** Extracting best practices for every `.claude/` configuration in the super repo. Adopting proven patterns for skill frontmatter, hook event handling, agent delegation, and context management strategies.
- **Key patterns to extract:**
  - Phase-wise gated plans with tests at each phase
  - Cross-model review (e.g., Opus for planning, Sonnet for code)
  - `/compact` discipline (manual at max 50%, `/clear` for task switches)
  - Subagent frontmatter fields (tools, disallowedTools, model, permissionMode, maxTurns, skills, hooks, memory)
  - Stop hooks for nudging continuation
  - Agent Teams for parallel coordination

### 3.3 — claude-howto
- **Repo:** `https://github.com/luongnv89/claude-howto.git`
- **What it is:** Visual, example-driven tutorial guide to Claude Code. Progressive learning path from basics to advanced agents with Mermaid diagrams and copy-paste templates.
- **What it contributes:** Well-structured templates for skills, subagents, hooks, MCP integrations, and workflows. Clear examples of how features compose together.
- **Use it for:** Stealing copy-paste-ready templates for skill definitions, subagent configurations, hook scripts, and MCP setup patterns. The tutorial structure also informs how the super repo's own documentation should be organized.
- **Key templates to extract:**
  - Skill SKILL.md frontmatter patterns
  - Subagent .md definitions with YAML frontmatter
  - Hook event handlers (PreToolUse, PostToolUse, Stop, SessionStart)
  - MCP server integration patterns
  - Agent Team coordination examples

### 3.4 — oh-my-claudecode (OMC)
- **Repo:** `https://github.com/Yeachan-Heo/oh-my-claudecode.git`
- **What it is:** Teams-first multi-agent orchestration plugin for Claude Code. 19+ specialized agents, 28+ skills, full pipeline coverage from idea to ship.
- **What it contributes:** This is the **backbone**. OMC already implements most of the pipeline phases the super repo needs. Its architecture (skill-based routing, agent delegation, team coordination, HUD observability, memory system) is the foundation to build on.
- **Key capabilities to leverage:**
  - `/deep-interview` — Socratic questioning to clarify vague ideas before execution (IDEA phase)
  - `/ralplan` — Strategic interview-based planning workflow (PLAN phase)
  - `architect` agent — Designs system architecture before building (ARCHITECT phase)
  - `ultrawork` — Maximum parallelism with aggressive agent delegation (BUILD phase)
  - `ralph` loop — Self-referential execution loop until completion with verification (BUILD phase)
  - `autopilot` — Full autonomous execution from idea to working code (BUILD phase)
  - Agent Teams — N coordinated agents on shared task list with real-time messaging (BUILD phase)
  - `ultraqa` — Quality assurance and test workflows (TEST phase)
  - TDD workflows — Test-driven development guidance (TEST phase)
  - `git-master` — Atomic commits, branch management (SHIP phase)
  - `release` skill — Release management (SHIP phase)
  - HUD — Real-time observability of orchestration state
  - Memory system — Three-tier persistence that survives compaction
  - Skill pipelines — Declarative handoff contracts between skills (e.g., `deep-interview → omc-plan → autopilot`)
- **Architecture to adopt:**
  - Plugin-based installation via Claude Code marketplace
  - CLAUDE.md auto-routing based on task type detection
  - Skill frontmatter with pipeline/handoff contracts
  - Agent categories with auto-model-selection (visual-engineering, ultrabrain, etc.)
  - `.omc/` state directory for artifacts, specs, and session state
- **Do NOT:** Fork OMC wholesale. Extract its patterns and adapt them. The super repo should be opinionated about the pipeline phases in ways OMC is not.

### 3.5 — coding-interview-university
- **Repo:** `https://github.com/jwasham/coding-interview-university.git`
- **What it is:** Complete CS self-study plan — data structures, algorithms, Big-O, system design, graphs, trees, sorting, dynamic programming, etc. 340k+ stars.
- **What it contributes:** The **foundational knowledge layer**. CS fundamentals that inform good architectural decisions and code quality. This is not about interview prep — it is about ensuring the agents (and the human) have access to core CS principles when making design decisions.
- **Use it for:** Curating a distilled knowledge base that gets injected into agent context at appropriate pipeline phases. When the architect agent is designing a system, it should have access to data structure tradeoffs, algorithmic complexity, and system design patterns. When the build agent is writing code, it should know about proper implementations.
- **What to extract and distill:**
  - Data structures: when to use what, tradeoffs, complexity
  - Algorithms: sorting, searching, graph traversal, dynamic programming
  - System design: scalability patterns, database selection, caching strategies, load balancing
  - Big-O analysis: how to evaluate solution efficiency
  - Design patterns: common software patterns and when to apply them
- **How to structure it:** Create concise, agent-readable markdown files organized by topic. NOT the full study plan — distilled reference cards that an agent can load as context when needed.

---

## 4. Architecture

### 4.1 — Two-Layer Design

The super repo operates on two layers:

**KNOWLEDGE LAYER** — Curated, distilled reference material that agents load as context when they need it. Sourced from all 5 repos. Organized by topic, not by source.

**EXECUTION LAYER** — The actual pipeline: agents, skills, commands, hooks, and team configurations that execute each phase of the idea-to-ship workflow. Modeled after OMC's architecture but restructured around the six explicit pipeline phases.

### 4.2 — Directory Structure

```
super-repo/
│
├── CLAUDE.md                          # Master orchestration — task routing, phase detection, global rules
├── README.md                          # Human-readable project overview and setup instructions
├── setup.sh                           # One-command installation script
├── .gitignore                         # Git ignore rules (.omc/ exclusion)
│
├── .claude/
│   ├── settings.json                  # Permissions, hooks config, MCP servers
│   │
│   ├── commands/                      # Slash commands (user-facing entry points)
│   │   ├── idea.md                    # /idea — Start from scratch, run Socratic interview
│   │   ├── plan.md                    # /plan — Generate PRD from idea output
│   │   ├── architect.md               # /architect — Design system from PRD
│   │   ├── build.md                   # /build — Execute implementation from architecture
│   │   ├── test.md                    # /test — Run QA, verification, coverage
│   │   ├── ship.md                    # /ship — Release, deploy, tag
│   │   └── full-pipeline.md           # /full-pipeline — Run all phases sequentially with gates
│   │
│   ├── agents/                        # Subagent definitions
│   │   ├── interviewer.md             # Socratic requirements gathering
│   │   ├── planner.md                 # PRD and spec generation
│   │   ├── architect.md               # System design and tech decisions
│   │   ├── executor.md                # Code implementation
│   │   ├── reviewer.md                # Code review and quality checks
│   │   ├── tester.md                  # Test writing and QA
│   │   ├── release-manager.md         # Git, versioning, deployment
│   │   └── critic.md                  # Cross-cutting quality gate agent
│   │
│   ├── skills/                        # Skill definitions (auto-loaded by relevance)
│   │   ├── deep-interview/            # Socratic questioning skill
│   │   │   └── SKILL.md
│   │   ├── prd-generator/             # PRD creation from interview output
│   │   │   └── SKILL.md
│   │   ├── system-design/             # Architecture design skill
│   │   │   └── SKILL.md
│   │   ├── parallel-build/            # Multi-agent parallel execution
│   │   │   └── SKILL.md
│   │   ├── tdd/                       # Test-driven development
│   │   │   └── SKILL.md
│   │   ├── verification/              # Output verification loops
│   │   │   └── SKILL.md
│   │   ├── git-workflow/              # Branch, commit, PR management
│   │   │   └── SKILL.md
│   │   └── release/                   # Versioning and deployment
│   │       └── SKILL.md
│   │
│   └── hooks/                         # Lifecycle hooks
│       ├── session-start.js           # Load project state, check phase
│       ├── pre-tool-use.js            # Guard rails, logging
│       ├── stop.js                    # Nudge continuation, verify completion
│       └── post-tool-use.js           # Track progress, update HUD
│
├── knowledge/                         # Distilled reference material (agent-readable)
│   │
│   ├── cs-fundamentals/               # From coding-interview-university
│   │   ├── data-structures.md         # Arrays, linked lists, trees, graphs, hash tables — when to use, tradeoffs, Big-O
│   │   ├── algorithms.md              # Sorting, searching, graph traversal, DP — patterns and complexity
│   │   ├── system-design.md           # Scalability, databases, caching, load balancing, message queues
│   │   └── design-patterns.md         # Common patterns: factory, observer, strategy, etc.
│   │
│   ├── claude-code-patterns/          # From best-practice + claude-howto
│   │   ├── agent-design.md            # How to write effective agent .md files, delegation patterns
│   │   ├── skill-design.md            # Skill frontmatter, auto-discovery, pipeline handoffs
│   │   ├── hook-patterns.md           # Hook events, common handlers, lifecycle management
│   │   ├── context-management.md      # Compaction strategy, /clear discipline, memory tiers
│   │   ├── team-coordination.md       # Agent Teams setup, mailbox patterns, task distribution
│   │   └── prompt-patterns.md         # Effective prompting: ultrathink, verification, challenge patterns
│   │
│   └── harness-internals/             # From claw-code
│       ├── tool-orchestration.md      # How tools are wired and invoked at runtime
│       ├── context-window.md          # How context is managed, token budgets, compaction mechanics
│       └── runtime-behavior.md        # Agent loop mechanics, error handling, retry patterns
│
├── pipeline/                          # Phase-specific artifacts and templates
│   │
│   ├── 01-idea/
│   │   ├── interview-template.md      # Structured interview questions by project type
│   │   └── output-spec.md             # What the idea phase must produce before advancing
│   │
│   ├── 02-plan/
│   │   ├── prd-template.md            # PRD format with user stories, acceptance criteria
│   │   ├── task-breakdown-template.md # How to decompose PRD into buildable tasks
│   │   └── output-spec.md             # What the plan phase must produce
│   │
│   ├── 03-architect/
│   │   ├── design-doc-template.md     # Architecture decision records, tech stack selection
│   │   ├── data-model-template.md     # Schema design template
│   │   └── output-spec.md             # What the architecture phase must produce
│   │
│   ├── 04-build/
│   │   ├── team-config-template.md    # How to configure agent teams for parallel build
│   │   ├── coding-standards.md        # Code quality expectations
│   │   └── output-spec.md             # What the build phase must produce
│   │
│   ├── 05-test/
│   │   ├── test-strategy-template.md  # Unit, integration, e2e test planning
│   │   ├── qa-checklist.md            # Verification checklist
│   │   └── output-spec.md             # What the test phase must produce
│   │
│   └── 06-ship/
│       ├── release-checklist.md       # Pre-release verification
│       ├── deploy-template.md         # Deployment configuration
│       └── output-spec.md             # What the ship phase must produce
│
├── templates/                         # Project type starters
│   ├── web-app/                       # React/Next.js web application
│   ├── api-service/                   # FastAPI/Express backend service
│   ├── cli-tool/                      # Command-line tool
│   ├── full-stack/                    # Full-stack application
│   └── agent-system/                  # Multi-agent AI system
│
└── .omc/                             # Runtime state (gitignored)
    ├── artifacts/                     # Phase outputs, specs, interview results
    ├── state/                         # Current pipeline phase, progress tracking
    └── memory/                        # Persistent knowledge across sessions
```

### 4.3 — Pipeline Flow

Each phase follows this pattern:

```
ENTRY GATE → EXECUTE → VERIFY → EXIT GATE → HANDOFF ARTIFACT
```

**Entry Gate:** Check that the previous phase's output spec is satisfied. If not, refuse to proceed and explain what's missing.

**Execute:** Run the phase's primary skill/agent/team. Inject relevant knowledge from `knowledge/` into context.

**Verify:** Run the critic agent against the output. Check the phase's `output-spec.md` requirements.

**Exit Gate:** Confirm all output-spec criteria are met. Generate the handoff artifact.

**Handoff Artifact:** A markdown file saved to `.omc/artifacts/{phase}/` that the next phase reads as input.

### 4.4 — Phase Details

#### Phase 1: IDEA (`/idea`)
- **Agent:** `interviewer`
- **Skill:** `deep-interview`
- **Knowledge loaded:** None (this phase is about the human's vision)
- **Process:** Socratic questioning to extract requirements, constraints, success criteria, target users, and scope. Measures clarity across weighted dimensions. Exposes hidden assumptions.
- **Handoff artifact:** `.omc/artifacts/01-idea/idea-brief.md` — Structured summary of the idea with clarity scores
- **Exit criteria:** All clarity dimensions score above threshold. User has confirmed the brief.

#### Phase 2: PLAN (`/plan`)
- **Agent:** `planner`
- **Skill:** `prd-generator`
- **Knowledge loaded:** `system-design.md`, `design-patterns.md`
- **Process:** Takes idea brief, generates PRD with user stories, acceptance criteria, task breakdown, dependency graph, and priority ranking.
- **Handoff artifact:** `.omc/artifacts/02-plan/prd.md` — Full PRD with testable acceptance criteria
- **Exit criteria:** Every user story has acceptance criteria. Task breakdown covers all stories. Dependencies are mapped.

#### Phase 3: ARCHITECT (`/architect`)
- **Agent:** `architect`
- **Skill:** `system-design`
- **Knowledge loaded:** `data-structures.md`, `algorithms.md`, `system-design.md`, `design-patterns.md`
- **Process:** Takes PRD, produces architecture: tech stack decisions, data model, API contracts, component diagram, infrastructure plan. Justifies decisions with tradeoffs.
- **Handoff artifact:** `.omc/artifacts/03-architect/architecture.md` — Complete design document
- **Exit criteria:** Every PRD task is covered by the architecture. Tech stack is justified. Data model is defined. API contracts are specified.

#### Phase 4: BUILD (`/build`)
- **Agent:** `executor` (primary), `reviewer` (quality gate)
- **Skill:** `parallel-build`, `verification`
- **Knowledge loaded:** `agent-design.md`, `context-management.md`, `team-coordination.md` (from knowledge/). Also loads `coding-standards.md` from `pipeline/04-build/` (pipeline-local reference, not a knowledge file).
- **Process:** Decomposes architecture into parallelizable work units. Spins up Agent Teams or subagents. Each agent works on its assigned component. Reviewer agent gates PRs. Ralph-style loop ensures completion.
- **Handoff artifact:** Working code in the project repository. `.omc/artifacts/04-build/build-report.md` — What was built, what was deferred.
- **Exit criteria:** All planned components are implemented. Code compiles/runs. Reviewer has approved.

#### Phase 5: TEST (`/test`)
- **Agent:** `tester`
- **Skill:** `tdd`, `verification`
- **Knowledge loaded:** `algorithms.md` (for edge cases), `prompt-patterns.md` (for verification)
- **Process:** Generates test strategy from PRD acceptance criteria. Writes unit, integration, and e2e tests. Runs tests. Reports coverage. Loops until all acceptance criteria pass.
- **Handoff artifact:** `.omc/artifacts/05-test/test-report.md` — Coverage report, all acceptance criteria mapped to passing tests.
- **Exit criteria:** All PRD acceptance criteria have corresponding passing tests. Coverage meets threshold.

#### Phase 6: SHIP (`/ship`)
- **Agent:** `release-manager`
- **Skill:** `git-workflow`, `release`
- **Knowledge loaded:** `hook-patterns.md` (for CI/CD hooks)
- **Process:** Runs release checklist. Tags version. Generates changelog. Creates release PR or deploys.
- **Handoff artifact:** `.omc/artifacts/06-ship/release-notes.md` — Version, changelog, deploy status.
- **Exit criteria:** Version tagged. Changelog generated. Deployed or PR created.

### 4.5 — CLAUDE.md Strategy

The root `CLAUDE.md` file is the brain of the system. It must:

1. **Detect task type** from user input and route to the correct phase
2. **Load knowledge** relevant to the current phase from `knowledge/`
3. **Enforce gates** — prevent skipping phases without explicit override
4. **Track state** — know which phase the project is in, what artifacts exist
5. **Delegate intelligently** — use subagents for focused work, teams for parallel work
6. **Manage context** — compact at 50%, clear between phases, preserve memory

The CLAUDE.md should reference all skills, agents, and commands, and define the routing logic that decides which phase to invoke based on what the user says and what artifacts already exist.

---

## 5. Implementation Plan

Execute in this order:

### Step 1: Scaffold
Create the directory structure above. Write placeholder files with TODO comments describing what each file should contain.

### Step 2: CLAUDE.md
Write the master CLAUDE.md with routing logic, phase detection, and knowledge loading rules. This is the most important file — get it right first.

### Step 3: Pipeline Output Specs
Write every `output-spec.md` file. These define what each phase must produce. They are the contract between phases and must be precise.

### Step 4: Commands
Write the slash command `.md` files for each phase. Each command should describe what it does, what knowledge to load, which agent to invoke, and what the exit criteria are.

### Step 5: Agents
Write the agent `.md` files with proper YAML frontmatter (tools, model, permissionMode, maxTurns, skills).

### Step 6: Skills
Write the skill `SKILL.md` files with frontmatter including pipeline handoff contracts.

### Step 7: Knowledge Base
Distill content from the 5 source repos into the `knowledge/` directory. This is curation work — read the source material, extract what's useful, rewrite it in a concise agent-readable format.

### Step 8: Templates
Create starter templates for common project types.

### Step 9: Hooks
Write lifecycle hooks for session management, progress tracking, and gate enforcement.

### Step 10: Test the Pipeline
Run a real project through the full pipeline end-to-end. Identify gaps. Iterate.

---

## 6. Critical Design Decisions

1. **OMC is a reference, not a dependency.** The super repo should be self-contained. Study OMC's patterns but don't require it as a plugin. If the user also has OMC installed, the two should not conflict.

2. **Knowledge is injected, not always-loaded.** CS fundamentals and patterns are only loaded into context when relevant to the current phase. Loading everything always wastes context window.

3. **Gates are enforced by default, overridable explicitly.** The pipeline should prevent skipping from idea to build without planning and architecture. But experienced users should be able to say "skip to build" if they already have a spec.

4. **Handoff artifacts are the source of truth.** Each phase reads the previous phase's artifact. If the artifact doesn't exist or is incomplete, the phase refuses to start. This creates a paper trail and makes the pipeline resumable.

5. **The pipeline is phase-resumable.** If a session dies mid-build, the user should be able to say `/build` again and resume from where they left off, because state is in `.omc/`.

6. **Templates are opinionated.** The project type templates should make real tech stack choices (e.g., web-app = Next.js + Tailwind + Supabase), not be generic. Opinionated defaults are faster than blank canvases.

---

## 7. Success Criteria

The super repo is done when:

- [ ] A user can clone it, run setup, and start a new project with `/idea`
- [ ] The full pipeline `/idea` → `/plan` → `/architect` → `/build` → `/test` → `/ship` works end-to-end
- [ ] Each phase produces a clear handoff artifact that the next phase consumes
- [ ] Gates prevent phase-skipping without explicit override
- [ ] Knowledge from all 5 source repos is distilled and accessible to agents at the right moments
- [ ] At least 3 project type templates exist and work
- [ ] The system works with vanilla Claude Code (no OMC dependency required)
- [ ] A developer unfamiliar with the system can read the README and start using it within 10 minutes

---

## 8. What NOT to Build

- **Not a tutorial.** This is a tool, not a course. Documentation exists to explain how to use it, not to teach Claude Code basics.
- **Not a fork of OMC.** OMC is inspiration and reference. The super repo has its own structure and opinions.
- **Not a monorepo of the 5 source repos.** We are synthesizing, not aggregating. No git submodules pointing to the originals.
- **Not a framework.** It is a project-level configuration that lives inside a real project. It doesn't abstract away Claude Code — it configures it.

---

*End of context briefing. Begin with Step 1: Scaffold.*
