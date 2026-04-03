#!/usr/bin/env node
/**
 * PreToolUse Hook — Guard Rails & Action Logging
 *
 * Blocks dangerous shell commands and logs tool invocations to a JSONL
 * audit trail at .omc/state/tool-log.jsonl.
 *
 * Input (stdin JSON):
 *   { tool_name, tool_input: { command?, file_path?, ... }, session_id, ... }
 *
 * Output (stdout JSON):
 *   { continue: true } — allow
 *   { continue: true, hookSpecificOutput: { permissionDecision: "deny" } } — block
 */

const fs = require("fs");
const path = require("path");

const PROJECT_DIR = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const LOG_PATH = path.join(PROJECT_DIR, ".omc", "state", "tool-log.jsonl");

// Dangerous bash patterns to block outright
const BLOCKED_PATTERNS = [
  { pattern: /\brm\s+(-[a-zA-Z]*r[a-zA-Z]*\s+(-[a-zA-Z]*f[a-zA-Z]*\s+)?|(-[a-zA-Z]*f[a-zA-Z]*\s+)?-[a-zA-Z]*r[a-zA-Z]*\s+)\//, reason: "Blocking recursive rm on root or system paths" },
  { pattern: /\bsudo\s+rm\b/, reason: "Blocking sudo rm" },
  { pattern: /\bDROP\s+(TABLE|DATABASE)\b/i, reason: "Blocking DROP TABLE/DATABASE" },
  { pattern: /\bgit\s+push\s+[^|;]*(-f\b|--force\b)(?!-)/, reason: "Blocking git push --force/-f (use --force-with-lease)" },
  { pattern: /\bformat\s+[A-Z]:/i, reason: "Blocking drive format" },
  { pattern: /\b(mkfs|fdisk)\b/, reason: "Blocking disk operations" },
  { pattern: /\bdd\s+.*\bof=\/dev\//, reason: "Blocking dd write to device" },
  { pattern: /\bcurl\b.*\|\s*(ba)?sh\b/, reason: "Blocking pipe-to-shell execution" },
  { pattern: /\bwget\b.*\|\s*(ba)?sh\b/, reason: "Blocking pipe-to-shell execution" },
];

function logAction(data) {
  try {
    const dir = path.dirname(LOG_PATH);
    fs.mkdirSync(dir, { recursive: true });
    const entry = {
      timestamp: new Date().toISOString(),
      tool: data.tool_name || "unknown",
      session: data.session_id || "unknown",
    };
    if (data.tool_input && data.tool_input.command) {
      entry.command = data.tool_input.command.substring(0, 200);
    }
    if (data.tool_input && (data.tool_input.file_path || data.tool_input.filePath)) {
      entry.file = data.tool_input.file_path || data.tool_input.filePath;
    }
    fs.appendFileSync(LOG_PATH, JSON.stringify(entry) + "\n");
  } catch {
    // Logging failure must not block the agent
  }
}

function checkBashGuards(command) {
  for (const { pattern, reason } of BLOCKED_PATTERNS) {
    if (pattern.test(command)) {
      return { blocked: true, reason };
    }
  }
  return { blocked: false };
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

  // Log all tool invocations for audit trail
  logAction(data);

  // Guard: Block dangerous Bash commands
  if (toolName === "Bash" && toolInput.command) {
    const result = checkBashGuards(toolInput.command);
    if (result.blocked) {
      process.stderr.write(`BLOCKED: ${result.reason}\n`);
      process.stdout.write(
        JSON.stringify({
          continue: true,
          hookSpecificOutput: {
            permissionDecision: "deny",
          },
          additionalContext: `Hook denied this command: ${result.reason}. Use a safer alternative.`,
        })
      );
      return;
    }
  }

  // Default: allow
  process.stdout.write(JSON.stringify({ continue: true }));
}

main().catch((err) => {
  process.stderr.write(`pre-tool-use hook error: ${err.message}`);
  process.stdout.write(JSON.stringify({ continue: true }));
});
