<!-- TODO: /full-pipeline — Chains all 6 phases sequentially with gate enforcement.
     Runs: /idea → /plan → /architect → /build → /test → /ship
     Each phase must satisfy its output-spec before the next phase starts.
     Supports resumption: detects existing artifacts and skips completed phases.
     Uses /clear between phases to manage context window.
     Tracks overall pipeline progress in .omc/state/. -->
