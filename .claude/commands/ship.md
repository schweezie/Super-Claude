<!-- TODO: /ship — Entry point for the SHIP phase.
     Reads .omc/artifacts/05-test/test-report.md as input.
     Invokes the release-manager agent with git-workflow and release skills.
     Runs release checklist, tags version, generates changelog,
     creates release PR or deploys.
     Produces: .omc/artifacts/06-ship/release-notes.md
     Gate: Requires test-report.md with all tests passing. -->
