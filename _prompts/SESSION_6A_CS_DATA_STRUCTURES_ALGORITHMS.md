# SESSION 6A — Extract from coding-interview-university (Data Structures + Algorithms)

You are working on the "super repo" project. Read AGENT_STATE.md and CHECKLIST.md first to understand where we are.

## Task
Clone https://github.com/jwasham/coding-interview-university.git into a `references/` directory (if not already there). This is a massive repo — DO NOT try to read all of it. Extract only what's needed for two specific knowledge files.

## What to extract — DATA STRUCTURES
Read only the sections about: arrays, linked lists, stacks, queues, hash tables, trees (binary, BST, AVL, red-black), heaps, graphs, tries.

For each data structure, distill:
- What it is (1 sentence)
- When to use it vs alternatives
- Big-O for common operations (insert, delete, search, access)
- Key tradeoffs (memory vs speed, ordered vs unordered)

Write to: `knowledge/cs-fundamentals/data-structures.md`

## What to extract — ALGORITHMS
Read only the sections about: sorting (quick, merge, heap, radix), searching (binary search, BFS, DFS), graph algorithms (Dijkstra, A*, topological sort), dynamic programming patterns, divide and conquer.

For each algorithm/pattern, distill:
- What it solves (1 sentence)
- Time and space complexity
- When to choose it over alternatives
- Common application patterns

Write to: `knowledge/cs-fundamentals/algorithms.md`

## Rules
- Each file MUST be under 2000 tokens. These are quick-reference cards for agents making design decisions, not textbooks.
- Use tables for Big-O comparisons where possible — they're dense and scannable.
- Do NOT read the entire repo. Use the README.md table of contents to navigate directly to relevant sections.
- After writing each file, update CHECKLIST.md (tasks 7.1, 7.2, 7.3) and AGENT_STATE.md.
- If you approach 50% context (100k tokens), save state and /compact before continuing.
