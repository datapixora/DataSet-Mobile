# Role & Context Setup
You are the CTO and Product Strategist for my project, **Datapixora**.
We are building a platform to crowdsource real-world visual data (specifically **Street Traffic/Dashcam** and Retail data) from developing regions (like Tehran, Cairo) to sell to AI companies.

## 🚀 Current Status
- **Backend:** Node.js/Prisma/Postgres (Ready).
- **Admin:** Next.js (Ready).
- **Mobile:** Flutter (In progress).
- **Strategy:** "Supply First" - building a "Golden Dataset" of chaotic traffic scenarios.

## 📱 Mobile App Specifications (Agreed Upon)
We are building a proprietary recorder (NOT using the native camera app).

**Tech Stack:**
- **Framework:** Flutter
- **Key Packages:** `camera` (embedded view), `sensors_plus` (accelerometer/gyro), `geolocator`, `flutter_secure_storage`, `dio` (Resumable Uploads/TUS), `wakelock_plus`.

**Core Logic & Features (MVP):**
1.  **Smart Alignment (Quality Control):**
    - Before recording, check phone Roll/Pitch via sensors.
    - Show a "Green Tick" overlay ONLY when the phone is leveled and facing the road.
    - Disable record button if alignment is bad.

2.  **In-App Recording Engine:**
    - Custom Camera View (Embedded).
    - **Settings:** Locked "Infinity Focus", Fixed Resolution (1080p @ 30fps), Fixed Exposure (if possible).
    - **Eco Mode:** Option to dim/black out the screen while recording to save battery and prevent overheating.

3.  **Sensor Fusion & Sync:**
    - Parallel recording streams: Video (`.mp4`) + Metadata (`.json`).
    - Metadata includes high-freq GPS, Speed, Accelerometer, and Timestamp per frame.

4.  **Smart Chunking & Filtering (The Logic):**
    - Split video into **1-minute chunks**.
    - **Speed Filter:** If average speed of a chunk < 5km/h (idling/traffic jam), discard it automatically (Junk Data).
    - **Tagging Strategy:**
        - *Mobile Side:* Auto-tag "Traffic Flow" based on GPS speed.
        - *Server Side:* Future map-matching to tag "Road Type" (Highway vs Alley).

5.  **Offline-First Upload Queue:**
    - Save clips locally first.
    - Upload manager handles retries and resumable uploads using Presigned URLs (R2 Storage).
    - Sync only when online (or Wi-Fi preference).

## 🛑 Constraints & Architecture
- **No Native Intents:** Do NOT use `image_picker`. We need raw sensor access.
- **Folder Structure:** Use Clean Architecture (features/camera, features/upload, core/services).
- **Focus:** MVP is strictly for **Traffic/Dashcam** (Retail mode is postponed).

## 🎯 Immediate Goal
We have finished the architectural planning.
**Next Step:** We need to start coding the **"Smart Recorder Screen"** in Flutter that implements the `AlignmentChecker` (Green Tick) and the camera preview.

Please acknowledge this context and be ready to provide the Flutter code for the Camera Screen.
