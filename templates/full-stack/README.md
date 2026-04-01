# Full-Stack Starter

Next.js 14 + FastAPI + Supabase monorepo template.

## What's Included

- **frontend/** — Next.js 14 (App Router), React 18, Tailwind CSS, TypeScript, Supabase client
- **backend/** — FastAPI, SQLAlchemy, Alembic-ready, Supabase Postgres connection

## Prerequisites

- Node.js 18+
- Python 3.11+
- A Supabase project ([supabase.com](https://supabase.com))

## Setup

### 1. Clone and configure environment

```bash
cp frontend/.env.example frontend/.env.local
cp backend/.env.example backend/.env
```

Fill in both `.env` files with your Supabase credentials.

### 2. Frontend

```bash
cd frontend
npm install
npm run dev
```

Runs at [http://localhost:3000](http://localhost:3000).

### 3. Backend

```bash
cd backend
python -m venv .venv
source .venv/bin/activate      # Windows: .venv\Scripts\activate
pip install -e ".[dev]"
uvicorn app.main:app --reload
```

Runs at [http://localhost:8000](http://localhost:8000). Docs at `/docs`.

## How Frontend Connects to Backend

`next.config.js` rewrites `/api/backend/*` to the FastAPI server, so the frontend calls `/api/backend/health` and Next.js proxies it. The `frontend/lib/api.ts` helper wraps this.

## Project Structure

```
.
├── frontend/
│   ├── app/             # Next.js App Router pages
│   ├── lib/             # Shared utilities (API client, etc.)
│   └── ...config files
├── backend/
│   ├── app/
│   │   ├── api/         # Route handlers
│   │   ├── models/      # SQLAlchemy models
│   │   ├── main.py      # FastAPI entry point
│   │   ├── config.py    # Settings (reads .env)
│   │   └── database.py  # DB session factory
│   └── pyproject.toml
└── .gitignore
```
