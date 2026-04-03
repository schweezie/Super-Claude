"""CLI integration tests using Typer's CliRunner."""

from typer.testing import CliRunner

from cli_tool import __version__
from cli_tool.main import app

runner = CliRunner()


def test_help() -> None:
    result = runner.invoke(app, ["--help"])
    assert result.exit_code == 0
    assert "cli-tool" in result.output.lower() or "help" in result.output.lower()


def test_version() -> None:
    result = runner.invoke(app, ["--version"])
    assert result.exit_code == 0
    assert __version__ in result.output


def test_hello() -> None:
    result = runner.invoke(app, ["hello"])
    assert result.exit_code == 0
    assert "Hello" in result.output


def test_greet_basic() -> None:
    result = runner.invoke(app, ["greet", "Alice"])
    assert result.exit_code == 0
    assert "Hello, Alice!" in result.output


def test_greet_count() -> None:
    result = runner.invoke(app, ["greet", "Bob", "--count", "3"])
    assert result.exit_code == 0
    assert result.output.count("Hello, Bob!") == 3


def test_greet_shout() -> None:
    result = runner.invoke(app, ["greet", "Alice", "--shout"])
    assert result.exit_code == 0
    assert "HELLO, ALICE!" in result.output


def test_greet_missing_name() -> None:
    result = runner.invoke(app, ["greet"])
    assert result.exit_code != 0
