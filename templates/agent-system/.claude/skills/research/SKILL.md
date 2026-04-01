---
name: research
description: Structured research workflow for exploring a codebase or topic before implementation.
trigger: When the coordinator needs to understand the codebase before implementing a change.
---

# Research Skill

Follow these steps in order:

## Step 1: Understand the Goal
Read the task description carefully. Identify the key questions that need answers before implementation can begin.

## Step 2: Map the Terrain
Use Glob to find relevant files. Start broad, then narrow:
- Look for files related to the task by name pattern
- Look for the entry points (index files, main modules, route files)

## Step 3: Read Key Files
Read the most relevant files. Focus on:
- Interfaces and type definitions
- Function signatures and their docstrings
- Existing patterns that the new code should follow

## Step 4: Search for Patterns
Use Grep to find how similar things are done elsewhere in the codebase. New code should match existing conventions.

## Step 5: Write Findings
Write your findings to `.state/research-notes.md`. Structure:
```
# Research: [task name]
## Key Files
- [path]: [what it does]
## Patterns to Follow
- [pattern]: [example location]
## Open Questions
- [question the implementer should answer]
```

## Step 6: Return Summary
Summarize findings to the coordinator so it can decide next steps.
