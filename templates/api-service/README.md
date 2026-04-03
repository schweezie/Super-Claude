# API Service Starter

A minimal FastAPI + SQLAlchemy 2.0 starter for building async REST APIs with PostgreSQL.

## What's Included

- FastAPI with CORS middleware
- SQLAlchemy 2.0 async engine + session
- Alembic migrations
- Pydantic v2 settings management
- Health check endpoint
- pytest test setup

## Setup

### 1. Install dependencies

```bash
pip install -e ".[dev]"
```

### 2. Configure environment

```bash
cp .env.example .env
# Edit .env with your values
```

### 3. Run migrations

```bash
alembic upgrade head
```

### 4. Start the dev server

```bash
uvicorn app.main:app --reload
```

The API will be available at `http://localhost:8000`.
Interactive docs at `http://localhost:8000/docs`.

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | Async PostgreSQL URL | required |
| `SECRET_KEY` | Secret for signing tokens | required |
| `DEBUG` | Enable debug mode | `false` |
| `ALLOWED_ORIGINS` | Comma-separated CORS origins | `http://localhost:3000` |

## Common Commands

```bash
# Dev server with auto-reload
uvicorn app.main:app --reload

# Create a new migration
alembic revision --autogenerate -m "describe change"

# Apply migrations
alembic upgrade head

# Rollback one migration
alembic downgrade -1

# Run tests
pytest

# Run tests with coverage
pytest --cov=app
```

## Project Structure

```
app/
  api/          # Route handlers
  models/       # SQLAlchemy ORM models
  schemas/      # Pydantic request/response schemas
  config.py     # Settings (env vars)
  database.py   # DB engine and session
  main.py       # FastAPI app entry point
alembic/        # Database migrations
tests/          # pytest tests
```
