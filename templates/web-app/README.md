# Web App Starter

A minimal Next.js 14 + Tailwind CSS + Supabase starter template. Copy this directory to begin a new project.

## What's Included

- **Next.js 14** with App Router and TypeScript
- **Tailwind CSS** for styling
- **Supabase** client for database and auth
- **ESLint** configured for Next.js
- A reusable `Button` component to get started

## Setup

### 1. Install dependencies

```bash
npm install
```

### 2. Configure environment variables

```bash
cp .env.example .env.local
```

Open `.env.local` and fill in your Supabase project URL and anon key. You can find these in your [Supabase dashboard](https://app.supabase.com) under Project Settings > API.

### 3. Run the dev server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Common Commands

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server |
| `npm run build` | Production build |
| `npm run start` | Start production server |
| `npm run lint` | Run ESLint |

## Project Structure

```
app/           # Next.js App Router pages and layouts
components/    # Reusable UI components
  ui/          # Primitive UI components (Button, Input, etc.)
lib/           # Utilities and client initializations
  supabase.ts  # Supabase client
public/        # Static assets
```

## Next Steps

- Add Supabase auth with `@supabase/auth-helpers-nextjs`
- Add your database types with `supabase gen types typescript`
- Build your first page in `app/`
