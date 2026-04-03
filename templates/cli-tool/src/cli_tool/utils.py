"""Shared utilities for cli-tool."""

from rich.console import Console

# Single shared console instance — import this everywhere instead of using print().
console = Console()
