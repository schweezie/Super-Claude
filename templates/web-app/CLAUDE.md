# CLAUDE.md — Web App Project Overlay

> Project-specific instructions for Claude Code. This overlays the repo-level CLAUDE.md with conventions specific to this Next.js + Tailwind + Supabase project.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Next.js 14 (App Router) |
| Language | TypeScript (strict) |
| Styling | Tailwind CSS |
| Database / Auth | Supabase |
| Package manager | npm |

## File Conventions

```
app/                    # Pages, layouts, and route handlers
  layout.tsx            # Root layout (html, body, global styles)
  page.tsx              # Home page (/)
  (auth)/               # Auth route group (no shared layout)
  (dashboard)/          # Dashboard route group
components/
  ui/                   # Primitive components (Button, Input, Modal)
  [feature]/            # Feature-specific components
lib/
  supabase.ts           # Supabase browser client
  supabase-server.ts    # Supabase server client (for Server Components)
  utils.ts              # Shared utility functions
types/
  index.ts              # Shared TypeScript types and interfaces
```

## Coding Standards

### TypeScript

- Use `strict` mode — no `any`, no implicit types.
- Prefer `interface` for object shapes, `type` for unions and aliases.
- Export types alongside the components/functions that use them.

### React / Next.js

- **Server Components by default.** Only add `'use client'` when you need browser APIs, event handlers, or React hooks.
- Use `async/await` in Server Components for data fetching — no `useEffect` for data loading.
- Keep pages thin — move logic into components and lib functions.
- Use Next.js `Image` for all images. Use `Link` for all internal navigation.

### Styling

- Tailwind utility classes only. No inline styles, no CSS modules, no styled-components.
- Responsive-first: write mobile styles first, add `md:` / `lg:` breakpoints as needed.
- Extract repeated class combinations into a component, not a `@apply` rule.

### Supabase

- Use the browser client (`lib/supabase.ts`) in Client Components.
- Use the server client (`lib/supabase-server.ts`) in Server Components and Route Handlers.
- Never expose the service role key to the client. It belongs only in server-side code with env vars that do NOT have the `NEXT_PUBLIC_` prefix.

### File naming

- React components: `PascalCase.tsx`
- Utilities and non-component files: `kebab-case.ts`
- Route segments follow Next.js conventions: `page.tsx`, `layout.tsx`, `route.ts`, `loading.tsx`, `error.tsx`

## Common Commands

```bash
npm run dev        # Start dev server (http://localhost:3000)
npm run build      # Type-check + production build
npm run start      # Serve the production build locally
npm run lint       # Run ESLint
```

## Environment Variables

All required env vars are documented in `.env.example`. Copy it to `.env.local` before running the app.

| Variable | Where used |
|----------|-----------|
| `NEXT_PUBLIC_SUPABASE_URL` | Browser + server client |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Browser + server client |

## Do Not

- Do not put secret keys in `NEXT_PUBLIC_` variables.
- Do not use the Pages Router (`pages/` directory) — this project uses App Router exclusively.
- Do not use `getServerSideProps` or `getStaticProps` — use Server Components instead.
- Do not commit `.env.local`.
