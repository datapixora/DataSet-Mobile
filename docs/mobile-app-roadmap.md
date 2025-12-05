# Mobile App Roadmap – Visual Data Platform

This document tracks the step-by-step development of the **Mobile Contributor App** for the Visual Data / DataSet project.

The goal is that any new developer can open this file and immediately understand:
- What has been done so far
- What is currently in progress
- What should be implemented next
- Which files/modules are involved

---

## M0 – Mobile Repo Setup

**Status:** ✅ DONE

**Repository:** https://github.com/datapixora/DataSet-Mobile

**Tasks:**
- [x] Create a dedicated repository for the mobile app (`DataSet-Mobile`)
- [x] Decide on main tech stack: **Flutter** (chosen)
- [x] Add this file: `docs/mobile-app-roadmap.md` with initial plan
- [ ] Link this repo from the main backend repo README (optional but recommended)

> Notes:
> This repo is dedicated to the **contributor-facing mobile app** (Android/iOS).
> Backend lives in a separate repository (`DataSet`).
> This file must be updated at the end of each work session so the next developer knows exactly what changed and what's next.

> **2025-12-04 – Mostafa (datapixora)**
> Created repository and selected Flutter as the tech stack. Multi-platform support configured for Android, iOS, Web, Windows, macOS, and Linux.

---

## M1 – Mobile App Skeleton & Auth Layer

**Goal:** A minimal mobile app that can:
- Sign up a user
- Log in a user
- Store the access token securely on the device

**Status:** ✅ DONE


**API (from backend):**
- `POST /auth/signup`
- `POST /auth/login`

**Tasks:**
- [x] Initialize the mobile project (e.g. Flutter in `/mobile/` folder or root)
- [x] Implement basic screens:
  - Login screen
  - Signup screen
- [x] Call backend endpoints:
  - `POST /auth/signup`
  - `POST /auth/login`
- [x] Store JWT/access token securely (e.g. `shared_preferences` or secure storage)
- [x] Document how to run the app (in this repo's README)

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


**Files (implemented):**
- `lib/main.dart` (entry point)
- `lib/core/api_client.dart` (HTTP + auth token helper)
- `lib/core/config.dart` (API configuration)
- `lib/features/auth/auth_service.dart` (signup/login logic)
- `lib/features/auth/login_screen.dart` (login UI)
- `lib/features/auth/signup_screen.dart` (signup UI)

At the end of this milestone:
- [x] Update this file (M1 → DONE)
- [x] Add a short changelog entry (who did what & when)

---

## M2 – Campaign List & Detail Screens

**Goal:** After login, the user should see a list of active campaigns and view detailed information about each campaign.

**Status:** ✅ DONE

**API (from backend):**
- `GET /campaigns` - Fetch all campaigns
- `GET /campaigns/:id` - Fetch specific campaign details

**Tasks:**
- [x] Fetch campaigns from backend
- [x] Display them in a list (title, short description, payout)
- [x] Handle loading / error / empty state
- [x] Navigate from Auth → CampaignList after successful login
- [x] Implement search functionality
- [x] Implement filter by status (All/Active/Expired)
- [x] Add pull-to-refresh
- [x] Create campaign detail screen
- [x] Display comprehensive campaign information
- [x] Show progress tracking (uploaded/required photos)
- [x] Add upload button placeholder for M3

**Files (implemented):**
- `lib/features/campaigns/models/campaign.dart` - Campaign data model
- `lib/features/campaigns/services/campaign_service.dart` - API service
- `lib/features/campaigns/campaign_list_screen.dart` - Campaign list UI
- `lib/features/campaigns/campaign_detail_screen.dart` - Campaign detail UI
- `IMPLEMENTATION.md` - Complete implementation documentation

> **2025-12-05 – Claude Code + Mostafa**
> Completed M2: Implemented comprehensive campaign browsing system.
> Features:
> - Campaign model with JSON serialization and helper properties
> - Campaign service for API integration
> - Campaign list screen with search, filter (All/Active/Expired), and pull-to-refresh
> - Campaign detail screen with progress tracking and upload button placeholder
> - Updated auth screens to navigate to new campaign list
> - Added complete implementation documentation
>
> The placeholder screen can now be removed as it has been replaced with full functionality.

---

## M3 – Photo Upload Flow (Initiate → Upload → Complete)

**Goal:** From a campaign detail screen, the user can select photos from camera or gallery and submit them to that campaign.

**Status:** ✅ DONE

**API (from backend):**
- `POST /uploads/initiate` - Get presigned upload URL
- Upload binary file directly to `uploadUrl` (Cloudflare R2/S3)
- `POST /uploads/complete` - Finalize upload
- `GET /uploads/me` - Get user uploads
- `GET /uploads?campaignId=xxx` - Get campaign uploads

**Tasks:**
- [x] Campaign detail screen (completed in M2)
- [x] Add image picker dependencies (`image_picker`, `geolocator`, `permission_handler`, etc.)
- [x] Implement photo source selection (Camera vs Gallery)
- [x] Integrate camera functionality
- [x] Integrate gallery picker with multi-select
- [x] Add image preview before upload
- [x] Implement multi-image selection
- [x] Create UploadService class
- [x] Integrate `/uploads/initiate`:
  - Send `campaignId`, `fileName`, `mimeType`
  - Receive `uploadUrl` and `fileKey`
- [x] Upload image file to `uploadUrl` (S3-compatible with PUT)
- [x] Implement upload progress tracking
- [x] Call `/uploads/complete` with:
  - `campaignId`
  - `fileKey`
  - `metadata` (GPS, tags, etc.)
- [x] Add location/GPS metadata extraction
- [x] Show success / error feedback to the user
- [ ] Handle offline upload queue (deferred to future)

**Files (implemented):**
- `lib/features/uploads/models/upload.dart` - Upload and UploadInitiateResponse models
- `lib/features/uploads/services/upload_service.dart` - Complete upload API logic
- `lib/features/uploads/screens/photo_upload_screen.dart` - Full upload UI with preview
- `lib/features/campaigns/campaign_detail_screen.dart` - Wired upload button
- `pubspec.yaml` - Added dependencies
- `M3_UPLOAD_IMPLEMENTATION.md` - Complete documentation

> **2025-12-05 – Claude Code + Mostafa**
> Completed M3: Implemented comprehensive photo upload system.
> Features:
> - Camera and gallery integration with multi-image selection
> - Three-step upload flow (initiate → S3 upload → complete)
> - Upload progress tracking with visual feedback
> - GPS metadata extraction (latitude, longitude, accuracy)
> - Image preview grid with add/remove functionality
> - Permission handling for camera and location
> - Success/error feedback with user-friendly messages
> - Direct S3/R2 upload using presigned URLs
> - Batch upload support for multiple images
>
> Users can now capture photos or select from gallery and upload them to campaigns with full progress tracking and metadata.

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
