# Mobile App Roadmap – Visual Data Platform

This document tracks the step-by-step development of the **Mobile Contributor App** for the Visual Data / DataSet project.

The goal is that any new developer can open this file and immediately understand:
- What has been done so far
- What is currently in progress
- What should be implemented next
- Which files/modules are involved

---

## M0 – Mobile Repo Setup

**Status:** IN PROGRESS

**Repository:** https://github.com/datapixora/DataSet-Mobile

**Tasks:**
- [x] Create a dedicated repository for the mobile app (`DataSet-Mobile`)
- [ ] Decide on main tech stack:
  - Option A: Flutter
  - Option B: React Native
- [ ] Add this file: `docs/mobile-app-roadmap.md` with initial plan
- [ ] Link this repo from the main backend repo README (optional but recommended)

> Notes:  
> This repo is dedicated to the **contributor-facing mobile app** (Android/iOS).  
> Backend lives in a separate repository (`DataSet`).  
> This file must be updated at the end of each work session so the next developer knows exactly what changed and what’s next.

---

## M1 – Mobile App Skeleton & Auth Layer

**Goal:** A minimal mobile app that can:
- Sign up a user
- Log in a user
- Store the access token securely on the device

**Status:** IN PROGRESS


**API (from backend):**
- `POST /auth/signup`
- `POST /auth/login`

**Tasks:**
- [ ] Initialize the mobile project (e.g. Flutter in `/mobile/` folder or root)
- [ ] Implement basic screens:
  - Login screen
  - Signup screen
- [ ] Call backend endpoints:
  - `POST /auth/signup`
  - `POST /auth/login`
- [ ] Store JWT/access token securely (e.g. `shared_preferences` or secure storage)
- [ ] Document how to run the app (in this repo’s README)

> **2025-12-04 – Mostafa (datapixora)**  
> Started M1: added core API client and basic auth layer in Flutter.  
> Created:
> - `lib/core/config.dart`
> - `lib/core/api_client.dart`
> - `lib/features/auth/auth_service.dart`
> - `lib/features/auth/login_screen.dart`

> **2025-12-04 – Mostafa (datapixora)**  
> Configured Flutter dependencies and fixed pub access (using flutter-io.cn mirror).  
> `pubspec.yaml` now includes `http` and `shared_preferences`, and `LoginScreen` is wired as the app home in `main.dart`.

> **2025-12-04 – Mostafa (datapixora)**  
> Continued M1: added basic signup flow and navigation to a placeholder campaign list screen.  
> Created:
> - `lib/features/auth/signup_screen.dart`
> - `lib/features/campaigns/campaign_list_placeholder.dart`
> Updated:
> - `lib/features/auth/login_screen.dart` to navigate on success and link to signup.


**Files (proposed for Flutter):**
- `lib/main.dart` (entry point)
- `lib/api_client.dart` (HTTP + auth token helper)
- `lib/services/auth_service.dart` (signup/login logic)

At the end of this milestone:
- [ ] Update this file (M1 → IN PROGRESS / DONE)
- [ ] Add a short changelog entry (who did what & when)

---

## M2 – Campaign List Screen

**Goal:** After login, the user should see a list of active campaigns.

**Status:** TODO

**API (from backend):**
- `GET /campaigns`

**Tasks:**
- [ ] Fetch campaigns from backend
- [ ] Display them in a list (title, short description, payout)
- [ ] Handle loading / error / empty state
- [ ] Navigate from Auth → CampaignList after successful login

**Files (proposed):**
- `lib/services/campaign_service.dart`
- `lib/screens/campaign_list_screen.dart`

---

## M3 – Upload Flow (Initiate → Upload → Complete)

**Goal:** From a campaign detail screen, the user can select a photo and submit it to that campaign.

**Status:** TODO

**API (from backend):**
- `POST /uploads/initiate`
- Upload binary file directly to `uploadUrl` (Cloudflare R2/S3)
- `POST /uploads/complete`

**Tasks:**
- [ ] Implement campaign detail screen
- [ ] Integrate `/uploads/initiate`:
  - Send `campaignId`, `fileName`, `mimeType`
  - Receive `uploadUrl` and `fileKey`
- [ ] Upload image file to `uploadUrl`
- [ ] Call `/uploads/complete` with:
  - `campaignId`
  - `fileKey`
  - `metadata` (GPS, tags, etc. – to be defined)
- [ ] Show success / error feedback to the user

**Files (proposed):**
- `lib/services/upload_service.dart`
- `lib/screens/campaign_detail_screen.dart`

---

## M4 – Earnings & Gamification (Future)

**Goal:** Show the user how much they have earned and make the experience feel like a game.

**Status:** FUTURE

**Possible APIs (from backend):**
- `GET /users/earnings`
- `GET /users/transactions`

**Ideas:**
- [ ] Total confirmed earnings
- [ ] Pending earnings per campaign
- [ ] Recent accepted/rejected submissions
- [ ] XP / levels / streaks / progress bar

---

## Update Rules

When you complete a step:

1. Update the **Status** field for that milestone:
   - `TODO` → `IN PROGRESS` → `DONE`
2. Add a short note:
   - Date
   - Your name
   - What exactly changed (files, endpoints, behavior)
3. If you changed any API contract, document it here and in the backend docs.

Example log entry:

> **2025-12-04 – Mostafa**  
> Created `DataSet-Mobile` repo and added `docs/mobile-app-roadmap.md`.  
> Next: decide on stack (Flutter vs React Native) and start M1 auth skeleton.
