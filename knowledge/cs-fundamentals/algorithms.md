# Algorithms — Agent Quick Reference

> For agents choosing algorithms for implementation, optimization, and system design decisions.

## Sorting Algorithms

| Algorithm | Best | Average | Worst | Space | Stable? | When to Use |
|-----------|------|---------|-------|-------|---------|-------------|
| **Quicksort** | O(n log n) | O(n log n) | O(n²) | O(log n) | No | General purpose; fastest in practice for most data |
| **Mergesort** | O(n log n) | O(n log n) | O(n log n) | O(n) | Yes | Need stability or guaranteed O(n log n); linked lists |
| **Heapsort** | O(n log n) | O(n log n) | O(n log n) | O(1) | No | Guaranteed O(n log n) with O(1) extra space |
| **Radix Sort** | O(nk) | O(nk) | O(nk) | O(n+k) | Yes | Fixed-length integers/strings; k=digits, beats comparison sorts |
| **Insertion Sort** | O(n) | O(n²) | O(n²) | O(1) | Yes | Small n (<16) or nearly-sorted data; used as base case |

**Rule of thumb:** Use language stdlib sort (typically introsort: quicksort + heapsort fallback). Only hand-roll for special constraints.

## Searching Algorithms

| Algorithm | Time | Space | When to Use |
|-----------|------|-------|-------------|
| **Binary Search** | O(log n) | O(1) | Sorted array; find element, boundary, or insertion point |
| **BFS** | O(V+E) | O(V) | Shortest path in unweighted graphs; level-order traversal |
| **DFS** | O(V+E) | O(V) | Cycle detection, topological sort, connected components |

**BFS vs DFS:** BFS finds shortest path (unweighted) and explores by layers. DFS uses less memory on wide graphs and naturally handles backtracking problems.

## Graph Algorithms

| Algorithm | Time | Space | What It Solves |
|-----------|------|-------|---------------|
| **Dijkstra** | O((V+E) log V) | O(V) | Shortest path from single source, non-negative weights |
| **Bellman-Ford** | O(VE) | O(V) | Shortest path with negative weights; detects negative cycles |
| **A*** | O(E) best case | O(V) | Shortest path with heuristic; optimal when heuristic is admissible |
| **Topological Sort** | O(V+E) | O(V) | Linear ordering of DAG nodes; dependency resolution |
| **Kruskal/Prim** | O(E log V) | O(V) | Minimum spanning tree |

**Dijkstra vs A*:** Use Dijkstra for general shortest-path. Use A* when you have a good heuristic (e.g., geographic distance). A* reduces explored nodes but requires an admissible heuristic.

## Dynamic Programming Patterns

DP applies when a problem has **overlapping subproblems** and **optimal substructure**.

| Pattern | Example Problems | Approach |
|---------|-----------------|----------|
| **1D sequence** | Fibonacci, climbing stairs, house robber | dp[i] depends on dp[i-1], dp[i-2] |
| **2D grid/string** | Edit distance, LCS, knapsack | dp[i][j] from adjacent cells |
| **Interval** | Matrix chain, burst balloons | dp[i][j] = best for range [i,j] |
| **State machine** | Stock trading, regex matching | States transition based on input |

**Top-down vs Bottom-up:** Top-down (memoization) is easier to write; bottom-up (tabulation) avoids recursion overhead. Start top-down, convert to bottom-up if stack depth is a concern.

## Divide and Conquer

Splits problem into independent subproblems, solves recursively, combines results.

| Application | Time | Key Insight |
|-------------|------|-------------|
| Merge sort | O(n log n) | Divide array, sort halves, merge |
| Binary search | O(log n) | Eliminate half the search space |
| Closest pair of points | O(n log n) | Divide plane, only check strip near boundary |
| Strassen matrix multiply | O(n^2.81) | Reduce 8 multiplications to 7 |

**vs DP:** Divide-and-conquer subproblems are independent (no overlap). If subproblems overlap, use DP with memoization instead.
