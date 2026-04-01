# /run — Route a Task Through the Coordinator

Invoke this command with a task description. The coordinator will analyze the task, delegate to the right specialist(s), and return a result.

## Usage

```
/run <task description>
```

## What Happens

1. The coordinator agent receives your task
2. It checks `.state/current-task.md` for any in-progress work
3. It delegates to researcher, implementer, or reviewer as needed
4. It returns a synthesized result

## Examples

```
/run Add a validation function for email addresses in src/utils/validate.ts
/run Explain how authentication works in this codebase
/run Refactor the UserService to use dependency injection
```

---

$ARGUMENTS

Invoke the coordinator agent with the above task.
