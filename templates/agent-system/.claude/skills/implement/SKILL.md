---
name: implement
description: Structured implementation workflow for making changes to the codebase.
trigger: When the coordinator has a clear implementation task and research is complete.
---

# Implement Skill

Follow these steps in order:

## Step 1: Read the Input
Read `.state/research-notes.md` if it exists — use prior research rather than re-exploring.
Read the specific files you will modify before touching them.

## Step 2: Plan the Change
Before writing any code, outline:
- Which files you will create or modify
- What each change does
- Any dependencies between changes (do X before Y)

## Step 3: Implement
Make the changes in dependency order. After each file:
- Verify the change looks correct before moving to the next

## Step 4: Verify
If the project has tests, run them. If a linter is configured, run it.
Fix any failures before reporting completion.

## Step 5: Write State
Update `.state/current-task.md`:
```
# Task: [task name]
## Status: complete
## Changes Made
- [file]: [what changed]
## Notes
- [anything the reviewer or coordinator should know]
```

## Step 6: Report
Return a concise summary of what was done to the coordinator.
