# CLAUDE.md — Project Overlay

This file gives Claude Code context about this specific project. It overrides general defaults for this monorepo.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Next.js 14 (App Router), React 18, TypeScript, Tailwind CSS |
| Backend | FastAPI, SQLAlchemy (async), Python 3.11+ |
| Database | Supabase (Postgres) |
| Auth | Supabase Auth |
| Storage | Supabase Storage |

## Monorepo Layout

```
frontend/   ← Next.js app (npm)
backend/    ← FastAPI app (pip / pyproject.toml)
```

Each side has its own dependency manager. Do not mix them. There is no root `package.json`.

## Frontend Conventions (TypeScript / Next.js)

- App Router only — no `pages/` directory.
- All components are server components by default. Add `"use client"` only when you need browser APIs or React state.
- Tailwind for all styling. No CSS modules, no styled-components.
- Fetch data in server components using the built-in `fetch`. For client-side calls, use `lib/api.ts`.
- Types go in `types/` or co-located with the file that uses them.
- File naming: `kebab-case` for files, `PascalCase` for React components.
- Path aliases: `@/` maps to the project root (configured in `tsconfig.json`).

### Common Frontend Commands

```bash
cd frontend
npm run dev        # Start dev server (port 3000)
npm run build      # Production build
npm run lint       # ESLint
npm run type-check # tsc --noEmit
```

## Backend Conventions (Python / FastAPI)

- All settings come from `app/config.py` (reads `.env` via pydantic-settings). Never hardcode secrets.
- Database sessions are managed by the `get_db` dependency in `app/database.py`. Always use it; never create sessions manually.
- Route files live in `app/api/`. Each file is a router; register it in `app/main.py`.
- SQLAlchemy models live in `app/models/`. Import `Base` from `app/models/base.py`.
- Use type hints everywhere. Return Pydantic schemas from endpoints, not raw ORM objects.
- Naming: `snake_case` for everything.

### Common Backend Commands

```bash
cd backend
source .venv/bin/activate         # Activate virtualenv
uvicorn app.main:app --reload     # Start dev server (port 8000)
pytest                            # Run tests
alembic revision --autogenerate -m "description"  # New migration
alembic upgrade head              # Apply migrations
```

## Frontend ↔ Backend Communication

The frontend calls `/api/backend/*` — Next.js rewrites these to `http://localhost:8000/*` in development (see `next.config.js`). Use the `apiFetch` helper in `frontend/lib/api.ts` for all backend calls.

In production, set `NEXT_PUBLIC_API_URL` to the deployed backend URL.

## Environment Variables

Frontend env vars must be prefixed with `NEXT_PUBLIC_` to be accessible in the browser. Backend env vars are never exposed to the frontend.

## Supabase Notes

- Use the Supabase client from `@supabase/supabase-js` in the frontend for auth and storage.
- For database access in the backend, connect directly via SQLAlchemy using the Supabase Postgres connection string.
- Row-Level Security (RLS) should be enabled on all tables in Supabase.
