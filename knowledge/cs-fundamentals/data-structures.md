# Data Structures — Agent Quick Reference

> For agents making design decisions about data storage, collection types, and data organization.

## Core Structures — Big-O Comparison

| Structure | Access | Search | Insert | Delete | Space | Ordered? |
|-----------|--------|--------|--------|--------|-------|----------|
| **Array** | O(1) | O(n) | O(n)* | O(n) | O(n) | By index |
| **Dynamic Array** | O(1) | O(n) | O(1)† | O(n) | O(n) | By index |
| **Linked List (singly)** | O(n) | O(n) | O(1)‡ | O(1)‡ | O(n) | No |
| **Doubly Linked List** | O(n) | O(n) | O(1)‡ | O(1)‡ | O(n) | No |
| **Stack** | O(n) | O(n) | O(1) | O(1) | O(n) | LIFO |
| **Queue** | O(n) | O(n) | O(1) | O(1) | O(n) | FIFO |
| **Hash Table** | — | O(1)§ | O(1)§ | O(1)§ | O(n) | No |
| **BST (balanced)** | O(log n) | O(log n) | O(log n) | O(log n) | O(n) | Yes |
| **BST (degenerate)** | O(n) | O(n) | O(n) | O(n) | O(n) | Yes |
| **Min/Max Heap** | O(1)¶ | O(n) | O(log n) | O(log n) | O(n) | Partial |
| **Trie** | — | O(k) | O(k) | O(k) | O(n·k) | By prefix |
| **Graph (adj list)** | — | O(V+E) | O(1) | O(E) | O(V+E) | No |
| **Graph (adj matrix)** | O(1) | O(V) | O(1) | O(1) | O(V²) | No |

*Insert at arbitrary position. †Amortized append. ‡At known position. §Average case; O(n) worst. ¶Min or max only. k=key length.

## When to Use What

| Need | Use | Why |
|------|-----|-----|
| Fast random access by index | Array / Dynamic Array | O(1) access, cache-friendly |
| Fast insert/delete at ends | Deque / Doubly Linked List | O(1) at both ends |
| Fast key-value lookup | Hash Table | O(1) average lookup |
| Ordered iteration + fast search | Balanced BST (AVL/Red-Black) | O(log n) ops + in-order traversal |
| Priority/min/max extraction | Binary Heap | O(1) peek, O(log n) extract |
| LIFO processing (undo, DFS) | Stack | Natural recursion replacement |
| FIFO processing (BFS, scheduling) | Queue | Preserves arrival order |
| Prefix matching / autocomplete | Trie | O(k) prefix search, shared prefixes |
| Relationships/connections | Graph | Models networks, dependencies |

## Key Tradeoffs

- **Array vs Linked List:** Arrays have cache locality and O(1) access; linked lists have O(1) insert/delete at known positions but poor cache behavior. Prefer arrays unless frequent mid-list mutations.
- **Hash Table vs BST:** Hash tables are faster for exact lookup (O(1) vs O(log n)) but unordered. BSTs support range queries and ordered traversal.
- **AVL vs Red-Black Tree:** AVL is more strictly balanced (faster lookups); red-black has faster insertions/deletions (fewer rotations). Most stdlib trees use red-black.
- **Adjacency List vs Matrix:** Lists are space-efficient for sparse graphs O(V+E); matrices allow O(1) edge lookup but cost O(V²) space. Use lists unless the graph is dense.
- **Heap vs Sorted Array:** Heaps offer O(log n) insert vs O(n) for sorted arrays, but only give access to min/max. Use heaps for priority queues, sorted arrays for binary search.
