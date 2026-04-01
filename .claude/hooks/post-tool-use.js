#!/usr/bin/env node
/**
 * PostToolUse Hook — Progress Tracking & State Updates
 *
 * Fires after Write/Edit tool calls. Detects when pipeline artifacts are
 * written and auto-updates .omc/state/pipeline-state.json.
 *
 * Input (stdin JSON):
 *   { tool_name, tool_input, tool_output, session_id, ... }
 *
 * Output (stdout JSON):
 *   { continue: true, additionalContext?: "..." }
 */

const fs = require("fs");
const path = require("path");

const PROJECT_DIR = process.env.CLAUDE_PROJECT_DIR || process.cwd();

const STATE_PATH = path.join(PROJECT_DIR, ".omc", "state", "pipeline-state.json");

// Map: expected parent directory → { artifact filename, phase key }
const PHASE_ARTIFACTS = [
  { dir: "01-idea", file: "idea-brief.md", phase: "idea" },
  { dir: "02-plan", file: "prd.md", phase: "plan" },
  { dir: "03-architect", file: "architecture.md", phase: "architect" },
  { dir: "04-build", file: "build-report.md", phase: "build" },
  { dir: "05-test", file: "test-report.md", phase: "test" },
  { dir: "06-ship", file: "release-notes.md", phase: "ship" },
];

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

function detectArtifactWrite(toolName, toolInput) {
  if (toolName !== "Write" && toolName !== "Edit") return null;

  const filePath = toolInput.file_path || toolInput.filePath || "";
  const normalized = filePath.replace(/\\/g, "/");

  // Must be inside .omc/artifacts/
  if (!normalized.includes(".omc/artifacts/")) return null;

  const basename = path.basename(normalized);
  const parentDir = path.basename(path.dirname(normalized));

  // Validate both filename AND parent directory to prevent false positives
  for (const entry of PHASE_ARTIFACTS) {
    if (basename === entry.file && parentDir === entry.dir) {
      return entry.phase;
    }
  }

  return null;
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
    process.stdout.write(JSON.stringify({ continue: true }));
    return;
  }

  const toolName = data.tool_name || "";
  const toolInput = data.tool_input || {};

  // Detect if a pipeline artifact was just written
  const completedPhase = detectArtifactWrite(toolName, toolInput);

  if (completedPhase) {
    let state = readState() || {
      current_phase: completedPhase,
      phase_status: "in_progress",
      phases_completed: [],
      phases_skipped: [],
      started_at: new Date().toISOString(),
      last_updated: new Date().toISOString(),
    };

    // Mark phase as completed
    if (!state.phases_completed) state.phases_completed = [];
    if (!state.phases_completed.includes(completedPhase)) {
      state.phases_completed.push(completedPhase);
    }

    state.current_phase = completedPhase;
    state.phase_status = "completed";
    state.last_updated = new Date().toISOString();

    writeState(state);

    process.stdout.write(
      JSON.stringify({
        continue: true,
        additionalContext: `Pipeline update: ${completedPhase.toUpperCase()} phase artifact written. State updated.`,
      })
    );
    return;
  }

  // Default: continue silently
  process.stdout.write(JSON.stringify({ continue: true }));
}

main().catch((err) => {
  process.stderr.write(`post-tool-use hook error: ${err.message}`);
  process.stdout.write(JSON.stringify({ continue: true }));
});
