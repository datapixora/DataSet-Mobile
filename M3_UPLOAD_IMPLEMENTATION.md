# Photo Upload Feature Implementation (M3)

## Overview
This document describes the implementation of the Photo Upload feature for the DataSet Mobile app (Milestone 3).

## What Was Implemented

### 1. Dependencies Added
**File**: `pubspec.yaml`

Added required packages:
- `image_picker: ^1.0.7` - Camera and gallery access
- `path: ^1.8.3` - File path manipulation
- `mime: ^1.0.5` - MIME type detection
- `permission_handler: ^11.3.0` - Permission management
- `geolocator: ^11.0.0` - GPS location for metadata

### 2. Data Models
**File**: `lib/features/uploads/models/upload.dart`

Created two model classes:

#### Upload Model
- Represents an uploaded photo with all its properties
- Properties: id, campaignId, userId, fileKey, status, timestamps, rejection info, metadata
- Helper properties:
  - `isPending`: Check if upload is pending review
  - `isApproved`: Check if upload is approved
  - `isRejected`: Check if upload is rejected
- Factory constructor for JSON deserialization

#### UploadInitiateResponse Model
- Represents the response from `/uploads/initiate` endpoint
- Contains: uploadUrl (presigned S3 URL) and fileKey

### 3. Upload Service
**File**: `lib/features/uploads/services/upload_service.dart`

Comprehensive upload service with three-step upload flow:

#### Step 1: Initiate Upload
- `initiateUpload()` - Calls `POST /uploads/initiate`
- Sends: campaignId, fileName, mimeType
- Receives: presigned uploadUrl and fileKey

#### Step 2: Upload to Storage
- `uploadToStorage()` - Uploads directly to S3/R2
- Uses HTTP PUT with presigned URL
- Supports progress tracking via callback
- Handles file streaming

#### Step 3: Complete Upload
- `completeUpload()` - Calls `POST /uploads/complete`
- Sends: campaignId, fileKey, metadata
- Registers upload in backend database

#### Convenience Methods
- `uploadPhoto()` - Combines all three steps
- `getUserUploads()` - Fetch user's upload history
- `getCampaignUploads()` - Fetch uploads for specific campaign

### 4. Photo Upload Screen
**File**: `lib/features/uploads/screens/photo_upload_screen.dart`

Full-featured upload UI with:

#### Camera & Gallery Integration
- Camera capture via `ImagePicker`
- Multi-image gallery selection
- Permission handling

#### Image Management
- Grid view for selected images
- Image preview
- Remove individual images
- Add more images after initial selection

#### Metadata Collection
- GPS coordinates (latitude, longitude, accuracy)
- Timestamp
- Optional metadata support
- Graceful degradation if GPS unavailable

#### Upload Process
- Progress indicator for uploads
- Multi-image batch upload
- Individual file progress tracking
- Success/error handling
- Success dialog on completion

#### UI Features
- Empty state with camera/gallery buttons
- Image grid with thumbnails
- Remove button on each image
- "Add More" button in grid
- Upload section with progress bar
- Camera and upload buttons
- Responsive design

### 5. Campaign Detail Integration
**File**: `lib/features/campaigns/campaign_detail_screen.dart` (updated)

Changes made:
- Added import for `PhotoUploadScreen`
- Updated `_handleUpload()` method to navigate to upload screen
- Passes campaignId and campaignTitle to upload screen

## Project Structure

```
lib/features/
├── campaigns/
│   ├── campaign_detail_screen.dart    [UPDATED]
│   └── ...
└── uploads/                            [NEW]
    ├── models/
    │   └── upload.dart
    ├── services/
    │   └── upload_service.dart
    └── screens/
        └── photo_upload_screen.dart
```

## API Integration

The implementation uses the following backend endpoints:

### Upload Flow
1. **`POST /uploads/initiate`**
   - Request: `{ campaignId, fileName, mimeType }`
   - Response: `{ uploadUrl, fileKey }`

2. **`PUT <uploadUrl>`** (S3/R2 Direct Upload)
   - Binary file upload to presigned URL
   - Content-Type header with MIME type

3. **`POST /uploads/complete`**
   - Request: `{ campaignId, fileKey, metadata }`
   - Response: Upload object with status

### Additional Endpoints
- **`GET /uploads/me`** - Get user's uploads
- **`GET /uploads?campaignId=xxx`** - Get campaign uploads

## Features Summary

### Photo Selection
✅ Camera capture
✅ Gallery multi-select
✅ Image preview grid
✅ Remove individual images
✅ Add more images

### Upload Process
✅ Three-step upload flow (initiate → upload → complete)
✅ Direct S3/R2 upload
✅ Progress tracking
✅ Multi-image batch upload
✅ GPS metadata extraction
✅ Timestamp metadata

### User Experience
✅ Loading states
✅ Error handling
✅ Success feedback
✅ Permission requests
✅ Empty state messaging
✅ Responsive design

## Permissions Required

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos for campaigns</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to upload existing photos</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location access to add GPS data to photos</string>
```

## Usage Flow

1. User views campaign details
2. Taps "Upload Photos" button
3. Chooses camera or gallery
4. Selects/captures one or more photos
5. Reviews selected photos in grid
6. Can add more or remove photos
7. Taps upload button
8. System:
   - Requests GPS location (optional)
   - For each photo:
     - Initiates upload (gets presigned URL)
     - Uploads to S3/R2
     - Completes upload in backend
   - Shows progress
9. Success dialog appears
10. Returns to campaign detail

## Testing

To test this implementation:

1. **Setup**:
   ```bash
   flutter pub get
   flutter run
   ```

2. **Test camera**:
   - Go to campaign detail
   - Tap "Upload Photos"
   - Tap "Camera" button
   - Capture a photo
   - Verify it appears in grid

3. **Test gallery**:
   - Tap "Gallery" button
   - Select multiple photos
   - Verify they appear in grid

4. **Test upload**:
   - Select photos
   - Tap upload button
   - Verify progress indicator
   - Check backend for uploaded files

5. **Test metadata**:
   - Enable GPS/location
   - Upload a photo
   - Check backend metadata includes GPS coords

## Next Steps (Future Enhancements)

### M4 Candidates:
1. **Upload History Screen**
   - View all user uploads
   - Filter by status (pending/approved/rejected)
   - View rejection reasons

2. **Offline Queue**
   - Queue uploads when offline
   - Auto-sync when connection restored
   - Persistent storage

3. **Image Optimization**
   - Compress before upload
   - Resize to max dimensions
   - EXIF data handling

4. **Advanced Features**
   - Video upload support
   - Photo annotations/tags
   - Quality validation before upload
   - Duplicate detection

## Notes

- GPS metadata is optional; uploads work without it
- All permissions are requested at runtime
- Upload progress updates in real-time
- Multi-image uploads are sequential (not parallel)
- Images are uploaded at 85% quality to reduce size
- Original file MIME type is preserved

## Dependencies Used

New packages added:
- `image_picker` - Native camera/gallery access
- `path` - File path utilities
- `mime` - MIME type detection
- `permission_handler` - Runtime permissions
- `geolocator` - GPS location services

## Code Quality

- Proper error handling with try-catch
- User-friendly error messages
- Loading states for better UX
- Permission requests with fallbacks
- Clean separation of concerns (models, services, UI)
- Progress tracking for transparency
- Follows Flutter best practices
