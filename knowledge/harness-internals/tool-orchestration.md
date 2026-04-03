# Tool Orchestration — Harness Internals

How tools are registered, dispatched, and executed inside the Claude Code agent harness.

## Tool Definition

Each tool is a `ToolSpec` with four fields: name, description, JSON Schema for input, and a required permission mode. Tools are collected into a flat `Vec<ToolSpec>` at startup — there is no plugin discovery at this layer, just a static registry function (`mvp_tool_specs()`). Tools are tagged with a `ToolSource` (Base or Conditional) for manifest tracking.

## Permission-Gated Dispatch

Every tool declares a `required_permission` from a tiered mode hierarchy: `ReadOnly < WorkspaceWrite < DangerFullAccess`. The runtime holds a `PermissionPolicy` with the session's active mode and per-tool overrides. Before a tool executes, the policy checks:
1. If active mode >= required mode, allow immediately.
2. If active mode is `Prompt`, or the tool requires escalation (e.g., workspace-write user calling a danger-full-access tool), invoke a `PermissionPrompter` trait to ask the user.
3. Otherwise, deny with a reason string that becomes the tool result (marked `is_error: true`).

A `ToolPermissionContext` can also block tools by exact name or prefix — used for blanket deny-lists.

## Execution Flow

The full tool execution path within a single turn:

```
API response stream → parse AssistantEvent::ToolUse blocks
  → for each (tool_use_id, tool_name, input):
    1. PermissionPolicy.authorize(tool_name, input, prompter)
    2. If denied → return ToolResult(is_error=true, reason)
    3. HookRunner.run_pre_tool_use(tool_name, input)
       - Exit 0: allow (may append feedback)
       - Exit 2: deny (skip execution, return hook message)
       - Other: warn (append message, continue)
    4. ToolExecutor.execute(tool_name, input)
       - Ok(output) or Err(ToolError)
    5. Merge pre-hook feedback into output
    6. HookRunner.run_post_tool_use(tool_name, input, output, is_error)
       - Exit 2: mark result as error
    7. Merge post-hook feedback into output
    8. Push ToolResult message to session
```

## Hook Mechanics

Hooks are shell commands configured per event type (`PreToolUse`, `PostToolUse`). The harness pipes a JSON payload to stdin and sets environment variables (`HOOK_EVENT`, `HOOK_TOOL_NAME`, `HOOK_TOOL_INPUT`, `HOOK_TOOL_OUTPUT`, `HOOK_TOOL_IS_ERROR`). The exit code determines the outcome. Multiple hooks run sequentially — a deny from any hook short-circuits the chain.

## ToolExecutor Trait

The `ToolExecutor` trait has a single method: `execute(tool_name, input) -> Result<String, ToolError>`. The `StaticToolExecutor` implementation maps tool names to closures via a `BTreeMap`. This design decouples the conversation loop from tool implementation — any struct implementing the trait can serve as the execution backend.

## Tool Pool Assembly

At startup, `assemble_tool_pool()` builds a filtered tool set based on mode flags: `simple_mode` restricts to Bash/Read/Edit, `include_mcp` controls MCP tool inclusion, and `permission_context` removes denied tools. The pool is immutable for the session.

## Design Implications for Agents

- Tool availability is determined at session start, not per-turn. An agent cannot dynamically add tools mid-conversation.
- Permission checks happen at dispatch time, not definition time — an agent can reference tools it might not be allowed to use.
- Hook feedback is injected into the tool result that the model sees, creating a feedback channel from external processes into the conversation.
- Tool errors are non-fatal to the loop. A failed tool returns an error result, and the model continues with that context.
