#!/usr/bin/env node
/**
 * Stop Hook — Completion Check & State Persistence
 *
 * Fires when the agent is about to stop. Saves current pipeline state
 * and checks whether the active phase's output artifact exists.
 * If an artifact is expected but missing, injects a nudge (max 3 times
 * per phase to prevent infinite loops).
 *
 * Input (stdin JSON):
 *   { session_id, stop_reason, hook_event_name, ... }
 *
 * Output (stdout JSON):
 *   { continue: true }                          — allow stop
 *   { continue: false, stopReason: "..." }      — nudge to continue
 */

const fs = require("fs");
const path = require("path");

const PROJECT_DIR = process.env.CLAUDE_PROJECT_DIR || process.cwd();

const STATE_PATH = path.join(PROJECT_DIR, ".omc", "state", "pipeline-state.json");
const NUDGE_PATH = path.join(PROJECT_DIR, ".omc", "state", "nudge-count.json");
const MAX_NUDGES = 3;

const PHASE_ARTIFACTS = {
  idea: { dir: "01-idea", file: "idea-brief.md" },
  plan: { dir: "02-plan", file: "prd.md" },
  architect: { dir: "03-architect", file: "architecture.md" },
  build: { dir: "04-build", file: "build-report.md" },
  test: { dir: "05-test", file: "test-report.md" },
  ship: { dir: "06-ship", file: "release-notes.md" },
};

function fileExists(filePath) {
  try {
    const stat = fs.statSync(filePath);
    return stat.isFile() && stat.size > 0;
  } catch {
    return false;
  }
}

function readState() {
  try {
    return JSON.parse(fs.readFileSync(STATE_PATH, "utf8"));
  } catch {
    return null;
  }
}

function writeState(state) {
  const dir = path.dirname(STATE_PATH);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(STATE_PATH, JSON.stringify(state, null, 2), "utf8");
}

function readNudgeCount(phase) {
  try {
    const data = JSON.parse(fs.readFileSync(NUDGE_PATH, "utf8"));
    return data[phase] || 0;
  } catch {
    return 0;
  }
}

function incrementNudgeCount(phase) {
  let data = {};
  try {
    data = JSON.parse(fs.readFileSync(NUDGE_PATH, "utf8"));
  } catch {
    // Start fresh
  }
  data[phase] = (data[phase] || 0) + 1;
  const dir = path.dirname(NUDGE_PATH);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(NUDGE_PATH, JSON.stringify(data, null, 2), "utf8");
  return data[phase];
}

function resetNudgeCount(phase) {
  let data = {};
  try {
    data = JSON.parse(fs.readFileSync(NUDGE_PATH, "utf8"));
  } catch {
    return;
  }
  delete data[phase];
  fs.writeFileSync(NUDGE_PATH, JSON.stringify(data, null, 2), "utf8");
}

async function main() {
  let input = "";
  for await (const chunk of process.stdin) {
    input += chunk;
  }

  let data;
  try {
    data = JSON.parse(input);
  } catch {
    data = {};
  }

  const state = readState();

  // If no pipeline is active, allow stop without checks
  if (!state || !state.current_phase || state.phase_status !== "in_progress") {
    process.stdout.write(JSON.stringify({ continue: true }));
    return;
  }

  const phase = state.current_phase;
  const phaseInfo = PHASE_ARTIFACTS[phase];

  // Update last_updated timestamp
  state.last_updated = new Date().toISOString();
  writeState(state);

  // Check if the current phase's artifact has been produced
  if (phaseInfo) {
    const artifactPath = path.join(
      PROJECT_DIR,
      ".omc",
      "artifacts",
      phaseInfo.dir,
      phaseInfo.file
    );

    if (fileExists(artifactPath)) {
      // Artifact exists — reset nudge counter and allow stop
      resetNudgeCount(phase);
      process.stdout.write(JSON.stringify({ continue: true }));
      return;
    }

    // Artifact missing — check nudge budget
    const nudgeCount = readNudgeCount(phase);
    if (nudgeCount >= MAX_NUDGES) {
      // Exhausted nudge budget — allow stop to prevent infinite loop
      resetNudgeCount(phase);
      process.stdout.write(
        JSON.stringify({
          continue: true,
          additionalContext: `Warning: Phase "${phase.toUpperCase()}" artifact (${phaseInfo.file}) was never written after ${MAX_NUDGES} nudges. The phase may need manual intervention.`,
        })
      );
      return;
    }

    // Nudge: artifact is missing, budget remaining
    incrementNudgeCount(phase);
    process.stdout.write(
      JSON.stringify({
        continue: false,
        stopReason: `Phase "${phase.toUpperCase()}" is in-progress but its output artifact (${phaseInfo.file}) has not been written yet. Please complete the phase or save progress before stopping. (Nudge ${nudgeCount + 1}/${MAX_NUDGES})`,
      })
    );
    return;
  }

  // Phase is unknown — allow stop
  process.stdout.write(JSON.stringify({ continue: true }));
}

main().catch((err) => {
  process.stderr.write(`stop hook error: ${err.message}`);
  // On error, don't block the stop
  process.stdout.write(JSON.stringify({ continue: true }));
});
