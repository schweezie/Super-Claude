"""cli-tool — entry point."""

from typing import Optional

import typer

from cli_tool import __version__
from cli_tool.commands import greet
from cli_tool.utils import console

app = typer.Typer(help="A minimal Python CLI built with Typer and Rich.")
app.add_typer(greet.app, name="greet")


def _version_callback(value: bool) -> None:
    if value:
        console.print(f"cli-tool version [bold]{__version__}[/bold]")
        raise typer.Exit()


@app.callback()
def main(
    version: Optional[bool] = typer.Option(
        None,
        "--version",
        "-V",
        callback=_version_callback,
        is_eager=True,
        help="Show the version and exit.",
    ),
) -> None:
    """cli-tool root — use a subcommand or --help."""


@app.command()
def hello() -> None:
    """Say hello from cli-tool."""
    console.print("[bold green]Hello from cli-tool![/bold green]")
