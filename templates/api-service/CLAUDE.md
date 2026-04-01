# CLAUDE.md — API Service Project Overlay

> Project-specific instructions for Claude Code. Overrides repo-level defaults where noted.

## Tech Stack

| Layer | Library | Version |
|-------|---------|---------|
| Web framework | FastAPI | ^0.115 |
| ORM | SQLAlchemy | 2.0 (async) |
| Validation | Pydantic | v2 |
| Migrations | Alembic | ^1.13 |
| Database | PostgreSQL | 15+ |
| Server | Uvicorn | ^0.30 |
| Settings | pydantic-settings | ^2.0 |
| Testing | pytest + httpx | latest |

## File Conventions

```
app/
  api/           # FastAPI routers — one file per resource (users.py, items.py)
  models/        # SQLAlchemy ORM models — one file per table
  schemas/       # Pydantic v2 schemas — one file per resource
  config.py      # Single Settings class, loaded once at startup
  database.py    # Engine, session factory, get_db dependency
  main.py        # App factory — CORS, routers, lifespan
alembic/
  env.py         # Alembic env — imports Base.metadata for autogenerate
  versions/      # Generated migration files (do not hand-edit)
tests/
  conftest.py    # Shared fixtures (test client, test DB session)
  test_*.py      # One test file per router file
```

### Naming Conventions

- Router files: `app/api/{resource}.py` (plural noun, snake_case)
- Model files: `app/models/{resource}.py` (singular noun)
- Schema files: `app/schemas/{resource}.py` (singular noun)
- Schema class names: `{Resource}Create`, `{Resource}Read`, `{Resource}Update`
- Router prefix: `/{resource}` (plural)

## Coding Standards

### Always

- Use full type hints on all function signatures and return types
- Use `async def` for route handlers and DB operations
- Use `Annotated` + `Depends` for dependency injection
- Use SQLAlchemy 2.0 style (`mapped_column`, `Mapped`, `select()`)
- Use Pydantic v2 style (`model_config = ConfigDict(...)`, not `class Config`)
- Validate all env vars through the `Settings` class — never use `os.environ` directly

### Never

- Do not use synchronous SQLAlchemy sessions in async routes
- Do not import `settings` at module level outside `config.py` — use `Depends(get_settings)`
- Do not put business logic in route handlers — move to service functions
- Do not hardcode connection strings or secrets anywhere

### Route Handler Pattern

```python
@router.get("/{id}", response_model=ThingRead)
async def get_thing(
    id: int,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> ThingRead:
    result = await db.execute(select(Thing).where(Thing.id == id))
    thing = result.scalar_one_or_none()
    if thing is None:
        raise HTTPException(status_code=404, detail="Not found")
    return thing
```

### Adding a New Resource

1. Create `app/models/{resource}.py` — define SQLAlchemy model
2. Create `app/schemas/{resource}.py` — define Pydantic schemas
3. Create `app/api/{resource}.py` — define router with CRUD endpoints
4. Import model in `app/models/__init__.py` so Alembic sees it
5. Include router in `app/main.py`
6. Run `alembic revision --autogenerate -m "add {resource} table"`
7. Run `alembic upgrade head`
8. Add tests in `tests/test_{resource}.py`

## Common Commands

```bash
# Start dev server
uvicorn app.main:app --reload

# Generate migration after model changes
alembic revision --autogenerate -m "describe the change"

# Apply all pending migrations
alembic upgrade head

# Rollback last migration
alembic downgrade -1

# Run all tests
pytest

# Run tests with coverage report
pytest --cov=app --cov-report=term-missing

# Run a single test file
pytest tests/test_health.py -v
```

## Environment Variables

All vars are defined in `.env` (never committed) and typed in `app/config.py`.

| Variable | Type | Required |
|----------|------|----------|
| `DATABASE_URL` | `str` | Yes — must use `postgresql+asyncpg://` scheme |
| `SECRET_KEY` | `str` | Yes |
| `DEBUG` | `bool` | No — defaults to `False` |
| `ALLOWED_ORIGINS` | `str` | No — comma-separated, defaults to `http://localhost:3000` |

## Testing Guidelines

- Use `httpx.AsyncClient` with `ASGITransport` for async route testing
- Use an in-memory SQLite (`aiosqlite`) or a dedicated test PostgreSQL DB
- Reset DB state between tests using fixtures, not `autouse` teardowns on prod DB
- Test the HTTP contract (status codes, response shape), not internal implementation
