# Visual Data Platform — System Overview

## Purpose
Single reference for how backend, admin, and mobile fit together: architecture, flows, environments, and change management.

## Components
- Backend API (`DataSet`): Node.js/Express + TypeScript, Prisma/PostgreSQL, Cloudflare R2 (S3-compatible).
- Admin Dashboard (`visual-data-admin`): Next.js 15 + TypeScript + Tailwind + Zustand; talks to Backend API.
- Mobile App (`DataSet-Mobile`): Flutter client; talks to Backend API.
- Storage: Cloudflare R2 for uploads; metadata lives in Postgres.
- AuthN/AuthZ: JWT (access + refresh), roles (ADMIN/USER).

## Architecture (text)
Clients (Admin, Mobile) → Backend API (REST) → Postgres (Prisma ORM)  
Uploads: Client requests presigned URL → R2 direct upload → Backend records metadata and review status.

## Core Flows
1) Auth
   - Signup/Login → Backend issues `accessToken` + `refreshToken`.
   - Clients store token (admin: localStorage; mobile: secure storage). Bearer token on all requests.
2) Campaign lifecycle
   - Admin creates/updates campaigns.
   - Clients list campaigns; recommended endpoint for personalized feed.
3) Upload lifecycle
   - Client asks for presigned URL → uploads to R2 → notifies backend with metadata.
   - Admin reviews: approve/reject → payout amount recorded.
4) Earnings/Payouts
   - Backend tracks balances/transactions; clients show earnings summaries and history.
5) Roles & Permissions
   - USER: browse campaigns, upload, view earnings/history.
   - ADMIN: manage campaigns, review uploads, view users/analytics.

## Environments
| Env      | API Base URL                       | Admin URL                         | Mobile API base                  | Notes                          |
|----------|------------------------------------|-----------------------------------|----------------------------------|--------------------------------|
| Local    | http://localhost:3000/v1           | http://localhost:3001 (or dev)    | http://localhost:3000/v1         | Run API+DB locally; seed data. |
| Staging  | https://staging-api.example.com/v1 | https://staging-admin.example.com | https://staging-api.example.com/v1 | Use staging DB/R2 bucket.     |
| Prod     | https://visual-data-api.onrender.com/v1 | (prod admin URL)              | https://visual-data-api.onrender.com/v1 | Prod DB/R2 bucket.           |

Env vars (examples):
- Backend: `DATABASE_URL`, `JWT_SECRET`, `REFRESH_TOKEN_SECRET`, `R2_*`, `PORT`, `NODE_ENV`
- Admin: `NEXT_PUBLIC_API_URL`
- Mobile: `API_BASE_URL` (or equivalent per flavor)

## API Contract & Versioning
- Follow semantic versioning for public API (`v1` path). Breaking changes require a new version or a migration note.
- Maintain `docs/API_CHANGELOG.md` in backend; surface impactful changes in admin/mobile READMEs.
- When changing schema/endpoints:
  1) Add changelog entry (what changed, client impact, migration steps).
  2) Deploy backend behind feature flags or additive changes first.
  3) Update clients to consume new fields/endpoints.
  4) Remove deprecated fields after clients migrate.

## Release Sequence (cross-repo)
1) Backend change (schema/endpoint) lands → deploy to staging.
2) Admin/Mobile align with staging API → verify key flows (auth, uploads, campaigns).
3) Tag releases: backend first, then clients. Note required backend version in client release notes.

## Testing Responsibilities
- Backend: unit (services/utils), integration (routes/db via Prisma test DB), smoke on staging, health check `/v1/health`.
- Admin: lint/tsc, component/unit tests, basic e2e happy paths for auth/campaigns/uploads.
- Mobile: unit/widget tests, API integration against staging, device targets (Android/iOS/Web if enabled).
- Shared manual checks before prod: login, campaign list/detail, upload + review + approve, earnings summary.

## Observability & Ops
- Health: `/v1/health` (backend); ensure admin/mobile display friendly errors when unreachable.
- Logging: backend structured logs for auth, upload, review, payouts.
- Storage: R2 bucket CORS/public access for images as needed; keep secrets out of clients.
- DB migrations: run Prisma migrations during deploy; keep seed script for smoke data.

## Data & Security
- JWT expiration + refresh; enforce ADMIN role on admin endpoints.
- PII (emails) and financial data in Postgres; never stored in clients beyond session token.
- Uploads: validate type/size; presigned URLs time-limited; metadata recorded server-side.
- Secrets: `.env` files not committed; rotate `JWT_SECRET`/`REFRESH_TOKEN_SECRET` and R2 keys as needed.

## Workflows (multi-developer)
- Branching: feature branches → PR → required checks (lint/tests) → review → merge.
- PR template: summary, linked issue, tests run, screenshots (admin/mobile), API changes noted.
- Issue templates: feature/bug/tech-debt with acceptance criteria and testing expectations.
- Definition of Done: code + tests + docs (README/CHANGELOG) updated + environments noted if needed.

## Quick Links
- Backend repo: https://github.com/datapixora/DataSet
- Admin repo: https://github.com/datapixora/visual-data-admin
- Mobile repo: https://github.com/datapixora/DataSet-Mobile
- API docs: https://github.com/datapixora/DataSet/blob/main/docs/API.md
- Roadmaps: `ROADMAP.md` (backend/admin), `docs/mobile-app-roadmap.md` (mobile)
