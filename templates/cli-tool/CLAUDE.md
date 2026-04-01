# CLAUDE.md — CLI Tool Project Overlay

## Tech Stack

- **Python 3.11+**
- **Typer** — CLI framework (argument parsing, help text, subcommands)
- **Rich** — Terminal output formatting (colors, tables, progress bars)
- **pytest** — Testing framework
- **typer.testing.CliRunner** — CLI integration testing

## Project Structure

```
src/cli_tool/
    __init__.py      # Package version (__version__)
    main.py          # Root Typer app, version callback, command registration
    utils.py         # Shared utilities — console = Console() lives here
    commands/
        __init__.py
        greet.py     # Each command group gets its own module
tests/
    __init__.py
    test_cli.py
```

**Convention:** Each logical command group is a separate module under `commands/`. Register it in `main.py` with `app.add_typer()`.

## Coding Standards

- **Type hints required** on all function signatures.
- **Docstrings required** on every Typer command — Typer uses them as `--help` text.
- **Use Rich for all output.** Import `console` from `cli_tool.utils`, never use `print()` directly.
- **Errors:** Use `console.print("[red]Error: ...[/red]")` then `raise typer.Exit(code=1)`.
- Keep command modules focused — one command group per file.

## Common Commands

```bash
# Install in editable mode with dev dependencies
pip install -e ".[dev]"

# Run the CLI
cli-tool --help
cli-tool greet Alice

# Run tests
pytest
pytest -v
pytest tests/test_cli.py::test_hello

# Check types (if mypy added)
mypy src/
```

## Typer Patterns

```python
# Sub-app registration in main.py
from cli_tool.commands import greet
app.add_typer(greet.app, name="greet")

# Command with options
@app.command()
def my_cmd(name: str, count: int = typer.Option(1, help="How many times")):
    """Short description becomes --help text."""
    ...

# Exit with error
raise typer.Exit(code=1)
```
