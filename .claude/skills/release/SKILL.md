---
name: release
description: Generates release notes, changelog, and deployment documentation to complete the SHIP phase. Use after git-workflow to finalize the release.
level: 4
aliases: [release-notes, changelog, ship-release]
argument-hint: "[version]"
agent: release-manager
model: sonnet
pipeline: [deep-interview, prd-generator, system-design, parallel-build, tdd, verification, git-workflow, release]
next-skill: null
handoff: .omc/artifacts/06-ship/release-notes.md
---

<Purpose>
Generate the final release artifact: release notes with version, changelog, test status, deployment evidence, known issues, and follow-up items. This is the terminal skill in the pipeline — completing it means the project is shipped.
</Purpose>

<Use_When>
- Called automatically after git-workflow completes
- Git tag and commits are in place
- The `/ship` command invokes git-workflow then release in sequence
</Use_When>

<Do_Not_Use_When>
- Git operations haven't been done yet (run git-workflow first)
- User wants to deploy to a specific environment (this skill documents, it doesn't deploy infrastructure)
</Do_Not_Use_When>

<Steps>

## Step 1: Load Inputs

1. Read `.omc/artifacts/05-test/test-report.md` — extract test results, coverage, bugs
2. Read `.omc/artifacts/04-build/build-report.md` — extract deferred items, implementation summary
3. Read `.omc/state/pipeline-state.json` — extract project name, timestamps
4. Get git info: latest tag, recent commits, branch name

## Step 2: Determine Version

1. Read the git tag created by git-workflow
2. If no tag exists, determine from `$ARGUMENTS` or ask the user
3. Validate semver format: MAJOR.MINOR.PATCH

## Step 3: Build Changelog

Compile changes from git commits and build report:

Group by category:
- **Added:** New features and capabilities
- **Changed:** Modifications to existing behavior
- **Fixed:** Bug fixes
- **Removed:** Removed features or deprecated items

At least one category must have entries. Each entry is a concise description.

## Step 4: Summarize Test Status

From the test report:
- Overall result: PASS (required)
- Coverage percentage
- Open bugs summary: confirm no critical/high open
- Reference to full test report path

## Step 5: Document Deployment

Record what was done to release:
- Git tag created (name)
- PR created (URL, if applicable)
- Package published (registry, if applicable)
- Deployed to environment (URL, if applicable)
- Manual release (instructions, if applicable)

At least one deployment action must have evidence.

## Step 6: Compile Known Issues

From test report bugs (medium/low) and build report deferred items:
- List each with severity and workaround
- "None" is acceptable if everything is clean

## Step 7: Suggest Follow-Up

From deferred items across build and test phases:
- Features not implemented (P1/P2 from PRD)
- Tests not written
- Technical debt noted during review
- "No follow-up items" is acceptable

## Step 8: Write Release Notes

Assemble with these exact H2 sections:
- `## Release Info` (version, date, project name, one-line summary)
- `## Changelog` (categorized changes)
- `## Test Status` (result, coverage, bug summary)
- `## Deployment` (what was done, evidence)
- `## Known Issues` (open items with workarounds)
- `## What's Next` (follow-up suggestions)

Write to `.omc/artifacts/06-ship/release-notes.md`.

## Step 9: Finalize Pipeline

Update `.omc/state/pipeline-state.json`:
- `current_phase`: "ship"
- `phase_status`: "completed"
- Add "ship" to `phases_completed`

Announce: "Release complete. Pipeline finished. Release notes at `.omc/artifacts/06-ship/release-notes.md`."

</Steps>

<Tool_Usage>
- **Read**: Load test report, build report, pipeline state
- **Bash**: Git commands to get tag info, commit log, branch info
- **Write**: Write the release notes artifact
- **Glob**: Find artifacts from previous phases
</Tool_Usage>

<Escalation_And_Stop_Conditions>
- **Stop if** git tag doesn't exist — run git-workflow first
- **Stop if** test report shows FAIL — cannot release failing code
- **Escalate if** user wants to publish to a package registry — confirm the action and credentials
- **Escalate if** deployment requires infrastructure changes — present the steps and confirm
</Escalation_And_Stop_Conditions>

<Final_Checklist>
- [ ] All 6 H2 sections present and non-empty
- [ ] Version follows semver format
- [ ] Test status confirms PASS with no critical/high bugs
- [ ] Changelog has at least one entry
- [ ] Deployment section has evidence of action taken
- [ ] Known issues documented (or "None")
- [ ] Follow-up items listed (or "No follow-up items")
- [ ] Artifact written to `.omc/artifacts/06-ship/release-notes.md`
- [ ] Pipeline state updated to completed
- [ ] Pipeline complete announcement made
</Final_Checklist>
