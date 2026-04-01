"""Greet command group — example of a Typer sub-app."""

import typer

from cli_tool.utils import console

app = typer.Typer(help="Greeting commands.")


@app.command()
def greet(
    name: str = typer.Argument(..., help="Name to greet."),
    count: int = typer.Option(1, "--count", "-n", help="Number of times to greet.", min=1),
    shout: bool = typer.Option(False, "--shout", "-s", help="Print in uppercase."),
) -> None:
    """Greet NAME with an optional repeat count."""
    message = f"Hello, {name}!"
    if shout:
        message = message.upper()
    for _ in range(count):
        console.print(message)
