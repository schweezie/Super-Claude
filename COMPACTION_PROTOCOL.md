# Compaction Protocol

> **This file defines how coding agents manage context and survive compaction.**
> Reference this in the root CLAUDE.md so every agent session follows these rules.
> Best practices sourced from oh-my-claudecode, claude-code-best-practice, and claude-howto.

---

## Rule 1: Compact at 200k Tokens — No Exceptions

Monitor context usage with `/context`. When you hit **200k tokens** (approximately 50% of a 400k context window), **immediately compact**:

```
/compact
```

Do NOT wait until Claude warns you. Do NOT push past 200k hoping to finish one more task. Compaction quality degrades as context grows — early compaction preserves better summaries.

**Why 50%:** From claude-code-best-practice: "avoid agent dumb zone, do manual /compact at max 50%." Beyond 50%, the model's ability to reason about earlier context degrades significantly. The agent becomes unreliable.

---

## Rule 2: Save State BEFORE Compacting

Before running `/compact`, you MUST:

1. **Finish the current atomic task** (don't compact mid-file-creation)
2. **Update `AGENT_STATE.md`** with:
   - Current step and task number
   - Last action taken
   - Last file created/modified
   - Any active decisions or context that must survive
   - Files created this session
3. **Update `CHECKLIST.md`** — check off completed tasks
4. **Log the compaction** in the Compaction Log table in `AGENT_STATE.md`
5. **Commit changes** to git: `git add -A && git commit -m "Pre-compaction checkpoint: task X.Y"`

**Then** run `/compact`.

---

## Rule 3: Recovery After Compaction

After compaction completes, the agent MUST execute this sequence before doing anything else:

```
STEP 1: cat AGENT_STATE.md          ← Know where you are
STEP 2: cat CHECKLIST.md            ← Know what's done and what's next
STEP 3: cat SUPER_REPO_CONTEXT.md   ← Refresh on project goals (if needed)
STEP 4: cat COMPACTION_PROTOCOL.md  ← Refresh on compaction rules (RECOMMENDED — this file contains 10 rules, not all of which are summarized elsewhere)
STEP 5: Resume from NEXT_ACTION in AGENT_STATE.md
```

Do NOT try to remember what you were doing from the compacted summary. The summary is lossy. The state files are lossless. **Trust the files, not the summary.**

---

## Rule 4: Use /clear When Switching Phases

When transitioning between major pipeline phases (e.g., finishing Step 3: Output Specs and starting Step 4: Commands), use `/clear` instead of `/compact`:

```
/clear
```

This gives you a fresh context window. Immediately re-read state files after `/clear` using the same recovery sequence from Rule 3.

**Why:** Different steps require different mental models. Carrying stale context from the knowledge base curation step into the hooks implementation step wastes tokens and confuses routing.

---

## Rule 5: Git Commits as Checkpoints

Commit after every completed step (not every task — that's too noisy):

```bash
git add -A && git commit -m "Step N complete: [step name]"
```

This creates recovery points. If something goes catastrophically wrong, you can `git reset` to the last good step.

Commit more frequently during Step 7 (Knowledge Base Curation) since that step involves many independent files that each take significant work.

---

## Rule 6: Session Start Protocol

Every new Claude Code session (including after machine restart, new terminal, or `/resume`) MUST begin with:

```
cat AGENT_STATE.md
cat CHECKLIST.md
```

Only then should the agent begin work. This applies even if the agent "remembers" context — always verify against the files.

---

## Rule 7: Token Budget Per Step

Rough token budgets to stay within compaction windows:

| Step | Estimated Tokens | Compactions Expected |
|------|-----------------|---------------------|
| 1: Scaffold | ~30k | 0 |
| 2: CLAUDE.md | ~80k | 0 |
| 3: Output Specs | ~60k | 0 |
| 4: Commands | ~80k | 0 |
| 5: Agents | ~80k | 0 |
| 6: Skills | ~100k | 0-1 |
| 7: Knowledge Base | ~400k+ | 2-3 |
| 8: Templates | ~150k | 1 |
| 9: Hooks | ~80k | 0 |
| 10: E2E Testing | ~300k+ | 2-3 |

Steps 7 and 10 are the heaviest. Plan for multiple compactions. Step 7 in particular requires reading external repos, which consumes large amounts of context — consider using `/clear` between each knowledge category (cs-fundamentals, claude-code-patterns, harness-internals).

---

## Rule 8: Multi-Agent Awareness

If multiple agents are running in parallel (e.g., during Step 7 with different knowledge categories):

- Each agent MUST write to its own section of `AGENT_STATE.md`
- Use file locking or sequential writes to avoid race conditions on `CHECKLIST.md`
- `/rename` each session descriptively: `[KB-cs-fundamentals]`, `[KB-claude-patterns]`, etc.
- From best-practice: "label each instance when running multiple Claudes simultaneously"

---

## Rule 9: What To Write in Active Decisions

The "Active Decisions" section of `AGENT_STATE.md` should capture:

- **Architecture choices** made during implementation that deviate from the plan
- **Blockers** encountered (e.g., a repo is unavailable, a pattern doesn't work)
- **Dependencies** between tasks discovered during work
- **Questions** for the project owner that need resolution
- **Tradeoffs** chosen (e.g., "chose X over Y because Z")

Clear resolved items when moving to a new step. Keep unresolved items across steps.

---

## Rule 10: Emergency Recovery

If state files are corrupted or missing:

1. Check git log: `git log --oneline -20`
2. Find last good commit with state files
3. Restore: `git checkout <commit> -- AGENT_STATE.md CHECKLIST.md`
4. Scan filesystem to verify what actually exists vs what the checklist says
5. Reconcile and continue

If git history is also gone, scan the filesystem manually:

```bash
find . -name "*.md" -o -name "*.js" -o -name "*.json" | head -100
```

Rebuild state from what exists on disk.

---

## CLAUDE.md Integration

Add this block to the root `CLAUDE.md` to enforce the protocol:

```markdown
## Compaction & State Protocol

This project uses file-based state tracking to survive compaction.

- **AGENT_STATE.md** — Current progress, next action, active decisions, pre/post compaction checklists. READ FIRST after any compaction or session start.
- **CHECKLIST.md** — Granular task list. Mark `[x]` after each completion.
- **SUPER_REPO_CONTEXT.md** — Full project context and architecture.
- **COMPACTION_PROTOCOL.md** — Full compaction rules (all 10 rules) and recovery procedures. Re-read after compaction if rules are unclear.

### Compaction Rules (all 10)
1. Compact at 200k tokens (50% context). Never later.
2. Before compacting: finish current atomic task, update AGENT_STATE.md, update CHECKLIST.md, log compaction, git commit. THEN /compact.
3. After compacting: read AGENT_STATE.md → CHECKLIST.md → SUPER_REPO_CONTEXT.md (optional) → COMPACTION_PROTOCOL.md (recommended) → resume from NEXT_ACTION.
4. Use /clear when switching between major pipeline steps (not /compact). Run recovery sequence after /clear.
5. Git commit after every completed step (not every task).
6. Session start: always read AGENT_STATE.md → CHECKLIST.md before beginning work.
7. Token budgets per step — plan compactions for heavy steps (7, 10).
8. Multi-agent sessions: each agent writes to its own section, use file locking on CHECKLIST.md.
9. Active decisions section in AGENT_STATE.md captures architecture choices, blockers, tradeoffs.
10. Emergency recovery: restore state files from git history if corrupted. If git is gone, rebuild from filesystem scan.
```

---

*This protocol is non-negotiable. Skipping any rule risks losing progress and wasting tokens.*