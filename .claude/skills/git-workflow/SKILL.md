---
name: git-workflow
description: Manages git operations for the SHIP phase — branching, committing, tagging, and PR creation. Use after verification to prepare the codebase for release.
level: 4
aliases: [git, branch, commit, pr]
argument-hint: "[version]"
agent: release-manager
model: sonnet
pipeline: [deep-interview, prd-generator, system-design, parallel-build, tdd, verification, git-workflow, release]
next-skill: release
handoff: git tags and branches in the repository
---

<Purpose>
Prepare the codebase for release by managing git operations: ensure a clean working tree, create appropriate branches/tags, commit all changes with descriptive messages, and optionally create a pull request. This skill handles the git mechanics; the release skill handles documentation and deployment.
</Purpose>

<Use_When>
- The `/ship` command is invoked
- `.omc/artifacts/05-test/test-report.md` exists with overall result PASS
- User says "ship", "deploy", "release", "tag", or "publish"
- Transitioning from TEST to SHIP in the pipeline
</Use_When>

<Do_Not_Use_When>
- Test report shows FAIL or has open critical/high bugs
- User wants to commit code mid-development (just commit directly)
- User wants to manage git manually
</Do_Not_Use_When>

<Steps>

## Step 1: Load Inputs

1. Read `.omc/artifacts/05-test/test-report.md` — confirm overall result is PASS
2. Read `.omc/artifacts/04-build/build-report.md` — get implementation summary
3. Read `.omc/state/pipeline-state.json` — get project name
4. Check git status — ensure working tree state is known

## Step 2: Pre-Flight Checks

1. **Test status:** Confirm test report says PASS with no critical/high bugs
2. **Working tree:** Run `git status` — note untracked and modified files
3. **Branch:** Identify current branch. If on main/master, consider creating a release branch
4. **Remote:** Check if remote is configured (`git remote -v`)

If test report is FAIL: stop and direct user to fix issues first.

## Step 3: Stage and Commit

1. Review all changes with `git diff` and `git status`
2. Stage relevant files (exclude `.omc/` which is gitignored, exclude secrets)
3. Create commit(s) with descriptive messages:
   - Use conventional commit format: `feat:`, `fix:`, `chore:`, `docs:`
   - Reference the project name and phase
   - Group related changes into logical commits

## Step 4: Version Tagging

1. Determine version number:
   - If first release: `v1.0.0`
   - If `$ARGUMENTS` provides a version, use that
   - Otherwise, use semver based on changes (feat = minor, fix = patch)
2. Create annotated git tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`

## Step 5: Branch Management (Optional)

If the project has a remote and the user wants a PR:

1. Create release branch if not already on one: `git checkout -b release/vX.Y.Z`
2. Push branch to remote: `git push -u origin release/vX.Y.Z`
3. Create PR using `gh pr create` (if gh CLI available)

Ask user before pushing or creating PRs — these are visible to others.

## Step 6: Hand Off to Release

Pass forward to the release skill:
- Version number
- Tag name
- Branch name
- Commit hash(es)
- Whether a PR was created

</Steps>

<Tool_Usage>
- **Read**: Load test report, build report, pipeline state
- **Bash**: All git operations (status, add, commit, tag, push, gh pr create)
- **Glob**: Check for files that shouldn't be committed (secrets, large binaries)
- **Grep**: Search for hardcoded secrets before committing
</Tool_Usage>

<Escalation_And_Stop_Conditions>
- **Stop if** test report doesn't exist or shows FAIL — direct user to run `/test` first
- **Stop if** there are merge conflicts — present conflicts and ask user to resolve
- **Escalate before** any push to remote — confirm with user
- **Escalate before** any PR creation — confirm with user
- **Escalate if** working tree has files that look like secrets (.env, credentials) — ask before staging
</Escalation_And_Stop_Conditions>

<Final_Checklist>
- [ ] Test report confirms PASS
- [ ] All relevant files committed
- [ ] No secrets or credentials in committed files
- [ ] Version tag created (semver format)
- [ ] Commit messages are descriptive
- [ ] User confirmed before any push/PR operations
- [ ] Version, tag, and branch info ready for release skill
</Final_Checklist>
