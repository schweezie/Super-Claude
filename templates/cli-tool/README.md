# cli-tool

A Python CLI tool built with [Typer](https://typer.tiangolo.com/) and [Rich](https://rich.readthedocs.io/).

## Setup

```bash
pip install -e ".[dev]"
```

## Usage

```bash
# Show help
cli-tool --help

# Show version
cli-tool --version

# Say hello
cli-tool hello

# Greet someone
cli-tool greet Alice
cli-tool greet Alice --count 3
```

## What's Included

```
src/cli_tool/
    main.py          # Typer app entry point, version callback
    utils.py         # Shared Rich console instance
    commands/
        greet.py     # Example command module
tests/
    test_cli.py      # CLI tests using CliRunner
pyproject.toml       # Project config, dependencies, entry point
```

## Running Tests

```bash
pytest
pytest -v          # verbose
pytest --tb=short  # shorter tracebacks
```

## Adding a New Command

1. Create `src/cli_tool/commands/your_command.py` with a Typer app.
2. Import and register it in `src/cli_tool/main.py`:
   ```python
   from cli_tool.commands import your_command
   app.add_typer(your_command.app, name="your-command")
   ```
3. Add tests in `tests/test_cli.py`.
