# GSD — Getting Shit Done

**GSD (Getting Shit Done)** is a mobile-first productivity platform built on Supabase + Base44 to enable fast capture, simple daily focus, routines, habits, and human-in-the-loop AI.

---

## Tech Stack

- **Supabase** (Auth, DB, RLS, Edge Functions)
- **Base44** frontend
- **Cursor / Antigravity** for development
- **GitHub** version control
- **Notion** documentation (optional)

---

## Prerequisites

- Docker Desktop (running)
- Node.js (v18+)
- Supabase CLI (`brew install supabase/tap/supabase`)
- (Optional) GitHub CLI
- (Optional) Base44 account

---

## Quick Start

```bash
# Start local Supabase (first time will apply migrations)
supabase start

# Reset database to current migrations
supabase db reset

# Serve Edge Functions locally
supabase functions serve
```

---

## Local URLs

- **Studio:** http://localhost:54323
- **Supabase REST API:** http://localhost:54321
- **Database:** `localhost:54322`
- **Mailpit (email testing):** http://localhost:54324

---

## Project Structure

```
supabase/
  migrations/        # SQL migrations
  functions/         # Edge Functions (TypeScript)
src/
  lib/               # Shared utilities (AI client, helpers)
.env                 # Local secrets (never commit)
.env.example         # Template for env vars
```

---

## Development Workflow

**Philosophy: Small steps, clear commits.**

1. Create a feature branch (`feature/your-feature`)
2. Make small, focused changes
3. Commit with clear summary (`feat:`, `fix:`, `chore:`)
4. Open PR for review
5. Merge → deploy manually

---

## Running Edge Functions Locally

```bash
supabase functions serve
```

This starts a local Deno runtime at `http://localhost:54321/functions/v1/<function-name>`

---

## Naming Conventions

- **Branches:** `feature/`, `fix/`, `chore/`
- **Commits:** Conventional commits (`feat:`, `fix:`, `docs:`, etc.)
- **Migrations:** `YYYYMMDDHHMMSS_descriptive_name.sql`
- **Functions:** `kebab-case` (e.g. `process-capture`)

---

## Notes

- This repo contains **backend only** (Supabase)
- Frontend lives in Base44 (separate)
- All API endpoints are auto-generated via PostgREST + RLS
- Edge Functions provide custom business logic

