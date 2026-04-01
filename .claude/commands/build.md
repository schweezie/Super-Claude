<!-- TODO: /build — Entry point for the BUILD phase.
     Reads .omc/artifacts/03-architect/architecture.md as input.
     Invokes the executor agent (primary) and reviewer agent (quality gate)
     with parallel-build and verification skills.
     Decomposes architecture into parallelizable work units,
     spins up Agent Teams or subagents.
     Produces: working code + .omc/artifacts/04-build/build-report.md
     Gate: Requires architecture.md to exist. -->
