# SESSION 6B — Extract from coding-interview-university (System Design + Design Patterns)

You are working on the "super repo" project. Read AGENT_STATE.md and CHECKLIST.md first to understand where we are.

## Task
Continue extracting from the already-cloned `references/coding-interview-university/` repo. This session covers the remaining two CS fundamentals files.

## What to extract — SYSTEM DESIGN
Read only the sections about: scalability, load balancing, caching (strategies, invalidation), databases (SQL vs NoSQL, sharding, replication), message queues, CDNs, API design, microservices vs monolith.

For each topic, distill:
- What problem it solves
- Key patterns and when to apply them
- Tradeoffs (consistency vs availability, latency vs throughput)
- Decision framework for choosing between options

Write to: `knowledge/cs-fundamentals/system-design.md`

## What to extract — DESIGN PATTERNS
Read only the sections about common software design patterns. Cover at minimum: Factory, Singleton, Observer, Strategy, Command, Adapter, Decorator, Facade, Repository, Dependency Injection.

For each pattern, distill:
- What problem it solves (1 sentence)
- When to use it
- When NOT to use it
- Simple structure description (no UML — just "class A delegates to class B" style)

Write to: `knowledge/cs-fundamentals/design-patterns.md`

## Rules
- Each file MUST be under 2000 tokens. Quick-reference cards, not textbooks.
- Focus on decision-making: "when to use X" is more valuable than "how X works internally."
- After writing each file, update CHECKLIST.md (tasks 7.4, 7.5) and AGENT_STATE.md.
- After both files are done, validate that ALL knowledge files created across Sessions 2–6 exist and are under 2000 tokens each (task 7.18). Update AGENT_STATE.md to mark Step 7 progress.
