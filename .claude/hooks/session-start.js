#!/usr/bin/env node
/**
 * SessionStart Hook — Pipeline Status HUD
 *
 * Fires on session start/resume/clear/compact.
 * Reads pipeline state and artifact existence, then injects a status
 * summary into the assistant's context via `systemMessage`.
 *
 * Input (stdin JSON):
 *   { session_id, source ("startup"|"resume"|"clear"|"compact"), ... }
 *
 * Output (stdout JSON):
 *   { continue: true, systemMessage: "..." }
 */

const fs = require("fs");
const path = require("path");

const PROJECT_DIR = process.env.CLAUDE_PROJECT_DIR || process.cwd();

const STATE_PATH = path.join(PROJECT_DIR, ".omc", "state", "pipeline-state.json");

const PHASES = [
  { key: "idea", dir: "01-idea", artifact: "idea-brief.md" },
  { key: "plan", dir: "02-plan", artifact: "prd.md" },
  { key: "architect", dir: "03-architect", artifact: "architecture.md" },
  { key: "build", dir: "04-build", artifact: "build-report.md" },
  { key: "test", dir: "05-test", artifact: "test-report.md" },
  { key: "ship", dir: "06-ship", artifact: "release-notes.md" },
];

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

function buildStatusHUD(state) {
  const lines = [];
  lines.push("=== Pipeline Status ===");

  // Check artifact existence
  const artifactDir = path.join(PROJECT_DIR, ".omc", "artifacts");
  const phaseStatus = PHASES.map((p) => {
    const exists = fileExists(path.join(artifactDir, p.dir, p.artifact));
    const icon = exists ? "[x]" : "[ ]";
    return `  ${icon} ${p.key.toUpperCase()} (${p.artifact})`;
  });
  lines.push(...phaseStatus);

  if (state) {
    lines.push("");
    lines.push(`Current phase: ${(state.current_phase || "none").toUpperCase()}`);
    lines.push(`Phase status: ${state.phase_status || "unknown"}`);
    if (state.project_name) {
      lines.push(`Project: ${state.project_name}`);
    }
    if (state.phases_skipped && state.phases_skipped.length > 0) {
      lines.push(`Skipped: ${state.phases_skipped.join(", ")}`);
    }
  } else {
    lines.push("");
    lines.push("No pipeline state found. Run /idea to start a new project.");
  }

  lines.push("=======================");
  return lines.join("\n");
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
  const hud = buildStatusHUD(state);

  const source = data.source || "startup";
  const hint =
    source === "compact" || source === "clear"
      ? "\nPost-compaction: re-read AGENT_STATE.md and CHECKLIST.md before continuing."
      : "";

  const output = {
    continue: true,
    systemMessage: `${hud}${hint}`,
  };

  process.stdout.write(JSON.stringify(output));
}

main().catch((err) => {
  process.stderr.write(`session-start hook error: ${err.message}`);
  process.stdout.write(JSON.stringify({ continue: true }));
});
