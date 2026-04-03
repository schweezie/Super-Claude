# /review — Review Recent Changes

Invokes the reviewer agent on the most recently changed files. Use after the implementer completes a task to get a quality gate before considering work done.

## Usage

```
/review
/review <specific file or directory>
```

## What Happens

1. Finds recently modified files (or uses the path you provide)
2. Delegates to the reviewer agent with those files as context
3. Returns a structured verdict: APPROVED, CHANGES REQUESTED, or BLOCKED

## Examples

```
/review
/review src/utils/validate.ts
/review src/services/
```

---

$ARGUMENTS

If an argument was provided, review that specific file or directory.
If no argument was provided, read `.state/current-task.md` to find which files were recently changed, then review those.

Invoke the reviewer agent with those files as context.
