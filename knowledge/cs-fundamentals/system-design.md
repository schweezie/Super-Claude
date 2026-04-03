# System Design — Agent Quick Reference

> For agents making architecture and infrastructure decisions. Focus: when to use what, key tradeoffs.

## System Design Process

1. **Clarify scope** — Define use cases, constraints, and scale (requests/sec, data volume, read/write ratio)
2. **Estimate constraints** — Back-of-envelope math: storage over 5 years, bandwidth, QPS
3. **Design high-level** — Service layers, data flow, APIs, storage
4. **Deep dive** — Bottlenecks, scaling strategies, failure modes

## Core Building Blocks

| Component | Solves | Key Pattern |
|-----------|--------|-------------|
| **Load Balancer** | Distribute traffic across servers | Round-robin, least-connections, consistent hashing |
| **Cache** | Reduce latency + DB load | Read-through, write-behind, write-through |
| **CDN** | Serve static content near users | Push (preload) vs pull (on-demand) |
| **Message Queue** | Decouple producers from consumers | Async processing, backpressure, retry |
| **API Gateway** | Single entry point, routing | Rate limiting, auth, request transformation |
| **Reverse Proxy** | Hide backend topology | SSL termination, compression, caching |

## Database Decision Framework

| Need | Choose | Why |
|------|--------|-----|
| Complex queries, joins, ACID | **Relational (SQL)** | Strong consistency, mature tooling |
| Flexible schema, high write throughput | **Document DB** (MongoDB) | Schema-per-document, horizontal scale |
| Simple key-value at extreme scale | **Key-Value** (Redis, DynamoDB) | O(1) lookups, easy partitioning |
| Relationships/graph traversal | **Graph DB** (Neo4j) | Efficient multi-hop queries |
| Time-series / append-heavy | **Time-Series DB** (InfluxDB) | Optimized for ordered writes + range queries |
| Full-text search | **Search Engine** (Elasticsearch) | Inverted index, relevance scoring |

## Scaling Patterns

- **Vertical scaling:** Bigger machine. Simple but has a ceiling.
- **Horizontal scaling:** More machines. Requires stateless services or shared state.
- **Database sharding:** Partition data by key (user_id, geo). Tradeoff: cross-shard queries are expensive.
- **Read replicas:** Route reads to replicas, writes to primary. Tradeoff: replication lag = eventual consistency.
- **Caching layers:** L1 (app memory) → L2 (Redis/Memcached) → L3 (CDN). Tradeoff: cache invalidation complexity.

## Caching Strategies

| Strategy | How | When |
|----------|-----|------|
| **Cache-aside** | App checks cache first, loads from DB on miss | General purpose, most common |
| **Read-through** | Cache loads from DB automatically on miss | When cache library supports it |
| **Write-through** | Write to cache and DB simultaneously | Need strong consistency |
| **Write-behind** | Write to cache, async flush to DB | High write throughput, tolerate some lag |

**Invalidation:** TTL (time-based), event-driven (invalidate on write), versioning. TTL is simplest; event-driven is most consistent.

## Key Tradeoffs (CAP + Beyond)

| Tradeoff | Option A | Option B | Decision Guide |
|----------|----------|----------|---------------|
| **Consistency vs Availability** | Strong consistency (CP) | High availability (AP) | Banking → CP; Social feed → AP |
| **Latency vs Throughput** | Optimize per-request time | Optimize total requests/sec | Interactive → latency; Batch → throughput |
| **SQL vs NoSQL** | Schema enforcement, joins | Flexible schema, horizontal scale | Complex relations → SQL; Simple access patterns → NoSQL |
| **Sync vs Async** | Immediate response | Queue-based processing | User-facing → sync; Background work → async |
| **Monolith vs Microservices** | Simple deployment, shared state | Independent scaling, team autonomy | Small team/early stage → monolith; Large org → microservices |

## Consensus & Distributed Systems

- **CAP Theorem:** In a partition, choose consistency (reject requests) or availability (serve stale data). In practice, tune per-operation.
- **Consistent Hashing:** Distribute data across nodes with minimal redistribution when nodes join/leave. Essential for caches and DHTs.
- **Raft/Paxos:** Leader election + log replication for strong consistency across replicas. Use managed services (etcd, ZooKeeper) unless building infrastructure.

## Numbers to Know

| Operation | Latency |
|-----------|---------|
| L1 cache | ~1 ns |
| L2 cache | ~4 ns |
| RAM access | ~100 ns |
| SSD random read | ~16 μs |
| HDD seek | ~4 ms |
| Same-datacenter round trip | ~0.5 ms |
| Cross-continent round trip | ~150 ms |
